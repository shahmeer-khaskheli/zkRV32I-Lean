# zkRV32I-Lean

**A Lean 4 development for RV32I machine semantics, finite-memory
correspondence, ELF32 loading, and selected datapath refinement.**

This repository brings together a Lean model of RV32I instructions and machine
state, a fixed-size `no_std` Rust reference implementation, model-level
refinement theorems, a subset ELF32/RISC-V parser and loader, and a functional
Lean ALU datapath model. The intended contribution is an inspectable
verification workbench: each claim is tied to a definition, theorem, or
repeatable runtime check, and the boundaries between them are explicit.

It is **not** a verified Rust compiler, complete RISC-V processor model,
verified RTL implementation, production zero-knowledge virtual machine, or
end-to-end proof that a compiled ELF runs according to the source model.

## Research value and present status

The repository supports experimentation with the interfaces between:

1. word-level RV32I decoding and abstract machine transitions;
2. total Lean memory and a bounded finite-memory representation;
3. a Lean-transcribed Rust-shaped step model and the Lean ISA step;
4. ELF32 program-header parsing, segment loading, instruction fetch, and one
   modeled binary step; and
5. a functional ALU datapath model and the corresponding Lean instruction
   semantics.

The Lean development currently builds with Lean 4.19.0. The checked source
contains no `sorry`, `admit`, or project-defined `axiom` declarations according
to the repository scans. This is a source-policy result, not a claim of
axiom-free mathematics: for example, `#print axioms` reports
`[propext, Quot.sound]` for `master_end_to_end_refinement` and the newer
`rust_to_rv32i_refinement` and `singleCycleALUStep_refines_step` theorems.

The firmware runtime script parses and loads the current ELF fixture, fetches
and decodes the entry instruction, simulates one `binaryStep`, and checks
several isolated Lean-model edge cases. These are useful integration checks;
they do not constitute full-program execution, hardware simulation, or
compiler/linker verification.

## Model and implementation

### Lean ISA and machine semantics

- [`formal/ZkRV32I/Base.lean`](formal/ZkRV32I/Base.lean) defines `Word32`
  using `UInt32`, the register abstraction, and a bounded-by-predicate memory
  structure with a total byte function.
- [`formal/ZkRV32I/ISA.lean`](formal/ZkRV32I/ISA.lean) defines instruction
  constructors, bit-field/immediate operations, and decoding.
- [`formal/ZkRV32I/Machine.lean`](formal/ZkRV32I/Machine.lean) defines
  `MachineState`, partial `step`, and word-level arithmetic, branch, load,
  store, and terminal behavior. Loads/stores and misaligned branch targets can
  fail through `Option`; `ECALL`/`EBREAK` set the modeled terminal state.
- [`formal/ZkRV32I/Trace.lean`](formal/ZkRV32I/Trace.lean) defines bounded
  state sequences and predicates for initial states and valid adjacent
  transitions. A valid trace is a predicate over Lean states; it does not by
  itself record machine-code fetch witnesses.

The source includes 40 instruction constructors checked by the coverage
script. The coverage scan is textual and is not a proof of complete RISC-V
specification conformance or exhaustive decoder equivalence.

### Refinement models

- [`formal/ZkRV32I/Refinement/Memory.lean`](formal/ZkRV32I/Refinement/Memory.lean)
  defines `RustMemory size` as Lean finite memory and proves conversion,
  load, and store relations with Lean's total-function memory.
- [`formal/ZkRV32I/Refinement/Step.lean`](formal/ZkRV32I/Refinement/Step.lean)
  defines `RustFiniteState`, a Rust-shaped instruction/state model in Lean, and
  `master_end_to_end_refinement`.
- [`formal/ZkRV32I/Source.lean`](formal/ZkRV32I/Source.lean) exposes a
  source-shaped view as `rustSourceStep`, proves
  `rust_to_rv32i_refinement`, and proves a successful finite-model store
  satisfies `Memory.validRange`.

In simplified form, the step result is:

```text
rustSourceStep state instruction = step state.toLean instruction
```

under the theorem's aligned-PC precondition. Both sides are Lean definitions.
The source model is a transcription; it is not mechanically derived from
[`rust/src/lib.rs`](rust/src/lib.rs), and the theorem does not execute Rust
code.

### ELF32 loader and runtime check

[`formal/ZkRV32I/Binary.lean`](formal/ZkRV32I/Binary.lean) contains a
project-specific subset parser for ELF32 little-endian RISC-V executables. It
checks selected identification and header fields, program-header table
bounds, segment file bounds, and `p_filesz ≤ p_memsz`. The loader bounds
segments to the configured Lean memory and 32-bit address range; it copies
file bytes and zero-fills the remaining segment memory.

The same module defines aligned four-byte `fetch32`, converts the fetched word
to `BitVec 32`, decodes through the ISA decoder, and composes a binary step
from fetch, decode, and `step`. The parser is not a complete ELF ABI
validator: it does not establish every alignment, overlap, permission,
relocation, or platform rule.

The current firmware is a link/load fixture at `0x80000000`. The
[`scripts/verify_elf.lean`](scripts/verify_elf.lean) script:

1. reads and parses a particular ELF at runtime;
2. checks its executable entry placement and loads its segments into bounded
   Lean memory;
3. fetches and decodes the entry instruction;
4. requires one successful modeled `binaryStep`; and
5. checks selected Lean-model cases for ADDI wraparound, unaligned and
   overflowing memory-range rejection, ECALL halt behavior, and the
   `MAX_TRACE` bound.

This is a one-step smoke test plus separate model checks. It does not run a
complete firmware trace or test equivalent Rust error paths.

### Functional datapath model

[`formal/ZkRV32I/Hardware/SingleCycle.lean`](formal/ZkRV32I/Hardware/SingleCycle.lean)
defines ALU controls, input selection, result computation, and register
writeback for the 19 ALU instruction constructors. Its
`singleCycleALUStep_refines_step` theorem proves that this Lean function agrees
with Lean `step` under its input-availability and PC-alignment conditions.
This is a functional model, not imported RTL, a full processor
microarchitecture, or a physical-hardware refinement proof.

### Rust and circuit code

[`rust/src/lib.rs`](rust/src/lib.rs) is a fixed-size Rust reference library
with `#![no_std]` and `#![forbid(unsafe_code)]`. It implements words,
registers, memory, decode, and `step`. Source scans check crate attributes,
unsafe syntax, and common allocation APIs; these scans do not prove properties
of all dependencies or generated machine code.

The modules under [`formal/ZkRV32I/Circuit/`](formal/ZkRV32I/Circuit/) provide
illustrative predicates. The encoding currently has an empty gate list and
does not implement a production AIR/R1CS, proof system, verifier, or
cryptographic soundness theorem.

## Claims and open obligations

| Area | Established in the repository | Not established |
|---|---|---|
| Lean source policy | Current scans find no `sorry`, `admit`, or project `axiom` declarations. | A proof of correctness of Lean itself or a foundationally axiom-free development. |
| ISA and machine | Lean definitions and kernel-checked theorems about those definitions. | Complete conformance to every RISC-V rule and all reserved encodings. |
| Finite memory | Theorems relating two Lean memory models, including checked store/load results. | Universal Rust source-to-model correspondence. |
| Step refinement | Theorem comparing a Rust-shaped Lean transition specification with Lean `step`. | A theorem about execution of `rust/src/lib.rs` or compiler output. |
| ELF loader | Runtime checks and Lean bounds/geometry theorems for the defined loader. | Full ELF ABI validation or proof that external loaders behave identically. |
| Firmware | A RISC-V ELF fixture; current script checks one fetched, decoded, modeled step. | Complete binary trace refinement or compiled-program correctness. |
| Datapath | Functional Lean ALU subset with theorem to Lean `step`. | RTL/gate-level equivalence, timing behavior, or physical silicon claims. |
| Rust safety | `no_std`/`forbid(unsafe_code)` attributes and source policy scans. | Whole-program memory-safety proof, exhaustive runtime validation, or dependency audit. |
| ZK constraints | Lean illustrative definitions. | Production circuit, soundness, zero knowledge, or cryptographic security. |

## Reproducing checks

Pinned toolchains are specified by [`lean-toolchain`](lean-toolchain) and
[`rust-toolchain.toml`](rust-toolchain.toml). From the repository root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml \
  --target riscv32i-unknown-none-elf
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

The equivalent convenience target is `make verify-firmware`. Rust unit tests
require a host target and linker with test-harness support; a bare-metal
`cargo check` is not a test run. Bash policy scripts require Bash and
`lake` on that shell's `PATH`.

## Research roadmap

1. **Specification and parser assurance:** state the accepted ISA and ELF
   profiles precisely; prove parser soundness/completeness relative to those
   profiles and specify overlapping-segment policy.
2. **Trace-level binary semantics:** connect concrete fetched words and
   repeated binary transitions to trace rows, with explicit terminal/fault
   handling and checked program termination bounds.
3. **Source translation validation:** choose a specified Rust subset or
   compiler IR; define its semantics and prove a validator relates each
   emitted instruction sequence to that semantics. The compiler and validator
   trust base must be explicit.
4. **RTL refinement:** select a concrete open RTL core and interface, formalize
   clock/reset and memory protocols, and prove cycle-level refinement to the
   abstract ISA semantics.
5. **Constraint-system soundness:** replace illustrative predicates with an
   explicit encoding, prove completeness/soundness for the intended trace
   relation, and separately analyze the cryptographic proof system.
6. **Testing and reproducibility:** run host tests with a supported toolchain,
   strengthen property-based/differential testing, and preserve artifact
   provenance in CI.

These are proposed research directions, not completed milestones or grant
readiness certifications.

## Further reading

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the repository inventory and
component data flow, and [`TECHNICAL_WHITEPAPER.md`](TECHNICAL_WHITEPAPER.md)
for theorem scope, formal notation, a verification claims matrix, and the
trust boundary.
