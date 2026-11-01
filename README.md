# zkRV32I-Lean

`zkRV32I-Lean` is a machine-checked Lean 4 verification workbench for a
bounded RV32I execution model, ELF32 loading, binary fetch/decode transitions,
CFG reachability, and constraint-trace correspondence.

The repository distinguishes executable formal specifications from runtime
checks and external implementations. A theorem in Lean applies to the
definitions named by that theorem; it does not, by itself, prove compiler,
linker, cryptographic, RTL, or physical-hardware properties.

## Overview

The current implementation provides:

- A Lean RV32I instruction syntax, decoder, and partial machine transition.
- A bounded machine state containing PC, register file, memory, and terminal
  state.
- ELF32 parsing, segment loading, four-byte fetch, dynamic decoding, and
  binary-transition witnesses.
- Static and dynamic successor computation and bounded CFG traces.
- Constraint rows, fetch/decode/step transition predicates, soundness and
  completeness lemmas, and projection to `BoundedCFGTrace`.
- Kernel-checkable loader invariants for entry alignment, RV32 bounds, segment
  bounds, and pairwise segment overlap rejection.
- Lean proofs for successful trace extensions, selected concrete program
  classes, and constraint trace correspondence.

## Core Architectural Highlights

```text
ELF32 file image
      |
      | parseELF32
      v
ElfLoadSpec + ElfLoadableImage
      |
      | elfToInitialMachineState
      v
MachineState { pc, regs, memory, terminal=running }
      |
      | fetch32 -> decodeBitVec32 -> step
      v
DynamicStepWitness / binaryTransition
      |
      | adjacent binary transitions
      v
BoundedCFGTrace or valid Trace (length <= 2^20)
      |
      | ConstraintRow / ConstraintTransition
      v
AIR/R1CS-style constraint predicates
```

The principal correspondence is established by definitions and propositions:

```text
ElfLoadableImage
  -> elf_initial_state_correct
  -> MachineState.initial(entryPC, loadedMemory)

binaryTransition(before, after)
  <-> fetch32
      /\ decode
      /\ step(before, instruction) = some(after)

ConstraintTransition(beforeRow, afterRow)
  -> binaryTransition(rowBefore.toMachineState, rowAfter.toMachineState)

binaryTransition(before, after)
  -> assignment satisfying ConstraintTransition(beforeRow, afterRow)

satisfied ConstraintTraceRows
  -> BoundedCFGTrace
```

`ConstraintRow` contains PC, register file, memory, instruction, raw instruction
word, and terminal state. The transition predicate checks fetch, decoding, and
the Lean machine `step`. This is not a production cryptographic AIR or R1CS
implementation.

## Directory Structure

```text
formal/
  ZkRV32I.lean                 Root umbrella module and exports
  ZkRV32I/Base.lean            Word32 and register/memory primitives
  ZkRV32I/ISA.lean             RV32I syntax, decoder, and instruction dispatch
  ZkRV32I/Machine.lean         MachineState and architectural step semantics
  ZkRV32I/Trace.lean           Bounded traces and valid-transition relations
  ZkRV32I/Binary.lean          ELF bridge, dynamic decoder, CFG, and binary traces
  ZkRV32I/Circuit/             Algebraic gate and constraint predicates
  ZkRV32I/Refinement/          Lean memory and Rust-shaped refinement models
scripts/                       Policy scans and ELF verification
docs/                          Installation and formal verification documentation
.github/workflows/verify.yml   Reproducible verification CI
rust/                          Optional no_std Rust reference implementation
```

See [docs/END_TO_END_VERIFICATION_AUDIT.md](docs/END_TO_END_VERIFICATION_AUDIT.md)
for the exact theorem inventory, trust boundaries, and remaining obligations.

## Verification Guarantees

The Lean source is checked by a pinned Lean 4 toolchain. Repository policy scans
reject source occurrences of `sorry` and `admit`. The axiom policy rejects
project-defined `axiom` declarations and reports the theorem dependencies used
by its sampled refinement theorem.

Established guarantees are limited to:

- Deterministic machine transitions under the definitions in `Machine.lean`.
- The declared ELF loader invariants and successful state initialization.
- Dynamic fetch/decode/step witnesses for supported instructions.
- Explicit CFG successor soundness and bounded CFG projection.
- Fetch/decode/step constraint-row soundness and transition completeness.
- Constraint traces implying bounded architectural CFG paths.

They do not by themselves claim complete RISC-V conformance, complete ELF ABI
validation, cryptographic proof-system soundness, RTL equivalence, compiler
correctness, or Rust binary correctness.

## Quick Start

Requirements:

- Linux, macOS, or Windows
- Git
- Bash-compatible shell for repository policy scripts
- Lean 4 v4.19.0 and Lake, supplied by the repository toolchain or an
  equivalent installation

```sh
git clone https://github.com/shahmeer-khaskheli/zkRV32I-Lean.git
cd zkRV32I-Lean
lake build
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
bash scripts/verify_all.sh
```

For exact platform setup, caching, and troubleshooting, see
[docs/INSTALLATION.md](docs/INSTALLATION.md).

## License

No `LICENSE` file is currently present in the repository. No license terms are
granted by this README alone; downstream reuse requires an explicit license or
permission from the repository owner.
