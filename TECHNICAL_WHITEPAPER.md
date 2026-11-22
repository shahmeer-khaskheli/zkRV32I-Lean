# Technical Whitepaper

## Abstract

zkRV32I-Lean is a work-in-progress system for formal RV32I modeling,
bounded ELF loading, execution transcripts, and Lean-to-Lean refinement.
The strongest verified chain in the repository is a bounded transcript chain:

```text
bounded ELF
  -> loaded memory
  -> checked PC/word/decode/step/snapshot rows
  -> BinaryTrace, valid_trace, or verified stop prefix
```

## Formal evidence

Lean proves segment geometry and pairwise-disjoint write commutativity.
The transcript checker verifies initial state and every row. Stop-reason
definitions distinguish halt, fuel limit, and fault. `accepted_halt_stop`
theorems connect an accepted halt to the terminal state of the corresponding
binary trace model.

## Refinement evidence

`RustFiniteState` and `RustMemory` provide finite modeled Rust views.
`master_end_to_end_refinement` connects finite Rust step specifications to Lean
`step`. Transcript row proofs apply this correspondence under aligned PC
premises.

This is not an extraction proof for Rust source.

## Excluded work

The repository does not yet establish compiler correctness, complete ELF ABI
loading, arbitrary RV32I conformance, hardware equivalence, production
constraints, cryptographic proofs, or external verifier acceptance.
