use std::fmt::Write as FmtWrite;
use std::fs;
use std::io::Read;
use std::path::Path;

use zkrv32i::{
    decode, step, DecodeError, ExecutionError, Instruction, MachineState, MemoryError,
    TerminalState,
};

const MAX_ELF_BYTES: usize = 1 << 20;
const MAX_MEMORY_BYTES: usize = 1 << 16;
const DEFAULT_FUEL: usize = 64;
const MAX_FUEL: usize = 256;
const TRANSCRIPT_FORMAT: &str = "zkrv32i-execution-transcript";
const TRANSCRIPT_VERSION: u32 = 2;

struct LoadSegment {
    file_offset: usize,
    file_size: usize,
    virtual_address: u32,
    memory_size: usize,
}

struct LoadPlan {
    segments: Vec<LoadSegment>,
    entry: u32,
    memory_base: u32,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct DecodedInstruction {
    kind: &'static str,
    operands: Vec<i64>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct StateSnapshot {
    pc: u32,
    terminal: &'static str,
    registers: Vec<u32>,
    memory_base: u32,
    memory: Vec<u8>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct TraceStep {
    pc: u32,
    word: u32,
    decoded: DecodedInstruction,
    state: StateSnapshot,
}

#[derive(Clone, Debug, Eq, PartialEq)]
enum StopReason {
    Halt,
    Fault {
        stage: &'static str,
        pc: u32,
        word: Option<u32>,
        decoded: Option<DecodedInstruction>,
        error: &'static str,
    },
    FuelLimit {
        steps: usize,
        limit: usize,
    },
}

struct ExecutionTranscript {
    elf_bytes: Vec<u8>,
    initial_state: StateSnapshot,
    steps: Vec<TraceStep>,
    stop: StopReason,
}

fn read_u16(bytes: &[u8], offset: usize) -> Option<u16> {
    let bytes = bytes.get(offset..offset.checked_add(2)?)?;
    Some(u16::from_le_bytes([bytes[0], bytes[1]]))
}

fn read_u32(bytes: &[u8], offset: usize) -> Option<u32> {
    let bytes = bytes.get(offset..offset.checked_add(4)?)?;
    Some(u32::from_le_bytes([bytes[0], bytes[1], bytes[2], bytes[3]]))
}

fn parse_bounded_executable_elf32(bytes: &[u8]) -> Result<LoadPlan, String> {
    if bytes.len() > MAX_ELF_BYTES {
        return Err(format!("ELF is larger than the {MAX_ELF_BYTES}-byte limit"));
    }
    if bytes.len() < 52
        || bytes.get(0..7) != Some(&[0x7f, b'E', b'L', b'F', 1, 1, 1])
    {
        return Err("ELF must have a complete ELF32 little-endian version-1 header".into());
    }

    let object_type = read_u16(bytes, 16).ok_or("missing ELF object type")?;
    let machine = read_u16(bytes, 18).ok_or("missing ELF machine")?;
    let version = read_u32(bytes, 20).ok_or("missing ELF version")?;
    let entry = read_u32(bytes, 24).ok_or("missing ELF entry")?;
    let program_header_offset =
        usize::try_from(read_u32(bytes, 28).ok_or("missing program-header offset")?)
            .map_err(|_| "program-header offset does not fit the host")?;
    let header_size = read_u16(bytes, 40).ok_or("missing ELF header size")?;
    let program_header_size =
        usize::from(read_u16(bytes, 42).ok_or("missing program-header entry size")?);
    let program_header_count =
        read_u16(bytes, 44).ok_or("missing program-header count")?;

    if object_type != 2 || machine != 243 || version != 1 || header_size != 52 {
        return Err("ELF must be an executable RISC-V ELF32 image".into());
    }
    if program_header_count == 0 || program_header_size < 32 {
        return Err("ELF must contain at least one complete program header".into());
    }
    let table_size = program_header_size
        .checked_mul(usize::from(program_header_count))
        .ok_or("program-header table size overflows")?;
    let table_end = program_header_offset
        .checked_add(table_size)
        .ok_or("program-header table size overflows")?;
    if table_end > bytes.len() {
        return Err("program-header table extends past the ELF bytes".into());
    }

    if entry % 4 != 0 {
        return Err("ELF entry must be 4-byte aligned".into());
    }

    let mut segments = Vec::new();
    let mut executable_entry = false;
    for index in 0..usize::from(program_header_count) {
        let header_offset = program_header_offset
            .checked_add(
                program_header_size
                    .checked_mul(index)
                    .ok_or("program-header offset overflows")?,
            )
            .ok_or("program-header offset overflows")?;
        let segment_type =
            read_u32(bytes, header_offset).ok_or("missing segment type")?;
        let file_offset = usize::try_from(
            read_u32(bytes, header_offset + 4).ok_or("missing segment file offset")?,
        )
        .map_err(|_| "segment file offset does not fit the host")?;
        let virtual_address =
            read_u32(bytes, header_offset + 8).ok_or("missing segment virtual address")?;
        let file_size = usize::try_from(
            read_u32(bytes, header_offset + 16).ok_or("missing segment file size")?,
        )
        .map_err(|_| "segment file size does not fit the host")?;
        let memory_size = usize::try_from(
            read_u32(bytes, header_offset + 20).ok_or("missing segment memory size")?,
        )
        .map_err(|_| "segment memory size does not fit the host")?;
        let flags = read_u32(bytes, header_offset + 24).ok_or("missing segment flags")?;

        let file_end = file_offset
            .checked_add(file_size)
            .ok_or("segment file range overflows")?;
        if file_end > bytes.len() || file_size > memory_size {
            return Err("program-header file range or size is invalid".into());
        }

        if segment_type == 1 {
            let address_end = u64::from(virtual_address) + memory_size as u64;
            if address_end > (1_u64 << 32) {
                return Err("loadable segment exceeds the RV32 address space".into());
            }
            if flags & 1 != 0
                && u64::from(virtual_address) <= u64::from(entry)
                && u64::from(entry) + 4 <= address_end
            {
                executable_entry = true;
            }
            segments.push(LoadSegment {
                file_offset,
                file_size,
                virtual_address,
                memory_size,
            });
        }
    }

    if segments.is_empty() || !executable_entry {
        return Err("ELF entry must lie in an executable PT_LOAD segment".into());
    }
    for first in 0..segments.len() {
        let first_end =
            u64::from(segments[first].virtual_address) + segments[first].memory_size as u64;
        for second in first + 1..segments.len() {
            let second_start = u64::from(segments[second].virtual_address);
            let second_end =
                second_start + segments[second].memory_size as u64;
            let first_start = u64::from(segments[first].virtual_address);
            if !(first_end <= second_start || second_end <= first_start) {
                return Err("loadable segment memory ranges overlap".into());
            }
        }
    }

    let memory_base = segments
        .iter()
        .map(|segment| segment.virtual_address)
        .min()
        .ok_or("ELF has no loadable segments")?;
    let memory_window_end = u64::from(memory_base) + MAX_MEMORY_BYTES as u64;
    if memory_window_end > (1_u64 << 32) {
        return Err("bounded memory range exceeds the RV32 address space".into());
    }
    for segment in &segments {
        let segment_end =
            u64::from(segment.virtual_address) + segment.memory_size as u64;
        if u64::from(segment.virtual_address) < u64::from(memory_base)
            || segment_end > memory_window_end
        {
            return Err("loadable segments do not fit the bounded memory window".into());
        }
    }

    Ok(LoadPlan {
        segments,
        entry,
        memory_base,
    })
}

fn instruction_record(instruction: Instruction) -> DecodedInstruction {
    use Instruction::*;

    let (kind, operands) = match instruction {
        Lui { rd, imm } => ("lui", vec![i64::from(rd), i64::from(imm)]),
        Auipc { rd, imm } => ("auipc", vec![i64::from(rd), i64::from(imm)]),
        Jal { rd, imm } => ("jal", vec![i64::from(rd), i64::from(imm)]),
        Jalr { rd, rs1, imm } => {
            ("jalr", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Beq { rs1, rs2, imm } => {
            ("beq", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Bne { rs1, rs2, imm } => {
            ("bne", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Blt { rs1, rs2, imm } => {
            ("blt", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Bge { rs1, rs2, imm } => {
            ("bge", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Bltu { rs1, rs2, imm } => {
            ("bltu", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Bgeu { rs1, rs2, imm } => {
            ("bgeu", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Lb { rd, rs1, imm } => {
            ("lb", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Lh { rd, rs1, imm } => {
            ("lh", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Lw { rd, rs1, imm } => {
            ("lw", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Lbu { rd, rs1, imm } => {
            ("lbu", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Lhu { rd, rs1, imm } => {
            ("lhu", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Sb { rs1, rs2, imm } => {
            ("sb", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Sh { rs1, rs2, imm } => {
            ("sh", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Sw { rs1, rs2, imm } => {
            ("sw", vec![i64::from(rs1), i64::from(rs2), i64::from(imm)])
        }
        Addi { rd, rs1, imm } => {
            ("addi", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Slti { rd, rs1, imm } => {
            ("slti", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Sltiu { rd, rs1, imm } => {
            ("sltiu", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Xori { rd, rs1, imm } => {
            ("xori", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Ori { rd, rs1, imm } => {
            ("ori", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Andi { rd, rs1, imm } => {
            ("andi", vec![i64::from(rd), i64::from(rs1), i64::from(imm)])
        }
        Slli { rd, rs1, shamt } => {
            ("slli", vec![i64::from(rd), i64::from(rs1), i64::from(shamt)])
        }
        Srli { rd, rs1, shamt } => {
            ("srli", vec![i64::from(rd), i64::from(rs1), i64::from(shamt)])
        }
        Srai { rd, rs1, shamt } => {
            ("srai", vec![i64::from(rd), i64::from(rs1), i64::from(shamt)])
        }
        Add { rd, rs1, rs2 } => {
            ("add", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Sub { rd, rs1, rs2 } => {
            ("sub", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Sll { rd, rs1, rs2 } => {
            ("sll", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Slt { rd, rs1, rs2 } => {
            ("slt", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Sltu { rd, rs1, rs2 } => {
            ("sltu", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Xor { rd, rs1, rs2 } => {
            ("xor", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Srl { rd, rs1, rs2 } => {
            ("srl", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Sra { rd, rs1, rs2 } => {
            ("sra", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Or { rd, rs1, rs2 } => {
            ("or", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        And { rd, rs1, rs2 } => {
            ("and", vec![i64::from(rd), i64::from(rs1), i64::from(rs2)])
        }
        Fence => ("fence", vec![]),
        Ecall => ("ecall", vec![]),
        Ebreak => ("ebreak", vec![]),
    };

    DecodedInstruction {
        kind,
        operands,
    }
}

fn snapshot<const N: usize>(state: &MachineState<N>) -> Result<StateSnapshot, String> {
    let mut registers = Vec::with_capacity(32);
    for index in 0..32 {
        let value = state
            .registers
            .read(index)
            .ok_or_else(|| format!("register x{index} could not be read"))?;
        registers.push(value.unsigned());
    }

    let mut memory = Vec::with_capacity(N);
    for offset in 0..N {
        let offset = u32::try_from(offset).map_err(|_| "memory offset exceeds RV32")?;
        let address = state
            .memory
            .base
            .checked_add(offset)
            .ok_or("memory snapshot address overflows RV32")?;
        memory.push(
            state
                .memory
                .load_u8(address)
                .map_err(|error| format!("memory snapshot failed: {error:?}"))?,
        );
    }

    Ok(StateSnapshot {
        pc: state.pc,
        terminal: match state.terminal {
            TerminalState::Running => "running",
            TerminalState::Halted => "halted",
        },
        registers,
        memory_base: state.memory.base,
        memory,
    })
}

fn decode_error_name(error: DecodeError) -> &'static str {
    match error {
        DecodeError::IllegalInstruction => "illegal_instruction",
        DecodeError::UnsupportedInstruction => "unsupported_instruction",
    }
}

fn memory_error_name(error: MemoryError) -> &'static str {
    match error {
        MemoryError::OutOfBounds => "memory_out_of_bounds",
        MemoryError::Misaligned => "memory_misaligned",
        MemoryError::AddressOverflow => "memory_address_overflow",
    }
}

fn execution_error_name(error: ExecutionError) -> &'static str {
    match error {
        ExecutionError::Memory(error) => memory_error_name(error),
        ExecutionError::MisalignedInstructionAddress => "misaligned_instruction_address",
        ExecutionError::InvalidRegisterIndex => "invalid_register_index",
        ExecutionError::Halted => "already_halted",
    }
}

impl ExecutionTranscript {
    fn run(elf_bytes: Vec<u8>, fuel: usize) -> Result<Self, String> {
        if fuel > MAX_FUEL {
            return Err(format!("fuel exceeds the {MAX_FUEL}-step limit"));
        }

        let plan = parse_bounded_executable_elf32(&elf_bytes)?;
        let mut state = MachineState::<MAX_MEMORY_BYTES>::new(plan.entry, plan.memory_base);
        for segment in plan.segments {
            for offset in 0..segment.file_size {
                let address = segment
                    .virtual_address
                    .checked_add(
                        u32::try_from(offset).map_err(|_| "segment offset exceeds RV32")?,
                    )
                    .ok_or("segment address overflows RV32")?;
                state
                    .memory
                    .store_u8(address, elf_bytes[segment.file_offset + offset])
                    .map_err(|error| format!("could not load ELF segment: {error:?}"))?;
            }
        }
        let initial_state = snapshot(&state)?;
        let mut steps = Vec::with_capacity(fuel);
        let stop = loop {
            if steps.len() == fuel {
                break StopReason::FuelLimit {
                    steps: steps.len(),
                    limit: fuel,
                };
            }

            let pc = state.pc;
            let word = match state.memory.load_u32(pc) {
                Ok(word) => word,
                Err(error) => {
                    break StopReason::Fault {
                        stage: "fetch",
                        pc,
                        word: None,
                        decoded: None,
                        error: memory_error_name(error),
                    };
                }
            };
            let instruction = match decode(word) {
                Ok(instruction) => instruction,
                Err(error) => {
                    break StopReason::Fault {
                        stage: "decode",
                        pc,
                        word: Some(word),
                        decoded: None,
                        error: decode_error_name(error),
                    };
                }
            };
            let decoded = instruction_record(instruction);
            let next = match step(state.clone(), instruction) {
                Ok(next) => next,
                Err(error) => {
                    break StopReason::Fault {
                        stage: "step",
                        pc,
                        word: Some(word),
                        decoded: Some(decoded),
                        error: execution_error_name(error),
                    };
                }
            };
            let next_snapshot = snapshot(&next)?;
            steps.push(TraceStep {
                pc,
                word,
                decoded,
                state: next_snapshot,
            });
            state = next;
            if state.terminal == TerminalState::Halted {
                break StopReason::Halt;
            }
        };

        Ok(Self {
            elf_bytes,
            initial_state,
            steps,
            stop,
        })
    }

    fn to_json(&self) -> Result<String, std::fmt::Error> {
        let mut output = String::new();
        write!(
            output,
            "{{\"format\":\"{TRANSCRIPT_FORMAT}\",\"version\":{TRANSCRIPT_VERSION},\"elf_bytes\":\""
        )?;
        write_hex(&mut output, &self.elf_bytes)?;
        output.push_str("\",\"initial_state\":");
        write_snapshot(&mut output, &self.initial_state)?;
        output.push_str(",\"steps\":[");
        for (index, step) in self.steps.iter().enumerate() {
            if index != 0 {
                output.push(',');
            }
            write!(
                output,
                "{{\"pc\":{},\"word\":{},\"decoded\":",
                step.pc, step.word
            )?;
            write_instruction(&mut output, &step.decoded)?;
            output.push_str(",\"state\":");
            write_snapshot(&mut output, &step.state)?;
            output.push('}');
        }
        output.push_str("],\"stop\":");
        match &self.stop {
            StopReason::Halt => output.push_str("{\"kind\":\"halt\"}"),
            StopReason::Fault {
                stage,
                pc,
                word,
                decoded,
                error,
            } => {
                write!(
                    output,
                    "{{\"kind\":\"fault\",\"stage\":\"{stage}\",\"pc\":{pc},\"word\":"
                )?;
                match word {
                    Some(word) => write!(output, "{word}")?,
                    None => output.push_str("null"),
                }
                output.push_str(",\"decoded\":");
                match decoded {
                    Some(decoded) => write_instruction(&mut output, decoded)?,
                    None => output.push_str("null"),
                }
                write!(output, ",\"error\":\"{error}\"}}")?;
            }
            StopReason::FuelLimit { steps, limit } => {
                write!(
                    output,
                    "{{\"kind\":\"fuel_limit\",\"steps\":{steps},\"limit\":{limit}}}"
                )?;
            }
        }
        output.push('}');
        Ok(output)
    }
}

fn write_hex(output: &mut String, bytes: &[u8]) -> Result<(), std::fmt::Error> {
    for byte in bytes {
        write!(output, "{byte:02x}")?;
    }
    Ok(())
}

fn write_instruction(
    output: &mut String,
    instruction: &DecodedInstruction,
) -> Result<(), std::fmt::Error> {
    write!(
        output,
        "{{\"kind\":\"{}\",\"operands\":[",
        instruction.kind
    )?;
    for (index, operand) in instruction.operands.iter().enumerate() {
        if index != 0 {
            output.push(',');
        }
        write!(output, "{operand}")?;
    }
    output.push_str("]}");
    Ok(())
}

fn write_snapshot(
    output: &mut String,
    snapshot: &StateSnapshot,
) -> Result<(), std::fmt::Error> {
    write!(
        output,
        "{{\"pc\":{},\"terminal\":\"{}\",\"registers\":[",
        snapshot.pc, snapshot.terminal
    )?;
    for (index, register) in snapshot.registers.iter().enumerate() {
        if index != 0 {
            output.push(',');
        }
        write!(output, "{register}")?;
    }
    write!(
        output,
        "],\"memory_base\":{},\"memory_size\":{},\"memory_hex\":\"",
        snapshot.memory_base,
        snapshot.memory.len()
    )?;
    write_hex(output, &snapshot.memory)?;
    output.push_str("\"}");
    Ok(())
}

pub fn emit_cli(args: &[String]) -> Result<(), String> {
    if !(2..=3).contains(&args.len()) {
        return Err(
            "usage: --emit-transcript <elf32-riscv> <transcript.json> [fuel]".into(),
        );
    }
    let fuel = match args.get(2) {
        Some(value) => value
            .parse::<usize>()
            .map_err(|_| "fuel must be a non-negative integer")?,
        None => DEFAULT_FUEL,
    };
    if fuel > MAX_FUEL {
        return Err(format!("fuel exceeds the {MAX_FUEL}-step limit"));
    }

    let input_path = Path::new(&args[0]);
    let output_path = Path::new(&args[1]);
    let file = fs::File::open(input_path)
        .map_err(|error| format!("could not open ELF {}: {error}", input_path.display()))?;
    let mut elf_bytes = Vec::new();
    file.take((MAX_ELF_BYTES as u64) + 1)
        .read_to_end(&mut elf_bytes)
        .map_err(|error| format!("could not read ELF {}: {error}", input_path.display()))?;
    let transcript = ExecutionTranscript::run(elf_bytes, fuel)?;
    let json = transcript
        .to_json()
        .map_err(|error| format!("could not serialize transcript: {error}"))?;
    fs::write(output_path, json)
        .map_err(|error| format!("could not write transcript {}: {error}", output_path.display()))?;
    println!(
        "transcript v{TRANSCRIPT_VERSION}: {} steps, stop={:?}",
        transcript.steps.len(),
        transcript.stop
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{ExecutionTranscript, MAX_FUEL, MAX_MEMORY_BYTES, StopReason};

    const ENTRY: u32 = 0x1000;
    const PROGRAM_HEADER_OFFSET: usize = 52;
    const PROGRAM_HEADER_SIZE: usize = 32;
    const PROGRAM_HEADER_COUNT: usize = 2;
    const SEGMENT_OFFSET: usize =
        PROGRAM_HEADER_OFFSET + PROGRAM_HEADER_SIZE * PROGRAM_HEADER_COUNT;
    const DATA_ADDRESS: u32 = ENTRY + 0x1000;

    fn put_u16(bytes: &mut [u8], offset: usize, value: u16) {
        bytes[offset..offset + 2].copy_from_slice(&value.to_le_bytes());
    }

    fn put_u32(bytes: &mut [u8], offset: usize, value: u32) {
        bytes[offset..offset + 4].copy_from_slice(&value.to_le_bytes());
    }

    fn test_elf(words: &[u32]) -> Vec<u8> {
        test_elf_with_entry(words, ENTRY)
    }

    fn test_elf_with_entry(words: &[u32], entry: u32) -> Vec<u8> {
        let file_size = words.len() * 4;
        let data_file_offset = SEGMENT_OFFSET + file_size;
        let data_file_size = 4;
        let mut bytes = vec![0_u8; data_file_offset + data_file_size];
        bytes[0..7].copy_from_slice(&[0x7f, b'E', b'L', b'F', 1, 1, 1]);
        put_u16(&mut bytes, 16, 2);
        put_u16(&mut bytes, 18, 243);
        put_u32(&mut bytes, 20, 1);
        put_u32(&mut bytes, 24, entry);
        put_u32(&mut bytes, 28, PROGRAM_HEADER_OFFSET as u32);
        put_u16(&mut bytes, 40, 52);
        put_u16(&mut bytes, 42, PROGRAM_HEADER_SIZE as u16);
        put_u16(&mut bytes, 44, PROGRAM_HEADER_COUNT as u16);

        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET, 1);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 4, SEGMENT_OFFSET as u32);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 8, ENTRY);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 16, file_size as u32);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 20, file_size as u32);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 24, 5);
        put_u32(&mut bytes, PROGRAM_HEADER_OFFSET + 28, 4);
        let data_header_offset = PROGRAM_HEADER_OFFSET + PROGRAM_HEADER_SIZE;
        put_u32(&mut bytes, data_header_offset, 1);
        put_u32(
            &mut bytes,
            data_header_offset + 4,
            data_file_offset as u32,
        );
        put_u32(&mut bytes, data_header_offset + 8, DATA_ADDRESS);
        put_u32(&mut bytes, data_header_offset + 16, data_file_size as u32);
        put_u32(&mut bytes, data_header_offset + 20, 8);
        put_u32(&mut bytes, data_header_offset + 24, 6);
        put_u32(&mut bytes, data_header_offset + 28, 4);
        for (index, word) in words.iter().enumerate() {
            put_u32(&mut bytes, SEGMENT_OFFSET + index * 4, *word);
        }
        bytes[data_file_offset..data_file_offset + data_file_size]
            .copy_from_slice(&[0xaa, 0xbb, 0xcc, 0xdd]);
        bytes
    }

    #[test]
    fn arithmetic_store_and_ebreak_emit_full_halted_trace() {
        let transcript = ExecutionTranscript::run(
            test_elf(&[
                0x0000_0097,
                0x1000_8093,
                0x0050_0113,
                0x0020_a023,
                0x0010_0073,
            ]),
            8,
        )
        .unwrap();

        assert_eq!(transcript.stop, StopReason::Halt);
        assert_eq!(transcript.steps.len(), 5);
        assert_eq!(transcript.initial_state.pc, ENTRY);
        assert_eq!(transcript.initial_state.registers.len(), 32);
        assert_eq!(transcript.initial_state.memory.len(), MAX_MEMORY_BYTES);
        assert_eq!(transcript.steps[0].decoded.kind, "auipc");
        assert_eq!(transcript.steps[0].decoded.operands, [1, 0]);
        assert_eq!(transcript.steps[0].state.registers[1], ENTRY);
        assert_eq!(transcript.steps[3].decoded.kind, "sw");
        assert_eq!(
            &transcript.steps[3].state.memory[0x100..0x104],
            &[5, 0, 0, 0]
        );
        assert_eq!(transcript.steps[4].state.terminal, "halted");

        let json = transcript.to_json().unwrap();
        assert!(json.starts_with(
            "{\"format\":\"zkrv32i-execution-transcript\",\"version\":2,"
        ));
        assert!(json.contains("\"kind\":\"ebreak\",\"operands\":[]"));
        assert!(json.contains("\"kind\":\"halt\""));
        assert!(json.contains(
            "\"memory_size\":65536,\"memory_hex\":\"97000000938000101301500023a0200073001000"
        ));
    }

    #[test]
    fn fuel_and_decode_fault_are_explicit_stop_reasons() {
        let fuel_limited = ExecutionTranscript::run(test_elf(&[0x0070_0093]), 1).unwrap();
        assert_eq!(
            fuel_limited.stop,
            StopReason::FuelLimit {
                steps: 1,
                limit: 1
            }
        );
        assert_eq!(fuel_limited.steps.len(), 1);
        assert!(fuel_limited
            .to_json()
            .unwrap()
            .contains("\"stop\":{\"kind\":\"fuel_limit\",\"steps\":1,\"limit\":1}"));

        let decode_fault = ExecutionTranscript::run(test_elf(&[u32::MAX]), 1).unwrap();
        assert!(matches!(
            decode_fault.stop,
            StopReason::Fault {
                stage: "decode",
                error: "unsupported_instruction" | "illegal_instruction",
                ..
            }
        ));
        assert!(decode_fault.steps.is_empty());
        assert!(decode_fault
            .to_json()
            .unwrap()
            .contains("\"kind\":\"fault\",\"stage\":\"decode\""));
        assert!(ExecutionTranscript::run(test_elf(&[0x0070_0093]), MAX_FUEL + 1).is_err());
    }

    #[test]
    fn accepts_multiple_segments_and_entry_inside_executable_segment() {
        let multiple_segments = test_elf_with_entry(
            &[0x0070_0093, 0x0010_0073],
            ENTRY + 4,
        );
        let transcript = ExecutionTranscript::run(multiple_segments, 1).unwrap();
        assert_eq!(transcript.initial_state.pc, ENTRY + 4);
        assert_eq!(transcript.steps.len(), 1);
        assert_eq!(transcript.stop, StopReason::Halt);
        let data_offset = (DATA_ADDRESS - transcript.initial_state.memory_base) as usize;
        assert_eq!(
            &transcript.initial_state.memory[data_offset..data_offset + 8],
            &[0xaa, 0xbb, 0xcc, 0xdd, 0, 0, 0, 0]
        );

        let mut mismatched_entry = test_elf(&[0x0010_0073]);
        put_u32(&mut mismatched_entry, PROGRAM_HEADER_OFFSET + 8, ENTRY + 4);
        assert!(ExecutionTranscript::run(mismatched_entry, 1).is_err());
    }

    #[test]
    fn rejects_elf_header_segment_and_entry_mutations() {
        let valid = test_elf(&[0x0010_0073]);

        let mut bad_magic = valid.clone();
        bad_magic[0] = 0;
        assert!(ExecutionTranscript::run(bad_magic, 1).is_err());

        let mut wrong_machine = valid.clone();
        put_u16(&mut wrong_machine, 18, 3);
        assert!(ExecutionTranscript::run(wrong_machine, 1).is_err());

        let mut non_load_segment = valid.clone();
        put_u32(&mut non_load_segment, PROGRAM_HEADER_OFFSET, 2);
        assert!(ExecutionTranscript::run(non_load_segment, 1).is_err());

        let mut non_executable_segment = valid.clone();
        put_u32(&mut non_executable_segment, PROGRAM_HEADER_OFFSET + 24, 4);
        assert!(ExecutionTranscript::run(non_executable_segment, 1).is_err());

        let mut misaligned_entry = valid.clone();
        put_u32(&mut misaligned_entry, 24, ENTRY + 1);
        assert!(ExecutionTranscript::run(misaligned_entry, 1).is_err());

        let mut entry_outside_segment = valid;
        put_u32(&mut entry_outside_segment, 24, ENTRY + 4);
        assert!(ExecutionTranscript::run(entry_outside_segment, 1).is_err());
    }

    #[test]
    fn rejects_overlapping_and_out_of_window_load_segments() {
        let valid = test_elf(&[0x0010_0073]);

        let mut overlapping = valid.clone();
        let data_header_offset = PROGRAM_HEADER_OFFSET + PROGRAM_HEADER_SIZE;
        put_u32(&mut overlapping, data_header_offset + 8, ENTRY);
        assert!(ExecutionTranscript::run(overlapping, 1).is_err());

        let mut out_of_window = valid;
        put_u32(
            &mut out_of_window,
            data_header_offset + 8,
            ENTRY + MAX_MEMORY_BYTES as u32,
        );
        assert!(ExecutionTranscript::run(out_of_window, 1).is_err());
    }
}
