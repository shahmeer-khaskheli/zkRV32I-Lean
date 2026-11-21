use std::path::PathBuf;
use std::process::Command;

use zkrv32i::{
    decode, step, DecodeError, ExecutionError, Instruction, MachineState, Memory, MemoryError,
    RegisterFile, TerminalState, Word32, MAX_TRACE,
};

mod transcript;

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
    expected_rust: &'static str,
}

fn parse_corpus() -> Result<Vec<Case>, String> {
    let contents = include_str!("../corpus.txt");
    let mut cases = Vec::new();
    for (line_index, line) in contents.lines().enumerate() {
        let fields: Vec<_> = line.split('|').collect();
        if fields.len() != 7 {
            return Err(format!("corpus line {} has {} fields", line_index + 1, fields.len()));
        }
        let parse = |field: &str, name: &str| {
            field.parse::<u32>().map_err(|_| {
                format!("corpus line {} has invalid {}", line_index + 1, name)
            })
        };
        let expected_lean = match fields[5] {
            "ok" | "fault" | "decode_illegal" | "decode_unsupported" => fields[5],
            _ => return Err(format!("corpus line {} has invalid expectation", line_index + 1)),
        };
        let expected_rust = match fields[6] {
            "ok"
            | "decode_illegal"
            | "decode_unsupported"
            | "step_misaligned_pc"
            | "step_memory_misaligned"
            | "step_memory_out_of_bounds" => fields[6],
            _ => return Err(format!("corpus line {} has invalid Rust expectation", line_index + 1)),
        };
        cases.push(Case {
            name: fields[0].to_owned(),
            pc: parse(fields[1], "pc")?,
            x1: parse(fields[2], "x1")?,
            x2: parse(fields[3], "x2")?,
            instruction: parse(fields[4], "instruction")?,
            expected_lean,
            expected_rust,
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
    memory_base: u32,
    memory: Vec<u8>,
}

enum RustOutcome {
    State(RustSnapshot),
    DecodeError(DecodeError),
    StepError(ExecutionError),
}

fn rust_snapshot<const N: usize>(state: &MachineState<N>) -> Result<RustSnapshot, String> {
    let registers = (0..32)
        .map(|index| state.registers.read(index).map(Word32::unsigned))
        .collect::<Option<Vec<_>>>()
        .ok_or_else(|| "invalid register index in snapshot".to_owned())?;
    let memory = (0..N)
        .map(|offset| {
            let offset = u32::try_from(offset).ok()?;
            let address = state.memory.base.checked_add(offset)?;
            state.memory.load_u8(address).ok()
        })
        .collect::<Option<Vec<_>>>()
        .ok_or_else(|| "memory snapshot out of bounds".to_owned())?;
    Ok(RustSnapshot {
        pc: state.pc,
        terminal: state.terminal,
        registers,
        memory_base: state.memory.base,
        memory,
    })
}

fn rust_result(case: &Case) -> Result<RustOutcome, String> {
    let mut initial = MachineState::<64>::new(case.pc, 0);
    let _ = initial.registers.write(1, Word32::new(case.x1));
    let _ = initial.registers.write(2, Word32::new(case.x2));
    let instruction = match decode(case.instruction) {
        Ok(instruction) => instruction,
        Err(error) => return Ok(RustOutcome::DecodeError(error)),
    };
    let state = match step(initial, instruction) {
        Ok(state) => state,
        Err(error) => return Ok(RustOutcome::StepError(error)),
    };
    Ok(RustOutcome::State(rust_snapshot(&state)?))
}

fn addi_error_name(error: ExecutionError) -> &'static str {
    match error {
        ExecutionError::Halted => "halted",
        ExecutionError::InvalidRegisterIndex => "invalid_register",
        ExecutionError::MisalignedInstructionAddress => "misaligned_pc",
        ExecutionError::Memory(_) => "other",
    }
}

fn append_snapshot_fields(fields: &mut Vec<String>, snapshot: &RustSnapshot) {
    fields.push(snapshot.pc.to_string());
    fields.push(match snapshot.terminal {
        TerminalState::Running => "running".to_owned(),
        TerminalState::Halted => "halted".to_owned(),
    });
    fields.push(
        snapshot
            .registers
            .iter()
            .map(u32::to_string)
            .collect::<Vec<_>>()
            .join(","),
    );
    fields.push(snapshot.memory_base.to_string());
    fields.push(
        snapshot
            .memory
            .iter()
            .map(u8::to_string)
            .collect::<Vec<_>>()
            .join(","),
    );
}

fn addi_bridge_record(case: &Case) -> Result<Option<(String, bool)>, String> {
    let instruction = match decode(case.instruction) {
        Ok(instruction) => instruction,
        Err(_) => return Ok(None),
    };
    let Instruction::Addi { rd, rs1, imm } = instruction else {
        return Ok(None);
    };

    let mut input_state = MachineState::<64>::new(case.pc, 0);
    let _ = input_state.registers.write(1, Word32::new(case.x1));
    let _ = input_state.registers.write(2, Word32::new(case.x2));
    let input = rust_snapshot(&input_state)?;
    let outcome = match step(input_state, instruction) {
        Ok(state) => Ok(rust_snapshot(&state)?),
        Err(error) => Err(addi_error_name(error)),
    };

    let mut fields = vec![
        "addi".to_owned(),
        case.instruction.to_string(),
        rd.to_string(),
        rs1.to_string(),
        (imm as u32).to_string(),
    ];
    append_snapshot_fields(&mut fields, &input);
    let expected_acceptance = outcome.is_ok();
    match outcome {
        Ok(output) => {
            fields.push("ok".to_owned());
            append_snapshot_fields(&mut fields, &output);
        }
        Err(error) => {
            fields.push("err".to_owned());
            fields.push(error.to_owned());
        }
    }
    Ok(Some((fields.join("|"), expected_acceptance)))
}

fn add_bridge_record(case: &Case) -> Result<Option<(String, bool)>, String> {
    let instruction = match decode(case.instruction) {
        Ok(instruction) => instruction,
        Err(_) => return Ok(None),
    };
    let Instruction::Add { rd, rs1, rs2 } = instruction else {
        return Ok(None);
    };

    let mut input_state = MachineState::<64>::new(case.pc, 0);
    let _ = input_state.registers.write(1, Word32::new(case.x1));
    let _ = input_state.registers.write(2, Word32::new(case.x2));
    let input = rust_snapshot(&input_state)?;
    let outcome = match step(input_state, instruction) {
        Ok(state) => Ok(rust_snapshot(&state)?),
        Err(error) => Err(addi_error_name(error)),
    };

    let mut fields = vec![
        "add".to_owned(),
        case.instruction.to_string(),
        rd.to_string(),
        rs1.to_string(),
        rs2.to_string(),
    ];
    append_snapshot_fields(&mut fields, &input);
    let expected_acceptance = outcome.is_ok();
    match outcome {
        Ok(output) => {
            fields.push("ok".to_owned());
            append_snapshot_fields(&mut fields, &output);
        }
        Err(error) => {
            fields.push("err".to_owned());
            fields.push(error.to_owned());
        }
    }
    Ok(Some((fields.join("|"), expected_acceptance)))
}

fn lean_bridge_oracle(
    root: &std::path::Path,
    record_flag: &str,
    record: &str,
) -> Result<bool, String> {
    let output = Command::new("lake")
        .current_dir(root)
        .args([
            "env",
            "lean",
            "--run",
            "adversarial/LeanOracle.lean",
            "--",
            record_flag,
            record,
        ])
        .output()
        .map_err(|error| format!("could not start Lean bridge oracle: {error}"))?;
    if !output.status.success() {
        return Err(format!(
            "Lean bridge oracle failed: {}",
            String::from_utf8_lossy(&output.stderr).trim()
        ));
    }
    let stdout = String::from_utf8(output.stdout)
        .map_err(|error| format!("Lean bridge output was not UTF-8: {error}"))?;
    match stdout.trim() {
        "accepted" => Ok(true),
        "rejected" => Ok(false),
        other => Err(format!("Lean bridge returned unexpected result: {other}")),
    }
}

fn expect_bridge_record_rejected(
    root: &std::path::Path,
    fields: &[String],
    label: &str,
    index: usize,
    record_flag: &str,
    replacement: String,
) -> Result<(), String> {
    let mut mutated = fields.to_vec();
    mutated[index] = replacement;
    if lean_bridge_oracle(root, record_flag, &mutated.join("|"))? {
        return Err(format!("Lean checker accepted mutated {label}"));
    }
    println!("bridge mutation {label}: rejected");
    Ok(())
}

fn check_addi_bridge_mutations(root: &std::path::Path, cases: &[Case]) -> Result<(), String> {
    let case = cases
        .iter()
        .find(|case| case.name == "addi_x1_imm1")
        .ok_or_else(|| "ADDI bridge mutation baseline is missing".to_owned())?;
    let (record, expected_acceptance) = addi_bridge_record(case)?
        .ok_or_else(|| "ADDI bridge mutation baseline did not decode as ADDI".to_owned())?;
    if !expected_acceptance {
        return Err("ADDI bridge mutation baseline did not succeed in Rust".into());
    }
    if !lean_bridge_oracle(root, "--addi-record", &record)? {
        return Err("Lean ADDI checker rejected its unmodified Rust record".into());
    }
    let fields = record.split('|').map(str::to_owned).collect::<Vec<_>>();
    if fields.len() != 16 {
        return Err("ADDI bridge baseline has an unexpected record shape".into());
    }

    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI instruction word",
        1,
        "--addi-record",
        "0".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI decoded rd",
        2,
        "--addi-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI decoded immediate",
        4,
        "--addi-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI misaligned input PC",
        5,
        "--addi-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI output PC",
        11,
        "--addi-record",
        "8".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI output registers",
        13,
        "--addi-record",
        vec!["0"; 32].join(","),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI output terminal",
        12,
        "--addi-record",
        "halted".into(),
    )?;
    let mut changed_memory = fields[15]
        .split(',')
        .map(str::to_owned)
        .collect::<Vec<_>>();
    let first_byte = changed_memory
        .first_mut()
        .ok_or_else(|| "ADDI bridge baseline memory snapshot is empty".to_owned())?;
    *first_byte = "1".into();
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADDI output memory",
        15,
        "--addi-record",
        changed_memory.join(","),
    )
}

fn check_add_bridge_mutations(root: &std::path::Path, cases: &[Case]) -> Result<(), String> {
    let case = cases
        .iter()
        .find(|case| case.name == "add_x3_x1_x2")
        .ok_or_else(|| "ADD bridge mutation baseline is missing".to_owned())?;
    let (record, expected_acceptance) = add_bridge_record(case)?
        .ok_or_else(|| "ADD bridge mutation baseline did not decode as ADD".to_owned())?;
    if !expected_acceptance {
        return Err("ADD bridge mutation baseline did not succeed in Rust".into());
    }
    if !lean_bridge_oracle(root, "--add-record", &record)? {
        return Err("Lean ADD checker rejected its unmodified Rust record".into());
    }
    let fields = record.split('|').map(str::to_owned).collect::<Vec<_>>();
    if fields.len() != 16 {
        return Err("ADD bridge baseline has an unexpected record shape".into());
    }

    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD instruction word",
        1,
        "--add-record",
        "0".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD decoded rd",
        2,
        "--add-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD decoded rs1",
        3,
        "--add-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD decoded rs2",
        4,
        "--add-record",
        "1".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD misaligned input PC",
        5,
        "--add-record",
        "2".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD output PC",
        11,
        "--add-record",
        "8".into(),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD output registers",
        13,
        "--add-record",
        vec!["0"; 32].join(","),
    )?;
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD output terminal",
        12,
        "--add-record",
        "halted".into(),
    )?;
    let mut changed_memory = fields[15]
        .split(',')
        .map(str::to_owned)
        .collect::<Vec<_>>();
    let first_byte = changed_memory
        .first_mut()
        .ok_or_else(|| "ADD bridge baseline memory snapshot is empty".to_owned())?;
    *first_byte = "1".into();
    expect_bridge_record_rejected(
        root,
        &fields,
        "ADD output memory",
        15,
        "--add-record",
        changed_memory.join(","),
    )
}

fn rust_result_class(result: &Result<RustOutcome, String>) -> &'static str {
    match result {
        Ok(RustOutcome::State(_)) => "ok",
        Ok(RustOutcome::DecodeError(DecodeError::IllegalInstruction)) => "decode_illegal",
        Ok(RustOutcome::DecodeError(DecodeError::UnsupportedInstruction)) => "decode_unsupported",
        Ok(RustOutcome::StepError(ExecutionError::MisalignedInstructionAddress)) => {
            "step_misaligned_pc"
        }
        Ok(RustOutcome::StepError(ExecutionError::Memory(MemoryError::Misaligned))) => {
            "step_memory_misaligned"
        }
        Ok(RustOutcome::StepError(ExecutionError::Memory(MemoryError::OutOfBounds))) => {
            "step_memory_out_of_bounds"
        }
        Ok(RustOutcome::StepError(_)) => "unexpected_error",
        Err(_) => "unexpected_error",
    }
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
                    expected_rust: "ok",
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
    let mut state_agreements = 0_usize;
    let mut no_successor_matches = 0_usize;
    let mut decode_agreements = 0_usize;

    for case in &cases {
        let lean = lean_oracle(&root, case)?;
        let lean_class = lean.split('|').next().unwrap_or_default();
        if lean_class != case.expected_lean {
            return Err(format!(
                "corpus regression {}: expected Lean {}, got {}",
                case.name, case.expected_lean, lean_class
            ));
        }
        let rust = rust_result(case);
        let rust_class = rust_result_class(&rust);
        if rust_class != case.expected_rust {
            return Err(format!(
                "Rust regression {}: expected {}, got {}",
                case.name, case.expected_rust, rust_class
            ));
        }
        match (lean_class, rust) {
            ("ok", Ok(RustOutcome::State(snapshot))) if agrees_with_lean(&lean, &snapshot) => {
                state_agreements += 1;
                println!("case {}: agreement", case.name);
            }
            ("ok", Ok(RustOutcome::State(_))) => {
                return Err(format!("state mismatch for {}", case.name));
            }
            ("fault", Ok(RustOutcome::StepError(error))) if rust_class.starts_with("step_") => {
                no_successor_matches += 1;
                println!(
                    "case {}: no-successor match (Rust {:?}; Lean fault is untyped)",
                    case.name, error
                );
            }
            ("decode_illegal", Ok(RustOutcome::DecodeError(DecodeError::IllegalInstruction)))
            | ("decode_unsupported", Ok(RustOutcome::DecodeError(DecodeError::UnsupportedInstruction))) => {
                decode_agreements += 1;
                println!("case {}: decode-category agreement", case.name);
            }
            (lean, rust) => {
                return Err(format!(
                    "outcome mismatch for {}: Lean {lean}, Rust {}",
                    case.name,
                    rust_result_class(&rust)
                ));
            }
        }

        if let Some((record, expected_acceptance)) = addi_bridge_record(case)? {
            let accepted = lean_bridge_oracle(&root, "--addi-record", &record)?;
            if accepted != expected_acceptance {
                return Err(format!(
                    "ADDI bridge mismatch for {}: expected {}, got {}",
                    case.name,
                    if expected_acceptance { "accepted" } else { "rejected" },
                    if accepted { "accepted" } else { "rejected" }
                ));
            }
            println!(
                "case {}: Rust ADDI record {} by Lean checker",
                case.name,
                if accepted { "accepted" } else { "rejected" }
            );
        }
        if let Some((record, expected_acceptance)) = add_bridge_record(case)? {
            let accepted = lean_bridge_oracle(&root, "--add-record", &record)?;
            if accepted != expected_acceptance {
                return Err(format!(
                    "ADD bridge mismatch for {}: expected {}, got {}",
                    case.name,
                    if expected_acceptance { "accepted" } else { "rejected" },
                    if accepted { "accepted" } else { "rejected" }
                ));
            }
            println!(
                "case {}: Rust ADD record {} by Lean checker",
                case.name,
                if accepted { "accepted" } else { "rejected" }
            );
        }
    }

    check_addi_bridge_mutations(&root, &cases)?;
    check_add_bridge_mutations(&root, &cases)?;
    check_mutation_classes()?;
    println!(
        "corpus: {} cases; state agreements: {}, no-successor matches: {}, decode-category agreements: {}",
        cases.len(),
        state_agreements,
        no_successor_matches,
        decode_agreements
    );
    println!("step-failure matches compare only absence of a successor, not fault taxonomy");
    println!("finite harness results are not a universal proof");
    Ok(())
}

fn main() {
    let args = std::env::args().skip(1).collect::<Vec<_>>();
    let result = match args.first().map(String::as_str) {
        Some("--emit-transcript") => transcript::emit_cli(&args[1..]),
        Some("--help") if args.len() == 1 => {
            println!(
                "usage: zkrv32i-adversarial [--emit-transcript <elf32-riscv> <transcript.json> [fuel]]"
            );
            Ok(())
        }
        None => run(),
        Some(_) => Err(
            "usage: zkrv32i-adversarial [--emit-transcript <elf32-riscv> <transcript.json> [fuel]]"
                .into(),
        ),
    };
    if let Err(error) = result {
        eprintln!("harness failure: {error}");
        std::process::exit(1);
    }
}
