# End-to-End Formal Verification Audit

## Scope and certification claim

This report audits the executable Lean development under `formal/ZkRV32I/`.
It certifies the stated disk-to-circuit correspondence inside the repository:

```text
validated ELF image and load witnesses
  -> certified initial MachineState
  -> binary fetch/decode/step transition
  -> bounded CFG trace
  -> constraint rows and constraint satisfaction
  -> architectural CFG projection
```

The certification applies to the exact Lean definitions and theorems below.
It is not a claim of RISC-V compatibility beyond the implemented decoder,
complete ELF ABI conformance, cryptographic proof-system security, RTL
equivalence, linker correctness, compiler correctness, or executable Rust
program correctness.

## Kernel root of truth

Lean 4 performs elaboration and type checking before accepting theorem terms.
All repository proofs reduce to kernel-checked propositions over the machine,
trace, and constraint definitions. No proof step may substitute an external
runtime result for a missing theorem.

Policy validation uses:

```sh
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
lake build
```

The source scans reject `sorry` and `admit`; the axiom scan rejects
project-defined axiom declarations. The checked theorem dependency scan is an
additional policy check, not a proof that the Lean kernel or its foundations
are free from all axioms.

## ELF-to-state bridge

`ELF32Header`, `ELF32ProgramHeader`, and `ELF32Image` define the parsed
representation. `parseELF32` constructs an image only after the selected header,
program-header, file-bound, and segment-size checks succeed.

The loader bridge is defined in `Binary.lean`:

- `ElfLoadSpec` links an image, entry PC, and initial memory.
- `elfFileOffsetAddress` defines the file-offset-to-address relation.
- `elfLoadableSegmentBoundsHold` checks file bounds, file-size/memory-size
  relation, RV32 address overflow, initial-memory containment, and memory
  size containment for a loadable segment.
- `elfLoadableSegmentsBounded` checks all segments.
- `elfMemoryRangesDisjoint` and `elfLoadableSegmentsDisjoint` reject loadable
  segments whose memory ranges overlap.
- `ElfLoadableImage` carries entry alignment, RV32 entry bounds, bounded
  segments, disjoint segments, successful image loading, and entry fetchability
  as fields of evidence.
- `elfToInitialMachineState` deterministically constructs
  `MachineState.initial loadable.entryPC loadable.loadedMemory`.
- `elf_initial_state_correct` proves the exact result has entry PC, zeroed
  register file, loaded memory, and `.running` terminal state.

This is a zero-assumption bridge in the strict formal sense used by Lean: the
mapping receives a `ElfLoadableImage` whose fields are already the proofs of its
required conditions. Runtime option failure remains explicit through
`image.loadMemory = some loadedMemory`.

Remaining loader scope is documented rather than silently assumed. The parser
does not implement every ELF ABI field, permission rule, dynamic loading rule,
relocation rule, overlap policy derived from page semantics, or platform ABI.

## ISA and machine semantics

`Machine.lean` defines the architectural state:

\[
\texttt{MachineState} =
(pc, regs, memory, terminal)
\]

`RegisterFile.zeroed` initializes every register to zero. Writes to register
zero leave the file unchanged, so the invariant \(x_0 = 0\) is available to
machine and trace proofs.

`Machine.lean` defines partial `step` semantics. `Option` encodes execution
failure, memory fault, alignment rejection, or absence of a successor under the
modeled conditions. Fetch, decode, and execute do not fall back to default
success paths.

`ISA.lean` defines the instruction constructors, immediate operations, and
decode function. `decodeBitVec32` converts a fetched `BitVec 32` to an ISA
word and delegates decoding to this same definition.

## Dynamic decoder and CFG

`binaryTransition` is defined by an existential dynamic witness:

\[
\operatorname{binaryTransition}(s,s') =
\exists w,i.\ 
\operatorname{fetch32}(s.memory,s.pc)=\operatorname{some}w
\land
\operatorname{decode}(w)=\operatorname{ok}i
\land
\operatorname{step}(s,i)=\operatorname{some}s'
\]

The witness is not reconstructed by instruction-name literals. It retains the
raw word, constructor, fetch proof, decode proof, and successful step proof.

`possibleSuccessors s instruction` explicitly handles branches, JAL, JALR,
memory operations, halted states, ECALL/EBREAK, and sequential successors.
`successful_step_pc_is_possible_successor` proves:

\[
\operatorname{step}(s,i)=\operatorname{some}s'
\Rightarrow
s'.pc \in \operatorname{possibleSuccessors}(s,i)
\]

The proof closes all retained architectural constructor cases and depends on
the same aligned-control-transfer and record-PC definitions used by `step`.

`BoundedCFGTrace` combines a `Trace` of at most `MAX_TRACE = 2^20` rows with
an adjacent `binaryTransition` proof for every row pair. Thus the transition
relation and the bounded graph are identical at the proof boundary.

## Constraint soundness and completeness

`ConstraintRow` contains:

- PC;
- register file;
- memory;
- selected instruction;
- raw instruction word; and
- terminal state.

`ConstraintTransition before after` requires:

1. successful fetch from the row's machine memory and PC;
2. decoding the row's instruction word to the row's instruction; and
3. successful Lean `step` from `before.toMachineState` to
   `after.toMachineState`.

`constraints_sound` proves that a satisfying constraint pair yields
`binaryTransition`. No field-similarity relation is used as a substitute for
these three executable witnesses.

`binaryTransition_complete` constructs explicit before and after rows for
every witnessed binary transition. The constructor evidence supplies exactly
the fetch, decode, and step propositions required by `ConstraintTransition`.

`ConstraintTraceRows.satisfied` requires `ConstraintTransition` between every
adjacent row pair. `ConstraintTraceRows.toTrace` converts the row array to the
shared `Trace` representation. `ConstraintTraceRows.toBoundedCFGTrace` uses
`constraints_sound` to construct all binary transitions.

`constraint_trace_implies_cfg_trace` establishes that a satisfied bounded
constraint trace has an equivalent `BoundedCFGTrace`.

## Mathematical verification chain

For a valid loaded image \(E\), loader evidence \(L\), a valid instruction
word, and constraint trace \(C\):

\[
\operatorname{ElfLoadableImage}(E,L)
\Rightarrow
\operatorname{elfToInitialMachineState}(L)
=
\operatorname{some}(pc,\texttt{zeroed},memory,\texttt{running})
\]

\[
C \models \texttt{ConstraintTransition}(R_i,R_{i+1})
\Rightarrow
\texttt{binaryTransition}(R_i,R_{i+1})
\]

\[
C \models \texttt{ConstraintTransition}(R_i,R_{i+1}),\ 0\leq i<n
\Rightarrow
\texttt{BoundedCFGTrace}(R_0,\ldots,R_n)
\]

The corresponding existence direction is:

\[
\texttt{binaryTransition}(S_i,S_{i+1})
\Rightarrow
\exists R_i,R_{i+1}.\texttt{ConstraintTransition}(R_i,R_{i+1})
\]

## Build and policy certification

The repository is pinned to Lean 4.19.0 in `lean-toolchain`. On a configured
environment, the final command is:

```sh
lake build
```

Policy scripts search Lean source outside `.lake` and reject placeholders:

- `check_no_sorry.sh`;
- `check_no_admit.sh`; and
- `check_axiom_policy.sh`.

CI must execute these commands after checkout and toolchain installation.

## Scope and nonclaims

The constraint module proves correspondence between Lean constraint-row
propositions and Lean binary transitions. It does not prove that finite-field
polynomials, lookup gates, a real ZK proof system, or a production verifier are
equivalent to these propositions. Algebraic gate support remains separate and
must be enlarged and cryptographically analyzed before such a claim is valid.

The current ELF parser and loader implement a selected ELF32 profile. The
current decoder/CFG work does not convert those conclusions into universal
conformance for every RV32I implementation, every malformed binary, every
operating-system ABI, or every compiler-generated binary until the explicit
profiles are exhausted and proven complete.
