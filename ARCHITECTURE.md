# zkRV32I-Lean Architecture

## 1. Purpose and scope

This document describes the repository as it exists now: a Lean 4 model of
RV32I instruction decoding and execution, a Rust `no_std` reference
implementation, a Lean finite-memory and step-refinement development, a
runtime ELF32 parser/loader/fetch path, a linked RISC-V firmware fixture, and
supporting checks and documentation.

The architecture is layered to make the intended relationships visible, but
not all layers are connected by end-to-end proofs. In particular:

- `master_end_to_end_refinement` equates a Lean finite-state specification
  with the Lean machine `step`; it does not call Rust or reason about compiled
  Rust instructions.
- the firmware verification script parses an external ELF file at runtime,
  loads it into Lean memory, fetches its entry word, and checks that the word
  decodes. It does not prove compiler/linker correctness or the complete
  execution of the firmware.
- the circuit modules define illustrative predicates and are not a production
  AIR, R1CS, STARK, SNARK, or verifier.

Consequently, the repository is a formal-modeling and binary-loading
foundation, not a completed, unconditional machine-code verification system.

## 2. Repository structure

The tree below lists maintained project inputs and the concrete firmware
artifact currently generated in the workspace. Build caches and intermediate
compiler products are summarized separately in §2.2 because their filenames
are toolchain-generated and can change between builds.

```text
zk-verifier-core/
├── .cargo/
│   └── config.toml
├── .github/
│   └── workflows/
│       └── ci.yml
├── adversarial/
│   ├── Cargo.lock
│   ├── Cargo.toml
│   ├── LeanOracle.lean
│   ├── corpus.txt
│   └── src/
│       └── main.rs
├── circuit/                         [empty directory]
├── formal/
│   ├── ZkRV32I.lean
│   └── ZkRV32I/
│       ├── Base.lean
│       ├── Binary.lean
│       ├── ISA.lean
│       ├── Machine.lean
│       ├── Trace.lean
│       ├── Circuit/
│       │   ├── Constraints.lean
│       │   └── Field.lean
│       └── Refinement/
│           ├── Memory.lean
│           └── Step.lean
├── release/
│   ├── BUILD_PROVENANCE.md           [historical snapshot]
│   ├── KNOWN_LIMITATIONS.md          [historical snapshot]
│   ├── PROOF_MANIFEST.md             [historical snapshot]
│   └── VERIFIED_SCOPE.md             [historical snapshot]
├── rust/
│   ├── Cargo.toml
│   ├── firmware.ld
│   └── src/
│       ├── lib.rs
│       └── bin/
│           └── firmware.rs
├── scripts/
│   ├── check_alloc_policy.sh
│   ├── check_axiom_policy.sh
│   ├── check_isa_coverage.sh
│   ├── check_no_admit.sh
│   ├── check_no_sorry.sh
│   ├── check_no_unsafe.sh
│   ├── verify_all.sh
│   └── verify_elf.lean
├── target/                          [generated Rust outputs]
│   └── riscv32i-unknown-none-elf/
│       └── release/
│           └── firmware            [linked ELF32 ET_EXEC]
├── .lake/                           [generated Lean outputs]
├── _probe_riscv.rs                   [leftover standalone probe; not a target]
├── Cargo.lock
├── Cargo.toml
├── lake-manifest.json
├── lakefile.toml
├── lean-toolchain
├── Makefile
├── README.md
├── TECHNICAL_WHITEPAPER.md
└── rust-toolchain.toml
```

### 2.1 File and directory responsibilities

#### Root configuration and documentation

| Path | Responsibility |
|---|---|
| [`Cargo.toml`](Cargo.toml) | Root Cargo workspace manifest; includes the `rust` crate. |
| [`Cargo.lock`](Cargo.lock) | Cargo's root workspace dependency lockfile. |
| [`lakefile.toml`](lakefile.toml) | Lake package definition; selects the `formal` source directory and `ZkRV32I` library target. |
| [`lake-manifest.json`](lake-manifest.json) | Generated/resolved Lake dependency manifest. |
| [`lean-toolchain`](lean-toolchain) | Pins Lean to `leanprover/lean4:v4.19.0`. |
| [`rust-toolchain.toml`](rust-toolchain.toml) | Pins Rust to 1.97.1 with the minimal profile. |
| [`Makefile`](Makefile) | Convenience targets for Lean, Rust, firmware build/verification, tests, differential/mutation harness, and aggregate checks. |
| [`README.md`](README.md) | User-facing overview, commands, architecture summary, and scope caveats. |
| [`TECHNICAL_WHITEPAPER.md`](TECHNICAL_WHITEPAPER.md) | Extended technical and verification-scope discussion. |
| [`_probe_riscv.rs`](_probe_riscv.rs) | Standalone RISC-V probe source left in the workspace. It is not included as a Cargo target or used by the firmware build. |
| [`circuit/`](circuit) | Empty directory; no independent circuit implementation is present here. Lean circuit predicates live under `formal/ZkRV32I/Circuit/`. |

#### Rust target configuration and continuous integration

| Path | Responsibility |
|---|---|
| [`.cargo/config.toml`](.cargo/config.toml) | Sets the default target to `riscv32i-unknown-none-elf`; applies `panic=abort` and the firmware linker script arguments for that target. |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | GitHub Actions workflow for Lean setup/build, source checks, Rust checks, and tests. Its test command uses the workspace's configured Rust target, so test-harness compatibility must be considered when running the workflow. |

#### Lean entry point and mathematical foundations

| Path | Responsibility |
|---|---|
| [`formal/ZkRV32I.lean`](formal/ZkRV32I.lean) | Root Lean module; imports the circuit, refinement, and binary modules and re-exports selected definitions and theorems. |
| [`formal/ZkRV32I/Base.lean`](formal/ZkRV32I/Base.lean) | Defines `Word32`, signed/unsigned helpers, register-file abstraction, total-function memory, validity checks, and little-endian loads/stores. |
| [`formal/ZkRV32I/ISA.lean`](formal/ZkRV32I/ISA.lean) | Defines the instruction algebraic data type, decode errors, bit-field/immediate helpers, decoder, and B-immediate lemmas/examples. |
| [`formal/ZkRV32I/Machine.lean`](formal/ZkRV32I/Machine.lean) | Defines machine/terminal states, `step`, helper operations, partial faults, and the executable `execute` composition. |
| [`formal/ZkRV32I/Trace.lean`](formal/ZkRV32I/Trace.lean) | Defines `MAX_TRACE`, finite state traces, initial/terminal predicates, valid transitions/traces, and trace lemmas. |

#### Lean refinement, binary, and circuit modules

| Path | Responsibility |
|---|---|
| [`formal/ZkRV32I/Refinement/Memory.lean`](formal/ZkRV32I/Refinement/Memory.lean) | Defines `RustMemory size`, its relation to Lean total memory, checked-offset behavior, memory load/store models, and memory correspondence lemmas. `RustMemory` is a Lean model, not imported Rust code. |
| [`formal/ZkRV32I/Refinement/Step.lean`](formal/ZkRV32I/Refinement/Step.lean) | Defines a Rust-shaped instruction/state model in Lean, finite-step specifications, instruction-family lemmas, and `master_end_to_end_refinement`. The theorem compares Lean definitions. |
| [`formal/ZkRV32I/Binary.lean`](formal/ZkRV32I/Binary.lean) | Reads ELF32 little-endian fields, validates selected ELF/RISC-V metadata and segment bounds, loads `PT_LOAD` segments, fetches aligned words, decodes `BitVec 32`, and defines binary-valid transitions/traces with safety/projection theorems. |
| [`formal/ZkRV32I/Circuit/Field.lean`](formal/ZkRV32I/Circuit/Field.lean) | Provides Boolean operations intended to model the field F₂ and selected algebraic law proofs. |
| [`formal/ZkRV32I/Circuit/Constraints.lean`](formal/ZkRV32I/Circuit/Constraints.lean) | Defines public inputs, witness/gates, trace/transition predicates, and completeness/transition-predicate results. The encoding uses an empty gate list; this is not a production constraint system. |

#### Rust execution and firmware

| Path | Responsibility |
|---|---|
| [`rust/Cargo.toml`](rust/Cargo.toml) | Defines the Rust library package and a `firmware` binary target with tests/benches disabled for that binary. |
| [`rust/src/lib.rs`](rust/src/lib.rs) | `#![no_std]`, `#![forbid(unsafe_code)]` RV32I reference library: word operations, fixed-size registers and memory, decoder, execution/error types, `step`, and Rust unit tests. The source uses fixed-size arrays for execution state. |
| [`rust/src/bin/firmware.rs`](rust/src/bin/firmware.rs) | Bare-metal binary source with `no_std`, `no_main`, and `forbid(unsafe_code)`. Provides a nonreturning start function, panic handler, and a `#[used]` reference to the Rust decoder. |
| [`rust/firmware.ld`](rust/firmware.ld) | RISC-V linker script setting `_start`, placing the image at `0x80000000`, collecting text/data/bss, and discarding unwind sections. |

#### Adversarial and policy tooling

| Path | Responsibility |
|---|---|
| [`adversarial/Cargo.toml`](adversarial/Cargo.toml) | Host-side harness package depending on the Rust core crate. |
| [`adversarial/Cargo.lock`](adversarial/Cargo.lock) | Lockfile for the adversarial package. |
| [`adversarial/corpus.txt`](adversarial/corpus.txt) | Ten finite decoder/step examples and expected Lean outcome classes. |
| [`adversarial/LeanOracle.lean`](adversarial/LeanOracle.lean) | Command-line Lean oracle that decodes and executes one supplied instruction word and serializes selected state. |
| [`adversarial/src/main.rs`](adversarial/src/main.rs) | Host-side finite differential harness comparing Lean oracle output with Rust `decode`/`step`; also runs simple mutation-class checks. This is not a formal proof and uses allocation on the host harness path. |
| [`scripts/check_no_sorry.sh`](scripts/check_no_sorry.sh) | Greps project Lean source (excluding `.lake`) for the `sorry` token. |
| [`scripts/check_no_admit.sh`](scripts/check_no_admit.sh) | Greps project Lean source for the `admit` token. |
| [`scripts/check_axiom_policy.sh`](scripts/check_axiom_policy.sh) | Scans Lean source for project axiom declarations and prints/checks the master refinement theorem's axiom dependencies against an allowlist. Requires `lake` available in its shell environment. |
| [`scripts/check_no_unsafe.sh`](scripts/check_no_unsafe.sh) | Checks for required crate-level Rust attributes and scans the Rust source tree for common unsafe syntax patterns. This is a source scan, not a whole-program proof. |
| [`scripts/check_alloc_policy.sh`](scripts/check_alloc_policy.sh) | Scans Rust source for common standard heap-allocation APIs. It is a heuristic source check. |
| [`scripts/check_isa_coverage.sh`](scripts/check_isa_coverage.sh) | Checks for instruction-case text in selected Lean and Rust source files. It does not validate semantics. |
| [`scripts/verify_all.sh`](scripts/verify_all.sh) | Runs policy scripts, `lake build`, `cargo check`, and `cargo test`. The configured bare-metal target may not support the normal test harness. |
| [`scripts/verify_elf.lean`](scripts/verify_elf.lean) | Runtime Lean program that reads an ELF, checks executable entry placement, loads segments into bounded Lean memory, fetches the entry word, and requires successful decode. |

#### Release snapshots

| Path | Responsibility |
|---|---|
| [`release/BUILD_PROVENANCE.md`](release/BUILD_PROVENANCE.md) | Historical environment/build snapshot; predates the current linked firmware workflow. |
| [`release/KNOWN_LIMITATIONS.md`](release/KNOWN_LIMITATIONS.md) | Historical limitations snapshot; some statements predate current Rust and ELF work. |
| [`release/PROOF_MANIFEST.md`](release/PROOF_MANIFEST.md) | Historical proof manifest; does not enumerate all later binary-loader declarations. |
| [`release/VERIFIED_SCOPE.md`](release/VERIFIED_SCOPE.md) | Historical scope snapshot; points readers to the current overview documents. |

### 2.2 Generated workspace directories

These paths are outputs/caches rather than maintained source modules:

- `.lake/` contains Lake-built Lean artifacts such as `.olean`, `.ilean`,
  `.trace`, and generated C intermediate files under `build/`.
- `target/` contains Cargo outputs for the host and
  `riscv32i-unknown-none-elf` profiles, including dependencies and intermediate
  objects. The concrete linked firmware output is
  `target/riscv32i-unknown-none-elf/release/firmware`.
- `adversarial/target/` contains the adversarial crate's Cargo build cache.
- `.lake/`, both `target/` trees, and their exact hashed filenames are
  toolchain-generated and will vary or disappear on clean builds. They are not
  enumerated file by file in the maintained source tree.

## 3. Layered architectural blueprint

### Layer 1 — Mathematical foundations and ISA semantics

The semantic core is organized from low-level values upward:

1. **Values and storage:** `Base.lean` defines 32-bit values, x0-aware register
   accessors, byte memory, bounds/alignment predicates, and little-endian
   primitives.
2. **Instruction syntax and decoding:** `ISA.lean` provides the instruction
   constructors and maps words to constructors or decode errors.
3. **Single-step behavior:** `Machine.lean` consumes a state and an abstract
   instruction, updates registers/PC/memory, and returns `none` for its modeled
   fault cases.
4. **Trace composition:** `Trace.lean` bounds finite state sequences and
   describes initial rows and adjacent valid transitions.

The instruction set data type and step pattern cover the base RV32I instruction
families represented in the source. Source presence and compilation alone do
not prove conformance to every clause of the RISC-V specification.

### Layer 2 — Binary parsing and formal loader

`Binary.lean` adds an ELF32/RISC-V ingestion path on top of the Lean memory
model:

1. `readU16LE`/`readU32LE` read bounded little-endian values from byte arrays.
2. `parseELF32Header` checks the ELF identification bytes, ELF32/little-endian
   format, `ET_EXEC`, RISC-V machine ID, header size, and program-header table
   range.
3. `parseELF32ProgramHeader` reads segment type, file offset, virtual address,
   file size, memory size, flags, and alignment, checking the file range and
   `p_filesz ≤ p_memsz`.
4. `parseELF32` constructs an image from the parsed header and program-header
   table.
5. `segmentFits` checks file and formal-memory containment and 32-bit address
   range. `loadSegment` copies file bytes, zero-fills the memory tail, and
   preserves bytes outside the mapped range. `loadELF32Segments` processes
   loadable segments.
6. `fetch32` reads a word-aligned four-byte word from Lean memory and forms a
   `BitVec 32` in little-endian order. `decodeBitVec32` delegates to the
   existing Lean ISA decoder.

The implementation validates a useful subset of ELF requirements. It should
not be treated as a full ELF ABI verifier: all relocation, alignment
congruence, segment overlap, permission, and architecture-specific rules have
not been established as a complete policy.

### Layer 3 — Formal verification and refinement

The formal results occupy distinct scopes:

- `Refinement/Memory.lean` proves properties between two Lean memory
  representations, including bounded finite bytes versus a total byte
  function.
- `Refinement/Step.lean` defines a Rust-shaped finite-state model in Lean and
  proves `master_end_to_end_refinement` between that model and Lean `step` for
  matching abstract instructions and the theorem's preconditions.
- `Binary.lean` proves segment-fit bounds, loader geometry preservation,
  and projection from binary-valid transitions/traces to the existing
  abstract valid-transition/trace predicates.
- `Trace.lean` supplies bounded trace structure and basic trace lemmas.

The phrase “binary-valid trace” refers to a Lean predicate that assumes a
successful fetch, decode, and Lean step at each transition. The trace
projection theorem is consequently a theorem about those predicates, not an
independent simulation theorem for a concrete processor or Rust executable.

The repository's scans report zero `sorry`, zero `admit`, and no project
axiom declarations in formal source. A direct theorem axiom audit reports
Lean foundational dependencies, including `propext` and `Quot.sound` for the
master refinement theorem. These are not project-defined axioms, but they are
axiom dependencies and should be disclosed.

### Layer 4 — Systems implementation

The Rust library is compiled for `riscv32i-unknown-none-elf`. Its execution
crate uses `#![no_std]` and `#![forbid(unsafe_code)]`, fixed-size register and
memory arrays, explicit wrapping/checking arithmetic, a decoder, and a step
function with typed faults. Unit tests are in the Rust library source. The
adversarial harness is a separate host crate and does use heap-backed
collections; it is not on the Rust execution path.

The firmware binary target is separate from the reference-step library
behavior. It supplies a bare-metal entry fixture and a `#[used]` reference to
the Rust decoder. The linker script makes `_start` the entry at `0x80000000`.
The generated workspace artifact has been observed as an ELF32 little-endian
RISC-V `ET_EXEC` with executable `PT_LOAD` headers. This artifact is a small
linking/loading fixture, not a test program that runs every Rust `step` case.

## 4. Component interaction and data flow

The concrete artifact validation path is:

```text
rust/src/bin/firmware.rs + rust/src/lib.rs
                  │
                  ▼
       rustc for riscv32i-unknown-none-elf
                  │
                  ▼
             rust-lld + firmware.ld
                  │
                  ▼
  target/riscv32i-unknown-none-elf/release/firmware
                  │
                  ▼
 scripts/verify_elf.lean reads bytes at runtime
                  │
                  ▼
 parseELF32Header → parseELF32ProgramHeader → parseELF32
                  │
                  ▼
 ELF32Image.loadMemory → loadELF32Segments → loadSegment
                  │
                  ▼
 check entry executable PT_LOAD range and memory bounds
                  │
                  ▼
 fetch32 (little-endian bytes → BitVec 32)
                  │
                  ▼
 decodeBitVec32 → ISA.decode → supported instruction constructor
```

Detailed execution of this verifier:

1. Cargo invokes `rustc` for the bare-metal target. The target linker selected
   by the Rust toolchain is `rust-lld`; `.cargo/config.toml` passes the
   `rust/firmware.ld` script.
2. The linker emits an ELF executable whose program headers describe file
   ranges and virtual-memory ranges. The ELF itself is an external runtime
   input to Lean.
3. `verify_elf.lean` reads the bytes with Lean IO and calls `parseELF32`.
   Malformed or unsupported headers produce an explicit error rather than a
   success-shaped fallback.
4. The verifier checks that `ET_EXEC` is selected, that the parsed program
   header count matches the header, and that the entry lies inside a loadable
   executable segment.
5. It creates a finite-range Lean memory starting at `0x80000000`, and
   `loadMemory` applies segment loading with file bounds, virtual address
   bounds, memory-size checks, and zero-fill for any segment's BSS tail.
6. It verifies the entry's aligned four-byte range, fetches the word from
   loaded memory, and asks the ISA decoder to accept it.
7. The runtime verifier prints success if the fetched entry word decodes.
   This does not run repeated `binaryStep` calls over the artifact or prove
   all reachable machine states.

There is a separate model-level proof path:

```text
RustMemory (Lean finite model) ──Refines──► Lean Memory
RustFiniteState (Lean model) ──toLean─────► Lean MachineState
         │                                      │
         └── rustFiniteStepSpec ────────────────┘
                           │
                           ▼
             master_end_to_end_refinement
```

Despite its Rust-oriented names, the left side of this diagram is Lean code.
The theorem does not consume the ELF bytes or call the compiled Rust program.

The optional adversarial workflow is another distinct path: `adversarial/src/main.rs`
parses a finite corpus, invokes the Lean command-line oracle and Rust library,
and compares selected results. This is finite test evidence only. It is not
used by the ELF verifier and cannot establish universal equivalence.

## 5. Trust boundary and assumptions

### 5.1 Machine checked by Lean

Subject to the Lean kernel and the theorem's definitions, the current build
checks:

- the types and equations for the Lean word/register/memory/ISA/machine models;
- declared theorem proofs in the formal tree;
- finite-memory refinement statements;
- the model-level finite-step refinement theorem;
- segment-fit address bounds and memory geometry for the Lean loader; and
- the implication from the defined binary-valid trace predicate to the
  defined abstract valid trace predicate.

These facts prove the statements as encoded. They do not independently prove
that the encoding is a complete statement of the RISC-V ISA, ELF ABI, hardware,
or Rust language semantics.

### 5.2 Runtime checked, not proved about all inputs

`scripts/verify_elf.lean` runs Lean code over one supplied file. Its checks
establish that this invocation accepted the file according to the parser and
loader implementation. They do not constitute a theorem quantifying over all
ELFs or prove that an external component will load the image identically.

The ELF parser currently validates selected fields and ranges, not every ELF
ABI condition. Loader order also matters if program headers overlap; no
independent policy/theorem establishes that overlaps are rejected or
architecturally appropriate.

### 5.3 External trusted components

The following remain outside the project theorems:

- `rustc`, its LLVM backend, compiler flags, and Rust language/compiler
  correctness;
- `rust-lld`, the linker script's full interpretation, and the linker's
  production of the ELF fields;
- the host filesystem/runtime delivering the bytes to Lean;
- the correctness/completeness of the ELF profile as an architecture contract;
- Lean 4's kernel/compiler/runtime as the proof-checking platform; and
- the Lean foundational axioms reported by `#print axioms`, including
  `propext` and `Quot.sound` where used.

The no-unsafe and no-allocation policy scripts are source scans over selected
syntax. They are useful guardrails but do not replace a whole-program
capability proof or account for all compiler/runtime behavior.

### 5.4 Not established

The repository does not currently establish:

- complete RISC-V specification conformance for all 32-bit words;
- a universal Rust decoder/step to Lean decoder/step theorem;
- a source-to-machine-code correctness theorem for Rust compilation;
- full execution refinement of the generated firmware ELF;
- proof-system construction, verifier soundness, or cryptographic security;
- a production circuit encoding bound to all state fields and transitions; or
- a seL4-style end-to-end assurance case.

## 6. Build and operation entry points

From the repository root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml \
  --target riscv32i-unknown-none-elf
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

`make firmware` builds the linked artifact. `make verify-firmware` builds the
firmware, builds Lean, then runs the ELF verification program. The Makefile's
`differential` and `mutation` targets invoke the same finite adversarial
harness. `scripts/verify_all.sh` runs source checks, Lean build, Rust check,
and Rust tests; the test command must be run with an appropriate host target
and linker when the configured bare-metal target does not provide the Rust test
harness.

## 7. Architecture summary

The data architecture intentionally places formal semantics, runtime binary
validation, and systems implementation side by side:

- **Lean semantic layer:** abstract instruction words/states and transition
  predicates.
- **Lean binary layer:** ELF32 byte parsing, checked segment mapping, fetch,
  decoder call, and predicates for binary-valid transitions/traces.
- **Rust layer:** a bounded no-std reference implementation plus a separate
  firmware link fixture.
- **Bridge layer:** proved relationships among Lean definitions and runtime
  checks of a concrete ELF, but no current compiler-to-machine-code theorem.

This decomposition makes current guarantees reviewable while leaving the
largest assurance gap explicit: proving that actual compiled Rust machine code,
loaded from the ELF under the stated assumptions, follows the same RV32I
transition semantics for all relevant states and traces.
