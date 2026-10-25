# Historical Verified Scope Snapshot

> **Historical snapshot.** This file predates the linked firmware ELF and the
> expanded `Binary.lean` loader. Its descriptions of Rust execution, ELF
> support, and policy scripts are not current. For the current verified scope,
> read [README.md](../README.md) and
> [TECHNICAL_WHITEPAPER.md](../TECHNICAL_WHITEPAPER.md).

## Machine-checked in the current Lean build

- Lean 4.19.0 builds the project using `lake build`.
- The theorem declarations and their precise statements are listed in
  [PROOF_MANIFEST.md](./PROOF_MANIFEST.md).
- The current trace predicates establish a nonempty bounded trace, initial
  first row, and adjacency via the existing `valid_transition` predicate.
- The current constraint predicates establish the stated boundary bindings,
  trace-length bound, Boolean gate satisfaction, and direct reuse of
  `valid_transition`.
- The audited theorem dependencies use only Lean standard axioms `propext` and
  `Quot.sound`; no project-defined axioms were found.

These theorems establish only their encoded Lean propositions. In particular,
the x0 accessor is defined as constant zero, so its preservation theorems do not
show that an independently represented stored x0 cell is preserved.

## Implemented, but not established by ISA-correctness theorems

- Lean defines decoding and step cases for the RV32I instruction constructors
  listed in `formal/ZkRV32I/ISA.lean` and `formal/ZkRV32I/Machine.lean`.
- The Lean model uses `UInt32` arithmetic and an abstract byte memory with
  bounds/alignment checks. Its faults are represented as `none`.
- Rust provides `Word32`, a fixed-size register file, and fixed-size memory
  operations. Rust `step` always returns `ExecutionError::UnsupportedInstruction`;
  no Rust instruction decoding or execution is implemented.
- The adversarial harness and ten-case corpus are present. Corpus classifications
  were checked against the Lean oracle. The Rust binary could not be run on the
  audit host, so no runtime Rust-vs-Lean differential result is established.

## Tested

- `lake build` succeeded.
- `cargo check` succeeded for both the core crate and adversarial crate.
- `cargo check --tests` succeeded for the adversarial crate.
- The Lean oracle classified all ten checked-in corpus cases as expected.
- The core Rust test binary and adversarial harness binary did not link because
  `link.exe` is not installed. Thus Rust tests and runtime mutation probes were
  not executed.
- The policy scripts returned exit code zero, but each script is currently only
  `#!/bin/sh` followed by `exit 0`; their pass status does not substantively
  establish policy compliance.

## Acceptance posture

There is no end-to-end theorem connecting decoded RV32I execution, concrete
machine traces, a production AIR/R1CS encoding, and verifier acceptance. No
cryptographic soundness or proof-system security property is established.
