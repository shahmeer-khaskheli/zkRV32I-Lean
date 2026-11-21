import Lean
import ZkRV32I.Binary
import ZkRV32I.Refinement.Step

namespace ZkRV32I.Binary

namespace TranscriptV1

open Lean
open ZkRV32I.Refinement

def memoryWindowSize : Nat := 2 ^ 16
def maxELFBytes : Nat := 2 ^ 20
def maxStepCount : Nat := 256
def formatName : String := "zkrv32i-execution-transcript"
def formatVersion : Nat := 2

structure DecodedInstructionRecord where
  kind : String
  operands : Array Int
  deriving DecidableEq, Repr

structure Snapshot where
  pc : Nat
  terminal : String
  registers : Array Nat
  memoryBase : Nat
  memorySize : Nat
  memoryBytes : Array UInt8
  deriving DecidableEq, Repr

structure StepRecord where
  pc : Nat
  word : Nat
  decoded : DecodedInstructionRecord
  state : Snapshot
  deriving DecidableEq, Repr

structure Transcript where
  elfBytes : Array UInt8
  initialState : Snapshot
  steps : List StepRecord
  stop : Json

private structure JsonInstruction where
  kind : String
  operands : Array Int
  deriving FromJson

private structure JsonSnapshot where
  pc : Nat
  terminal : String
  registers : Array Nat
  memory_base : Nat
  memory_size : Nat
  memory_hex : String
  deriving FromJson

private structure JsonStep where
  pc : Nat
  word : Nat
  decoded : JsonInstruction
  state : JsonSnapshot
  deriving FromJson

private structure JsonTranscript where
  format : String
  version : Nat
  elf_bytes : String
  initial_state : JsonSnapshot
  steps : Array JsonStep
  stop : Json
  deriving FromJson

private def hexNibble (char : Char) : Option Nat :=
  let value := char.toNat
  if 48 ≤ value && value ≤ 57 then
    some (value - 48)
  else if 97 ≤ value && value ≤ 102 then
    some (value - 87)
  else
    none

private def decodeHexAux : List Char → Array UInt8 → Option (Array UInt8)
  | [], bytes => some bytes
  | high :: low :: rest, bytes => do
      let highValue ← hexNibble high
      let lowValue ← hexNibble low
      decodeHexAux rest (bytes.push (UInt8.ofNat (highValue * 16 + lowValue)))
  | _, _ => none

def decodeHex (text : String) : Option (Array UInt8) :=
  decodeHexAux text.toList #[]

private def parseSnapshot (raw : JsonSnapshot) : Except String Snapshot := do
  let some memoryBytes := decodeHex raw.memory_hex
    | throw "snapshot memory_hex is not lowercase hexadecimal"
  if memoryBytes.size != raw.memory_size then
    throw "snapshot memory_size does not match memory_hex"
  pure {
    pc := raw.pc
    terminal := raw.terminal
    registers := raw.registers
    memoryBase := raw.memory_base
    memorySize := raw.memory_size
    memoryBytes := memoryBytes
  }

private def parseStep (raw : JsonStep) : Except String StepRecord := do
  if raw.word ≥ 2 ^ 32 then
    throw "step word is outside the 32-bit instruction range"
  let state ← parseSnapshot raw.state
  pure {
    pc := raw.pc
    word := raw.word
    decoded := ⟨raw.decoded.kind, raw.decoded.operands⟩
    state := state
  }

def parse (text : String) : Except String Transcript := do
  let json ← Json.parse text
  let raw : JsonTranscript ← fromJson? json
  if raw.format != formatName || raw.version != formatVersion then
    throw "unsupported transcript format or version"
  let some elfBytes := decodeHex raw.elf_bytes
    | throw "elf_bytes is not lowercase hexadecimal"
  let initialState ← parseSnapshot raw.initial_state
  let steps ← raw.steps.toList.mapM parseStep
  pure {
    elfBytes := elfBytes
    initialState := initialState
    steps := steps
    stop := raw.stop
  }

private def intNat (value : Nat) : Int :=
  Int.ofNat value

def instructionRecord : Instruction → DecodedInstructionRecord
  | .lui rd imm => ⟨"lui", #[intNat rd.val, intNat imm.toNat]⟩
  | .auipc rd imm => ⟨"auipc", #[intNat rd.val, intNat imm.toNat]⟩
  | .jal rd imm => ⟨"jal", #[intNat rd.val, Word32.signed imm]⟩
  | .jalr rd rs1 imm =>
      ⟨"jalr", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .beq rs1 rs2 imm =>
      ⟨"beq", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .bne rs1 rs2 imm =>
      ⟨"bne", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .blt rs1 rs2 imm =>
      ⟨"blt", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .bge rs1 rs2 imm =>
      ⟨"bge", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .bltu rs1 rs2 imm =>
      ⟨"bltu", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .bgeu rs1 rs2 imm =>
      ⟨"bgeu", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .lb rd rs1 imm =>
      ⟨"lb", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .lh rd rs1 imm =>
      ⟨"lh", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .lw rd rs1 imm =>
      ⟨"lw", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .lbu rd rs1 imm =>
      ⟨"lbu", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .lhu rd rs1 imm =>
      ⟨"lhu", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .sb rs1 rs2 imm =>
      ⟨"sb", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .sh rs1 rs2 imm =>
      ⟨"sh", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .sw rs1 rs2 imm =>
      ⟨"sw", #[intNat rs1.val, intNat rs2.val, Word32.signed imm]⟩
  | .addi rd rs1 imm =>
      ⟨"addi", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .slti rd rs1 imm =>
      ⟨"slti", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .sltiu rd rs1 imm =>
      ⟨"sltiu", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .xori rd rs1 imm =>
      ⟨"xori", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .ori rd rs1 imm =>
      ⟨"ori", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .andi rd rs1 imm =>
      ⟨"andi", #[intNat rd.val, intNat rs1.val, Word32.signed imm]⟩
  | .slli rd rs1 shamt =>
      ⟨"slli", #[intNat rd.val, intNat rs1.val, intNat shamt]⟩
  | .srli rd rs1 shamt =>
      ⟨"srli", #[intNat rd.val, intNat rs1.val, intNat shamt]⟩
  | .srai rd rs1 shamt =>
      ⟨"srai", #[intNat rd.val, intNat rs1.val, intNat shamt]⟩
  | .add rd rs1 rs2 =>
      ⟨"add", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .sub rd rs1 rs2 =>
      ⟨"sub", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .sll rd rs1 rs2 =>
      ⟨"sll", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .slt rd rs1 rs2 =>
      ⟨"slt", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .sltu rd rs1 rs2 =>
      ⟨"sltu", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .xor rd rs1 rs2 =>
      ⟨"xor", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .srl rd rs1 rs2 =>
      ⟨"srl", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .sra rd rs1 rs2 =>
      ⟨"sra", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .or rd rs1 rs2 =>
      ⟨"or", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .and rd rs1 rs2 =>
      ⟨"and", #[intNat rd.val, intNat rs1.val, intNat rs2.val]⟩
  | .fence => ⟨"fence", #[]⟩
  | .ecall => ⟨"ecall", #[]⟩
  | .ebreak => ⟨"ebreak", #[]⟩

private def registerSnapshot (registers : RegisterFile) : Array Nat :=
  (List.finRange 32).toArray.map fun index => (registers.read index).toNat

private def memorySnapshot (memory : Memory) : Array UInt8 :=
  (List.range memory.size).toArray.map fun index => memory.bytes index

def snapshotMatches (snapshot : Snapshot) (state : MachineState) : Bool :=
  snapshot.pc == state.pc.toNat &&
  snapshot.terminal == (if state.terminal == .running then "running" else "halted") &&
  snapshot.registers == registerSnapshot state.regs &&
  snapshot.memoryBase == state.memory.base.toNat &&
  snapshot.memorySize == state.memory.size &&
  snapshot.memoryBytes == memorySnapshot state.memory

structure CheckedStep (state : MachineState) (record : StepRecord) where
  next : MachineState
  word : BitVec 32
  instruction : Instruction
  pcMatches : record.pc = state.pc.toNat
  fetches : fetch32 state.memory state.pc.toNat = some word
  wordMatches : record.word = word.toNat
  decodes : decodeBitVec32 word = .ok instruction
  decodedMatches : record.decoded = instructionRecord instruction
  executes : step state instruction = some next
  outputMatches : snapshotMatches record.state next = true

def checkStep (state : MachineState) (record : StepRecord) :
    Option (CheckedStep state record) := do
  if hpc : record.pc = state.pc.toNat then
    match hfetch : fetch32 state.memory state.pc.toNat with
    | none => none
    | some word =>
      if hword : record.word = word.toNat then
        match hdecode : decodeBitVec32 word with
        | .error _ => none
        | .ok instruction =>
          if hdecoded : record.decoded = instructionRecord instruction then
            match hstep : step state instruction with
            | none => none
            | some next =>
              if houtput : snapshotMatches record.state next = true then
                some {
                  next := next
                  word := word
                  instruction := instruction
                  pcMatches := hpc
                  fetches := hfetch
                  wordMatches := hword
                  decodes := hdecode
                  decodedMatches := hdecoded
                  executes := hstep
                  outputMatches := houtput
                }
              else none
          else none
      else none
  else none

inductive VerifiedRows : MachineState → List StepRecord → Type where
  | nil (state : MachineState) : VerifiedRows state []
  | cons {state : MachineState} {record : StepRecord} {records : List StepRecord}
      (checked : CheckedStep state record)
      (tail : VerifiedRows checked.next records) :
      VerifiedRows state (record :: records)

def verifyRows (state : MachineState) :
    (records : List StepRecord) → Option (VerifiedRows state records)
  | [] => some (.nil state)
  | record :: records =>
      match checkStep state record with
      | none => none
      | some checked =>
          match verifyRows checked.next records with
          | none => none
          | some tail => some (.cons checked tail)

def rustFiniteView (state : MachineState) : RustFiniteState state.memory.size :=
  { pc := state.pc
    regs := state.regs
    memory := RustMemory.ofLean state.memory.size state.memory
    terminal := state.terminal }

theorem rustFiniteView_related (state : MachineState) :
    finiteRelated (rustFiniteView state) state := by
  refine ⟨rfl, rfl, rfl, ?_⟩
  exact lean_toRust_refines state.memory rfl

private def jsonField {α : Type} [FromJson α] (json : Json) (key : String) :
    Option α :=
  (Json.getObjValAs? json α key).toOption

private def jsonFieldIsNull (json : Json) (key : String) : Bool :=
  match json.getObjVal? key with
  | .ok .null => true
  | _ => false

private def decodeErrorName : DecodeError → String
  | .illegalEncoding => "illegal_instruction"
  | .unsupportedInstruction => "unsupported_instruction"

private def fetchErrorName (state : MachineState) : String :=
  let address := state.pc.toNat
  if address % 4 != 0 then "memory_misaligned"
  else if state.memory.base.toNat > address then "memory_out_of_bounds"
  else if address + 3 ≥ 2 ^ 32 then "memory_address_overflow"
  else "memory_out_of_bounds"

private def memoryErrorName
    (state : MachineState) (address : Word32) (width alignment : Nat) : String :=
  if alignment > 1 && address.toNat % alignment != 0 then "memory_misaligned"
  else if state.memory.base.toNat > address.toNat then "memory_out_of_bounds"
  else if address.toNat + (width - 1) ≥ 2 ^ 32 then "memory_address_overflow"
  else "memory_out_of_bounds"

private def invalidMemoryAccess
    (state : MachineState) (address : Word32) (width alignment : Nat) :
    Option String :=
  if Memory.validRange state.memory address.toNat width alignment then
    none
  else
    some (memoryErrorName state address width alignment)

private def misalignedTarget (target : Word32) : Option String :=
  if target.toNat % 4 != 0 then some "misaligned_instruction_address" else none

private def stepErrorName (state : MachineState) (instruction : Instruction) :
    Option String :=
  if state.terminal == .halted then
    some "already_halted"
  else if state.pc.toNat % 4 != 0 then
    some "misaligned_instruction_address"
  else
    match instruction with
    | .jal _ imm => misalignedTarget (Word32.add state.pc imm)
    | .jalr _ rs1 imm =>
            let target := Word32.ofNat (Word32.add (regRead state rs1) imm).toNat
            let target := Word32.ofNat (target.toNat / 2 * 2)
            misalignedTarget target
    | .beq rs1 rs2 imm =>
            if regRead state rs1 == regRead state rs2 then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .bne rs1 rs2 imm =>
            if regRead state rs1 != regRead state rs2 then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .blt rs1 rs2 imm =>
            if Word32.signed (regRead state rs1) < Word32.signed (regRead state rs2) then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .bge rs1 rs2 imm =>
            if Word32.signed (regRead state rs1) ≥ Word32.signed (regRead state rs2) then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .bltu rs1 rs2 imm =>
            if regRead state rs1 < regRead state rs2 then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .bgeu rs1 rs2 imm =>
            if regRead state rs1 ≥ regRead state rs2 then
              misalignedTarget (Word32.add state.pc imm)
            else none
    | .lb _ rs1 imm | .lbu _ rs1 imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 1 1
    | .lh _ rs1 imm | .lhu _ rs1 imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 2 2
    | .lw _ rs1 imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 4 4
    | .sb rs1 _ imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 1 1
    | .sh rs1 _ imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 2 2
    | .sw rs1 _ imm =>
            invalidMemoryAccess state (Word32.add (regRead state rs1) imm) 4 4
    | _ => none

private def decodedStopMatches (json : Json) (instruction : Instruction) : Bool :=
  match (Json.getObjValAs? json JsonInstruction "decoded").toOption with
  | some decoded =>
          (⟨decoded.kind, decoded.operands⟩ : DecodedInstructionRecord) ==
            instructionRecord instruction
  | none => false

private def faultStopMatches (json : Json) (state : MachineState) : Bool :=
  if state.terminal != .running ||
          jsonField json "pc" != some state.pc.toNat then
    false
  else
    match jsonField json "stage" with
    | some ("fetch" : String) =>
            fetch32 state.memory state.pc.toNat == none &&
            jsonFieldIsNull json "word" &&
            jsonFieldIsNull json "decoded" &&
            jsonField json "error" == some (fetchErrorName state)
    | some ("decode" : String) =>
            match fetch32 state.memory state.pc.toNat with
            | none => false
            | some word =>
                match decodeBitVec32 word with
                | .ok _ => false
                | .error error =>
                    jsonField json "word" == some word.toNat &&
                    jsonFieldIsNull json "decoded" &&
                    jsonField json "error" == some (decodeErrorName error)
    | some ("step" : String) =>
            match fetch32 state.memory state.pc.toNat with
            | none => false
            | some word =>
                match decodeBitVec32 word with
                | .error _ => false
                | .ok instruction =>
                    match step state instruction with
                    | some _ => false
                    | none =>
                        jsonField json "word" == some word.toNat &&
                        decodedStopMatches json instruction &&
                        jsonField json "error" == stepErrorName state instruction
    | _ => false

def stopMatches (json : Json) (state : MachineState) (stepCount : Nat) : Bool :=
  match jsonField json "kind" with
  | some ("halt" : String) => state.terminal == .halted
  | some ("fuel_limit" : String) =>
          state.terminal == .running &&
          jsonField json "steps" == some stepCount &&
          jsonField json "limit" == some stepCount &&
          stepCount ≤ maxStepCount
  | some ("fault" : String) => faultStopMatches json state
  | _ => false

theorem stopMatches_fuelLimit_fields
    (json : Json) (state : MachineState) (stepCount : Nat)
    (hkind : jsonField json "kind" = some ("fuel_limit" : String))
    (hrunning : state.terminal = .running)
    (hmatches : stopMatches json state stepCount = true) :
    (jsonField json "steps" = some stepCount ∧
      jsonField json "limit" = some stepCount) ∧
      stepCount ≤ maxStepCount := by
  have hfieldsBool :
      (jsonField json "steps" == some stepCount &&
        jsonField json "limit" == some stepCount &&
        stepCount ≤ maxStepCount) = true := by
    simpa [stopMatches, hkind, hrunning] using hmatches
  simpa only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] using hfieldsBool

inductive VerifiedStopReason (json : Json) (state : MachineState) (stepCount : Nat) : Type where
  | halt (hStopMatches : stopMatches json state stepCount = true)
      (terminalHalted : state.terminal = .halted)
  | fuelLimit (hStopMatches : stopMatches json state stepCount = true)
      (terminalRunning : state.terminal = .running)
  | fault (hStopMatches : stopMatches json state stepCount = true)
      (terminalRunning : state.terminal = .running)

def verifyStopReason (json : Json) (state : MachineState) (stepCount : Nat) :
    Option (VerifiedStopReason json state stepCount) := do
  if hmatches : stopMatches json state stepCount then
    match jsonField json "kind" with
    | some ("halt" : String) =>
        match hterminal : state.terminal with
        | .running => none
        | .halted => some (.halt hmatches hterminal)
    | some ("fuel_limit" : String) =>
        match hterminal : state.terminal with
        | .running => some (.fuelLimit hmatches hterminal)
        | .halted => none
    | some ("fault" : String) =>
        match hterminal : state.terminal with
        | .running => some (.fault hmatches hterminal)
        | .halted => none
    | _ => none
  else none

def VerifiedStopReason.isHalt {json : Json} {state : MachineState} {stepCount : Nat} :
    VerifiedStopReason json state stepCount → Bool
  | .halt _ _ => true
  | .fuelLimit _ _ => false
  | .fault _ _ => false

theorem VerifiedStopReason.halt_implies_terminal
    {json : Json} {state : MachineState} {stepCount : Nat}
    (reason : VerifiedStopReason json state stepCount)
    (hhalt : reason.isHalt = true) :
    state.terminal = .halted := by
  cases reason with
  | halt _ hterminal => exact hterminal
  | fuelLimit _ _ => simp [isHalt] at hhalt
  | fault _ _ => simp [isHalt] at hhalt

theorem VerifiedStopReason.notHalt_implies_running
    {json : Json} {state : MachineState} {stepCount : Nat}
    (reason : VerifiedStopReason json state stepCount)
    (hnotHalt : reason.isHalt = false) :
    state.terminal = .running := by
  cases reason with
  | halt _ _ => simp [isHalt] at hnotHalt
  | fuelLimit _ hrunning => exact hrunning
  | fault _ hrunning => exact hrunning

namespace VerifiedRows

def finalState {state : MachineState} {records : List StepRecord} :
    VerifiedRows state records → MachineState
  | .nil state => state
  | .cons _ tail => tail.finalState

def stateAt {state : MachineState} {records : List StepRecord} :
    VerifiedRows state records → Nat → MachineState
  | .nil state, _ => state
  | .cons (state := state) _ tail, index =>
      if index = 0 then state else tail.stateAt (index - 1)

def witnessAt {state : MachineState} {records : List StepRecord} :
    VerifiedRows state records → Nat → BitVec 32 × Instruction
  | .nil _, _ => (0, .ecall)
  | .cons checked tail, index =>
      if index = 0 then (checked.word, checked.instruction)
      else tail.witnessAt (index - 1)

theorem stateAt_length {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) :
    verified.stateAt records.length = verified.finalState := by
  induction verified with
  | nil => rfl
  | @cons state record records checked tail ih =>
      simpa [stateAt, finalState] using ih

@[simp] theorem stateAt_zero {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) :
    verified.stateAt 0 = state := by
  cases verified <;> rfl

@[simp] theorem stateAt_succ {state : MachineState} {record : StepRecord}
    {records : List StepRecord} (checked : CheckedStep state record)
    (tail : VerifiedRows checked.next records) (index : Nat) :
    (VerifiedRows.cons checked tail).stateAt (index + 1) = tail.stateAt index := by
  simp [stateAt]

@[simp] theorem witnessAt_zero {state : MachineState} {record : StepRecord}
    {records : List StepRecord} (checked : CheckedStep state record)
    (tail : VerifiedRows checked.next records) :
    (VerifiedRows.cons checked tail).witnessAt 0 = (checked.word, checked.instruction) := by
  simp [witnessAt]

@[simp] theorem witnessAt_succ {state : MachineState} {record : StepRecord}
    {records : List StepRecord} (checked : CheckedStep state record)
    (tail : VerifiedRows checked.next records) (index : Nat) :
    (VerifiedRows.cons checked tail).witnessAt (index + 1) =
      tail.witnessAt index := by
  simp [witnessAt]

theorem stepAt {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) (index : Nat)
    (hindex : index < records.length) :
    fetch32 (verified.stateAt index).memory (verified.stateAt index).pc.toNat =
        some (verified.witnessAt index).1 ∧
      decodeBitVec32 (verified.witnessAt index).1 = .ok (verified.witnessAt index).2 ∧
      step (verified.stateAt index) (verified.witnessAt index).2 =
        some (verified.stateAt (index + 1)) := by
  induction verified generalizing index with
  | nil state =>
      simp at hindex
  | @cons state record records checked tail ih =>
      cases index with
      | zero =>
          simp only [stateAt_zero, witnessAt_zero, stateAt_succ]
          exact ⟨checked.fetches, checked.decodes, checked.executes⟩
      | succ index =>
          have htail : index < records.length := by simpa using hindex
          simpa using ih index htail

theorem stepAt_finite_refinement {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) (index : Nat)
    (hindex : index < records.length) :
    finiteRelated (rustFiniteView (verified.stateAt index))
        (verified.stateAt index) ∧
      rustFiniteStepSpec (rustFiniteView (verified.stateAt index))
        (encodeInstruction (verified.witnessAt index).2) =
          (step (rustFiniteView (verified.stateAt index)).toLean
            (verified.witnessAt index).2).map id := by
  have htransition := verified.stepAt index hindex
  have haligned := (fetch32_success_implies_aligned_and_valid _ _
    (verified.witnessAt index).1 htransition.1).1
  constructor
  · exact rustFiniteView_related (verified.stateAt index)
  · rw [master_end_to_end_refinement
      (rustFiniteView (verified.stateAt index))
      (verified.witnessAt index).2 haligned]
    simp

def toTrace {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records)
    (_hbound : records.length < MAX_TRACE) : Trace where
  length := records.length + 1
  rows := fun index => verified.stateAt index.val
  bounded := by omega

theorem toTrace_finalState {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) (hbound : records.length < MAX_TRACE) :
    (verified.toTrace hbound).get
      ((verified.toTrace hbound).length - 1) (by simp [toTrace]) =
        verified.finalState := by
  simp [toTrace, Trace.get, stateAt_length]

def toBinaryTrace {state : MachineState} {records : List StepRecord}
    (verified : VerifiedRows state records) (loaded : LoadedELFImage)
    (hbound : records.length < MAX_TRACE)
    (hstart : state = MachineState.initial loaded.image.header.entry loaded.memory) :
    BinaryTrace where
  loadedImage := loaded
  stateTrace := verified.toTrace hbound
  wordAt := fun index => (verified.witnessAt index).1
  instructionAt := fun index => (verified.witnessAt index).2
  startsAtLoadedEntry := by
    refine ⟨by simp [toTrace], ?_⟩
    simpa [toTrace, Trace.get, stateAt] using hstart
  transitions := by
    intro index hnext
    have hindex : index < records.length := by
      simp [toTrace] at hnext
      omega
    have hstep := verified.stepAt index hindex
    simpa [toTrace, Trace.get] using hstep

end VerifiedRows

structure VerifiedPrefix (transcript : Transcript) where
  loaded : LoadedELFImage
  initialState : MachineState
  startsAtLoadedEntry :
    initialState = MachineState.initial loaded.image.header.entry loaded.memory
  lengthBound : transcript.steps.length < MAX_TRACE
  rows : VerifiedRows initialState transcript.steps

def VerifiedPrefix.binaryTrace {transcript : Transcript}
    (verifiedPrefix : VerifiedPrefix transcript) : BinaryTrace :=
  verifiedPrefix.rows.toBinaryTrace verifiedPrefix.loaded verifiedPrefix.lengthBound
    verifiedPrefix.startsAtLoadedEntry

def VerifiedPrefix.finalState {transcript : Transcript}
    (verifiedPrefix : VerifiedPrefix transcript) : MachineState :=
  verifiedPrefix.rows.finalState

theorem VerifiedPrefix.binaryTrace_finalState
    {transcript : Transcript} (verifiedPrefix : VerifiedPrefix transcript) :
    verifiedPrefix.binaryTrace.finalState = verifiedPrefix.finalState := by
  simp [BinaryTrace.finalState, binaryTrace, VerifiedRows.toBinaryTrace]
  exact VerifiedRows.toTrace_finalState verifiedPrefix.rows verifiedPrefix.lengthBound

def checkPrefix (elfBytes : Array UInt8) (transcript : Transcript) :
    Option (VerifiedPrefix transcript) :=
  if transcript.elfBytes != elfBytes then none
  else if elfBytes.size > maxELFBytes then none
  else if hTooMany : transcript.steps.length > maxStepCount then none
  else do
    let image ← parseELF32 elfBytes
    let base ← loadableSegmentBase image
    let baseMemory := Memory.empty base memoryWindowSize
    let loadable ← parseBoundedELF32 elfBytes baseMemory
    let loaded := loadable.toLoadedELFImage
    let initialState :=
      MachineState.initial loadable.image.header.entry loadable.loadedMemory
    let hbound : transcript.steps.length < MAX_TRACE := by
      have hcount : transcript.steps.length ≤ maxStepCount := Nat.le_of_not_gt hTooMany
      exact Nat.lt_of_le_of_lt hcount (by decide)
    if snapshotMatches transcript.initialState initialState then
      match verifyRows initialState transcript.steps with
      | none => none
      | some verified =>
              some {
                loaded := loaded
                initialState := initialState
                startsAtLoadedEntry := rfl
                lengthBound := hbound
                rows := verified
              }
    else none

structure VerifiedTranscript (transcript : Transcript) where
  verifiedPrefix : VerifiedPrefix transcript
  stopReason : VerifiedStopReason transcript.stop verifiedPrefix.finalState transcript.steps.length

def check (elfBytes : Array UInt8) (transcript : Transcript) :
    Option (VerifiedTranscript transcript) := do
  let verifiedPrefix ← checkPrefix elfBytes transcript
  let stopReason ←
    verifyStopReason transcript.stop verifiedPrefix.finalState transcript.steps.length
  pure ⟨verifiedPrefix, stopReason⟩

def accepted (elfBytes : Array UInt8) (transcript : Transcript) : Bool :=
  (check elfBytes transcript).isSome

theorem VerifiedTranscript.halt_implies_final_state_halted
    {transcript : Transcript} (verified : VerifiedTranscript transcript)
    (hhalt : verified.stopReason.isHalt = true) :
    verified.verifiedPrefix.finalState.terminal = .halted :=
  verified.stopReason.halt_implies_terminal hhalt

theorem VerifiedTranscript.notHalt_implies_final_state_running
    {transcript : Transcript} (verified : VerifiedTranscript transcript)
    (hnotHalt : verified.stopReason.isHalt = false) :
    verified.verifiedPrefix.finalState.terminal = .running :=
  verified.stopReason.notHalt_implies_running hnotHalt

theorem check_sound (elfBytes : Array UInt8) (transcript : Transcript)
    (verified : VerifiedTranscript transcript)
    (_hcheck : check elfBytes transcript = some verified) :
    binaryValidTrace verified.verifiedPrefix.binaryTrace.stateTrace ∧
      valid_trace verified.verifiedPrefix.binaryTrace.stateTrace :=
  ⟨verified.verifiedPrefix.binaryTrace.to_binaryValidTrace,
    verified.verifiedPrefix.binaryTrace.to_valid_trace⟩

theorem accepted_sound (elfBytes : Array UInt8) (transcript : Transcript)
    (haccepted : accepted elfBytes transcript = true) :
    ∃ verified : VerifiedTranscript transcript,
      check elfBytes transcript = some verified ∧
        binaryValidTrace verified.verifiedPrefix.binaryTrace.stateTrace ∧
        valid_trace verified.verifiedPrefix.binaryTrace.stateTrace := by
  cases hcheck : check elfBytes transcript with
  | none => simp [accepted, hcheck] at haccepted
  | some verified =>
          exact ⟨verified, rfl, verified.verifiedPrefix.binaryTrace.to_binaryValidTrace,
            verified.verifiedPrefix.binaryTrace.to_valid_trace⟩

theorem accepted_steps_refine_finite_model
    (elfBytes : Array UInt8) (transcript : Transcript)
    (haccepted : accepted elfBytes transcript = true) :
    ∃ verified : VerifiedTranscript transcript,
      check elfBytes transcript = some verified ∧
      ∀ index, index < transcript.steps.length →
        finiteRelated
            (rustFiniteView (verified.verifiedPrefix.rows.stateAt index))
            (verified.verifiedPrefix.rows.stateAt index) ∧
          rustFiniteStepSpec
              (rustFiniteView (verified.verifiedPrefix.rows.stateAt index))
              (encodeInstruction
                (verified.verifiedPrefix.rows.witnessAt index).2) =
            (step
              (rustFiniteView
                (verified.verifiedPrefix.rows.stateAt index)).toLean
              (verified.verifiedPrefix.rows.witnessAt index).2).map id := by
  cases hcheck : check elfBytes transcript with
  | none => simp [accepted, hcheck] at haccepted
  | some verified =>
      refine ⟨verified, rfl, ?_⟩
      intro index hindex
      exact verified.verifiedPrefix.rows.stepAt_finite_refinement index hindex

theorem accepted_halt_stop_implies_functionallyCorrect_terminal
    (elfBytes : Array UInt8) (transcript : Transcript)
    (verified : VerifiedTranscript transcript)
    (_haccepted : check elfBytes transcript = some verified)
    (hhalt : verified.stopReason.isHalt = true) :
    accepted elfBytes transcript = true ∧
      verified.verifiedPrefix.binaryTrace.finalState.terminal = .halted := by
  constructor
  · simp [accepted, _haccepted]
  · rw [verified.verifiedPrefix.binaryTrace_finalState]
    exact verified.halt_implies_final_state_halted hhalt

theorem accepted_halt_stop_implies_FunctionallyCorrectBinary_terminal
    (elfBytes : Array UInt8) (transcript : Transcript)
    (verified : VerifiedTranscript transcript)
    (haccepted : check elfBytes transcript = some verified)
    (binary : FunctionallyCorrectBinary elfBytes)
    (htrace : verified.verifiedPrefix.binaryTrace = binary.binaryTrace)
    (hhalt : verified.stopReason.isHalt = true) :
    binary.execution.finalState.terminal = .halted := by
  have hacceptedAndHalted :=
    accepted_halt_stop_implies_functionallyCorrect_terminal
      elfBytes transcript verified haccepted hhalt
  have hbinaryTraceHalted : binary.binaryTrace.finalState.terminal = .halted := by
    simpa [htrace] using hacceptedAndHalted.2
  rw [← binary.binaryTrace_finalState_eq_execution_finalState]
  exact hbinaryTraceHalted

end TranscriptV1

end ZkRV32I.Binary
