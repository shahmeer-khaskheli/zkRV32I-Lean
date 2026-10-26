# RV32I Semantics, ELF Loading, and Selected Refinement Results in Lean 4

## Abstract

This paper documents the current technical scope of `zkRV32I-Lean`, a Lean 4
and Rust repository for modeling selected layers of a RISC-V 32-bit integer
execution stack. The Lean development defines 32-bit values, registers,
bounded memory operations, instruction decoding, a partial machine step,
finite-memory correspondence, a Lean-transcribed Rust-shaped step model, an
ELF32/RISC-V subset parser and loader, and a functional ALU datapath
abstraction.

The main model-level theorem equates the Lean finite-state step specification
with Lean `step` for a matching instruction and aligned PC. A separate theorem
establishes equality between a functional Lean ALU result path and Lean `step`
for the ALU instruction subset. ELF runtime tooling checks a concrete
artifact, executes one modeled binary step at its entry, and evaluates selected
standalone model edge cases.

These results are deliberately narrower than verified compilation or processor
verification. The Rust source is not mechanically translated to the Lean
source model. The compiler and linker are not verified. No RTL core is
imported, and the functional ALU model is not a clocked microarchitecture. The
circuit predicates are illustrative, not a cryptographic proof system.
Current source scans find no `sorry`, `admit`, or project-defined axiom
declarations; theorem axiom output includes Lean foundational dependencies,
notably `propext` and `Quot.sound`.

## 1. Motivation and research question

An execution-verification stack contains distinct semantic boundaries:

\[
\text{source program}
\to \text{compiler IR}
\to \text{machine instructions}
\to \text{loaded memory image}
\to \text{architectural transitions}
\to \text{hardware cycles}.
\]

Each arrow requires its own representation relation and correctness
argument. Checking one layer does not discharge the obligations at adjacent
layers. This repository provides a small experimental setting for formalizing
some of these interfaces and for marking the remaining gaps precisely.

The research question represented by the current code is modest:

> What Lean-checkable properties can be stated about a word-level RV32I
> machine model, its finite-memory representation, a subset ELF loading
> function, and a functional ALU abstraction?

The repository does not currently answer the stronger question of whether a
particular Rust program, compiled to a particular ELF, executes identically
on a physical RISC-V implementation.

## 2. Artifact identity and reproducible scope

The pinned versions are Lean `leanprover/lean4:v4.19.0` and Rust
`1.97.1`, with the Rust target `riscv32i-unknown-none-elf`. The root source
tree contains:

- `formal/ZkRV32I/Base.lean`, `ISA.lean`, `Machine.lean`, and `Trace.lean`;
- `formal/ZkRV32I/Refinement/Memory.lean` and `Refinement/Step.lean`;
- `formal/ZkRV32I/Source.lean`;
- `formal/ZkRV32I/Binary.lean`;
- `formal/ZkRV32I/Hardware/SingleCycle.lean`;
- illustrative modules in `formal/ZkRV32I/Circuit/`;
- a Rust reference library and a separate firmware fixture;
- a runtime ELF verification script and source policy scans; and
- a finite host-side differential harness and corpus.

The firmware ELF under `target/` is a generated build artifact. It is not
source-controlled evidence of a particular build unless accompanied by
artifact hashes, compiler/linker provenance, and reproducible build records.
The runtime script reads whichever file path it is given; its result applies
to that invocation only.

## 3. Word, register, memory, and instruction definitions

### 3.1 Machine state

`Base.lean` abbreviates `Word32` to Lean `UInt32`. The formal state in
`Machine.lean` is:

\[
\sigma = (pc, regs, mem, \tau),
\]

where:

- \(pc \in \mathbb{U}_{32}\);
- `regs` is a function-indexed register structure over `Fin 32`;
- memory has a 32-bit base \(b\), natural-number size \(n\), and a total byte
  function; and
- \(\tau\) is the model terminal tag `running` or `halted`.

Reads of register zero return zero; writes to index zero return the old
register structure. The `x0` accessor itself is defined to return zero
independently of the stored function. This representation choice makes some
x0 theorems immediate properties of the accessor definition rather than
nontrivial invariants over a physical cell.

### 3.2 Memory validity

For address \(a\), width \(w\), alignment \(q\), base \(b\), and memory size
\(n\), `Memory.validRange` checks:

\[
\begin{aligned}
&(q \le 1) \lor (a \bmod q = 0),\\
&w \ne 0,\quad b \le a,\\
&a + w - 1 < 2^{32},\\
&a-b+w \le n.
\end{aligned}
\]

The code uses natural-number calculations in the predicate, so the range
checks themselves do not wrap. `Memory.load` and `Memory.store` are partial:
they return `none` on a rejected range and otherwise use little-endian
byte composition/update. These are model semantics. The independently
implemented Rust `checked_offset` is not proven equivalent to this Lean
predicate for all inputs by a theorem about Rust execution.

### 3.3 Instruction syntax and decoder

`ISA.lean` provides constructors for the base RV32I operations represented in
the project: U-type, jumps, conditional branches, loads, stores, immediate and
register integer ALU operations, shifts, `FENCE`, `ECALL`, and `EBREAK`. It
extracts word fields and reconstructs I-, S-, B-, and J-format immediates.
The B-immediate helper and examples cover corrected bit weights, including
the bit-7 contribution to immediate bit 11.

The existence of constructors and examples is not a proof of full
specification conformance. The repository does not contain a theorem proving
the decoder's equivalence to the complete RISC-V encoding table over all
\(2^{32}\) bit patterns, including every reserved field, extension, and
illegal-versus-unsupported classification.

### 3.4 Partial machine operation

The step function is:

\[
\operatorname{step} : \Sigma \times Instruction \to Option(\Sigma).
\]

It matches on an abstract `Instruction`; instruction fetch and decode are
separate operations. `none` denotes a rejected or unavailable modeled
transition, including invalid memory accesses or misaligned control-transfer
targets. The current function does not fully model privilege state,
architectural trap vectors, CSRs, interrupts, or memory ordering. `FENCE`
advances the PC without a concurrency/memory-order semantics. `ECALL` and
`EBREAK` set the terminal state to halted in this model.

## 4. Finite-memory and source-shaped step refinement

### 4.1 Memory relation

`RustMemory size` is a Lean structure with base address and bytes indexed by
`Fin size`. The relation `RustMemory.Refines` requires:

\[
b_\mathrm{finite}=b_\mathrm{lean},\quad
n_\mathrm{lean}=size,\quad
\forall i<size,\; bytes_\mathrm{lean}(i)=bytes_\mathrm{finite}(i).
\]

The module proves conversion/refinement facts and selected load/store
agreement results. The identifier “Rust” labels an intended shape; the
definition is Lean code and is not generated from the Rust library.

### 4.2 Lean source model

`Refinement/Step.lean` defines `RustFiniteState`, `RustInstruction`, a
translation from Lean instruction constructors, and the finite model step
specifications. `Source.lean` exposes:

\[
\operatorname{rustSourceStep}(s,i)
=\operatorname{rustFiniteStepSpec}
  (s,\operatorname{encodeInstruction}(i)).
\]

For aligned PC, the theorem
`ZkRV32I.Refinement.rust_to_rv32i_refinement` states:

\[
\operatorname{rustSourceStep}(s,i)
= \operatorname{step}(s.toLean,i).
\]

This theorem reuses `master_end_to_end_refinement`. It is proved in Lean
because both sides are Lean functions. The Rust file
[`rust/src/lib.rs`](rust/src/lib.rs) is a human reference for the
transcription, but there is no verified parser, extractor, or semantic
translation from that file to `rustSourceStep`.

`rustSourceStore_success_validRange` states that if the finite-model store
returns `some next`, then the corresponding Lean `Memory.validRange` check is
true. It does not establish that every Rust execution is memory-safe, that
the compiler introduces no undefined behavior, or that errors have identical
representations. The Rust API returns typed `Result` errors; multiple Lean
operations use `Option`.

## 5. ELF parser, segment mapping, and binary operations

### 5.1 Accepted ELF subset

`Binary.lean` reads little-endian fields from `Array UInt8` and parses a
project-specific subset of ELF32. The current header parser checks:

- ELF magic, 32-bit class, little-endian encoding, and current identification
  version;
- object type `ET_EXEC`;
- machine identifier 243 (RISC-V);
- ELF version and 52-byte ELF header size;
- program-header entry size minimum when entries exist; and
- program-header table extent within the byte array.

Each program-header parser checks its 32-byte field extent, segment file
extent, and `p_filesz ≤ p_memsz`. This parser does not claim complete ELF ABI
validation; it does not establish every optional-header rule, section-table
rule, alignment congruence, permission combination, overlap policy,
relocation, or platform ABI condition.

### 5.2 Loader predicate and mapping

For a segment \((o,f,v,m)\) and input array \(F\), destination memory with base
\(b\) and size \(n\), `segmentFits` requires:

\[
o+f\le |F|,\quad f\le m,\quad v+m\le 2^{32},\quad
b\le v,\quad v-b+m\le n.
\]

When this predicate holds, `loadSegment` copies bytes \(F[o,\ldots,o+f)\)
into the virtual-address interval and zero-fills the remaining bytes up to
`memorySize`. Outside the affected interval it preserves the memory byte
function. Theorems in `Binary.lean` establish selected address bounds and
base/size geometry for successful calls to this function.

The loader processes loadable segments in program-header order. No complete
independent policy or theorem currently establishes that overlapping segments
are rejected or that the chosen order matches every platform loader's
behavior.

### 5.3 Fetch/decode/step

For word address \(a\), `fetch32` requires:

\[
a \bmod 4=0
\quad\land\quad
Memory.validRange(mem,a,4,4)=true.
\]

It constructs a 32-bit little-endian word:

\[
word = \sum_{k=0}^{3} byte(a-b+k)\cdot 2^{8k}\pmod {2^{32}}.
\]

`decodeBitVec32` converts this value to the existing word decoder.
`binaryStep` composes fetch, successful decode, and `step`. In contrast,
`binaryValidTransition` is a proposition that already contains witnesses for
successful fetch, decode, and abstract step. The theorem from this predicate
to `valid_transition` projects those witnesses; it does not independently
show that every loaded artifact has such a transition at every reachable PC.

### 5.4 Runtime smoke test

The current `scripts/verify_elf.lean` reads an ELF file from the host runtime,
checks executable entry placement, loads segments into a configured Lean
memory region beginning at `0x80000000`, fetches and decodes the entry word,
then requires one successful call to `binaryStep`. It reports the next PC.
For the firmware artifact used in the latest validation, this reported
`0x80000004`.

The script additionally evaluates separate model-level checks:

- `0xffffffff + 1` wraps in `Word32`;
- ADDI from `0xffffffff` plus one writes zero;
- unaligned and overflowing memory ranges are rejected;
- `ECALL` transitions to the modeled halted tag, and a halted state rejects
  another step; and
- the trace length boundary is `MAX_TRACE = 2^{20}`.

These checks do not form a sequential trace of the firmware, do not exercise
the equivalent Rust paths, and do not simulate hardware. They are a finite
runtime smoke test, not exhaustive stress testing.

## 6. Functional ALU datapath refinement

`Hardware/SingleCycle.lean` defines:

- `ALUControl` variants for add, subtract, bitwise logic, comparisons, and
  shifts;
- `selectALUInputs`, which selects destination, operation, and operands for
  the ALU instruction subset;
- `aluExecute`, a pure word-level result function; and
- `singleCycleALUStep`, which writes the selected result and advances PC
  under its terminal/alignment guards.

The theorem `singleCycleALUStep_refines_step` states equality with the Lean
`step` function for an aligned PC and instruction whose ALU input selection is
present. Its proof is a theorem about two Lean definitions. No RTL source or
netlist is imported. There is no cycle relation, clock/reset model, bus
protocol, pipeline state, hazard logic, interrupt protocol, or physical
microarchitecture relation. The name “single-cycle” describes the functional
abstraction, not a validated hardware implementation.

## 7. Theorem and evidence inventory

The table summarizes representative results and the exact boundary of their
interpretation. It is not a claim that each repository property has been
independently audited for all possible inputs.

| Result/evidence | Statement checked | Does not establish |
|---|---|---|
| `rustMemory_toLean_refines` and related memory lemmas | Equality/relations between Lean memory representations. | Rust memory source correctness or compiled behavior. |
| `master_end_to_end_refinement` | Lean finite step spec equals Lean `step` for matching abstract instruction with aligned PC. | Source extraction, compiler correctness, binary refinement. |
| `rust_to_rv32i_refinement` | Source-shaped Lean wrapper refines to Lean `step`. | A theorem about `rust/src/lib.rs` execution. |
| `rustSourceStore_success_validRange` | Successful modeled store implies a valid range. | Universal Rust memory safety or absence of compiler-induced behavior. |
| `loadSegment_success_has_bounded_addresses` | Successful Lean segment load satisfies stated address bounds. | Full ELF correctness or external loader equivalence. |
| `binaryValidTrace_implies_valid_trace` | A binary-valid predicate implies the abstract valid trace predicate. | Derivation of binary transition witnesses for arbitrary firmware. |
| `singleCycleALUStep_refines_step` | Functional Lean ALU subset agrees with Lean `step` under preconditions. | RTL, gate-level, timing, or silicon refinement. |
| `verify_elf.lean` runtime invocation | One concrete ELF parses, loads, fetches, decodes, and takes one modeled step; selected separate checks pass. | A universal theorem, complete program trace, Rust differential proof, or physical execution. |

### 7.1 Axiom and placeholder policy

The current source scans find no Lean `sorry`, `admit`, or project-defined
`axiom` declarations. This describes the scanned Lean source, not all
dependencies or the complete trusted base.

Direct `#print axioms` output reported:

```text
ZkRV32I.Refinement.master_end_to_end_refinement
  depends on axioms: [propext, Quot.sound]

ZkRV32I.Refinement.rust_to_rv32i_refinement
  depends on axioms: [propext, Quot.sound]

ZkRV32I.Hardware.singleCycleALUStep_refines_step
  depends on axioms: [propext, Quot.sound]

ZkRV32I.Binary.loadSegment_success_has_bounded_addresses
  depends on axioms: [propext]
```

These are Lean foundational axioms. The accurate statement is that there are
no project-defined axioms in scanned source, while some theorem dependencies
include foundational axioms. The theorem prover/kernel and its implementation
remain part of the trusted proof-checking base.

### 7.2 Static and dynamic checks

The repository scripts check source spelling patterns for `sorry`, `admit`,
axiom declarations, unsafe constructs, allocation API names, and selected
instruction case names. Such scans are useful regression guards but are not
semantic verification. The adversarial harness has a finite corpus and
hand-written mutation checks; it provides selected finite testing, not a
universal proof or broad property-based coverage.

## 8. Security, verification, and grant claims matrix

| Topic | Defensible current claim | Research gap before a stronger claim |
|---|---|---|
| Machine-checked proofs | Lean checks the declarations and theorem proofs in the built modules. | Independently state and validate the complete ISA/ABI specification and trusted base. |
| Placeholder discipline | Current scripts find no `sorry`/`admit`; source scan finds no project axiom command. | Audit imports, generated code, scripts, and CI reproducibility beyond text scans. |
| Rust safety policy | Core source includes `no_std` and `forbid(unsafe_code)`; checks pass for the RISC-V target. | Prove semantics of dependencies and Rust implementation; verify compiled result or use a verified compiler. |
| ELF processing | A selected ELF32 subset is parsed; loader bounds are checked; concrete fixture passes runtime validation. | Complete format profile and parser soundness/completeness, overlap and permissions policy, producer-loader correspondence. |
| Execution | One modeled instruction at the fixture entry succeeds. | Multi-step binary trace proof, loop/fault/termination handling, and artifact-specific semantic correspondence. |
| Hardware | A pure Lean ALU subset equals the Lean instruction semantics. | A named RTL target, cycle semantics, state relation, and RTL-to-ISA refinement proof. |
| Cryptographic/ZK use | Repository contains illustrative constraint predicates. | Sound constraints, proof system, verifier correctness, zero-knowledge and cryptographic assumptions. |
| Institutional readiness | The source and proof boundaries can be evaluated and extended. | No certification or seL4/CompCert-equivalent assurance case is claimed. |

This matrix is intended to support technically informed research evaluation,
not to certify grant eligibility, security, production readiness, or
equivalence to another project.

## 9. Trusted computing base and assumptions

The theorem results are checked by Lean under its type theory and reported
axioms. The external environment includes the Lean kernel/toolchain used to
build and check the project. Runtime ELF parsing additionally depends on the
host filesystem and Lean IO delivering the bytes passed to the parser.

The firmware artifact is produced by `rustc`/LLVM and the target linker
according to repository configuration. No project theorem proves those
transformations correct. The hardware target is unspecified because no
concrete external RTL implementation is part of the current refinement proof.
Any future end-to-end theorem must state which of these components are proved,
assumed, or validated by testing.

## 10. Reproduction

With the pinned toolchains and target support, from the repository root:

```sh
lake build
cargo check --locked --manifest-path rust/Cargo.toml \
  --target riscv32i-unknown-none-elf
cargo build --locked --manifest-path rust/Cargo.toml \
  --release --bin firmware --target riscv32i-unknown-none-elf
lake env lean --run scripts/verify_elf.lean \
  target/riscv32i-unknown-none-elf/release/firmware
```

The latest recorded runtime result in this workspace was:

```text
Parsed, loaded, fetched, decoded, and executed ELF entry 0x2147483648;
next PC is 0x2147483652.
Model edge cases passed: ADDI register wraparound, unaligned and overflowing
memory ranges, ECALL halt behavior, and MAX_TRACE boundary.
```

These outputs are environment-specific test evidence. They are not a durable
build attestation unless captured together with source revision, binary hash,
tool versions, and build configuration. Rust unit tests require a supported
host target and linker; the bare-metal target check is not itself a test run.

## 11. Development roadmap

### Work package A — Specification closure

State the exact RV32I profile, supported encodings, fault policy, and ELF
profile. Prove decoder and parser properties against those specifications,
including invalid-input classifications and segment interaction.

### Work package B — Binary trace refinement

Define a trace carrying binary words, fetch addresses, decode outcomes, and
successor states. Prove induction from loaded-memory invariants to each
transition. Relate this trace to `Trace.valid_trace` without assuming its
transition witnesses in the theorem premise.

### Work package C — Source-to-binary validation

Select an actual compiler IR and supported language subset, define its
operational semantics, and verify a translation validator over emitted
machine code. A theorem must identify exactly which compiler stages are
covered, what is trusted, and how source faults/undefined behavior are
represented. A Lean model of a Rust-shaped step alone does not discharge this
work package.

### Work package D — RTL refinement

Choose a named RTL core and revision. Formalize clocked transition behavior,
reset, memory protocol, interrupts/exceptions, and architectural observation.
Prove a simulation/refinement theorem with stuttering or cycle correspondence
as needed. The current functional ALU model is only a starting abstraction.

### Work package E — Constraint and cryptographic soundness

Replace placeholder-like encoding with a complete state/transition encoding.
Prove the algebraic relation sound and complete for the intended trace model,
then separately state and justify the proof system's cryptographic
assumptions.

The work packages are future research proposals. Completion should be
reported theorem-by-theorem with reproducible source, exact assumptions, and
axiom audit output.

## 12. Conclusion

The current repository combines a compilable Lean RV32I model, finite-memory
and model-step correspondence results, a subset ELF32 loader with bounds
lemmas, a runtime one-step firmware check, and a functional Lean ALU
refinement. Its principal value is as a transparent base for investigating
proof boundaries and designing stronger translation, binary-trace, and
hardware-refinement obligations.

It does not establish verified compilation, full ELF execution refinement,
RTL correctness, physical-silicon invariance, or ZK soundness. Those are
distinct research efforts that require explicit source/compiler/RTL targets
and additional definitions, proofs, and validation.
