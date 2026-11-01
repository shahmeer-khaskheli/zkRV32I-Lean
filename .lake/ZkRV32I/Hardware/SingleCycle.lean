import ZkRV32I.Machine

namespace ZkRV32I.Hardware

open ZkRV32I

inductive ALUControl where
  | add
  | sub
  | bitAnd
  | bitOr
  | bitXor
  | signedLessThan
  | unsignedLessThan
  | shiftLeft
  | shiftRightLogical
  | shiftRightArithmetic
  deriving DecidableEq, Repr

def aluExecute (control : ALUControl) (lhs rhs : Word32) : Word32 :=
  match control with
  | .add => Word32.add lhs rhs
  | .sub => Word32.sub lhs rhs
  | .bitAnd => wordAnd lhs rhs
  | .bitOr => wordOr lhs rhs
  | .bitXor => wordXor lhs rhs
  | .signedLessThan => boolWord (Word32.signed lhs < Word32.signed rhs)
  | .unsignedLessThan => boolWord (lhs < rhs)
  | .shiftLeft => ZkRV32I.shiftLeft lhs rhs.toNat
  | .shiftRightLogical => ZkRV32I.shiftRightLogical lhs rhs.toNat
  | .shiftRightArithmetic => ZkRV32I.shiftRightArithmetic lhs rhs.toNat

def selectALUInputs (state : MachineState) (instruction : Instruction) :
    Option (Fin 32 × ALUControl × Word32 × Word32) :=
  let read := regRead state
  match instruction with
  | .addi rd rs1 imm => some (rd, .add, read rs1, imm)
  | .slti rd rs1 imm => some (rd, .signedLessThan, read rs1, imm)
  | .sltiu rd rs1 imm => some (rd, .unsignedLessThan, read rs1, imm)
  | .xori rd rs1 imm => some (rd, .bitXor, read rs1, imm)
  | .ori rd rs1 imm => some (rd, .bitOr, read rs1, imm)
  | .andi rd rs1 imm => some (rd, .bitAnd, read rs1, imm)
  | .slli rd rs1 shamt =>
      some (rd, .shiftLeft, read rs1, Word32.ofNat (shamt % 32))
  | .srli rd rs1 shamt =>
      some (rd, .shiftRightLogical, read rs1, Word32.ofNat (shamt % 32))
  | .srai rd rs1 shamt =>
      some (rd, .shiftRightArithmetic, read rs1, Word32.ofNat (shamt % 32))
  | .add rd rs1 rs2 => some (rd, .add, read rs1, read rs2)
  | .sub rd rs1 rs2 => some (rd, .sub, read rs1, read rs2)
  | .sll rd rs1 rs2 => some (rd, .shiftLeft, read rs1, read rs2)
  | .slt rd rs1 rs2 => some (rd, .signedLessThan, read rs1, read rs2)
  | .sltu rd rs1 rs2 => some (rd, .unsignedLessThan, read rs1, read rs2)
  | .xor rd rs1 rs2 => some (rd, .bitXor, read rs1, read rs2)
  | .srl rd rs1 rs2 => some (rd, .shiftRightLogical, read rs1, read rs2)
  | .sra rd rs1 rs2 => some (rd, .shiftRightArithmetic, read rs1, read rs2)
  | .or rd rs1 rs2 => some (rd, .bitOr, read rs1, read rs2)
  | .and rd rs1 rs2 => some (rd, .bitAnd, read rs1, read rs2)
  | _ => none

/--
One-cycle register/ALU result path for the ALU instruction subset. This is a
functional Lean model of a datapath stage; it is not imported or verified RTL.
-/
def singleCycleALUStep (state : MachineState) (instruction : Instruction) :
    Option MachineState :=
  if state.terminal == .halted || state.pc.toNat % 4 != 0 then none
  else
    match selectALUInputs state instruction with
    | none => none
    | some (rd, control, lhs, rhs) =>
        some (regWrite state (nextPC state) rd (aluExecute control lhs rhs))

theorem aluExecute_add (lhs rhs : Word32) :
    aluExecute .add lhs rhs = Word32.add lhs rhs := rfl

theorem aluExecute_sub (lhs rhs : Word32) :
    aluExecute .sub lhs rhs = Word32.sub lhs rhs := rfl

theorem singleCycleALUStep_refines_step (state : MachineState)
    (instruction : Instruction) (hpc : state.pc.toNat % 4 = 0)
    (hinput : (selectALUInputs state instruction).isSome = true) :
    singleCycleALUStep state instruction = step state instruction := by
  cases instruction <;>
    simp_all [singleCycleALUStep, selectALUInputs, aluExecute, step,
      regRead, nextPC, regWrite, boolWord, wordAnd, wordOr, wordXor,
      ZkRV32I.shiftLeft, ZkRV32I.shiftRightLogical,
      ZkRV32I.shiftRightArithmetic, Word32.ofNat] <;> omega

end ZkRV32I.Hardware
