# Research Contributions and Evidence

## Evidence-backed additions

- A bounded transcript checker that independently verifies ELF loading and
  transcript snapshots against Lean definitions;
- pairwise-disjoint `PT_LOAD` loading proofs and segment-write commutativity;
- halt, fault, fuel-limit, and verified-prefix separation;
- a finite memory/step refinement view for every verified transcript row;
- adversarial ELF, snapshot, operand, and stop-reason mutation coverage.

## Verification evidence

The most recent `bash scripts/verify_all.sh` run passed with:

- 1,631 theorem declarations in the axiom audit;
- zero project-defined axioms;
- 17 core Rust tests;
- 5 adversarial unit tests;
- 9 ELF mutation cases;
- 8 transcript mutation cases;
- 3 valid fault-stop cases.

## Scope and open boundaries

These contributions do not prove Rust source extraction, compiler output
equivalence, linker correctness, arbitrary ELF loading, hardware execution,
complete RV32I conformance, or cryptographic proof-system correctness.
