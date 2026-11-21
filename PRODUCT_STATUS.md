# Product Status

**Status: active development; work in progress.**

The repository passes its current verification gate in WSL, but it is not a
finished binary verifier or ZK system.

## Verified at 2026-11-21

- Lean build passed.
- No source `sorry` or `admit`.
- No project-defined axioms.
- Axiom audit checked 1,631 theorem declarations.
- 17 core Rust tests passed.
- 5 adversarial unit tests passed.
- 9 ELF mutation cases passed.
- 8 transcript mutation cases and 3 valid fault stops passed.
- RISC-V target Cargo check passed.
- `rust/src/lib.rs` retained `no_std` and `forbid(unsafe_code)`.

## Open

- Full ELF ABI coverage;
- arbitrary binary and control-flow verification;
- source extraction of Rust;
- compiler/linker/machine-code verification;
- RTL/hardware verification;
- production constraint and cryptographic proof system.
