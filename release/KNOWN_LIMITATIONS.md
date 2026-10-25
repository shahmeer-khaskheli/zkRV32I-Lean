# Historical Known-Limitations Snapshot

> **Historical snapshot.** This file predates later Rust execution work, the
> linked firmware ELF, and the expanded Lean ELF loader. Some statements below
> are no longer current. For current limitations and exact claims, read
> [README.md](../README.md) and
> [TECHNICAL_WHITEPAPER.md](../TECHNICAL_WHITEPAPER.md).

## ISA and execution

- Rust `step` unconditionally returns `UnsupportedInstruction`. Rust has no
  decoder, interpreter, or RV32I instruction execution.
- Lean has decoder and operational-semantics cases for the RV32I base
  instruction constructors, but there are no instruction-by-instruction
  correctness theorems, conformance suite, or proof that `decode` matches the
  architectural encoding specification for all 32-bit words.
- The Lean decoder's reserved-field validation has not been audited as complete.
- Lean `FENCE` is modelled as a no-op; the model is not a concurrent memory
  model. `ECALL` and `EBREAK` are represented as terminal state changes.
- Rust and Lean memory error reporting differs: Rust returns categorized
  `MemoryError` values; Lean memory and step use `Option`. Rust instruction
  execution does not exist, so load/store instruction fault behavior has no
  cross-language correspondence result.

## Registers, traces, and proofs

- Lean `RegisterFile.x0` is a constant-zero accessor, not a projection from the
  stored `values` function. Its x0 theorems are consequently trivial with
  respect to the underlying stored cell.
- Lean `valid_transition` existentially quantifies an instruction. A trace
  carries only machine-state rows, not instruction witnesses.
- Traces are nonempty prefixes bounded by `MAX_TRACE`; a terminal final row is
  not required.
- The current step and trace theorem set does not prove global ISA
  implementation correctness, decoder correctness, memory refinement, or
  equivalence with Rust.
- Standard Lean axiom dependencies found by `#print axioms` are `propext` and
  `Quot.sound`. No project-defined axioms, `sorry`, or `admit` were found.

## Constraint model

- The selected field is illustrative F₂ represented by `Bool`. The code defines
  operations and proves selected laws, but does not instantiate Lean's `Field`
  typeclass or define a production proof-system field profile.
- The range-check predicate checks only the trace length bound. It does not
  decompose words or prove bit ranges for registers, PCs, addresses, or
  intermediates.
- ALU gates are Boolean add/multiply equations over a separate gate list.
  `encode` supplies an empty gate list; these equations are not linked to ISA
  operands or result columns.
- Branch and memory constraint families alias the semantic transition
  predicate. They are not separate algebraic branch or memory-consistency
  arguments.
- Public inputs bind entry PC, final PC, and trace length. They do not bind
  final registers, memory, commitments, or other outputs.
- Transition constraints directly reuse `valid_transition`, which itself uses
  the Lean `step` relation. This is not a production polynomial AIR/R1CS
  mapping. The completeness result and transition “soundness” result are
  limited to these directly defined Prop predicates.
- No production constraint system, STARK/SNARK, commitment scheme, verifier, or
  cryptographic soundness theorem exists.

## Build, tests, and harness

- The audit host lacks the MSVC linker `link.exe`; `cargo test` for the core and
  `cargo run` for the adversarial binary fail at linking. Rust test cases and
  mutation probes were therefore not run.
- The corpus was run through Lean only. The actual differential comparison
  binary could not execute, so there are no measured Rust/Lean agreements or
  divergences.
- The checked-in policy scripts are stubs that exit zero; they do not perform
  the checks their names imply.
- The Makefile's `differential` and `mutation` targets are still skeleton echo
  targets and do not invoke the adversarial harness.
- Finite corpus cases and mutation tests are not universal proofs and do not
  replace Lean theorems.
