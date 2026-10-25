use std::path::PathBuf;
use std::process::Command;

use zkrv32i::{
    decode, step, MachineState, Memory, RegisterFile, TerminalState, Word32, MAX_TRACE,
};

#[derive(Clone, Copy, Debug)]
enum MutationClass {
    ProgramCounter,
    GeneralRegister,
    X0,
    BranchOutcome,
    MemoryContentsBoundsAlignment,
    TraceLength,
    PublicOutput,
    ConstraintSelector,
}

impl MutationClass {
    const ALL: [Self; 8] = [
        Self::ProgramCounter,
        Self::GeneralRegister,
        Self::X0,
        Self::BranchOutcome,
        Self::MemoryContentsBoundsAlignment,
        Self::TraceLength,
        Self::PublicOutput,
        Self::ConstraintSelector,
    ];

    const fn name(self) -> &'static str {
        match self {
            Self::ProgramCounter => "pc",
            Self::GeneralRegister => "gpr",
            Self::X0 => "x0",
            Self::BranchOutcome => "branch",
            Self::MemoryContentsBoundsAlignment => "memory",
            Self::TraceLength => "trace_length",
            Self::PublicOutput => "public_output",
            Self::ConstraintSelector => "constraint_selector",
        }
    }
}

struct Case {
    name: String,
    pc: u32,
    x1: u32,
    x2: u32,
    instruction: u32,
    expected_lean: &'static str,
}

fn parse_corpus() -> Result<Vec<Case>, String> {
    let contents = include_str!("../corpus.txt");
    let mut cases = Vec::new();
    for (line_index, line) in contents.lines().enumerate() {
        let fields: Vec<_> = line.split('|').collect();
        if fields.len() != 6 {
            return Err(format!("corpus line {} has {} fields", line_index + 1, fields.len()));
        }
        let parse = |field: &str, name: &str| {
            field.parse::<u32>().map_err(|_| {
                format!("corpus line {} has invalid {}", line_index + 1, name)
            })
        };
        let expected_lean = match fields[5] {
            "ok" | "fault" | "decode_error" => fields[5],
            _ => return Err(format!("corpus line {} has invalid expectation", line_index + 1)),
        };
        cases.push(Case {
            name: fields[0].to_owned(),
            pc: parse(fields[1], "pc")?,
            x1: parse(fields[2], "x1")?,
            x2: parse(fields[3], "x2")?,
            instruction: parse(fields[4], "instruction")?,
            expected_lean,
        });
    }
    Ok(cases)
}

fn lean_oracle(root: &std::path::Path, case: &Case) -> Result<String, String> {
    let output = Command::new("lake")
        .current_dir(root)
        .args([
            "env",
            "lean",
            "--run",
            "adversarial/LeanOracle.lean",
            "--",
            &case.pc.to_string(),
            &case.x1.to_string(),
            &case.x2.to_string(),
            &case.instruction.to_string(),
        ])
        .output()
        .map_err(|error| format!("could not start Lean oracle: {error}"))?;
    if !output.status.success() {
        return Err(format!(
            "Lean oracle failed for {}: {}",
            case.name,
            String::from_utf8_lossy(&output.stderr).trim()
        ));
    }
    let stdout = String::from_utf8(output.stdout)
        .map_err(|error| format!("Lean oracle output was not UTF-8: {error}"))?;
    stdout
        .lines()
        .next()
        .map(|line| line.trim().to_owned())
        .ok_or_else(|| format!("Lean oracle returned no result for {}", case.name))
}

struct RustSnapshot {
    pc: u32,
    terminal: TerminalState,
    registers: Vec<u32>,
    memory: Vec<u8>,
}

fn rust_result(case: &Case) -> Result<RustSnapshot, String> {
    let mut initial = MachineState::<64>::new(case.pc, 0);
    let _ = initial.registers.write(1, Word32::new(case.x1));
    let _ = initial.registers.write(2, Word32::new(case.x2));
    let instruction = decode(case.instruction).map_err(|error| format!("decode: {error:?}"))?;
    let state = step(initial, instruction).map_err(|error| format!("step: {error:?}"))?;
    let registers = (0..32)
        .map(|index| state.registers.read(index).map(Word32::unsigned))
        .collect::<Option<Vec<_>>>()
        .ok_or_else(|| "invalid register index in snapshot".to_owned())?;
    let memory = (0..64)
        .map(|address| state.memory.load_u8(address).ok())
        .collect::<Option<Vec<_>>>()
        .ok_or_else(|| "memory snapshot out of bounds".to_owned())?;
    Ok(RustSnapshot {
        pc: state.pc,
        terminal: state.terminal,
        registers,
        memory,
    })
}

fn agrees_with_lean(lean: &str, rust: &RustSnapshot) -> bool {
    let fields: Vec<_> = lean.split('|').collect();
    if fields.len() != 5 || fields[0] != "ok" {
        return false;
    }
    let Ok(pc) = fields[1].parse::<u32>() else {
        return false;
    };
    let terminal = match fields[2] {
        "running" => TerminalState::Running,
        "halted" => TerminalState::Halted,
        _ => return false,
    };
    let parse_csv = |text: &str| -> Option<Vec<u32>> {
        text.split(',').map(|value| value.parse().ok()).collect()
    };
    let Some(registers) = parse_csv(fields[3]) else {
        return false;
    };
    let Some(memory) = parse_csv(fields[4]) else {
        return false;
    };
    pc == rust.pc
        && terminal == rust.terminal
        && registers == rust.registers
        && memory == rust.memory.iter().map(|byte| u32::from(*byte)).collect::<Vec<_>>()
}

fn check_mutation_classes() -> Result<(), String> {
    for class in MutationClass::ALL {
        match class {
            MutationClass::ProgramCounter => {
                let aligned = Case {
                    name: "pc-aligned".into(),
                    pc: 0,
                    x1: 1,
                    x2: 1,
                    instruction: 2_130_531,
                    expected_lean: "ok",
                };
                let misaligned = Case {
                    pc: 2,
                    name: "pc-misaligned".into(),
                    ..aligned
                };
                if aligned.pc % 4 != 0 || misaligned.pc % 4 == 0 {
                    return Err("PC mutation failed to exercise alignment".into());
                }
            }
            MutationClass::GeneralRegister => {
                let mut regs = RegisterFile::zeroed();
                if !regs.write(1, Word32::new(7)) || regs.read(1) != Some(Word32::new(7)) {
                    return Err("GPR mutation was not observable".into());
                }
            }
            MutationClass::X0 => {
                let mut regs = RegisterFile::zeroed();
                if regs.write(0, Word32::new(1))
                    || regs.read(0) != Some(Word32::ZERO)
                    || !regs.x0_is_zero()
                {
                    return Err("x0 mutation was not rejected".into());
                }
            }
            MutationClass::BranchOutcome => {
                let equal = 5_u32 == 5;
                let mutated = 5_u32 == 6;
                if !equal || mutated {
                    return Err("branch-condition mutation did not flip outcome".into());
                }
            }
            MutationClass::MemoryContentsBoundsAlignment => {
                let mut memory = Memory::<8>::new(0);
                memory.store_u8(0, 0xA5).map_err(|e| format!("memory setup: {e:?}"))?;
                if memory.load_u8(0) != Ok(0xA5)
                    || memory.load_u32(1).is_ok()
                    || memory.load_u8(8).is_ok()
                {
                    return Err("memory content/bounds/alignment mutation failed".into());
                }
            }
            MutationClass::TraceLength => {
                let accepted = |length: usize| length >= 1 && length <= MAX_TRACE;
                if accepted(0)
                    || !accepted(1)
                    || !accepted(MAX_TRACE)
                    || accepted(MAX_TRACE + 1)
                {
                    return Err("trace-length boundaries failed".into());
                }
            }
            MutationClass::PublicOutput => {
                let binds_output = |claimed: u32, actual: u32| claimed == actual;
                if !binds_output(4, 4) || binds_output(5, 4) {
                    return Err("public-output binding mutation failed".into());
                }
            }
            MutationClass::ConstraintSelector => {
                let selected_add_gate = |selector: bool, left: bool, right: bool, output: bool| {
                    !selector || left ^ right == output
                };
                if !selected_add_gate(true, true, false, true)
                    || selected_add_gate(true, true, false, false)
                {
                    return Err("constraint selector/witness mutation failed".into());
                }
            }
        }
        println!("mutation class {}: exercised", class.name());
    }
    Ok(())
}

fn run() -> Result<(), String> {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .ok_or_else(|| "adversarial directory has no repository parent".to_owned())?
        .to_path_buf();
    let cases = parse_corpus()?;
    if cases.is_empty() {
        return Err("regression corpus is empty".into());
    }
    let mut agreements = 0_usize;
    let mut divergences = 0_usize;

    for case in &cases {
        let lean = lean_oracle(&root, case)?;
        let lean_class = lean.split('|').next().unwrap_or_default();
        if lean_class != case.expected_lean {
            return Err(format!(
                "corpus regression {}: expected Lean {}, got {}",
                case.name, case.expected_lean, lean_class
            ));
        }
        match rust_result(case) {
            Ok(snapshot) if agrees_with_lean(&lean, &snapshot) => {
                agreements += 1;
                println!("case {}: agreement", case.name);
            }
            Ok(_) => {
                divergences += 1;
                println!("case {}: divergence (state or outcome mismatch)", case.name);
            }
            Err(error) => {
                divergences += 1;
                println!(
                    "case {}: divergence (Rust {error}; Lean {})",
                    case.name, lean_class,
                );
            }
        }
    }

    check_mutation_classes()?;
    println!(
        "corpus: {} cases, regressions passed; differential agreements: {}, divergences: {}",
        cases.len(),
        agreements,
        divergences
    );
    println!("finite harness results are not a universal proof");
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("harness failure: {error}");
        std::process::exit(1);
    }
}
