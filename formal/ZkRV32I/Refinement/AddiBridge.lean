import ZkRV32I.Machine

namespace ZkRV32I.Refinement

open ZkRV32I

structure AddiBridgeSnapshot where
  pc : Word32
  terminal : TerminalState
  registers : List Word32
  memoryBase : Word32
  memoryBytes : List UInt8
  deriving DecidableEq, Repr

structure AddiBridgeOperands where
  rd : Nat
  rs1 : Nat
  immediate : Word32
  deriving DecidableEq, Repr

inductive AddiBridgeError where
  | halted
  | invalidRegisterIndex
  | misalignedInstructionAddress
  | other
  deriving DecidableEq, Repr

inductive AddiBridgeOutcome where
  | success (snapshot : AddiBridgeSnapshot)
  | error (error : AddiBridgeError)
  deriving DecidableEq, Repr

structure AddiBridgeRecord where
  instructionWord : Word32
  decoded : AddiBridgeOperands
  input : AddiBridgeSnapshot
  outcome : AddiBridgeOutcome
  deriving DecidableEq, Repr

structure AddBridgeOperands where
  rd : Nat
  rs1 : Nat
  rs2 : Nat
  deriving DecidableEq, Repr

structure AddBridgeRecord where
  instructionWord : Word32
  decoded : AddBridgeOperands
  input : AddiBridgeSnapshot
  outcome : AddiBridgeOutcome
  deriving DecidableEq, Repr

def AddiBridgeSnapshot.toMachineState (snapshot : AddiBridgeSnapshot) : MachineState :=
  { pc := snapshot.pc
    regs := ⟨fun index => (snapshot.registers[index.val]?).getD 0⟩
    memory := ⟨snapshot.memoryBase, snapshot.memoryBytes.length,
      fun index => (snapshot.memoryBytes[index]?).getD 0⟩
    terminal := snapshot.terminal }

def AddiBridgeSnapshot.ofMachineState (state : MachineState) : AddiBridgeSnapshot :=
  { pc := state.pc
    terminal := state.terminal
    registers := (List.range 32).map fun index =>
      state.regs.read ⟨index % 32, Nat.mod_lt _ (by decide)⟩
    memoryBase := state.memory.base
    memoryBytes := (List.range state.memory.size).map state.memory.bytes }

def AddiBridgeSnapshot.wellFormed (snapshot : AddiBridgeSnapshot) : Prop :=
  snapshot.registers.length = 32 ∧ snapshot.registers[0]? = some 0

def checkAddiBridgeRecord (record : AddiBridgeRecord) : Bool :=
  match decode record.instructionWord with
  | .ok (.addi rd rs1 immediate) =>
      if decide (
        record.decoded.rd = rd.val ∧
        record.decoded.rs1 = rs1.val ∧
        record.decoded.immediate = immediate ∧
        record.input.registers.length = 32 ∧
        record.input.registers[0]? = some 0 ∧
        record.input.terminal = .running ∧
        record.input.pc.toNat % 4 = 0) then
        match step record.input.toMachineState (.addi rd rs1 immediate) with
        | none => false
        | some next =>
            match record.outcome with
            | .error _ => false
            | .success output => decide (output = AddiBridgeSnapshot.ofMachineState next)
      else
        false
  | _ => false

theorem checkAddiBridgeRecord_sound (record : AddiBridgeRecord)
    (hcheck : checkAddiBridgeRecord record = true) :
    ∃ (rd rs1 : Fin 32) (immediate : Word32) (next : MachineState)
      (output : AddiBridgeSnapshot),
      decode record.instructionWord = .ok (.addi rd rs1 immediate) ∧
      record.decoded.rd = rd.val ∧
      record.decoded.rs1 = rs1.val ∧
      record.decoded.immediate = immediate ∧
      record.input.registers.length = 32 ∧
      record.input.registers[0]? = some 0 ∧
      record.input.terminal = .running ∧
      record.input.pc.toNat % 4 = 0 ∧
      step record.input.toMachineState (.addi rd rs1 immediate) = some next ∧
      pcAligned next ∧
      record.outcome = .success output ∧
      output = AddiBridgeSnapshot.ofMachineState next := by
  unfold checkAddiBridgeRecord at hcheck
  cases hdecode : decode record.instructionWord with
  | error error =>
      simp [hdecode] at hcheck
  | ok instruction =>
      cases instruction with
      | addi rd rs1 immediate =>
          by_cases hpre :
            record.decoded.rd = rd.val ∧
            record.decoded.rs1 = rs1.val ∧
            record.decoded.immediate = immediate ∧
            record.input.registers.length = 32 ∧
            record.input.registers[0]? = some 0 ∧
            record.input.terminal = .running ∧
            record.input.pc.toNat % 4 = 0
          · simp [hdecode, hpre] at hcheck
            rcases hpre with ⟨hrd, hrs1, himm, hregs, hx0, hterminal, hpc⟩
            cases hstep : step record.input.toMachineState (.addi rd rs1 immediate) with
            | none =>
                simp [hstep] at hcheck
            | some next =>
                cases houtcome : record.outcome with
                | error error =>
                    simp [hstep, houtcome] at hcheck
                | success output =>
                    simp [hstep, houtcome] at hcheck
                    have hnextAligned : pcAligned next :=
                      step_preserves_pcAligned _ _ _ (by simpa [pcAligned] using hpc) hstep
                    refine ⟨rd, rs1, immediate, next, output, rfl, hrd, hrs1, himm,
                      hregs, hx0, hterminal, hpc, hstep, hnextAligned, rfl, hcheck⟩
          · simp [hdecode, hpre] at hcheck
      | _ =>
          simp [hdecode] at hcheck

def checkAddBridgeRecord (record : AddBridgeRecord) : Bool :=
  match decode record.instructionWord with
  | .ok (.add rd rs1 rs2) =>
      if decide (
        record.decoded.rd = rd.val ∧
        record.decoded.rs1 = rs1.val ∧
        record.decoded.rs2 = rs2.val ∧
        record.input.registers.length = 32 ∧
        record.input.registers[0]? = some 0 ∧
        record.input.terminal = .running ∧
        record.input.pc.toNat % 4 = 0) then
        match step record.input.toMachineState (.add rd rs1 rs2) with
        | none => false
        | some next =>
            match record.outcome with
            | .error _ => false
            | .success output => decide (output = AddiBridgeSnapshot.ofMachineState next)
      else
        false
  | _ => false

theorem checkAddBridgeRecord_sound (record : AddBridgeRecord)
    (hcheck : checkAddBridgeRecord record = true) :
    ∃ (rd rs1 rs2 : Fin 32) (next : MachineState) (output : AddiBridgeSnapshot),
      decode record.instructionWord = .ok (.add rd rs1 rs2) ∧
      record.decoded.rd = rd.val ∧
      record.decoded.rs1 = rs1.val ∧
      record.decoded.rs2 = rs2.val ∧
      record.input.registers.length = 32 ∧
      record.input.registers[0]? = some 0 ∧
      record.input.terminal = .running ∧
      record.input.pc.toNat % 4 = 0 ∧
      step record.input.toMachineState (.add rd rs1 rs2) = some next ∧
      pcAligned next ∧
      record.outcome = .success output ∧
      output = AddiBridgeSnapshot.ofMachineState next := by
  unfold checkAddBridgeRecord at hcheck
  cases hdecode : decode record.instructionWord with
  | error error =>
      simp [hdecode] at hcheck
  | ok instruction =>
      cases instruction with
      | add rd rs1 rs2 =>
          by_cases hpre :
            record.decoded.rd = rd.val ∧
            record.decoded.rs1 = rs1.val ∧
            record.decoded.rs2 = rs2.val ∧
            record.input.registers.length = 32 ∧
            record.input.registers[0]? = some 0 ∧
            record.input.terminal = .running ∧
            record.input.pc.toNat % 4 = 0
          · simp [hdecode, hpre] at hcheck
            rcases hpre with ⟨hrd, hrs1, hrs2, hregs, hx0, hterminal, hpc⟩
            cases hstep : step record.input.toMachineState (.add rd rs1 rs2) with
            | none =>
                simp [hstep] at hcheck
            | some next =>
                cases houtcome : record.outcome with
                | error error =>
                    simp [hstep, houtcome] at hcheck
                | success output =>
                    simp [hstep, houtcome] at hcheck
                    have hnextAligned : pcAligned next :=
                      step_preserves_pcAligned _ _ _ (by simpa [pcAligned] using hpc) hstep
                    refine ⟨rd, rs1, rs2, next, output, rfl, hrd, hrs1, hrs2,
                      hregs, hx0, hterminal, hpc, hstep, hnextAligned, rfl, hcheck⟩
          · simp [hdecode, hpre] at hcheck
      | _ =>
          simp [hdecode] at hcheck

end ZkRV32I.Refinement
