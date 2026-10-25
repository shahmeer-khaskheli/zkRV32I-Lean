import ZkRV32I.Machine

namespace ZkRV32I

def MAX_TRACE : Nat := 2 ^ 20

abbrev Row := MachineState

structure Trace where
  length : Nat
  rows : Fin length → Row
  bounded : length ≤ MAX_TRACE

-- A trace is a bounded finite prefix; it need not end in a terminal state.
namespace Trace

def get (trace : Trace) (index : Nat) (h : index < trace.length) : Row :=
  trace.rows ⟨index, h⟩

def singleton (state : MachineState) : Trace where
  length := 1
  rows := fun _ => state
  bounded := by decide

end Trace

def initial (state : MachineState) : Prop :=
  ∃ pc memory, state = MachineState.initial pc memory

def terminal (state : MachineState) : Prop :=
  state.terminal = TerminalState.halted

def valid_transition (before after : MachineState) : Prop :=
  ∃ instruction, step before instruction = some after

def valid_trace (trace : Trace) : Prop :=
  ∃ hnonempty : 0 < trace.length,
    initial (trace.get 0 hnonempty) ∧
    ∀ (index : Nat) (hnext : index + 1 < trace.length),
      valid_transition
        (trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (trace.get (index + 1) hnext)

theorem valid_trace_length_bounds (trace : Trace) (h : valid_trace trace) :
    1 ≤ trace.length ∧ trace.length ≤ MAX_TRACE := by
  exact ⟨Nat.succ_le_of_lt h.1, trace.bounded⟩

theorem zero_length_trace_invalid (trace : Trace) (hzero : trace.length = 0) :
    ¬ valid_trace trace := by
  rintro ⟨hnonempty, _, _⟩
  omega

theorem singleton_valid_trace (state : MachineState) (h : initial state) :
    valid_trace (Trace.singleton state) := by
  refine ⟨by simp [Trace.singleton], ?_, ?_⟩
  · simpa [Trace.singleton, Trace.get] using h
  · intro index hindex
    simp [Trace.singleton] at hindex

theorem adjacent_rows_are_valid_transitions (trace : Trace) (index : Nat)
    (htrace : valid_trace trace) (hindex : index + 1 < trace.length) :
    valid_transition
      (trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hindex))
      (trace.get (index + 1) hindex) := by
  exact htrace.2.2 index hindex

theorem x0_zero_throughout_valid_trace (trace : Trace) (index : Nat)
    (_htrace : valid_trace trace) (hindex : index < trace.length) :
    (trace.get index hindex).regs.x0 = 0 := by
  rfl

end ZkRV32I
