# Verification Roadmap

## Completed

1. Lean RV32I state and step model.
2. Restricted ELF32 parser and loader.
3. Transcript v1 and stop-reason separation.
4. Transcript v2 with bounded multi-segment loading.
5. Disjoint-write commutativity proofs.
6. Transcript-step finite-memory/step refinement.
7. Mutation harness for ELF, snapshots, operands, and stop reasons.

## Next milestone

## Milestone 1: Full RV32I conformance and extended memory/ABI properties

1. Define an explicit RV32I conformance statement and instrument remaining
   instruction families.
2. Add alignment, bounds, arithmetic wraparound, control-flow, and terminal
   behavior tests for all supported encodings.
3. Extend ELF coverage beyond the bounded profile only behind explicit proofs
   for segment overlap, entry validity, permissions, and loader geometry.
4. Define and prove ABI/state properties that are required for firmware and
   executable entry points.
5. Preserve `#![no_std]` and `#![forbid(unsafe_code)]` in Rust throughout.

## Milestone 2: Rust and ELF binary equivalence

1. Add a mechanically checked bridge for Rust host parsing and execution, not
   a separate test-only specification.
2. Connect emitted ELF bytes, loaded memory, and instruction words to a
   Lean-checked binary trace.
3. Replace transcript-only runner evidence with a stronger independent
   execution witness or reproducible binary attestation.
4. State compiler/linker bounds explicitly or prove the required compilation
   and linkage properties.

## Milestone 3: Algebraic constraint soundness

1. Select a constraint framework compatible with zkLean/cLean or an
   equivalent defined target.
2. Implement concrete AIR/R1CS-style constraints for the bounded machine
   transition and trace shape.
3. Prove constraint soundness and valid-trace completeness against
   `Machine.step`, `Trace.valid_trace`, and `BinaryTrace`.
4. Add cryptographic prover/verifier integration only after the constraint
   proofs are complete and independently reviewable.

No milestone is complete until it has kernel-checked Lean proofs and a passing
`bash scripts/verify_all.sh` run.

No milestone should be described as complete until it has kernel-checked
proofs and a passing `bash scripts/verify_all.sh` run.
