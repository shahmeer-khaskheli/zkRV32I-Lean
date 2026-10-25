# zkRV32I-Lean

zkRV32I-Lean is a Lean 4 and Rust project for exploring formal models of the
RV32I base instruction set, a bounded Rust reference machine, Lean refinement
statements, and ELF32/RISC-V binary loading. It combines executable Rust
semantics with machine-checked Lean definitions and theorems.

The project is **not** a proof that the Rust compiler, linker, or a complete
compiled program implements the formal ISA model. In particular, the current
master refinement theorem relates two Lean definitions; it does not execute or
formally model the Rust source or machine code. The firmware ELF check validates
the current artifact's format, load segments, entry address, and first decoded
instruction, not its complete execution behavior.

## Purpose

The project is intended as a practical foundation for studying how an
instruction-set model, fixed-size Rust state, Lean proofs, and binary loading
can be brought into one workflow. Its explicit scope and limitations are part
of the result: a passing build establishes that the Lean declarations compile
and that Rust compiles for the selected target, but does not by itself establish
architectural correctness, compiler correctness, or cryptographic soundness.

## Repository architecture

### Lean base model

- [`formal/ZkRV32I/Base.lean`](formal/ZkRV32I/Base.lean) defines `Word32` using
  `UInt32`, a register-file abstraction, and a memory abstraction. Lean memory
  has a total byte function plus a base and size; checked operations reject
  invalid accesses.
- [`formal/ZkRV32I/ISA.lean`](formal/ZkRV32I/ISA.lean) defines instruction
  constructors and a decoder over 32-bit words. It includes the base integer
  operations, loads/stores, control flow, `FENCE`, `ECALL`, and `EBREAK`.
- [`formal/ZkRV32I/Machine.lean`](formal/ZkRV32I/Machine.lean) defines the
  machine state and one-step semantics. Memory/step faults are represented by
  `Option`; `FENCE` is a sequential no-op and system calls/breakpoints produce
  a halted state.
- [`formal/ZkRV32I/Trace.lean`](formal/ZkRV32I/Trace.lean) defines finite
  bounded state traces and the `valid_transition`/`valid_trace` predicates.

### Rust reference core

[`rust/src/lib.rs`](rust/src/lib.rs) is a `#![no_std]`,
`#![forbid(unsafe_code)]` library. It contains:

- 32-bit words and a fixed-size register file with x0 reads as zero and writes
  to x0 ignored;
- fixed-size byte-array memory with little-endian loads/stores, bounds,
  alignment, and address-overflow errors;
- an RV32I decoder and instruction `step` implementation using fixed-size
  state and no standard heap-allocation APIs.

Rust reports errors with `Result` and typed error variants, while Lean uses
`Option` for several faults. A structural similarity between these models is
not a proof that all error outcomes or all implementation details correspond.

### Lean refinement models

- [`formal/ZkRV32I/Refinement/Memory.lean`](formal/ZkRV32I/Refinement/Memory.lean)
  defines a finite-array-style Lean memory and proves relations between that
  model and Lean's total-function memory, including load/store lemmas.
- [`formal/ZkRV32I/Refinement/Step.lean`](formal/ZkRV32I/Refinement/Step.lean)
  defines a Lean finite-state execution model and the theorem
  `ZkRV32I.Refinement.master_end_to_end_refinement`.

The theorem equates the Lean finite-state step specification and the Lean
`step` definition for a matching encoded instruction, under its aligned-PC
precondition. Despite its name, this theorem does **not** directly compare
execution with `rust/src/lib.rs` or a compiled Rust artifact.

### ELF and binary path

[`formal/ZkRV32I/Binary.lean`](formal/ZkRV32I/Binary.lean) defines ELF32
little-endian header/program-header parsing for the supported RISC-V ELF
profile, validates segment file ranges and file-size/memory-size relations,
and provides a checked `PT_LOAD`-style segment loader into Lean memory. Its
segment-bound and geometry theorems establish properties of this Lean loader.

The same module defines aligned 32-bit instruction fetch, `BitVec 32` decoding
through the ISA decoder, and a binary-valid transition/trace predicate. The
proved implication from a binary-valid trace to `valid_trace` uses the
transition witness already included in the binary-valid predicate. It does not
prove that arbitrary ELF bytes execute correctly or that Rust-generated
instruction sequences refine the Rust source semantics.

[`rust/src/bin/firmware.rs`](rust/src/bin/firmware.rs) and
[`rust/firmware.ld`](rust/firmware.ld) produce a small no-std RISC-V firmware
image with `_start` set to `0x80000000`. The source defines a looping
`firmware_start` function and a `#[used]` reference to the Rust decoder; the
image is a linking/loading fixture, not a workload that runs the RV32I
reference interpreter. [`scripts/verify_elf.lean`](scripts/verify_elf.lean) parses the
built ELF, checks that the entry lies in an executable loadable segment, loads
segments into a bounded Lean memory, fetches the entry word, and checks that it
decodes to a supported instruction.

### Circuit model

[`formal/ZkRV32I/Circuit/Field.lean`](formal/ZkRV32I/Circuit/Field.lean) and
[`formal/ZkRV32I/Circuit/Constraints.lean`](formal/ZkRV32I/Circuit/Constraints.lean)
provide an illustrative constraint predicate using Boolean `F₂` operations.
The encoding stores a trace and an empty gate list; transition and memory
constraints reuse the semantic transition predicate. This is not a production
AIR/R1CS, STARK, SNARK, verifier, or cryptographic soundness result.

## Getting started

### Toolchains

The repository pins Lean in [`lean-toolchain`](lean-toolchain) and Rust in
[`rust-toolchain.toml`](rust-toolchain.toml). The Cargo configuration defaults
to `riscv32i-unknown-none-elf`; Rust target support is therefore needed for
default target builds. Lake/Elan, Cargo/Rustup, and Bash are needed for the
commands below. On Windows, Bash is available through Git Bash or another
compatible installation; ensure Elan's `lake` command is on Bash's `PATH` when
running the scripts.

### Build Lean and check the Rust library

From the repository root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml --target riscv32i-unknown-none-elf
```

The Rust check is a compile/type-check, not a test run.

### Build and inspect the firmware ELF

```sh
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

The build uses the target toolchain's `rust-lld` and the linker script
[`rust/firmware.ld`](rust/firmware.ld). The verifier checks the current image's
ELF header and program headers, executable entry placement, segment loading,
and fetch/decode at the entry point. It does not verify all instructions in the
image, run the firmware, or prove compiler/linker correctness.

The corresponding Make targets are:

```sh
make firmware
make verify-firmware
```

The latter runs the Lean build and then the ELF verification script.

### Source policy checks

The shell scripts can be invoked individually from the repository root:

```sh
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
bash scripts/check_no_unsafe.sh
bash scripts/check_alloc_policy.sh
bash scripts/check_isa_coverage.sh
```

The placeholder scripts scan Lean source for `sorry` and `admit`; the axiom
script scans for project axiom declarations and checks the listed master
theorem's axiom dependencies against its allowlist; the Rust scripts scan for
the required crate attributes, unsafe constructs, and common heap-allocation
APIs. These are source-policy checks, not proofs of semantic correctness. The
instruction coverage script checks for instruction-case text in selected Lean
and Rust files; it does not establish correctness or exhaustive decode
correspondence.

[`scripts/verify_all.sh`](scripts/verify_all.sh) combines these checks with
`lake build`, `cargo check`, and `cargo test`. Its test step depends on an
appropriate Rust test target and host linker being available. In particular,
the configured bare-metal target may not support the Rust test harness; choose
and validate a host-target test configuration separately rather than treating
`cargo check` as evidence that tests ran.

## Current verification boundary

The checked-in Lean theorems prove their stated propositions about Lean
definitions. Current `#print axioms` output for
`ZkRV32I.Refinement.master_end_to_end_refinement` lists Lean foundational
dependencies `propext` and `Quot.sound`; the source contains no project-defined
axioms, `sorry`, or `admit` according to the current scans. This is not the
same as saying the theorem is axiom-free in the strict foundational sense.

The ELF verification command is an executable check of a concrete built file,
but the Lean program reads bytes at runtime; the proof assistant has not
proved that the bytes were produced by a correct compiler/linker. No theorem
currently connects compiled Rust control flow to the Lean step relation for
every state, nor does the repository establish an end-to-end machine-code
execution theorem, production proof-system soundness, or cryptographic
security.

## Test and adversarial harness

[`adversarial/`](adversarial) contains a host-side finite-case harness and a
10-entry corpus. It invokes the Lean oracle and Rust `decode`/`step`, compares
the selected state fields for those cases, and exercises several hand-written
mutation checks. These are finite checks, not formal proofs. The harness uses
host utilities and allocating types; it is not part of the Rust `no_std`
execution library. `make differential` and `make mutation` currently both run
this same harness.

## Further technical detail

See [`TECHNICAL_WHITEPAPER.md`](TECHNICAL_WHITEPAPER.md) for the formal model,
the exact binary-loading boundary, theorem scope, trusted assumptions, and
remaining work.
