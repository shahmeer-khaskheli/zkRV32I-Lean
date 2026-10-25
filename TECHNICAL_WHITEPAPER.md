# A Lean and Rust Foundation for RV32I Modeling and ELF Loading

## Abstract

This paper describes the current `zkRV32I-Lean` repository as an engineering
artifact, not as a claim of complete processor verification. The code contains
a Lean 4 model of RV32I instruction decoding and state transitions, a
`no_std`/`forbid(unsafe_code)` Rust reference implementation, Lean finite-memory
refinement lemmas, a model-level step theorem, and an ELF32/RISC-V parser and
loader. A linked bare-metal RISC-V ELF can be checked by a Lean runtime
verification program for its header, loadable segments, entry placement, and
entry instruction decode.

The current proofs are machine checked by Lean 4.19.0 and the current Lean
source scans contain no `sorry`, `admit`, or project-defined axiom
declarations. The master refinement theorem depends on Lean's foundational
axioms `propext` and `Quot.sound`. Most importantly, the theorem relates two
Lean specifications; it is not a proof of Rust compiler correctness or
equivalence between compiled Rust and the Lean machine. The ELF check evaluates
a concrete file but is not a theorem about the compiler or the binary's full
execution.

## 1. Introduction and motivation

Systems software combines arithmetic, memory, control flow, and toolchain
behavior. Formal models can make parts of that behavior explicit and allow
theorem provers to check propositions about those definitions. In proof-system
and zero-knowledge settings, a further obligation is to show that a
constraint-system encoding faithfully represents the intended computation and
that the proof system's verifier has the claimed soundness properties.

`zkRV32I-Lean` provides a small development setting for exploring these layers:

1. specify instruction decoding and machine steps in Lean;
2. implement a safe, fixed-size Rust reference machine;
3. state and prove correspondence properties between Lean definitions;
4. parse and load a concrete RISC-V ELF into a formal byte-memory model; and
5. distinguish the above from the still-missing link between actual compiled
   Rust instructions and the Lean semantics.

The current circuit-related modules are illustrative and are not a
zero-knowledge proof system. The project name and the presence of circuit
predicates should not be taken as evidence of a deployed or cryptographically
sound zkVM.

## 2. Project components

### 2.1 Word, register, and memory definitions

In [`formal/ZkRV32I/Base.lean`](formal/ZkRV32I/Base.lean), `Word32` is an
abbreviation for Lean `UInt32`. Helper definitions provide conversion,
signed interpretation, sign extension, addition, and subtraction. The Lean
`RegisterFile` stores a function from `Fin 32` to words. Reads of index zero
return zero, writes to index zero return the old record, and the `x0` accessor
itself is defined as constant zero.

Lean memory is a structure containing:

- a `Word32` base address;
- a natural-number byte size; and
- a total function from natural indices to `UInt8`.

`Memory.validRange` checks alignment, nonzero width, base ordering, 32-bit end
address bounds, and the memory-size bound. `load` and `store` are partial
operations, returning `Option` to represent invalid access. Values are
assembled and written little-endian.

The fact that `RegisterFile.x0` is a constant accessor matters when
interpreting its theorems: the zero-accessor properties do not prove a
nontrivial invariant about an independently stored x0 cell.

### 2.2 Instruction set and decoder

[`formal/ZkRV32I/ISA.lean`](formal/ZkRV32I/ISA.lean) defines constructors for
the 40 instruction cases exercised by the repository's coverage script:

- U-type and jumps: `LUI`, `AUIPC`, `JAL`, `JALR`;
- conditional branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`;
- loads: `LB`, `LH`, `LW`, `LBU`, `LHU`;
- stores: `SB`, `SH`, `SW`;
- immediate ALU and shifts: `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`,
  `SLLI`, `SRLI`, `SRAI`;
- register ALU and shifts: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`,
  `SRA`, `OR`, `AND`; and
- system/control: `FENCE`, `ECALL`, `EBREAK`.

The Lean decoder extracts fields from the numeric word, reconstructs signed
immediates, and returns either an instruction or a `DecodeError`. The B-type
immediate implementation includes the standard bit-7-to-immediate-bit-11 and
bit-31-to-sign-bit-12 weights with supporting lemmas. This does not amount to a
formal proof that all decoding rules and reserved-field behavior match the
complete RISC-V ISA specification for every possible 32-bit encoding.

Rust's decoder is implemented separately in
[`rust/src/lib.rs`](rust/src/lib.rs). Its errors distinguish illegal from
unsupported encodings. Both implementation presence and finite test cases are
useful checks, but neither is a universal decoder-equivalence proof.

### 2.3 Operational machine semantics

[`formal/ZkRV32I/Machine.lean`](formal/ZkRV32I/Machine.lean) defines a machine
state with PC, registers, memory, and a running/halted terminal tag. `step`
matches on an abstract `Instruction` and returns `Option MachineState`.
Arithmetic uses `UInt32` operations; branches, jumps, loads, and stores update
state according to the Lean definitions. `FENCE` advances sequentially without
memory-ordering effects. `ECALL` and `EBREAK` set the terminal tag to halted.
This model is not a concurrent or privilege-aware RISC-V implementation.

The Rust library represents memory using a const-generic fixed-size byte array,
and Rust `step` takes ownership of a machine state and returns
`Result<MachineState, ExecutionError>`. It checks terminal state, register
indices, and PC alignment; memory operations can report out-of-bounds,
misalignment, or address overflow. Rust and Lean therefore do not use
identical fault representations, and correspondence of every fault category
is not established by the successful-step master theorem.

### 2.4 Finite-memory relation and refinement theorem

[`formal/ZkRV32I/Refinement/Memory.lean`](formal/ZkRV32I/Refinement/Memory.lean)
defines `RustMemory size` using a `Fin size → UInt8` byte vector and a base
address. Its `Refines` predicate requires equal bases, matching size, and
equal bytes at in-range indices. The module proves conversion/refinement
properties, load agreement, and store agreement between two Lean memory
definitions.

[`formal/ZkRV32I/Refinement/Step.lean`](formal/ZkRV32I/Refinement/Step.lean)
defines `RustFiniteState`, a separate Lean datatype intended to model the
finite Rust state. It also defines finite-step specifications and
correspondence lemmas, culminating in
`ZkRV32I.Refinement.master_end_to_end_refinement`. In simplified notation, the
theorem states, for a finite state and abstract instruction with an aligned
PC:

```text
rustFiniteStepSpec state (encodeInstruction instruction)
  = step state.toLean instruction
```

Both sides of this equation are Lean definitions. The theorem does not invoke
Rust code, extract a Rust program, or reason about compiler output. Its name
must therefore not be interpreted as a Rust-to-binary universal refinement
result.

### 2.5 Trace predicates

[`formal/ZkRV32I/Trace.lean`](formal/ZkRV32I/Trace.lean) defines a finite
`Trace` of `MachineState` values bounded by `MAX_TRACE = 2^20`. A valid trace is
nonempty, begins in an initial state, and has adjacent rows related by
`valid_transition`. That transition predicate existentially supplies an
instruction whose Lean step reaches the next row.

The trace stores state rows, not instruction words or a fetch witness. In
particular, ordinary `valid_trace` is not by itself a binary execution trace.

## 3. ELF32 parsing and loading

### 3.1 Parser profile

[`formal/ZkRV32I/Binary.lean`](formal/ZkRV32I/Binary.lean) contains functions
to read little-endian 16-bit and 32-bit values from `Array UInt8`. The parser
checks a subset of the ELF32 executable profile:

- ELF magic, 32-bit class, little-endian encoding, and current identification
  version;
- `ET_EXEC`, RISC-V machine identifier 243, and ELF header size 52;
- program-header table extent within the input byte array;
- the minimum 32-byte ELF32 program-header size;
- each parsed program-header record's file extent; and
- `p_filesz ≤ p_memsz`.

The parser reads the fields used to construct `ELF32Header` and
`ELF32ProgramHeader`. It is a project-specific parser, not a complete,
independently validated implementation of every ELF ABI rule. It does not
validate all alignment congruences, all optional header fields, permissions
and overlap policies, or every architecture-specific ABI requirement.

### 3.2 Segment loading and theorem scope

`segmentFits` checks that a segment's file range fits the byte array, that its
file size does not exceed its memory size, that its virtual address plus memory
size is at most `2^32`, and that its range lies within the target Lean memory
region. These expressions use `Nat`, so the bound checks themselves do not
wrap. `loadSegment` copies file bytes, zero-fills the `p_memsz - p_filesz`
tail, and preserves memory bytes outside the loaded range. `loadELF32Segments`
folds the segment operation over loadable (`PT_LOAD`) records.

The machine-checked theorems `segmentFits_preserves_address_bounds`,
`loadSegment_success_preserves_geometry`, and
`loadSegment_success_has_bounded_addresses` establish bounds and memory
geometry properties for the Lean loader. They do not prove that the host file
reader, ELF producer, linker, or an external loader has the same behavior.

### 3.3 Fetch and decode

`fetch32` requires a word-aligned address and a valid four-byte memory range,
then combines four bytes little-endian into a `BitVec 32`. `decodeBitVec32`
converts that bitvector's natural value to `Word32` and invokes the existing
Lean decoder. `fetchDecode_uses_isa_decoder` records this connection.

`binaryStep` composes these operations with Lean `step`. The binary transition
predicate includes a fetched word, a successful decode, and a successful
abstract step. `binaryValidTrace_implies_valid_trace` follows by projecting the
step witness from each binary transition. This is a valid implication between
the defined Lean predicates, but does not establish that every possible
machine execution of a linked artifact follows those transitions.

### 3.4 Concrete artifact verification

The firmware target in [`rust/src/bin/firmware.rs`](rust/src/bin/firmware.rs)
is `no_std`, `no_main`, and `forbid(unsafe_code)`. Its start routine loops and
the source declares a `#[used]` static function pointer to the Rust decoder.
The linker script
[`rust/firmware.ld`](rust/firmware.ld) places `_start` at `0x80000000`.
[`scripts/verify_elf.lean`](scripts/verify_elf.lean) reads the resulting file
at runtime and checks:

1. parsing succeeds and the object type is `ET_EXEC`;
2. the parsed program-header count matches the header;
3. the entry lies inside a loadable executable segment;
4. the loadable segments fit the configured Lean memory;
5. the entry address is a valid aligned four-byte range; and
6. the fetched entry instruction decodes successfully.

This is an executable validation procedure over a particular file. It is not a
proof inside Lean that the compiler or linker generated the file correctly,
nor does it execute the firmware or prove all its instructions and reachable
states. The entry routine is a linker/loading fixture, not a run of the Rust
reference `step` implementation.

## 4. Constraint model and zero-knowledge boundary

The modules under `formal/ZkRV32I/Circuit/` define an illustrative Boolean
field (`Bool` as `F₂`), add/multiply gates, public entry/final PC and trace
length, and predicates called boundary, transition, range-check, ALU, branch,
memory, and public-output constraints.

The current implementation has important limitations:

- `encode` stores the trace with an empty gate list.
- The range predicate constrains the trace length only; it does not bit-decompose
  PC, registers, addresses, or intermediates.
- The gate equations are not linked to instruction operands or result columns.
- Branch and memory constraints reuse the semantic transition predicate.
- Public inputs do not bind final registers, memory, or commitments.
- There is no production AIR/R1CS construction, cryptographic commitment,
  proof system, verifier, or cryptographic soundness theorem.

Consequently, the circuit module is a Lean predicate exercise, not a
zero-knowledge proof implementation.

## 5. Proof and policy audit

### 5.0 Finite adversarial harness

The `adversarial` crate has a ten-case checked-in corpus, invokes the Lean
oracle and Rust decoder/step implementation, compares selected output state,
and includes hand-written checks for several mutation classes. Its host-side
code uses allocating Rust types and is not part of the `no_std` execution
crate. The corpus and mutation checks are finite software tests; they do not
substitute for universal theorems. The Makefile's `differential` and `mutation`
targets both invoke this harness rather than separate mutation-testing
infrastructure.

### 5.1 Placeholder scan

The source policy scripts scan `.lean` files for `sorry` and `admit`, and scan
for project-defined `axiom` commands. The current scan reports none of these.
This statement is limited to source matched by the scripts; generated `.lake`
outputs are excluded from the scans.

### 5.2 Theorem axiom dependencies

The current `#print axioms` results include:

```text
ZkRV32I.Refinement.master_end_to_end_refinement
  depends on axioms: [propext, Quot.sound]

ZkRV32I.Binary.loadSegment_success_has_bounded_addresses
  depends on axioms: [propext]

ZkRV32I.Binary.binaryValidTrace_implies_valid_trace
  depends on axioms: [propext]
```

These names are Lean foundational axioms, not declarations introduced by this
project. Thus the accurate claim is **no project-defined axioms or proof
placeholders were found**, rather than “the proofs use no axioms whatsoever.”

The other shell policy scripts are source-level checks. In particular,
`check_isa_coverage.sh` searches for instruction-case text in selected files;
it is not a semantic audit or a proof. The policies do not provide a general
proof that no unsafe or allocation behavior could enter through every
dependency or build configuration.

### 5.3 Reproduction commands

With the pinned toolchains and RV32I target available, run from the repository
root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml \
  --target riscv32i-unknown-none-elf
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

The Rust target linker bundled with the selected toolchain is `rust-lld`, and
the target configuration passes `rust/firmware.ld`. On Windows, Bash-based
scripts also require a working Bash installation and a `PATH` from which `lake`
is available. Rust tests require a target with test-harness support and an
available host linker; a bare-metal target check is not equivalent to running
unit tests.

## 6. Trust boundary

The formal proofs are checked by the Lean kernel in the pinned Lean version.
Theorems rely on the standard Lean foundational axioms reported above. The
repository also relies on the correctness of the Lean compiler/runtime and
kernel implementation as the proof-checking platform.

The ELF file is parsed by Lean code but supplied as an external runtime input.
The Rust source is compiled by `rustc`, and the firmware is linked by the
target linker (`rust-lld`) according to a linker script. The current Lean
theorems do not establish:

- Rust language semantics or correctness of the Rust compiler;
- correctness of LLVM code generation or the linker;
- equivalence of the compiled ELF's machine code to the Rust source semantics;
- complete ELF ABI compliance or behavior of hardware loading; or
- refinement of all firmware executions to the abstract trace semantics.

The theorem connecting a binary-valid trace to `valid_trace` is conditional on
the binary-valid trace predicate, which already requires each fetch/decode
result and each Lean `step` result. It is not an independent derivation of
those witnesses from the generated firmware's actual execution.

## 7. Limitations and future work

A credible path toward a stronger end-to-end result would require separate,
incremental obligations:

1. **ELF parser specification:** Prove parser soundness properties against a
   fully stated ELF32 profile, including the accepted header constraints,
   program-table bounds, segment fields, alignment, and rejection behavior.
2. **Multi-segment image relation:** Define the relation between ELF program
   headers, file bytes, and loaded memory, then prove all load segments preserve
   the intended byte mapping, zero-fill, non-overlap/overlap policy, and
   address bounds.
3. **Binary decoder equivalence:** Prove that instruction bytes fetched from a
   loaded image map to the intended architectural instruction encoding,
   including reserved and unsupported encoding classification.
4. **Execution trace linkage:** Define a fetch-decode-execute trace relation
   that carries concrete instruction words and prove its correspondence with
   the desired ISA semantics over multiple steps.
5. **Rust source and machine-code connection:** Either formally verify the
   relevant Rust compiler/code-generation path, use a verified compiler, or
   narrow the theorem to a specific artifact and make its binary-level
   semantics the object of proof. Any trusted components must be listed.
6. **Fault and terminal correspondence:** Relate Rust `Result` error variants
   to Lean partial outcomes and establish matching conditions for memory
   faults, alignment faults, illegal encodings, halted states, and system
   instructions.
7. **Production constraint system:** If zero-knowledge verification is a goal,
   connect each machine transition to algebraic constraints, prove encoding
   completeness and soundness, implement or specify the proof/verifier stack,
   and establish the required cryptographic assumptions separately.
8. **Build and test reproducibility:** Run policy checks, Rust tests on a
   supported host target, target firmware builds, and artifact validation in CI.
   Finite tests should supplement—not replace—universal theorems.

## 8. Conclusion

The repository currently supplies a machine-checked Lean ISA/machine model, a
no-std Rust reference implementation, Lean finite-memory and model-step
correspondence results, an ELF32/RISC-V loader, and a concrete artifact check
that fetches and decodes the entry instruction of a linked firmware image.
Those are meaningful foundations for further verification work.

They are not yet an unconditional, complete, compiler-to-binary-to-execution
refinement proof. In particular, the existing master theorem is a Lean-to-Lean
model theorem, and the ELF utility validates a concrete file operationally
without proving the compiler/linker path. These boundaries are essential to
the interpretation of all reported build and proof results.
