# Grant Readiness

## Verified technical evidence

The repository currently demonstrates:

- a passing Lean 4.19.0 build;
- zero `sorry`, zero `admit`, and zero project-defined Lean axioms;
- bounded ELF32 parsing/loading and multi-`PT_LOAD` disjoint-write proofs;
- transcript v2 fetch/decode/step/snapshot checking;
- halt, fault, and fuel-limit stop-reason separation;
- finite-memory and step refinement theorems;
- 17 host Rust unit tests and 5 adversarial unit tests;
- ELF and transcript mutation coverage; and
- a single `bash scripts/verify_all.sh` verification gate.

The gate passed with 1,631 theorem declarations audited and the tested
mutation harness counts recorded in `README.md`. These facts do not establish
independent security review, certification, production deployment, compiler
correctness, hardware equivalence, or a complete cryptographic system.

## Reviewer interpretation

Grant reviewers should treat the work as active formal-verification engineering
with a bounded binary/transcript scope. Source extraction, an independent
execution attestation, full RV32I conformance, production constraint systems,
and cryptographic prover/verifier verification remain open work.

## Funding and review questions

Eligibility, institutional participation, publication plans, budgets, and
independent review are administrative decisions outside this repository.
They should not be inferred from a passing build or test run.
