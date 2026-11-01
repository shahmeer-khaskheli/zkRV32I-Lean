import ZkRV32I.Trace

namespace ZkRV32I.Binary

open ZkRV32I

def readU32LE (bytes : Array UInt8) (offset : Nat) : Option UInt32 := do
  let b0 ← bytes[offset]?
  let b1 ← bytes[offset + 1]?
  let b2 ← bytes[offset + 2]?
  let b3 ← bytes[offset + 3]?
  pure (UInt32.ofNat
    (b0.toNat + b1.toNat * 256 + b2.toNat * 65536 + b3.toNat * 16777216))

def readU16LE (bytes : Array UInt8) (offset : Nat) : Option UInt16 := do
  let b0 ← bytes[offset]?
  let b1 ← bytes[offset + 1]?
  pure (UInt16.ofNat (b0.toNat + b1.toNat * 256))

structure ELF32Header where
  objectType : Nat
  entry : UInt32
  version : Nat
  programHeaderOffset : Nat
  programHeaderEntrySize : Nat
  programHeaderCount : Nat
  deriving DecidableEq, Repr

structure ELF32ProgramHeader where
  segmentType : Nat
  fileOffset : Nat
  virtualAddress : Nat
  fileSize : Nat
  memorySize : Nat
  flags : Nat
  alignment : Nat
  deriving DecidableEq, Repr

structure ELF32Image where
  header : ELF32Header
  programHeaders : Array ELF32ProgramHeader
  fileBytes : Array UInt8

def parseELF32Header (bytes : Array UInt8) : Option ELF32Header := do
  guard (bytes.size >= 52 &&
    bytes[0]? == some 0x7f &&
    bytes[1]? == some 0x45 &&
    bytes[2]? == some 0x4c &&
    bytes[3]? == some 0x46 &&
    bytes[4]? == some 1 &&
    bytes[5]? == some 1 &&
    bytes[6]? == some 1)
  let objectType ← readU16LE bytes 16
  let machine ← readU16LE bytes 18
  let version ← readU32LE bytes 20
  let entry ← readU32LE bytes 24
  let programHeaderOffset ← readU32LE bytes 28
  let headerSize ← readU16LE bytes 40
  let programHeaderEntrySize ← readU16LE bytes 42
  let programHeaderCount ← readU16LE bytes 44
  guard (objectType.toNat == 2 &&
    machine.toNat == 243 &&
    version.toNat == 1 &&
    headerSize.toNat == 52 &&
    (programHeaderCount.toNat == 0 || programHeaderEntrySize.toNat >= 32) &&
    programHeaderOffset.toNat +
      programHeaderEntrySize.toNat * programHeaderCount.toNat <= bytes.size)
  pure
    { objectType := objectType.toNat
      entry := entry
      version := version.toNat
      programHeaderOffset := programHeaderOffset.toNat
      programHeaderEntrySize := programHeaderEntrySize.toNat
      programHeaderCount := programHeaderCount.toNat }

def parseELF32ProgramHeader (bytes : Array UInt8) (offset : Nat) :
    Option ELF32ProgramHeader := do
  guard (offset + 32 <= bytes.size)
  let segmentType ← readU32LE bytes offset
  let fileOffset ← readU32LE bytes (offset + 4)
  let virtualAddress ← readU32LE bytes (offset + 8)
  let fileSize ← readU32LE bytes (offset + 16)
  let memorySize ← readU32LE bytes (offset + 20)
  let flags ← readU32LE bytes (offset + 24)
  let alignment ← readU32LE bytes (offset + 28)
  guard (fileOffset.toNat + fileSize.toNat <= bytes.size &&
    fileSize.toNat <= memorySize.toNat)
  pure
    { segmentType := segmentType.toNat
      fileOffset := fileOffset.toNat
      virtualAddress := virtualAddress.toNat
      fileSize := fileSize.toNat
      memorySize := memorySize.toNat
      flags := flags.toNat
      alignment := alignment.toNat }

def readELF32ProgramHeaders (bytes : Array UInt8) (offset stride count : Nat) :
    Option (Array ELF32ProgramHeader) :=
  match count with
  | 0 => some #[]
  | Nat.succ count => do
      let header ← parseELF32ProgramHeader bytes offset
      let rest ← readELF32ProgramHeaders bytes (offset + stride) stride count
      pure (#[header] ++ rest)

def parseELF32 (bytes : Array UInt8) : Option ELF32Image := do
  let header ← parseELF32Header bytes
  let programHeaders ← readELF32ProgramHeaders bytes header.programHeaderOffset
    header.programHeaderEntrySize header.programHeaderCount
  pure { header := header, programHeaders := programHeaders, fileBytes := bytes }

def ELF32ProgramHeader.isLoadableExecutable (header : ELF32ProgramHeader) : Bool :=
  header.segmentType == 1 && Nat.land header.flags 1 != 0

/-- The segment is contained in both the file and the destination memory image. -/
def segmentFits (memory : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize : Nat) : Bool :=
  decide (fileOffset + fileSize ≤ file.size) &&
    decide (fileSize ≤ memorySize) &&
    decide (virtualAddress + memorySize ≤ 2 ^ 32) &&
    decide (memory.base.toNat ≤ virtualAddress) &&
    decide (virtualAddress - memory.base.toNat + memorySize ≤ memory.size)

/-- Load a segment, zero-fill its memory tail, and preserve bytes outside it. -/
def loadSegment (memory : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize : Nat) : Option Memory :=
  if segmentFits memory file fileOffset fileSize virtualAddress memorySize then
    let offset := virtualAddress - memory.base.toNat
    some
      { memory with
        bytes := fun index =>
          if offset ≤ index && index < offset + fileSize then
            (file[fileOffset + index - offset]?).getD 0
          else if offset + fileSize ≤ index && index < offset + memorySize then
            0
          else
            memory.bytes index }
  else
    none

def loadELF32Segments (memory : Memory) (image : ELF32Image) :
    List ELF32ProgramHeader → Option Memory
  | [] => some memory
  | header :: rest =>
      if header.segmentType == 1 then do
        let next ← loadSegment memory image.fileBytes header.fileOffset header.fileSize
          header.virtualAddress header.memorySize
        loadELF32Segments next image rest
      else
        loadELF32Segments memory image rest

def ELF32Image.loadMemory (image : ELF32Image) (memory : Memory) : Option Memory :=
  loadELF32Segments memory image image.programHeaders.toList

theorem segmentFits_preserves_address_bounds (memory : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize : Nat)
    (h : segmentFits memory file fileOffset fileSize virtualAddress memorySize = true) :
    virtualAddress + memorySize ≤ 2 ^ 32 ∧
      memory.base.toNat ≤ virtualAddress ∧
      virtualAddress - memory.base.toNat + memorySize ≤ memory.size := by
  simp only [segmentFits, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1.2, h.1.2, h.2⟩

theorem loadSegment_success_preserves_geometry (memory loaded : Memory)
    (file : Array UInt8) (fileOffset fileSize virtualAddress memorySize : Nat)
    (h : loadSegment memory file fileOffset fileSize virtualAddress memorySize =
      some loaded) :
    loaded.base = memory.base ∧ loaded.size = memory.size := by
  have hfits :
      segmentFits memory file fileOffset fileSize virtualAddress memorySize = true := by
    by_cases hfits :
        segmentFits memory file fileOffset fileSize virtualAddress memorySize = true
    · exact hfits
    · simp [loadSegment, hfits] at h
  simp [loadSegment, hfits] at h
  cases h
  exact ⟨rfl, rfl⟩

theorem loadSegment_success_has_bounded_addresses (memory loaded : Memory)
    (file : Array UInt8) (fileOffset fileSize virtualAddress memorySize : Nat)
    (h : loadSegment memory file fileOffset fileSize virtualAddress memorySize =
      some loaded) :
    virtualAddress + memorySize ≤ 2 ^ 32 ∧
      memory.base.toNat ≤ virtualAddress ∧
      virtualAddress - memory.base.toNat + memorySize ≤ memory.size := by
  have hfits :
      segmentFits memory file fileOffset fileSize virtualAddress memorySize = true := by
    by_cases hfits :
        segmentFits memory file fileOffset fileSize virtualAddress memorySize = true
    · exact hfits
    · simp [loadSegment, hfits] at h
  exact segmentFits_preserves_address_bounds memory file fileOffset fileSize
    virtualAddress memorySize hfits

def fetch32 (memory : Memory) (address : Nat) : Option (BitVec 32) :=
  if address % 4 == 0 && Memory.validRange memory address 4 4 then
    let offset := address - memory.base.toNat
    some (BitVec.ofNat 32
      ((memory.bytes offset).toNat +
        (memory.bytes (offset + 1)).toNat * 256 +
        (memory.bytes (offset + 2)).toNat * 65536 +
        (memory.bytes (offset + 3)).toNat * 16777216))
  else
    none

def decodeBitVec32 (word : BitVec 32) : Except DecodeError Instruction :=
  decode (Word32.ofNat word.toNat)

theorem decodeBitVec32_agrees_with_word32 (word : BitVec 32) :
    decodeBitVec32 word = decode (Word32.ofNat word.toNat) := rfl

def fetchDecode (memory : Memory) (address : Nat) :
    Option (Except DecodeError Instruction) :=
  (fetch32 memory address).map decodeBitVec32

theorem fetchDecode_uses_isa_decoder (memory : Memory) (address : Nat)
    (word : BitVec 32) (hfetch : fetch32 memory address = some word) :
    fetchDecode memory address = some (decode (Word32.ofNat word.toNat)) := by
  simp [fetchDecode, hfetch, decodeBitVec32]

def binaryStep (state : MachineState) : Option MachineState := do
  let word ← fetch32 state.memory state.pc.toNat
  let instruction ← (decodeBitVec32 word).toOption
  step state instruction

def binaryValidTransition (before after : MachineState) : Prop :=
  ∃ word instruction,
    fetch32 before.memory before.pc.toNat = some word ∧
    decodeBitVec32 word = .ok instruction ∧
    step before instruction = some after

theorem binaryValidTransition_implies_valid_transition
    (before after : MachineState)
    (h : binaryValidTransition before after) :
    valid_transition before after := by
  obtain ⟨_, instruction, _, _, hstep⟩ := h
  exact ⟨instruction, hstep⟩

theorem binaryStep_success_is_binaryValidTransition
    (state next : MachineState)
    (h : binaryStep state = some next) :
    binaryValidTransition state next := by
  unfold binaryStep at h
  cases hfetch : fetch32 state.memory state.pc.toNat with
  | none => simp [hfetch] at h
  | some word =>
      cases hdecode : decodeBitVec32 word with
      | error error => simp [hfetch, hdecode, Except.toOption] at h
      | ok instruction =>
          simp [hfetch, hdecode, Except.toOption] at h
          exact ⟨word, instruction, hfetch, hdecode, h⟩

def binaryValidTrace (trace : Trace) : Prop :=
  ∃ hnonempty : 0 < trace.length,
    initial (trace.get 0 hnonempty) ∧
    ∀ (index : Nat) (hnext : index + 1 < trace.length),
      binaryValidTransition
        (trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (trace.get (index + 1) hnext)

theorem binaryValidTrace_implies_valid_trace (trace : Trace)
    (h : binaryValidTrace trace) : valid_trace trace := by
  obtain ⟨hnonempty, hinitial, htransitions⟩ := h
  refine ⟨hnonempty, hinitial, ?_⟩
  intro index hnext
  exact binaryValidTransition_implies_valid_transition _ _
    (htransitions index hnext)

end ZkRV32I.Binary
