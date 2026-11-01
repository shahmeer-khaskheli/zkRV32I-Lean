# zkRV32I-Lean: Machine-Checked RV32I Binary Execution and Constraint Correspondence

## Abstract

`zkRV32I-Lean` is a Lean 4 formalization connecting an ELF32 loading profile,
an RV32I machine-state model, dynamic instruction fetch and decoding, bounded
CFG traces, and constraint-row predicates suitable for AIR/R1CS-oriented
development. The implementation models machine transitions as total or
explicitly partial Lean functions, carries fetch and decode witnesses into
binary transitions, and projects satisfied constraint traces into the shared
bounded CFG relation. These results are useful for establishing correspondence
among the repository's specifications. They do not by themselves establish
correctness of an external compiler, linker, cryptographic proof system,
physical processor, or RTL implementation.

## Introduction

A binary verification pipeline is difficult to inspect if its stages share
different state representations. The project therefore uses the Lean state
types as the semantic boundary:

1. an image is loaded into `Memory`;
2. the loader constructs a `MachineState`;
3. an instruction word is fetched from memory;
4. the word is decoded with the Lean ISA decoder;
5. `step` produces an optional successor state;
6. adjacent states are represented by a `binaryTransition` witness;
7. constraint rows reproduce fetch, decode, and step; and
8. satisfied rows project to a bounded CFG trace.

The central invariant is that proofs refer directly to the definitions that
execute or describe each stage. The Lean kernel checks every theorem application
after elaboration.

## Threat Model and Security Guarantees

The formal threat model covers malformed transition witnesses, memory accesses
outside represented bounds, misaligned control targets, decoder mismatch,
missing loader evidence, and constraint rows that claim a transition without
fetch, decode, and step witnesses.

Guarantees supplied by Lean proofs are:

- loader acceptance contains alignment, size, address, overlap, entry
  fetchability, and successful-load evidence;
- successful machine steps include the successor demanded by `step`;
- dynamic binary transitions require a concrete fetched word and decode result;
- possible successors contain the PC of every successful modeled step;
- constraint satisfaction implies a binary transition; and
- every binary transition can be represented as constraint-row evidence.

Out of scope are:

- memory safety of an external ELF file parser not represented by the Lean
  profile;
- hostile proof-system prover behavior independent of Lean constraint
  soundness;
- compiler-generated machine code correctness;
- timing side channels and microarchitectural behavior;
- hardware memory models, caches, buses, and faults not represented in
  `Machine.lean`; and
- complete cryptographic assurance of AIR/R1CS commitment, arithmetization,
  public-input binding, or verification.

## The Lean 4 Kernel as the Root of Truth

The source policy requires no proof placeholders. It rejects syntactic uses of
`sorry` and `admit` and rejects source declarations beginning with `axiom`.
Policy scripts supplement `lake build`; they do not replace kernel checking.

Let \(\Gamma\) denote the repository module environment and
\(\vdash_{\mathrm{Lean}} T : P\) denote kernel acceptance of term \(T\) for
proposition \(P\). The relevant claim is that:

\[
\Gamma,\texttt{ElfLoadableImage}(L)
\vdash_{\mathrm{Lean}}
\texttt{elf\_initial\_state\_correct}(L)
\]

and similarly:

\[
\Gamma \vdash_{\mathrm{Lean}}
\texttt{constraints\_sound} : 
\forall b,a,\texttt{ConstraintTransition}(b,a)
\rightarrow
\texttt{binaryTransition}(b.toMachineState,a.toMachineState)
\]

Lean kernel dependencies remain part of the trust base. Source-policy
checks do not claim that all reasoning is independent of classical logic,
definitional equalities, quotient soundness, or implementation details of the
Lean kernel.

## RV32I State and Machine Semantics

The architecture state is:

\[
\sigma=(pc,\rho,\mu,\tau)
\]

where \(pc\in\mathsf{Word32}\), \(\rho\) is a finite register file indexed by
\(\{0,\ldots,31\}\), \(\mu:\mathbb{N}\rightarrow\mathsf{UInt8}\) is the
repository's total memory function model, and \(\tau\) is running or halted.

Register zero is invariant:

\[
\rho_0=0
\]

`MachineState` and `RegisterFile` in Lean encode these fields directly.
`regRead` treats index zero specially, and `regWrite` leaves zero unchanged.

`step` maps a state and instruction to `Option MachineState`. Its partiality is
observable: memory faults, alignment failures, and terminal-state guards can
return `none`.

The bounded trace relation uses:

\[
\texttt{MAX\_TRACE}=2^{20}
\]

\[
\texttt{length}(T)\leq 2^{20}
\]

\[
\forall i<\texttt{length}(T)-1,\ 
\texttt{binaryTransition}(T_i,T_{i+1})
\]

The bound does not prove termination. It restricts the represented trace prefix
used for CFG and model-checking operations.

## Binary-Level Semantics and Decoding

`binaryTransition` includes the fetched 32-bit instruction word:

\[
\exists w,i.\ 
\texttt{fetch32}(\mu,pc)=\texttt{some}(w)
\land
\texttt{decodeBitVec32}(w)=\texttt{ok}(i)
\land
\texttt{step}(s,i)=\texttt{some}(s')
\]

Consequently, a binary transition differs from a bare `valid_transition`.
It establishes the disk/model memory fetch, raw-word decoder result, and
machine successor.

`DynamicStepWitness` and `BinaryTransition` evidence retain every proof
component. CFG successor computation mirrors `step` for branches, JAL, JALR,
sequential flow, memory operations, and terminal states:

\[
\texttt{step}(s,i)=\texttt{some}(s')
\Rightarrow
s'.pc\in\texttt{possibleSuccessors}(s,i)
\]

The alignment rule is part of the modeled destination and successor relation.
No separate alignment convention is introduced after successful transition
construction.

## The Zero-Assumption ELF Bridge

The loader specification is represented by an image plus an explicit entry and
initial memory. `ElfLoadableImage` extends `ElfLoadSpec` with evidence:

\[
entryPC\bmod 4=0
\]

\[
entryPC<2^{32}
\]

\[
\forall p\in PT,\ 
\operatorname{Loadable}(p)\Rightarrow
\operatorname{FileBounded}(p)\land
\operatorname{MemoryBounded}(p)\land
\operatorname{Disjoint}(p,\text{other loadable segments})
\]

`loadMemory` must return `some loadedMemory`; then:

\[
\texttt{elfToInitialMachineState}(L)
=
\texttt{some}
\begin{pmatrix}
pc=entryPC\\
regs=\texttt{RegisterFile.zeroed}\\
memory=loadedMemory\\
terminal=\texttt{running}
\end{pmatrix}
\]

The conditions live in data and proofs, not comments. A segment outside the
configured memory, a 32-bit overflow, an overlapping loadable segment, an
unaligned entry, or a failed load cannot produce a `ElfLoadableImage`.

## AIR/R1CS Constraint Systems

The constraint model uses:

\[
R_i=(pc_i,\rho_i,\mu_i,i_i,w_i,\tau_i)
\]

and a transition predicate:

\[
\operatorname{CT}(R_i,R_{i+1}) =
\operatorname{fetch32}(\mu_i,pc_i)=\operatorname{some}(w_i)
\land
\operatorname{decode}(w_i)=\operatorname{ok}(i_i)
\land
\operatorname{step}((pc_i,\rho_i,\mu_i,\tau_i),i_i)
=\operatorname{some}(R_{i+1}^{state})
\]

Soundness is proved as:

\[
\operatorname{CT}(b,a)\rightarrow
\texttt{binaryTransition}(b^{state},a^{state})
\]

Completeness is proved in the reverse direction:

\[
\texttt{binaryTransition}(s,s')
\rightarrow
\exists b,a.\operatorname{CT}(b,a)
\land b^{state}=s\land a^{state}=s'
\]

For a row array \(R_0,\ldots,R_n\):

\[
\forall i<n,\operatorname{CT}(R_i,R_{i+1})
\rightarrow
\texttt{BoundedCFGTrace}(R_0,\ldots,R_n)
\]

The current `AlgebraicGate` predicates cover add and multiply gate equations,
but they are separate illustrative circuit elements. The repository does not
yet claim arithmetization completeness for all machine operations, a concrete
AIR schedule, a concrete R1CS incidence matrix, a commitment scheme, a prover,
a verifier, or zero-knowledge properties.

## Bounded Verification and Compilation Gap

Lean definitions prevent a proof of arithmetic semantics from silently
depending on a second implementation if theorem statements reference the first
implementation directly. A binary trace, constraint trace, or CFG row is still
bounded:

\[
0<n\leq 2^{20}
\]

The bound is part of the trace relation, not a timeout approximation.
However, bounded success must be distinguished from whole-program termination.
An infinite execution remains an infinite family of reachable states; it is not
made finite by proving one bounded prefix.

## Conclusion

The implemented verification chain gives kernel-checked correspondence between
the ELF-load evidence, initial machine state, dynamic binary witness, bounded
CFG graph, and constraint-row transition. The repository therefore has a
complete architectural correspondence inside its declared Lean model.

Production end-to-end verification would additionally require:

1. a complete ELF profile and parser-completeness proof;
2. an ISA conformance matrix covering every accepted opcode and reserved form;
3. a concrete production constraint encoding for every row field and transition;
4. cryptographic protocol soundness and public-input binding; and
5. independent compiler, linker, RTL, and execution-environment refinements.
