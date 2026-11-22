# Trusted Computing Base

## A. Lean 4 formal trust

The formal trust base includes:

- Lean 4.19.0 and its kernel;
- the pinned Lake build;
- definitions and theorems under `formal/`;
- the standard Lean dependencies reported by the axiom policy; and
- Bash and Python policy scripts that report source and test status.

Within the current bounded ELF/transcript profile, Lean proves ELF geometry,
disjoint segment loading properties, transcript row acceptance, terminal stop
conditions, and finite-memory/step refinement relationships.

## B. Rust implementation trust

`rust/src/lib.rs` is a `#![no_std]` implementation with
`#![forbid(unsafe_code)]`. Rust tests exercise instruction behavior and memory
faults. The adversarial crate produces and mutates host transcripts.

This provides tested implementation evidence, not extraction or compiled
machine-code equivalence. Rust source, compiler optimization, linker behavior,
and target hardware remain outside the formal kernel trust argument.

## C. Transcript and runner limits

A transcript is accepted only after Lean independently checks ELF bytes,
initial state, every row, decode, `Machine.step`, snapshot, and stop reason.
Acceptance therefore establishes consistency with the Lean model.

It does not establish:

- that the Rust runner ran the ELF independently of the same model;
- that `fuel_limit` corresponds to a hardware fuel counter;
- that an external processor produced the emitted PC or snapshots;
- that the host compiler/linker emitted the intended machine instructions; or
- cryptographic, attested, or externally verifiable execution.

`fuel_limit` is transcript-provided evidence checked for internal consistency.
It is not external hardware attestation.
