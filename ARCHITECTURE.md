# zkRV32I-Lean: Architecture and Verification Boundaries

## 1. Executive summary

`zkRV32I-Lean` is a Lean 4 and Rust workbench for RV32I instruction
semantics, bounded-memory modeling, selected Lean-to-Lean refinement
theorems, ELF32/RISC-V loading, and a functional ALU datapath abstraction.
Its architecture deliberately separates mathematical definitions, runtime
artifact checks, and external implementation tools.

The current development provides:

- a Lean instruction decoder and partial machine-step function;
- a bounded Lean memory representation related to Lean total-function memory;
- a Lean-transcribed Rust-shaped state/step specification and its refinement
  theorem to the Lean machine step;
- a subset ELF32 parser, bounded segment loader, instruction fetch/decode, and
  a theorem projection for predicates constructed from successful transitions;
- a runtime script that parses an ELF fixture and models **one** entry
  transition, followed by isolated Lean-model edge checks; and
- a functional single-cycle ALU subset whose Lean result is proved equal to
  the corresponding Lean `step`.

The Lean source scans currently find no `sorry`, `admit`, or project-defined
`axiom` commands. Theorems still depend on Lean foundational axioms; current
`#print axioms` output includes `[propext, Quot.sound]` for the master
step-refinement theorem and the datapath refinement theorem.

This is a meaningful base for further verification work, not a claim of
complete ISA conformance, verified Rust compilation, complete binary execution
refinement, RTL correctness, physical-silicon assurance, or production
zero-knowledge security.

## 2. Source tree and responsibilities

The following is the maintained-source view. Generated `.lake/` and Cargo
`target/` files are summarized separately; individual build hashes are not
stable source artifacts.

```text
zk-verifier-core/
├── .cargo/
│   └── config.toml
├── .github/workflows/ci.yml
├── adversarial/
│   ├── Cargo.toml
│   ├── Cargo.lock
│   ├── LeanOracle.lean
│   ├── corpus.txt
│   └── src/main.rs
├── circuit/                              [empty directory]
├── formal/
│   ├── ZkRV32I.lean
│   └── ZkRV32I/
│       ├── Base.lean
│       ├── ISA.lean
│       ├── Machine.lean
│       ├── Trace.lean
│       ├── Binary.lean
│       ├── Source.lean
│       ├── Hardware/SingleCycle.lean
│       ├── Refinement/Memory.lean
│       ├── Refinement/Step.lean
│       └── Circuit/
│           ├── Field.lean
│           └── Constraints.lean
├── release/
│   ├── BUILD_PROVENANCE.md               [historical snapshot]
│   ├── KNOWN_LIMITATIONS.md              [historical snapshot]
│   ├── PROOF_MANIFEST.md                 [historical snapshot]
│   └── VERIFIED_SCOPE.md                 [historical snapshot]
├── rust/
│   ├── Cargo.toml
│   ├── firmware.ld
│   └── src/
│       ├── lib.rs
│       └── bin/firmware.rs
├── scripts/
│   ├── check_alloc_policy.sh
│   ├── check_axiom_policy.sh
│   ├── check_isa_coverage.sh
│   ├── check_no_admit.sh
│   ├── check_no_sorry.sh
│   ├── check_no_unsafe.sh
│   ├── verify_all.sh
│   └── verify_elf.lean
├── Cargo.toml
├── Cargo.lock
├── lakefile.toml
├── lake-manifest.json
├── lean-toolchain
├── rust-toolchain.toml
├── Makefile
├── README.md
├── ARCHITECTURE.md
├── TECHNICAL_WHITEPAPER.md
└── _probe_riscv.rs                       [standalone probe, not Cargo target]
```

### 2.1 Lean modules

| Module | Architectural role |
|---|---|
| [`formal/ZkRV32I.lean`](formal/ZkRV32I.lean) | Package root, imports project modules, and exports selected definitions/theorems. |
| [`formal/ZkRV32I/Base.lean`](formal/ZkRV32I/Base.lean) | `Word32 = UInt32`, register abstraction, byte memory, range predicates, and little-endian load/store primitives. |
| [`formal/ZkRV32I/ISA.lean`](formal/ZkRV32I/ISA.lean) | Instruction constructors, decode error type, fields, immediate helpers, and decoder. |
| [`formal/ZkRV32I/Machine.lean`](formal/ZkRV32I/Machine.lean) | Machine state and `step : MachineState → Instruction → Option MachineState`, plus `execute`. |
| [`formal/ZkRV32I/Trace.lean`](formal/ZkRV32I/Trace.lean) | Bounded state-list model, `MAX_TRACE`, initial/terminal and valid transition/trace predicates. |
| [`formal/ZkRV32I/Refinement/Memory.lean`](formal/ZkRV32I/Refinement/Memory.lean) | `RustMemory size` as a Lean finite-memory model and conversion/load/store relations to Lean memory. |
| [`formal/ZkRV32I/Refinement/Step.lean`](formal/ZkRV32I/Refinement/Step.lean) | Rust-shaped instruction/state definitions in Lean, finite-step models, and `master_end_to_end_refinement`. |
| [`formal/ZkRV32I/Source.lean`](formal/ZkRV32I/Source.lean) | Names the source-shaped Lean transcription as `rustSourceStep`; exposes `rust_to_rv32i_refinement` and a successful-model-store range theorem. |
| [`formal/ZkRV32I/Binary.lean`](formal/ZkRV32I/Binary.lean) | ELF32 subset parser, segment loading, bounds/geometry theorems, `fetch32`, decode bridge, binary step, and binary-valid predicates. |
| [`formal/ZkRV32I/Hardware/SingleCycle.lean`](formal/ZkRV32I/Hardware/SingleCycle.lean) | Functional ALU control and input/result/writeback model for ALU instructions; theorem to Lean `step`. Not RTL. |
| [`formal/ZkRV32I/Circuit/Field.lean`](formal/ZkRV32I/Circuit/Field.lean) | Illustrative Boolean operations and selected algebraic lemmas. |
| [`formal/ZkRV32I/Circuit/Constraints.lean`](formal/ZkRV32I/Circuit/Constraints.lean) | Illustrative trace/constraint predicates; current encoding uses an empty gate list. |

`RegisterFile.x0` in `Base.lean` is defined as a constant-zero accessor.
Accordingly, theorems stated only about that accessor are not proofs of an
independent physical x0 cell invariant.

### 2.2 Rust, build, and validation tooling

| Path | Responsibility |
|---|---|
| [`.cargo/config.toml`](.cargo/config.toml) | Default target and target-specific panic/linker arguments. |
| [`rust/src/lib.rs`](rust/src/lib.rs) | `no_std`/`forbid(unsafe_code)` Rust reference library: word/register/memory types, decoder, step, and unit tests. |
| [`rust/src/bin/firmware.rs`](rust/src/bin/firmware.rs) | Bare-metal entry fixture; looping entry routine and retained reference to the Rust decoder. |
| [`rust/firmware.ld`](rust/firmware.ld) | Linker script selecting `_start` and image placement at `0x80000000`. |
| [`scripts/verify_elf.lean`](scripts/verify_elf.lean) | Runtime ELF validation, loading, entry fetch/decode, one modeled binary step, and selected Lean-only edge checks. |
| [`scripts/check_no_sorry.sh`](scripts/check_no_sorry.sh) | Source scan for the `sorry` token. |
| [`scripts/check_no_admit.sh`](scripts/check_no_admit.sh) | Source scan for `admit`. |
| [`scripts/check_axiom_policy.sh`](scripts/check_axiom_policy.sh) | Source scan for project axiom commands and theorem axiom allowlist check. |
| [`scripts/check_no_unsafe.sh`](scripts/check_no_unsafe.sh) | Source scan for required crate attributes and common unsafe constructs. |
| [`scripts/check_alloc_policy.sh`](scripts/check_alloc_policy.sh) | Heuristic scan for common allocation APIs. |
| [`scripts/check_isa_coverage.sh`](scripts/check_isa_coverage.sh) | Text-presence check for instruction variants; not semantic coverage proof. |
| [`scripts/verify_all.sh`](scripts/verify_all.sh) | Runs policy scripts, Lake build, Cargo check, and Cargo test. Test target support is environment-dependent. |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | CI workflow for Lean, source checks, Rust check, and tests. |
| [`adversarial/LeanOracle.lean`](adversarial/LeanOracle.lean) | Lean command-line oracle for a single instruction/state sample. |
| [`adversarial/src/main.rs`](adversarial/src/main.rs) | Host-side finite differential and mutation harness; allocates and is not part of the no-std execution core. |
| [`adversarial/corpus.txt`](adversarial/corpus.txt) | Finite set of checked-in oracle cases. |
| [`adversarial/Cargo.toml`](adversarial/Cargo.toml) | Harness package manifest. |
| [`adversarial/Cargo.lock`](adversarial/Cargo.lock) | Harness dependency lockfile. |

The toolchain pins are in [`lean-toolchain`](lean-toolchain) and
[`rust-toolchain.toml`](rust-toolchain.toml). Root Cargo and Lake manifests are
[`Cargo.toml`](Cargo.toml), [`Cargo.lock`](Cargo.lock), and
[`lakefile.toml`](lakefile.toml); [`lake-manifest.json`](lake-manifest.json)
records the resolved Lake package state. `circuit/` is empty; circuit-related
Lean source is under the formal module tree. The four `release/*.md` files are
historical snapshots and are not authoritative current proof manifests.

Generated `.lake/`, `target/`, and `adversarial/target/` trees contain
intermediate build products and cached artifacts. The linked firmware output,
when built, is at
`target/riscv32i-unknown-none-elf/release/firmware`; it is a generated fixture,
not maintained source.

## 3. Mathematical model and execution interfaces

### 3.1 State and step relation

The Lean state is a tuple:

\[
\sigma = (pc, regs, mem, terminal)
\]

where `pc : Word32`, `regs : Fin 32 → Word32` through the register structure,
`mem` has a 32-bit base, a natural-number size, and a total byte function, and
`terminal ∈ {running, halted}`.

The machine operation is partial:

\[
\operatorname{step} : \Sigma \times Instruction \to Option(\Sigma).
\]

Returning `none` represents a failure of the modeled operation, such as a
memory range rejected by `Memory.validRange`, or a control-transfer target
that fails the model's alignment check. `ECALL` and `EBREAK` set the terminal
tag to `halted`; the given definition does not model privilege modes or an
architectural trap handler. `FENCE` advances PC and does not model memory
ordering.

The current `step` matches on an already constructed instruction. It does not
fetch an instruction word itself. `execute` combines the Lean decoder with
`step`, while `Binary.binaryStep` combines memory fetch, decode, and `step`.

### 3.2 Range and alignment predicate

For memory base \(b\), byte size \(n\), address \(a\), width \(w\), and
alignment \(q\), the model accepts a range only if:

\[
\begin{aligned}
&q \le 1 \;\lor\; a \bmod q = 0,\\
&w > 0,\quad b \le a,\\
&a + (w - 1) < 2^{32},\\
&a - b + w \le n.
\end{aligned}
\]

`Memory.validRange` uses natural-number expressions for its bounds rather than
wrapping arithmetic. Loads and stores return `none`/`some` according to this
predicate. This is a property of the Lean memory model; Rust's actual
`Memory::checked_offset` is separately implemented and not derived from this
definition by a verified compiler theorem.

### 3.3 Finite-memory and step correspondence

`RustMemory size` maps indices `Fin size` to bytes. Its `Refines` relation
requires equal base, equal size, and equal bytes at every in-range index.
The development proves selected conversion and load/store relationships
between this finite representation and Lean's total-function memory.

The master theorem has the form:

\[
\operatorname{rustFiniteStepSpec}(s,\operatorname{encodeInstruction}(i))
= \operatorname{step}(s.toLean,i)
\]

for a finite state \(s\), instruction \(i\), and aligned-PC precondition in
the theorem. `rustSourceStep` is a naming wrapper over that Lean
specification. This is a Lean-to-Lean theorem: no Rust source is parsed or
executed in the proof.

### 3.4 Binary and ELF model

The parser accepts a selected subset of ELF32 little-endian RISC-V inputs. It
checks the identification bytes, `ET_EXEC`, RISC-V machine identifier,
version/header size, program-header table bounds, program-header file bounds,
and `p_filesz ≤ p_memsz`. The project-specific profile does not claim complete
ELF ABI validation or validate every relocation, segment-overlap, permission,
alignment-congruence, and platform convention.

For a loadable segment with file offset \(o\), file size \(f\), virtual
address \(v\), memory size \(m\), input file \(F\), and destination memory
`Mem`, `segmentFits` enforces:

\[
o+f \le |F|,\quad f\le m,\quad v+m\le 2^{32},\quad
b\le v,\quad v-b+m\le |Mem|.
\]

`loadSegment` copies the \(f\) bytes and zero-fills the interval from \(f\) to
\(m\), preserving bytes outside the loaded interval. The proved bounds and
geometry lemmas concern these definitions. They do not prove behavior of an
external loader or validate all program-header interaction policies.

`fetch32` requires \(a \bmod 4=0\) and `Memory.validRange Mem a 4 4 = true`.
It forms a little-endian word:

\[
\operatorname{fetch32}(Mem,a)
= \sum_{k=0}^{3} Mem[a-b+k]\cdot 2^{8k}
\]

as `BitVec 32`. `decodeBitVec32` passes its numeric value to the Lean ISA
decoder. `binaryStep` then applies `step` to that decoded instruction.

The `binaryValidTransition` predicate existentially includes a successful
fetch, successful decode, and successful Lean step. Its theorem projecting to
`valid_transition` is therefore a predicate implication based on an already
present transition witness; it is not an independently derived theorem about
arbitrary ELF execution.

### 3.5 Functional datapath abstraction

`Hardware.SingleCycle` defines an `ALUControl` selection and a function
mapping selected operands to a word result. `selectALUInputs` covers 19
ALU/shift instruction constructors. `singleCycleALUStep` applies this ALU
function and writes the result to the destination register while advancing
the PC, subject to its current terminal/alignment guards.

The theorem `singleCycleALUStep_refines_step` proves equality with the Lean
`step` function under successful-input and aligned-PC assumptions. Despite
the module name, this is a functional datapath abstraction: no clock,
pipeline, reset, bus protocol, synthesized netlist, RTL source, gate-level
design, or silicon is modeled.

## 4. Data flow and execution pipeline

### 4.1 Runtime firmware smoke test

```text
Rust fixture + Rust reference library
       │ rustc, target configuration, linker script
       ▼
RISC-V ELF32 ET_EXEC file
       │ runtime file read by Lean IO
       ▼
ELF header and program-header subset parser
       ▼
checked PT_LOAD-style mapping into Lean Memory
       ▼
entry range check → fetch32 → BitVec 32
       ▼
decodeBitVec32 → ISA.decode
       ▼
binaryStep once from MachineState.initial
       ▼
print resulting next PC; run separate Lean model edge cases
```

The current fixture has a bare-metal entry at `0x80000000`. The runtime
verifier checks that the entry is in an executable loadable segment, maps the
segments into a fixed Lean memory region, then fetches, decodes, and simulates
one instruction. It does not repeatedly run until a loop, terminal state, or
trace bound; nor does it execute the ELF on a RISC-V emulator or core.

The edge checks are separate Lean evaluations for ADDI 32-bit wraparound,
rejection of unaligned and overflowing ranges, modeled ECALL halting, and the
`MAX_TRACE` boundary. They are not adversarial or property-based tests of all
states, nor tests of matching Rust operations.

### 4.2 Model-level refinement path

```text
RustMemory (Lean finite function) ──relation──► Lean Memory
RustFiniteState (Lean definition) ──toLean────► Lean MachineState
             │                                      │
             └── rustFiniteStepSpec ────────────────┘
                              │
                              ▼
              master_end_to_end_refinement

ALU input selection + ALU result + writeback (Lean)
                              │
                              ▼
              singleCycleALUStep_refines_step
```

These results connect Lean definitions. Neither path takes compiled firmware
bytes as a theorem input, proves Rust compilation correct, or reaches an
external hardware design.

## 5. Security and verification claims matrix

| Claim area | Current evidence | Formal scope | Open obligation |
|---|---|---|---|
| No `sorry`/`admit` | Source scans and successful Lean build. | Scans cover configured source patterns; build checks imported declarations. | Independently audit all generated/imported modules and verify CI environment. |
| Project axioms | Source scan finds no project axiom declarations. | Theorem audit reports standard Lean axioms including `propext`, `Quot.sound`. | Define and justify the trusted foundational base; do not call this axiom-free. |
| ISA semantics | Lean decoder and machine definitions compile. | Theorems hold for those definitions. | Formal conformance to the full RISC-V unprivileged specification, reserved cases, and faults. |
| Memory safety in model | `validRange`, checked loads/stores, finite memory lemmas. | Range facts for Lean memory operations. | Link these facts universally to actual Rust source behavior and generated code. |
| Rust core policy | `no_std` / `forbid(unsafe_code)` attributes; heuristic scans; target `cargo check`. | Build and source checks only. | Full dependency/toolchain analysis, host unit tests, verified source semantics. |
| ELF parser/loader | Runtime parser and checked segment loader; bounded-address/geometry theorems. | Subset format and Lean loader definitions. | Complete ELF profile, parser soundness/completeness, overlaps/permissions/relocations, producer/loader correspondence. |
| Binary execution | One entry `binaryStep` succeeds for current firmware fixture. | Concrete runtime smoke test, not a universal theorem. | Multi-step fetch/decode trace refinement from arbitrary artifact bytes. |
| Datapath | Functional ALU subset agrees with Lean `step` by theorem. | Pure Lean function equality under explicit preconditions. | RTL/gate-level refinement, timing, reset/clock and memory-system modeling. |
| Adversarial tests | Finite checked-in corpus and hand-written mutation checks. | Selected software cases. | Broad property/fuzz testing; tests do not replace proofs. |
| ZK claims | Illustrative Boolean predicate modules. | Definitions and selected lemmas only. | Sound encoding, proof system, verifier, zero-knowledge and cryptographic security. |

The no-unsafe and no-allocation scripts are syntactic scans, not proofs over
all dependencies or compiled code. The ISA coverage script checks textual
presence and cannot establish semantic completeness.

## 6. Trust boundaries

The Lean kernel checks theorem proofs relative to Lean's type theory and
reported foundational axioms. The project depends on Lean's trusted
proof-checking platform. A successful `lake build` establishes compilation of
the Lean modules; it is not by itself evidence that the modeled ISA is
complete or matches an external standard.

The Rust source is compiled by `rustc` and linked by the target toolchain. The
ELF is read by Lean IO at runtime. No current theorem proves:

- Rust language semantics for the implementation;
- correctness of `rustc`, LLVM transformations, or `rust-lld`;
- equivalence of the compiled ELF to the Rust reference state machine;
- that an external ELF loader maps segments exactly as the Lean loader does;
- behavior of an arbitrary conformant RISC-V implementation; or
- refinement of physical execution traces to Lean `Trace`.

For a grant or assurance review, any future result should report the exact
source/binary/RTL artifact, assumptions, theorem statement, axiom dependencies,
test commands, and toolchain provenance. The repository does not currently
provide an institutional certification or assurance case.

## 7. Build and validation interfaces

From the project root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml \
  --target riscv32i-unknown-none-elf
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

`make verify-firmware` combines firmware build, Lean build, and the runtime
smoke test. `scripts/verify_all.sh` also attempts Rust tests; a bare-metal
target normally does not provide the Rust `test` harness, so testing requires
a supported host target and linker. The CI workflow should be inspected for
that target assumption before using it as a release gate.

## 8. Research roadmap

### Phase 1 — Current Lean model and loader foundation (implemented, scoped)

- Lean RV32I definitions and machine step;
- finite-memory relation and model-level step refinement;
- subset ELF parser, bounded segment loader, and fetch/decode definitions;
- functional ALU subset refinement;
- one-step ELF runtime smoke check and selected isolated model edge cases.

“Implemented” here means these modules and checks exist and build; it does not
mean full ISA, ELF, Rust, binary, or hardware correctness is established.

### Phase 2 — Translation validation and source refinement

Choose a precisely specified source language/IR and compiler pipeline. Define
the source operational semantics, compiler-output format, and validator
relation. Prove a validator theorem over the actual emitted instruction
sequence, state fault/undefined-behavior assumptions, and disclose every
trusted component. Rust source syntax alone is not an adequate formal
interface.

### Phase 3 — Concrete RTL refinement

Select a specific core design, version, and formal interface. Model clock,
reset, fetch/data requests, memory responses, exceptions, and architectural
state. Prove a refinement relation between cycle-level RTL transitions and
the ISA step relation, accounting for stuttering and microarchitectural state.
The current `SingleCycle` function is not a substitute for this task.

### Phase 4 — End-to-end binary trace and constraint soundness

Prove parser/loader properties against a stated ELF profile, carry fetched
instruction bytes through a multi-step execution relation, and show trace
refinement. Separately construct a non-placeholder constraint encoding and
prove soundness/completeness relative to the trace specification before
making cryptographic claims.

All phases are research proposals. No phase should be presented as complete
without a concrete theorem inventory, independently reproducible build, and
explicit trust-base statement.

## 9. Related project documents

- [`README.md`](README.md): user-facing orientation and commands.
- [`TECHNICAL_WHITEPAPER.md`](TECHNICAL_WHITEPAPER.md): formal notation,
  theorem scope, claims matrix, and open research obligations.
- [`release/`](release): historical snapshots; consult current source and
  documents for the present project state.
