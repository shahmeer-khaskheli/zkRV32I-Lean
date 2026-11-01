import ZkRV32I.Trace
import ZkRV32I.Circuit.Field
import ZkRV32I.Binary

namespace ZkRV32I.Circuit

open ZkRV32I

structure PublicInputs where
  entryPC : Word32
  finalPC : Word32
  traceLength : Nat

inductive AlgebraicGate where
  | add (left right output : FieldElem)
  | multiply (left right output : FieldElem)
  deriving DecidableEq, Repr

namespace AlgebraicGate

def satisfied : AlgebraicGate → Prop
  | .add left right output => fieldAdd left right = output
  | .multiply left right output => fieldMul left right = output

end AlgebraicGate

structure PrivateWitness where
  trace : Trace
  gates : List AlgebraicGate

/-- A constraint-system row containing every architectural value constrained
by one dynamic binary transition. -/
structure ConstraintRow where
  pc : Word32
  regs : RegisterFile
  memory : Memory
  instruction : Instruction
  instructionWord : BitVec 32
  terminal : TerminalState

def ConstraintRow.toMachineState (row : ConstraintRow) : MachineState :=
  { pc := row.pc
    regs := row.regs
    memory := row.memory
    terminal := row.terminal }

structure ConstraintTraceRows where
  rows : Array ConstraintRow
  bounded : rows.size ≤ MAX_TRACE

def ConstraintRow.fromMachineState
    (state : MachineState) (instruction : Instruction)
    (word : BitVec 32) : ConstraintRow :=
  { pc := state.pc
    regs := state.regs
    memory := state.memory
    instruction := instruction
    instructionWord := word
    terminal := state.terminal }

def ConstraintTransition
    (before after : ConstraintRow) : Prop :=
  ZkRV32I.Binary.fetch32 before.toMachineState.memory before.pc.toNat =
      some before.instructionWord ∧
  ZkRV32I.Binary.decodeBitVec32 before.instructionWord = .ok before.instruction ∧
  step before.toMachineState before.instruction = some after.toMachineState

theorem constraints_sound
    (before after : ConstraintRow)
    (hconstraints : ConstraintTransition before after) :
    ZkRV32I.Binary.binaryTransition before.toMachineState after.toMachineState := by
  obtain ⟨hfetch, hdecode, hstep⟩ := hconstraints
  exact ⟨⟨before.instructionWord, before.instruction, hfetch, hdecode, hstep⟩, trivial⟩

theorem binaryTransition_complete
    (beforeState afterState : MachineState)
    (htransition : ZkRV32I.Binary.binaryTransition beforeState afterState) :
    ∃ before after : ConstraintRow,
      before.toMachineState = beforeState ∧
      after.toMachineState = afterState ∧
      ConstraintTransition before after := by
  obtain ⟨witness, _⟩ := htransition
  let before : ConstraintRow :=
    ConstraintRow.fromMachineState beforeState witness.instruction witness.word
  let after : ConstraintRow :=
    ConstraintRow.fromMachineState afterState witness.instruction witness.word
  exact ⟨before, after, rfl, rfl,
    ⟨witness.hfetch, witness.hdecode, witness.hstep⟩⟩

def ConstraintTraceRows.satisfied (trace : ConstraintTraceRows) : Prop :=
  ∀ (index : Nat) (hnext : index + 1 < trace.rows.size),
    ConstraintTransition
      (trace.rows[index]'(Nat.lt_trans (Nat.lt_succ_self index) hnext))
      (trace.rows[index + 1]'hnext)

def ConstraintTraceRows.toTrace (trace : ConstraintTraceRows) : Trace where
  length := trace.rows.size
  rows := fun index => (trace.rows[index]'index.isLt).toMachineState
  bounded := trace.bounded

def ConstraintTraceRows.toBoundedCFGTrace
    (trace : ConstraintTraceRows) (hsatisfied : trace.satisfied) :
    ZkRV32I.Binary.BoundedCFGTrace where
  stateTrace := trace.toTrace
  transitions := by
    intro index hnext
    have hbefore : index < trace.rows.size :=
      Nat.lt_trans (Nat.lt_succ_self index) hnext
    exact constraints_sound
      (trace.rows[index]'hbefore)
      (trace.rows[index + 1]'hnext)
      (hsatisfied index hnext)

theorem constraint_trace_implies_cfg_trace
    (trace : ConstraintTraceRows)
    (hsatisfied : trace.satisfied) :
    ∃ cfg : ZkRV32I.Binary.BoundedCFGTrace,
      cfg.stateTrace = trace.toTrace := by
  exact ⟨trace.toBoundedCFGTrace hsatisfied, rfl⟩
def encode (trace : Trace) : PrivateWitness :=
  ⟨trace, []⟩

def publicInputsFor (trace : Trace) (hvalid : valid_trace trace) : PublicInputs :=
  let first := trace.get 0 hvalid.1
  let last := trace.get (trace.length - 1) (by have h := hvalid.1; omega)
  ⟨first.pc, last.pc, trace.length⟩

def boundaryConstraints (public : PublicInputs) (witness : PrivateWitness) : Prop :=
  ∃ hnonempty : 0 < witness.trace.length,
    public.traceLength = witness.trace.length ∧
    initial (witness.trace.get 0 hnonempty) ∧
    public.entryPC = (witness.trace.get 0 hnonempty).pc ∧
    public.finalPC =
      (witness.trace.get (witness.trace.length - 1) (by have h := hnonempty; omega)).pc

def transitionConstraints (_public : PublicInputs) (witness : PrivateWitness) : Prop :=
  ∀ (index : Nat) (hnext : index + 1 < witness.trace.length),
    valid_transition
      (witness.trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
      (witness.trace.get (index + 1) hnext)

-- Rows and field elements have bounded representations; this checks the trace bound.
-- It does not add bit-decomposition range checks for individual Word32 values.
def rangeCheckConstraints (_public : PublicInputs) (witness : PrivateWitness) : Prop :=
  witness.trace.length ≤ MAX_TRACE

def aluConstraints (_public : PublicInputs) (witness : PrivateWitness) : Prop :=
  ∀ gate, gate ∈ witness.gates → gate.satisfied

-- Control-flow and memory semantics are inherited from the ISA-linked transition
-- predicate, rather than duplicated as separate instruction-specific equations.
def branchConstraints (public : PublicInputs) (witness : PrivateWitness) : Prop :=
  transitionConstraints public witness

def memoryConstraints (public : PublicInputs) (witness : PrivateWitness) : Prop :=
  transitionConstraints public witness

def publicOutputConstraints (public : PublicInputs) (witness : PrivateWitness) : Prop :=
  boundaryConstraints public witness

def constraintsSatisfied (public : PublicInputs) (witness : PrivateWitness) : Prop :=
  boundaryConstraints public witness ∧
  transitionConstraints public witness ∧
  rangeCheckConstraints public witness ∧
  aluConstraints public witness ∧
  branchConstraints public witness ∧
  memoryConstraints public witness ∧
  publicOutputConstraints public witness

theorem completeness_valid_trace_encoding_satisfies_constraints (trace : Trace)
    (hvalid : valid_trace trace) :
    constraintsSatisfied (publicInputsFor trace hvalid) (encode trace) := by
  refine ⟨?_, ?_, trace.bounded, ?_, ?_, ?_, ?_⟩
  · refine ⟨hvalid.1, rfl, hvalid.2.1, rfl, rfl⟩
  · exact hvalid.2.2
  · intro gate hgate
    simp [encode] at hgate
  · exact hvalid.2.2
  · exact hvalid.2.2
  · exact ⟨hvalid.1, rfl, hvalid.2.1, rfl, rfl⟩

theorem soundness_transition_constraints_imply_isa_transitions
    (public : PublicInputs) (witness : PrivateWitness)
    (h : transitionConstraints public witness) :
    ∀ (index : Nat) (hnext : index + 1 < witness.trace.length),
      valid_transition
        (witness.trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (witness.trace.get (index + 1) hnext) :=
  h

end ZkRV32I.Circuit
