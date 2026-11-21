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
  deriving DecidableEq

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

/-- The memory update performed by a successful segment load. -/
def loadSegmentBytes (memory : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize : Nat) : Memory :=
  let offset := virtualAddress - memory.base.toNat
  { memory with
    bytes := fun index =>
      if offset ≤ index && index < offset + fileSize then
        (file[fileOffset + index - offset]?).getD 0
      else if offset + fileSize ≤ index && index < offset + memorySize then
        0
      else
        memory.bytes index }

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

/-!
## Zero-assumption ELF loader specification

`ElfLoadSpec` separates the architectural inputs from the proof obligations.
`ElfLoadableImage` is an image together with kernel-checkable evidence that every
segment, the entry point, the segment layout, and the resulting memory state satisfy
the loader invariants.
-/
structure ElfLoadSpec where
  image : ELF32Image
  entryPC : Word32
  initialMemory : Memory

def elfFileOffsetAddress (segment : ELF32ProgramHeader) (fileOffset : Nat) : Option Nat :=
  if segment.segmentType == 1 &&
      segment.fileOffset ≤ fileOffset &&
      fileOffset < segment.fileOffset + segment.fileSize then
    some (segment.virtualAddress + (fileOffset - segment.fileOffset))
  else
    none

def elfLoadableSegmentBoundsHold (spec : ElfLoadSpec) (segment : ELF32ProgramHeader) : Bool :=
  if segment.segmentType != 1 then
    true
  else
    decide (segment.fileOffset + segment.fileSize ≤ spec.image.fileBytes.size) &&
    decide (segment.fileSize ≤ segment.memorySize) &&
    decide (segment.virtualAddress + segment.memorySize ≤ 2 ^ 32) &&
    decide (spec.initialMemory.base.toNat ≤ segment.virtualAddress) &&
    decide (segment.virtualAddress - spec.initialMemory.base.toNat +
      segment.memorySize ≤ spec.initialMemory.size)

def elfLoadableSegmentsBounded (spec : ElfLoadSpec) : Bool :=
  spec.image.programHeaders.toList.foldl
    (fun result segment => result && elfLoadableSegmentBoundsHold spec segment) true

def elfMemoryRangesDisjoint
    (aAddress aSize bAddress bSize : Nat) : Bool :=
  decide (aAddress + aSize ≤ bAddress ||
    bAddress + bSize ≤ aAddress)

def elfLoadableSegmentsDisjoint (spec : ElfLoadSpec) : Bool :=
  (List.range spec.image.programHeaders.size).foldl
    (fun result i =>
      (List.range spec.image.programHeaders.size).foldl
        (fun inner j =>
          if i < j then
            match spec.image.programHeaders[i]?, spec.image.programHeaders[j]? with
            | some a, some b =>
                if a.segmentType == 1 && b.segmentType == 1 then
                  inner && elfMemoryRangesDisjoint
                    a.virtualAddress a.memorySize b.virtualAddress b.memorySize
                else inner
            | _, _ => inner
          else inner)
        result)
    true

/-- Disjoint segment writes commute, including their zero-filled BSS tails. -/
theorem loadSegmentBytes_commute_of_disjoint
    (memory : Memory) (file : Array UInt8)
    (aFileOffset aFileSize aAddress aSize : Nat)
    (bFileOffset bFileSize bAddress bSize : Nat)
    (hdisjoint : elfMemoryRangesDisjoint aAddress aSize bAddress bSize = true)
    (hbaseA : memory.base.toNat ≤ aAddress)
    (hbaseB : memory.base.toNat ≤ bAddress)
    (hfileA : aFileSize ≤ aSize)
    (hfileB : bFileSize ≤ bSize) :
    loadSegmentBytes
        (loadSegmentBytes memory file aFileOffset aFileSize aAddress aSize)
        file bFileOffset bFileSize bAddress bSize =
      loadSegmentBytes
        (loadSegmentBytes memory file bFileOffset bFileSize bAddress bSize)
        file aFileOffset aFileSize aAddress aSize := by
  cases memory with
  | mk base size bytes =>
      have hbaseA' : base.toNat ≤ aAddress := by simpa using hbaseA
      have hbaseB' : base.toNat ≤ bAddress := by simpa using hbaseB
      have hdisjointNat :
          aAddress + aSize ≤ bAddress ∨ bAddress + bSize ≤ aAddress := by
        simpa [elfMemoryRangesDisjoint] using hdisjoint
      have hdisjointOffsets :
          aAddress - base.toNat + aSize ≤ bAddress - base.toNat ∨
            bAddress - base.toNat + bSize ≤ aAddress - base.toNat := by
        omega
      apply congrArg (fun byteFn => Memory.mk base size byteFn)
      funext index
      simp only [loadSegmentBytes]
      by_cases ha : aAddress - base.toNat ≤ index ∧
          index < aAddress - base.toNat + aSize
      · rcases ha with ⟨hastart, haend⟩
        have hnotb : ¬ (bAddress - base.toNat ≤ index ∧
            index < bAddress - base.toNat + bSize) := by
          intro hb
          rcases hb with ⟨hbstart, hbend⟩
          rcases hdisjointOffsets with hbefore | hafter
          · omega
          · omega
        have hnotbFile : ¬ (bAddress - base.toNat ≤ index ∧
            index < bAddress - base.toNat + bFileSize) := by omega
        have hnotbBss : ¬ (bAddress - base.toNat + bFileSize ≤ index ∧
            index < bAddress - base.toNat + bSize) := by omega
        simp [hastart, haend, hnotb, hnotbFile, hnotbBss]
      · by_cases hb : bAddress - base.toNat ≤ index ∧
            index < bAddress - base.toNat + bSize
        · rcases hb with ⟨hbstart, hbend⟩
          have hnota : ¬ (aAddress - base.toNat ≤ index ∧
              index < aAddress - base.toNat + aSize) := by
            intro ha
            rcases ha with ⟨hastart, haend⟩
            rcases hdisjointOffsets with hbefore | hafter
            · omega
            · omega
          have hnotaFile : ¬ (aAddress - base.toNat ≤ index ∧
              index < aAddress - base.toNat + aFileSize) := by omega
          have hnotaBss : ¬ (aAddress - base.toNat + aFileSize ≤ index ∧
              index < aAddress - base.toNat + aSize) := by omega
          simp [hnota, hnotaFile, hnotaBss, hbstart, hbend]
        · have hnotaFile : ¬ (aAddress - base.toNat ≤ index ∧
              index < aAddress - base.toNat + aFileSize) := by omega
          have hnotaBss : ¬ (aAddress - base.toNat + aFileSize ≤ index ∧
              index < aAddress - base.toNat + aSize) := by omega
          have hnotbFile : ¬ (bAddress - base.toNat ≤ index ∧
              index < bAddress - base.toNat + bFileSize) := by omega
          have hnotbBss : ¬ (bAddress - base.toNat + bFileSize ≤ index ∧
              index < bAddress - base.toNat + bSize) := by omega
          simp [ha, hb, hnotaFile, hnotaBss, hnotbFile, hnotbBss]

/-- Every successful loader result is exactly the segment-byte update. -/
theorem loadSegment_success_eq_bytes
    (memory loaded : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize : Nat)
    (hload : loadSegment memory file fileOffset fileSize virtualAddress memorySize =
      some loaded) :
    loaded = loadSegmentBytes memory file fileOffset fileSize virtualAddress memorySize := by
  unfold loadSegment at hload
  by_cases hfits :
      segmentFits memory file fileOffset fileSize virtualAddress memorySize = true
  · simp [hfits] at hload
    cases hload
    simp [loadSegmentBytes]
  · simp [hfits] at hload

/-- Two successful sequential loads of disjoint segments yield the same memory
in either order. The hypotheses make failure behavior explicit. -/
theorem successful_disjoint_segment_loads_commute
    (memory aFirst bFirst ab ba : Memory) (file : Array UInt8)
    (aFileOffset aFileSize aAddress aSize : Nat)
    (bFileOffset bFileSize bAddress bSize : Nat)
    (hdisjoint : elfMemoryRangesDisjoint aAddress aSize bAddress bSize = true)
    (hbaseA : memory.base.toNat ≤ aAddress)
    (hbaseB : memory.base.toNat ≤ bAddress)
    (hfileA : aFileSize ≤ aSize)
    (hfileB : bFileSize ≤ bSize)
    (hA : loadSegment memory file aFileOffset aFileSize aAddress aSize =
      some aFirst)
    (hAB : loadSegment aFirst file bFileOffset bFileSize bAddress bSize =
      some ab)
    (hB : loadSegment memory file bFileOffset bFileSize bAddress bSize =
      some bFirst)
    (hBA : loadSegment bFirst file aFileOffset aFileSize aAddress aSize =
      some ba) :
    ab = ba := by
  have hAbytes := loadSegment_success_eq_bytes memory aFirst file
    aFileOffset aFileSize aAddress aSize hA
  have hABbytes := loadSegment_success_eq_bytes aFirst ab file
    bFileOffset bFileSize bAddress bSize hAB
  have hBbytes := loadSegment_success_eq_bytes memory bFirst file
    bFileOffset bFileSize bAddress bSize hB
  have hBAbytes := loadSegment_success_eq_bytes bFirst ba file
    aFileOffset aFileSize aAddress aSize hBA
  subst aFirst
  subst bFirst
  rw [hABbytes, hBAbytes]
  exact loadSegmentBytes_commute_of_disjoint memory file
    aFileOffset aFileSize aAddress aSize
    bFileOffset bFileSize bAddress bSize
    hdisjoint hbaseA hbaseB hfileA hfileB

structure ElfLoadableImage extends ElfLoadSpec where
  loadedMemory : Memory
  hEntryAligned : entryPC.toNat % 4 = 0
  hEntryBounded : entryPC.toNat < 2 ^ 32
  hSegmentsBounded : elfLoadableSegmentsBounded toElfLoadSpec = true
  hSegmentsDisjoint : elfLoadableSegmentsDisjoint toElfLoadSpec = true
  hLoadSuccess : image.loadMemory initialMemory = some loadedMemory
  hEntryFetchable : Memory.validRange loadedMemory entryPC.toNat 4 4 = true
  hEntryMatches : entryPC = image.header.entry
  hSingleSegment : image.programHeaders.size = 1
  hExecutableEntry : ∃ segment, segment ∈ image.programHeaders.toList ∧
    segment.isLoadableExecutable = true ∧
    segment.virtualAddress ≤ entryPC.toNat ∧
    entryPC.toNat + 4 ≤ segment.virtualAddress + segment.memorySize


namespace ElfLoadableImage

def elfToInitialMachineState (loadable : ElfLoadableImage) : Option MachineState :=
  some (MachineState.initial loadable.entryPC loadable.loadedMemory)

theorem elf_initial_state_correct (loadable : ElfLoadableImage) :
    elfToInitialMachineState loadable =
      some { pc := loadable.entryPC
             regs := RegisterFile.zeroed
             memory := loadable.loadedMemory
             terminal := .running } := by
  simp [elfToInitialMachineState, MachineState.initial]

theorem elf_initial_state_pc_correct (loadable : ElfLoadableImage) :
    (elfToInitialMachineState loadable).map MachineState.pc =
      some loadable.entryPC := by
  simp [elfToInitialMachineState, MachineState.initial, Option.map]

theorem elf_initial_state_is_running (loadable : ElfLoadableImage)
    (state : MachineState)
    (hstate : elfToInitialMachineState loadable = some state) :
    state.terminal = .running := by
  simp [elfToInitialMachineState] at hstate
  cases hstate
  rfl

theorem elf_initial_state_x0_zero (loadable : ElfLoadableImage)
    (state : MachineState)
    (hstate : elfToInitialMachineState loadable = some state) :
    state.regs.x0 = 0 := by
  simp [elfToInitialMachineState] at hstate
  cases hstate
  rfl

theorem elf_initial_state_entry_aligned (loadable : ElfLoadableImage) :
    loadable.entryPC.toNat % 4 = 0 :=
  loadable.hEntryAligned

theorem elf_initial_state_entry_bounded (loadable : ElfLoadableImage) :
    loadable.entryPC.toNat < 2 ^ 32 :=
  loadable.hEntryBounded

theorem elf_initial_state_entry_fetchable (loadable : ElfLoadableImage) :
    Memory.validRange loadable.loadedMemory loadable.entryPC.toNat 4 4 = true :=
  loadable.hEntryFetchable

theorem elf_initial_state_load_success (loadable : ElfLoadableImage) :
    loadable.image.loadMemory loadable.initialMemory =
      some loadable.loadedMemory :=
  loadable.hLoadSuccess

end ElfLoadableImage

/-- Restricted parser-to-loader bridge.

This profile accepts exactly one ELF32 executable `PT_LOAD` segment and requires
its virtual address to equal the ELF entry point.  It is intentionally narrower
than the general ELF ABI and every accepted condition is represented by proof
fields in `ElfLoadableImage`.
-/
def parseSingleExecutableELF32
    (bytes : Array UInt8) (baseMemory : Memory) :
    Option ElfLoadableImage := do
  let image ← parseELF32 bytes
  if hsize : image.programHeaders.size = 1 then
    match hsegment : image.programHeaders[0]? with
    | none => none
    | some segment =>
      if hpt : segment.segmentType = 1 then
      if hexec : segment.isLoadableExecutable = true then
      if hvaddr : segment.virtualAddress = image.header.entry.toNat then
      if hspan : image.header.entry.toNat + 4 ≤ segment.virtualAddress + segment.memorySize then
      if halign : image.header.entry.toNat % 4 = 0 then
        match hload : image.loadMemory baseMemory with
        | none => none
        | some loadedMemory =>
          if hfetch : Memory.validRange loadedMemory image.header.entry.toNat 4 4 = true then
            let spec : ElfLoadSpec :=
              { image := image
                entryPC := image.header.entry
                initialMemory := baseMemory }
            if hbounded : elfLoadableSegmentsBounded spec = true then
              if hdisjoint : elfLoadableSegmentsDisjoint spec = true then
                some {
                  image := image
                  entryPC := image.header.entry
                  initialMemory := baseMemory
                  loadedMemory := loadedMemory
                  hEntryAligned := halign
                  hEntryBounded := UInt32.toNat_lt_size image.header.entry
                  hSegmentsBounded := hbounded
                  hSegmentsDisjoint := hdisjoint
                  hLoadSuccess := hload
                  hEntryFetchable := hfetch
                  hEntryMatches := rfl
                  hSingleSegment := hsize
                  hExecutableEntry := ⟨segment, by
                    have hmem : segment ∈ image.programHeaders := by
                      have hzero : 0 < image.programHeaders.size := by omega
                      have h0 : image.programHeaders[0]'hzero = segment := by
                        exact (Array.getElem_eq_iff).2 hsegment
                      exact h0 ▸ Array.getElem_mem hzero
                    have hmemList : segment ∈ image.programHeaders.toList :=
                      Array.mem_toList.mpr hmem
                    exact ⟨hmemList, hexec, hvaddr ▸ Nat.le_refl _, hspan⟩⟩
                }
              else none
            else none
          else none
      else none
      else none
      else none
      else none
      else none
  else none

def loadableSegmentBase (image : ELF32Image) : Option Word32 :=
  let addresses := image.programHeaders.toList.filterMap fun segment =>
    if segment.segmentType == 1 then some segment.virtualAddress else none
  match addresses with
  | [] => none
  | first :: rest =>
  some (Word32.ofNat (rest.foldl (fun base address => min base address) first))

def ELF32Image.hasExecutableEntry (image : ELF32Image) (entry : Nat) : Bool :=
  image.programHeaders.toList.any fun segment =>
    segment.isLoadableExecutable &&
      decide (segment.virtualAddress ≤ entry) &&
      decide (entry + 4 ≤ segment.virtualAddress + segment.memorySize)

theorem ELF32Image.hasExecutableEntry_spec (image : ELF32Image) (entry : Nat) :
    image.hasExecutableEntry entry = true ↔
      ∃ segment, segment ∈ image.programHeaders.toList ∧
        segment.isLoadableExecutable = true ∧
        segment.virtualAddress ≤ entry ∧
        entry + 4 ≤ segment.virtualAddress + segment.memorySize := by
  simp only [hasExecutableEntry, List.any_eq_true, Bool.and_eq_true,
    decide_eq_true_eq]
  constructor
  · rintro ⟨segment, hmem, ⟨hexecutable, hstart⟩, hend⟩
    exact ⟨segment, hmem, hexecutable, hstart, hend⟩
  · rintro ⟨segment, hmem, hexecutable, hstart, hend⟩
    exact ⟨segment, hmem, ⟨hexecutable, hstart⟩, hend⟩

structure BoundedELFLoadableImage extends ElfLoadSpec where
  loadedMemory : Memory
  hEntryAligned : entryPC.toNat % 4 = 0
  hEntryBounded : entryPC.toNat < 2 ^ 32
  hSegmentsBounded : elfLoadableSegmentsBounded toElfLoadSpec = true
  hSegmentsDisjoint : elfLoadableSegmentsDisjoint toElfLoadSpec = true
  hLoadSuccess : image.loadMemory initialMemory = some loadedMemory
  hEntryFetchable : Memory.validRange loadedMemory entryPC.toNat 4 4 = true
  hEntryMatches : entryPC = image.header.entry
  hExecutableEntry : image.hasExecutableEntry entryPC.toNat = true

/-- Bounded multi-segment ELF profile used by execution transcript checking.
It preserves the legacy single-segment parser and classifier separately. -/
def parseBoundedELF32
    (bytes : Array UInt8) (baseMemory : Memory) :
    Option BoundedELFLoadableImage := do
  let image ← parseELF32 bytes
  if halign : image.header.entry.toNat % 4 = 0 then
    let spec : ElfLoadSpec :=
      { image := image
        entryPC := image.header.entry
        initialMemory := baseMemory }
    if hbounded : elfLoadableSegmentsBounded spec = true then
      if hdisjoint : elfLoadableSegmentsDisjoint spec = true then
        match hload : image.loadMemory baseMemory with
        | none => none
        | some loadedMemory =>
          if hfetch : Memory.validRange loadedMemory image.header.entry.toNat 4 4 = true then
            if hexecutable : image.hasExecutableEntry image.header.entry.toNat then
              some {
                image := image
                entryPC := image.header.entry
                initialMemory := baseMemory
                loadedMemory := loadedMemory
                hEntryAligned := halign
                hEntryBounded := UInt32.toNat_lt_size image.header.entry
                hSegmentsBounded := hbounded
                hSegmentsDisjoint := hdisjoint
                hLoadSuccess := hload
                hEntryFetchable := hfetch
                hEntryMatches := rfl
                hExecutableEntry := hexecutable
              }
            else none
          else none
        else none
    else none
  else none

/-- Canonical loader base for the total byte-array classifier. -/
def rv32CanonicalBaseMemory : Memory :=
      Memory.empty 0 (2 ^ 32)

/-- Explicit reasons for excluding a byte array from the current
single-executable-segment ELF32/RV32I profile. -/
inductive BinaryRejectionReason where
      | elf32ParseRejected
      | segmentCountRejected
      | loadableSegmentRejected
      | executableFlagRejected
      | entrySegmentMismatch
      | entrySpanRejected
      | entryAlignmentRejected
      | segmentLoadRejected
      | entryFetchRejected
      | segmentBoundsRejected
      | segmentDisjointnessRejected
      | unsupportedProfile
      deriving DecidableEq, Repr

/-- Total rejection classification.  It mirrors the restricted parser and
returns the first profile condition that is not satisfied. -/
def binaryRejectionReason (bytes : Array UInt8) : BinaryRejectionReason :=
      match parseELF32 bytes with
      | none => .elf32ParseRejected
      | some image =>
          if image.programHeaders.size != 1 then
            .segmentCountRejected
          else
            match image.programHeaders[0]? with
            | none => .segmentCountRejected
            | some segment =>
                if segment.segmentType != 1 then
                  .loadableSegmentRejected
                else if segment.isLoadableExecutable != true then
                  .executableFlagRejected
                else if segment.virtualAddress != image.header.entry.toNat then
                  .entrySegmentMismatch
                else if image.header.entry.toNat + 4 >
                    segment.virtualAddress + segment.memorySize then
                  .entrySpanRejected
                else if image.header.entry.toNat % 4 != 0 then
                  .entryAlignmentRejected
                else
                  match image.loadMemory rv32CanonicalBaseMemory with
                  | none => .segmentLoadRejected
                  | some loadedMemory =>
                      if Memory.validRange loadedMemory image.header.entry.toNat 4 4 != true then
                        .entryFetchRejected
                      else
                        let spec : ElfLoadSpec :=
                          { image := image
                            entryPC := image.header.entry
                            initialMemory := rv32CanonicalBaseMemory }
                        if elfLoadableSegmentsBounded spec != true then
                          .segmentBoundsRejected
                        else if elfLoadableSegmentsDisjoint spec != true then
                          .segmentDisjointnessRejected
                        else
                          .unsupportedProfile

inductive BinaryClassification where
      | accepted : ElfLoadableImage → BinaryClassification
      | rejected : BinaryRejectionReason → BinaryClassification

/-- The classifier is defined for every byte array and has exactly two outcomes. -/
def classifyRV32Binary (bytes : Array UInt8) : BinaryClassification :=
      match parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory with
      | some loadable => .accepted loadable
      | none => .rejected (binaryRejectionReason bytes)

def LoadableRV32IBinary (bytes : Array UInt8) : Prop :=
      ∃ loadable : ElfLoadableImage,
        classifyRV32Binary bytes = .accepted loadable

def RejectedBinary (bytes : Array UInt8) : Prop :=
      ∃ reason : BinaryRejectionReason,
        classifyRV32Binary bytes = .rejected reason

/-- Every byte array is classified as accepted or rejected. -/
theorem rv32_loadability_classifier_total (bytes : Array UInt8) :
        LoadableRV32IBinary bytes ∨ RejectedBinary bytes := by
      cases h : classifyRV32Binary bytes with
      | accepted loadable =>
          exact Or.inl ⟨loadable, h⟩
      | rejected reason =>
          exact Or.inr ⟨reason, h⟩

theorem loadableRV32Binary_implies_loadable (bytes : Array UInt8)
        (haccepted : LoadableRV32IBinary bytes) :
        ∃ loadable : ElfLoadableImage,
          parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable := by
      rcases haccepted with ⟨loadable, hclassify⟩
      cases hparse : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory with
      | none =>
          simp [classifyRV32Binary, hparse] at hclassify
      | some parsedLoadable =>
          simp [classifyRV32Binary, hparse] at hclassify
          exact ⟨loadable, congrArg some hclassify⟩


/-- A proof-bearing restriction of the ELF32 inputs accepted by the
restricted single-executable-segment loader. -/
structure AcceptedELFProfile (bytes : Array UInt8) (baseMemory : Memory) where
  image : ELF32Image
  hParse : parseELF32 bytes = some image
  segment : ELF32ProgramHeader
  hSingleSegment : image.programHeaders = #[segment]
  hLoadableSegment : segment.segmentType = 1
  hExecutableSegment : segment.isLoadableExecutable = true
  hEntryMatchesSegment : segment.virtualAddress = image.header.entry.toNat
  hEntrySpan : image.header.entry.toNat + 4 ≤
    segment.virtualAddress + segment.memorySize
  hEntryAligned : image.header.entry.toNat % 4 = 0
  loadedMemory : Memory
  hLoadSuccess : image.loadMemory baseMemory = some loadedMemory
  hEntryFetchable : Memory.validRange loadedMemory
    image.header.entry.toNat 4 4 = true
  hSegmentsBounded : elfLoadableSegmentsBounded
    { image := image, entryPC := image.header.entry,
      initialMemory := baseMemory } = true
  hSegmentsDisjoint : elfLoadableSegmentsDisjoint
    { image := image, entryPC := image.header.entry,
      initialMemory := baseMemory } = true
  hParserSuccess : (parseSingleExecutableELF32 bytes baseMemory).isSome = true

namespace AcceptedELFProfile

def toElfLoadableImage {bytes : Array UInt8} {baseMemory : Memory}
    (profile : AcceptedELFProfile bytes baseMemory) : ElfLoadableImage :=
  { image := profile.image
    entryPC := profile.image.header.entry
    initialMemory := baseMemory
    loadedMemory := profile.loadedMemory
    hEntryAligned := profile.hEntryAligned
    hEntryBounded := UInt32.toNat_lt_size profile.image.header.entry
    hSegmentsBounded := profile.hSegmentsBounded
    hSegmentsDisjoint := profile.hSegmentsDisjoint
    hLoadSuccess := profile.hLoadSuccess
    hEntryFetchable := profile.hEntryFetchable
    hEntryMatches := rfl
    hSingleSegment := by simp [profile.hSingleSegment]
    hExecutableEntry := by
      refine ⟨profile.segment, ?_, profile.hExecutableSegment, ?_, profile.hEntrySpan⟩
      · rw [profile.hSingleSegment]
        simp
      · simp [profile.hEntryMatchesSegment] }

theorem parse_success {bytes : Array UInt8} {baseMemory : Memory}
    (profile : AcceptedELFProfile bytes baseMemory) :
    (parseSingleExecutableELF32 bytes baseMemory).isSome = true :=
  profile.hParserSuccess

theorem parse_yields_loadable {bytes : Array UInt8} {baseMemory : Memory}
    (profile : AcceptedELFProfile bytes baseMemory) :
    ∃ loadable : ElfLoadableImage,
      parseSingleExecutableELF32 bytes baseMemory = some loadable :=
  Option.isSome_iff_exists.mp profile.hParserSuccess

end AcceptedELFProfile

def elfToInitialMachineState (loadable : ElfLoadableImage) : Option MachineState :=
  ElfLoadableImage.elfToInitialMachineState loadable

theorem elf_initial_state_correct (loadable : ElfLoadableImage) :
    elfToInitialMachineState loadable =
      some { pc := loadable.entryPC
             regs := RegisterFile.zeroed
             memory := loadable.loadedMemory
             terminal := .running } := by
  exact ElfLoadableImage.elf_initial_state_correct loadable

theorem ELF32Image.loadMemory_single_loadable_segment
    (image : ELF32Image) (memory loaded : Memory)
    (segment : ELF32ProgramHeader)
    (hheaders : image.programHeaders = #[segment])
    (hloadable : segment.segmentType = 1)
    (hload : image.loadMemory memory = some loaded) :
    loadSegment memory image.fileBytes segment.fileOffset segment.fileSize
      segment.virtualAddress segment.memorySize = some loaded := by
  unfold ELF32Image.loadMemory at hload
  rw [hheaders] at hload
  simp [loadELF32Segments, hloadable] at hload
  exact hload

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

theorem loadSegment_success_copies_file_byte
    (memory loaded : Memory) (file : Array UInt8)
    (fileOffset fileSize virtualAddress memorySize index : Nat)
    (hload : loadSegment memory file fileOffset fileSize virtualAddress memorySize =
      some loaded)
    (hstart : virtualAddress - memory.base.toNat ≤ index)
    (hfileBacked : index < virtualAddress - memory.base.toNat + fileSize) :
    loaded.bytes index =
      (file[fileOffset + index - (virtualAddress - memory.base.toNat)]?).getD 0 := by
  have hfits :
      segmentFits memory file fileOffset fileSize virtualAddress memorySize = true := by
    by_cases hfits :
        segmentFits memory file fileOffset fileSize virtualAddress memorySize = true
    · exact hfits
    · simp [loadSegment, hfits] at hload
  simp [loadSegment, hfits] at hload
  have hbytes := congrArg (fun loadedMemory : Memory => loadedMemory.bytes index) hload
  simpa [loadSegmentBytes, hstart, hfileBacked] using hbytes.symm

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

theorem loadELF32Segments_success_preserves_geometry
    (memory loaded : Memory) (image : ELF32Image)
    (headers : List ELF32ProgramHeader)
    (hload : loadELF32Segments memory image headers = some loaded) :
    loaded.base = memory.base ∧ loaded.size = memory.size := by
  induction headers generalizing memory loaded with
  | nil =>
      simp [loadELF32Segments] at hload
      cases hload
      exact ⟨rfl, rfl⟩
  | cons header rest ih =>
      by_cases hloadable : header.segmentType == 1
      · cases hsegment : loadSegment memory image.fileBytes header.fileOffset
            header.fileSize header.virtualAddress header.memorySize with
        | none =>
            simp [loadELF32Segments, hloadable, hsegment] at hload
        | some intermediate =>
            have hrest :
                loadELF32Segments intermediate image rest = some loaded := by
              simpa [loadELF32Segments, hloadable, hsegment] using hload
            have hrestGeometry := ih intermediate loaded hrest
            have hsegmentGeometry := loadSegment_success_preserves_geometry
              memory intermediate image.fileBytes header.fileOffset header.fileSize
              header.virtualAddress header.memorySize hsegment
            exact ⟨hrestGeometry.1.trans hsegmentGeometry.1,
              hrestGeometry.2.trans hsegmentGeometry.2⟩
      · have hrest : loadELF32Segments memory image rest = some loaded := by
          simpa [loadELF32Segments, hloadable] using hload
        exact ih memory loaded hrest

theorem ELF32Image.loadMemory_success_preserves_geometry
    (image : ELF32Image) (memory loaded : Memory)
    (hload : image.loadMemory memory = some loaded) :
    loaded.base = memory.base ∧ loaded.size = memory.size := by
  exact loadELF32Segments_success_preserves_geometry memory loaded image
    image.programHeaders.toList hload

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

theorem fetch32_of_littleEndianBytes
    (memory : Memory) (address : Nat) (b0 b1 b2 b3 : UInt8)
    (haligned : address % 4 = 0)
    (hvalid : Memory.validRange memory address 4 4 = true)
    (h0 : memory.bytes (address - memory.base.toNat) = b0)
    (h1 : memory.bytes (address - memory.base.toNat + 1) = b1)
    (h2 : memory.bytes (address - memory.base.toNat + 2) = b2)
    (h3 : memory.bytes (address - memory.base.toNat + 3) = b3) :
    fetch32 memory address = some (BitVec.ofNat 32
      (b0.toNat + b1.toNat * 256 + b2.toNat * 65536 + b3.toNat * 16777216)) := by
  simp [fetch32, haligned, hvalid, h0, h1, h2, h3]

theorem fetch32_success_implies_aligned_and_valid
    (memory : Memory) (address : Nat) (word : BitVec 32)
    (hfetch : fetch32 memory address = some word) :
    address % 4 = 0 ∧ Memory.validRange memory address 4 4 = true := by
  unfold fetch32 at hfetch
  split at hfetch <;> simp_all

def decodeBitVec32 (word : BitVec 32) : Except DecodeError Instruction :=
  decode (Word32.ofNat word.toNat)

/-!
### Generalized encoded-instruction bridge

This section supplies a canonical raw-word representation for the instructions
that have a well-defined RV32I encoding.  An `Option` result keeps unsupported
or non-canonical immediate representations explicit.
-/

def encodeWordField (value : Nat) (shift width : Nat) : Nat :=
  (value % 2 ^ width) * 2 ^ shift

def encodeUImmediate (imm : Word32) : Nat :=
  imm.toNat / 4096 % 1048576 * 4096

def encodeIWord
    (opcode funct3 : Nat) (rd rs1 : Fin 32) (imm : Word32) : Option Word32 := do
  guard (Word32.signExtend (imm.toNat % 4096) 12 = imm)
  pure <| Word32.ofNat
    (encodeWordField (imm.toNat % 4096) 20 12 +
     encodeWordField rs1.val 15 5 +
     encodeWordField funct3 12 3 +
     encodeWordField rd.val 7 5 +
     encodeWordField opcode 0 7)

def encodeRWord (funct3 funct7 : Nat)
    (rd rs1 rs2 : Fin 32) : Word32 :=
  Word32.ofNat
    (encodeWordField funct7 25 7 +
     encodeWordField rs2.val 20 5 +
     encodeWordField rs1.val 15 5 +
     encodeWordField funct3 12 3 +
     encodeWordField rd.val 7 5 +
     encodeWordField 51 0 7)

def encodeSWord (funct3 : Nat) (rs1 rs2 : Fin 32)
    (imm : Word32) : Option Word32 := do
  guard (Word32.signExtend (imm.toNat % 4096) 12 = imm)
  let value := imm.toNat % 4096
  pure <| Word32.ofNat
    (encodeWordField (value / 32) 25 7 +
     encodeWordField rs2.val 20 5 +
     encodeWordField rs1.val 15 5 +
     encodeWordField funct3 12 3 +
     encodeWordField (value % 32) 7 5 +
     encodeWordField 35 0 7)

def encodeBWord (funct3 : Nat) (rs1 rs2 : Fin 32)
    (imm : Word32) : Option Word32 := do
  guard (Word32.signExtend (imm.toNat % 8192) 13 = imm)
  guard (imm.toNat % 2 = 0)
  let value := imm.toNat % 8192
  pure <| Word32.ofNat
    (encodeWordField (value / 4096) 31 1 +
     encodeWordField (value / 32 % 64) 25 6 +
     encodeWordField rs2.val 20 5 +
     encodeWordField rs1.val 15 5 +
     encodeWordField funct3 12 3 +
     encodeWordField (value / 2 % 16) 8 4 +
     encodeWordField (value / 2048 % 2) 7 1 +
     encodeWordField 99 0 7)

def encodeUWord (opcode : Nat) (rd : Fin 32) (imm : Word32) :
    Option Word32 := do
  guard (imm.toNat % 4096 = 0)
  pure <| Word32.ofNat
    (encodeWordField (imm.toNat / 4096) 12 20 +
     encodeWordField rd.val 7 5 +
     encodeWordField opcode 0 7)

def encodeJWord (rd : Fin 32) (imm : Word32) : Option Word32 := do
  guard (Word32.signExtend (imm.toNat % 2097152) 21 = imm)
  guard (imm.toNat % 2 = 0)
  let value := imm.toNat % 2097152
  pure <| Word32.ofNat
    (encodeWordField (value / 1048576 % 2) 31 1 +
     encodeWordField (value / 4096 % 256) 12 8 +
     encodeWordField (value / 2048 % 2) 20 1 +
     encodeWordField (value / 2 % 1024) 21 10 +
     encodeWordField rd.val 7 5 +
     encodeWordField 111 0 7)

def encodeInstructionWord : Instruction → Option Word32
  | .lui rd imm => encodeUWord 55 rd imm
  | .auipc rd imm => encodeUWord 23 rd imm
  | .jal rd imm => encodeJWord rd imm
  | .jalr rd rs1 imm => encodeIWord 103 0 rd rs1 imm
  | .beq rs1 rs2 imm => encodeBWord 0 rs1 rs2 imm
  | .bne rs1 rs2 imm => encodeBWord 1 rs1 rs2 imm
  | .blt rs1 rs2 imm => encodeBWord 4 rs1 rs2 imm
  | .bge rs1 rs2 imm => encodeBWord 5 rs1 rs2 imm
  | .bltu rs1 rs2 imm => encodeBWord 6 rs1 rs2 imm
  | .bgeu rs1 rs2 imm => encodeBWord 7 rs1 rs2 imm
  | .lb rd rs1 imm => encodeIWord 3 0 rd rs1 imm
  | .lh rd rs1 imm => encodeIWord 3 1 rd rs1 imm
  | .lw rd rs1 imm => encodeIWord 3 2 rd rs1 imm
  | .lbu rd rs1 imm => encodeIWord 3 4 rd rs1 imm
  | .lhu rd rs1 imm => encodeIWord 3 5 rd rs1 imm
  | .sb rs1 rs2 imm => encodeSWord 0 rs1 rs2 imm
  | .sh rs1 rs2 imm => encodeSWord 1 rs1 rs2 imm
  | .sw rs1 rs2 imm => encodeSWord 2 rs1 rs2 imm
  | .addi rd rs1 imm => encodeIWord 19 0 rd rs1 imm
  | .slti rd rs1 imm => encodeIWord 19 2 rd rs1 imm
  | .sltiu rd rs1 imm => encodeIWord 19 3 rd rs1 imm
  | .xori rd rs1 imm => encodeIWord 19 4 rd rs1 imm
  | .ori rd rs1 imm => encodeIWord 19 6 rd rs1 imm
  | .andi rd rs1 imm => encodeIWord 19 7 rd rs1 imm
  | .slli rd rs1 shamt =>
      do
        guard (shamt < 32)
        pure <| Word32.ofNat
          (encodeWordField (shamt % 32) 20 5 +
           encodeWordField rs1.val 15 5 +
           encodeWordField 1 12 3 +
           encodeWordField rd.val 7 5 +
           encodeWordField 19 0 7)
  | .srli rd rs1 shamt =>
      do
        guard (shamt < 32)
        pure <| Word32.ofNat
          (encodeWordField (shamt % 32) 20 5 +
           encodeWordField rs1.val 15 5 +
           encodeWordField 5 12 3 +
           encodeWordField rd.val 7 5 +
           encodeWordField 19 0 7)
  | .srai rd rs1 shamt =>
      do
        guard (shamt < 32)
        pure <| Word32.ofNat
          (encodeWordField 32 25 7 +
           encodeWordField (shamt % 32) 20 5 +
           encodeWordField rs1.val 15 5 +
           encodeWordField 5 12 3 +
           encodeWordField rd.val 7 5 +
           encodeWordField 19 0 7)
  | .add rd rs1 rs2 => some (encodeRWord 0 0 rd rs1 rs2)
  | .sub rd rs1 rs2 => some (encodeRWord 0 32 rd rs1 rs2)
  | .sll rd rs1 rs2 => some (encodeRWord 1 0 rd rs1 rs2)
  | .slt rd rs1 rs2 => some (encodeRWord 2 0 rd rs1 rs2)
  | .sltu rd rs1 rs2 => some (encodeRWord 3 0 rd rs1 rs2)
  | .xor rd rs1 rs2 => some (encodeRWord 4 0 rd rs1 rs2)
  | .srl rd rs1 rs2 => some (encodeRWord 5 0 rd rs1 rs2)
  | .sra rd rs1 rs2 => some (encodeRWord 5 32 rd rs1 rs2)
  | .or rd rs1 rs2 => some (encodeRWord 6 0 rd rs1 rs2)
  | .and rd rs1 rs2 => some (encodeRWord 7 0 rd rs1 rs2)
  | .fence => some (Word32.ofNat 0x0000000f)
  | .ecall => some (Word32.ofNat 0x00000073)
  | .ebreak => some (Word32.ofNat 0x00100073)

structure EncodedInstruction where
  /-- Raw 32-bit RV32I instruction word. -/
  word : Word32
  /-- The decoded ISA instruction constructor. -/
  instruction : Instruction
  /-- Reserved fields and representation-specific bit ranges are canonical. -/
  validReservedFields : encodeInstructionWord instruction = some word
  /-- Explicit encoding relation, kept independently of decoder behavior. -/
  encodingRelation : encodeInstructionWord instruction = some word
  /-- Kernel proof obligation that the decoder round-trips the raw word. -/
  decodingRelation : decode word = .ok instruction

theorem decode_encode_equivalence (encoded : EncodedInstruction) :
    decode encoded.word = .ok encoded.instruction := by
  exact encoded.decodingRelation

def EncodedInstruction.mkValid (instruction : Instruction) :
    Option EncodedInstruction :=
  match hencode : encodeInstructionWord instruction with
  | none => none
  | some word =>
      match hdecode : decode word with
      | .ok decoded =>
          if hinst : decoded = instruction then
            some {
              word := word
              instruction := instruction
              validReservedFields := hencode
              encodingRelation := hencode
              decodingRelation := by
                simpa [hinst] using hdecode
            }
          else none
      | .error _ => none

theorem decodeBitVec32_agrees_with_word32 (word : BitVec 32) :
    decodeBitVec32 word = decode (Word32.ofNat word.toNat) := rfl

set_option maxRecDepth 100000 in
theorem decodeBitVec32_entryAddiX1 :
    decodeBitVec32 (BitVec.ofNat 32 0x00100093) =
      .ok (.addi (Fin.mk 1 (by decide)) (Fin.mk 0 (by decide)) 1) := by
  have hword : (BitVec.ofNat 32 0x00100093).toNat = 0x00100093 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_addi_x1_x0_one

set_option maxRecDepth 100000 in
theorem decodeBitVec32_entryAddiX2 :
    decodeBitVec32 (BitVec.ofNat 32 0x00200113) =
      .ok (.addi (Fin.mk 2 (by decide)) (Fin.mk 0 (by decide)) 2) := by
  have hword : (BitVec.ofNat 32 0x00200113).toNat = 0x00200113 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_addi_x2_x0_two

set_option maxRecDepth 100000 in
theorem decodeBitVec32_entryAddiX3 :
    decodeBitVec32 (BitVec.ofNat 32 0x00308193) =
      .ok (.addi (Fin.mk 3 (by decide)) (Fin.mk 1 (by decide)) 3) := by
  have hword : (BitVec.ofNat 32 0x00308193).toNat = 0x00308193 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_addi_x3_x1_three

set_option maxRecDepth 100000 in
theorem decodeBitVec32_entryAddiX4 :
    decodeBitVec32 (BitVec.ofNat 32 0x00408213) =
      .ok (.addi (Fin.mk 4 (by decide)) (Fin.mk 1 (by decide)) 4) := by
  have hword : (BitVec.ofNat 32 0x00408213).toNat = 0x00408213 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_addi_x4_x1_four

theorem decodeBitVec32_entryEcall :
    decodeBitVec32 (BitVec.ofNat 32 0x00000073) = .ok .ecall := by
  have hword : (BitVec.ofNat 32 0x00000073).toNat = 0x00000073 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_ecall_word

set_option maxRecDepth 100000 in
theorem decodeBitVec32_add_x2_x1_x1 :
    decodeBitVec32 (BitVec.ofNat 32 0x00108133) =
      .ok (.add (Fin.mk 2 (by decide)) (Fin.mk 1 (by decide))
        (Fin.mk 1 (by decide))) := by
  have hword : (BitVec.ofNat 32 0x00108133).toNat = 0x00108133 := by decide
  rw [decodeBitVec32, hword]
  exact ZkRV32I.decode_add_x2_x1_x1

set_option maxRecDepth 100000 in
theorem decodeBitVec32_add_x3_x2_x2 :
    decodeBitVec32 (BitVec.ofNat 32 0x002101b3) =
      .ok (.add (Fin.mk 3 (by decide)) (Fin.mk 2 (by decide))
        (Fin.mk 2 (by decide))) := by
  have hword : (BitVec.ofNat 32 0x002101b3).toNat = 0x002101b3 := by decide
  rw [decodeBitVec32, hword]
  rfl

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

theorem binaryStep_eq_isaStep_of_fetch_decode
    (state next : MachineState) (word : BitVec 32) (instruction : Instruction)
    (hfetch : fetch32 state.memory state.pc.toNat = some word)
    (hdecode : decodeBitVec32 word = .ok instruction)
    (hstep : step state instruction = some next) :
    binaryStep state = some next := by
  simp [binaryStep, hfetch, hdecode, hstep, Except.toOption]

def binaryValidTransition (before after : MachineState) : Prop :=
  ∃ word instruction,
    fetch32 before.memory before.pc.toNat = some word ∧
    decodeBitVec32 word = .ok instruction ∧
    step before instruction = some after

structure DynamicStepWitness (before after : MachineState) where
  word : BitVec 32
  instruction : Instruction
  hfetch : fetch32 before.memory before.pc.toNat = some word
  hdecode : decodeBitVec32 word = .ok instruction
  hstep : step before instruction = some after

def binaryTransition (before after : MachineState) : Prop :=
  Nonempty (DynamicStepWitness before after)

theorem DynamicStepWitness.to_binaryValidTransition
    (before after : MachineState) (witness : DynamicStepWitness before after) :
    binaryValidTransition before after := by
  refine ⟨witness.word, witness.instruction, ?_, ?_, ?_⟩
  · exact witness.hfetch
  · exact witness.hdecode
  · exact witness.hstep

theorem binaryTransition_iff_binaryValidTransition
    (before after : MachineState) :
    binaryTransition before after ↔ binaryValidTransition before after := by
  constructor
  · intro hnonempty
    obtain ⟨witness⟩ := hnonempty
    exact DynamicStepWitness.to_binaryValidTransition before after witness
  · intro hvalid
    obtain ⟨word, instruction, hfetch, hdecode, hstep⟩ := hvalid
    exact ⟨⟨word, instruction, hfetch, hdecode, hstep⟩⟩

/-!
### Architectural CFG successors

`possibleSuccessors` is an over-approximation of destination PCs: conditional
branches include both architectural outcomes, and control-transfer targets are
retained only when they pass the same alignment check as `step`.
-/
def alignedSuccessor (target : Word32) : Option Word32 :=
  if target.toNat % 4 = 0 then some target else none

def alignedSuccessors (target : Word32) : List Word32 :=
  match alignedSuccessor target with
  | some target => [target]
  | none => []

def possibleSuccessors (state : MachineState) (instruction : Instruction) :
    List Word32 :=
  if state.terminal == .halted then
    []
  else
    let pc' := nextPC state
    match instruction with
    | .beq _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bne _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .blt _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bge _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bltu _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bgeu _ _ imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .jal _ imm =>
        alignedSuccessors (Word32.add state.pc imm)
    | .jalr _ rs1 imm =>
        let raw := Word32.add (regRead state rs1) imm
        let raw := Word32.ofNat raw.toNat
        let target := Word32.ofNat (raw.toNat / 2 * 2)
        alignedSuccessors target
    | .ecall | .ebreak => [state.pc]
    | _ => [pc']

theorem successful_step_pc_is_possible_successor
    (s s' : MachineState) (instruction : Instruction)
    (hstep : step s instruction = some s') :
    s'.pc ∈ possibleSuccessors s instruction := by
  revert s' hstep
  cases instruction with
  | beq rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : regRead s rs1 == regRead s rs2
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | bne rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : regRead s rs1 != regRead s rs2
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | blt rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : Word32.signed (regRead s rs1) < Word32.signed (regRead s rs2)
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | bge rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : Word32.signed (regRead s rs1) >= Word32.signed (regRead s rs2)
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | bltu rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : regRead s rs1 < regRead s rs2
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | bgeu rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, branch] at hstep
        rcases hstep with ⟨_, hbranch⟩
        rcases hbranch with ⟨_, heq⟩
        have hpc := congrArg MachineState.pc heq
        by_cases hcond : regRead s rs1 >= regRead s rs2
        · simp_all [hcond, hpc, possibleSuccessors, alignedSuccessors, alignedSuccessor]
        · simp_all [hcond, hpc, possibleSuccessors, nextPC]
  | jal rd imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht] at hstep
        rcases hstep with ⟨_, haligned, heq⟩
        subst s'
        simp only [possibleSuccessors]
        rw [if_neg ht]
        simp [regWrite, haligned, alignedSuccessors, alignedSuccessor, nextPC]
  | jalr rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht] at hstep
        rcases hstep with ⟨_, haligned, heq⟩
        subst s'
        simp only [possibleSuccessors]
        rw [if_neg ht]
        simp only [alignedSuccessors]
        simp [alignedSuccessor, haligned, regWrite, nextPC]
  | lb rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, loadValue] at hstep
        cases hload : s.memory.load (UInt32.toNat ((regRead s rs1).add imm)) 1 1 with
        | none => simp [hload] at hstep
        | some value =>
            simp [hload] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp only [possibleSuccessors]
            rw [if_neg ht]
            simp [regWrite, nextPC]
  | lh rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, loadValue] at hstep
        cases hload : s.memory.load (UInt32.toNat ((regRead s rs1).add imm)) 2 2 with
        | none => simp [hload] at hstep
        | some value =>
            simp [hload] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp only [possibleSuccessors]
            rw [if_neg ht]
            simp [regWrite, nextPC]
  | lw rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, loadValue] at hstep
        cases hload : s.memory.load (UInt32.toNat ((regRead s rs1).add imm)) 4 4 with
        | none => simp [hload] at hstep
        | some value =>
            simp [hload] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp only [possibleSuccessors]
            rw [if_neg ht]
            simp [regWrite, nextPC]
  | lbu rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, loadValue] at hstep
        cases hload : s.memory.load (UInt32.toNat ((regRead s rs1).add imm)) 1 1 with
        | none => simp [hload] at hstep
        | some value =>
            simp [hload] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp only [possibleSuccessors]
            rw [if_neg ht]
            simp [regWrite, nextPC]
  | lhu rd rs1 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, loadValue] at hstep
        cases hload : s.memory.load (UInt32.toNat ((regRead s rs1).add imm)) 2 2 with
        | none => simp [hload] at hstep
        | some value =>
            simp [hload] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp only [possibleSuccessors]
            rw [if_neg ht]
            simp [regWrite, nextPC]
  | sb rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, storeValue] at hstep
        cases hstore : s.memory.store
            (UInt32.toNat ((regRead s rs1).add imm)) 1 1 (regRead s rs2) with
        | none => simp [hstore] at hstep
        | some memory =>
            simp [hstore] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp [ht, possibleSuccessors, nextPC]
  | sh rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, storeValue] at hstep
        cases hstore : s.memory.store
            (UInt32.toNat ((regRead s rs1).add imm)) 2 2 (regRead s rs2) with
        | none => simp [hstore] at hstep
        | some memory =>
            simp [hstore] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp [ht, possibleSuccessors, nextPC]
  | sw rs1 rs2 imm =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht, storeValue] at hstep
        cases hstore : s.memory.store
            (UInt32.toNat ((regRead s rs1).add imm)) 4 4 (regRead s rs2) with
        | none => simp [hstore] at hstep
        | some memory =>
            simp [hstore] at hstep
            rcases hstep with ⟨_, heq⟩
            subst s'
            simp [ht, possibleSuccessors, nextPC]
  | _ =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht] at hstep
        rcases hstep with ⟨_, heq⟩
        cases heq
        simp [possibleSuccessors, regWrite, ht]

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

/-!
### Bounded CFG trace graph
-/
structure BoundedCFGTrace where
  stateTrace : Trace
  transitions :
    ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
      binaryTransition
        (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (stateTrace.get (index + 1) hnext)

theorem BoundedCFGTrace.length_bounds (trace : BoundedCFGTrace) :
    trace.stateTrace.length ≤ MAX_TRACE := trace.stateTrace.bounded

theorem BoundedCFGTrace.adjacent_transition
    (trace : BoundedCFGTrace) (index : Nat)
    (hnext : index + 1 < trace.stateTrace.length) :
    binaryTransition
      (trace.stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
      (trace.stateTrace.get (index + 1) hnext) :=
  trace.transitions index hnext

def CFGReachable (start target : MachineState) (bound : Nat) : Prop :=
  ∃ trace : BoundedCFGTrace,
    ∃ hstart : 0 < trace.stateTrace.length,
      ∃ hlast : trace.stateTrace.length - 1 < trace.stateTrace.length,
        trace.stateTrace.length ≤ bound ∧
        trace.stateTrace.get 0 hstart = start ∧
        trace.stateTrace.get (trace.stateTrace.length - 1) hlast = target

inductive BoundedBinaryStepOutcome where
  | continued (before after : MachineState)
  | terminated (before after : MachineState)
  | timeout (state : MachineState)
  | fetchFault (state : MachineState)
  | decodeFault (state : MachineState) (word : BitVec 32) (error : DecodeError)
  | executionFault (state : MachineState) (word : BitVec 32)
      (instruction : Instruction)
  | nonExecutablePC (state : MachineState)

def boundedBinaryStep (state : MachineState) (fuel : Nat) :
    BoundedBinaryStepOutcome :=
  if state.terminal == .halted then
    .terminated state state
  else
    match fuel with
    | 0 => .timeout state
    | _fuel + 1 =>
        match fetch32 state.memory state.pc.toNat with
        | none => .fetchFault state
        | some word =>
            match decodeBitVec32 word with
            | .error error => .decodeFault state word error
            | .ok instruction =>
                match step state instruction with
                | none => .executionFault state word instruction
                | some next =>
                    if next.terminal == .halted then
                      .terminated state next
                    else
                      .continued state next

theorem boundedBinaryStep_exhaustive
    (state : MachineState) (fuel : Nat)
    (outcome : BoundedBinaryStepOutcome) :
    boundedBinaryStep state fuel = outcome →
      (∃ before after, outcome = .continued before after) ∨
      (∃ before after, outcome = .terminated before after) ∨
      (∃ stalled, outcome = .timeout stalled) ∨
      (∃ faultState, outcome = .fetchFault faultState) ∨
      (∃ faultState word error, outcome = .decodeFault faultState word error) ∨
      (∃ faultState word instruction, outcome = .executionFault faultState word instruction) ∨
      (∃ faultState, outcome = .nonExecutablePC faultState) := by
  intro h
  cases outcome with
  | continued before after => exact Or.inl ⟨before, after, rfl⟩
  | terminated before after => exact Or.inr (Or.inl ⟨before, after, rfl⟩)
  | timeout stalled => exact Or.inr (Or.inr (Or.inl ⟨stalled, rfl⟩))
  | fetchFault faultState => exact Or.inr (Or.inr (Or.inr (Or.inl ⟨faultState, rfl⟩)))
  | decodeFault faultState word error =>
      exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl ⟨faultState, word, error, rfl⟩))))
  | executionFault faultState word instruction =>
      exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl
        ⟨faultState, word, instruction, rfl⟩)))))
  | nonExecutablePC faultState =>
      exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
        ⟨faultState, rfl⟩)))))

/-- Exhaustively execute at most `fuel` binary steps.
Success reaches either timeout, halt, fetch fault, decode fault, or ISA fault. -/
def boundedBinaryExecution (state : MachineState) : Nat →
    BoundedBinaryStepOutcome
  | 0 =>
      if state.terminal == .halted then
        .terminated state state
      else
        .timeout state
  | fuel + 1 =>
      if state.terminal == .halted then
        .terminated state state
      else
        match fetch32 state.memory state.pc.toNat with
        | none => .fetchFault state
        | some word =>
            match decodeBitVec32 word with
            | .error error => .decodeFault state word error
            | .ok instruction =>
                match step state instruction with
                | none => .executionFault state word instruction
                | some next =>
                    if next.terminal == .halted then
                      .terminated state next
                    else
                      boundedBinaryExecution next fuel

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

theorem binaryStep_success_yields_isa_step
    (state next : MachineState)
    (h : binaryStep state = some next) :
    ∃ instruction, step state instruction = some next := by
  obtain ⟨_, instruction, _, _, hstep⟩ :=
    binaryStep_success_is_binaryValidTransition state next h
  exact ⟨instruction, hstep⟩

theorem binaryStep_success_has_fetch_decode_step_witness
    (state next : MachineState) (h : binaryStep state = some next) :
    ∃ word instruction,
      fetch32 state.memory state.pc.toNat = some word ∧
      decodeBitVec32 word = .ok instruction ∧
      step state instruction = some next :=
  binaryStep_success_is_binaryValidTransition state next h

theorem binaryStep_success_has_fetch_decode_step_pair
    (state next : MachineState) (h : binaryStep state = some next) :
    ∃ witness : BitVec 32 × Instruction,
      fetch32 state.memory state.pc.toNat = some witness.1 ∧
      decodeBitVec32 witness.1 = .ok witness.2 ∧
      step state witness.2 = some next := by
  obtain ⟨word, instruction, hfetch, hdecode, hstep⟩ :=
    binaryStep_success_has_fetch_decode_step_witness state next h
  exact ⟨(word, instruction), hfetch, hdecode, hstep⟩

def binaryStep_success_has_fetch_decode_step_data
    (state next : MachineState) (h : binaryStep state = some next) :
    { witness : BitVec 32 × Instruction //
      fetch32 state.memory state.pc.toNat = some witness.1 ∧
      decodeBitVec32 witness.1 = .ok witness.2 ∧
      step state witness.2 = some next } := by
  unfold binaryStep at h
  cases hfetch : fetch32 state.memory state.pc.toNat with
  | none => simp [hfetch] at h
  | some word =>
      cases hdecode : decodeBitVec32 word with
      | error error => simp [hfetch, hdecode, Except.toOption] at h
      | ok instruction =>
          simp [hfetch, hdecode, Except.toOption] at h
          exact ⟨(word, instruction), rfl, by simpa using hdecode, h⟩

structure LoadedELFImage where
  image : ELF32Image
  baseMemory : Memory
  memory : Memory
  loadSucceeded : image.loadMemory baseMemory = some memory
  executableEntry : ∃ segment, segment ∈ image.programHeaders.toList ∧
    segment.isLoadableExecutable = true ∧
    segment.virtualAddress ≤ image.header.entry.toNat ∧
    image.header.entry.toNat + 4 ≤ segment.virtualAddress + segment.memorySize
  entryAligned : image.header.entry.toNat % 4 = 0
  entryFetchable : Memory.validRange memory image.header.entry.toNat 4 4 = true

def BoundedELFLoadableImage.toLoadedELFImage
    (loadable : BoundedELFLoadableImage) : LoadedELFImage :=
  { image := loadable.image
    baseMemory := loadable.initialMemory
    memory := loadable.loadedMemory
    loadSucceeded := loadable.hLoadSuccess
    executableEntry := by
      apply (ELF32Image.hasExecutableEntry_spec _ _).mp
      simpa [loadable.hEntryMatches] using loadable.hExecutableEntry
    entryAligned := by
      simpa [loadable.hEntryMatches] using loadable.hEntryAligned
    entryFetchable := by
      simpa [loadable.hEntryMatches] using loadable.hEntryFetchable }

theorem LoadedELFImage.initial_state_pcAligned (loaded : LoadedELFImage) :
    pcAligned (MachineState.initial loaded.image.header.entry loaded.memory) := by
  simpa [pcAligned, MachineState.initial] using loaded.entryAligned

def ElfLoadableImage.toLoadedELFImage
    (loadable : ElfLoadableImage) :
    LoadedELFImage :=
  { image := loadable.image
    baseMemory := loadable.initialMemory
    memory := loadable.loadedMemory
    loadSucceeded := loadable.hLoadSuccess
    executableEntry := by
      simpa [loadable.hEntryMatches] using loadable.hExecutableEntry
    entryAligned := by
      simpa [loadable.hEntryMatches] using loadable.hEntryAligned
    entryFetchable := by
      simpa [loadable.hEntryMatches] using loadable.hEntryFetchable }

theorem loadableRV32Binary_implies_loadedELFImage (bytes : Array UInt8)
    (haccepted : LoadableRV32IBinary bytes) :
    ∃ loadable : ElfLoadableImage, ∃ loaded : LoadedELFImage,
      parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable ∧
      loaded.image = loadable.image := by
  rcases loadableRV32Binary_implies_loadable bytes haccepted with ⟨loadable, hparse⟩
  let loaded := ElfLoadableImage.toLoadedELFImage loadable
  exact ⟨loadable, loaded, hparse, rfl⟩

namespace AcceptedELFProfile

def toLoadedELFImage {bytes : Array UInt8} {baseMemory : Memory}
    (profile : AcceptedELFProfile bytes baseMemory) : LoadedELFImage :=
  profile.toElfLoadableImage.toLoadedELFImage

theorem universal_profile_bridge {bytes : Array UInt8} {baseMemory : Memory}
    (profile : AcceptedELFProfile bytes baseMemory) :
    ∃ loaded : LoadedELFImage,
      (parseSingleExecutableELF32 bytes baseMemory).isSome = true ∧
      loaded.image = profile.image ∧
      loaded.memory = profile.loadedMemory := by
  exact ⟨profile.toLoadedELFImage, profile.parse_success, rfl, rfl⟩

end AcceptedELFProfile

theorem parseSingleExecutableELF32_toLoadedELFImage
    (bytes : Array UInt8) (baseMemory : Memory)
    (loadable : ElfLoadableImage)
    (_hparseLoad : parseSingleExecutableELF32 bytes baseMemory = some loadable) :
    ∃ loaded : LoadedELFImage,
      loaded.image = loadable.image ∧
      loaded.memory = loadable.loadedMemory := by
  let loaded := loadable.toLoadedELFImage
  exact ⟨loaded, rfl, rfl⟩

theorem LoadedELFImage.memory_preserves_geometry (loaded : LoadedELFImage) :
    loaded.memory.base = loaded.baseMemory.base ∧
      loaded.memory.size = loaded.baseMemory.size := by
  exact ELF32Image.loadMemory_success_preserves_geometry loaded.image
    loaded.baseMemory loaded.memory loaded.loadSucceeded

theorem LoadedELFImage.entry_fetch32_isSome (loaded : LoadedELFImage) :
    (fetch32 loaded.memory loaded.image.header.entry.toNat).isSome = true := by
  simp [fetch32, loaded.entryAligned, loaded.entryFetchable]

theorem LoadedELFImage.entry_fetchDecode_isSome (loaded : LoadedELFImage) :
    (fetchDecode loaded.memory loaded.image.header.entry.toNat).isSome = true := by
  simp [fetchDecode, loaded.entry_fetch32_isSome]

def LoadedELFImage.executableAddress (loaded : LoadedELFImage) (address : Nat) : Prop :=
  ∃ segment, segment ∈ loaded.image.programHeaders.toList ∧
    segment.isLoadableExecutable = true ∧
    segment.virtualAddress ≤ address ∧
    address + 4 ≤ segment.virtualAddress + segment.memorySize

/-- A proof-bearing result of bounded execution. The `.continued` constructor
records a real fetch/decode/ISA step and recursively accounts for the remaining
fuel; every other constructor records the exact stop condition. -/
inductive TotalLoadedBinaryOutcome (loaded : LoadedELFImage) :
    MachineState → Nat → Type where
  | halted {state : MachineState} {fuel : Nat}
      (hhalted : state.terminal = .halted) :
      TotalLoadedBinaryOutcome loaded state fuel
  | fuelExhausted {state : MachineState}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat) :
      TotalLoadedBinaryOutcome loaded state 0
  | nonExecutablePC {state : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hnonExecutable : ¬ loaded.executableAddress state.pc.toNat) :
      TotalLoadedBinaryOutcome loaded state fuel
  | fetchFault {state : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (hfetch : fetch32 state.memory state.pc.toNat = none) :
      TotalLoadedBinaryOutcome loaded state (fuel + 1)
  | decodeFault {state : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (error : DecodeError)
      (hdecode : decodeBitVec32 word = .error error) :
      TotalLoadedBinaryOutcome loaded state (fuel + 1)
  | executionFault {state : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = none) :
      TotalLoadedBinaryOutcome loaded state (fuel + 1)
  | haltedAfterStep {state next : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = some next)
      (hnextHalted : next.terminal = .halted) :
      TotalLoadedBinaryOutcome loaded state (fuel + 1)
  | continued {state next : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = some next)
      (hnextRunning : next.terminal ≠ .halted)
      (remaining : TotalLoadedBinaryOutcome loaded next fuel) :
      TotalLoadedBinaryOutcome loaded state (fuel + 1)

/-- Every loaded image has a proof-bearing outcome for every finite fuel.
The outcome includes all successful transitions before its first stop. -/
theorem loadedELFImage_total_bounded_outcome (loaded : LoadedELFImage)
    (state : MachineState) (fuel : Nat) :
    Nonempty (TotalLoadedBinaryOutcome loaded state fuel) := by
  classical
  induction fuel generalizing state with
  | zero =>
      by_cases hhalted : state.terminal = .halted
      · exact ⟨.halted hhalted⟩
      · by_cases hexecutable : loaded.executableAddress state.pc.toNat
        · exact ⟨.fuelExhausted hhalted hexecutable⟩
        · exact ⟨.nonExecutablePC hhalted hexecutable⟩
  | succ fuel ih =>
      by_cases hhalted : state.terminal = .halted
      · exact ⟨.halted hhalted⟩
      · by_cases hexecutable : loaded.executableAddress state.pc.toNat
        · cases hfetch : fetch32 state.memory state.pc.toNat with
          | none => exact ⟨.fetchFault hhalted hexecutable hfetch⟩
          | some word =>
              cases hdecode : decodeBitVec32 word with
              | error error =>
                  exact ⟨.decodeFault hhalted hexecutable word hfetch error hdecode⟩
              | ok instruction =>
                  cases hstep : step state instruction with
                  | none =>
                      exact ⟨.executionFault hhalted hexecutable word hfetch
                        instruction hdecode hstep⟩
                  | some next =>
                      by_cases hnextHalted : next.terminal = .halted
                      · exact ⟨.haltedAfterStep hhalted hexecutable word hfetch
                          instruction hdecode hstep hnextHalted⟩
                      · exact ⟨.continued hhalted hexecutable word hfetch
                          instruction hdecode hstep hnextHalted
                          (Classical.choice (ih next))⟩
        · exact ⟨.nonExecutablePC hhalted hexecutable⟩

theorem loadableRV32Binary_total_bounded_outcome (bytes : Array UInt8)
    (haccepted : LoadableRV32IBinary bytes) (fuel : Nat)
    (_hfuel : fuel ≤ MAX_TRACE) :
    ∃ loadable : ElfLoadableImage,
      parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable ∧
      Nonempty (TotalLoadedBinaryOutcome loadable.toLoadedELFImage
        (MachineState.initial loadable.image.header.entry loadable.loadedMemory) fuel) := by
  obtain ⟨loadable, hparse⟩ :=
    loadableRV32Binary_implies_loadable bytes haccepted
  exact ⟨loadable, hparse,
    loadedELFImage_total_bounded_outcome loadable.toLoadedELFImage
      (MachineState.initial loadable.image.header.entry loadable.loadedMemory)
      fuel⟩

/-- One loaded-binary step with an explicit executable-address check. -/
noncomputable def boundedLoadedBinaryStep (loaded : LoadedELFImage)
    (state : MachineState) (fuel : Nat) : BoundedBinaryStepOutcome :=
  by
    classical
    by_cases hexec : loaded.executableAddress state.pc.toNat
    · exact boundedBinaryStep state fuel
    · exact .nonExecutablePC state

/-- Loaded-binary execution retaining executable-address faults in the outcome. -/
noncomputable def boundedLoadedBinaryExecution (loaded : LoadedELFImage)
    (state : MachineState) : Nat → BoundedBinaryStepOutcome
  | 0 => by
      if state.terminal == .halted then
        exact .terminated state state
      else
        classical
        by_cases hexec : loaded.executableAddress state.pc.toNat
        · exact .timeout state
        · exact .nonExecutablePC state
  | fuel + 1 => by
      if state.terminal == .halted then
        exact .terminated state state
      else
        classical
        by_cases hexec : loaded.executableAddress state.pc.toNat
        ·
            match hfetch : fetch32 state.memory state.pc.toNat with
            | none => exact .fetchFault state
            | some word =>
                match hdecode : decodeBitVec32 word with
                | .error error => exact .decodeFault state word error
                | .ok instruction =>
                    match hstep : step state instruction with
                    | none => exact .executionFault state word instruction
                    | some next =>
                        if next.terminal == .halted then
                          exact .terminated state next
                        else
                          exact boundedLoadedBinaryExecution loaded next fuel
        · exact .nonExecutablePC state

theorem LoadedELFImage.entry_is_executable (loaded : LoadedELFImage) :
    loaded.executableAddress loaded.image.header.entry.toNat :=
  loaded.executableEntry

def entryAddiFourCodeBytes : Array UInt8 := #[
  0x93, 0x00, 0x10, 0x00,
  0x13, 0x01, 0x20, 0x00,
  0x93, 0x81, 0x30, 0x00,
  0x13, 0x82, 0x40, 0x00,
  0x73, 0x00, 0x00, 0x00
]

/-- Restricted concrete ELF32 fixture containing the five-instruction ADDI/ECALL fragment. -/
def entryAddiFourELF32Bytes : Array UInt8 := #[
  0x7f, 0x45, 0x4c, 0x46, 0x01, 0x01, 0x01, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x02, 0x00, 0xf3, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x10, 0x00, 0x00, 0x34, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x34, 0x00, 0x20, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x01, 0x00, 0x00, 0x00, 0x54, 0x00, 0x00, 0x00,
  0x00, 0x10, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00,
  0x14, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00,
  0x05, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
  0x93, 0x00, 0x10, 0x00, 0x13, 0x01, 0x20, 0x00,
  0x93, 0x81, 0x30, 0x00, 0x13, 0x82, 0x40, 0x00,
  0x73, 0x00, 0x00, 0x00
]

def entryAddiFourBaseMemory : Memory :=
  Memory.empty 0x1000 0x10000

def entryAddiFourELF32Segment : ELF32ProgramHeader :=
  { segmentType := 1
    fileOffset := 84
    virtualAddress := 0x10000
    fileSize := 20
    memorySize := 20
    flags := 5
    alignment := 4 }

def entryAddiFourELF32Image : ELF32Image :=
  { header :=
      { objectType := 2
        entry := UInt32.ofNat 0x10000
        version := 1
        programHeaderOffset := 52
        programHeaderEntrySize := 32
        programHeaderCount := 1 }
    programHeaders := #[entryAddiFourELF32Segment]
    fileBytes := entryAddiFourELF32Bytes }

def entryAddiFourELF32LoadedMemory : Memory :=
  { base := entryAddiFourBaseMemory.base
    size := entryAddiFourBaseMemory.size
    bytes := fun index =>
      let offset := entryAddiFourELF32Segment.virtualAddress -
        entryAddiFourBaseMemory.base.toNat
      if offset ≤ index && index < offset + entryAddiFourELF32Segment.fileSize then
        (entryAddiFourELF32Bytes[84 + index - offset]?).getD 0
      else
        0 }

theorem entryAddiFourELF32_direct_load :
    entryAddiFourELF32Image.loadMemory entryAddiFourBaseMemory =
      some entryAddiFourELF32LoadedMemory := by
  unfold ELF32Image.loadMemory loadELF32Segments loadSegment segmentFits
  simp [entryAddiFourELF32Image, entryAddiFourELF32Segment,
    entryAddiFourELF32Bytes, entryAddiFourBaseMemory,
    entryAddiFourELF32LoadedMemory]
  apply congrArg some
  congr
  funext index
  simp [Memory.empty, entryAddiFourBaseMemory,
    entryAddiFourELF32Segment]

def entryAddiFourParsedELF32Segment : ELF32ProgramHeader :=
  { segmentType := 1
    fileOffset := 84
    virtualAddress := 0x1000
    fileSize := 20
    memorySize := 20
    flags := 5
    alignment := 4 }

def entryAddiFourParsedELF32Image : ELF32Image :=
  { header :=
      { objectType := 2
        entry := UInt32.ofNat 0x1000
        version := 1
        programHeaderOffset := 52
        programHeaderEntrySize := 32
        programHeaderCount := 1 }
    programHeaders := #[entryAddiFourParsedELF32Segment]
    fileBytes := entryAddiFourELF32Bytes }

def entryAddiFourParsedELF32LoadedMemory : Memory :=
  { base := entryAddiFourBaseMemory.base
    size := entryAddiFourBaseMemory.size
    bytes := fun index =>
      let offset := entryAddiFourParsedELF32Segment.virtualAddress -
        entryAddiFourBaseMemory.base.toNat
      if offset ≤ index && index < offset + entryAddiFourParsedELF32Segment.fileSize then
        (entryAddiFourELF32Bytes[84 + index - offset]?).getD 0
      else
        0 }

theorem entryAddiFourParsedELF32_direct_load :
    entryAddiFourParsedELF32Image.loadMemory entryAddiFourBaseMemory =
      some entryAddiFourParsedELF32LoadedMemory := by
  unfold ELF32Image.loadMemory loadELF32Segments loadSegment segmentFits
  simp [entryAddiFourParsedELF32Image, entryAddiFourParsedELF32Segment,
    entryAddiFourELF32Bytes, entryAddiFourBaseMemory,
    entryAddiFourParsedELF32LoadedMemory]
  apply congrArg some
  congr
  funext index
  simp [Memory.empty, entryAddiFourBaseMemory,
    entryAddiFourParsedELF32Segment]

theorem entryAddiFourParsedELF32_direct_load_expanded :
    ({ header := entryAddiFourParsedELF32Image.header
       programHeaders := entryAddiFourParsedELF32Image.programHeaders
       fileBytes := entryAddiFourParsedELF32Image.fileBytes } : ELF32Image).loadMemory
        entryAddiFourBaseMemory =
      some entryAddiFourParsedELF32LoadedMemory := by
  simpa [entryAddiFourParsedELF32Image] using
    entryAddiFourParsedELF32_direct_load

def entryAddiFourELF32AcceptedProfile :
    AcceptedELFProfile entryAddiFourELF32Bytes entryAddiFourBaseMemory :=
  { image := entryAddiFourParsedELF32Image
    hParse := by native_decide
    segment := entryAddiFourParsedELF32Segment
    hSingleSegment := by native_decide
    hLoadableSegment := by native_decide
    hExecutableSegment := by native_decide
    hEntryMatchesSegment := by native_decide
    hEntrySpan := by native_decide
    hEntryAligned := by native_decide
    loadedMemory := entryAddiFourParsedELF32LoadedMemory
    hLoadSuccess := entryAddiFourParsedELF32_direct_load
    hEntryFetchable := by native_decide
    hSegmentsBounded := by native_decide
    hSegmentsDisjoint := by native_decide
    hParserSuccess := by native_decide }

theorem entryAddiFourELF32_parseELF32_exact :
    parseELF32 entryAddiFourELF32Bytes = some entryAddiFourParsedELF32Image := by
  native_decide

theorem entryAddiFourELF32_parse_loaded_fields
    (loadable : ElfLoadableImage)
    (hparse : parseSingleExecutableELF32
      entryAddiFourELF32Bytes entryAddiFourBaseMemory = some loadable) :
    loadable.image = entryAddiFourParsedELF32Image ∧
      loadable.loadedMemory = entryAddiFourParsedELF32LoadedMemory := by
  have hrecord := hparse
  unfold parseSingleExecutableELF32 at hrecord
  rw [entryAddiFourELF32_parseELF32_exact] at hrecord
  simp [entryAddiFourParsedELF32Image, entryAddiFourParsedELF32Segment,
    entryAddiFourParsedELF32_direct_load_expanded, entryAddiFourBaseMemory,
    entryAddiFourELF32Bytes, entryAddiFourParsedELF32LoadedMemory] at hrecord
  rcases hrecord with ⟨_, hrecord⟩
  have hloadable := Option.some.inj hrecord
  have himage := (congrArg
    (fun value : ElfLoadableImage => value.toElfLoadSpec.image) hloadable).symm
  have hbase := (congrArg
    (fun value : ElfLoadableImage => value.toElfLoadSpec.initialMemory) hloadable).symm
  constructor
  · exact himage
  · have hloadSuccess := loadable.hLoadSuccess
    rw [himage, hbase] at hloadSuccess
    have hmemory := hloadSuccess.symm.trans
      entryAddiFourParsedELF32_direct_load
    exact Option.some.inj hmemory

def entryAddiFourFixtureLoadedELFImage : LoadedELFImage :=
  entryAddiFourELF32AcceptedProfile.toLoadedELFImage

theorem entryAddiFourELF32_loads :
    (parseSingleExecutableELF32
      entryAddiFourELF32Bytes entryAddiFourBaseMemory).isSome = true := by
  native_decide

theorem entryAddiFourELF32_loadable_exists :
    ∃ loadable : ElfLoadableImage,
      parseSingleExecutableELF32
        entryAddiFourELF32Bytes entryAddiFourBaseMemory = some loadable :=
  Option.isSome_iff_exists.mp
    (by simpa using entryAddiFourELF32_loads)

def entryAddiFourLoadableImage : ElfLoadableImage :=
  (parseSingleExecutableELF32
    entryAddiFourELF32Bytes entryAddiFourBaseMemory).get
    (by native_decide)

def entryAddiFourLoadedELFImage : LoadedELFImage :=
  entryAddiFourLoadableImage.toLoadedELFImage

def LoadedELFImage.entryAddiFourPC (loaded : LoadedELFImage) : Nat → Word32
  | 0 => loaded.image.header.entry
  | slot + 1 => Word32.add (loaded.entryAddiFourPC slot) 4

structure LoadedELFImage.EntryAddiFour (loaded : LoadedELFImage) where
  segment : ELF32ProgramHeader
  singleSegment : loaded.image.programHeaders = #[segment]
  segmentLoadable : segment.segmentType = 1
  segmentExecutable : segment.isLoadableExecutable = true
  segmentStartsAtEntry : segment.virtualAddress = loaded.image.header.entry.toNat
  fileContainsCode : 20 ≤ segment.fileSize
  memoryContainsCode : 20 ≤ segment.memorySize
  entryCodeBytes : ∀ (index : Nat) (_hindex : index < 20),
    loaded.image.fileBytes[segment.fileOffset + index]? =
      entryAddiFourCodeBytes[index]?
  instructionPCAddresses : ∀ (slot : Nat) (_hslot : slot < 5),
    (loaded.entryAddiFourPC slot).toNat = loaded.image.header.entry.toNat + 4 * slot
  instructionPCFetchable : ∀ (slot : Nat) (_hslot : slot < 5),
    Memory.validRange loaded.memory (loaded.entryAddiFourPC slot).toNat 4 4 = true
  instructionPCExecutable : ∀ (slot : Nat) (_hslot : slot < 5),
    loaded.executableAddress (loaded.entryAddiFourPC slot).toNat

def entryAddiFourELF32_program :
    LoadedELFImage.EntryAddiFour entryAddiFourFixtureLoadedELFImage := by
  refine {
    segment := entryAddiFourParsedELF32Segment
    singleSegment := by native_decide
    segmentLoadable := by native_decide
    segmentExecutable := by native_decide
    segmentStartsAtEntry := by native_decide
    fileContainsCode := by native_decide
    memoryContainsCode := by native_decide
    entryCodeBytes := ?_
    instructionPCAddresses := ?_
    instructionPCFetchable := ?_
    instructionPCExecutable := ?_
  }
  · intro index hindex
    match index with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | 5 => native_decide
    | 6 => native_decide
    | 7 => native_decide
    | 8 => native_decide
    | 9 => native_decide
    | 10 => native_decide
    | 11 => native_decide
    | 12 => native_decide
    | 13 => native_decide
    | 14 => native_decide
    | 15 => native_decide
    | 16 => native_decide
    | 17 => native_decide
    | 18 => native_decide
    | 19 => native_decide
    | index + 20 => omega
  · intro slot hslot
    match slot with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | slot + 5 => omega
  · intro slot hslot
    match slot with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | slot + 5 => omega
  · intro slot hslot
    match slot with
    | 0 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 1 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 2 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 3 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 4 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | slot + 5 => omega

theorem entryAddiFourCanonicalParse_isSome :
    (parseSingleExecutableELF32
      entryAddiFourELF32Bytes rv32CanonicalBaseMemory).isSome = true := by
  native_decide

def entryAddiFourCanonicalLoadable : ElfLoadableImage :=
  (parseSingleExecutableELF32
    entryAddiFourELF32Bytes rv32CanonicalBaseMemory).get
    (by simpa using entryAddiFourCanonicalParse_isSome)

theorem entryAddiFourCanonicalLoadableAccepted :
    LoadableRV32IBinary entryAddiFourELF32Bytes := by
  refine ⟨entryAddiFourCanonicalLoadable, ?_⟩
  have hparse : parseSingleExecutableELF32
      entryAddiFourELF32Bytes rv32CanonicalBaseMemory =
        some entryAddiFourCanonicalLoadable := by
    simp [entryAddiFourCanonicalLoadable, entryAddiFourCanonicalParse_isSome]
  simp [classifyRV32Binary, hparse]

def entryAddiFourCanonicalLoadedELFImage : LoadedELFImage :=
  entryAddiFourCanonicalLoadable.toLoadedELFImage

def entryAddiFourCanonicalProgram :
    LoadedELFImage.EntryAddiFour entryAddiFourCanonicalLoadedELFImage := by
  refine {
    segment := entryAddiFourParsedELF32Segment
    singleSegment := by native_decide
    segmentLoadable := by native_decide
    segmentExecutable := by native_decide
    segmentStartsAtEntry := by native_decide
    fileContainsCode := by native_decide
    memoryContainsCode := by native_decide
    entryCodeBytes := ?_
    instructionPCAddresses := ?_
    instructionPCFetchable := ?_
    instructionPCExecutable := ?_
  }
  · intro index hindex
    match index with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | 5 => native_decide
    | 6 => native_decide
    | 7 => native_decide
    | 8 => native_decide
    | 9 => native_decide
    | 10 => native_decide
    | 11 => native_decide
    | 12 => native_decide
    | 13 => native_decide
    | 14 => native_decide
    | 15 => native_decide
    | 16 => native_decide
    | 17 => native_decide
    | 18 => native_decide
    | 19 => native_decide
    | index + 20 => omega
  · intro slot hslot
    match slot with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | slot + 5 => omega
  · intro slot hslot
    match slot with
    | 0 => native_decide
    | 1 => native_decide
    | 2 => native_decide
    | 3 => native_decide
    | 4 => native_decide
    | slot + 5 => omega
  · intro slot hslot
    match slot with
    | 0 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 1 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 2 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 3 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | 4 =>
        refine ⟨entryAddiFourParsedELF32Segment, ?_, by native_decide, by native_decide, by native_decide⟩
        native_decide
    | slot + 5 => omega

theorem LoadedELFImage.EntryAddiFour.loadedByte
  (program : LoadedELFImage.EntryAddiFour loaded) (slot lane : Nat)
    (hslot : slot < 5) (hlane : lane < 4) :
    loaded.memory.bytes
        ((program.segment.virtualAddress - loaded.memory.base.toNat) + slot * 4 + lane) =
      (entryAddiFourCodeBytes[slot * 4 + lane]?).getD 0 := by
  have hsegmentLoad := ELF32Image.loadMemory_single_loadable_segment
    loaded.image loaded.baseMemory loaded.memory program.segment program.singleSegment
    program.segmentLoadable loaded.loadSucceeded
  have hgeometry := loadSegment_success_preserves_geometry loaded.baseMemory
    loaded.memory loaded.image.fileBytes program.segment.fileOffset program.segment.fileSize
    program.segment.virtualAddress program.segment.memorySize hsegmentLoad
  have hfileSize := program.fileContainsCode
  have hindex : slot * 4 + lane < 20 := by omega
  have hstart : program.segment.virtualAddress - loaded.baseMemory.base.toNat ≤
      (program.segment.virtualAddress - loaded.baseMemory.base.toNat) + slot * 4 + lane := by
    omega
  have hfileBacked :
      (program.segment.virtualAddress - loaded.baseMemory.base.toNat) + slot * 4 + lane <
        program.segment.virtualAddress - loaded.baseMemory.base.toNat + program.segment.fileSize := by
    omega
  have hcopy := loadSegment_success_copies_file_byte loaded.baseMemory loaded.memory
    loaded.image.fileBytes program.segment.fileOffset program.segment.fileSize
    program.segment.virtualAddress program.segment.memorySize
    ((program.segment.virtualAddress - loaded.baseMemory.base.toNat) + slot * 4 + lane)
    hsegmentLoad hstart hfileBacked
  have hindexMap :
      program.segment.fileOffset +
          ((program.segment.virtualAddress - loaded.baseMemory.base.toNat) + slot * 4 + lane) -
            (program.segment.virtualAddress - loaded.baseMemory.base.toNat) =
        program.segment.fileOffset + slot * 4 + lane := by omega
  have hbytes := congrArg (fun bytes => bytes.getD 0)
    (program.entryCodeBytes (slot * 4 + lane) hindex)
  have hbase := congrArg UInt32.toNat hgeometry.1
  have hoffset : program.segment.virtualAddress - loaded.baseMemory.base.toNat =
      program.segment.virtualAddress - loaded.memory.base.toNat := by omega
  rw [hindexMap] at hcopy
  have hbaseNat : loaded.memory.base.toNat = loaded.baseMemory.base.toNat :=
    congrArg UInt32.toNat hgeometry.1
  rw [hbaseNat]
  calc
    loaded.memory.bytes
        (program.segment.virtualAddress - loaded.baseMemory.base.toNat + slot * 4 + lane) =
      (loaded.image.fileBytes[program.segment.fileOffset + slot * 4 + lane]?).getD 0 := hcopy
    _ = (entryAddiFourCodeBytes[slot * 4 + lane]?).getD 0 := by
      simpa [Nat.add_assoc] using hbytes

def entryAddiFourWord : Nat → BitVec 32
  | 0 => BitVec.ofNat 32 0x00100093
  | 1 => BitVec.ofNat 32 0x00200113
  | 2 => BitVec.ofNat 32 0x00308193
  | 3 => BitVec.ofNat 32 0x00408213
  | _ => BitVec.ofNat 32 0x00000073

def entryAddiFourInstruction : Nat → Instruction
  | 0 => .addi (Fin.mk 1 (by decide)) (Fin.mk 0 (by decide)) 1
  | 1 => .addi (Fin.mk 2 (by decide)) (Fin.mk 0 (by decide)) 2
  | 2 => .addi (Fin.mk 3 (by decide)) (Fin.mk 1 (by decide)) 3
  | 3 => .addi (Fin.mk 4 (by decide)) (Fin.mk 1 (by decide)) 4
  | _ => .ecall

def LoadedELFImage.entryAddiFourState1 (loaded : LoadedELFImage) : MachineState :=
  regWrite (MachineState.initial loaded.image.header.entry loaded.memory)
    (loaded.entryAddiFourPC 1) (Fin.mk 1 (by decide)) 1

def LoadedELFImage.entryAddiFourState2 (loaded : LoadedELFImage) : MachineState :=
  regWrite loaded.entryAddiFourState1 (loaded.entryAddiFourPC 2)
    (Fin.mk 2 (by decide)) 2

def LoadedELFImage.entryAddiFourState3 (loaded : LoadedELFImage) : MachineState :=
  regWrite loaded.entryAddiFourState2 (loaded.entryAddiFourPC 3)
    (Fin.mk 3 (by decide))
    (Word32.add (loaded.entryAddiFourState2.regs.read (Fin.mk 1 (by decide))) 3)

def LoadedELFImage.entryAddiFourState4 (loaded : LoadedELFImage) : MachineState :=
  regWrite loaded.entryAddiFourState3 (loaded.entryAddiFourPC 4)
    (Fin.mk 4 (by decide))
    (Word32.add (loaded.entryAddiFourState3.regs.read (Fin.mk 1 (by decide))) 4)

def LoadedELFImage.entryAddiFourState5 (loaded : LoadedELFImage) : MachineState :=
  { loaded.entryAddiFourState4 with terminal := .halted }

def LoadedELFImage.entryAddiFourState (loaded : LoadedELFImage) : Nat → MachineState
  | 0 => MachineState.initial loaded.image.header.entry loaded.memory
  | 1 => loaded.entryAddiFourState1
  | 2 => loaded.entryAddiFourState2
  | 3 => loaded.entryAddiFourState3
  | 4 => loaded.entryAddiFourState4
  | _ => loaded.entryAddiFourState5

theorem LoadedELFImage.EntryAddiFour.fetchesProgramWord
    (program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    fetch32 loaded.memory (loaded.entryAddiFourPC slot).toNat =
      some (entryAddiFourWord slot) := by
  have hentryRange := loaded.entryFetchable
  simp [Memory.validRange, loaded.entryAligned] at hentryRange
  have hbaseLeEntry :
      loaded.memory.base.toNat ≤ loaded.image.header.entry.toNat := by
    omega
  have haddress :
      (loaded.entryAddiFourPC slot).toNat - loaded.memory.base.toNat =
        program.segment.virtualAddress - loaded.memory.base.toNat + slot * 4 := by
    have hpc := program.instructionPCAddresses slot hslot
    calc
      (loaded.entryAddiFourPC slot).toNat - loaded.memory.base.toNat =
          (loaded.image.header.entry.toNat + 4 * slot) - loaded.memory.base.toNat := by
        rw [hpc]
      _ = (program.segment.virtualAddress - loaded.memory.base.toNat) + slot * 4 := by
        rw [program.segmentStartsAtEntry]
        omega
  have haligned : (loaded.entryAddiFourPC slot).toNat % 4 = 0 := by
    rw [program.instructionPCAddresses slot hslot]
    have hentry := loaded.entryAligned
    omega
  have hvalid := program.instructionPCFetchable slot hslot
  have hbyte (lane : Nat) (hlane : lane < 4) :
      loaded.memory.bytes
          ((loaded.entryAddiFourPC slot).toNat - loaded.memory.base.toNat + lane) =
        (entryAddiFourCodeBytes[slot * 4 + lane]?).getD 0 := by
    have hsource := program.loadedByte slot lane hslot hlane
    rw [← haddress] at hsource
    exact hsource
  let b0 := (entryAddiFourCodeBytes[slot * 4]?).getD 0
  let b1 := (entryAddiFourCodeBytes[slot * 4 + 1]?).getD 0
  let b2 := (entryAddiFourCodeBytes[slot * 4 + 2]?).getD 0
  let b3 := (entryAddiFourCodeBytes[slot * 4 + 3]?).getD 0
  have hfetch := fetch32_of_littleEndianBytes loaded.memory
    (loaded.entryAddiFourPC slot).toNat b0 b1 b2 b3 haligned hvalid
    (by simpa [b0] using hbyte 0 (by decide))
    (by simpa [b1] using hbyte 1 (by decide))
    (by simpa [b2] using hbyte 2 (by decide))
    (by simpa [b3] using hbyte 3 (by decide))
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourCodeBytes, b0, b1, b2, b3] using hfetch
  rcases hslots with hslot1 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourCodeBytes, b0, b1, b2, b3] using hfetch
  rcases hslots with hslot2 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourCodeBytes, b0, b1, b2, b3] using hfetch
  rcases hslots with hslot3 | hslot4
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourCodeBytes, b0, b1, b2, b3] using hfetch
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourCodeBytes, b0, b1, b2, b3] using hfetch

theorem LoadedELFImage.EntryAddiFour.decodedProgramWord
    (_program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    decodeBitVec32 (entryAddiFourWord slot) = .ok (entryAddiFourInstruction slot) := by
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourInstruction]
      using decodeBitVec32_entryAddiX1
  rcases hslots with hslot1 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourInstruction] using decodeBitVec32_entryAddiX2
  rcases hslots with hslot2 | hslots
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourInstruction] using decodeBitVec32_entryAddiX3
  rcases hslots with hslot3 | hslot4
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourInstruction] using decodeBitVec32_entryAddiX4
  · subst slot
    simpa [entryAddiFourWord, entryAddiFourInstruction] using decodeBitVec32_entryEcall

theorem LoadedELFImage.EntryAddiFour.stateAtPC
    (_program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    (loaded.entryAddiFourState slot).pc = loaded.entryAddiFourPC slot := by
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    rfl
  rcases hslots with hslot1 | hslots
  · subst slot
    rfl
  rcases hslots with hslot2 | hslots
  · subst slot
    rfl
  rcases hslots with hslot3 | hslot4
  · subst slot
    rfl
  · subst slot
    rfl

theorem LoadedELFImage.EntryAddiFour.stateAtMemory
    (_program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 6) :
    (loaded.entryAddiFourState slot).memory = loaded.memory := by
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 ∨ slot = 5 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    rfl
  rcases hslots with hslot1 | hslots
  · subst slot
    simp [LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState1,
      LoadedELFImage.entryAddiFourPC, regWrite, MachineState.initial]
  rcases hslots with hslot2 | hslots
  · subst slot
    simp [LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState1,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourPC,
      regWrite, MachineState.initial]
  rcases hslots with hslot3 | hslots
  · subst slot
    simp [LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState1,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourState3,
      LoadedELFImage.entryAddiFourPC, regWrite, MachineState.initial]
  rcases hslots with hslot4 | hslot5
  · subst slot
    simp [LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState1,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourState3,
      LoadedELFImage.entryAddiFourState4, LoadedELFImage.entryAddiFourPC,
      regWrite, MachineState.initial]
  · subst slot
    simp [LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState5,
      LoadedELFImage.entryAddiFourState4, LoadedELFImage.entryAddiFourState3,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourState1,
      LoadedELFImage.entryAddiFourPC, regWrite, MachineState.initial]

theorem LoadedELFImage.EntryAddiFour.stepAt
    (program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    step (loaded.entryAddiFourState slot) (entryAddiFourInstruction slot) =
      some (loaded.entryAddiFourState (slot + 1)) := by
  have hpc : (loaded.entryAddiFourState slot).pc.toNat % 4 = 0 := by
    rw [program.stateAtPC slot hslot, program.instructionPCAddresses slot hslot]
    have hEntry := loaded.entryAligned
    omega
  have hpcBool : ((loaded.entryAddiFourState slot).pc.toNat % 4 != 0) = false := by
    simp [hpc]
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add, hpcBool, loaded.entryAligned] <;> omega
  rcases hslots with hslot1 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add, hpcBool, loaded.entryAligned] <;> omega
  rcases hslots with hslot2 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourState3,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add, hpcBool, loaded.entryAligned] <;> omega
  rcases hslots with hslot3 | hslot4
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add, hpcBool, loaded.entryAligned] <;> omega
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState4, LoadedELFImage.entryAddiFourState5,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add, hpcBool, loaded.entryAligned] <;> omega

theorem LoadedELFImage.EntryAddiFour.binaryStepAt
    (program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    binaryStep (loaded.entryAddiFourState slot) =
      some (loaded.entryAddiFourState (slot + 1)) := by
  have hmemory := program.stateAtMemory slot (by omega)
  have hpc := program.stateAtPC slot hslot
  have hfetch :
      fetch32 (loaded.entryAddiFourState slot).memory
        (loaded.entryAddiFourState slot).pc.toNat = some (entryAddiFourWord slot) := by
    simpa only [hmemory, hpc] using program.fetchesProgramWord slot hslot
  exact binaryStep_eq_isaStep_of_fetch_decode _ _ (entryAddiFourWord slot)
    (entryAddiFourInstruction slot) hfetch
    (program.decodedProgramWord slot hslot) (program.stepAt slot hslot)

def LoadedELFImage.EntryAddiFour.stateTrace
    (_program : LoadedELFImage.EntryAddiFour loaded) : Trace :=
  { length := 6
    rows := fun index => loaded.entryAddiFourState index.val
    bounded := by decide }

def LoadedELFImage.HasSuccessfulEntryStep (loaded : LoadedELFImage) : Prop :=
  ∃ (word : BitVec 32) (instruction : Instruction) (next : MachineState),
    fetch32 loaded.memory loaded.image.header.entry.toNat = some word ∧
    decodeBitVec32 word = .ok instruction ∧
    step (MachineState.initial loaded.image.header.entry loaded.memory) instruction =
      some next ∧
    loaded.executableAddress next.pc.toNat

/-- Static entry-code condition for a program that halts on its first step. -/
structure LoadedELFImage.EntryEcall (loaded : LoadedELFImage) where
  word : BitVec 32
  fetchesEntry : fetch32 loaded.memory loaded.image.header.entry.toNat = some word
  decodesEntry : decodeBitVec32 word = .ok .ecall

/-- Static code condition for `addi x1, x0, 1; ecall`. -/
structure LoadedELFImage.EntryAddiEcall (loaded : LoadedELFImage) where
  addiWord : BitVec 32
  ecallWord : BitVec 32
  fetchesAddi : fetch32 loaded.memory loaded.image.header.entry.toNat = some addiWord
  decodesAddi : decodeBitVec32 addiWord =
    .ok (.addi ⟨1, by decide⟩ ⟨0, by decide⟩ 1)
  fetchesEcall : fetch32 loaded.memory
    (Word32.add loaded.image.header.entry 4).toNat = some ecallWord
  decodesEcall : decodeBitVec32 ecallWord = .ok .ecall
  ecallExecutable : loaded.executableAddress
    (Word32.add loaded.image.header.entry 4).toNat

/-- Integer ALU instructions whose modeled ISA steps always advance linearly. -/
inductive StraightLineALUInstruction : Instruction → Prop where
  | lui (rd : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.lui rd imm)
  | auipc (rd : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.auipc rd imm)
  | addi (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.addi rd rs1 imm)
  | slti (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.slti rd rs1 imm)
  | sltiu (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.sltiu rd rs1 imm)
  | xori (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.xori rd rs1 imm)
  | ori (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.ori rd rs1 imm)
  | andi (rd rs1 : Fin 32) (imm : Word32) :
      StraightLineALUInstruction (.andi rd rs1 imm)
  | slli (rd rs1 : Fin 32) (shamt : Nat) :
      StraightLineALUInstruction (.slli rd rs1 shamt)
  | srli (rd rs1 : Fin 32) (shamt : Nat) :
      StraightLineALUInstruction (.srli rd rs1 shamt)
  | srai (rd rs1 : Fin 32) (shamt : Nat) :
      StraightLineALUInstruction (.srai rd rs1 shamt)
  | add (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.add rd rs1 rs2)
  | sub (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.sub rd rs1 rs2)
  | sll (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.sll rd rs1 rs2)
  | slt (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.slt rd rs1 rs2)
  | sltu (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.sltu rd rs1 rs2)
  | xor (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.xor rd rs1 rs2)
  | srl (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.srl rd rs1 rs2)
  | sra (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.sra rd rs1 rs2)
  | or (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.or rd rs1 rs2)
  | and (rd rs1 rs2 : Fin 32) :
      StraightLineALUInstruction (.and rd rs1 rs2)

/-- A finite static code schedule of ALU instructions followed by a final
ECALL. The index is the entry PC and the natural number counts all steps,
including the terminating ECALL. -/
inductive StraightLineALUEcallProgram (loaded : LoadedELFImage) :
    Word32 → Nat → Type where
  | ecall {pc : Word32}
      (executable : loaded.executableAddress pc.toNat)
      (word : BitVec 32)
      (fetches : fetch32 loaded.memory pc.toNat = some word)
      (decodes : decodeBitVec32 word = .ok .ecall) :
      StraightLineALUEcallProgram loaded pc 1
  | alu {pc : Word32} {fuel : Nat}
      (executable : loaded.executableAddress pc.toNat)
      (instruction : Instruction)
      (instructionIsALU : StraightLineALUInstruction instruction)
      (word : BitVec 32)
      (fetches : fetch32 loaded.memory pc.toNat = some word)
      (decodes : decodeBitVec32 word = .ok instruction)
      (tail : StraightLineALUEcallProgram loaded
        (Word32.add pc 4) fuel) :
      StraightLineALUEcallProgram loaded pc (fuel + 1)

/-- Static code evidence for one arbitrary modeled integer ALU instruction
followed by ECALL. It contains no states or execution trace. -/
structure LoadedELFImage.EntryALUEcall (loaded : LoadedELFImage) where
  aluInstruction : Instruction
  aluInstructionIsALU : StraightLineALUInstruction aluInstruction
  aluWord : BitVec 32
  ecallWord : BitVec 32
  fetchesALU : fetch32 loaded.memory loaded.image.header.entry.toNat = some aluWord
  decodesALU : decodeBitVec32 aluWord = .ok aluInstruction
  fetchesEcall : fetch32 loaded.memory
    (Word32.add loaded.image.header.entry 4).toNat = some ecallWord
  decodesEcall : decodeBitVec32 ecallWord = .ok .ecall
  ecallExecutable : loaded.executableAddress
    (Word32.add loaded.image.header.entry 4).toNat

/--
A bounded state trace with the instruction bytes and decoded instruction
witnesses for every outgoing transition. The final row has no outgoing step.
-/
structure BinaryTrace where
  loadedImage : LoadedELFImage
  stateTrace : Trace
  wordAt : Nat → BitVec 32
  instructionAt : Nat → Instruction
  startsAtLoadedEntry : ∃ hnonempty : 0 < stateTrace.length,
    stateTrace.get 0 hnonempty =
      MachineState.initial loadedImage.image.header.entry loadedImage.memory
  transitions : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
    fetch32
        (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).memory
        (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat =
      some (wordAt index) ∧
    decodeBitVec32 (wordAt index) = .ok (instructionAt index) ∧
    step
        (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (instructionAt index) =
      some (stateTrace.get (index + 1) hnext)

theorem BinaryTrace.length_bounds (trace : BinaryTrace) :
    1 ≤ trace.stateTrace.length ∧ trace.stateTrace.length ≤ MAX_TRACE :=
  ⟨Nat.succ_le_of_lt trace.startsAtLoadedEntry.1, trace.stateTrace.bounded⟩

def BinaryTrace.finalState (trace : BinaryTrace) : MachineState :=
  trace.stateTrace.get (trace.stateTrace.length - 1) (by
    have hnonempty := trace.startsAtLoadedEntry.1
    omega)

theorem BinaryTrace.to_valid_trace (trace : BinaryTrace) :
    valid_trace trace.stateTrace := by
  refine ⟨trace.startsAtLoadedEntry.1, ?_, ?_⟩
  · rw [trace.startsAtLoadedEntry.2]
    exact ⟨trace.loadedImage.image.header.entry, trace.loadedImage.memory, rfl,
      by simpa [pcAligned, MachineState.initial] using trace.loadedImage.entryAligned⟩
  intro index hnext
  exact ⟨trace.instructionAt index, (trace.transitions index hnext).2.2⟩

theorem BinaryTrace.to_binaryValidTrace (trace : BinaryTrace) :
    binaryValidTrace trace.stateTrace := by
  refine ⟨trace.startsAtLoadedEntry.1, ?_, ?_⟩
  · rw [trace.startsAtLoadedEntry.2]
    exact ⟨trace.loadedImage.image.header.entry, trace.loadedImage.memory, rfl,
      by simpa [pcAligned, MachineState.initial] using trace.loadedImage.entryAligned⟩
  intro index hnext
  exact ⟨trace.wordAt index, trace.instructionAt index,
    (trace.transitions index hnext).1,
    (trace.transitions index hnext).2.1,
    (trace.transitions index hnext).2.2⟩

structure SuccessfulBinaryExecution where
  loadedImage : LoadedELFImage
  stateTrace : Trace
  startsAtLoadedEntry : ∃ hnonempty : 0 < stateTrace.length,
    stateTrace.get 0 hnonempty =
      MachineState.initial loadedImage.image.header.entry loadedImage.memory
  executablePCs : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
    loadedImage.executableAddress
      (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat
  successfulSteps : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
    { witness : BitVec 32 × Instruction //
      fetch32
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).memory
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat =
        some witness.1 ∧
      decodeBitVec32 witness.1 = .ok witness.2 ∧
      step
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
          witness.2 =
        some (stateTrace.get (index + 1) hnext) }

def SuccessfulBinaryExecution.finalState (execution : SuccessfulBinaryExecution) :
    MachineState :=
  execution.stateTrace.get (execution.stateTrace.length - 1) (by
    have hnonempty := execution.startsAtLoadedEntry.1
    omega)

structure SuccessfulEntryStep (loadedImage : LoadedELFImage) where
  word : BitVec 32
  instruction : Instruction
  nextState : MachineState
  fetchesEntry : fetch32 loadedImage.memory loadedImage.image.header.entry.toNat =
    some word
  decodesEntry : decodeBitVec32 word = .ok instruction
  executesEntry : step
      (MachineState.initial loadedImage.image.header.entry loadedImage.memory)
      instruction = some nextState
  nextPCExecutable : loadedImage.executableAddress nextState.pc.toNat

theorem SuccessfulEntryStep.binaryStep_success
    (entryStep : SuccessfulEntryStep loadedImage) :
    binaryStep
        (MachineState.initial loadedImage.image.header.entry loadedImage.memory) =
      some entryStep.nextState :=
  binaryStep_eq_isaStep_of_fetch_decode _ _ entryStep.word entryStep.instruction
    entryStep.fetchesEntry entryStep.decodesEntry entryStep.executesEntry

structure SuccessfulEntryExtension
    (entryStep : SuccessfulEntryStep loadedImage) where
  word : BitVec 32
  instruction : Instruction
  nextState : MachineState
  currentPCExecutable : loadedImage.executableAddress entryStep.nextState.pc.toNat
  fetchesCurrent : fetch32 entryStep.nextState.memory entryStep.nextState.pc.toNat =
    some word
  decodesCurrent : decodeBitVec32 word = .ok instruction
  executesCurrent : step entryStep.nextState instruction = some nextState
  nextPCExecutable : loadedImage.executableAddress nextState.pc.toNat

theorem SuccessfulEntryExtension.binaryStep_success
    (extension : SuccessfulEntryExtension entryStep) :
    binaryStep entryStep.nextState = some extension.nextState :=
  binaryStep_eq_isaStep_of_fetch_decode _ _ extension.word extension.instruction
    extension.fetchesCurrent extension.decodesCurrent extension.executesCurrent

theorem SuccessfulEntryExtension.currentPC_aligned
    (extension : SuccessfulEntryExtension entryStep) :
    entryStep.nextState.pc.toNat % 4 = 0 :=
  (fetch32_success_implies_aligned_and_valid entryStep.nextState.memory
    entryStep.nextState.pc.toNat extension.word extension.fetchesCurrent).1

theorem SuccessfulEntryExtension.currentPC_fetchable
    (extension : SuccessfulEntryExtension entryStep) :
    Memory.validRange entryStep.nextState.memory entryStep.nextState.pc.toNat 4 4 = true :=
  (fetch32_success_implies_aligned_and_valid entryStep.nextState.memory
    entryStep.nextState.pc.toNat extension.word extension.fetchesCurrent).2

def SuccessfulEntryExtension.stateTrace
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) : Trace :=
  { length := 3
    rows := fun index =>
      if index.val = 0 then
        MachineState.initial loadedImage.image.header.entry loadedImage.memory
      else if index.val = 1 then
        entryStep.nextState
      else
        extension.nextState
    bounded := by decide }

def SuccessfulEntryExtension.toSuccessfulBinaryExecution
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) : SuccessfulBinaryExecution := by
  let stateTrace := extension.stateTrace
  have hlength : stateTrace.length = 3 := rfl
  refine ⟨loadedImage, stateTrace, ?_, ?_, ?_⟩
  · refine ⟨by omega, ?_⟩
    simp [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get]
  · intro index hnext
    by_cases hindex : index = 0
    · subst index
      simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
        loadedImage.entry_is_executable
    · have hindexOne : index = 1 := by omega
      subst index
      simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
        extension.currentPCExecutable
  · intro index hnext
    by_cases hindex : index = 0
    · subst index
      refine ⟨(entryStep.word, entryStep.instruction), ?_⟩
      refine ⟨?_, entryStep.decodesEntry, ?_⟩
      · simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
          entryStep.fetchesEntry
      · simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
          entryStep.executesEntry
    · have hindexOne : index = 1 := by omega
      subst index
      refine ⟨(extension.word, extension.instruction), ?_⟩
      refine ⟨?_, extension.decodesCurrent, ?_⟩
      · simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
          extension.fetchesCurrent
      · simpa [stateTrace, SuccessfulEntryExtension.stateTrace, Trace.get] using
          extension.executesCurrent

theorem SuccessfulEntryExtension.toSuccessfulBinaryExecution_length
    (extension : SuccessfulEntryExtension entryStep) :
    (SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension).stateTrace.length =
      3 := rfl

def SuccessfulEntryStep.stateTrace (entryStep : SuccessfulEntryStep loadedImage) : Trace :=
  { length := 2
    rows := fun index =>
      if index.val = 0 then
        MachineState.initial loadedImage.image.header.entry loadedImage.memory
      else
        entryStep.nextState
    bounded := by decide }

def SuccessfulEntryStep.toSuccessfulBinaryExecution
    (entryStep : SuccessfulEntryStep loadedImage) : SuccessfulBinaryExecution := by
  refine ⟨loadedImage, entryStep.stateTrace, ?_, ?_, ?_⟩
  · refine ⟨by simp [SuccessfulEntryStep.stateTrace], ?_⟩
    simp [SuccessfulEntryStep.stateTrace, Trace.get]
  · intro index hnext
    have hindex : index = 0 := by
      simp [SuccessfulEntryStep.stateTrace] at hnext
      omega
    subst index
    simpa [SuccessfulEntryStep.stateTrace, Trace.get] using
      loadedImage.entry_is_executable
  · intro index hnext
    have hindex : index = 0 := by
      simp [SuccessfulEntryStep.stateTrace] at hnext
      omega
    subst index
    refine ⟨(entryStep.word, entryStep.instruction), ?_⟩
    refine ⟨?_, entryStep.decodesEntry, ?_⟩
    · simpa [SuccessfulEntryStep.stateTrace, Trace.get] using entryStep.fetchesEntry
    · simpa [SuccessfulEntryStep.stateTrace, Trace.get] using entryStep.executesEntry

theorem SuccessfulEntryStep.toSuccessfulBinaryExecution_length
    (entryStep : SuccessfulEntryStep loadedImage) :
    entryStep.toSuccessfulBinaryExecution.stateTrace.length = 2 := rfl

theorem SuccessfulEntryStep.toSuccessfulBinaryExecution_nextPC_executable
    (entryStep : SuccessfulEntryStep loadedImage) :
    loadedImage.executableAddress entryStep.nextState.pc.toNat :=
  entryStep.nextPCExecutable

def SuccessfulBinaryExecution.ofBinarySteps
    (loadedImage : LoadedELFImage) (stateTrace : Trace)
    (startsAtLoadedEntry : ∃ hnonempty : 0 < stateTrace.length,
      stateTrace.get 0 hnonempty =
        MachineState.initial loadedImage.image.header.entry loadedImage.memory)
    (executablePCs : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
      loadedImage.executableAddress
        (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat)
    (successfulSteps : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
      binaryStep
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)) =
        some (stateTrace.get (index + 1) hnext)) :
    SuccessfulBinaryExecution :=
  ⟨loadedImage, stateTrace, startsAtLoadedEntry, executablePCs,
    fun index hnext => binaryStep_success_has_fetch_decode_step_data
      (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
      (stateTrace.get (index + 1) hnext) (successfulSteps index hnext)⟩

theorem StraightLineALUInstruction.step_properties
    (state : MachineState) (instruction : Instruction)
    (hrunning : state.terminal = .running)
    (haligned : pcAligned state)
    (halu : StraightLineALUInstruction instruction) :
    ∃ next, step state instruction = some next ∧
      next.pc = nextPC state ∧ next.memory = state.memory ∧
      next.terminal = .running := by
  have hpcEq : state.pc.toNat % 4 = 0 := haligned
  have hpcBool : (state.pc.toNat % 4 != 0) = false := by simp [hpcEq]
  cases halu <;>
    simp [step, regWrite, nextPC, hrunning, hpcBool, RegisterFile.read,
      RegisterFile.write, wordAnd, wordOr, wordXor, shiftLeft,
      shiftRightLogical, shiftRightArithmetic, boolWord]

noncomputable def StraightLineALUInstruction.nextState
    (state : MachineState) (instruction : Instruction)
    (hrunning : state.terminal = .running)
    (haligned : pcAligned state)
    (halu : StraightLineALUInstruction instruction) : MachineState :=
  Classical.choose (step_properties state instruction hrunning haligned halu)

theorem StraightLineALUInstruction.nextState_spec
    (state : MachineState) (instruction : Instruction)
    (hrunning : state.terminal = .running)
    (haligned : pcAligned state)
    (halu : StraightLineALUInstruction instruction) :
    step state instruction = some (nextState state instruction hrunning haligned halu) ∧
      (nextState state instruction hrunning haligned halu).pc = nextPC state ∧
      (nextState state instruction hrunning haligned halu).memory = state.memory ∧
      (nextState state instruction hrunning haligned halu).terminal = .running :=
  Classical.choose_spec (step_properties state instruction hrunning haligned halu)

noncomputable def LoadedELFImage.EntryALUEcall.intermediateState
    (program : LoadedELFImage.EntryALUEcall loaded) : MachineState :=
  StraightLineALUInstruction.nextState
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.aluInstruction rfl loaded.initial_state_pcAligned
    program.aluInstructionIsALU

theorem LoadedELFImage.EntryALUEcall.intermediateState_spec
    (program : LoadedELFImage.EntryALUEcall loaded) :
    step (MachineState.initial loaded.image.header.entry loaded.memory)
        program.aluInstruction = some program.intermediateState ∧
      program.intermediateState.pc =
        Word32.add loaded.image.header.entry 4 ∧
      program.intermediateState.memory = loaded.memory ∧
      program.intermediateState.terminal = .running := by
  exact StraightLineALUInstruction.nextState_spec
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.aluInstruction rfl loaded.initial_state_pcAligned
    program.aluInstructionIsALU

noncomputable def LoadedELFImage.EntryALUEcall.finalState
    (program : LoadedELFImage.EntryALUEcall loaded) : MachineState :=
  { program.intermediateState with terminal := .halted }

noncomputable def LoadedELFImage.EntryALUEcall.stateAt
    (program : LoadedELFImage.EntryALUEcall loaded) : Nat → MachineState
  | 0 => MachineState.initial loaded.image.header.entry loaded.memory
  | 1 => program.intermediateState
  | _ => program.finalState

noncomputable def LoadedELFImage.EntryALUEcall.stateTrace
    (program : LoadedELFImage.EntryALUEcall loaded) : Trace :=
  { length := 3
    rows := fun index => program.stateAt index.val
    bounded := by decide }

noncomputable def LoadedELFImage.EntryALUEcall.toSuccessfulBinaryExecution
    (program : LoadedELFImage.EntryALUEcall loaded) :
    SuccessfulBinaryExecution := by
  have hspec := program.intermediateState_spec
  have hstateAligned := step_preserves_pcAligned
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.aluInstruction program.intermediateState
    loaded.initial_state_pcAligned hspec.1
  have hpcEq : program.intermediateState.pc.toNat % 4 = 0 := hstateAligned
  have hpcBool : (program.intermediateState.pc.toNat % 4 != 0) = false := by
    simp [hpcEq]
  have hstepEcall :
      step program.intermediateState .ecall = some program.finalState := by
    simp [LoadedELFImage.EntryALUEcall.finalState, step, hspec.2.2.2, hpcBool]
  have hbinaryALU := binaryStep_eq_isaStep_of_fetch_decode
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.intermediateState program.aluWord program.aluInstruction
    program.fetchesALU program.decodesALU hspec.1
  have hbinaryEcall := binaryStep_eq_isaStep_of_fetch_decode
    program.intermediateState program.finalState program.ecallWord .ecall
    (by rw [hspec.2.1, hspec.2.2.1]; exact program.fetchesEcall)
    program.decodesEcall hstepEcall
  refine SuccessfulBinaryExecution.ofBinarySteps loaded program.stateTrace ?_ ?_ ?_
  · refine ⟨by simp [LoadedELFImage.EntryALUEcall.stateTrace], ?_⟩
    simp [LoadedELFImage.EntryALUEcall.stateTrace,
      LoadedELFImage.EntryALUEcall.stateAt, Trace.get]
  · intro index hnext
    have hnext' : index + 1 < 3 := by
      simpa [LoadedELFImage.EntryALUEcall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 := by omega
    rcases hindex with hzero | hone
    · subst index
      simpa [LoadedELFImage.EntryALUEcall.stateTrace,
        LoadedELFImage.EntryALUEcall.stateAt, Trace.get] using
          loaded.entry_is_executable
    · subst index
      simpa [LoadedELFImage.EntryALUEcall.stateTrace,
        LoadedELFImage.EntryALUEcall.stateAt, Trace.get,
        hspec.2.1] using program.ecallExecutable
  · intro index hnext
    have hnext' : index + 1 < 3 := by
      simpa [LoadedELFImage.EntryALUEcall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 := by omega
    rcases hindex with hzero | hone
    · subst index
      simpa [LoadedELFImage.EntryALUEcall.stateTrace,
        LoadedELFImage.EntryALUEcall.stateAt, Trace.get] using hbinaryALU
    · subst index
      simpa [LoadedELFImage.EntryALUEcall.stateTrace,
        LoadedELFImage.EntryALUEcall.stateAt, Trace.get] using hbinaryEcall

theorem LoadedELFImage.EntryALUEcall.toSuccessfulBinaryExecution_halts
    (program : LoadedELFImage.EntryALUEcall loaded) :
    program.toSuccessfulBinaryExecution.finalState.terminal = .halted := by
  simp [SuccessfulBinaryExecution.finalState,
    LoadedELFImage.EntryALUEcall.toSuccessfulBinaryExecution,
    SuccessfulBinaryExecution.ofBinarySteps,
    LoadedELFImage.EntryALUEcall.stateTrace,
    LoadedELFImage.EntryALUEcall.stateAt,
    LoadedELFImage.EntryALUEcall.finalState, Trace.get]

/-- Static code condition for a short finite ALU instruction sequence followed by
ECALL. This is the largest practical straight-line subclass currently supported
without introducing unproved generalized recursion. -/
structure LoadedELFImage.EntryALU2Ecall (loaded : LoadedELFImage) where
  firstInstruction : Instruction
  firstIsALU : StraightLineALUInstruction firstInstruction
  secondInstruction : Instruction
  secondIsALU : StraightLineALUInstruction secondInstruction
  firstWord : BitVec 32
  secondWord : BitVec 32
  ecallWord : BitVec 32
  fetchesFirst : fetch32 loaded.memory loaded.image.header.entry.toNat = some firstWord
  decodesFirst : decodeBitVec32 firstWord = .ok firstInstruction
  fetchesSecond : fetch32 loaded.memory
    (Word32.add loaded.image.header.entry 4).toNat = some secondWord
  decodesSecond : decodeBitVec32 secondWord = .ok secondInstruction
  fetchesEcall : fetch32 loaded.memory
    (Word32.add loaded.image.header.entry 8).toNat = some ecallWord
  decodesEcall : decodeBitVec32 ecallWord = .ok .ecall
  firstExecutable : loaded.executableAddress loaded.image.header.entry.toNat
  secondExecutable : loaded.executableAddress
    (Word32.add loaded.image.header.entry 4).toNat
  ecallExecutable : loaded.executableAddress
    (Word32.add loaded.image.header.entry 8).toNat

noncomputable def LoadedELFImage.EntryALU2Ecall.stateAfterFirst
    (program : LoadedELFImage.EntryALU2Ecall loaded) : MachineState :=
  StraightLineALUInstruction.nextState
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.firstInstruction rfl loaded.initial_state_pcAligned
    program.firstIsALU

theorem LoadedELFImage.EntryALU2Ecall.stateAfterFirst_spec
    (program : LoadedELFImage.EntryALU2Ecall loaded) :
    step (MachineState.initial loaded.image.header.entry loaded.memory)
        program.firstInstruction = some program.stateAfterFirst ∧
      program.stateAfterFirst.pc = Word32.add loaded.image.header.entry 4 ∧
      program.stateAfterFirst.memory = loaded.memory ∧
      program.stateAfterFirst.terminal = .running := by
  exact StraightLineALUInstruction.nextState_spec
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.firstInstruction rfl loaded.initial_state_pcAligned
    program.firstIsALU

noncomputable def LoadedELFImage.EntryALU2Ecall.stateAfterSecond
    (program : LoadedELFImage.EntryALU2Ecall loaded) : MachineState := by
  have hfirst := program.stateAfterFirst_spec
  have hfirstAligned : pcAligned program.stateAfterFirst := by
    change program.stateAfterFirst.pc.toNat % 4 = 0
    rw [hfirst.2.1]
    exact nextPC_preserves_pcAligned
      (MachineState.initial loaded.image.header.entry loaded.memory)
      loaded.initial_state_pcAligned
  exact StraightLineALUInstruction.nextState program.stateAfterFirst
    program.secondInstruction hfirst.2.2.2 hfirstAligned
    program.secondIsALU

 theorem LoadedELFImage.EntryALU2Ecall.stateAfterSecond_spec
    (program : LoadedELFImage.EntryALU2Ecall loaded) :
    step program.stateAfterFirst program.secondInstruction = some program.stateAfterSecond ∧
      program.stateAfterSecond.pc = Word32.add loaded.image.header.entry 8 ∧
      program.stateAfterSecond.memory = loaded.memory ∧
      program.stateAfterSecond.terminal = .running := by
  have hfirst := program.stateAfterFirst_spec
  have hfirstAligned : pcAligned program.stateAfterFirst := by
    change program.stateAfterFirst.pc.toNat % 4 = 0
    rw [hfirst.2.1]
    exact nextPC_preserves_pcAligned
      (MachineState.initial loaded.image.header.entry loaded.memory)
      loaded.initial_state_pcAligned
  have hsecond := StraightLineALUInstruction.nextState_spec
    program.stateAfterFirst program.secondInstruction
    hfirst.2.2.2 hfirstAligned program.secondIsALU
  refine ⟨?_, ?_, ?_, hsecond.2.2.2⟩
  · simpa [LoadedELFImage.EntryALU2Ecall.stateAfterSecond] using hsecond.1
  · calc
      program.stateAfterSecond.pc = nextPC program.stateAfterFirst := by
        simpa [LoadedELFImage.EntryALU2Ecall.stateAfterSecond] using hsecond.2.1
      _ = Word32.add loaded.image.header.entry 8 := by
        rw [nextPC, hfirst.2.1]
        change (loaded.image.header.entry + 4) + 4 =
          loaded.image.header.entry + 8
        rw [UInt32.add_assoc]
        rw [show (4 : UInt32) + 4 = 8 by decide]
  · simpa [LoadedELFImage.EntryALU2Ecall.stateAfterSecond,
      hfirst.2.2.1] using hsecond.2.2.1

noncomputable def LoadedELFImage.EntryALU2Ecall.finalState
    (program : LoadedELFImage.EntryALU2Ecall loaded) : MachineState :=
  { program.stateAfterSecond with terminal := .halted }

noncomputable def LoadedELFImage.EntryALU2Ecall.stateAt
    (program : LoadedELFImage.EntryALU2Ecall loaded) : Nat → MachineState
  | 0 => MachineState.initial loaded.image.header.entry loaded.memory
  | 1 => program.stateAfterFirst
  | 2 => program.stateAfterSecond
  | _ => program.finalState

noncomputable def LoadedELFImage.EntryALU2Ecall.stateTrace
    (program : LoadedELFImage.EntryALU2Ecall loaded) : Trace :=
  { length := 4
    rows := fun index => program.stateAt index.val
    bounded := by decide }

noncomputable def LoadedELFImage.EntryALU2Ecall.toSuccessfulBinaryExecution
    (program : LoadedELFImage.EntryALU2Ecall loaded) :
    SuccessfulBinaryExecution := by
  have hfirst := program.stateAfterFirst_spec
  have hsecond := program.stateAfterSecond_spec
  have hstepEcall :
      step program.stateAfterSecond .ecall = some program.finalState := by
    have hstateAligned := step_preserves_pcAligned
      program.stateAfterFirst program.secondInstruction program.stateAfterSecond
      (by
        have hfirstAligned : pcAligned program.stateAfterFirst := by
          change program.stateAfterFirst.pc.toNat % 4 = 0
          rw [hfirst.2.1]
          exact nextPC_preserves_pcAligned
            (MachineState.initial loaded.image.header.entry loaded.memory)
            loaded.initial_state_pcAligned
        exact hfirstAligned)
      hsecond.1
    have hpcEq : program.stateAfterSecond.pc.toNat % 4 = 0 := hstateAligned
    have hpcBool : (program.stateAfterSecond.pc.toNat % 4 != 0) = false := by
      simp [hpcEq]
    simp [LoadedELFImage.EntryALU2Ecall.finalState, step, hsecond.2.2.2, hpcBool]
  have hbinaryFirst := binaryStep_eq_isaStep_of_fetch_decode
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.stateAfterFirst program.firstWord program.firstInstruction
    program.fetchesFirst program.decodesFirst hfirst.1
  have hbinarySecond := binaryStep_eq_isaStep_of_fetch_decode
    program.stateAfterFirst program.stateAfterSecond program.secondWord
    program.secondInstruction
    (by rw [hfirst.2.1, hfirst.2.2.1]; exact program.fetchesSecond)
    program.decodesSecond hsecond.1
  have hbinaryEcall := binaryStep_eq_isaStep_of_fetch_decode
    program.stateAfterSecond program.finalState program.ecallWord .ecall
    (by rw [hsecond.2.1, hsecond.2.2.1]; exact program.fetchesEcall)
    program.decodesEcall hstepEcall
  refine SuccessfulBinaryExecution.ofBinarySteps loaded program.stateTrace ?_ ?_ ?_
  · refine ⟨by simp [LoadedELFImage.EntryALU2Ecall.stateTrace], ?_⟩
    simp [LoadedELFImage.EntryALU2Ecall.stateTrace,
      LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get]
  · intro index hnext
    have hnext' : index + 1 < 4 := by
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 ∨ index = 2 := by omega
    rcases hindex with hzero | hone | htwo
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get] using
          loaded.entry_is_executable
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get,
        hfirst.2.1] using program.secondExecutable
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get,
        hsecond.2.1] using program.ecallExecutable
  · intro index hnext
    have hnext' : index + 1 < 4 := by
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 ∨ index = 2 := by omega
    rcases hindex with hzero | hone | htwo
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get] using hbinaryFirst
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get] using hbinarySecond
    · subst index
      simpa [LoadedELFImage.EntryALU2Ecall.stateTrace,
        LoadedELFImage.EntryALU2Ecall.stateAt, Trace.get] using hbinaryEcall

theorem LoadedELFImage.EntryALU2Ecall.toSuccessfulBinaryExecution_halts
    (_program : LoadedELFImage.EntryALU2Ecall loaded) :
    _program.toSuccessfulBinaryExecution.finalState.terminal = .halted := by
  simp [SuccessfulBinaryExecution.finalState,
    LoadedELFImage.EntryALU2Ecall.toSuccessfulBinaryExecution,
    SuccessfulBinaryExecution.ofBinarySteps,
    LoadedELFImage.EntryALU2Ecall.stateTrace,
    LoadedELFImage.EntryALU2Ecall.stateAt,
    LoadedELFImage.EntryALU2Ecall.finalState, Trace.get]

def LoadedELFImage.EntryAddiEcall.stateAfterAddi
    (_program : LoadedELFImage.EntryAddiEcall loaded) : MachineState :=
  regWrite (MachineState.initial loaded.image.header.entry loaded.memory)
    (Word32.add loaded.image.header.entry 4) ⟨1, by decide⟩ 1

def LoadedELFImage.EntryAddiEcall.finalState
    (program : LoadedELFImage.EntryAddiEcall loaded) : MachineState :=
  { program.stateAfterAddi with terminal := .halted }

def LoadedELFImage.EntryAddiEcall.stateAt
    (program : LoadedELFImage.EntryAddiEcall loaded) : Nat → MachineState
  | 0 => MachineState.initial loaded.image.header.entry loaded.memory
  | 1 => program.stateAfterAddi
  | _ => program.finalState

def LoadedELFImage.EntryAddiEcall.stateTrace
    (program : LoadedELFImage.EntryAddiEcall loaded) : Trace :=
  { length := 3
    rows := fun index => program.stateAt index.val
    bounded := by decide }

def LoadedELFImage.EntryAddiEcall.toSuccessfulBinaryExecution
    (program : LoadedELFImage.EntryAddiEcall loaded) :
    SuccessfulBinaryExecution := by
  have hinitialPCBool :
      (loaded.image.header.entry.toNat % 4 != 0) = false := by
    simp [loaded.entryAligned]
  have hstepAddi :
      step (MachineState.initial loaded.image.header.entry loaded.memory)
        (.addi ⟨1, by decide⟩ ⟨0, by decide⟩ 1) =
          some program.stateAfterAddi := by
    simp [LoadedELFImage.EntryAddiEcall.stateAfterAddi, step, regWrite,
      nextPC, MachineState.initial, regRead, RegisterFile.read, Word32.add,
      hinitialPCBool]
  have hrunning : program.stateAfterAddi.terminal ≠ .halted := by
    simp [LoadedELFImage.EntryAddiEcall.stateAfterAddi, regWrite,
      MachineState.initial]
  have hstepEcall :
      step program.stateAfterAddi .ecall = some program.finalState := by
    have hstateAligned := step_preserves_pcAligned
      (MachineState.initial loaded.image.header.entry loaded.memory)
      (.addi ⟨1, by decide⟩ ⟨0, by decide⟩ 1)
      program.stateAfterAddi loaded.initial_state_pcAligned hstepAddi
    have hpcEq : program.stateAfterAddi.pc.toNat % 4 = 0 := hstateAligned
    have hpcBool : (program.stateAfterAddi.pc.toNat % 4 != 0) = false := by
      simp [hpcEq]
    simp [LoadedELFImage.EntryAddiEcall.finalState, step, hrunning, hpcBool]
  have hbinaryAddi := binaryStep_eq_isaStep_of_fetch_decode
    (MachineState.initial loaded.image.header.entry loaded.memory)
    program.stateAfterAddi program.addiWord
    (.addi ⟨1, by decide⟩ ⟨0, by decide⟩ 1)
    program.fetchesAddi program.decodesAddi hstepAddi
  have hbinaryEcall := binaryStep_eq_isaStep_of_fetch_decode
    program.stateAfterAddi program.finalState program.ecallWord .ecall
    program.fetchesEcall program.decodesEcall hstepEcall
  refine SuccessfulBinaryExecution.ofBinarySteps loaded program.stateTrace ?_ ?_ ?_
  · refine ⟨by simp [LoadedELFImage.EntryAddiEcall.stateTrace], ?_⟩
    simp [LoadedELFImage.EntryAddiEcall.stateTrace,
      LoadedELFImage.EntryAddiEcall.stateAt, Trace.get]
  · intro index hnext
    have hnext' : index + 1 < 3 := by
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 := by omega
    rcases hindex with hzero | hone
    · subst index
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace,
        LoadedELFImage.EntryAddiEcall.stateAt, Trace.get] using
          loaded.entry_is_executable
    · subst index
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace,
        LoadedELFImage.EntryAddiEcall.stateAt, Trace.get] using
          program.ecallExecutable
  · intro index hnext
    have hnext' : index + 1 < 3 := by
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace] using hnext
    have hindex : index = 0 ∨ index = 1 := by omega
    rcases hindex with hzero | hone
    · subst index
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace,
        LoadedELFImage.EntryAddiEcall.stateAt, Trace.get] using hbinaryAddi
    · subst index
      simpa [LoadedELFImage.EntryAddiEcall.stateTrace,
        LoadedELFImage.EntryAddiEcall.stateAt, Trace.get] using hbinaryEcall

theorem LoadedELFImage.EntryAddiEcall.toSuccessfulBinaryExecution_halts
    (program : LoadedELFImage.EntryAddiEcall loaded) :
    program.toSuccessfulBinaryExecution.finalState.terminal = .halted := by
  simp [SuccessfulBinaryExecution.finalState,
    LoadedELFImage.EntryAddiEcall.toSuccessfulBinaryExecution,
    SuccessfulBinaryExecution.ofBinarySteps,
    LoadedELFImage.EntryAddiEcall.stateTrace,
    LoadedELFImage.EntryAddiEcall.stateAt,
    LoadedELFImage.EntryAddiEcall.finalState, Trace.get]

def LoadedELFImage.EntryAddiFour.toSuccessfulBinaryExecution
    (program : LoadedELFImage.EntryAddiFour loaded) : SuccessfulBinaryExecution := by
  refine SuccessfulBinaryExecution.ofBinarySteps loaded program.stateTrace ?_ ?_ ?_
  · have hlength : program.stateTrace.length = 6 := rfl
    refine ⟨by rw [hlength]; omega, ?_⟩
    simp [LoadedELFImage.EntryAddiFour.stateTrace, Trace.get,
      LoadedELFImage.entryAddiFourState]
  · intro index hnext
    have hlength : program.stateTrace.length = 6 := rfl
    rw [hlength] at hnext
    have hslot : index < 5 := by omega
    have hpc := program.stateAtPC index hslot
    simpa [LoadedELFImage.EntryAddiFour.stateTrace, Trace.get, hpc] using
      program.instructionPCExecutable index hslot
  · intro index hnext
    have hlength : program.stateTrace.length = 6 := rfl
    rw [hlength] at hnext
    have hslot : index < 5 := by omega
    simpa [LoadedELFImage.EntryAddiFour.stateTrace, Trace.get] using
      program.binaryStepAt index hslot

theorem LoadedELFImage.EntryAddiFour.toSuccessfulBinaryExecution_length
    (program : LoadedELFImage.EntryAddiFour loaded) :
    program.toSuccessfulBinaryExecution.stateTrace.length = 6 := rfl

def SuccessfulBinaryExecution.toBinaryTrace
    (execution : SuccessfulBinaryExecution) : BinaryTrace := by
  let witnessAt := fun (index : Nat) =>
    if hnext : index + 1 < execution.stateTrace.length then
      (execution.successfulSteps index hnext).1
    else
      (BitVec.ofNat 32 0, Instruction.ecall)
  refine ⟨execution.loadedImage, execution.stateTrace,
    fun index => (witnessAt index).1,
    fun index => (witnessAt index).2,
    execution.startsAtLoadedEntry, ?_⟩
  intro index hnext
  let witness := execution.successfulSteps index hnext
  exact ⟨by simpa [witnessAt, hnext] using witness.property.1,
    by simpa [witnessAt, hnext] using witness.property.2.1,
    by simpa [witnessAt, hnext] using witness.property.2.2⟩

theorem SuccessfulBinaryExecution.toBinaryTrace_projects_valid_trace
    (execution : SuccessfulBinaryExecution) :
    valid_trace execution.stateTrace :=
  BinaryTrace.to_valid_trace execution.toBinaryTrace

def prependStateTrace (state : MachineState) (trace : Trace)
    (hcapacity : trace.length < MAX_TRACE) : Trace where
  length := trace.length + 1
  rows := fun index =>
    if hzero : index.val = 0 then
      state
    else
      trace.rows ⟨index.val - 1, by omega⟩
  bounded := by
    have hbound := trace.bounded
    omega

theorem prependStateTrace_get_first (state : MachineState) (trace : Trace)
    (hcapacity : trace.length < MAX_TRACE) :
    (prependStateTrace state trace hcapacity).get 0 (by
      simp [prependStateTrace]) = state := by
  simp [prependStateTrace, Trace.get]

theorem prependStateTrace_get_succ (state : MachineState) (trace : Trace)
    (hcapacity : trace.length < MAX_TRACE) (index : Nat)
    (hindex : index < trace.length) :
    (prependStateTrace state trace hcapacity).get (index + 1) (by
      simp [prependStateTrace]
      omega) = trace.get index hindex := by
  simp [prependStateTrace, Trace.get, hindex]

inductive TotalOutcomeSuccessfulPath (loaded : LoadedELFImage) :
    MachineState → Nat → Type where
  | stop {state : MachineState} {fuel : Nat} :
      TotalOutcomeSuccessfulPath loaded state fuel
  | step {state next : MachineState} {fuel : Nat}
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = some next)
      (remaining : TotalOutcomeSuccessfulPath loaded next fuel) :
      TotalOutcomeSuccessfulPath loaded state (fuel + 1)

def TotalLoadedBinaryOutcome.toSuccessfulPath
    {loaded : LoadedELFImage} {state : MachineState} {fuel : Nat} :
    TotalLoadedBinaryOutcome loaded state fuel →
      TotalOutcomeSuccessfulPath loaded state fuel
  | .halted _ => .stop
  | .fuelExhausted _ _ => .stop
  | .nonExecutablePC _ _ => .stop
  | .fetchFault _ _ _ => .stop
  | .decodeFault _ _ _ _ _ _ => .stop
  | .executionFault _ _ _ _ _ _ _ => .stop
  | .haltedAfterStep _ hexecutable word hfetch instruction hdecode hstep _ =>
      .step hexecutable word hfetch instruction hdecode hstep .stop
  | .continued _ hexecutable word hfetch instruction hdecode hstep _ remaining =>
      .step hexecutable word hfetch instruction hdecode hstep
        remaining.toSuccessfulPath

structure TotalOutcomePathExecution (loaded : LoadedELFImage)
    (state : MachineState) (fuel : Nat) where
  stateTrace : Trace
  startsAtState : ∃ hnonempty : 0 < stateTrace.length,
    stateTrace.get 0 hnonempty = state
  finalState : MachineState
  endsAtFinal : stateTrace.get (stateTrace.length - 1) (by
    have hnonempty := startsAtState.1
    omega) = finalState
  executablePCs : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
    loaded.executableAddress
      (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat
  successfulSteps : ∀ (index : Nat) (hnext : index + 1 < stateTrace.length),
    { witness : BitVec 32 × Instruction //
      fetch32
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).memory
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat =
        some witness.1 ∧
      decodeBitVec32 witness.1 = .ok witness.2 ∧
      step
          (stateTrace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext))
          witness.2 =
        some (stateTrace.get (index + 1) hnext) }
  lengthBound : stateTrace.length ≤ fuel + 1

noncomputable def TotalOutcomeSuccessfulPath.toExecution
    {loaded : LoadedELFImage} {state : MachineState} {fuel : Nat}
    (path : TotalOutcomeSuccessfulPath loaded state fuel)
    (hfuel : fuel < MAX_TRACE) :
    TotalOutcomePathExecution loaded state fuel := by
  induction path with
  | @stop stoppedState stoppedFuel =>
      let trace := Trace.singleton stoppedState
      exact {
        stateTrace := trace
        startsAtState := by
          refine ⟨by simp [trace, Trace.singleton], ?_⟩
          rfl
        finalState := stoppedState
        endsAtFinal := by simp [trace, Trace.singleton, Trace.get]
        executablePCs := by
          intro index hnext
          simp [trace, Trace.singleton] at hnext
        successfulSteps := by
          intro index hnext
          simp [trace, Trace.singleton] at hnext
        lengthBound := by
          simp [trace, Trace.singleton]
      }
  | @step current next remaining hexecutable word hfetch instruction hdecode
      hstep tail ih =>
      have htailFuel : remaining < MAX_TRACE := by omega
      let tailExecution := ih htailFuel
      have hcapacity : tailExecution.stateTrace.length < MAX_TRACE := by
        have hlength := tailExecution.lengthBound
        omega
      let trace := prependStateTrace current tailExecution.stateTrace hcapacity
      have htraceLength : trace.length = tailExecution.stateTrace.length + 1 := rfl
      refine {
        stateTrace := trace
        startsAtState := by
          refine ⟨by simp [trace, prependStateTrace], ?_⟩
          exact prependStateTrace_get_first current tailExecution.stateTrace hcapacity
        finalState := tailExecution.finalState
        endsAtFinal := by
          have htailPositive := tailExecution.startsAtState.1
          have htailLast : tailExecution.stateTrace.length - 1 <
              tailExecution.stateTrace.length := by omega
          have hlastIndex :
              tailExecution.stateTrace.length - 1 + 1 = trace.length - 1 := by
            rw [htraceLength]
            omega
          have hlast := prependStateTrace_get_succ current
            tailExecution.stateTrace hcapacity (tailExecution.stateTrace.length - 1)
            htailLast
          calc
            trace.get (trace.length - 1) (by
              have hpositive := tailExecution.startsAtState.1
              rw [htraceLength]
              omega) =
                trace.get (tailExecution.stateTrace.length - 1 + 1) (by
                  rw [htraceLength]
                  omega) := by
                    congr 1
                    exact hlastIndex.symm
            _ = tailExecution.stateTrace.get
                  (tailExecution.stateTrace.length - 1) htailLast := by
                    simpa [trace, htraceLength] using hlast
            _ = tailExecution.finalState := tailExecution.endsAtFinal
        executablePCs := by
          intro index hnext
          by_cases hzero : index = 0
          · subst index
            have hfirst := prependStateTrace_get_first current
              tailExecution.stateTrace hcapacity
            rw [hfirst]
            exact hexecutable
          · have hpositive : 0 < index := Nat.pos_of_ne_zero hzero
            let tailIndex := index - 1
            have hindex : index = tailIndex + 1 := by omega
            have htailNext : tailIndex + 1 < tailExecution.stateTrace.length := by
              rw [← hindex]
              change index + 1 < tailExecution.stateTrace.length + 1 at hnext
              omega
            have hbefore := prependStateTrace_get_succ current
              tailExecution.stateTrace hcapacity tailIndex (by omega)
            have hbefore' :
                trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext) =
                  tailExecution.stateTrace.get tailIndex (by omega) := by
              simpa [hindex, trace] using hbefore
            rw [hbefore']
            exact tailExecution.executablePCs tailIndex htailNext
        successfulSteps := by
          intro index hnext
          by_cases hzero : index = 0
          · subst index
            have htailNonempty := tailExecution.startsAtState.1
            have hfirst := prependStateTrace_get_first current
              tailExecution.stateTrace hcapacity
            have hnextRow := prependStateTrace_get_succ current
              tailExecution.stateTrace hcapacity 0 htailNonempty
            have hnextState : trace.get 1 (by
                rw [htraceLength]
                omega) = next := by
              rw [hnextRow]
              exact tailExecution.startsAtState.2
            refine ⟨(word, instruction), ?_⟩
            rw [hfirst, hnextState]
            exact ⟨hfetch, hdecode, hstep⟩
          · have hpositive : 0 < index := Nat.pos_of_ne_zero hzero
            let tailIndex := index - 1
            have hindex : index = tailIndex + 1 := by omega
            have htailNext : tailIndex + 1 < tailExecution.stateTrace.length := by
              rw [← hindex]
              change index + 1 < tailExecution.stateTrace.length + 1 at hnext
              omega
            have hbefore := prependStateTrace_get_succ current
              tailExecution.stateTrace hcapacity tailIndex (by omega)
            have hafter := prependStateTrace_get_succ current
              tailExecution.stateTrace hcapacity (tailIndex + 1) (by omega)
            have hbefore' :
                trace.get index (Nat.lt_trans (Nat.lt_succ_self index) hnext) =
                  tailExecution.stateTrace.get tailIndex (by omega) := by
              simpa [hindex, trace] using hbefore
            have hafter' :
                trace.get (index + 1) hnext =
                  tailExecution.stateTrace.get (tailIndex + 1) (by omega) := by
              simpa [hindex, trace] using hafter
            rw [hbefore', hafter']
            exact tailExecution.successfulSteps tailIndex htailNext
        lengthBound := by
          rw [htraceLength]
          have hlength := tailExecution.lengthBound
          omega
      }

noncomputable def TotalLoadedBinaryOutcome.toSuccessfulBinaryExecution
    {loaded : LoadedELFImage} {state : MachineState} {fuel : Nat}
    (outcome : TotalLoadedBinaryOutcome loaded state fuel)
    (hstart : state = MachineState.initial loaded.image.header.entry loaded.memory)
    (hfuel : fuel < MAX_TRACE) : SuccessfulBinaryExecution :=
  let pathExecution := outcome.toSuccessfulPath.toExecution hfuel
  SuccessfulBinaryExecution.ofBinarySteps loaded pathExecution.stateTrace
    (by
      refine ⟨pathExecution.startsAtState.1, ?_⟩
      rw [pathExecution.startsAtState.2, hstart])
    pathExecution.executablePCs (fun index hnext => by
      let witness := pathExecution.successfulSteps index hnext
      exact binaryStep_eq_isaStep_of_fetch_decode
        (pathExecution.stateTrace.get index
          (Nat.lt_trans (Nat.lt_succ_self index) hnext))
        (pathExecution.stateTrace.get (index + 1) hnext)
        witness.1.1 witness.1.2 witness.property.1 witness.property.2.1
        witness.property.2.2)

def haltedAfterStepTrace (loaded : LoadedELFImage) (next : MachineState) : Trace :=
  { length := 2
    rows := fun index =>
      if index.val = 0 then
        MachineState.initial loaded.image.header.entry loaded.memory
      else
        next
    bounded := by decide }

theorem haltedAfterStep_constructs_execution (loaded : LoadedELFImage)
    (word : BitVec 32) (instruction : Instruction) (next : MachineState)
    (hexecutable : loaded.executableAddress
      (MachineState.initial loaded.image.header.entry loaded.memory).pc.toNat)
    (hfetch : fetch32 loaded.memory loaded.image.header.entry.toNat = some word)
    (hdecode : decodeBitVec32 word = .ok instruction)
    (hstep : step
      (MachineState.initial loaded.image.header.entry loaded.memory)
      instruction = some next) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loaded ∧
      execution.stateTrace.length = 2 ∧
      valid_trace execution.toBinaryTrace.stateTrace := by
  let trace := haltedAfterStepTrace loaded next
  let execution : SuccessfulBinaryExecution := {
    loadedImage := loaded
    stateTrace := trace
    startsAtLoadedEntry := by
      refine ⟨by simp [trace, haltedAfterStepTrace], ?_⟩
      rfl
    executablePCs := by
      intro index hnext
      change index + 1 < 2 at hnext
      have hindex : index = 0 := by omega
      subst index
      simpa [trace, haltedAfterStepTrace, Trace.get] using hexecutable
    successfulSteps := by
      intro index hnext
      change index + 1 < 2 at hnext
      have hindex : index = 0 := by omega
      subst index
      refine ⟨(word, instruction), ?_⟩
      simpa [trace, haltedAfterStepTrace, Trace.get] using
        And.intro hfetch (And.intro hdecode hstep)
  }
  exact ⟨execution, rfl, rfl,
    execution.toBinaryTrace_projects_valid_trace⟩

def entryAddiFourELF32SuccessfulExecution : SuccessfulBinaryExecution :=
  entryAddiFourELF32_program.toSuccessfulBinaryExecution

def entryAddiFourELF32BinaryTrace : BinaryTrace :=
  entryAddiFourELF32SuccessfulExecution.toBinaryTrace

theorem entryAddiFourELF32_end_to_end_valid_trace :
    valid_trace entryAddiFourELF32BinaryTrace.stateTrace :=
  entryAddiFourELF32SuccessfulExecution.toBinaryTrace_projects_valid_trace

theorem entryAddiFourELF32_parser_to_valid_trace :
    ∃ loadable : ElfLoadableImage,
      parseSingleExecutableELF32
          entryAddiFourELF32Bytes entryAddiFourBaseMemory = some loadable ∧
      loadable.image = entryAddiFourFixtureLoadedELFImage.image ∧
      loadable.loadedMemory = entryAddiFourFixtureLoadedELFImage.memory ∧
      ∃ program : LoadedELFImage.EntryAddiFour entryAddiFourFixtureLoadedELFImage,
        ∃ execution : SuccessfulBinaryExecution,
          execution = program.toSuccessfulBinaryExecution ∧
          execution.stateTrace.length = 6 ∧
          valid_trace execution.toBinaryTrace.stateTrace := by
  obtain ⟨loadable, hparse⟩ := entryAddiFourELF32_loadable_exists
  have hfields := entryAddiFourELF32_parse_loaded_fields loadable hparse
  refine ⟨loadable, hparse, ?_, ?_, ?_⟩
  · change loadable.image = entryAddiFourParsedELF32Image
    exact hfields.1
  · change loadable.loadedMemory = entryAddiFourParsedELF32LoadedMemory
    exact hfields.2
  · refine ⟨entryAddiFourELF32_program, ?_⟩
    refine ⟨entryAddiFourELF32SuccessfulExecution, rfl, rfl, ?_⟩
    exact entryAddiFourELF32SuccessfulExecution.toBinaryTrace_projects_valid_trace

/-- The explicit package for a machine-checked end-to-end binary result.

It requires classifier acceptance, parser/load success, the exact
LoadedELFImage used by the successful execution, and the conversion-derived
valid trace.  It does not imply this property for arbitrary accepted binaries. -/
structure FullyVerifiedBinary (bytes : Array UInt8) where
  loadable : ElfLoadableImage
  loaded : LoadedELFImage
  execution : SuccessfulBinaryExecution
  hAccepted : LoadableRV32IBinary bytes
  hParseLoad : (parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory).isSome = true
  hLoadedImage : loaded.image = loadable.image ∧
    loaded.memory = loadable.loadedMemory
  hExecutionLoaded : execution.loadedImage = loaded
  hValidTrace : valid_trace execution.toBinaryTrace.stateTrace

structure FunctionallyCorrectBinary (bytes : Array UInt8) where
  loadable : ElfLoadableImage
  loaded : LoadedELFImage
  execution : SuccessfulBinaryExecution
  binaryTrace : BinaryTrace
  hAccepted : LoadableRV32IBinary bytes
  hParseLoad : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
    some loadable
  hLoadedImage : loaded.image = loadable.image ∧
    loaded.memory = loadable.loadedMemory
  hExecutionLoaded : execution.loadedImage = loaded
  hBinaryTrace : binaryTrace = execution.toBinaryTrace
  hValidTrace : valid_trace binaryTrace.stateTrace
  hFinalHalted : execution.finalState.terminal = .halted

theorem FunctionallyCorrectBinary.binaryTrace_finalState_eq_execution_finalState
    {bytes : Array UInt8} (binary : FunctionallyCorrectBinary bytes) :
    binary.binaryTrace.finalState = binary.execution.finalState := by
  have hstates : binary.binaryTrace.stateTrace = binary.execution.stateTrace := by
    calc
      binary.binaryTrace.stateTrace =
          binary.execution.toBinaryTrace.stateTrace :=
        congrArg BinaryTrace.stateTrace binary.hBinaryTrace
      _ = binary.execution.stateTrace := rfl
  simp [BinaryTrace.finalState, SuccessfulBinaryExecution.finalState, hstates]

theorem FunctionallyCorrectBinary.binaryTrace_finalState_halted
    {bytes : Array UInt8} (binary : FunctionallyCorrectBinary bytes) :
    binary.binaryTrace.finalState.terminal = .halted := by
  rw [binary.binaryTrace_finalState_eq_execution_finalState]
  exact binary.hFinalHalted

/-- Accepted binaries parse and load under the restricted profile and match
one of the statically specified terminating entry-code shapes. The witnesses
contain parser, fetch, decode, and executable-address facts, not an execution
trace or a functional-correctness result. -/
def AcceptedRV32IBinary (bytes : Array UInt8) : Prop :=
  ∃ loadable : ElfLoadableImage,
    parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable ∧
      (Nonempty (LoadedELFImage.EntryAddiFour loadable.toLoadedELFImage) ∨
        Nonempty (LoadedELFImage.EntryEcall loadable.toLoadedELFImage) ∨
        Nonempty (LoadedELFImage.EntryAddiEcall loadable.toLoadedELFImage) ∨
        Nonempty (LoadedELFImage.EntryALUEcall loadable.toLoadedELFImage) ∨
        Nonempty (LoadedELFImage.EntryALU2Ecall loadable.toLoadedELFImage))

inductive TotalLoadedBinarySuccessfulHalt (loaded : LoadedELFImage) :
    MachineState → Nat → MachineState → Type where
  | halted {state : MachineState} {fuel : Nat}
      (hhalted : state.terminal = .halted) :
      TotalLoadedBinarySuccessfulHalt loaded state fuel state
  | haltedAfterStep {state next : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = some next)
      (hnextHalted : next.terminal = .halted) :
      TotalLoadedBinarySuccessfulHalt loaded state (fuel + 1) next
  | continued {state next finalState : MachineState} {fuel : Nat}
      (hrunning : state.terminal ≠ .halted)
      (hexecutable : loaded.executableAddress state.pc.toNat)
      (word : BitVec 32)
      (hfetch : fetch32 state.memory state.pc.toNat = some word)
      (instruction : Instruction)
      (hdecode : decodeBitVec32 word = .ok instruction)
      (hstep : step state instruction = some next)
      (hnextRunning : next.terminal ≠ .halted)
      (remaining : TotalLoadedBinarySuccessfulHalt loaded next fuel finalState) :
      TotalLoadedBinarySuccessfulHalt loaded state (fuel + 1) finalState

def TotalLoadedBinarySuccessfulHalt.toOutcome
    {loaded : LoadedELFImage} {state finalState : MachineState} {fuel : Nat} :
    TotalLoadedBinarySuccessfulHalt loaded state fuel finalState →
      TotalLoadedBinaryOutcome loaded state fuel
  | .halted hhalted => .halted hhalted
  | .haltedAfterStep hrunning hexecutable word hfetch instruction hdecode
      hstep hnextHalted =>
      .haltedAfterStep hrunning hexecutable word hfetch instruction hdecode
        hstep hnextHalted
  | .continued hrunning hexecutable word hfetch instruction hdecode hstep
      hnextRunning remaining =>
      .continued hrunning hexecutable word hfetch instruction hdecode hstep
        hnextRunning remaining.toOutcome

theorem TotalLoadedBinarySuccessfulHalt.finalState_halted
    {loaded : LoadedELFImage} {state finalState : MachineState} {fuel : Nat}
    (evidence : TotalLoadedBinarySuccessfulHalt loaded state fuel finalState) :
    finalState.terminal = .halted := by
  induction evidence with
  | halted hhalted => exact hhalted
  | haltedAfterStep _ _ _ _ _ _ _ hnextHalted => exact hnextHalted
  | continued _ _ _ _ _ _ _ _ _ ih => exact ih

structure SuccessfulHaltOutcomeEvidence (loaded : LoadedELFImage) (fuel : Nat) where
  outcome : TotalLoadedBinaryOutcome loaded
    (MachineState.initial loaded.image.header.entry loaded.memory) fuel
  hFuelBound : fuel < MAX_TRACE
  hFinalHalted :
    (outcome.toSuccessfulBinaryExecution rfl hFuelBound).finalState.terminal = .halted

def loadableRV32Binary_successfulExecution_toFunctionallyCorrect
    (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes)
    (loadable : ElfLoadableImage)
    (hparse : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
      some loadable)
    (loaded : LoadedELFImage)
    (hLoadedImage : loaded.image = loadable.image ∧
      loaded.memory = loadable.loadedMemory)
    (execution : SuccessfulBinaryExecution)
    (hExecutionLoaded : execution.loadedImage = loaded)
    (hFinalHalted : execution.finalState.terminal = .halted) :
    FunctionallyCorrectBinary bytes :=
  { loadable := loadable
    loaded := loaded
    execution := execution
    binaryTrace := execution.toBinaryTrace
    hAccepted := haccepted
    hParseLoad := hparse
    hLoadedImage := hLoadedImage
    hExecutionLoaded := hExecutionLoaded
    hBinaryTrace := rfl
    hValidTrace := execution.toBinaryTrace_projects_valid_trace
    hFinalHalted := hFinalHalted }

theorem acceptedRV32IBinary_implies_functionallyCorrect
    (bytes : Array UInt8) (haccepted : AcceptedRV32IBinary bytes) :
    Nonempty (FunctionallyCorrectBinary bytes) := by
  rcases haccepted with ⟨loadable, hparse, hprograms⟩
  rcases hprograms with hAddiFour | hrest
  · rcases hAddiFour with ⟨program⟩
    let loaded := loadable.toLoadedELFImage
    let execution := program.toSuccessfulBinaryExecution
    have hloadable : LoadableRV32IBinary bytes := by
      refine ⟨loadable, ?_⟩
      simp [classifyRV32Binary, hparse]
    have hfinalHalted : execution.finalState.terminal = .halted := by
      simp [execution, SuccessfulBinaryExecution.finalState,
        LoadedELFImage.EntryAddiFour.toSuccessfulBinaryExecution,
        SuccessfulBinaryExecution.ofBinarySteps,
        LoadedELFImage.EntryAddiFour.stateTrace,
        LoadedELFImage.entryAddiFourState,
        LoadedELFImage.entryAddiFourState5, Trace.get]
    exact ⟨loadableRV32Binary_successfulExecution_toFunctionallyCorrect
      bytes hloadable loadable hparse loaded ⟨rfl, rfl⟩ execution rfl
      hfinalHalted⟩
  · rcases hrest with hEcall | hrest'
    · rcases hEcall with ⟨program⟩
      let loaded := loadable.toLoadedELFImage
      let initial := MachineState.initial loaded.image.header.entry loaded.memory
      let final : MachineState := { initial with terminal := .halted }
      have hpcBool : (loaded.image.header.entry.toNat % 4 != 0) = false := by
        simp [loaded.entryAligned]
      have hstep : step initial .ecall = some final := by
        simp [initial, final, step, MachineState.initial, hpcBool]
      let trace := haltedAfterStepTrace loaded final
      let execution : SuccessfulBinaryExecution := {
        loadedImage := loaded
        stateTrace := trace
        startsAtLoadedEntry := by
          refine ⟨by simp [trace, haltedAfterStepTrace], ?_⟩
          rfl
        executablePCs := by
          intro index hnext
          change index + 1 < 2 at hnext
          have hindex : index = 0 := by omega
          subst index
          simpa [trace, haltedAfterStepTrace, Trace.get] using
            loaded.entry_is_executable
        successfulSteps := by
          intro index hnext
          change index + 1 < 2 at hnext
          have hindex : index = 0 := by omega
          subst index
          refine ⟨(program.word, .ecall), ?_⟩
          simpa [trace, haltedAfterStepTrace, Trace.get] using
            And.intro program.fetchesEntry
              (And.intro program.decodesEntry hstep)
      }
      have hfinalHalted : execution.finalState.terminal = .halted := by
        simp [SuccessfulBinaryExecution.finalState, execution, trace,
          haltedAfterStepTrace, Trace.get, final]
      have hloadable : LoadableRV32IBinary bytes := by
        refine ⟨loadable, ?_⟩
        simp [classifyRV32Binary, hparse]
      exact ⟨loadableRV32Binary_successfulExecution_toFunctionallyCorrect
        bytes hloadable loadable hparse loaded ⟨rfl, rfl⟩ execution rfl
        hfinalHalted⟩
    · rcases hrest' with hAddiEcall | hrest''
      · rcases hAddiEcall with ⟨program⟩
        let loaded := loadable.toLoadedELFImage
        let execution := program.toSuccessfulBinaryExecution
        have hloadable : LoadableRV32IBinary bytes := by
          refine ⟨loadable, ?_⟩
          simp [classifyRV32Binary, hparse]
        exact ⟨loadableRV32Binary_successfulExecution_toFunctionallyCorrect
          bytes hloadable loadable hparse loaded ⟨rfl, rfl⟩ execution rfl
          program.toSuccessfulBinaryExecution_halts⟩
      · rcases hrest'' with hALUEcall | hALU2Ecall
        · rcases hALUEcall with ⟨program⟩
          let loaded := loadable.toLoadedELFImage
          let execution := program.toSuccessfulBinaryExecution
          have hloadable : LoadableRV32IBinary bytes := by
            refine ⟨loadable, ?_⟩
            simp [classifyRV32Binary, hparse]
          exact ⟨loadableRV32Binary_successfulExecution_toFunctionallyCorrect
            bytes hloadable loadable hparse loaded ⟨rfl, rfl⟩ execution rfl
            program.toSuccessfulBinaryExecution_halts⟩
        · rcases hALU2Ecall with ⟨program⟩
          let loaded := loadable.toLoadedELFImage
          let execution := program.toSuccessfulBinaryExecution
          have hloadable : LoadableRV32IBinary bytes := by
            refine ⟨loadable, ?_⟩
            simp [classifyRV32Binary, hparse]
          exact ⟨loadableRV32Binary_successfulExecution_toFunctionallyCorrect
            bytes hloadable loadable hparse loaded ⟨rfl, rfl⟩ execution rfl
            program.toSuccessfulBinaryExecution_halts⟩

theorem rv32Binary_rejected_or_functionallyCorrect (bytes : Array UInt8) :
    (¬ AcceptedRV32IBinary bytes) ∨
      Nonempty (FunctionallyCorrectBinary bytes) := by
  by_cases haccepted : AcceptedRV32IBinary bytes
  · exact Or.inr (acceptedRV32IBinary_implies_functionallyCorrect bytes haccepted)
  · exact Or.inl haccepted

noncomputable def loadableRV32Binary_successfulHaltOutcome_toFunctionallyCorrect
    {fuel : Nat} (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes)
    (loadable : ElfLoadableImage)
    (hparse : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
      some loadable)
    (evidence : SuccessfulHaltOutcomeEvidence loadable.toLoadedELFImage fuel) :
    FunctionallyCorrectBinary bytes := by
  let execution := evidence.outcome.toSuccessfulBinaryExecution rfl evidence.hFuelBound
  exact loadableRV32Binary_successfulExecution_toFunctionallyCorrect bytes
    haccepted loadable hparse loadable.toLoadedELFImage ⟨rfl, rfl⟩ execution rfl
    evidence.hFinalHalted

structure LoadableRV32IBinarySuccessfulHalt (bytes : Array UInt8) where
  hAccepted : LoadableRV32IBinary bytes
  loadable : ElfLoadableImage
  hParseLoad : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
    some loadable
  fuel : Nat
  successfulHalt : SuccessfulHaltOutcomeEvidence loadable.toLoadedELFImage fuel

noncomputable def loadableRV32IBinarySuccessfulHalt_toFunctionallyCorrect
    (bytes : Array UInt8)
    (evidence : LoadableRV32IBinarySuccessfulHalt bytes) :
    FunctionallyCorrectBinary bytes :=
  loadableRV32Binary_successfulHaltOutcome_toFunctionallyCorrect bytes
    evidence.hAccepted evidence.loadable evidence.hParseLoad evidence.successfulHalt

theorem loadableRV32IBinarySuccessfulHalt_implies_functionallyCorrect
    (bytes : Array UInt8)
    (evidence : LoadableRV32IBinarySuccessfulHalt bytes) :
    Nonempty (FunctionallyCorrectBinary bytes) :=
  ⟨loadableRV32IBinarySuccessfulHalt_toFunctionallyCorrect bytes evidence⟩

def entryAddiFourCanonicalSuccessfulExecution : SuccessfulBinaryExecution :=
  entryAddiFourCanonicalProgram.toSuccessfulBinaryExecution

def entryAddiFourELF32_functionally_correct :
    FunctionallyCorrectBinary entryAddiFourELF32Bytes := by
  refine loadableRV32Binary_successfulExecution_toFunctionallyCorrect
    entryAddiFourELF32Bytes entryAddiFourCanonicalLoadableAccepted
    entryAddiFourCanonicalLoadable ?_ entryAddiFourCanonicalLoadedELFImage
    ⟨rfl, rfl⟩ entryAddiFourCanonicalSuccessfulExecution rfl ?_
  · have hparse : parseSingleExecutableELF32
        entryAddiFourELF32Bytes rv32CanonicalBaseMemory =
          some entryAddiFourCanonicalLoadable := by
      simp [entryAddiFourCanonicalLoadable, entryAddiFourCanonicalParse_isSome]
    exact hparse
  · simp [SuccessfulBinaryExecution.finalState,
      entryAddiFourCanonicalSuccessfulExecution,
      LoadedELFImage.EntryAddiFour.toSuccessfulBinaryExecution,
      SuccessfulBinaryExecution.ofBinarySteps,
      LoadedELFImage.EntryAddiFour.stateTrace,
      LoadedELFImage.entryAddiFourState, LoadedELFImage.entryAddiFourState5,
      Trace.get]

theorem entryAddiFourELF32_functionally_correct_exists :
    Nonempty (FunctionallyCorrectBinary entryAddiFourELF32Bytes) :=
  ⟨entryAddiFourELF32_functionally_correct⟩

theorem entryAddiFourCanonicalAccepted :
    AcceptedRV32IBinary entryAddiFourELF32Bytes := by
  refine ⟨entryAddiFourCanonicalLoadable, ?_, Or.inl ?_⟩
  · simp [entryAddiFourCanonicalLoadable, entryAddiFourCanonicalParse_isSome]
  · exact ⟨entryAddiFourCanonicalProgram⟩

def entryEcallELF32Bytes : Array UInt8 :=
  (((entryAddiFourELF32Bytes.set! 84 0x73).set! 85 0x00).set! 86 0x00).set! 87 0x00

theorem entryEcallCanonicalParse_isSome :
    (parseSingleExecutableELF32
      entryEcallELF32Bytes rv32CanonicalBaseMemory).isSome = true := by
  native_decide

def entryEcallCanonicalLoadable : ElfLoadableImage :=
  (parseSingleExecutableELF32
    entryEcallELF32Bytes rv32CanonicalBaseMemory).get
    (by simpa using entryEcallCanonicalParse_isSome)

theorem entryEcallCanonicalAccepted :
    AcceptedRV32IBinary entryEcallELF32Bytes := by
  refine ⟨entryEcallCanonicalLoadable, ?_, Or.inr (Or.inl ⟨?_⟩)⟩
  · simp [entryEcallCanonicalLoadable, entryEcallCanonicalParse_isSome]
  · exact {
      word := BitVec.ofNat 32 0x00000073
      fetchesEntry := by native_decide
      decodesEntry := by
        simpa [BitVec.ofNat] using decodeBitVec32_entryEcall
    }

theorem entryEcallCanonical_functionallyCorrect :
    Nonempty (FunctionallyCorrectBinary entryEcallELF32Bytes) :=
  acceptedRV32IBinary_implies_functionallyCorrect
    entryEcallELF32Bytes entryEcallCanonicalAccepted

def entryALUEcallELF32Bytes : Array UInt8 :=
  (((((((entryAddiFourELF32Bytes.set! 84 0x33).set! 85 0x81).set! 86 0x10).set! 87 0x00
    |>.set! 88 0x73).set! 89 0x00).set! 90 0x00).set! 91 0x00)

theorem entryALUEcallCanonicalParse_isSome :
    (parseSingleExecutableELF32
      entryALUEcallELF32Bytes rv32CanonicalBaseMemory).isSome = true := by
  native_decide

def entryALUEcallCanonicalLoadable : ElfLoadableImage :=
  (parseSingleExecutableELF32
    entryALUEcallELF32Bytes rv32CanonicalBaseMemory).get
    (by simpa using entryALUEcallCanonicalParse_isSome)

theorem entryALUEcallCanonicalAccepted :
    AcceptedRV32IBinary entryALUEcallELF32Bytes := by
  refine ⟨entryALUEcallCanonicalLoadable, ?_,
    Or.inr (Or.inr (Or.inr (Or.inl ⟨?_⟩)))⟩
  · simp [entryALUEcallCanonicalLoadable,
      entryALUEcallCanonicalParse_isSome]
  · exact {
      aluInstruction := .add ⟨2, by decide⟩ ⟨1, by decide⟩ ⟨1, by decide⟩
      aluInstructionIsALU := .add _ _ _
      aluWord := BitVec.ofNat 32 0x00108133
      ecallWord := BitVec.ofNat 32 0x00000073
      fetchesALU := by native_decide
      decodesALU := by
        simpa using decodeBitVec32_add_x2_x1_x1
      fetchesEcall := by native_decide
      decodesEcall := by
        simpa using decodeBitVec32_entryEcall
      ecallExecutable := by
        refine ⟨entryAddiFourParsedELF32Segment, ?_, ?_, ?_, ?_⟩
        · native_decide
        · native_decide
        · native_decide
        · native_decide
    }

theorem entryALUEcallCanonical_functionallyCorrect :
    Nonempty (FunctionallyCorrectBinary entryALUEcallELF32Bytes) :=
  acceptedRV32IBinary_implies_functionallyCorrect
    entryALUEcallELF32Bytes entryALUEcallCanonicalAccepted

def entryALU2EcallELF32Bytes : Array UInt8 := Id.run do
  let bytes := entryAddiFourELF32Bytes.set! 84 0x33
  let bytes := bytes.set! 85 0x81
  let bytes := bytes.set! 86 0x10
  let bytes := bytes.set! 87 0x00
  let bytes := bytes.set! 88 0xb3
  let bytes := bytes.set! 89 0x01
  let bytes := bytes.set! 90 0x21
  let bytes := bytes.set! 91 0x00
  let bytes := bytes.set! 92 0x73
  let bytes := bytes.set! 93 0x00
  let bytes := bytes.set! 94 0x00
  return bytes.set! 95 0x00

theorem entryALU2EcallCanonicalParse_isSome :
    (parseSingleExecutableELF32
      entryALU2EcallELF32Bytes rv32CanonicalBaseMemory).isSome = true := by
  native_decide

def entryALU2EcallCanonicalLoadable : ElfLoadableImage :=
  (parseSingleExecutableELF32
    entryALU2EcallELF32Bytes rv32CanonicalBaseMemory).get
    (by simpa using entryALU2EcallCanonicalParse_isSome)

theorem entryALU2EcallCanonicalAccepted :
    AcceptedRV32IBinary entryALU2EcallELF32Bytes := by
  refine ⟨entryALU2EcallCanonicalLoadable, ?_,
    Or.inr (Or.inr (Or.inr (Or.inr ⟨?_⟩)))⟩
  · simp [entryALU2EcallCanonicalLoadable,
      entryALU2EcallCanonicalParse_isSome]
  · exact {
      firstInstruction := .add ⟨2, by decide⟩ ⟨1, by decide⟩ ⟨1, by decide⟩
      firstIsALU := .add _ _ _
      secondInstruction := .add ⟨3, by decide⟩ ⟨2, by decide⟩ ⟨2, by decide⟩
      secondIsALU := .add _ _ _
      firstWord := BitVec.ofNat 32 0x00108133
      secondWord := BitVec.ofNat 32 0x002101b3
      ecallWord := BitVec.ofNat 32 0x00000073
      fetchesFirst := by native_decide
      decodesFirst := by
        simpa using decodeBitVec32_add_x2_x1_x1
      fetchesSecond := by native_decide
      decodesSecond := by
        simpa using decodeBitVec32_add_x3_x2_x2
      fetchesEcall := by native_decide
      decodesEcall := by
        simpa using decodeBitVec32_entryEcall
      firstExecutable := by
        refine ⟨entryAddiFourParsedELF32Segment, ?_, ?_, ?_, ?_⟩
        · native_decide
        · native_decide
        · native_decide
        · native_decide
      secondExecutable := by
        refine ⟨entryAddiFourParsedELF32Segment, ?_, ?_, ?_, ?_⟩
        · native_decide
        · native_decide
        · native_decide
        · native_decide
      ecallExecutable := by
        refine ⟨entryAddiFourParsedELF32Segment, ?_, ?_, ?_, ?_⟩
        · native_decide
        · native_decide
        · native_decide
        · native_decide
    }

theorem entryALU2EcallCanonical_functionallyCorrect :
    Nonempty (FunctionallyCorrectBinary entryALU2EcallELF32Bytes) :=
  acceptedRV32IBinary_implies_functionallyCorrect
    entryALU2EcallELF32Bytes entryALU2EcallCanonicalAccepted

structure AcceptedOutcomeVerification (bytes : Array UInt8) (fuel : Nat) where
  verified : FullyVerifiedBinary bytes
  outcome : TotalLoadedBinaryOutcome verified.loaded
    (MachineState.initial verified.loaded.image.header.entry verified.loaded.memory) fuel
  hFuelBound : fuel < MAX_TRACE
  hExecutionTrace : verified.execution.stateTrace =
    (outcome.toSuccessfulBinaryExecution rfl hFuelBound).stateTrace

structure AcceptedTerminalOutcomeVerification (bytes : Array UInt8) where
  verified : FullyVerifiedBinary bytes
  outcome : Nonempty (TotalLoadedBinaryOutcome verified.loaded
    (MachineState.initial verified.loaded.image.header.entry verified.loaded.memory) 1)

/-- Explicit bounded, successful execution evidence additional to acceptance.
This is the missing universal implication for arbitrary accepted binaries:
an accepted image still needs decoder/ISA-step witnesses for its execution. -/
structure NonFaultingBoundedExecutionEvidence (bytes : Array UInt8) where
  loadable : ElfLoadableImage
  loaded : LoadedELFImage
  execution : SuccessfulBinaryExecution
  hAccepted : LoadableRV32IBinary bytes
  hParseLoad : (parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory).isSome = true
  hLoadedImage : loaded.image = loadable.image ∧
    loaded.memory = loadable.loadedMemory
  hExecutionLoaded : execution.loadedImage = loaded

def NonFaultingBoundedExecutionEvidence.toFullyVerifiedBinary
    {bytes : Array UInt8}
    (evidence : NonFaultingBoundedExecutionEvidence bytes) :
    FullyVerifiedBinary bytes := by
  refine {
    loadable := evidence.loadable
    loaded := evidence.loaded
    execution := evidence.execution
    hAccepted := evidence.hAccepted
    hParseLoad := evidence.hParseLoad
    hLoadedImage := evidence.hLoadedImage
    hExecutionLoaded := evidence.hExecutionLoaded
    hValidTrace := ?_
  }
  exact evidence.execution.toBinaryTrace_projects_valid_trace

/-- A loadable image with one successful entry instruction that halts
constructs a two-row `SuccessfulBinaryExecution` and its `FullyVerifiedBinary`
package. This covers the one-transition terminal case, not recursive runs. -/
noncomputable def loadableRV32Binary_haltedEntryStep_toFullyVerified
    (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes)
    (word : BitVec 32) (instruction : Instruction) (next : MachineState)
    (hfetch : ∀ loadable : ElfLoadableImage,
      parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable →
      fetch32 loadable.loadedMemory loadable.image.header.entry.toNat = some word)
    (hdecode : decodeBitVec32 word = .ok instruction)
    (hstep : ∀ loadable : ElfLoadableImage,
      parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory = some loadable →
      step
        (MachineState.initial loadable.image.header.entry loadable.loadedMemory)
        instruction = some next)
    (hnextHalted : next.terminal = .halted) :
    AcceptedTerminalOutcomeVerification bytes := by
  let loadable := Classical.choose
    (loadableRV32Binary_implies_loadable bytes haccepted)
  have hparse : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
      some loadable :=
    Classical.choose_spec
      (loadableRV32Binary_implies_loadable bytes haccepted)
  let loaded := loadable.toLoadedELFImage
  have hfetchLoaded :
      fetch32 loaded.memory loaded.image.header.entry.toNat = some word := by
    exact hfetch loadable hparse
  have hstepLoaded :
      step (MachineState.initial loaded.image.header.entry loaded.memory)
        instruction = some next := by
    exact hstep loadable hparse
  have hentryRunning :
      (MachineState.initial loaded.image.header.entry loaded.memory).terminal ≠
        .halted := by
    simp [MachineState.initial]
  have houtcome : TotalLoadedBinaryOutcome loaded
      (MachineState.initial loaded.image.header.entry loaded.memory) 1 :=
    .haltedAfterStep hentryRunning loaded.entry_is_executable word hfetchLoaded
      instruction hdecode hstepLoaded hnextHalted
  let execution := Classical.choose
    (haltedAfterStep_constructs_execution loaded word instruction next
      loaded.entry_is_executable hfetchLoaded hdecode hstepLoaded)
  have hExecutionSpec := Classical.choose_spec
    (haltedAfterStep_constructs_execution loaded word instruction next
      loaded.entry_is_executable hfetchLoaded hdecode hstepLoaded)
  let verified : FullyVerifiedBinary bytes := {
    loadable := loadable
    loaded := loaded
    execution := execution
    hAccepted := haccepted
    hParseLoad := by simp [hparse]
    hLoadedImage := ⟨rfl, rfl⟩
    hExecutionLoaded := hExecutionSpec.1
    hValidTrace := hExecutionSpec.2.2
  }
  exact ⟨verified, ⟨houtcome⟩⟩

noncomputable def loadableRV32Binary_outcome_toFullyVerified
    (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes)
    (loadable : ElfLoadableImage)
    (hparse : parseSingleExecutableELF32 bytes rv32CanonicalBaseMemory =
      some loadable)
    (fuel : Nat) (hfuel : fuel < MAX_TRACE)
    (outcome : TotalLoadedBinaryOutcome loadable.toLoadedELFImage
      (MachineState.initial loadable.image.header.entry loadable.loadedMemory)
      fuel) :
    AcceptedOutcomeVerification bytes fuel := by
  let loaded := loadable.toLoadedELFImage
  let execution := outcome.toSuccessfulBinaryExecution rfl hfuel
  let verified : FullyVerifiedBinary bytes := {
    loadable := loadable
    loaded := loaded
    execution := execution
    hAccepted := haccepted
    hParseLoad := by simp [hparse]
    hLoadedImage := ⟨rfl, rfl⟩
    hExecutionLoaded := rfl
    hValidTrace := execution.toBinaryTrace_projects_valid_trace
  }
  exact ⟨verified, outcome, hfuel, rfl⟩

theorem loadableRV32Binary_maximalPrefix_toFullyVerified
    (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes) :
    Nonempty (AcceptedOutcomeVerification bytes (MAX_TRACE - 1)) := by
  obtain ⟨loadable, hparse, houtcome⟩ :=
    loadableRV32Binary_total_bounded_outcome bytes haccepted
      (MAX_TRACE - 1) (by
        have hmax : 0 < MAX_TRACE := by decide
        omega)
  exact ⟨loadableRV32Binary_outcome_toFullyVerified bytes haccepted
    loadable hparse (MAX_TRACE - 1) (by
      have hmax : 0 < MAX_TRACE := by decide
      omega) (Classical.choice houtcome)⟩

theorem loadableRV32Binary_implies_FullyVerifiedBinary
    (bytes : Array UInt8) (haccepted : LoadableRV32IBinary bytes) :
    Nonempty (FullyVerifiedBinary bytes) := by
  obtain ⟨evidence⟩ :=
    loadableRV32Binary_maximalPrefix_toFullyVerified bytes haccepted
  exact ⟨evidence.verified⟩

theorem rv32LoadableBinary_rejected_or_fullyVerified (bytes : Array UInt8) :
    (¬ LoadableRV32IBinary bytes) ∨ Nonempty (FullyVerifiedBinary bytes) := by
  rcases rv32_loadability_classifier_total bytes with haccepted | hrejected
  · exact Or.inr (loadableRV32Binary_implies_FullyVerifiedBinary bytes haccepted)
  · apply Or.inl
    intro haccepted
    obtain ⟨loadable, hacceptedClass⟩ := haccepted
    obtain ⟨reason, hrejectedClass⟩ := hrejected
    rw [hacceptedClass] at hrejectedClass
    cases hrejectedClass

theorem SuccessfulEntryExtension.toSuccessfulBinaryExecution_projects_valid_trace
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    valid_trace
      (SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension).toBinaryTrace.stateTrace :=
  SuccessfulBinaryExecution.toBinaryTrace_projects_valid_trace
    (SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension)

theorem SuccessfulEntryExtension.toSuccessfulBinaryExecution_projects_binaryValidTrace
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    binaryValidTrace
      (SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension).toBinaryTrace.stateTrace :=
  BinaryTrace.to_binaryValidTrace
    (SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension).toBinaryTrace

theorem SuccessfulEntryExtension.constructs_execution
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loadedImage ∧ execution.stateTrace.length = 3 ∧
      valid_trace execution.toBinaryTrace.stateTrace := by
  let execution := SuccessfulEntryExtension.toSuccessfulBinaryExecution entryStep extension
  exact ⟨execution, rfl,
    SuccessfulEntryExtension.toSuccessfulBinaryExecution_length extension,
    SuccessfulEntryExtension.toSuccessfulBinaryExecution_projects_valid_trace
      entryStep extension⟩

theorem SuccessfulEntryStep.toSuccessfulBinaryExecution_projects_valid_trace
    (entryStep : SuccessfulEntryStep loadedImage) :
    valid_trace entryStep.toSuccessfulBinaryExecution.toBinaryTrace.stateTrace :=
  SuccessfulBinaryExecution.toBinaryTrace_projects_valid_trace
    entryStep.toSuccessfulBinaryExecution

theorem LoadedELFImage.hasSuccessfulEntryStep_constructs_execution
    (loadedImage : LoadedELFImage)
    (h : loadedImage.HasSuccessfulEntryStep) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loadedImage ∧ execution.stateTrace.length = 2 ∧
      valid_trace execution.toBinaryTrace.stateTrace := by
  obtain ⟨word, instruction, next, hfetch, hdecode, hstep, hnext⟩ := h
  let entryStep : SuccessfulEntryStep loadedImage :=
    ⟨word, instruction, next, hfetch, hdecode, hstep, hnext⟩
  let execution := entryStep.toSuccessfulBinaryExecution
  exact ⟨execution, rfl, entryStep.toSuccessfulBinaryExecution_length,
    entryStep.toSuccessfulBinaryExecution_projects_valid_trace⟩

theorem SuccessfulBinaryExecution.toBinaryTrace_has_executable_fetch_pcs
    (execution : SuccessfulBinaryExecution) :
    ∀ (index : Nat) (hnext : index + 1 < execution.stateTrace.length),
      execution.loadedImage.executableAddress
        (execution.stateTrace.get index
          (Nat.lt_trans (Nat.lt_succ_self index) hnext)).pc.toNat :=
  execution.executablePCs

inductive BinaryPrefixStop where
  | halted (state : MachineState)
  | timeout (state : MachineState)
  | fetchFault (state : MachineState)
  | decodeFault (state : MachineState) (word : BitVec 32) (error : DecodeError)
  | executionFault (state : MachineState) (word : BitVec 32)
      (instruction : Instruction)
  | nonExecutablePC (state : MachineState)
  | traceLimit

/-- A successful execution prefix together with an explicit reason that it
cannot be extended, or an explicit trace-limit stop. -/
structure MaximalBinaryExecutionPrefix where
  execution : SuccessfulBinaryExecution
  stop : BinaryPrefixStop
  stopAtFinal :
    match stop with
    | .halted state => execution.finalState = state ∧ state.terminal = .halted
    | .timeout state => execution.finalState = state ∧ state.terminal ≠ .halted
    | .fetchFault state => execution.finalState = state ∧ state.terminal ≠ .halted
    | .decodeFault state _ _ => execution.finalState = state ∧ state.terminal ≠ .halted
    | .executionFault state _ _ => execution.finalState = state ∧ state.terminal ≠ .halted
    | .nonExecutablePC state => execution.finalState = state ∧ state.terminal ≠ .halted
    | .traceLimit => execution.stateTrace.length = MAX_TRACE

def maximalHaltedPrefix (execution : SuccessfulBinaryExecution)
    (hhalted : execution.finalState.terminal = .halted) :
    MaximalBinaryExecutionPrefix :=
  { execution := execution
    stop := .halted execution.finalState
    stopAtFinal := ⟨rfl, hhalted⟩ }

def maximalTimeoutPrefix (execution : SuccessfulBinaryExecution)
    (hrunning : execution.finalState.terminal ≠ .halted) :
    MaximalBinaryExecutionPrefix :=
  { execution := execution
    stop := .timeout execution.finalState
    stopAtFinal := ⟨rfl, hrunning⟩ }

structure AcceptedMaximalBinaryPrefixEvidence (bytes : Array UInt8) where
  executionEvidence : NonFaultingBoundedExecutionEvidence bytes
  maximalExecution : MaximalBinaryExecutionPrefix
  hExecutionLoaded : maximalExecution.execution.loadedImage = executionEvidence.loaded

def AcceptedMaximalBinaryPrefixEvidence.toFullyVerifiedBinary
    {bytes : Array UInt8}
    (evidence : AcceptedMaximalBinaryPrefixEvidence bytes) :
    FullyVerifiedBinary bytes :=
  evidence.executionEvidence.toFullyVerifiedBinary

def appendStateTrace (trace : Trace) (nextState : MachineState)
    (hcapacity : trace.length < MAX_TRACE) : Trace where
  length := trace.length + 1
  rows := fun index =>
    if hindex : index.val < trace.length then
      trace.rows ⟨index.val, hindex⟩
    else
      nextState
  bounded := by have hbound := trace.bounded; omega

theorem appendStateTrace_get_prior (trace : Trace) (nextState : MachineState)
    (hcapacity : trace.length < MAX_TRACE) (index : Nat) (hindex : index < trace.length) :
    (appendStateTrace trace nextState hcapacity).get index (by
      change index < trace.length + 1
      omega) =
      trace.get index hindex := by
  simp [appendStateTrace, Trace.get, hindex]

theorem appendStateTrace_get_appended (trace : Trace) (nextState : MachineState)
    (hcapacity : trace.length < MAX_TRACE) :
    (appendStateTrace trace nextState hcapacity).get trace.length (by
      change trace.length < trace.length + 1
      omega) =
      nextState := by
  simp [appendStateTrace, Trace.get]

structure SuccessfulExecutionExtension (execution : SuccessfulBinaryExecution) where
  hasCapacity : execution.stateTrace.length < MAX_TRACE
  currentStateExecutable : execution.loadedImage.executableAddress
    execution.finalState.pc.toNat
  word : BitVec 32
  instruction : Instruction
  nextState : MachineState
  fetchesCurrent : fetch32 execution.finalState.memory execution.finalState.pc.toNat =
    some word
  decodesCurrent : decodeBitVec32 word = .ok instruction
  executesCurrent : step execution.finalState instruction = some nextState
  nextStateExecutable : execution.loadedImage.executableAddress nextState.pc.toNat

theorem SuccessfulExecutionExtension.currentState_aligned
    (extension : SuccessfulExecutionExtension execution) :
    execution.finalState.pc.toNat % 4 = 0 :=
  (fetch32_success_implies_aligned_and_valid execution.finalState.memory
    execution.finalState.pc.toNat extension.word extension.fetchesCurrent).1

theorem SuccessfulExecutionExtension.currentState_fetchable
    (extension : SuccessfulExecutionExtension execution) :
    Memory.validRange execution.finalState.memory execution.finalState.pc.toNat 4 4 = true :=
  (fetch32_success_implies_aligned_and_valid execution.finalState.memory
    execution.finalState.pc.toNat extension.word extension.fetchesCurrent).2

theorem SuccessfulExecutionExtension.binaryStep_success
    (extension : SuccessfulExecutionExtension execution) :
    binaryStep execution.finalState = some extension.nextState :=
  binaryStep_eq_isaStep_of_fetch_decode _ _ extension.word extension.instruction
    extension.fetchesCurrent extension.decodesCurrent extension.executesCurrent

def SuccessfulBinaryExecution.extend
    (execution : SuccessfulBinaryExecution)
    (extension : SuccessfulExecutionExtension execution) : SuccessfulBinaryExecution := by
  let nextTrace := appendStateTrace execution.stateTrace extension.nextState
    extension.hasCapacity
  have hlength : nextTrace.length = execution.stateTrace.length + 1 := rfl
  refine SuccessfulBinaryExecution.ofBinarySteps execution.loadedImage nextTrace ?_ ?_ ?_
  · refine ⟨?_, ?_⟩
    · rw [hlength]
      omega
    · have hnonempty := execution.startsAtLoadedEntry.1
      have hfirst := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity 0 (by omega)
      exact hfirst.trans execution.startsAtLoadedEntry.2
  · intro index hnext
    change index + 1 < execution.stateTrace.length + 1 at hnext
    by_cases hold : index + 1 < execution.stateTrace.length
    · have hrow := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity index (by omega)
      rw [hrow]
      exact execution.executablePCs index hold
    · have hlast : index + 1 = execution.stateTrace.length := by omega
      have hindex : index < execution.stateTrace.length := by omega
      have hrow := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity index hindex
      have hfinalIndex : index = execution.stateTrace.length - 1 := by omega
      rw [hrow]
      simpa [SuccessfulBinaryExecution.finalState, hfinalIndex] using
        extension.currentStateExecutable
  · intro index hnext
    change index + 1 < execution.stateTrace.length + 1 at hnext
    by_cases hold : index + 1 < execution.stateTrace.length
    · let witness := execution.successfulSteps index hold
      have hbefore := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity index (by omega)
      have hafter := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity (index + 1) hold
      have hstep := binaryStep_eq_isaStep_of_fetch_decode
        (execution.stateTrace.get index
          (Nat.lt_trans (Nat.lt_succ_self index) hold))
        (execution.stateTrace.get (index + 1) hold)
        witness.1.1 witness.1.2 witness.property.1 witness.property.2.1
        witness.property.2.2
      rw [hbefore, hafter]
      exact hstep
    · have hlast : index + 1 = execution.stateTrace.length := by omega
      have hindex : index < execution.stateTrace.length := by omega
      have hfinalIndex : index = execution.stateTrace.length - 1 := by omega
      have hbefore := appendStateTrace_get_prior execution.stateTrace extension.nextState
        extension.hasCapacity index hindex
      have hafter := appendStateTrace_get_appended execution.stateTrace extension.nextState
        extension.hasCapacity
      have hnextTraceIndex : index < nextTrace.length := by
        rw [hlength]
        omega
      have hbeforeFinal :
          nextTrace.get index hnextTraceIndex = execution.finalState := by
        change (appendStateTrace execution.stateTrace extension.nextState
          extension.hasCapacity).get index hnextTraceIndex = execution.finalState
        rw [hbefore]
        simp [SuccessfulBinaryExecution.finalState, hfinalIndex]
      have hafterFinal :
          nextTrace.get (index + 1) hnext = extension.nextState := by
        simpa only [hlast] using hafter
      change binaryStep (nextTrace.get index hnextTraceIndex) =
        some (nextTrace.get (index + 1) hnext)
      rw [hbeforeFinal, hafterFinal]
      exact extension.binaryStep_success

theorem SuccessfulBinaryExecution.extend_length
    (execution : SuccessfulBinaryExecution)
    (extension : SuccessfulExecutionExtension execution) :
    (execution.extend extension).stateTrace.length = execution.stateTrace.length + 1 := rfl

structure SuccessfulExecutionPlan where
  initial : SuccessfulBinaryExecution
  extensionFor : ∀ (current : SuccessfulBinaryExecution),
    current.loadedImage = initial.loadedImage →
    current.stateTrace.length < MAX_TRACE →
    SuccessfulExecutionExtension current

def SuccessfulExecutionPlan.iterate
    (plan : SuccessfulExecutionPlan) :
    (steps : Nat) → steps ≤ MAX_TRACE - plan.initial.stateTrace.length →
      { result : SuccessfulBinaryExecution //
        result.stateTrace.length = plan.initial.stateTrace.length + steps ∧
          result.loadedImage = plan.initial.loadedImage }
  | 0, _ => ⟨plan.initial, by simp, rfl⟩
  | steps + 1, hsteps => by
      let previous := plan.iterate steps (Nat.le_of_succ_le hsteps)
      have hcapacity : previous.val.stateTrace.length < MAX_TRACE := by
        rw [previous.property.1]
        omega
      let extension := plan.extensionFor previous.val previous.property.2 hcapacity
      let extended := previous.val.extend extension
      refine ⟨extended, ?_, ?_⟩
      · change (previous.val.extend extension).stateTrace.length =
          plan.initial.stateTrace.length + (steps + 1)
        rw [SuccessfulBinaryExecution.extend_length, previous.property.1]
        omega
      · change previous.val.loadedImage = plan.initial.loadedImage
        exact previous.property.2

def SuccessfulExecutionPlan.toLength
    (plan : SuccessfulExecutionPlan) (targetLength : Nat)
    (hbase : plan.initial.stateTrace.length ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) : SuccessfulBinaryExecution :=
  (plan.iterate (targetLength - plan.initial.stateTrace.length) (by omega)).1

theorem SuccessfulExecutionPlan.toLength_length
    (plan : SuccessfulExecutionPlan) (targetLength : Nat)
    (hbase : plan.initial.stateTrace.length ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    (plan.toLength targetLength hbase htarget).stateTrace.length = targetLength := by
  have hiter := (plan.iterate (targetLength - plan.initial.stateTrace.length)
    (by omega)).property.1
  unfold SuccessfulExecutionPlan.toLength
  omega

theorem SuccessfulExecutionPlan.toLength_same_image
    (plan : SuccessfulExecutionPlan) (targetLength : Nat)
    (hbase : plan.initial.stateTrace.length ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    (plan.toLength targetLength hbase htarget).loadedImage = plan.initial.loadedImage :=
  (plan.iterate (targetLength - plan.initial.stateTrace.length)
    (by omega)).property.2

theorem SuccessfulExecutionPlan.toLength_projects_valid_trace
    (plan : SuccessfulExecutionPlan) (targetLength : Nat)
    (hbase : plan.initial.stateTrace.length ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    valid_trace (plan.toLength targetLength hbase htarget).toBinaryTrace.stateTrace :=
  SuccessfulBinaryExecution.toBinaryTrace_projects_valid_trace
    (plan.toLength targetLength hbase htarget)

theorem SuccessfulExecutionPlan.toLength_projects_binaryValidTrace
    (plan : SuccessfulExecutionPlan) (targetLength : Nat)
    (hbase : plan.initial.stateTrace.length ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    binaryValidTrace (plan.toLength targetLength hbase htarget).toBinaryTrace.stateTrace :=
  BinaryTrace.to_binaryValidTrace (plan.toLength targetLength hbase htarget).toBinaryTrace

def entryJalLoopInstruction : Instruction := .jal ⟨0, by decide⟩ 0

def entrySetRegisterInstruction : Instruction :=
  .addi ⟨1, by decide⟩ ⟨0, by decide⟩ 1

def LoadedELFImage.entryAddiJalLoopPC (loaded : LoadedELFImage) : Word32 :=
  Word32.add loaded.image.header.entry 4

def LoadedELFImage.entryAddiJalLoopState (loaded : LoadedELFImage) : MachineState :=
  regWrite (MachineState.initial loaded.image.header.entry loaded.memory)
    loaded.entryAddiJalLoopPC ⟨1, by decide⟩ 1

theorem LoadedELFImage.entryAddiJalLoopState_x1 (loaded : LoadedELFImage) :
    loaded.entryAddiJalLoopState.regs.read ⟨1, by decide⟩ = 1 := by
  simp [LoadedELFImage.entryAddiJalLoopState, LoadedELFImage.entryAddiJalLoopPC,
    regWrite, MachineState.initial, RegisterFile.read, RegisterFile.write]

theorem step_entrySetRegister (pc : Word32) (memory : Memory)
    (hpc : pc.toNat % 4 = 0) :
    step (MachineState.initial pc memory) entrySetRegisterInstruction =
      some (regWrite (MachineState.initial pc memory) (Word32.add pc 4)
        ⟨1, by decide⟩ 1) := by
  have hpcBool : (pc.toNat % 4 != 0) = false := by simp [hpc]
  simp [entrySetRegisterInstruction, step, MachineState.initial, regRead,
    regWrite, nextPC, Word32.add, RegisterFile.read, RegisterFile.write, hpcBool]

theorem step_jalLoop_preserves_state (state : MachineState)
    (hrunning : state.terminal = .running)
    (haligned : state.pc.toNat % 4 = 0) :
    step state entryJalLoopInstruction = some state := by
  cases state with
  | mk pc regs memory terminal =>
      cases terminal <;>
        simp_all [entryJalLoopInstruction, step, haligned, nextPC,
          regWrite, RegisterFile.write, Word32.add]

structure LoadedELFImage.EntryAddiJalLoop (loaded : LoadedELFImage) where
  entryWord : BitVec 32
  fetchesEntry : fetch32 loaded.memory loaded.image.header.entry.toNat = some entryWord
  decodesEntry : decodeBitVec32 entryWord = .ok entrySetRegisterInstruction
  loopWord : BitVec 32
  fetchesLoop : fetch32 loaded.memory loaded.entryAddiJalLoopPC.toNat = some loopWord
  decodesLoop : decodeBitVec32 loopWord = .ok entryJalLoopInstruction
  loopPC_ne_entry : loaded.entryAddiJalLoopPC ≠ loaded.image.header.entry
  loopPCExecutable : loaded.executableAddress loaded.entryAddiJalLoopPC.toNat

def LoadedELFImage.entryAddiJalLoopStep
    (loaded : LoadedELFImage) (program : loaded.EntryAddiJalLoop) :
    SuccessfulEntryStep loaded :=
  ⟨program.entryWord, entrySetRegisterInstruction,
    loaded.entryAddiJalLoopState, program.fetchesEntry, program.decodesEntry,
    by simpa [LoadedELFImage.entryAddiJalLoopState,
      LoadedELFImage.entryAddiJalLoopPC] using
        step_entrySetRegister loaded.image.header.entry loaded.memory
          loaded.entryAligned,
    program.loopPCExecutable⟩

theorem SuccessfulBinaryExecution.entryAddiJalLoop_rows
    (execution : SuccessfulBinaryExecution)
    (program : execution.loadedImage.EntryAddiJalLoop) :
    ∀ (index : Nat) (hindex : index < execution.stateTrace.length),
      execution.stateTrace.get index hindex =
        MachineState.initial execution.loadedImage.image.header.entry
          execution.loadedImage.memory ∨
      execution.stateTrace.get index hindex = execution.loadedImage.entryAddiJalLoopState := by
  intro index
  induction index with
  | zero =>
      intro hindex
      obtain ⟨_, hstart⟩ := execution.startsAtLoadedEntry
      exact Or.inl (by simpa [Trace.get] using hstart)
  | succ index ih =>
      intro hindex
      have hnext : index + 1 < execution.stateTrace.length := by omega
      have hpreviousIndex : index < execution.stateTrace.length := by omega
      have hpreviousCases := ih hpreviousIndex
      let witness := execution.successfulSteps index hnext
      have hfetch := witness.property.1
      have hdecode := witness.property.2.1
      have hstep := witness.property.2.2
      rcases hpreviousCases with hpreviousInitial | hpreviousLoop
      · have hfetchInitial :
            fetch32 execution.loadedImage.memory
              execution.loadedImage.image.header.entry.toNat = some witness.val.1 := by
          simpa [hpreviousInitial] using hfetch
        have hstepInitial :
            step
                (MachineState.initial execution.loadedImage.image.header.entry
                  execution.loadedImage.memory)
                witness.val.2 = some (execution.stateTrace.get (index + 1) hnext) := by
          simpa [hpreviousInitial] using hstep
        have hword : witness.val.1 = program.entryWord := by
          rw [program.fetchesEntry] at hfetchInitial
          injection hfetchInitial with hword
          exact hword.symm
        have hinstruction : witness.val.2 = entrySetRegisterInstruction := by
          rw [hword, program.decodesEntry] at hdecode
          injection hdecode with hinstruction
          exact hinstruction.symm
        rw [hinstruction, step_entrySetRegister _ _ execution.loadedImage.entryAligned]
          at hstepInitial
        injection hstepInitial with hstate
        exact Or.inr (by simpa [LoadedELFImage.entryAddiJalLoopState,
          LoadedELFImage.entryAddiJalLoopPC] using hstate.symm)
      · let hloopState := execution.loadedImage.entryAddiJalLoopState
        have hfetchLoop :
            fetch32 execution.loadedImage.memory
              execution.loadedImage.entryAddiJalLoopPC.toNat = some witness.val.1 := by
          simpa [hpreviousLoop, hloopState, LoadedELFImage.entryAddiJalLoopState,
            LoadedELFImage.entryAddiJalLoopPC, regWrite] using hfetch
        have hstepLoop :
            step hloopState witness.val.2 =
              some (execution.stateTrace.get (index + 1) hnext) := by
          simpa [hpreviousLoop, hloopState, LoadedELFImage.entryAddiJalLoopState,
            LoadedELFImage.entryAddiJalLoopPC, regWrite] using hstep
        have hword : witness.val.1 = program.loopWord := by
          rw [program.fetchesLoop] at hfetchLoop
          injection hfetchLoop with hword
          exact hword.symm
        have hinstruction : witness.val.2 = entryJalLoopInstruction := by
          rw [hword, program.decodesLoop] at hdecode
          injection hdecode with hinstruction
          exact hinstruction.symm
        have hprogramFetchLoop :
            fetch32 hloopState.memory hloopState.pc.toNat = some program.loopWord := by
          simpa [hloopState, LoadedELFImage.entryAddiJalLoopState,
            LoadedELFImage.entryAddiJalLoopPC, regWrite] using program.fetchesLoop
        have haligned := (fetch32_success_implies_aligned_and_valid
          hloopState.memory hloopState.pc.toNat program.loopWord hprogramFetchLoop).1
        have hrunning : hloopState.terminal = .running := by
          simp [hloopState, LoadedELFImage.entryAddiJalLoopState,
            LoadedELFImage.entryAddiJalLoopPC, regWrite, MachineState.initial]
        have hloopStep := step_jalLoop_preserves_state hloopState hrunning haligned
        rw [hinstruction, hloopStep] at hstepLoop
        injection hstepLoop with hstate
        exact Or.inr (by simpa [hloopState, LoadedELFImage.entryAddiJalLoopState,
          LoadedELFImage.entryAddiJalLoopPC, regWrite] using hstate.symm)

theorem SuccessfulBinaryExecution.entryAddiJalLoop_finalState_cases
    (execution : SuccessfulBinaryExecution)
    (program : execution.loadedImage.EntryAddiJalLoop) :
    execution.finalState =
        MachineState.initial execution.loadedImage.image.header.entry execution.loadedImage.memory ∨
      execution.finalState = execution.loadedImage.entryAddiJalLoopState := by
  have hnonempty := execution.startsAtLoadedEntry.1
  exact execution.entryAddiJalLoop_rows program
    (execution.stateTrace.length - 1) (by omega)

def SuccessfulBinaryExecution.entryAddiJalLoopExtension
    (execution : SuccessfulBinaryExecution)
    (program : execution.loadedImage.EntryAddiJalLoop)
    (hcapacity : execution.stateTrace.length < MAX_TRACE) :
    SuccessfulExecutionExtension execution := by
  let initialState := MachineState.initial execution.loadedImage.image.header.entry
    execution.loadedImage.memory
  let loopState := execution.loadedImage.entryAddiJalLoopState
  have hfinalCases := execution.entryAddiJalLoop_finalState_cases program
  by_cases hpc : execution.finalState.pc = execution.loadedImage.image.header.entry
  · have hfinal : execution.finalState = initialState := by
      rcases hfinalCases with hinitial | hloop
      · exact hinitial
      · have hloopPC : execution.finalState.pc = loopState.pc := by
          simpa [loopState, LoadedELFImage.entryAddiJalLoopState,
            LoadedELFImage.entryAddiJalLoopPC, regWrite] using
              congrArg MachineState.pc hloop
        exact False.elim (program.loopPC_ne_entry (hloopPC.symm.trans hpc))
    refine {
      hasCapacity := hcapacity
      currentStateExecutable := by
        rw [hfinal]
        exact execution.loadedImage.entry_is_executable
      word := program.entryWord
      instruction := entrySetRegisterInstruction
      nextState := loopState
      fetchesCurrent := by rw [hfinal]; exact program.fetchesEntry
      decodesCurrent := program.decodesEntry
      executesCurrent := by
        rw [hfinal]
        simpa [LoadedELFImage.entryAddiJalLoopState,
          LoadedELFImage.entryAddiJalLoopPC] using
          step_entrySetRegister execution.loadedImage.image.header.entry
            execution.loadedImage.memory execution.loadedImage.entryAligned
      nextStateExecutable := program.loopPCExecutable }
  · have hfinal : execution.finalState = loopState := by
      rcases hfinalCases with hinitial | hloop
      · have hinitialPC : execution.finalState.pc = execution.loadedImage.image.header.entry := by
          simpa [initialState] using congrArg MachineState.pc hinitial
        exact False.elim (hpc hinitialPC)
      · exact hloop
    have hprogramFetchLoop :
        fetch32 loopState.memory loopState.pc.toNat = some program.loopWord := by
      simpa [loopState, LoadedELFImage.entryAddiJalLoopState,
        LoadedELFImage.entryAddiJalLoopPC, regWrite] using program.fetchesLoop
    have haligned := (fetch32_success_implies_aligned_and_valid
      loopState.memory loopState.pc.toNat program.loopWord hprogramFetchLoop).1
    have hrunning : loopState.terminal = .running := by
      simp [loopState, LoadedELFImage.entryAddiJalLoopState,
        LoadedELFImage.entryAddiJalLoopPC, regWrite, MachineState.initial]
    refine {
      hasCapacity := hcapacity
      currentStateExecutable := by rw [hfinal]; exact program.loopPCExecutable
      word := program.loopWord
      instruction := entryJalLoopInstruction
      nextState := loopState
      fetchesCurrent := by
        rw [hfinal]
        exact hprogramFetchLoop
      decodesCurrent := program.decodesLoop
      executesCurrent := by
        rw [hfinal]
        exact step_jalLoop_preserves_state loopState hrunning haligned
      nextStateExecutable := program.loopPCExecutable }

def LoadedELFImage.entryAddiJalLoopPlan
    (loaded : LoadedELFImage) (program : loaded.EntryAddiJalLoop) :
    SuccessfulExecutionPlan where
  initial := (loaded.entryAddiJalLoopStep program).toSuccessfulBinaryExecution
  extensionFor := fun current hsame hcapacity => by
    have hprogram : current.loadedImage.EntryAddiJalLoop := by
      rw [hsame]
      exact program
    exact current.entryAddiJalLoopExtension hprogram hcapacity

theorem LoadedELFImage.entryAddiJalLoopPlan_constructs_length
    (loaded : LoadedELFImage) (program : loaded.EntryAddiJalLoop)
    (targetLength : Nat) (hbase : 2 ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loaded ∧ execution.stateTrace.length = targetLength ∧
      valid_trace execution.toBinaryTrace.stateTrace := by
  let plan := loaded.entryAddiJalLoopPlan program
  have hinitialLength : plan.initial.stateTrace.length = 2 := by
    simp [plan, LoadedELFImage.entryAddiJalLoopPlan,
      SuccessfulEntryStep.toSuccessfulBinaryExecution_length]
  let execution := plan.toLength targetLength (by omega) htarget
  refine ⟨execution, ?_, ?_, ?_⟩
  · calc
      execution.loadedImage = plan.initial.loadedImage :=
        SuccessfulExecutionPlan.toLength_same_image plan targetLength (by omega) htarget
      _ = loaded := rfl
  · exact SuccessfulExecutionPlan.toLength_length plan targetLength (by omega) htarget
  · exact SuccessfulExecutionPlan.toLength_projects_valid_trace plan targetLength
      (by omega) htarget

theorem LoadedELFImage.entryAddiJalLoopPlan_constructs_binaryValidTrace
    (loaded : LoadedELFImage) (program : loaded.EntryAddiJalLoop)
    (targetLength : Nat) (hbase : 2 ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loaded ∧ execution.stateTrace.length = targetLength ∧
      binaryValidTrace execution.toBinaryTrace.stateTrace := by
  let plan := loaded.entryAddiJalLoopPlan program
  have hinitialLength : plan.initial.stateTrace.length = 2 := by
    simp [plan, LoadedELFImage.entryAddiJalLoopPlan,
      SuccessfulEntryStep.toSuccessfulBinaryExecution_length]
  let execution := plan.toLength targetLength (by omega) htarget
  exact ⟨execution,
    (SuccessfulExecutionPlan.toLength_same_image plan targetLength (by omega) htarget).trans rfl,
    SuccessfulExecutionPlan.toLength_length plan targetLength (by omega) htarget,
    SuccessfulExecutionPlan.toLength_projects_binaryValidTrace plan targetLength
      (by omega) htarget⟩

theorem step_entryJalLoop (pc : Word32) (memory : Memory)
    (haligned : pc.toNat % 4 = 0) :
    step (MachineState.initial pc memory) entryJalLoopInstruction =
      some (MachineState.initial pc memory) := by
  simp [entryJalLoopInstruction, step, MachineState.initial, haligned,
    nextPC, regWrite, RegisterFile.write, Word32.add]

structure LoadedELFImage.EntryJalLoop (loaded : LoadedELFImage) where
  word : BitVec 32
  fetchesEntry : fetch32 loaded.memory loaded.image.header.entry.toNat = some word
  decodesEntry : decodeBitVec32 word = .ok entryJalLoopInstruction

def LoadedELFImage.entryJalLoopStep
    (loaded : LoadedELFImage) (loop : loaded.EntryJalLoop) :
    SuccessfulEntryStep loaded :=
  ⟨loop.word, entryJalLoopInstruction,
    MachineState.initial loaded.image.header.entry loaded.memory,
    loop.fetchesEntry, loop.decodesEntry,
    step_entryJalLoop loaded.image.header.entry loaded.memory loaded.entryAligned,
    loaded.entry_is_executable⟩

theorem SuccessfulBinaryExecution.entryJalLoop_rows
    (execution : SuccessfulBinaryExecution)
    (loop : execution.loadedImage.EntryJalLoop) :
    ∀ (index : Nat) (hindex : index < execution.stateTrace.length),
      execution.stateTrace.get index hindex =
        MachineState.initial execution.loadedImage.image.header.entry
          execution.loadedImage.memory := by
  intro index
  induction index with
  | zero =>
      intro hindex
      obtain ⟨_, hstart⟩ := execution.startsAtLoadedEntry
      simpa [Trace.get] using hstart
  | succ index ih =>
      intro hindex
      have hnext : index + 1 < execution.stateTrace.length := by omega
      have hpreviousIndex : index < execution.stateTrace.length := by omega
      have hprevious := ih hpreviousIndex
      let witness := execution.successfulSteps index hnext
      have hfetch := witness.property.1
      have hdecode := witness.property.2.1
      have hstep := witness.property.2.2
      have hfetchInitial :
          fetch32 execution.loadedImage.memory
            execution.loadedImage.image.header.entry.toNat = some witness.val.1 := by
        simpa [hprevious] using hfetch
      have hstepInitial :
          step
              (MachineState.initial execution.loadedImage.image.header.entry
                execution.loadedImage.memory)
              witness.val.2 = some (execution.stateTrace.get (index + 1) hnext) := by
        simpa [hprevious] using hstep
      have hword : witness.val.1 = loop.word := by
        rw [loop.fetchesEntry] at hfetchInitial
        injection hfetchInitial with hword
        exact hword.symm
      have hinstruction : witness.val.2 = entryJalLoopInstruction := by
        rw [hword, loop.decodesEntry] at hdecode
        injection hdecode with hinstruction
        exact hinstruction.symm
      have hloopStep := step_entryJalLoop execution.loadedImage.image.header.entry
        execution.loadedImage.memory execution.loadedImage.entryAligned
      rw [hinstruction, hloopStep] at hstepInitial
      injection hstepInitial with hstate
      exact hstate.symm

theorem SuccessfulBinaryExecution.entryJalLoop_finalState
    (execution : SuccessfulBinaryExecution)
    (loop : execution.loadedImage.EntryJalLoop) :
    execution.finalState =
      MachineState.initial execution.loadedImage.image.header.entry execution.loadedImage.memory := by
  have hnonempty := execution.startsAtLoadedEntry.1
  exact execution.entryJalLoop_rows loop (execution.stateTrace.length - 1) (by omega)

def SuccessfulBinaryExecution.entryJalLoopExtension
    (execution : SuccessfulBinaryExecution)
    (loop : execution.loadedImage.EntryJalLoop)
    (hcapacity : execution.stateTrace.length < MAX_TRACE) :
    SuccessfulExecutionExtension execution := by
  have hfinal := execution.entryJalLoop_finalState loop
  refine {
    hasCapacity := hcapacity
    currentStateExecutable := by
      rw [hfinal]
      exact execution.loadedImage.entry_is_executable
    word := loop.word
    instruction := entryJalLoopInstruction
    nextState := MachineState.initial execution.loadedImage.image.header.entry
      execution.loadedImage.memory
    fetchesCurrent := by
      rw [hfinal]
      exact loop.fetchesEntry
    decodesCurrent := loop.decodesEntry
    executesCurrent := by
      rw [hfinal]
      exact step_entryJalLoop execution.loadedImage.image.header.entry
        execution.loadedImage.memory execution.loadedImage.entryAligned
    nextStateExecutable := execution.loadedImage.entry_is_executable }

def LoadedELFImage.entryJalLoopPlan
    (loaded : LoadedELFImage) (loop : loaded.EntryJalLoop) :
    SuccessfulExecutionPlan where
  initial := (loaded.entryJalLoopStep loop).toSuccessfulBinaryExecution
  extensionFor := fun current hsame hcapacity => by
    have loopCurrent : current.loadedImage.EntryJalLoop := by
      rw [hsame]
      exact loop
    exact current.entryJalLoopExtension loopCurrent hcapacity

theorem LoadedELFImage.entryJalLoop_plan_constructs_length
    (loaded : LoadedELFImage) (loop : loaded.EntryJalLoop)
    (targetLength : Nat) (hbase : 2 ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loaded ∧ execution.stateTrace.length = targetLength ∧
      valid_trace execution.toBinaryTrace.stateTrace := by
  let plan := loaded.entryJalLoopPlan loop
  have hinitialLength : plan.initial.stateTrace.length = 2 := by
    simp [plan, LoadedELFImage.entryJalLoopPlan,
      SuccessfulEntryStep.toSuccessfulBinaryExecution_length]
  let execution := plan.toLength targetLength (by omega) htarget
  refine ⟨execution, ?_, ?_, ?_⟩
  · calc
      execution.loadedImage = plan.initial.loadedImage :=
        SuccessfulExecutionPlan.toLength_same_image plan targetLength (by omega) htarget
      _ = loaded := rfl
  · exact SuccessfulExecutionPlan.toLength_length plan targetLength (by omega) htarget
  · exact SuccessfulExecutionPlan.toLength_projects_valid_trace plan targetLength
      (by omega) htarget

theorem LoadedELFImage.entryJalLoop_plan_constructs_binaryValidTrace
    (loaded : LoadedELFImage) (loop : loaded.EntryJalLoop)
    (targetLength : Nat) (hbase : 2 ≤ targetLength)
    (htarget : targetLength ≤ MAX_TRACE) :
    ∃ execution : SuccessfulBinaryExecution,
      execution.loadedImage = loaded ∧ execution.stateTrace.length = targetLength ∧
      binaryValidTrace execution.toBinaryTrace.stateTrace := by
  let plan := loaded.entryJalLoopPlan loop
  have hinitialLength : plan.initial.stateTrace.length = 2 := by
    simp [plan, LoadedELFImage.entryJalLoopPlan,
      SuccessfulEntryStep.toSuccessfulBinaryExecution_length]
  let execution := plan.toLength targetLength (by omega) htarget
  exact ⟨execution,
    (SuccessfulExecutionPlan.toLength_same_image plan targetLength (by omega) htarget).trans rfl,
    SuccessfulExecutionPlan.toLength_length plan targetLength (by omega) htarget,
    SuccessfulExecutionPlan.toLength_projects_binaryValidTrace plan targetLength
      (by omega) htarget⟩

theorem SuccessfulBinaryExecution.extend_preserves_prior_states
    (execution : SuccessfulBinaryExecution)
    (extension : SuccessfulExecutionExtension execution)
    (index : Nat) (hindex : index < execution.stateTrace.length) :
    (execution.extend extension).stateTrace.get index (by
      rw [SuccessfulBinaryExecution.extend_length]
      omega) = execution.stateTrace.get index hindex := by
  simpa [SuccessfulBinaryExecution.extend, SuccessfulBinaryExecution.ofBinarySteps] using
    appendStateTrace_get_prior execution.stateTrace extension.nextState
      extension.hasCapacity index hindex

theorem SuccessfulBinaryExecution.extend_projects_valid_trace
    (execution : SuccessfulBinaryExecution)
    (extension : SuccessfulExecutionExtension execution) :
    valid_trace (execution.extend extension).toBinaryTrace.stateTrace :=
  SuccessfulBinaryExecution.toBinaryTrace_projects_valid_trace (execution.extend extension)

theorem SuccessfulBinaryExecution.extend_projects_binaryValidTrace
    (execution : SuccessfulBinaryExecution)
    (extension : SuccessfulExecutionExtension execution) :
    binaryValidTrace (execution.extend extension).toBinaryTrace.stateTrace :=
  BinaryTrace.to_binaryValidTrace (execution.extend extension).toBinaryTrace

theorem SuccessfulEntryStep.toSuccessfulBinaryExecution_finalState
    (entryStep : SuccessfulEntryStep loadedImage) :
    entryStep.toSuccessfulBinaryExecution.finalState = entryStep.nextState := by
  simp [SuccessfulBinaryExecution.finalState,
    SuccessfulEntryStep.toSuccessfulBinaryExecution,
    SuccessfulEntryStep.stateTrace, Trace.get]

def SuccessfulEntryExtension.toSuccessfulExecutionExtension
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    SuccessfulExecutionExtension entryStep.toSuccessfulBinaryExecution := by
  have hfinal := SuccessfulEntryStep.toSuccessfulBinaryExecution_finalState entryStep
  refine {
    hasCapacity := by
      rw [SuccessfulEntryStep.toSuccessfulBinaryExecution_length]
      decide
    currentStateExecutable := by simpa [hfinal] using extension.currentPCExecutable
    word := extension.word
    instruction := extension.instruction
    nextState := extension.nextState
    fetchesCurrent := by simpa [hfinal] using extension.fetchesCurrent
    decodesCurrent := extension.decodesCurrent
    executesCurrent := by simpa [hfinal] using extension.executesCurrent
    nextStateExecutable := extension.nextPCExecutable }

theorem SuccessfulEntryExtension.general_extension_length
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    (entryStep.toSuccessfulBinaryExecution.extend
      (extension.toSuccessfulExecutionExtension entryStep)).stateTrace.length = 3 := by
  rw [SuccessfulBinaryExecution.extend_length,
    SuccessfulEntryStep.toSuccessfulBinaryExecution_length]

theorem SuccessfulEntryExtension.general_extension_projects_valid_trace
    (entryStep : SuccessfulEntryStep loadedImage)
    (extension : SuccessfulEntryExtension entryStep) :
    valid_trace
      (entryStep.toSuccessfulBinaryExecution.extend
        (extension.toSuccessfulExecutionExtension entryStep)).toBinaryTrace.stateTrace :=
  SuccessfulBinaryExecution.extend_projects_valid_trace _ _

end ZkRV32I.Binary
