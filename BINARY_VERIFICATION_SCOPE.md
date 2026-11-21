# Binary Verification Scope

## Scope in force

The maintained implementation has evidence at these levels:

1. Lean ELF32 parsing/loading for the bounded transcript profile;
2. pairwise-disjoint `PT_LOAD` loading and 64 KiB window geometry;
3. Lean fetch, decode, `Machine.step`, and `BinaryTrace` composition;
4. transcript v2 checking for each recorded state transition;
5. finite Rust memory/step refinement for modeled states;
6. Rust host execution and mutation testing.

The general ELF classifier and its narrow single-segment accepted profile
remain distinct from the transcript profile.

## ELF profile

The transcript profile accepts bounded ELF images when all of the following
hold:

- ELF32 little-endian, version 1, RISC-V executable metadata;
- at least one `PT_LOAD`;
- parsed segment file ranges fit and `p_filesz <= p_memsz`;
- loadable ranges do not overlap;
- all loadable ranges fit the 64 KiB window rooted at the minimum loadable
  virtual address;
- the ELF entry is aligned and lies inside an executable `PT_LOAD` 4-byte
  fetch range;
- loading succeeds.

Non-loadable headers are ignored after parsing. This is not a complete ELF ABI
parser.

## Transcript profile

Transcript v2 is accepted only if:

- the ELF bytes match;
- the ELF size is at most 1 MiB;
- the recorded step count is at most 256;
- the initial snapshot exactly matches Lean's loaded initial state;
- every row matches the current PC, raw word, decoded operands, successful
  `Machine.step`, and next snapshot;
- the stop record matches the final Lean state.

An accepted halt has a terminal halted state. An accepted fuel-limit stop
requires an equal `steps` and `limit` value, a bound of 256, and a running
state. An accepted fault stop is matched to the modeled fetch, decode, or
step fault.

## Refinement

[Step.lean](formal/ZkRV32I/Refinement/Step.lean) proves alignment-gated
correspondence between `rustFiniteStepSpec` and Lean `step`. The transcript
module converts each verified state to a finite Rust memory view and uses that
correspondence for every row.

This is a Lean model-to-model bridge. It is not extraction of
`rust/src/lib.rs`, a compiler proof, or machine-code proof.

## Open scope

The project does not prove arbitrary ELF execution, general RV32I conformance,
arbitrary-length control flow, arbitrary memory programs, compiler/linker
correctness, hardware equivalence, or ZK proof-system correctness.
