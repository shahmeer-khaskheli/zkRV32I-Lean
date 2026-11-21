# Verified Scope

The verified scope is the intersection of:

- Lean 4.19.0 kernel-checked proofs;
- the bounded ELF and transcript definitions;
- Rust host tests and adversarial transcript checks;
- `scripts/verify_all.sh`.

## Verified

- No source `sorry` or `admit`;
- no project-defined axioms;
- 1,631 axiom-audit theorem declarations;
- 40 RV32I instruction variants covered by the existing coverage policy;
- 17 core Rust tests;
- 5 adversarial unit tests;
- 9 ELF mutation cases;
- 8 transcript mutation cases;
- 3 valid fault-stop cases;
- RISC-V Cargo check;
- bounded ELF loading and disjoint segment-write proofs;
- transcript prefix and stop-reason proofs.

## Not verified

This release scope does not include arbitrary ELF processing, Rust source
extraction, compiler output equivalence, hardware execution, RTL, or
cryptographic proof-system behavior.
