import ZkRV32I.ISA

namespace ZkRV32I

inductive TerminalState where
  | running
  | halted
  deriving DecidableEq, Repr

structure MachineState where
  pc : Word32
  regs : RegisterFile
  memory : Memory
  terminal : TerminalState

inductive ExecutionOutcome where
  | continued (state : MachineState)
  | terminated (state : MachineState)

namespace MachineState

def initial (pc : Word32) (memory : Memory) : MachineState :=
  ⟨pc, RegisterFile.zeroed, memory, .running⟩

end MachineState

def nextPC (state : MachineState) : Word32 :=
  Word32.add state.pc 4

def regRead (state : MachineState) (index : Fin 32) : Word32 :=
  state.regs.read index

def regWrite (state : MachineState) (pc : Word32) (rd : Fin 32)
    (value : Word32) : MachineState :=
  { state with pc := pc, regs := state.regs.write rd value }

def boolWord (value : Bool) : Word32 :=
  if value then 1 else 0

def wordAnd (a b : Word32) : Word32 :=
  Word32.ofNat (Nat.land a.toNat b.toNat)

def wordOr (a b : Word32) : Word32 :=
  Word32.ofNat (Nat.lor a.toNat b.toNat)

def wordXor (a b : Word32) : Word32 :=
  Word32.ofNat (Nat.xor a.toNat b.toNat)

def shiftLeft (value : Word32) (amount : Nat) : Word32 :=
  Word32.ofNat (value.toNat * 2 ^ (amount % 32))

def shiftRightLogical (value : Word32) (amount : Nat) : Word32 :=
  Word32.ofNat (value.toNat / 2 ^ (amount % 32))

def shiftRightArithmetic (value : Word32) (amount : Nat) : Word32 :=
  Word32.ofNat ((Word32.signed value).ediv (Int.ofNat (2 ^ (amount % 32))) |>.emod
    (Int.ofNat 4294967296) |>.toNat)

def loadValue (state : MachineState) (address : Word32) (width alignment : Nat)
    (signed : Bool) : Option Word32 := do
  let value ← Memory.load state.memory address.toNat width alignment
  if signed then
    pure (Word32.signExtend value.toNat (width * 8))
  else
    pure value

def storeValue (state : MachineState) (pc : Word32) (address : Word32)
    (width alignment : Nat) (value : Word32) : Option MachineState := do
  let memory ← Memory.store state.memory address.toNat width alignment value
  pure { state with pc := pc, memory := memory }

def branch (state : MachineState) (condition : Bool) (immediate : Word32) :
    Option MachineState := do
  let target := if condition then Word32.add state.pc immediate else nextPC state
  if target.toNat % 4 != 0 then none
  else pure { state with pc := target }

def step (state : MachineState) (instruction : Instruction) : Option MachineState :=
  if state.terminal == .halted then none else
  let pc' := nextPC state
  match instruction with
  | .lui rd imm => some (regWrite state pc' rd imm)
  | .auipc rd imm => some (regWrite state pc' rd (Word32.add state.pc imm))
  | .jal rd imm =>
      let target := Word32.add state.pc imm
      if target.toNat % 4 != 0 then none
      else some (regWrite state target rd pc')
  | .jalr rd rs1 imm =>
      let target := Word32.ofNat (Word32.add (regRead state rs1) imm).toNat
      let target := Word32.ofNat (target.toNat / 2 * 2)
      if target.toNat % 4 != 0 then none
      else some (regWrite state target rd pc')
  | .beq rs1 rs2 imm =>
      branch state (regRead state rs1 == regRead state rs2) imm
  | .bne rs1 rs2 imm =>
      branch state (regRead state rs1 != regRead state rs2) imm
  | .blt rs1 rs2 imm =>
      branch state (Word32.signed (regRead state rs1) <
        Word32.signed (regRead state rs2)) imm
  | .bge rs1 rs2 imm =>
      branch state (Word32.signed (regRead state rs1) >=
        Word32.signed (regRead state rs2)) imm
  | .bltu rs1 rs2 imm =>
      branch state (regRead state rs1 < regRead state rs2) imm
  | .bgeu rs1 rs2 imm =>
      branch state (regRead state rs1 >= regRead state rs2) imm
  | .lb rd rs1 imm =>
      let address := Word32.add (regRead state rs1) imm
      (loadValue state address 1 1 true).map (regWrite state pc' rd)
  | .lh rd rs1 imm =>
      let address := Word32.add (regRead state rs1) imm
      (loadValue state address 2 2 true).map (regWrite state pc' rd)
  | .lw rd rs1 imm =>
      let address := Word32.add (regRead state rs1) imm
      (loadValue state address 4 4 true).map (regWrite state pc' rd)
  | .lbu rd rs1 imm =>
      let address := Word32.add (regRead state rs1) imm
      (loadValue state address 1 1 false).map (regWrite state pc' rd)
  | .lhu rd rs1 imm =>
      let address := Word32.add (regRead state rs1) imm
      (loadValue state address 2 2 false).map (regWrite state pc' rd)
  | .sb rs1 rs2 imm =>
      storeValue state pc' (Word32.add (regRead state rs1) imm) 1 1
        (regRead state rs2)
  | .sh rs1 rs2 imm =>
      storeValue state pc' (Word32.add (regRead state rs1) imm) 2 2
        (regRead state rs2)
  | .sw rs1 rs2 imm =>
      storeValue state pc' (Word32.add (regRead state rs1) imm) 4 4
        (regRead state rs2)
  | .addi rd rs1 imm =>
      some (regWrite state pc' rd (Word32.add (regRead state rs1) imm))
  | .slti rd rs1 imm =>
      some (regWrite state pc' rd
        (boolWord (Word32.signed (regRead state rs1) < Word32.signed imm)))
  | .sltiu rd rs1 imm =>
      some (regWrite state pc' rd (boolWord (regRead state rs1 < imm)))
  | .xori rd rs1 imm =>
      some (regWrite state pc' rd (wordXor (regRead state rs1) imm))
  | .ori rd rs1 imm =>
      some (regWrite state pc' rd (wordOr (regRead state rs1) imm))
  | .andi rd rs1 imm =>
      some (regWrite state pc' rd (wordAnd (regRead state rs1) imm))
  | .slli rd rs1 shamt =>
      some (regWrite state pc' rd (shiftLeft (regRead state rs1) shamt))
  | .srli rd rs1 shamt =>
      some (regWrite state pc' rd (shiftRightLogical (regRead state rs1) shamt))
  | .srai rd rs1 shamt =>
      some (regWrite state pc' rd (shiftRightArithmetic (regRead state rs1) shamt))
  | .add rd rs1 rs2 =>
      some (regWrite state pc' rd (Word32.add (regRead state rs1) (regRead state rs2)))
  | .sub rd rs1 rs2 =>
      some (regWrite state pc' rd (Word32.sub (regRead state rs1) (regRead state rs2)))
  | .sll rd rs1 rs2 =>
      some (regWrite state pc' rd
        (shiftLeft (regRead state rs1) (regRead state rs2).toNat))
  | .slt rd rs1 rs2 =>
      some (regWrite state pc' rd (boolWord
        (Word32.signed (regRead state rs1) < Word32.signed (regRead state rs2))))
  | .sltu rd rs1 rs2 =>
      some (regWrite state pc' rd (boolWord (regRead state rs1 < regRead state rs2)))
  | .xor rd rs1 rs2 =>
      some (regWrite state pc' rd (wordXor (regRead state rs1) (regRead state rs2)))
  | .srl rd rs1 rs2 =>
      some (regWrite state pc' rd
        (shiftRightLogical (regRead state rs1) (regRead state rs2).toNat))
  | .sra rd rs1 rs2 =>
      some (regWrite state pc' rd
        (shiftRightArithmetic (regRead state rs1) (regRead state rs2).toNat))
  | .or rd rs1 rs2 =>
      some (regWrite state pc' rd (wordOr (regRead state rs1) (regRead state rs2)))
  | .and rd rs1 rs2 =>
      some (regWrite state pc' rd (wordAnd (regRead state rs1) (regRead state rs2)))
  | .fence => some { state with pc := pc' }
  | .ecall | .ebreak => some { state with terminal := .halted }

def execute (state : MachineState) (word : Word32) : Option ExecutionOutcome := do
  let instruction ← (decode word).toOption
  let next ← step state instruction
  if next.terminal == .halted then
    pure (.terminated next)
  else
    pure (.continued next)

theorem x0_preserved_by_step (s : MachineState) (i : Instruction) (s' : MachineState)
    (h : step s i = some s') : s'.regs.x0 = 0 := by
  simp [step] at h
  split at h <;> simp_all [RegisterFile.x0, regWrite, RegisterFile.write]

end ZkRV32I
