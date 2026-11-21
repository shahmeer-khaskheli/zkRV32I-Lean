# Project Master Specification

## Purpose

The project is building a formally checked path from bounded ELF binaries
through Rust execution transcripts and Lean machine semantics.

## Current deliverables

- Lean RV32I machine, memory, trace, and ELF definitions;
- a bounded multi-segment `PT_LOAD` loader profile;
- transcript v2 parsing and checking;
- finite Rust memory/step refinement definitions;
- adversarial ELF and transcript mutation tests;
- a repository-wide verification gate.

## Current acceptance boundary

Lean acceptance is limited to the bounded ELF and transcript profile described
in [BINARY_VERIFICATION_SCOPE.md](BINARY_VERIFICATION_SCOPE.md). Rust execution
and transcript emission are tested but are not extracted or cryptographically
attested.

## Open requirements

Compiler/linker equivalence, full ELF support, broad RV32I execution,
source extraction, hardware equivalence, constraint construction, prover
integration, verifier soundness, and independent deployment evidence remain
open.
