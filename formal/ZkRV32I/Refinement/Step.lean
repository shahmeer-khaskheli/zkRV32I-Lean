import ZkRV32I.Machine
import ZkRV32I.Refinement.Memory

namespace ZkRV32I.Refinement

open ZkRV32I

structure RustState where
  pc : Word32
  regs : RegisterFile
  memory : Memory
  terminal : TerminalState

inductive RustInstruction where
  | lui (rd : Fin 32) (imm : Word32)
  | auipc (rd : Fin 32) (imm : Word32)
  | jal (rd : Fin 32) (imm : Word32)
  | jalr (rd rs1 : Fin 32) (imm : Word32)
  | beq (rs1 rs2 : Fin 32) (imm : Word32)
  | bne (rs1 rs2 : Fin 32) (imm : Word32)
  | blt (rs1 rs2 : Fin 32) (imm : Word32)
  | bge (rs1 rs2 : Fin 32) (imm : Word32)
  | bltu (rs1 rs2 : Fin 32) (imm : Word32)
  | bgeu (rs1 rs2 : Fin 32) (imm : Word32)
  | lb (rd rs1 : Fin 32) (imm : Word32)
  | lh (rd rs1 : Fin 32) (imm : Word32)
  | lw (rd rs1 : Fin 32) (imm : Word32)
  | lbu (rd rs1 : Fin 32) (imm : Word32)
  | lhu (rd rs1 : Fin 32) (imm : Word32)
  | sb (rs1 rs2 : Fin 32) (imm : Word32)
  | sh (rs1 rs2 : Fin 32) (imm : Word32)
  | sw (rs1 rs2 : Fin 32) (imm : Word32)
  | addi (rd rs1 : Fin 32) (imm : Word32)
  | xori (rd rs1 : Fin 32) (imm : Word32)
  | ori (rd rs1 : Fin 32) (imm : Word32)
  | andi (rd rs1 : Fin 32) (imm : Word32)
  | slti (rd rs1 : Fin 32) (imm : Word32)
  | sltiu (rd rs1 : Fin 32) (imm : Word32)
  | add (rd rs1 rs2 : Fin 32)
  | sub (rd rs1 rs2 : Fin 32)
  | xor (rd rs1 rs2 : Fin 32)
  | or (rd rs1 rs2 : Fin 32)
  | and (rd rs1 rs2 : Fin 32)
  | slt (rd rs1 rs2 : Fin 32)
  | sltu (rd rs1 rs2 : Fin 32)
  | sll (rd rs1 rs2 : Fin 32)
  | srl (rd rs1 rs2 : Fin 32)
  | sra (rd rs1 rs2 : Fin 32)
  | slli (rd rs1 : Fin 32) (shamt : Nat)
  | srli (rd rs1 : Fin 32) (shamt : Nat)
  | srai (rd rs1 : Fin 32) (shamt : Nat)
  | fence
  | ecall
  | ebreak
  | other (instruction : Instruction)
  deriving DecidableEq, Repr

def interpret (state : MachineState) : RustState :=
  ⟨state.pc, state.regs, state.memory, state.terminal⟩

def RustState.toLean (state : RustState) : MachineState :=
  ⟨state.pc, state.regs, state.memory, state.terminal⟩

def related (lean : MachineState) (rust : RustState) : Prop :=
  lean.pc = rust.pc ∧
    lean.regs = rust.regs ∧
    lean.memory = rust.memory ∧
    lean.terminal = rust.terminal

def encodeInstruction : Instruction → RustInstruction
  | .lui rd imm => .lui rd imm
  | .auipc rd imm => .auipc rd imm
  | .jal rd imm => .jal rd imm
  | .jalr rd rs1 imm => .jalr rd rs1 imm
  | .beq rs1 rs2 imm => .beq rs1 rs2 imm
  | .bne rs1 rs2 imm => .bne rs1 rs2 imm
  | .blt rs1 rs2 imm => .blt rs1 rs2 imm
  | .bge rs1 rs2 imm => .bge rs1 rs2 imm
  | .bltu rs1 rs2 imm => .bltu rs1 rs2 imm
  | .bgeu rs1 rs2 imm => .bgeu rs1 rs2 imm
  | .lb rd rs1 imm => .lb rd rs1 imm
  | .lh rd rs1 imm => .lh rd rs1 imm
  | .lw rd rs1 imm => .lw rd rs1 imm
  | .lbu rd rs1 imm => .lbu rd rs1 imm
  | .lhu rd rs1 imm => .lhu rd rs1 imm
  | .sb rs1 rs2 imm => .sb rs1 rs2 imm
  | .sh rs1 rs2 imm => .sh rs1 rs2 imm
  | .sw rs1 rs2 imm => .sw rs1 rs2 imm
  | .addi rd rs1 imm => .addi rd rs1 imm
  | .xori rd rs1 imm => .xori rd rs1 imm
  | .ori rd rs1 imm => .ori rd rs1 imm
  | .andi rd rs1 imm => .andi rd rs1 imm
  | .slti rd rs1 imm => .slti rd rs1 imm
  | .sltiu rd rs1 imm => .sltiu rd rs1 imm
  | .add rd rs1 rs2 => .add rd rs1 rs2
  | .sub rd rs1 rs2 => .sub rd rs1 rs2
  | .xor rd rs1 rs2 => .xor rd rs1 rs2
  | .or rd rs1 rs2 => .or rd rs1 rs2
  | .and rd rs1 rs2 => .and rd rs1 rs2
  | .slt rd rs1 rs2 => .slt rd rs1 rs2
  | .sltu rd rs1 rs2 => .sltu rd rs1 rs2
  | .sll rd rs1 rs2 => .sll rd rs1 rs2
  | .srl rd rs1 rs2 => .srl rd rs1 rs2
  | .sra rd rs1 rs2 => .sra rd rs1 rs2
  | .slli rd rs1 shamt => .slli rd rs1 shamt
  | .srli rd rs1 shamt => .srli rd rs1 shamt
  | .srai rd rs1 shamt => .srai rd rs1 shamt
  | .fence => .fence
  | .ecall => .ecall
  | .ebreak => .ebreak

structure RustFiniteState (size : Nat) where
  pc : Word32
  regs : RegisterFile
  memory : RustMemory size
  terminal : TerminalState

def RustFiniteState.toLean {size : Nat} (state : RustFiniteState size) : MachineState :=
  ⟨state.pc, state.regs, state.memory.toLean, state.terminal⟩

def finiteRelated {size : Nat} (rust : RustFiniteState size) (lean : MachineState) : Prop :=
  rust.pc = lean.pc ∧
    rust.regs = lean.regs ∧
    rust.terminal = lean.terminal ∧
    rust.memory.Refines lean.memory

def rustFiniteLoadValue {size : Nat} (memory : RustMemory size)
    (address width alignment : Nat) (signed : Bool) : Option Word32 := do
  let value ← memory.load address width alignment
  if signed then pure (Word32.signExtend value.toNat (width * 8)) else pure value

theorem rustFiniteLoadValue_matches_lean {size : Nat} (memory : RustMemory size)
    (address width alignment : Nat) (signed : Bool) :
    rustFiniteLoadValue memory address width alignment signed =
      (do
        let value ← Memory.load memory.toLean address width alignment
        if signed then pure (Word32.signExtend value.toNat (width * 8)) else pure value) := by
  unfold rustFiniteLoadValue
  rw [rustLoad_matches_leanLoad]

theorem validRange_offset_end {size : Nat} (memory : RustMemory size)
    (address width alignment : Nat)
    (hvalid : Memory.validRange memory.toLean address width alignment = true) :
    address - memory.base.toNat + width ≤ size := by
  simp [Memory.validRange] at hvalid
  simpa [RustMemory.toLean] using hvalid.2.2.2.2

theorem rustFiniteStore_matches_lean {size : Nat} (memory : RustMemory size)
    (address width alignment : Nat) (value : Word32) :
    (memory.store address width alignment value).map RustMemory.toLean =
      Memory.store memory.toLean address width alignment value := by
  unfold RustMemory.store Memory.store
  by_cases hvalid : Memory.validRange memory.toLean address width alignment
  · have hend := validRange_offset_end memory address width alignment hvalid
    simp only [hvalid, ↓reduceIte, Option.map_some]
    apply congrArg some
    cases memory with
    | mk base bytes =>
        have hend' : address - base.toNat + width ≤ size := by
          simpa [RustMemory.toLean] using hend
        apply congrArg (fun byteFn => Memory.mk base size byteFn)
        funext index
        by_cases hindex : index < size
        · simp [RustMemory.toLean, RustMemory.byteAt, Memory.storeBytes,
            hindex]
        · have houtside :
              ¬ (address - base.toNat ≤ index ∧ index < address - base.toNat + width) := by
            intro hinterval
            omega
          simp [RustMemory.toLean, RustMemory.byteAt, Memory.storeBytes,
            hindex, houtside]
  · simp [hvalid]

theorem rustFiniteStoreStep_matches_lean {size : Nat}
    (state : RustFiniteState size) (pc address : Word32) (width alignment : Nat)
    (value : Word32) :
    (state.memory.store address.toNat width alignment value).map
        (fun memory => { state.toLean with pc := pc, memory := memory.toLean }) =
      storeValue state.toLean pc address width alignment value := by
  have hstore := rustFiniteStore_matches_lean state.memory address.toNat
    width alignment value
  simp only [storeValue]
  have hmap :
      (state.memory.store address.toNat width alignment value).map
          (fun memory => { state.toLean with pc := pc, memory := memory.toLean }) =
        ((state.memory.store address.toNat width alignment value).map RustMemory.toLean).map
          (fun memory => { state.toLean with pc := pc, memory := memory }) := by
    simp [Option.map_map, Function.comp_def]
  rw [hmap, hstore]
  cases hmem : state.toLean.memory.store address.toNat width alignment value <;>
    simpa [hmem, storeValue, RustFiniteState.toLean]

def rustFiniteMemoryStep {size : Nat} (state : RustFiniteState size)
    (instruction : RustInstruction) : Option (RustFiniteState size) :=
  if state.terminal == .halted || state.pc.toNat % 4 != 0 then none else
  let pc' := Word32.add state.pc 4
  match instruction with
  | .lb rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 1 1 true).map fun value =>
        { state with pc := pc', regs := state.regs.write rd value }
  | .lh rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 2 2 true).map fun value =>
        { state with pc := pc', regs := state.regs.write rd value }
  | .lw rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 4 4 true).map fun value =>
        { state with pc := pc', regs := state.regs.write rd value }
  | .lbu rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 1 1 false).map fun value =>
        { state with pc := pc', regs := state.regs.write rd value }
  | .lhu rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 2 2 false).map fun value =>
        { state with pc := pc', regs := state.regs.write rd value }
  | .sb rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 1 1 (state.regs.read rs2)).map fun memory =>
        { state with pc := pc', memory := memory }
  | .sh rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 2 2 (state.regs.read rs2)).map fun memory =>
        { state with pc := pc', memory := memory }
  | .sw rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 4 4 (state.regs.read rs2)).map fun memory =>
        { state with pc := pc', memory := memory }
  | _ => none

def interpretFinite {size : Nat} (state : RustFiniteState size) : RustState :=
  ⟨state.pc, state.regs, state.memory.toLean, state.terminal⟩

def rustFinitePureStep {size : Nat} (state : RustFiniteState size)
    (instruction : RustInstruction) : Option (RustFiniteState size) :=
  if state.terminal == .halted || state.pc.toNat % 4 != 0 then none else
  let pc' := Word32.add state.pc 4
  let write := fun rd value =>
    some { state with pc := pc', regs := state.regs.write rd value }
  let branch := fun (condition : Bool) imm =>
    let target := if condition then Word32.add state.pc imm else pc'
    if target.toNat % 4 != 0 then none else some { state with pc := target }
  match instruction with
  | .lui rd imm => write rd imm
  | .auipc rd imm => write rd (Word32.add state.pc imm)
  | .jal rd imm =>
      let target := Word32.add state.pc imm
      if target.toNat % 4 != 0 then none
      else some { state with pc := target, regs := state.regs.write rd pc' }
  | .jalr rd rs1 imm =>
      let target := Word32.ofNat (Word32.add (state.regs.read rs1) imm).toNat
      let target := Word32.ofNat (target.toNat / 2 * 2)
      if target.toNat % 4 != 0 then none
      else some { state with pc := target, regs := state.regs.write rd pc' }
  | .beq rs1 rs2 imm =>
      branch (state.regs.read rs1 == state.regs.read rs2) imm
  | .bne rs1 rs2 imm =>
      branch (state.regs.read rs1 != state.regs.read rs2) imm
  | .blt rs1 rs2 imm =>
      branch (decide (Word32.signed (state.regs.read rs1) < Word32.signed (state.regs.read rs2))) imm
  | .bge rs1 rs2 imm =>
      branch (decide (Word32.signed (state.regs.read rs1) >= Word32.signed (state.regs.read rs2))) imm
  | .bltu rs1 rs2 imm => branch (decide (state.regs.read rs1 < state.regs.read rs2)) imm
  | .bgeu rs1 rs2 imm => branch (decide (state.regs.read rs1 >= state.regs.read rs2)) imm
  | .addi rd rs1 imm => write rd (Word32.add (state.regs.read rs1) imm)
  | .xori rd rs1 imm => write rd (wordXor (state.regs.read rs1) imm)
  | .ori rd rs1 imm => write rd (wordOr (state.regs.read rs1) imm)
  | .andi rd rs1 imm => write rd (wordAnd (state.regs.read rs1) imm)
  | .slti rd rs1 imm =>
      write rd (boolWord (decide (Word32.signed (state.regs.read rs1) < Word32.signed imm)))
  | .sltiu rd rs1 imm => write rd (boolWord (state.regs.read rs1 < imm))
  | .add rd rs1 rs2 => write rd (Word32.add (state.regs.read rs1) (state.regs.read rs2))
  | .sub rd rs1 rs2 => write rd (Word32.sub (state.regs.read rs1) (state.regs.read rs2))
  | .xor rd rs1 rs2 => write rd (wordXor (state.regs.read rs1) (state.regs.read rs2))
  | .or rd rs1 rs2 => write rd (wordOr (state.regs.read rs1) (state.regs.read rs2))
  | .and rd rs1 rs2 => write rd (wordAnd (state.regs.read rs1) (state.regs.read rs2))
  | .slt rd rs1 rs2 =>
      write rd (boolWord (decide (Word32.signed (state.regs.read rs1) < Word32.signed (state.regs.read rs2))))
  | .sltu rd rs1 rs2 => write rd (boolWord (state.regs.read rs1 < state.regs.read rs2))
  | .sll rd rs1 rs2 => write rd (shiftLeft (state.regs.read rs1) (state.regs.read rs2).toNat)
  | .srl rd rs1 rs2 => write rd (shiftRightLogical (state.regs.read rs1) (state.regs.read rs2).toNat)
  | .sra rd rs1 rs2 =>
      write rd (shiftRightArithmetic (state.regs.read rs1) (state.regs.read rs2).toNat)
  | .slli rd rs1 shamt => write rd (shiftLeft (state.regs.read rs1) shamt)
  | .srli rd rs1 shamt => write rd (shiftRightLogical (state.regs.read rs1) shamt)
  | .srai rd rs1 shamt =>   write rd (shiftRightArithmetic (state.regs.read rs1) shamt)
  | .fence => some { state with pc := pc' }
  | .ecall | .ebreak => some { state with terminal := .halted }
  | _ => none

def rustFiniteInterpreterStep {size : Nat} (state : RustFiniteState size)
    (instruction : RustInstruction) : Option (RustFiniteState size) :=
  match instruction with
  | .lb .. | .lh .. | .lw .. | .lbu .. | .lhu .. | .sb .. | .sh .. | .sw .. =>
      rustFiniteMemoryStep state instruction
  | _ => rustFinitePureStep state instruction

def rustFiniteStepSpec {size : Nat} (state : RustFiniteState size)
    (instruction : RustInstruction) : Option MachineState :=
  if state.terminal == .halted || state.pc.toNat % 4 != 0 then none else
  let leanState := state.toLean
  let pc' := Word32.add state.pc 4
  match instruction with
  | .lb rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 1 1 true).map
        (regWrite leanState pc' rd)
  | .lh rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 2 2 true).map
        (regWrite leanState pc' rd)
  | .lw rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 4 4 true).map
        (regWrite leanState pc' rd)
  | .lbu rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 1 1 false).map
        (regWrite leanState pc' rd)
  | .lhu rd rs1 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (rustFiniteLoadValue state.memory address.toNat 2 2 false).map
        (regWrite leanState pc' rd)
  | .sb rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 1 1 (state.regs.read rs2)).map fun memory =>
        { leanState with pc := pc', memory := memory.toLean }
  | .sh rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 2 2 (state.regs.read rs2)).map fun memory =>
        { leanState with pc := pc', memory := memory.toLean }
  | .sw rs1 rs2 imm =>
      let address := Word32.add (state.regs.read rs1) imm
      (state.memory.store address.toNat 4 4 (state.regs.read rs2)).map fun memory =>
        { leanState with pc := pc', memory := memory.toLean }
  | instruction => (rustFinitePureStep state instruction).map RustFiniteState.toLean

def rustBranch (state : RustState) (condition : Bool) (imm : Word32) :
    Option RustState :=
  let target := if condition then Word32.add state.pc imm else Word32.add state.pc 4
  if target.toNat % 4 != 0 then none else some { state with pc := target }

private def rustField (bits low width : Nat) : Nat :=
  bits / 2 ^ low % 2 ^ width

def rustStepSpec (state : RustState) (instruction : RustInstruction) :
    Option RustState :=
  if state.terminal == .halted || state.pc.toNat % 4 != 0 then none else
  let pc' := Word32.add state.pc 4
  match instruction with
  | .lui rd imm =>
      some { state with pc := pc', regs := state.regs.write rd imm }
  | .auipc rd imm =>
      some { state with pc := pc', regs := state.regs.write rd (Word32.add state.pc imm) }
  | .jal rd imm =>
      let target := Word32.add state.pc imm
      if target.toNat % 4 != 0 then none
      else some { state with pc := target, regs := state.regs.write rd pc' }
  | .jalr rd rs1 imm =>
      let target := Word32.ofNat (Word32.add (state.regs.read rs1) imm).toNat
      let target := Word32.ofNat (target.toNat / 2 * 2)
      if target.toNat % 4 != 0 then none
      else some { state with pc := target, regs := state.regs.write rd pc' }
  | .beq rs1 rs2 imm =>
      rustBranch state (state.regs.read rs1 == state.regs.read rs2) imm
  | .bne rs1 rs2 imm =>
      rustBranch state (state.regs.read rs1 != state.regs.read rs2) imm
  | .blt rs1 rs2 imm =>
      rustBranch state
        (Word32.signed (state.regs.read rs1) < Word32.signed (state.regs.read rs2)) imm
  | .bge rs1 rs2 imm =>
      rustBranch state
        (Word32.signed (state.regs.read rs1) >= Word32.signed (state.regs.read rs2)) imm
  | .bltu rs1 rs2 imm =>
      rustBranch state (state.regs.read rs1 < state.regs.read rs2) imm
  | .bgeu rs1 rs2 imm =>
      rustBranch state (state.regs.read rs1 >= state.regs.read rs2) imm
  | .lb .. | .lh .. | .lw .. | .lbu .. | .lhu .. | .sb .. | .sh .. | .sw .. => none
  | .addi rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (Word32.add (state.regs.read rs1) imm) }
  | .xori rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (wordXor (state.regs.read rs1) imm) }
  | .ori rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (wordOr (state.regs.read rs1) imm) }
  | .andi rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (wordAnd (state.regs.read rs1) imm) }
  | .slti rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (boolWord (decide (Word32.signed (state.regs.read rs1) < Word32.signed imm))) }
  | .sltiu rd rs1 imm =>
      some { state with pc := pc', regs := state.regs.write rd (boolWord (decide (state.regs.read rs1 < imm))) }
  | .add rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (Word32.add (state.regs.read rs1) (state.regs.read rs2)) }
  | .sub rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (Word32.sub (state.regs.read rs1) (state.regs.read rs2)) }
  | .xor rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (wordXor (state.regs.read rs1) (state.regs.read rs2)) }
  | .or rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (wordOr (state.regs.read rs1) (state.regs.read rs2)) }
  | .and rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (wordAnd (state.regs.read rs1) (state.regs.read rs2)) }
  | .slt rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (boolWord (decide (Word32.signed (state.regs.read rs1) < Word32.signed (state.regs.read rs2)))) }
  | .sltu rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (boolWord (decide (state.regs.read rs1 < state.regs.read rs2))) }
  | .sll rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (shiftLeft (state.regs.read rs1) (state.regs.read rs2).toNat) }
  | .srl rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (shiftRightLogical (state.regs.read rs1) (state.regs.read rs2).toNat) }
  | .sra rd rs1 rs2 =>
      some { state with pc := pc', regs := state.regs.write rd (shiftRightArithmetic (state.regs.read rs1) (state.regs.read rs2).toNat) }
  | .slli rd rs1 shamt =>
      some { state with pc := pc', regs := state.regs.write rd (shiftLeft (state.regs.read rs1) shamt) }
  | .srli rd rs1 shamt =>
      some { state with pc := pc', regs := state.regs.write rd (shiftRightLogical (state.regs.read rs1) shamt) }
  | .srai rd rs1 shamt =>
      some { state with pc := pc', regs := state.regs.write rd (shiftRightArithmetic (state.regs.read rs1) shamt) }
  | .fence => some { state with pc := pc' }
  | .ecall | .ebreak => some { state with terminal := .halted }
  | .other _ => none

def rustDecode (word : Word32) : Except DecodeError RustInstruction :=
  let bits := word.toNat
  let opcode := rustField bits 0 7
  let rd : Fin 32 := ⟨rustField bits 7 5, Nat.mod_lt _ (by decide)⟩
  let rs1 : Fin 32 := ⟨rustField bits 15 5, Nat.mod_lt _ (by decide)⟩
  let rs2 : Fin 32 := ⟨rustField bits 20 5, Nat.mod_lt _ (by decide)⟩
  let funct3 := rustField bits 12 3
  let funct7 := rustField bits 25 7
  let immI := Word32.signExtend (rustField bits 20 12) 12
  let shamt := rustField bits 20 5
  let immJ := Word32.signExtend
    (rustField bits 21 10 * 2 + rustField bits 20 1 * 2048 +
      rustField bits 12 8 * 4096 + rustField bits 31 1 * 1048576) 21
  if opcode == 99 then
    let imm := Word32.signExtend (bImmediateRaw bits) 13
    match rustField bits 12 3 with
    | 0 => .ok (.beq rs1 rs2 imm)
    | 1 => .ok (.bne rs1 rs2 imm)
    | 4 => .ok (.blt rs1 rs2 imm)
    | 5 => .ok (.bge rs1 rs2 imm)
    | 6 => .ok (.bltu rs1 rs2 imm)
    | 7 => .ok (.bgeu rs1 rs2 imm)
    | _ => (decode word).map encodeInstruction
  else if opcode == 111 then
    .ok (.jal rd immJ)
  else if opcode == 103 then
    if funct3 == 0 then .ok (.jalr rd rs1 immI)
    else (decode word).map encodeInstruction
  else if opcode == 15 then
    (decode word).map encodeInstruction
  else if opcode == 115 then
    (decode word).map encodeInstruction
  else if opcode == 19 then
    match funct3 with
    | 0 => .ok (.addi rd rs1 immI)
    | 2 => .ok (.slti rd rs1 immI)
    | 3 => .ok (.sltiu rd rs1 immI)
    | 4 => .ok (.xori rd rs1 immI)
    | 6 => .ok (.ori rd rs1 immI)
    | 7 => .ok (.andi rd rs1 immI)
    | 1 => if funct7 == 0 then .ok (.slli rd rs1 shamt) else (decode word).map encodeInstruction
    | 5 =>
        if funct7 == 0 then .ok (.srli rd rs1 shamt)
        else if funct7 == 32 then .ok (.srai rd rs1 shamt)
        else (decode word).map encodeInstruction
    | _ => (decode word).map encodeInstruction
  else if opcode == 51 then
    match funct3, funct7 with
    | 0, 0 => .ok (.add rd rs1 rs2)
    | 0, 32 => .ok (.sub rd rs1 rs2)
    | 1, 0 => .ok (.sll rd rs1 rs2)
    | 2, 0 => .ok (.slt rd rs1 rs2)
    | 3, 0 => .ok (.sltu rd rs1 rs2)
    | 4, 0 => .ok (.xor rd rs1 rs2)
    | 5, 0 => .ok (.srl rd rs1 rs2)
    | 5, 32 => .ok (.sra rd rs1 rs2)
    | 6, 0 => .ok (.or rd rs1 rs2)
    | 7, 0 => .ok (.and rd rs1 rs2)
    | _, _ => (decode word).map encodeInstruction
  else
    (decode word).map encodeInstruction

set_option maxHeartbeats 1000000

theorem interpret_related (state : MachineState) :
    related state (interpret state) := by
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem encode_lui (rd : Fin 32) (imm : Word32) :
    encodeInstruction (.lui rd imm) = .lui rd imm := rfl

theorem encode_auipc (rd : Fin 32) (imm : Word32) :
    encodeInstruction (.auipc rd imm) = .auipc rd imm := rfl

theorem encode_blt (rs1 rs2 : Fin 32) (imm : Word32) :
    encodeInstruction (.blt rs1 rs2 imm) = .blt rs1 rs2 imm := rfl

theorem encode_bge (rs1 rs2 : Fin 32) (imm : Word32) :
    encodeInstruction (.bge rs1 rs2 imm) = .bge rs1 rs2 imm := rfl

theorem encode_bltu (rs1 rs2 : Fin 32) (imm : Word32) :
    encodeInstruction (.bltu rs1 rs2 imm) = .bltu rs1 rs2 imm := rfl

theorem encode_bgeu (rs1 rs2 : Fin 32) (imm : Word32) :
    encodeInstruction (.bgeu rs1 rs2 imm) = .bgeu rs1 rs2 imm := rfl

theorem decode_lui_example :
    rustDecode (Word32.ofNat 0x123450b7) =
      .ok (.lui ⟨1, by decide⟩ (Word32.ofNat 0x12345000)) := by
  rfl

theorem decode_auipc_example :
    rustDecode (Word32.ofNat 0x12345097) =
      .ok (.auipc ⟨1, by decide⟩ (Word32.ofNat 0x12345000)) := by
  rfl

set_option maxRecDepth 4096 in
theorem decode_blt_negative_bit7_immediate :
    rustDecode (Word32.ofNat 0x8020c0e3) =
      .ok (.blt ⟨1, by decide⟩ ⟨2, by decide⟩ (Word32.ofNat 0xfffff800)) := by
      have hword : (Word32.ofNat 0x8020c0e3).toNat = 0x8020c0e3 := by decide
      simp [rustDecode, rustField, bImmediateRaw, bitField, Word32.signExtend, hword]

set_option maxRecDepth 4096 in
theorem decode_bge_negative_bit7_immediate :
    rustDecode (Word32.ofNat 0x8020d0e3) =
      .ok (.bge ⟨1, by decide⟩ ⟨2, by decide⟩ (Word32.ofNat 0xfffff800)) := by
      have hword : (Word32.ofNat 0x8020d0e3).toNat = 0x8020d0e3 := by decide
      simp [rustDecode, rustField, bImmediateRaw, bitField, Word32.signExtend, hword]

set_option maxRecDepth 4096 in
theorem decode_bltu_negative_bit7_immediate :
    rustDecode (Word32.ofNat 0x8020e0e3) =
      .ok (.bltu ⟨1, by decide⟩ ⟨2, by decide⟩ (Word32.ofNat 0xfffff800)) := by
      have hword : (Word32.ofNat 0x8020e0e3).toNat = 0x8020e0e3 := by decide
      simp [rustDecode, rustField, bImmediateRaw, bitField, Word32.signExtend, hword]

set_option maxRecDepth 4096 in
theorem decode_bgeu_negative_bit7_immediate :
    rustDecode (Word32.ofNat 0x8020f0e3) =
      .ok (.bgeu ⟨1, by decide⟩ ⟨2, by decide⟩ (Word32.ofNat 0xfffff800)) := by
      have hword : (Word32.ofNat 0x8020f0e3).toNat = 0x8020f0e3 := by decide
      simp [rustDecode, rustField, bImmediateRaw, bitField, Word32.signExtend, hword]

set_option maxRecDepth 4096 in
theorem decode_lb_zero_offset :
        rustDecode (Word32.ofNat 0x00008103) =
          .ok (.lb ⟨2, by decide⟩ ⟨1, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_lh_zero_offset :
        rustDecode (Word32.ofNat 0x00009103) =
          .ok (.lh ⟨2, by decide⟩ ⟨1, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_lw_zero_offset :
        rustDecode (Word32.ofNat 0x0000a103) =
          .ok (.lw ⟨2, by decide⟩ ⟨1, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_lbu_zero_offset :
        rustDecode (Word32.ofNat 0x0000c103) =
          .ok (.lbu ⟨2, by decide⟩ ⟨1, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_lhu_zero_offset :
        rustDecode (Word32.ofNat 0x0000d103) =
          .ok (.lhu ⟨2, by decide⟩ ⟨1, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sb_zero_offset :
        rustDecode (Word32.ofNat 0x00208023) =
          .ok (.sb ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sh_zero_offset :
        rustDecode (Word32.ofNat 0x00209023) =
          .ok (.sh ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sw_zero_offset :
        rustDecode (Word32.ofNat 0x0020a023) =
          .ok (.sw ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_lb_sign_extended_immediate :
        rustDecode (Word32.ofNat 0xfff08103) =
          .ok (.lb ⟨2, by decide⟩ ⟨1, by decide⟩ (Word32.ofNat 0xffffffff)) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sb_sign_extended_immediate :
    rustDecode (Word32.ofNat 0xfe208fa3) =
      .ok (.sb ⟨1, by decide⟩ ⟨2, by decide⟩ (Word32.ofNat 0xffffffff)) := by rfl

theorem lb_finite_memory_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rd rs1 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (.lb rd rs1 imm) =
          step state.toLean (.lb rd rs1 imm) := by
  by_cases hhalt : state.terminal = .halted
  · simp [rustFiniteStepSpec, RustFiniteState.toLean, step, hhalt]
  · have hload := rustFiniteLoadValue_matches_lean state.memory
          (Word32.add (state.regs.read rs1) imm).toNat 1 1 true
    simp [rustFiniteStepSpec, RustFiniteState.toLean, step, loadValue, regWrite, nextPC, hpc, hhalt,
          RustFiniteState.toLean, regRead, hload]

theorem lh_finite_memory_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rd rs1 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (.lh rd rs1 imm) =
      step state.toLean (.lh rd rs1 imm) := by
  by_cases hhalt : state.terminal = .halted
  · simp [rustFiniteStepSpec, RustFiniteState.toLean, step, hhalt]
  · have hload := rustFiniteLoadValue_matches_lean state.memory
      (Word32.add (state.regs.read rs1) imm).toNat 2 2 true
    simp [rustFiniteStepSpec, RustFiniteState.toLean, step, loadValue, regWrite,
      nextPC, hpc, hhalt, regRead, hload]

theorem lw_finite_memory_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rd rs1 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (.lw rd rs1 imm) =
      step state.toLean (.lw rd rs1 imm) := by
  by_cases hhalt : state.terminal = .halted
  · simp [rustFiniteStepSpec, RustFiniteState.toLean, step, hhalt]
  · have hload := rustFiniteLoadValue_matches_lean state.memory
      (Word32.add (state.regs.read rs1) imm).toNat 4 4 true
    simp [rustFiniteStepSpec, RustFiniteState.toLean, step, loadValue, regWrite,
      nextPC, hpc, hhalt, regRead, hload]

theorem lbu_finite_memory_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rd rs1 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (.lbu rd rs1 imm) =
      step state.toLean (.lbu rd rs1 imm) := by
  by_cases hhalt : state.terminal = .halted
  · simp [rustFiniteStepSpec, RustFiniteState.toLean, step, hhalt]
  · have hload := rustFiniteLoadValue_matches_lean state.memory
      (Word32.add (state.regs.read rs1) imm).toNat 1 1 false
    simp [rustFiniteStepSpec, RustFiniteState.toLean, step, loadValue, regWrite,
      nextPC, hpc, hhalt, regRead, hload]

theorem lhu_finite_memory_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rd rs1 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (.lhu rd rs1 imm) =
      step state.toLean (.lhu rd rs1 imm) := by
  by_cases hhalt : state.terminal = .halted
  · simp [rustFiniteStepSpec, RustFiniteState.toLean, step, hhalt]
  · have hload := rustFiniteLoadValue_matches_lean state.memory
      (Word32.add (state.regs.read rs1) imm).toNat 2 2 false
    simp [rustFiniteStepSpec, RustFiniteState.toLean, step, loadValue, regWrite,
      nextPC, hpc, hhalt, regRead, hload]

theorem sb_finite_store_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rs1 rs2 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) (hrunning : state.terminal ≠ .halted)
    (hvalid : Memory.validRange state.memory.toLean
      (Word32.add (state.regs.read rs1) imm).toNat 1 1) :
    ∃ rustNext leanNext,
      rustFiniteMemoryStep state (.sb rs1 rs2 imm) = some rustNext ∧
      rustFiniteStepSpec state (.sb rs1 rs2 imm) = some rustNext.toLean ∧
      step state.toLean (.sb rs1 rs2 imm) = some leanNext ∧
      finiteRelated rustNext leanNext := by
  let address := Word32.add (state.regs.read rs1) imm
  let value := state.regs.read rs2
  obtain ⟨rustMemory, leanMemory, hrustStore, hleanStore, hrefines⟩ :=
    rustStore_success_refines_leanStore state.memory address.toNat 1 1 value hvalid
  let rustNext : RustFiniteState size :=
    { state with pc := Word32.add state.pc 4, memory := rustMemory }
  let leanNext : MachineState :=
    { state.toLean with pc := Word32.add state.pc 4, memory := leanMemory }
  refine ⟨rustNext, leanNext, ?_, ?_, ?_, ?_⟩
  · simp [rustFiniteMemoryStep, hpc, hrunning, address, value, rustNext, hrustStore]
  · simp [rustFiniteStepSpec, hpc, hrunning, address, value, rustNext, hrustStore,
      RustFiniteState.toLean]
  · simp [step, storeValue, regRead, hrunning, address, value, leanNext, hleanStore,
      nextPC, RustFiniteState.toLean]
  · exact ⟨rfl, rfl, rfl, hrefines⟩

theorem sh_finite_store_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rs1 rs2 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) (hrunning : state.terminal ≠ .halted)
    (hvalid : Memory.validRange state.memory.toLean
      (Word32.add (state.regs.read rs1) imm).toNat 2 2) :
    ∃ rustNext leanNext,
      rustFiniteMemoryStep state (.sh rs1 rs2 imm) = some rustNext ∧
      rustFiniteStepSpec state (.sh rs1 rs2 imm) = some rustNext.toLean ∧
      step state.toLean (.sh rs1 rs2 imm) = some leanNext ∧
      finiteRelated rustNext leanNext := by
  let address := Word32.add (state.regs.read rs1) imm
  let value := state.regs.read rs2
  obtain ⟨rustMemory, leanMemory, hrustStore, hleanStore, hrefines⟩ :=
    rustStore_success_refines_leanStore state.memory address.toNat 2 2 value hvalid
  let rustNext : RustFiniteState size :=
    { state with pc := Word32.add state.pc 4, memory := rustMemory }
  let leanNext : MachineState :=
    { state.toLean with pc := Word32.add state.pc 4, memory := leanMemory }
  refine ⟨rustNext, leanNext, ?_, ?_, ?_, ?_⟩
  · simp [rustFiniteMemoryStep, hpc, hrunning, address, value, rustNext, hrustStore]
  · simp [rustFiniteStepSpec, hpc, hrunning, address, value, rustNext, hrustStore,
      RustFiniteState.toLean]
  · simp [step, storeValue, regRead, hrunning, address, value, leanNext, hleanStore,
      nextPC, RustFiniteState.toLean]
  · exact ⟨rfl, rfl, rfl, hrefines⟩

theorem sw_finite_store_step_correspondence {size : Nat}
    (state : RustFiniteState size) (rs1 rs2 : Fin 32) (imm : Word32)
    (hpc : state.pc.toNat % 4 = 0) (hrunning : state.terminal ≠ .halted)
    (hvalid : Memory.validRange state.memory.toLean
      (Word32.add (state.regs.read rs1) imm).toNat 4 4) :
    ∃ rustNext leanNext,
      rustFiniteMemoryStep state (.sw rs1 rs2 imm) = some rustNext ∧
      rustFiniteStepSpec state (.sw rs1 rs2 imm) = some rustNext.toLean ∧
      step state.toLean (.sw rs1 rs2 imm) = some leanNext ∧
      finiteRelated rustNext leanNext := by
  let address := Word32.add (state.regs.read rs1) imm
  let value := state.regs.read rs2
  obtain ⟨rustMemory, leanMemory, hrustStore, hleanStore, hrefines⟩ :=
    rustStore_success_refines_leanStore state.memory address.toNat 4 4 value hvalid
  let rustNext : RustFiniteState size :=
    { state with pc := Word32.add state.pc 4, memory := rustMemory }
  let leanNext : MachineState :=
    { state.toLean with pc := Word32.add state.pc 4, memory := leanMemory }
  refine ⟨rustNext, leanNext, ?_, ?_, ?_, ?_⟩
  · simp [rustFiniteMemoryStep, hpc, hrunning, address, value, rustNext, hrustStore]
  · simp [rustFiniteStepSpec, hpc, hrunning, address, value, rustNext, hrustStore,
      RustFiniteState.toLean]
  · simp [step, storeValue, regRead, hrunning, address, value, leanNext, hleanStore,
      nextPC, RustFiniteState.toLean]
  · exact ⟨rfl, rfl, rfl, hrefines⟩

theorem rustBranch_matches_Lean_branch (state : MachineState) (condition : Bool)
    (imm : Word32) :
    rustBranch (interpret state) condition imm =
      (branch state condition imm).map interpret := by
  cases condition <;> simp [rustBranch, branch, interpret, nextPC]

theorem lui_step_correspondence (state : MachineState) (rd : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.lui rd imm)) =
      (step state (.lui rd imm)).map interpret := by
  by_cases h : state.terminal = .halted
  · simp [rustStepSpec, interpret, encodeInstruction, step, h, hpc]
  · simp [rustStepSpec, interpret, encodeInstruction, step, h, hpc,
      nextPC, regWrite, RegisterFile.write]

theorem auipc_step_correspondence (state : MachineState) (rd : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.auipc rd imm)) =
      (step state (.auipc rd imm)).map interpret := by
  by_cases h : state.terminal = .halted
  · simp [rustStepSpec, interpret, encodeInstruction, step, h, hpc]
  · simp [rustStepSpec, interpret, encodeInstruction, step, h, hpc,
      nextPC, regWrite, RegisterFile.write]

theorem lui_success_correspondence (state : MachineState) (rd : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.lui rd imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.lui rd imm)) =
      some (interpret next) := by
  rw [lui_step_correspondence state rd imm hpc]
  simp [hstep]

theorem auipc_success_correspondence (state : MachineState) (rd : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.auipc rd imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.auipc rd imm)) =
      some (interpret next) := by
  rw [auipc_step_correspondence state rd imm hpc]
  simp [hstep]

theorem blt_step_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.blt rs1 rs2 imm)) =
      (step state (.blt rs1 rs2 imm)).map interpret := by
  by_cases hhalt : state.terminal = .halted
  · have hhalt' : (interpret state).terminal = .halted := by simpa [interpret] using hhalt
    simp [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, step]
  · have hhalt' : (interpret state).terminal ≠ .halted := by simpa [interpret] using hhalt
    have hpc' : (interpret state).pc.toNat % 4 = 0 := by simpa [interpret] using hpc
    simp only [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, hpc', step, regRead]
    rw [rustBranch_matches_Lean_branch]
    simp [interpret, hhalt]

theorem bge_step_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.bge rs1 rs2 imm)) =
      (step state (.bge rs1 rs2 imm)).map interpret := by
  by_cases hhalt : state.terminal = .halted
  · have hhalt' : (interpret state).terminal = .halted := by simpa [interpret] using hhalt
    simp [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, step]
  · have hhalt' : (interpret state).terminal ≠ .halted := by simpa [interpret] using hhalt
    have hpc' : (interpret state).pc.toNat % 4 = 0 := by simpa [interpret] using hpc
    simp only [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, hpc', step, regRead]
    rw [rustBranch_matches_Lean_branch]
    simp [interpret, hhalt]

theorem bltu_step_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.bltu rs1 rs2 imm)) =
      (step state (.bltu rs1 rs2 imm)).map interpret := by
  by_cases hhalt : state.terminal = .halted
  · have hhalt' : (interpret state).terminal = .halted := by simpa [interpret] using hhalt
    simp [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, step]
  · have hhalt' : (interpret state).terminal ≠ .halted := by simpa [interpret] using hhalt
    have hpc' : (interpret state).pc.toNat % 4 = 0 := by simpa [interpret] using hpc
    simp only [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, hpc', step, regRead]
    rw [rustBranch_matches_Lean_branch]
    simp [interpret, hhalt]

theorem bgeu_step_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction (.bgeu rs1 rs2 imm)) =
      (step state (.bgeu rs1 rs2 imm)).map interpret := by
  by_cases hhalt : state.terminal = .halted
  · have hhalt' : (interpret state).terminal = .halted := by simpa [interpret] using hhalt
    simp [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, step]
  · have hhalt' : (interpret state).terminal ≠ .halted := by simpa [interpret] using hhalt
    have hpc' : (interpret state).pc.toNat % 4 = 0 := by simpa [interpret] using hpc
    simp only [rustStepSpec, encodeInstruction, hhalt', hhalt, hpc, hpc', step, regRead]
    rw [rustBranch_matches_Lean_branch]
    simp [interpret, hhalt]

theorem blt_success_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.blt rs1 rs2 imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.blt rs1 rs2 imm)) =
      some (interpret next) := by
  rw [blt_step_correspondence state rs1 rs2 imm hpc]
  simp [hstep]

theorem bge_success_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.bge rs1 rs2 imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.bge rs1 rs2 imm)) =
      some (interpret next) := by
  rw [bge_step_correspondence state rs1 rs2 imm hpc]
  simp [hstep]

theorem bltu_success_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.bltu rs1 rs2 imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.bltu rs1 rs2 imm)) =
      some (interpret next) := by
  rw [bltu_step_correspondence state rs1 rs2 imm hpc]
  simp [hstep]

theorem bgeu_success_correspondence (state : MachineState) (rs1 rs2 : Fin 32)
    (imm : Word32) (hpc : state.pc.toNat % 4 = 0) (next : MachineState)
    (hstep : step state (.bgeu rs1 rs2 imm) = some next) :
    rustStepSpec (interpret state) (encodeInstruction (.bgeu rs1 rs2 imm)) =
      some (interpret next) := by
  rw [bgeu_step_correspondence state rs1 rs2 imm hpc]
  simp [hstep]

set_option maxRecDepth 4096 in
theorem decode_addi_example :
    rustDecode (Word32.ofNat 0x00010193) =
      .ok (.addi ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_slti_example :
    rustDecode (Word32.ofNat 0x00012193) =
      .ok (.slti ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sltiu_example :
    rustDecode (Word32.ofNat 0x00013193) =
      .ok (.sltiu ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_xori_example :
    rustDecode (Word32.ofNat 0x00014193) =
      .ok (.xori ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_ori_example :
    rustDecode (Word32.ofNat 0x00016193) =
      .ok (.ori ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_andi_example :
    rustDecode (Word32.ofNat 0x00017193) =
      .ok (.andi ⟨3, by decide⟩ ⟨2, by decide⟩ 0) := by rfl

set_option maxRecDepth 4096 in
theorem decode_slli_example :
    rustDecode (Word32.ofNat 0x00311193) =
      .ok (.slli ⟨3, by decide⟩ ⟨2, by decide⟩ 3) := by rfl

set_option maxRecDepth 4096 in
theorem decode_srli_example :
    rustDecode (Word32.ofNat 0x00315193) =
      .ok (.srli ⟨3, by decide⟩ ⟨2, by decide⟩ 3) := by rfl

set_option maxRecDepth 4096 in
theorem decode_srai_example :
    rustDecode (Word32.ofNat 0x40315193) =
      .ok (.srai ⟨3, by decide⟩ ⟨2, by decide⟩ 3) := by rfl

set_option maxRecDepth 4096 in
theorem decode_add_example :
    rustDecode (Word32.ofNat 0x001101b3) =
      .ok (.add ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sub_example :
    rustDecode (Word32.ofNat 0x401101b3) =
      .ok (.sub ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sll_example :
    rustDecode (Word32.ofNat 0x001111b3) =
      .ok (.sll ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_slt_example :
    rustDecode (Word32.ofNat 0x001121b3) =
      .ok (.slt ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sltu_example :
    rustDecode (Word32.ofNat 0x001131b3) =
      .ok (.sltu ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_xor_example :
    rustDecode (Word32.ofNat 0x001141b3) =
      .ok (.xor ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_srl_example :
    rustDecode (Word32.ofNat 0x001151b3) =
      .ok (.srl ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_sra_example :
    rustDecode (Word32.ofNat 0x401151b3) =
      .ok (.sra ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_or_example :
    rustDecode (Word32.ofNat 0x001161b3) =
      .ok (.or ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

set_option maxRecDepth 4096 in
theorem decode_and_example :
    rustDecode (Word32.ofNat 0x001171b3) =
      .ok (.and ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨1, by decide⟩) := by rfl

def isAluInstruction : Instruction → Bool
  | .addi .. | .slti .. | .sltiu .. | .xori .. | .ori .. | .andi ..
  | .slli .. | .srli .. | .srai ..
  | .add .. | .sub .. | .sll .. | .slt .. | .sltu .. | .xor .. | .srl ..
  | .sra .. | .or .. | .and .. => true
  | _ => false

def isCoveredInstruction : Instruction → Bool
  | .lui .. | .auipc .. | .jal .. | .jalr .. | .beq .. | .bne ..
  | .blt .. | .bge .. | .bltu .. | .bgeu ..
  | .lb .. | .lh .. | .lw .. | .lbu .. | .lhu .. | .sb .. | .sh .. | .sw .. => true
  | .fence | .ecall | .ebreak => true
  | instruction => isAluInstruction instruction

theorem all_isa_instructions_covered (instruction : Instruction) :
    isCoveredInstruction instruction = true := by
  cases instruction <;> rfl

theorem alu_family_step_correspondence (state : MachineState)
    (instruction : Instruction) (hAlu : isAluInstruction instruction = true)
    (hpc : state.pc.toNat % 4 = 0) :
    rustStepSpec (interpret state) (encodeInstruction instruction) =
      (step state instruction).map interpret := by
  cases instruction <;> simp [isAluInstruction] at hAlu
  all_goals
    by_cases hhalt : state.terminal = .halted
    · simp [rustStepSpec, encodeInstruction, step, interpret, regRead, hhalt, hpc]
    · simp [rustStepSpec, encodeInstruction, step, interpret, hhalt, hpc,
        nextPC, regRead, regWrite, RegisterFile.write]

theorem finite_alu_family_step_correspondence {size : Nat}
    (state : RustFiniteState size) (instruction : Instruction)
    (hAlu : isAluInstruction instruction = true)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (encodeInstruction instruction) =
      (step state.toLean instruction).map id := by
  cases instruction <;> simp [isAluInstruction] at hAlu
  all_goals
    by_cases hhalt : state.terminal = .halted
    · simp [rustFiniteStepSpec, encodeInstruction, RustFiniteState.toLean,
        rustFinitePureStep, step, regRead, hhalt, hpc]
    · simp [rustFiniteStepSpec, encodeInstruction, RustFiniteState.toLean,
        rustFinitePureStep, step, regRead, hhalt, hpc, nextPC, regWrite,
        RegisterFile.write]

def isControlInstruction : Instruction → Bool
  | .jal .. | .jalr .. | .beq .. | .bne .. | .fence | .ecall | .ebreak => true
  | _ => false

theorem finite_control_step_correspondence {size : Nat}
    (state : RustFiniteState size) (instruction : Instruction)
    (hControl : isControlInstruction instruction = true)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (encodeInstruction instruction) =
      (step state.toLean instruction).map id := by
  cases instruction <;> simp [isControlInstruction] at hControl
  all_goals
    by_cases hhalt : state.terminal = .halted
    · simp [rustFiniteStepSpec, encodeInstruction, RustFiniteState.toLean,
        rustFinitePureStep, step, hhalt, hpc]
    · simp [rustFiniteStepSpec, encodeInstruction, RustFiniteState.toLean,
        rustFinitePureStep, step, branch, regRead, hhalt, hpc, nextPC,
        regWrite, RegisterFile.write]

theorem finite_control_interpreter_correspondence {size : Nat}
    (state : RustFiniteState size) (instruction : Instruction)
    (hControl : isControlInstruction instruction = true)
    (hpc : state.pc.toNat % 4 = 0) :
    (rustFiniteInterpreterStep state (encodeInstruction instruction)).map
        RustFiniteState.toLean =
      step state.toLean instruction := by
  cases instruction <;> simp [isControlInstruction] at hControl
  all_goals
    by_cases hhalt : state.terminal = .halted
    · simp [rustFiniteInterpreterStep, rustFinitePureStep,
        encodeInstruction, RustFiniteState.toLean, step, hhalt, hpc]
    · simp [rustFiniteInterpreterStep, rustFinitePureStep,
        encodeInstruction, RustFiniteState.toLean, step, branch, regRead,
        hhalt, hpc, nextPC, regWrite, RegisterFile.write]

theorem master_end_to_end_refinement {size : Nat}
    (state : RustFiniteState size) (instruction : Instruction)
    (hpc : state.pc.toNat % 4 = 0) :
    rustFiniteStepSpec state (encodeInstruction instruction) =
      step state.toLean instruction := by
  cases instruction <;>
    by_cases hhalt : state.terminal = .halted
  all_goals
    simp [rustFiniteStepSpec, encodeInstruction, RustFiniteState.toLean,
      rustFinitePureStep, step, branch, regRead, nextPC, regWrite,
      loadValue, RegisterFile.write,
      rustFiniteLoadValue_matches_lean, rustFiniteStore_matches_lean,
      rustFiniteStoreStep_matches_lean, hpc, hhalt]
  all_goals
    first
    | simpa [RustFiniteState.toLean] using
        (rustFiniteStoreStep_matches_lean state _ _ 1 1 _)
    | simpa [RustFiniteState.toLean] using
        (rustFiniteStoreStep_matches_lean state _ _ 2 2 _)
    | simpa [RustFiniteState.toLean] using
        (rustFiniteStoreStep_matches_lean state _ _ 4 4 _)

set_option maxRecDepth 16384 in
theorem decode_jal_example :
    rustDecode (Word32.ofNat 0x008000ef) =
      .ok (.jal ⟨1, by decide⟩ (Word32.ofNat 8)) := by
  have hword : (Word32.ofNat 0x008000ef).toNat = 0x008000ef := by decide
  simp [rustDecode, rustField, hword, Word32.signExtend, encodeInstruction,
    decode, bitField]

set_option maxRecDepth 16384 in
theorem decode_jalr_example :
    rustDecode (Word32.ofNat 0x000100e7) =
      .ok (.jalr ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by
  have hword : (Word32.ofNat 0x000100e7).toNat = 0x000100e7 := by decide
  simp [rustDecode, rustField, hword, Word32.signExtend, encodeInstruction,
    decode, bitField] <;> decide

set_option maxRecDepth 16384 in
theorem decode_beq_example :
    rustDecode (Word32.ofNat 0x00208063) =
      .ok (.beq ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by
  have hword : (Word32.ofNat 0x00208063).toNat = 0x00208063 := by decide
  simp [rustDecode, rustField, hword, Word32.signExtend, encodeInstruction,
    decode, bitField, bImmediateRaw] <;> decide

set_option maxRecDepth 16384 in
theorem decode_bne_example :
    rustDecode (Word32.ofNat 0x00209063) =
      .ok (.bne ⟨1, by decide⟩ ⟨2, by decide⟩ 0) := by
  have hword : (Word32.ofNat 0x00209063).toNat = 0x00209063 := by decide
  simp [rustDecode, rustField, hword, Word32.signExtend, encodeInstruction,
    decode, bitField, bImmediateRaw] <;> decide

theorem decode_fence_example :
    rustDecode (Word32.ofNat 0x0000000f) = .ok .fence := by rfl

theorem decode_ecall_example :
    rustDecode (Word32.ofNat 0x00000073) = .ok .ecall := by rfl

theorem decode_ebreak_example :
    rustDecode (Word32.ofNat 0x00100073) = .ok .ebreak := by rfl

end ZkRV32I.Refinement
