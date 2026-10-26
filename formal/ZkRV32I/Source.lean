import ZkRV32I.Refinement.Step

namespace ZkRV32I.Refinement

open ZkRV32I

/--
The finite-state Rust source model uses fixed-size memory, matching the
execution core's `Memory<const N: usize>` representation.
-/
abbrev RustSourceState (size : Nat) := RustFiniteState size

/--
The modeled post-decode transition for the Rust execution core. This is a Lean
specification of the Rust transition behavior, not an execution or formal
translation of Rust source code.
-/
def rustSourceStep {size : Nat} (state : RustSourceState size)
    (instruction : Instruction) : Option MachineState :=
  rustFiniteStepSpec state (encodeInstruction instruction)

/--
For aligned PCs, the Lean Rust-source model and the Lean RV32I machine step
produce the same result for every abstract instruction.
-/
theorem rust_to_rv32i_refinement {size : Nat}
    (state : RustSourceState size) (instruction : Instruction)
    (hpc : state.pc.toNat % 4 = 0) :
    rustSourceStep state instruction = step state.toLean instruction := by
  exact master_end_to_end_refinement state instruction hpc

/--
A successful store in the finite Rust-memory model can only occur when its
entire requested range satisfies the model's bounds, alignment, and address
overflow checks.
-/
theorem rustSourceStore_success_validRange {size : Nat}
    (memory : RustMemory size) (address width alignment : Nat) (value : Word32)
    (next : RustMemory size)
    (hstore : memory.store address width alignment value = some next) :
    Memory.validRange memory.toLean address width alignment = true := by
  unfold RustMemory.store at hstore
  split at hstore
  · assumption
  · simp at hstore

end ZkRV32I.Refinement
