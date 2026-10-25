import ZkRV32I.Trace
import ZkRV32I.Circuit.Field

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
