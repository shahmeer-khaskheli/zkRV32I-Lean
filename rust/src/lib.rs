#![no_std]
#![forbid(unsafe_code)]

pub const MAX_TRACE: usize = 1 << 20;

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
#[repr(transparent)]
pub struct Word32(u32);

impl Word32 {
    pub const ZERO: Self = Self(0);

    pub const fn new(value: u32) -> Self {
        Self(value)
    }

    pub const fn wrapping_add(self, rhs: Self) -> Self {
        Self(self.0.wrapping_add(rhs.0))
    }

    pub const fn wrapping_sub(self, rhs: Self) -> Self {
        Self(self.0.wrapping_sub(rhs.0))
    }

    pub const fn checked_add(self, rhs: Self) -> Option<Self> {
        match self.0.checked_add(rhs.0) {
            Some(value) => Some(Self(value)),
            None => None,
        }
    }

    pub const fn checked_sub(self, rhs: Self) -> Option<Self> {
        match self.0.checked_sub(rhs.0) {
            Some(value) => Some(Self(value)),
            None => None,
        }
    }

    pub const fn signed(self) -> i32 {
        self.0 as i32
    }

    pub const fn unsigned(self) -> u32 {
        self.0
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RegisterFile {
    registers: [Word32; 32],
}

impl RegisterFile {
    pub const fn zeroed() -> Self {
        Self {
            registers: [Word32::ZERO; 32],
        }
    }

    pub const fn read(&self, index: u8) -> Option<Word32> {
        if index == 0 {
            Some(Word32::ZERO)
        } else if index < 32 {
            Some(self.registers[index as usize])
        } else {
            None
        }
    }

    pub fn write(&mut self, index: u8, value: Word32) -> bool {
        if index == 0 || index >= 32 {
            false
        } else {
            self.registers[index as usize] = value;
            true
        }
    }

    pub const fn x0_is_zero(&self) -> bool {
        self.registers[0].unsigned() == 0
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MemoryError {
    OutOfBounds,
    Misaligned,
    AddressOverflow,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Memory<const N: usize> {
    pub base: u32,
    bytes: [u8; N],
}

impl<const N: usize> Memory<N> {
    pub const fn new(base: u32) -> Self {
        Self {
            base,
            bytes: [0; N],
        }
    }

    pub fn checked_offset(
        &self,
        address: u32,
        width: usize,
        alignment: usize,
    ) -> Result<usize, MemoryError> {
        if alignment > 1 {
            let address_as_usize =
                usize::try_from(address).map_err(|_| MemoryError::OutOfBounds)?;
            if address_as_usize % alignment != 0 {
                return Err(MemoryError::Misaligned);
            }
        }

        let offset = address
            .checked_sub(self.base)
            .ok_or(MemoryError::OutOfBounds)?;
        let offset = usize::try_from(offset).map_err(|_| MemoryError::OutOfBounds)?;
        let last_byte = width.checked_sub(1).ok_or(MemoryError::OutOfBounds)?;
        address
            .checked_add(u32::try_from(last_byte).map_err(|_| MemoryError::AddressOverflow)?)
            .ok_or(MemoryError::AddressOverflow)?;
        let end = offset
            .checked_add(width)
            .ok_or(MemoryError::AddressOverflow)?;
        if end > N {
            return Err(MemoryError::OutOfBounds);
        }
        Ok(offset)
    }

    pub fn load_u8(&self, address: u32) -> Result<u8, MemoryError> {
        let offset = self.checked_offset(address, 1, 1)?;
        Ok(self.bytes[offset])
    }

    pub fn store_u8(&mut self, address: u32, value: u8) -> Result<(), MemoryError> {
        let offset = self.checked_offset(address, 1, 1)?;
        self.bytes[offset] = value;
        Ok(())
    }

    pub fn load_u16(&self, address: u32) -> Result<u16, MemoryError> {
        let offset = self.checked_offset(address, 2, 2)?;
        Ok(u16::from_le_bytes([
            self.bytes[offset],
            self.bytes[offset + 1],
        ]))
    }

    pub fn store_u16(&mut self, address: u32, value: u16) -> Result<(), MemoryError> {
        let offset = self.checked_offset(address, 2, 2)?;
        let bytes = value.to_le_bytes();
        self.bytes[offset] = bytes[0];
        self.bytes[offset + 1] = bytes[1];
        Ok(())
    }

    pub fn load_u32(&self, address: u32) -> Result<u32, MemoryError> {
        let offset = self.checked_offset(address, 4, 4)?;
        Ok(u32::from_le_bytes([
            self.bytes[offset],
            self.bytes[offset + 1],
            self.bytes[offset + 2],
            self.bytes[offset + 3],
        ]))
    }

    pub fn store_u32(&mut self, address: u32, value: u32) -> Result<(), MemoryError> {
        let offset = self.checked_offset(address, 4, 4)?;
        let bytes = value.to_le_bytes();
        self.bytes[offset] = bytes[0];
        self.bytes[offset + 1] = bytes[1];
        self.bytes[offset + 2] = bytes[2];
        self.bytes[offset + 3] = bytes[3];
        Ok(())
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Instruction {
    Lui { rd: u8, imm: u32 },
    Auipc { rd: u8, imm: u32 },
    Jal { rd: u8, imm: i32 },
    Jalr { rd: u8, rs1: u8, imm: i32 },
    Beq { rs1: u8, rs2: u8, imm: i32 },
    Bne { rs1: u8, rs2: u8, imm: i32 },
    Blt { rs1: u8, rs2: u8, imm: i32 },
    Bge { rs1: u8, rs2: u8, imm: i32 },
    Bltu { rs1: u8, rs2: u8, imm: i32 },
    Bgeu { rs1: u8, rs2: u8, imm: i32 },
    Lb { rd: u8, rs1: u8, imm: i32 },
    Lh { rd: u8, rs1: u8, imm: i32 },
    Lw { rd: u8, rs1: u8, imm: i32 },
    Lbu { rd: u8, rs1: u8, imm: i32 },
    Lhu { rd: u8, rs1: u8, imm: i32 },
    Sb { rs1: u8, rs2: u8, imm: i32 },
    Sh { rs1: u8, rs2: u8, imm: i32 },
    Sw { rs1: u8, rs2: u8, imm: i32 },
    Addi { rd: u8, rs1: u8, imm: i32 },
    Slti { rd: u8, rs1: u8, imm: i32 },
    Sltiu { rd: u8, rs1: u8, imm: i32 },
    Xori { rd: u8, rs1: u8, imm: i32 },
    Ori { rd: u8, rs1: u8, imm: i32 },
    Andi { rd: u8, rs1: u8, imm: i32 },
    Slli { rd: u8, rs1: u8, shamt: u8 },
    Srli { rd: u8, rs1: u8, shamt: u8 },
    Srai { rd: u8, rs1: u8, shamt: u8 },
    Add { rd: u8, rs1: u8, rs2: u8 },
    Sub { rd: u8, rs1: u8, rs2: u8 },
    Sll { rd: u8, rs1: u8, rs2: u8 },
    Slt { rd: u8, rs1: u8, rs2: u8 },
    Sltu { rd: u8, rs1: u8, rs2: u8 },
    Xor { rd: u8, rs1: u8, rs2: u8 },
    Srl { rd: u8, rs1: u8, rs2: u8 },
    Sra { rd: u8, rs1: u8, rs2: u8 },
    Or { rd: u8, rs1: u8, rs2: u8 },
    And { rd: u8, rs1: u8, rs2: u8 },
    Fence,
    Ecall,
    Ebreak,
}

impl Instruction {
    fn registers_valid(self) -> bool {
        match self {
            Self::Lui { rd, .. } | Self::Auipc { rd, .. } | Self::Jal { rd, .. } => rd < 32,
            Self::Jalr { rd, rs1, .. }
            | Self::Lb { rd, rs1, .. }
            | Self::Lh { rd, rs1, .. }
            | Self::Lw { rd, rs1, .. }
            | Self::Lbu { rd, rs1, .. }
            | Self::Lhu { rd, rs1, .. }
            | Self::Addi { rd, rs1, .. }
            | Self::Slti { rd, rs1, .. }
            | Self::Sltiu { rd, rs1, .. }
            | Self::Xori { rd, rs1, .. }
            | Self::Ori { rd, rs1, .. }
            | Self::Andi { rd, rs1, .. }
            | Self::Slli { rd, rs1, .. }
            | Self::Srli { rd, rs1, .. }
            | Self::Srai { rd, rs1, .. } => rd < 32 && rs1 < 32,
            Self::Beq { rs1, rs2, .. }
            | Self::Bne { rs1, rs2, .. }
            | Self::Blt { rs1, rs2, .. }
            | Self::Bge { rs1, rs2, .. }
            | Self::Bltu { rs1, rs2, .. }
            | Self::Bgeu { rs1, rs2, .. }
            | Self::Sb { rs1, rs2, .. }
            | Self::Sh { rs1, rs2, .. }
            | Self::Sw { rs1, rs2, .. } => rs1 < 32 && rs2 < 32,
            Self::Add { rd, rs1, rs2 }
            | Self::Sub { rd, rs1, rs2 }
            | Self::Sll { rd, rs1, rs2 }
            | Self::Slt { rd, rs1, rs2 }
            | Self::Sltu { rd, rs1, rs2 }
            | Self::Xor { rd, rs1, rs2 }
            | Self::Srl { rd, rs1, rs2 }
            | Self::Sra { rd, rs1, rs2 }
            | Self::Or { rd, rs1, rs2 }
            | Self::And { rd, rs1, rs2 } => rd < 32 && rs1 < 32 && rs2 < 32,
            Self::Fence | Self::Ecall | Self::Ebreak => true,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DecodeError {
    IllegalInstruction,
    UnsupportedInstruction,
}

pub fn decode(word: u32) -> Result<Instruction, DecodeError> {
    let opcode = word & 0x7f;
    let rd = ((word >> 7) & 0x1f) as u8;
    let funct3 = (word >> 12) & 0x7;
    let rs1 = ((word >> 15) & 0x1f) as u8;
    let rs2 = ((word >> 20) & 0x1f) as u8;
    let funct7 = word >> 25;
    let sign_extend =
        |value: u32, width: u32| -> i32 { ((value << (32 - width)) as i32) >> (32 - width) };
    let imm_i = sign_extend(word >> 20, 12);
    let imm_s = sign_extend(((word >> 7) & 0x1f) | (((word >> 25) & 0x7f) << 5), 12);
    let imm_b = sign_extend(
        (((word >> 8) & 0xf) << 1)
            | (((word >> 25) & 0x3f) << 5)
            | (((word >> 7) & 1) << 11)
            | (((word >> 31) & 1) << 12),
        13,
    );
    let imm_j = sign_extend(
        (((word >> 21) & 0x3ff) << 1)
            | (((word >> 20) & 1) << 11)
            | (((word >> 12) & 0xff) << 12)
            | (((word >> 31) & 1) << 20),
        21,
    );

    let instruction = match opcode {
        0x37 => Instruction::Lui {
            rd,
            imm: word & 0xffff_f000,
        },
        0x17 => Instruction::Auipc {
            rd,
            imm: word & 0xffff_f000,
        },
        0x6f => Instruction::Jal { rd, imm: imm_j },
        0x67 if funct3 == 0 => Instruction::Jalr {
            rd,
            rs1,
            imm: imm_i,
        },
        0x67 => return Err(DecodeError::IllegalInstruction),
        0x63 => match funct3 {
            0 => Instruction::Beq {
                rs1,
                rs2,
                imm: imm_b,
            },
            1 => Instruction::Bne {
                rs1,
                rs2,
                imm: imm_b,
            },
            4 => Instruction::Blt {
                rs1,
                rs2,
                imm: imm_b,
            },
            5 => Instruction::Bge {
                rs1,
                rs2,
                imm: imm_b,
            },
            6 => Instruction::Bltu {
                rs1,
                rs2,
                imm: imm_b,
            },
            7 => Instruction::Bgeu {
                rs1,
                rs2,
                imm: imm_b,
            },
            _ => return Err(DecodeError::IllegalInstruction),
        },
        0x03 => match funct3 {
            0 => Instruction::Lb {
                rd,
                rs1,
                imm: imm_i,
            },
            1 => Instruction::Lh {
                rd,
                rs1,
                imm: imm_i,
            },
            2 => Instruction::Lw {
                rd,
                rs1,
                imm: imm_i,
            },
            4 => Instruction::Lbu {
                rd,
                rs1,
                imm: imm_i,
            },
            5 => Instruction::Lhu {
                rd,
                rs1,
                imm: imm_i,
            },
            _ => return Err(DecodeError::IllegalInstruction),
        },
        0x23 => match funct3 {
            0 => Instruction::Sb {
                rs1,
                rs2,
                imm: imm_s,
            },
            1 => Instruction::Sh {
                rs1,
                rs2,
                imm: imm_s,
            },
            2 => Instruction::Sw {
                rs1,
                rs2,
                imm: imm_s,
            },
            _ => return Err(DecodeError::IllegalInstruction),
        },
        0x13 => match funct3 {
            0 => Instruction::Addi {
                rd,
                rs1,
                imm: imm_i,
            },
            2 => Instruction::Slti {
                rd,
                rs1,
                imm: imm_i,
            },
            3 => Instruction::Sltiu {
                rd,
                rs1,
                imm: imm_i,
            },
            4 => Instruction::Xori {
                rd,
                rs1,
                imm: imm_i,
            },
            6 => Instruction::Ori {
                rd,
                rs1,
                imm: imm_i,
            },
            7 => Instruction::Andi {
                rd,
                rs1,
                imm: imm_i,
            },
            1 if funct7 == 0 => Instruction::Slli {
                rd,
                rs1,
                shamt: rs2,
            },
            5 if funct7 == 0 => Instruction::Srli {
                rd,
                rs1,
                shamt: rs2,
            },
            5 if funct7 == 0x20 => Instruction::Srai {
                rd,
                rs1,
                shamt: rs2,
            },
            1 | 5 => return Err(DecodeError::IllegalInstruction),
            _ => return Err(DecodeError::IllegalInstruction),
        },
        0x33 => match (funct3, funct7) {
            (0, 0) => Instruction::Add { rd, rs1, rs2 },
            (0, 0x20) => Instruction::Sub { rd, rs1, rs2 },
            (1, 0) => Instruction::Sll { rd, rs1, rs2 },
            (2, 0) => Instruction::Slt { rd, rs1, rs2 },
            (3, 0) => Instruction::Sltu { rd, rs1, rs2 },
            (4, 0) => Instruction::Xor { rd, rs1, rs2 },
            (5, 0) => Instruction::Srl { rd, rs1, rs2 },
            (5, 0x20) => Instruction::Sra { rd, rs1, rs2 },
            (6, 0) => Instruction::Or { rd, rs1, rs2 },
            (7, 0) => Instruction::And { rd, rs1, rs2 },
            _ => return Err(DecodeError::IllegalInstruction),
        },
        0x0f if funct3 == 0
            && rd == 0
            && rs1 == 0
            && (word >> 28 == 0
                || (word >> 28 == 8 && ((word >> 24) & 0xf) == 3 && ((word >> 20) & 0xf) == 3)) =>
        {
            Instruction::Fence
        }
        0x0f => return Err(DecodeError::UnsupportedInstruction),
        0x73 if word == 0x0000_0073 => Instruction::Ecall,
        0x73 if word == 0x0010_0073 => Instruction::Ebreak,
        0x73 => return Err(DecodeError::UnsupportedInstruction),
        _ => return Err(DecodeError::IllegalInstruction),
    };
    Ok(instruction)
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TerminalState {
    Running,
    Halted,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ExecutionError {
    Memory(MemoryError),
    MisalignedInstructionAddress,
    InvalidRegisterIndex,
    Halted,
}

impl From<MemoryError> for ExecutionError {
    fn from(error: MemoryError) -> Self {
        Self::Memory(error)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MachineState<const N: usize> {
    pub pc: u32,
    pub registers: RegisterFile,
    pub memory: Memory<N>,
    pub terminal: TerminalState,
}

impl<const N: usize> MachineState<N> {
    pub const fn new(pc: u32, memory_base: u32) -> Self {
        Self {
            pc,
            registers: RegisterFile::zeroed(),
            memory: Memory::new(memory_base),
            terminal: TerminalState::Running,
        }
    }
}

fn reg_read(registers: &RegisterFile, index: u8) -> u32 {
    registers.read(index).unwrap_or(Word32::ZERO).unsigned()
}

fn reg_write(registers: &mut RegisterFile, index: u8, value: u32) {
    let _ = registers.write(index, Word32::new(value));
}

fn signed_address(base: u32, offset: i32) -> u32 {
    base.wrapping_add(offset as u32)
}

fn branch_target(pc: u32, offset: i32) -> Result<u32, ExecutionError> {
    let target = pc.wrapping_add(offset as u32);
    if target & 0b11 != 0 {
        Err(ExecutionError::MisalignedInstructionAddress)
    } else {
        Ok(target)
    }
}

pub fn step<const N: usize>(
    mut state: MachineState<N>,
    instruction: Instruction,
) -> Result<MachineState<N>, ExecutionError> {
    if state.terminal == TerminalState::Halted {
        return Err(ExecutionError::Halted);
    }
    if !instruction.registers_valid() {
        return Err(ExecutionError::InvalidRegisterIndex);
    }
    if state.pc & 0b11 != 0 {
        return Err(ExecutionError::MisalignedInstructionAddress);
    }
    let pc = state.pc;
    let sequential_pc = pc.wrapping_add(4);
    let source_registers = state.registers.clone();
    let rs1 = |index| reg_read(&source_registers, index);
    let write_rd = |state: &mut MachineState<N>, rd, value| {
        reg_write(&mut state.registers, rd, value);
        state.pc = sequential_pc;
    };

    match instruction {
        Instruction::Lui { rd, imm } => write_rd(&mut state, rd, imm),
        Instruction::Auipc { rd, imm } => write_rd(&mut state, rd, pc.wrapping_add(imm)),
        Instruction::Jal { rd, imm } => {
            let target = branch_target(pc, imm)?;
            reg_write(&mut state.registers, rd, sequential_pc);
            state.pc = target;
        }
        Instruction::Jalr {
            rd,
            rs1: source,
            imm,
        } => {
            let target = signed_address(rs1(source), imm) & !1;
            if target & 0b11 != 0 {
                return Err(ExecutionError::MisalignedInstructionAddress);
            }
            reg_write(&mut state.registers, rd, sequential_pc);
            state.pc = target;
        }
        Instruction::Beq {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if rs1(a) == rs1(b) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Bne {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if rs1(a) != rs1(b) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Blt {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if (rs1(a) as i32) < (rs1(b) as i32) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Bge {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if (rs1(a) as i32) >= (rs1(b) as i32) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Bltu {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if rs1(a) < rs1(b) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Bgeu {
            rs1: a,
            rs2: b,
            imm,
        } => {
            state.pc = if rs1(a) >= rs1(b) {
                branch_target(pc, imm)?
            } else {
                sequential_pc
            };
        }
        Instruction::Lb { rd, rs1: base, imm } => {
            let address = signed_address(rs1(base), imm);
            let value = state.memory.load_u8(address)? as i8 as i32 as u32;
            write_rd(&mut state, rd, value);
        }
        Instruction::Lh { rd, rs1: base, imm } => {
            let address = signed_address(rs1(base), imm);
            let value = state.memory.load_u16(address)? as i16 as i32 as u32;
            write_rd(&mut state, rd, value);
        }
        Instruction::Lw { rd, rs1: base, imm } => {
            let address = signed_address(rs1(base), imm);
            let value = state.memory.load_u32(address)?;
            write_rd(&mut state, rd, value);
        }
        Instruction::Lbu { rd, rs1: base, imm } => {
            let address = signed_address(rs1(base), imm);
            let value = state.memory.load_u8(address)? as u32;
            write_rd(&mut state, rd, value);
        }
        Instruction::Lhu { rd, rs1: base, imm } => {
            let address = signed_address(rs1(base), imm);
            let value = state.memory.load_u16(address)? as u32;
            write_rd(&mut state, rd, value);
        }
        Instruction::Sb {
            rs1: base,
            rs2: source,
            imm,
        } => {
            let address = signed_address(rs1(base), imm);
            state.memory.store_u8(address, rs1(source) as u8)?;
            state.pc = sequential_pc;
        }
        Instruction::Sh {
            rs1: base,
            rs2: source,
            imm,
        } => {
            let address = signed_address(rs1(base), imm);
            state.memory.store_u16(address, rs1(source) as u16)?;
            state.pc = sequential_pc;
        }
        Instruction::Sw {
            rs1: base,
            rs2: source,
            imm,
        } => {
            let address = signed_address(rs1(base), imm);
            state.memory.store_u32(address, rs1(source))?;
            state.pc = sequential_pc;
        }
        Instruction::Addi {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, rs1(source).wrapping_add(imm as u32)),
        Instruction::Slti {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, u32::from((rs1(source) as i32) < imm)),
        Instruction::Sltiu {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, u32::from(rs1(source) < imm as u32)),
        Instruction::Xori {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, rs1(source) ^ imm as u32),
        Instruction::Ori {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, rs1(source) | imm as u32),
        Instruction::Andi {
            rd,
            rs1: source,
            imm,
        } => write_rd(&mut state, rd, rs1(source) & imm as u32),
        Instruction::Slli {
            rd,
            rs1: source,
            shamt,
        } => write_rd(
            &mut state,
            rd,
            rs1(source).wrapping_shl(u32::from(shamt & 31)),
        ),
        Instruction::Srli {
            rd,
            rs1: source,
            shamt,
        } => write_rd(
            &mut state,
            rd,
            rs1(source).wrapping_shr(u32::from(shamt & 31)),
        ),
        Instruction::Srai {
            rd,
            rs1: source,
            shamt,
        } => write_rd(
            &mut state,
            rd,
            ((rs1(source) as i32) >> (shamt & 31)) as u32,
        ),
        Instruction::Add { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, rs1(a).wrapping_add(rs1(b)))
        }
        Instruction::Sub { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, rs1(a).wrapping_sub(rs1(b)))
        }
        Instruction::Sll { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, rs1(a).wrapping_shl(rs1(b) & 31))
        }
        Instruction::Slt { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, u32::from((rs1(a) as i32) < (rs1(b) as i32)))
        }
        Instruction::Sltu { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, u32::from(rs1(a) < rs1(b)))
        }
        Instruction::Xor { rd, rs1: a, rs2: b } => write_rd(&mut state, rd, rs1(a) ^ rs1(b)),
        Instruction::Srl { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, rs1(a).wrapping_shr(rs1(b) & 31))
        }
        Instruction::Sra { rd, rs1: a, rs2: b } => {
            write_rd(&mut state, rd, ((rs1(a) as i32) >> (rs1(b) & 31)) as u32)
        }
        Instruction::Or { rd, rs1: a, rs2: b } => write_rd(&mut state, rd, rs1(a) | rs1(b)),
        Instruction::And { rd, rs1: a, rs2: b } => write_rd(&mut state, rd, rs1(a) & rs1(b)),
        Instruction::Fence => state.pc = sequential_pc,
        Instruction::Ecall | Instruction::Ebreak => state.terminal = TerminalState::Halted,
    }
    Ok(state)
}

#[cfg(test)]
mod tests {
    use super::{
        DecodeError, ExecutionError, Instruction, MachineState, Memory, MemoryError, RegisterFile,
        TerminalState, Word32, decode, step,
    };

    fn state_with_registers<const N: usize>(pc: u32, registers: &[(u8, u32)]) -> MachineState<N> {
        let mut state = MachineState::new(pc, 0);
        for &(index, value) in registers {
            assert!(state.registers.write(index, Word32::new(value)));
        }
        state
    }

    fn value<const N: usize>(state: &MachineState<N>, index: u8) -> u32 {
        state.registers.read(index).unwrap().unsigned()
    }

    #[test]
    fn x0_reads_zero_and_rejects_writes() {
        let mut registers = RegisterFile::zeroed();
        assert_eq!(registers.read(0), Some(Word32::ZERO));
        assert!(!registers.write(0, Word32::new(42)));
        assert_eq!(registers.read(0), Some(Word32::ZERO));
        assert!(registers.x0_is_zero());
    }

    #[test]
    fn register_file_rejects_out_of_range_index() {
        let mut registers = RegisterFile::zeroed();
        assert_eq!(registers.read(32), None);
        assert!(!registers.write(32, Word32::new(1)));
        assert_eq!(
            step(
                MachineState::<8>::new(0, 0),
                Instruction::Addi {
                    rd: 32,
                    rs1: 0,
                    imm: 1
                }
            ),
            Err(ExecutionError::InvalidRegisterIndex)
        );
    }

    #[test]
    fn memory_checks_bounds_alignment_and_end_address_overflow() {
        let mut memory = Memory::<8>::new(0x1000);
        assert_eq!(memory.store_u8(0x1000, 0xAA), Ok(()));
        assert_eq!(memory.load_u8(0x1000), Ok(0xAA));
        assert_eq!(memory.load_u8(0x0FFF), Err(MemoryError::OutOfBounds));
        assert_eq!(memory.load_u8(0x1008), Err(MemoryError::OutOfBounds));
        assert_eq!(memory.load_u16(0x1001), Err(MemoryError::Misaligned));
        assert_eq!(
            memory.checked_offset(u32::MAX - 1, 4, 1),
            Err(MemoryError::AddressOverflow)
        );
    }

    #[test]
    fn multi_byte_memory_access_is_little_endian_and_aligned() {
        let mut memory = Memory::<8>::new(0x2000);
        assert_eq!(memory.store_u16(0x2000, 0x1234), Ok(()));
        assert_eq!(memory.load_u8(0x2000), Ok(0x34));
        assert_eq!(memory.load_u8(0x2001), Ok(0x12));
        assert_eq!(memory.store_u32(0x2004, 0x89AB_CDEF), Ok(()));
        assert_eq!(memory.load_u32(0x2004), Ok(0x89AB_CDEF));
        assert_eq!(memory.load_u32(0x2002), Err(MemoryError::Misaligned));
        assert_eq!(memory.load_u32(0x2008), Err(MemoryError::OutOfBounds));
    }

    #[test]
    fn word_arithmetic_wraps_and_checked_helpers_report_overflow() {
        assert_eq!(
            Word32::new(u32::MAX).wrapping_add(Word32::new(1)),
            Word32::ZERO
        );
        assert_eq!(
            Word32::ZERO.wrapping_sub(Word32::new(1)),
            Word32::new(u32::MAX)
        );
        assert_eq!(Word32::new(u32::MAX).checked_add(Word32::new(1)), None);
        assert_eq!(Word32::ZERO.checked_sub(Word32::new(1)), None);
        assert_eq!(Word32::new(u32::MAX).signed(), -1);
        assert_eq!(Word32::new(u32::MAX).unsigned(), u32::MAX);
    }

    #[test]
    fn decode_accepts_priority_alu_and_rejects_illegal_encodings() {
        assert_eq!(
            decode(0x0010_8093),
            Ok(Instruction::Addi {
                rd: 1,
                rs1: 1,
                imm: 1
            })
        );
        assert_eq!(decode(0), Err(DecodeError::IllegalInstruction));
        assert_eq!(decode(0x0200_1093), Err(DecodeError::IllegalInstruction));
        assert_eq!(
            decode(0x0000_100f),
            Err(DecodeError::UnsupportedInstruction)
        );
        assert_eq!(decode(0x0000_000f), Ok(Instruction::Fence));
        assert_eq!(decode(0x8330_000f), Ok(Instruction::Fence));
    }

    #[test]
    fn step_executes_wrapping_arithmetic_and_bitwise_operations() {
        let state = state_with_registers::<16>(0, &[(1, u32::MAX), (2, 3)]);
        let state = step(
            state,
            Instruction::Add {
                rd: 3,
                rs1: 1,
                rs2: 2,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 3), 2);
        assert_eq!(state.pc, 4);

        let state = step(
            state,
            Instruction::Andi {
                rd: 4,
                rs1: 1,
                imm: 0x0f,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 4), 0x0f);
    }

    #[test]
    fn upper_immediate_and_shift_operations_use_rv32_width() {
        let state = state_with_registers::<16>(0x100, &[(1, 1), (2, 0x8000_0000), (3, 31)]);
        let state = step(
            state,
            Instruction::Lui {
                rd: 4,
                imm: 0xffff_f000,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 4), 0xffff_f000);
        let state = step(state, Instruction::Auipc { rd: 5, imm: 0x1000 }).unwrap();
        assert_eq!(value(&state, 5), 0x1104);
        let state = step(
            state,
            Instruction::Slli {
                rd: 6,
                rs1: 1,
                shamt: 31,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 6), 0x8000_0000);
        let state = step(
            state,
            Instruction::Srli {
                rd: 7,
                rs1: 2,
                shamt: 31,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 7), 1);
        let state = step(
            state,
            Instruction::Srai {
                rd: 8,
                rs1: 2,
                shamt: 31,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 8), u32::MAX);
        let state = step(
            state,
            Instruction::Sub {
                rd: 9,
                rs1: 1,
                rs2: 2,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 9), 0x8000_0001);
        assert_eq!(value(&state, 3), 31);
    }

    #[test]
    fn step_keeps_x0_zero_and_ignores_write() {
        let state = state_with_registers::<16>(0, &[]);
        let state = step(
            state,
            Instruction::Addi {
                rd: 0,
                rs1: 0,
                imm: 99,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 0), 0);
        assert!(state.registers.x0_is_zero());
    }

    #[test]
    fn branch_taken_and_not_taken_update_pc_correctly() {
        let state = state_with_registers::<16>(0, &[(1, 7), (2, 7)]);
        let taken = step(
            state.clone(),
            Instruction::Beq {
                rs1: 1,
                rs2: 2,
                imm: 8,
            },
        )
        .unwrap();
        assert_eq!(taken.pc, 8);
        let not_taken = step(
            state,
            Instruction::Bne {
                rs1: 1,
                rs2: 2,
                imm: 8,
            },
        )
        .unwrap();
        assert_eq!(not_taken.pc, 4);
    }

    #[test]
    fn jal_and_jalr_write_link_and_jump_to_aligned_targets() {
        let state = state_with_registers::<16>(0, &[]);
        let jumped = step(state, Instruction::Jal { rd: 1, imm: 8 }).unwrap();
        assert_eq!(jumped.pc, 8);
        assert_eq!(value(&jumped, 1), 4);

        let state = state_with_registers::<16>(0, &[(2, 9)]);
        let jumped = step(
            state,
            Instruction::Jalr {
                rd: 1,
                rs1: 2,
                imm: 4,
            },
        )
        .unwrap();
        assert_eq!(jumped.pc, 12);
        assert_eq!(value(&jumped, 1), 4);
    }

    #[test]
    fn load_store_are_little_endian_and_faults_are_reported() {
        let mut state = state_with_registers::<16>(0, &[(1, 4), (2, 0x89ab_cdef)]);
        state.memory.store_u32(4, 0x1234_5678).unwrap();
        let loaded = step(
            state,
            Instruction::Lw {
                rd: 3,
                rs1: 1,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(value(&loaded, 3), 0x1234_5678);
        assert_eq!(loaded.memory.load_u8(4), Ok(0x78));

        let stored = step(
            loaded,
            Instruction::Sw {
                rs1: 1,
                rs2: 2,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(stored.memory.load_u32(4), Ok(0x89ab_cdef));

        let misaligned = state_with_registers::<16>(0, &[(1, 2)]);
        assert_eq!(
            step(
                misaligned,
                Instruction::Lw {
                    rd: 3,
                    rs1: 1,
                    imm: 0
                }
            ),
            Err(ExecutionError::Memory(MemoryError::Misaligned))
        );

        let out_of_bounds = state_with_registers::<16>(0, &[(1, 16)]);
        assert_eq!(
            step(
                out_of_bounds,
                Instruction::Lw {
                    rd: 3,
                    rs1: 1,
                    imm: 0
                }
            ),
            Err(ExecutionError::Memory(MemoryError::OutOfBounds))
        );
    }

    #[test]
    fn signed_and_unsigned_comparisons_and_loads_are_distinct() {
        let state = state_with_registers::<16>(0, &[(1, u32::MAX), (2, 1)]);
        let state = step(
            state,
            Instruction::Slt {
                rd: 3,
                rs1: 1,
                rs2: 2,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 3), 1);
        let state = step(
            state,
            Instruction::Sltu {
                rd: 4,
                rs1: 1,
                rs2: 2,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 4), 0);

        let mut state = state_with_registers::<16>(0, &[(1, 0)]);
        state.memory.store_u8(0, 0xff).unwrap();
        let state = step(
            state,
            Instruction::Lb {
                rd: 2,
                rs1: 1,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 2), u32::MAX);
        let state = step(
            state,
            Instruction::Lbu {
                rd: 3,
                rs1: 1,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 3), 0xff);
    }

    #[test]
    fn signed_and_unsigned_branches_and_halfword_memory_work() {
        let state = state_with_registers::<16>(0, &[(1, u32::MAX), (2, 1)]);
        let signed_branch = step(
            state.clone(),
            Instruction::Blt {
                rs1: 1,
                rs2: 2,
                imm: 8,
            },
        )
        .unwrap();
        assert_eq!(signed_branch.pc, 8);
        let unsigned_branch = step(
            state,
            Instruction::Bltu {
                rs1: 1,
                rs2: 2,
                imm: 8,
            },
        )
        .unwrap();
        assert_eq!(unsigned_branch.pc, 4);

        let mut state = state_with_registers::<16>(0, &[(1, 4), (2, 0x8001)]);
        state = step(
            state,
            Instruction::Sh {
                rs1: 1,
                rs2: 2,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(state.memory.load_u16(4), Ok(0x8001));
        let state = step(
            state,
            Instruction::Lh {
                rd: 3,
                rs1: 1,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 3), 0xffff_8001);
        let state = step(
            state,
            Instruction::Lhu {
                rd: 4,
                rs1: 1,
                imm: 0,
            },
        )
        .unwrap();
        assert_eq!(value(&state, 4), 0x8001);
        let state = step(
            state,
            Instruction::Sb {
                rs1: 1,
                rs2: 2,
                imm: 2,
            },
        )
        .unwrap();
        assert_eq!(state.memory.load_u8(6), Ok(1));
    }

    #[test]
    fn ecall_and_ebreak_set_terminal_status_and_fence_advances_pc() {
        let state = state_with_registers::<16>(0, &[]);
        let state = step(state, Instruction::Fence).unwrap();
        assert_eq!(state.pc, 4);
        let state = step(state, Instruction::Ecall).unwrap();
        assert_eq!(state.terminal, TerminalState::Halted);
        assert_eq!(
            step(state, Instruction::Ebreak),
            Err(ExecutionError::Halted)
        );
    }

    #[test]
    fn misaligned_control_flow_target_is_rejected_without_a_successor() {
        let state = state_with_registers::<16>(0, &[]);
        assert_eq!(
            step(state, Instruction::Jal { rd: 1, imm: 2 }),
            Err(ExecutionError::MisalignedInstructionAddress)
        );
    }
}
