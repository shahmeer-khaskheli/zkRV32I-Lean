# Binary Trace Scope

## Machine-checked additions

`LoadedELFImage` packages an ELF image, an initial memory, a successful `loadMemory` result, an executable entry-segment witness, and explicit entry alignment/fetchability proofs. Successful segment-list and image loads preserve memory base and size. From the entry invariants, `LoadedELFImage.entry_fetch32_isSome` proves that entry fetch succeeds, and `LoadedELFImage.entry_fetchDecode_isSome` proves fetch/decode returns a present `Except` result. That result may be a controlled `DecodeError`.

`binaryStep_success_has_fetch_decode_step_witness` exposes the fetched word, successful decode, and exact ISA `step` successor for every successful `binaryStep`. `binaryStep_eq_isaStep_of_fetch_decode` proves the converse composition from those three witnesses.

`BinaryTrace` carries a bounded `Trace`, a word and decoded instruction for every outgoing edge, and an initial state equal to the loaded image's entry state. Its projection theorems establish `valid_trace` and `binaryValidTrace`; its length is between 1 and `MAX_TRACE`.

`SuccessfulBinaryExecution` is a restricted construction premise: the caller supplies the bounded state trace, proves its first row is the loaded image's initial entry state, proves every outgoing PC lies in an executable PT_LOAD range, and supplies a successful binary-step witness for every adjacent row. `ofBinarySteps` derives the word/decode/ISA-step data from successful `binaryStep` results. `toBinaryTrace` constructs the corresponding `BinaryTrace`, which projects to `valid_trace`.

## Restricted Entry-Step Construction

`LoadedELFImage.HasSuccessfulEntryStep` states that the loaded entry word fetches, decodes to an instruction, that instruction has a successful ISA `step` from the initialized entry state, and the successor PC lies in an executable PT_LOAD range. `LoadedELFImage.hasSuccessfulEntryStep_constructs_execution` proves that this condition yields a `SuccessfulBinaryExecution` with exactly two states and whose converted `BinaryTrace` projects to `valid_trace`. The concrete `SuccessfulEntryStep` witness and `toSuccessfulBinaryExecution` definition make the construction explicit.

`SuccessfulEntryExtension entryStep` adds a second fetch/decode/ISA-step witness from the first successor state and requires the second successor PC to remain executable. Its successful `fetch32` premise is inverted by `fetch32_success_implies_aligned_and_valid`, proving the current PC is four-byte aligned and its four-byte memory range is valid. The decoded instruction must be `.ok`, and the ISA `step` must return the supplied next state. `SuccessfulEntryExtension.constructs_execution` then yields a `SuccessfulBinaryExecution` with exactly three states and two certified transitions. The result converts to `BinaryTrace`, `valid_trace`, and `binaryValidTrace`. No claim is made that later steps will succeed.

## General One-Step Extension

`SuccessfulExecutionExtension execution` applies to any existing `SuccessfulBinaryExecution`. It requires remaining trace capacity (`stateTrace.length < MAX_TRACE`), an executable final PC, a fetched word, a successful decode, a successful ISA `step` from the exact final state, and an executable successor PC. The successful fetch separately proves four-byte alignment and a valid four-byte memory range. `SuccessfulBinaryExecution.extend` appends one state; `extend_preserves_prior_states` proves every pre-existing row is unchanged. The constructor re-establishes the prior binary-step edges and records the new fetch/decode/step witness. Its length theorem establishes `old length + 1`; the result projects to both `valid_trace` and `binaryValidTrace`. The earlier entry-specific `SuccessfulEntryExtension` adapts to this generic extension, so its two-transition construction is an instance of the reusable operation.

`SuccessfulExecutionPlan` packages any existing successful execution with an extension provider for every same-image successful execution whose length is below `MAX_TRACE`. Its structural `iterate` applies `SuccessfulBinaryExecution.extend` repeatedly, maintaining exact length and image identity. `toLength` constructs any requested length between the initial execution's length and `MAX_TRACE`; the result has exactly that length and projects to `valid_trace` and `binaryValidTrace`. An existing one- or two-transition entry construction can serve as the plan's initial execution. The per-execution extension provider remains an explicit premise: the induction does not find instructions or successful successors on its own.

## Concrete Entry Self-Loop Class

`LoadedELFImage.EntryJalLoop` requires the loaded entry fetch to produce a word that the model decoder accepts as `jal x0, 0`. Under this restriction, `SuccessfulBinaryExecution.entryJalLoop_rows` proves every state in any successful execution for that image equals the initialized entry state: the decoded jump writes x0, leaves memory and terminal state unchanged, and returns PC to the entry. This invariant constructs the extension provider for every same-image execution below `MAX_TRACE`.

`LoadedELFImage.entryJalLoop_plan_constructs_length` and `LoadedELFImage.entryJalLoop_plan_constructs_binaryValidTrace` therefore construct a successful execution and binary-valid trace for any requested length from 2 through `MAX_TRACE`, assuming `EntryJalLoop`. The execution's trace rows and every transition are machine-checked against the loaded memory's fetch/decode and the ISA `step`; the theorem does not prove that the ELF parser or loader will produce an image satisfying this restriction.

## Concrete Register-Setting Loop Class

`LoadedELFImage.EntryAddiJalLoop` is a second, strictly richer restriction. It requires the loaded entry word to fetch/decode as `addi x1, x0, 1`, the next PC (`entry + 4` in RV32 arithmetic) to be distinct from entry and executable, and its fetched word to decode as `jal x0, 0`. Under this restriction, the entry step sets x1 to 1; every later loop step preserves the state and PC. `SuccessfulBinaryExecution.entryAddiJalLoop_rows` proves every row is either the initial state or that register-setting loop state. This invariant provides an extension witness for every intermediate execution of the same image.

`LoadedELFImage.entryAddiJalLoopPlan_constructs_length` and `...constructs_binaryValidTrace` therefore establish a valid binary execution at any requested length from 2 through `MAX_TRACE`. The restriction records fetch and decode witnesses for the two instruction locations; it does not assert that every ELF has these bytes, nor prove compiler/linker output has this form. This is a straight-line register-setting instruction followed by a self-loop, not general straight-line program verification.

## Not established

The definitions do not prove that parsing/loading an arbitrary ELF yields a `LoadedELFImage` or that it satisfies either concrete program restriction. Automatic long-run construction is proved only for the `jal x0, 0` self-loop class and the `addi x1, x0, 1; jal x0, 0` class. Other images still require explicit per-step extension providers. General extensions require successful fetch/decode/step witnesses, executable current/successor PCs, and remaining `MAX_TRACE` capacity. Termination, arbitrary ELF runs, and faulting-trace coverage remain unproved. The parser is still a project-specific ELF subset, and no compiler, linker, external loader, RTL, or hardware refinement is claimed. The trace is an architectural Lean-model trace, not a physical execution claim.
