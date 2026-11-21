# Technical Scope

## Summary

zkRV32I-Lean is an active work-in-progress formalization of bounded RV32I
execution, ELF loading, transcripts, and Lean-to-Lean finite refinement.

The formal checker builds a machine-checked trace from ELF bytes and an
execution transcript. It verifies the initial loaded snapshot and every
recorded PC, instruction word, decode result, `Machine.step` transition, and
output snapshot.

## What is proved

- Lean source contains no `sorry` or `admit`.
- No project-defined `axiom` declarations are found.
- Lean has bounded ELF segment loading and disjoint-write commutativity proofs.
- An accepted transcript produces a binary-valid and valid trace.
- An accepted halt proves the final terminal state is halted.
- Fault and fuel-limit stops separate verified-prefix evidence from halt
  completion.
- A finite modeled Rust state is related to the Lean state and step for every
  accepted transcript row.

## What is not proved

- A complete ELF ABI or external loader specification;
- compiler/linker correctness;
- Rust source extraction or compiled binary equivalence;
- universal RV32I conformance;
- arbitrary control-flow or memory programs;
- hardware, RTL, FPGA, or processor equivalence;
- production AIR/R1CS;
- cryptographic proof-system security or external verifier acceptance.
