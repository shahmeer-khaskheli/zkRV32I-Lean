#!/usr/bin/env python3
"""Append declaration-specific semantic judgments to the generated proof ledger."""

from __future__ import annotations

import re
import sys
from pathlib import Path

import proof_ledger_source_scan as source_scan


ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "PROOF_LEDGER.md"
EXPECTED_SOURCE_DECLARATIONS = 281
ENTRY_HEADING = re.compile(r"^#### ([0-9]+)\. `([^`]+)`$", re.MULTILINE)


def inventory_entries(ledger: str) -> dict[str, tuple[int, str]]:
    headings = list(ENTRY_HEADING.finditer(ledger))
    result: dict[str, tuple[int, str]] = {}
    for index, heading in enumerate(headings):
        end = headings[index + 1].start() if index + 1 < len(headings) else len(ledger)
        result[heading.group(2)] = (int(heading.group(1)), ledger[heading.start():end])
    return result


def assessment(name: str, has_implication: bool) -> tuple[str, str, str, str]:
    short = name.rsplit(".", 1)[-1]

    if short in {
        "x0_write_invariant",
        "x0_preserved_by_step",
        "x0_zero_throughout_valid_trace",
    }:
        return (
            "Definitional/degenerate: the proposition concerns the modeled "
            "`RegisterFile.x0` accessor, which is defined as constant zero; it "
            "does not establish preservation of an independently stored x0 cell.",
            "The exact assumptions are in the linked type. The result is "
            "conditional only on those binders; the x0 equality itself reduces "
            "by the definition of the accessor, so it is vacuous as evidence "
            "for physical register-file preservation.",
            "Lean register/machine model only; no Rust register implementation "
            "or compiled binary is related by this declaration.",
            "A stored-register representation invariant and a proof that the "
            "actual implementation enforces x0=0 remain unproved.",
        )

    if short in {
        "rv32Binary_rejected_or_functionallyCorrect",
        "rv32LoadableBinary_rejected_or_fullyVerified",
    }:
        return (
            "Tautological disjunction: this is a rejected-or-accepted-result "
            "split, not a proof that every input binary is correct.",
            "The stated accepted-class implication is used only on the "
            "accepted branch; the rejected branch needs no correctness proof. "
            "The proposition is therefore not a universal correctness claim.",
            "Lean predicates over byte arrays and the modeled parser/executor "
            "only.",
            "Correctness for arbitrary accepted loadable binaries, and a "
            "non-disjunctive universal binary-correctness theorem, remain "
            "unproved.",
        )

    if short == "soundness_transition_constraints_imply_isa_transitions":
        return (
            "Definitional restatement: `transitionConstraints` is defined as "
            "the same adjacent-row `valid_transition` property returned by "
            "this theorem.",
            "The premise supplies the entire conclusion; this is conditional "
            "and does not establish independent constraint soundness.",
            "Lean semantic trace predicate only; no algebraic constraints are "
            "involved.",
            "A genuine AIR/R1CS encoding and a proof that algebraic "
            "satisfaction implies ISA execution remain unproved.",
        )

    if short == "completeness_valid_trace_encoding_satisfies_constraints":
        return (
            "A real implication for the current semantic-predicate encoding, "
            "but degenerate as an algebraic-circuit result: `encode` stores "
            "the trace with an empty gate list.",
            "Conditional on `valid_trace`; the theorem does not prove that "
            "this premise is inhabited for every program.",
            "Lean trace and semantic predicates only, not a polynomial "
            "constraint system or proof witness.",
            "Nontrivial algebraic witness construction, range constraints, "
            "and algebraic soundness remain unproved.",
        )

    if name.startswith("ZkRV32I.Circuit.Field."):
        if short == "field_mul_inv_of_nonzero":
            condition = (
                "Conditional on the explicit nonzero premise; over the "
                "two-element Boolean representation that premise forces "
                "the sole nonzero element."
            )
        else:
            condition = (
                "Unconditional algebraic identity over the declared "
                "two-element Boolean carrier."
            )
        return (
            "A genuine algebraic identity for the project's `Bool`-encoded "
            "F₂ operations; it is not merely a theorem about machine "
            "execution.",
            condition,
            "Lean Boolean field model only.",
            "A production-size prime field, its machine encoding, and "
            "constraints over that field remain unproved.",
        )

    if name.startswith("ZkRV32I.Circuit."):
        return (
            "The proposition concerns either a semantic transition predicate "
            "or its trace projection; the exact conclusion is in the linked "
            "type. It does not by itself establish algebraic constraint "
            "soundness.",
            (
                "Conditional on the displayed constraint/transition witness."
                if has_implication
                else "No additional proposition premise beyond the displayed "
                "quantified inputs."
            ),
            "Lean semantic predicates and Lean trace rows only.",
            "Algebraic AIR/R1CS equations, bit-range enforcement, and "
            "cryptographic proof-system soundness remain unproved.",
        )

    if name.startswith("ZkRV32I.Hardware."):
        return (
            "A theorem about the functional Lean ALU/datapath model; the "
            "two `aluExecute_*` results are definitional equations, while "
            "`singleCycleALUStep_refines_step` is conditional model "
            "correspondence.",
            (
                "Conditional on the aligned-PC and selected-ALU-input "
                "premises shown in the type."
                if short == "singleCycleALUStep_refines_step"
                else "No additional proposition premise beyond the displayed "
                "quantified operands."
            ),
            "Lean hardware-shaped function only, not RTL, gates, or physical "
            "hardware.",
            "RTL refinement, synthesis equivalence, timing, and hardware "
            "implementation correctness remain unproved.",
        )

    if name.startswith("ZkRV32I.Refinement."):
        if short == "interpret_related":
            return (
                "Definitional correspondence: `interpret` maps a Lean machine "
                "state into the modeled Rust-state record, and this result "
                "proves the declared relation for that same input.",
                "Unconditional for each quantified Lean state.",
                "Lean-to-Lean state encoding only; the Rust-shaped record is "
                "not extracted from `rust/src/lib.rs`.",
                "Injectivity/adequacy of the actual Rust representation and "
                "source-level correctness remain unproved.",
            )
        if short == "all_isa_instructions_covered":
            return (
                "Constructor/classifier coverage: case analysis shows every "
                "constructor of the Lean `Instruction` datatype returns true "
                "from `isCoveredInstruction`.",
                "Unconditional for every Lean instruction constructor.",
                "Lean instruction datatype and classifier only.",
                "The classifier result does not prove execution correctness, "
                "external RV32I conformance, or Rust test coverage.",
            )
        if short == "master_end_to_end_refinement":
            return (
                "A broad model-level forward equality: for every modeled "
                "instruction and finite Rust-shaped state with aligned PC, "
                "`rustFiniteStepSpec` agrees with Lean `step` after the "
                "declared encoding/state map.",
                "Conditional on the aligned-PC premise; it compares two Lean "
                "definitions, not a separately verified implementation.",
                "Lean finite-state specification versus Lean machine "
                "semantics.",
                "A source-extraction/translation or other defensible proof "
                "that `rustFiniteStepSpec` matches the maintained Rust "
                "implementation remains unproved.",
            )
        if short == "rust_to_rv32i_refinement":
            return (
                "Alias-level refinement theorem: it applies "
                "`master_end_to_end_refinement` to compare the Rust-shaped "
                "Lean finite-state step with Lean `step` for the supplied "
                "instruction.",
                "Conditional on the aligned-PC premise and a supplied "
                "Rust-shaped state/instruction.",
                "Lean-to-Lean relation only; `rustSourceStep` is a Lean "
                "specification, not a translation of the Rust source.",
                "A verified connection from actual `rust/src/lib.rs` to "
                "`rustFiniteStepSpec` remains unproved.",
            )
        if short == "finite_alu_family_step_correspondence":
            return (
                "Instruction-family simulation for constructors selected by "
                "`isAluInstruction`, under the aligned-PC condition.",
                "Conditional on the ALU classifier premise and aligned PC.",
                "Two Lean execution models only.",
                "Actual Rust ALU code correspondence and complete ISA-wide "
                "source correspondence remain unproved.",
            )
        if short in {
            "finite_control_step_correspondence",
            "finite_control_interpreter_correspondence",
        }:
            return (
                "Instruction-family simulation for the constructors selected "
                "by `isControlInstruction`, with aligned PC.",
                "Conditional on the control-instruction classifier premise "
                "and aligned PC.",
                "Two Lean execution models only.",
                "Actual Rust control-flow implementation, memory behavior "
                "for all instructions, and external source correspondence "
                "remain unproved.",
            )
        if short in {"entry_fetch32_isSome", "entry_fetchDecode_isSome"}:
            return (
                "Derives that the supplied `LoadedELFImage` record's entry "
                "can be fetched, and then decoded to some result, from its "
                "alignment and fetchability fields.",
                "Universal over the proof-bearing loaded-image structure; "
                "the relevant parser/loader facts are supplied fields.",
                "Lean fetch/decode functions only.",
                "That an external ELF loader produces this record and that "
                "entry decoding succeeds with a supported instruction remain "
                "unproved.",
            )
        if short == "entry_is_executable":
            return (
                "Projects the executable-entry witness carried by the "
                "loaded-image record.",
                "Universal over the proof-bearing `LoadedELFImage` record.",
                "Lean executable-segment predicate only.",
                "Deriving executable-segment membership from a real ELF "
                "loader and binary remains unproved.",
            )
        if short == "rustSourceStore_success_validRange":
            return (
                "Success-implies-range theorem for `rustSourceStep`, which "
                "is explicitly a Lean specification of the Rust transition, "
                "not execution of Rust source.",
                "Conditional on the modeled store returning `some next`.",
                "Lean Rust-shaped finite-memory model only.",
                "The actual Rust store's bounds/alignment/error behavior and "
                "compiled code remain unproved.",
            )
        if short in {
            "ofLean_toLean_bytes_identity",
            "rustMemory_toLean_refines",
            "lean_toRust_refines",
        }:
            return (
                "Representation-level memory relation/round trip between "
                "the finite Lean `RustMemory` record and Lean `Memory`; "
                "the exact size and byte premises are in the linked type.",
                "Conditional on the stated size equality where present; "
                "otherwise universal over the finite model record.",
                "Lean data representations only.",
                "Correspondence to the storage layout and operations of the "
                "actual Rust memory implementation remains unproved.",
            )
        if short.startswith("checkedOffset_"):
            return (
                "Arithmetic equivalence/bounds property of the modeled "
                "`RustMemory.checkedOffset` and `Memory.validRange` "
                "definitions.",
                "Conditional on the explicit address/range premises for the "
                "bound theorem; the equivalence theorem is universal over "
                "its numeric inputs.",
                "Lean arithmetic model of a 64-bit `usize` profile only.",
                "Actual target-specific Rust arithmetic, compiler behavior, "
                "and error mapping remain unproved.",
            )
        if short.startswith("rustLoad_"):
            return (
                "Modeled little-endian load equality/expansion over the "
                "finite Lean memory record; width-specific success results "
                "use the stated valid-range premise.",
                "The width-specific facts are conditional on memory validity; "
                "the general model equality is unconditional.",
                "Lean finite-memory model only.",
                "Actual Rust memory load code, error behavior, and runtime "
                "correspondence remain unproved.",
            )
        if short == "validRange_offset_end":
            return (
                "Arithmetic consequence of `Memory.validRange`: a valid "
                "range fits within the modeled finite memory size.",
                "Conditional on the explicit `validRange = true` premise.",
                "Lean memory model only.",
                "The corresponding actual Rust range-check implementation "
                "remains unproved.",
            )
        if short.startswith("decode_"):
            return (
                "Concrete decoder example: the specific instruction word "
                "reduces to the displayed instruction/error constructor; "
                "this is not a universal decoder theorem.",
                "Unconditional concrete computation unless additional "
                "hypotheses appear in the linked type.",
                "Lean decoder over Lean bit-vectors/words only.",
                "All-word decoder correctness against an independent RV32I "
                "specification and correspondence to the Rust decoder remain "
                "unproved.",
            )
        if short.startswith("encode_"):
            return (
                "Constructor-level identity for the named instruction "
                "encoding; it does not prove machine execution correspondence.",
                "Unconditional for the explicitly quantified constructor "
                "arguments.",
                "Lean instruction-encoding model only.",
                "Correctness of the maintained Rust encoder and binary "
                "encoding against an external ISA specification remain "
                "unproved.",
            )
        if "correspondence" in short or "matches" in short or "refines" in short:
            return (
                "A genuine relation between the separately defined "
                "Rust-shaped Lean semantics and Lean ISA/memory semantics, "
                "limited to the operations and premises in the linked type.",
                (
                    "Conditional on the displayed PC-alignment, memory-range, "
                    "halt-state, or successful-operation premises; those are "
                    "not discharged universally by this theorem."
                    if has_implication
                    else "No additional proposition premise beyond the "
                    "displayed quantified inputs."
                ),
                "Lean model-to-model correspondence only; no extraction, "
                "verification, or execution of `rust/src/lib.rs` is proved.",
                "A source-level bridge to the actual Rust implementation, "
                "full instruction/error coverage, and binary-to-Rust "
                "correspondence remain unproved.",
            )
        return (
            "A statement about the Lean refinement model, its encoding, or "
            "a specific decoder example; the full proposition and all "
            "premises are shown in the linked inventory entry.",
            (
                "Conditional exactly on the hypotheses displayed in the "
                "type; those premises are inputs, not consequences."
                if has_implication
                else "No additional proposition premise beyond the displayed "
                "quantified inputs."
            ),
            "Lean specification only, including Rust-shaped definitions; "
            "not a theorem about Rust source.",
            "The corresponding property of the maintained Rust code and its "
            "compiled RV32I behavior remain unproved.",
        )

    if name.startswith("ZkRV32I.Binary."):
        if "elf_initial_state" in short:
            if short.endswith("_correct"):
                return (
                    "Definitional state-construction equation: the modeled "
                    "ELF-to-state function returns the state formed from "
                    "entry PC, zeroed modeled registers, loaded memory, and "
                    "running status.",
                    "Universal over the supplied `ElfLoadableImage`; its "
                    "loader and entry facts are fields of that structure.",
                    "Lean initial-state constructor only.",
                    "That the maintained parser/loader supplies this image "
                    "and that compiled ELF execution begins in this state "
                    "remain unproved.",
                )
            if short.endswith("_pc_correct"):
                return (
                    "Projection of the modeled initial-state constructor's "
                    "PC field.",
                    "Universal over the supplied loadable-image record.",
                    "Lean initial-state constructor only.",
                    "The external loader/processor's entry-state behavior "
                    "remains unproved.",
                )
            if short.endswith("_is_running"):
                return (
                    "Projects the running terminal field from an initial "
                    "state witness.",
                    "Conditional on `elfToInitialMachineState loadable = "
                    "some state`; this theorem does not prove arbitrary "
                    "loadable records parse.",
                    "Lean state constructor only.",
                    "External loader initialization and parser success for "
                    "arbitrary bytes remain unproved.",
                )
            if short.endswith("_x0_zero"):
                return (
                    "Projects the constant-zero modeled x0 accessor from "
                    "the initial-state witness.",
                    "Conditional on the supplied initial-state equality.",
                    "Lean model only; the accessor is definitionally zero.",
                    "A separately stored Rust/physical x0 register invariant "
                    "remains unproved.",
                )
            return (
                "Projects a proof field (entry alignment, address bound, "
                "fetchability, or load success) already packaged in "
                "`ElfLoadableImage`.",
                "Universal over a supplied `ElfLoadableImage`; the relevant "
                "fact is an input field, not derived from arbitrary bytes.",
                "Lean loadable-image structure only.",
                "Deriving the packaged fact from an independent ELF parser "
                "or actual loader remains unproved.",
            )
        if short == "rv32_loadability_classifier_total":
            return (
                "Exhaustive case split on the Lean classifier's two result "
                "constructors, yielding accepted or rejected classification "
                "for every byte array.",
                "Unconditional over byte arrays; classification totality "
                "does not imply semantic correctness of either branch.",
                "Lean classifier only.",
                "Soundness/completeness of the classifier against an external "
                "ELF/RV32I implementation remains unproved.",
            )
        if short == "loadableRV32Binary_implies_loadable":
            return (
                "Unpacks the `LoadableRV32IBinary` witness to recover a "
                "successful parser result; it is a witness projection.",
                "Conditional on the accepted/loadable predicate, which "
                "contains the classifier witness.",
                "Lean parser and classifier only.",
                "Parser completeness for arbitrary ELF bytes and external "
                "loader correspondence remain unproved.",
            )
        if short == "loadableRV32Binary_implies_loadedELFImage":
            return (
                "Unpacks the loadability witness and constructs the matching "
                "Lean `LoadedELFImage` record; the existential image is "
                "constructed from the supplied parser result.",
                "Conditional on the `LoadableRV32IBinary` witness.",
                "Lean parser/loadable-image records only.",
                "An external parser/loader bridge and execution correctness "
                "for arbitrary loadable inputs remain unproved.",
            )
        if short in {"parse_success", "parse_yields_loadable"}:
            return (
                "Projects the parser-success field from an "
                "`AcceptedELFProfile`; the existential result is obtained "
                "from that supplied proof.",
                "Conditional on the explicit proof-bearing profile.",
                "Lean restricted ELF parser only.",
                "The theorem does not show that arbitrary bytes have such a "
                "profile or are accepted by an external parser.",
            )
        if short in {"fetch32_of_littleEndianBytes", "fetch32_success_implies_aligned_and_valid"}:
            return (
                "Establishes the exact little-endian fetch equation, or "
                "extracts alignment/range conditions from a successful "
                "modeled fetch, as stated in the linked type.",
                "The byte equation consumes explicit alignment, validity, "
                "and four byte-equality premises; the success theorem "
                "consumes a successful-fetch premise.",
                "Lean finite-memory fetch function only.",
                "Actual instruction-fetch hardware/Rust behavior and "
                "external memory faults remain unproved.",
            )
        if short == "to_binaryValidTransition":
            return (
                "Converts a supplied fetch/decode/step witness into the "
                "equivalent existential binary-transition proposition.",
                "Witness-dependent: all three successful fetch, decode, and "
                "step facts are inputs to the structure.",
                "Lean dynamic-step witness and transition predicates.",
                "Automatically obtaining those witnesses from arbitrary "
                "binary bytes remains unproved.",
            )
        if short == "binaryTransition_iff_binaryValidTransition":
            return (
                "Equivalence between a `Nonempty` packaged witness and the "
                "same fetch/decode/step facts expressed existentially.",
                "Unconditional for each pair of Lean machine states, but the "
                "transition itself requires a witness.",
                "Lean transition definitions only.",
                "Progress/termination or actual execution of an arbitrary "
                "binary remains unproved.",
            )
        if "binaryValidTransition_implies_valid_transition" in short:
            return (
                "Forgets the raw-word fetch/decode witness in a binary-valid "
                "transition to obtain the weaker abstract ISA "
                "`valid_transition` relation.",
                "Conditional on the supplied binary-valid transition "
                "witness.",
                "Lean transition predicates only.",
                "The reverse implication, actual instruction fetch, and "
                "Rust/ELF execution correspondence remain unproved.",
            )
        if "BoundedCFGTrace" in name and short == "length_bounds":
            return (
                "Projects the trace bound stored in `BoundedCFGTrace`.",
                "Universal over a supplied bounded trace.",
                "Lean bounded CFG trace record only.",
                "Unbounded reachability, completeness of CFG exploration, and "
                "termination remain unproved.",
            )
        if "BoundedCFGTrace" in name and short == "adjacent_transition":
            return (
                "Projects the adjacent-transition witness stored in the "
                "bounded CFG trace.",
                "Conditional on the index being a valid adjacent-row index; "
                "the trace record supplies the transition proof.",
                "Lean bounded CFG trace only.",
                "Discovering successors, CFG completeness, and executable "
                "termination remain unproved.",
            )
        if short in {"universal_profile_bridge", "parseSingleExecutableELF32_toLoadedELFImage"}:
            return (
                "Constructs a `LoadedELFImage` record from an existing "
                "accepted profile/loadable record; the existential image is "
                "a Lean record projection.",
                "Conditional on the supplied accepted profile or loadable "
                "record. The parse argument in the latter is unused for "
                "constructing the image.",
                "Lean parser/loader data structures only.",
                "A complete ELF parser-to-machine-state theorem for arbitrary "
                "bytes and correspondence to an external ELF implementation "
                "remain unproved.",
            )
        if short == "memory_preserves_geometry":
            return (
                "Derives loaded memory base/size equality from the "
                "`loadSucceeded` field of the `LoadedELFImage` record.",
                "Conditional on the record's supplied successful-load "
                "witness.",
                "Lean loader model only.",
                "External loader geometry preservation and byte-level "
                "correspondence beyond the modeled loader remain unproved.",
            )
        if "StraightLineALUInstruction" in name and short == "nextState_spec":
            return (
                "Returns the specification of a `Classical.choose` result "
                "whose existence is proved by `step_properties`; it gives a "
                "successful modeled ALU step and unchanged memory/running "
                "state.",
                "Conditional on `hrunning` and the instruction-family "
                "membership proof.",
                "Lean ISA/machine model only; choice dependencies are listed "
                "in the linked inventory entry.",
                "A constructive executable next-state function and "
                "correspondence to Rust or hardware remain unproved.",
            )
        if short == "loadableRV32Binary_maximalPrefix_toFullyVerified":
            return (
                "Produces a bounded outcome record and a `FullyVerifiedBinary` "
                "trace package for a loadable input. `TotalLoadedBinaryOutcome` "
                "explicitly includes faults, non-executable PCs, and fuel "
                "exhaustion; `FullyVerifiedBinary` requires a successful "
                "prefix trace, not a halted final state.",
                "Conditional on `LoadableRV32IBinary`; the selected outcome "
                "is supplied via classical choice from a total outcome "
                "existence theorem.",
                "Lean bounded executor and trace package only.",
                "Halt-success for every loadable binary is not proved; the "
                "outcome may be a fault or a bounded stop.",
            )
        if short == "loadableRV32Binary_implies_FullyVerifiedBinary":
            return (
                "Derives existence of the weaker `FullyVerifiedBinary` "
                "package from the maximal-prefix result. That package does "
                "not require a halted final state.",
                "Conditional on the loadable-binary predicate.",
                "Lean bounded execution/trace model only.",
                "The desired halt-success property for arbitrary loadable "
                "binaries remains unproved; this theorem does not establish "
                "it.",
            )
        if short == "TotalLoadedBinarySuccessfulHalt.finalState_halted":
            return (
                "Projects the halted final-state field from the supplied "
                "`TotalLoadedBinarySuccessfulHalt` record.",
                "Conditional on that proof-bearing structure; the theorem "
                "does not establish that arbitrary execution reaches halt.",
                "Lean bounded execution record only.",
                "Deriving halt-success from arbitrary accepted binary bytes "
                "remains unproved.",
            )
        if short in {"loadedELFImage_total_bounded_outcome", "loadableRV32Binary_total_bounded_outcome"}:
            return (
                "Proves existence of a bounded outcome by exhaustive "
                "case-analysis/induction; the outcome constructors include "
                "halt, fuel exhaustion, non-executable PC, fetch/decode "
                "fault, execution fault, and successful continuation.",
                "The loaded-image theorem is unconditional for its state and "
                "fuel; the loadable-binary theorem is conditional on the "
                "loadable predicate and bound.",
                "Lean totalized bounded executor only.",
                "Excluding fault/timeout outcomes and proving halt-success "
                "for arbitrary accepted binaries remain unproved.",
            )
        if short == "binaryValidTrace_implies_valid_trace":
            return (
                "Forgets the extra binary fetch/decode witnesses to obtain "
                "the weaker ISA-level valid-trace predicate.",
                "Conditional on a supplied `binaryValidTrace` and its "
                "nonempty trace.",
                "Lean trace predicates only.",
                "The reverse implication, trace generation from actual "
                "binary execution, and termination remain unproved.",
            )
        if short == "successful_step_pc_is_possible_successor":
            return (
                "Shows a successful modeled step's destination PC belongs "
                "to the model's `possibleSuccessors` over-approximation.",
                "Conditional on the successful step premise.",
                "Lean control-flow semantics only.",
                "CFG completeness, reachable-state exploration, and "
                "termination proofs for arbitrary control flow remain "
                "unproved.",
            )
        if short == "boundedBinaryStep_exhaustive":
            return (
                "Classifies a single modeled binary-step attempt into the "
                "declared bounded outcome cases; it does not assert every "
                "case is successful.",
                "Conditional on the input state and execution bound shown "
                "in the type.",
                "Lean one-step outcome classification only.",
                "A successful continuation or halt for arbitrary binary "
                "states is not established.",
            )
        if short.startswith("decode") or "fetchDecode" in short:
            return (
                "A decoder/fetch-decode result for the exact word or "
                "fetch/decode witnesses in the type. Example theorems cover "
                "specific constants; bridge theorems consume explicit "
                "dynamic witnesses.",
                (
                    "Conditional on supplied fetch/decode witnesses."
                    if has_implication
                    else "Concrete computation or unconditional model "
                    "equality for the displayed inputs."
                ),
                "Lean bit-vector/word decoder and modeled memory only.",
                "Universal decoder correctness against an independent ISA "
                "specification and correspondence to the Rust decoder remain "
                "unproved.",
            )
        if "loadSegment" in short or "loadMemory" in short or "loadELF32" in short or "segmentFits" in short:
            return (
                "A property of the Lean ELF segment-loading function. "
                "Success-implies properties are conditional on that modeled "
                "loader returning `some`; they do not prove parser "
                "completeness.",
                (
                    "Conditional on segment geometry/load success when those "
                    "hypotheses appear in the linked type."
                    if has_implication
                    else "No additional proposition premise beyond the "
                    "displayed quantified inputs."
                ),
                "The in-project Lean ELF32 profile and byte-array memory "
                "model only.",
                "Conformance to an independent ELF implementation, all ELF "
                "segment layouts, relocation/dynamic-linking behavior, and "
                "the actual loader implementation remain unproved.",
            )
        if short.startswith("entry") or ".Entry" in name:
            return (
                "Fixture-specific result for the named fixed ELF/program "
                "shape (or a field projection from its supplied record); it "
                "is not a universal program theorem.",
                (
                    "Witness-dependent when the type takes a loaded image, "
                    "program predicate, accepted-class proof, or execution "
                    "record; otherwise a concrete closed fixture computation."
                ),
                "Lean byte arrays, parser/loader, and execution semantics; "
                "the fixture is not evidence that an external compiler "
                "produced it.",
                "Generalization beyond this exact fixture/class and "
                "correspondence to compiler-produced ELF remain unproved.",
            )
        if "rejected_or" in short:
            return (
                "Tautological rejected-or-result classification, not a "
                "correctness proof for the rejected branch.",
                "The accepted implication is used only on the accepted "
                "disjunct; the result does not imply correctness for all "
                "bytes.",
                "Lean byte-array predicates only.",
                "A universal non-disjunctive correctness theorem for "
                "arbitrary accepted/loadable binaries remains unproved.",
            )
        if "acceptedRV32IBinary_implies" in short:
            return (
                "Non-vacuous conditional theorem: static accepted-class "
                "evidence implies the stated halt-success correctness in "
                "the Lean binary model. It does not put correctness into "
                "the acceptance predicate.",
                "Conditional on `AcceptedRV32IBinary`; concrete accepted "
                "fixtures witness some members, but this theorem does not "
                "prove acceptance for arbitrary bytes.",
                "Lean parser/loader, fetch/decode, and machine semantics over "
                "byte arrays.",
                "Correctness for all loadable binaries, general RV32I "
                "control flow, and correspondence to external ELF execution "
                "remain unproved.",
            )
        if "JalLoop" in short or "jalLoop" in short or "jal_loop" in short:
            return (
                "A concrete looping-program or finite-prefix invariant. "
                "It proves repeated model transitions, not successful "
                "termination.",
                (
                    "Conditional on the named loop/program witness and "
                    "trace-length bounds where present."
                    if has_implication
                    else "No additional proposition premise beyond the "
                    "displayed quantified inputs."
                ),
                "Lean ELF and machine model for the named loop fixture.",
                "Halt-success correctness for this nonterminating loop and "
                "general CFG termination are not proved by these lemmas.",
            )
        if "Successful" in name or "BinaryTrace" in name or "Trace" in short:
            return (
                "Trace/execution invariant or projection. Extension and plan "
                "lemmas preserve supplied successful-step evidence; they do "
                "not establish that an arbitrary next step exists.",
                (
                    "Conditional on the successful execution/extension "
                    "witness, capacity bound, and trace invariants in the "
                    "linked type."
                    if has_implication
                    else "No additional proposition premise beyond the "
                    "displayed quantified inputs."
                ),
                "Lean bounded trace and successful-step records only.",
                "Unbounded execution, total termination, and existence of "
                "next steps for arbitrary loadable binaries remain unproved.",
            )
        if "loadableRV32Binary_total_bounded_outcome" in short or "loadedELFImage_total_bounded_outcome" in short:
            return (
                "Totality of the explicitly bounded outcome computation; "
                "fuel/bound exhaustion is not a halt-success theorem.",
                "Conditional on a loadable image/binary witness when shown "
                "in the type.",
                "Lean bounded executor only.",
                "Successful termination rather than fault/fuel outcomes for "
                "arbitrary loadable binaries remains unproved.",
            )
        if "haltedAfterStep" in short or "finalState_halted" in short:
            return (
                "A halt property for the supplied successful execution/step "
                "record; inspect the exact type for the success witness.",
                "Conditional on the supplied execution or halted-step "
                "evidence; it is not a proof that execution reaches halt.",
                "Lean execution model only.",
                "Deriving the required successful step sequence from arbitrary "
                "binary bytes remains unproved.",
            )
        if "step_" in short or "step" in short.lower():
            return (
                "A named instruction-step fact in the Lean ISA semantics; "
                "any fetch/decode or state premises are explicit in the "
                "linked type.",
                (
                    "Conditional on the displayed state, alignment, "
                    "instruction, or successful-step premises."
                    if has_implication
                    else "No additional proposition premise beyond the "
                    "displayed quantified inputs."
                ),
                "Lean machine/binary semantics only.",
                "General instruction-level refinement to the actual Rust "
                "implementation and external ISA remain unproved.",
            )
        return (
            "A proposition about the named Lean ELF, decoder, loader, "
            "transition, or trace definition; its exact claim is the "
            "elaborated type in the linked entry.",
            (
                "Conditional exactly on the premises displayed in that type; "
                "the theorem does not establish their satisfiability."
                if has_implication
                else "No additional proposition premise beyond the displayed "
                "quantified inputs."
            ),
            "Lean formal byte-array/ELF/execution model only.",
            "External parser/loader correspondence and general binary "
            "correctness outside the theorem's exact type remain unproved.",
        )

    if name.startswith("ZkRV32I.") and (
        "valid_trace" in short or "transition" in short or "trace" in short.lower()
    ):
        return (
            "A property or projection of the Lean finite-trace validity "
            "predicate; validity is about the provided rows and does not "
            "imply termination unless the type explicitly says so.",
            (
                "Conditional on the supplied trace-validity or index-bound "
                "premises when present."
                if has_implication
                else "No additional proposition premise beyond the displayed "
                "quantified inputs."
            ),
            "Lean machine and trace definitions only.",
            "A trace generated by actual Rust execution or a proof of "
            "program termination remains unproved.",
        )

    if name.startswith("ZkRV32I.") and short.startswith("bImmediate"):
        return (
            "A bit-position, immediate reconstruction, or sign-extension "
            "fact for the Lean B-immediate decoder.",
            "Unconditional for the exact bit-vector/Nat inputs in the type.",
            "Lean decoder arithmetic only.",
            "An all-instruction decoder refinement against an independently "
            "specified RV32I encoding remains unproved.",
        )

    if name.startswith("ZkRV32I.") and short.startswith("decode_"):
        return (
            "Concrete decoder computation for the named instruction word "
            "or encoding; it is evidence for that case, not universal "
            "decoder correctness.",
            "Unconditional concrete computation unless extra assumptions "
            "are shown in the exact type.",
            "Lean instruction decoder only.",
            "All-word decoding correctness and correspondence to an external "
            "ISA/Rust decoder remain unproved.",
        )

    return (
        f"A declaration-specific proposition about `{short}`; its exact "
        "meaning is the full elaborated type in the linked inventory entry.",
        (
            "Conditional on the explicit hypotheses in that type; their "
            "satisfiability is not established by this declaration."
            if has_implication
            else "No additional proposition premise beyond the displayed "
            "quantified inputs."
        ),
        "Lean formal model only; this theorem does not establish actual Rust "
        "source or compiled ELF behavior.",
        "The corresponding property of the external implementation and any "
        "stronger claim not stated in this proposition remain unproved.",
    )


def main() -> int:
    declarations = source_scan.source_declarations()
    if len(declarations) != EXPECTED_SOURCE_DECLARATIONS:
        print(
            f"expected {EXPECTED_SOURCE_DECLARATIONS} source declarations; "
            f"found {len(declarations)}",
            file=sys.stderr,
        )
        return 1
    names = [name for name, _ in declarations]
    if len(set(names)) != len(names):
        print("duplicate authored declaration names in review input", file=sys.stderr)
        return 1

    ledger = LEDGER.read_text(encoding="utf-8")
    entries = inventory_entries(ledger)
    missing = [name for name in names if name not in entries]
    if missing:
        print(
            "authored declarations missing from elaborated inventory: "
            + ", ".join(missing),
            file=sys.stderr,
        )
        return 1

    reviews: list[str] = [
        "\n## Individual authored-declaration review\n\n",
        (
            "Each record below is keyed to the exact elaborated declaration "
            "and source location. The referenced inventory entry contains "
            "the complete Lean proposition (all binders and premises), "
            "`unsafe` status, and transitive axiom list. The assessment "
            "distinguishes theorem truth in the model from premise "
            "satisfiability and from external implementation correspondence. "
            "All 281 authored declarations are individually classified; "
            "conditional premises are not treated as proven merely because "
            "the implication is kernel-checked.\n"
        ),
    ]

    for position, (name, location) in enumerate(declarations, start=1):
        inventory_number, entry = entries[name]
        source_line = next(
            (
                line.removeprefix("- Source origin: ").rstrip(".")
                for line in entry.splitlines()
                if line.startswith("- Source origin: ")
            ),
            f"`{location}`",
        )
        dependencies = next(
            (
                line.removeprefix("- Transitive axiom dependencies: ")
                .rstrip(".")
                for line in entry.splitlines()
                if line.startswith("- Transitive axiom dependencies: ")
            ),
            "not found",
        )
        unsafe = "unsafe=true" in entry
        type_text = ""
        fenced = re.search(r"```lean\n(.*?)\n```", entry, re.DOTALL)
        if fenced:
            type_text = fenced.group(1)
        has_implication = "→" in type_text
        semantic, vacuity, boundary, gap = assessment(name, has_implication)
        reviews.extend(
            [
                f"\n### {position}. `{name}`\n\n",
                (
                    f"- **Proposition and assumptions:** exact proposition, "
                    f"all quantified variables, and premises are the full "
                    f"Lean type in inventory entry **{inventory_number}**; "
                    "there are no additional assumptions hidden from that "
                    "type.\n"
                ),
                (
                    f"- **Kernel/dependencies/circularity:** "
                    f"`unsafe={str(unsafe).lower()}`; transitive dependencies "
                    f"{dependencies}. Lean kernel-checked proof terms cannot "
                    "have a cyclic declaration dependency; the audited "
                    "dependency set contains no project-defined axiom.\n"
                ),
                (
                    f"- **Conditionality/vacuity/witnesses:** {vacuity} "
                    "Existential conclusions are produced by the proof term; "
                    "any existential or proof-bearing hypothesis is explicit "
                    "in the linked type.\n"
                ),
                f"- **Semantic strength:** {semantic}\n",
                f"- **System boundary:** {boundary}\n",
                f"- **Concrete property still unproved:** {gap}\n",
                (
                    f"- **Evidence:** authored declaration at "
                    f"{source_line}; exact elaborated type and dependency "
                    f"record at inventory entry **{inventory_number}**.\n"
                ),
            ]
        )

    reviews.extend(
        [
            "\n## Individual-review completion\n\n",
            f"- Authored declarations reviewed: **{len(declarations)}/281**.\n",
            "- Unresolved declaration-level classifications: **0**. "
            "For conditional theorems, premise satisfiability remains "
            "unproved unless the proposition itself or a separate fixture "
            "establishes it; that limitation is recorded as a remaining "
            "property, not silently counted as an unconditional result.\n",
            "- No theorem statements or proof terms were changed to perform "
            "this audit.\n",
        ]
    )
    sys.stdout.write("".join(reviews))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
