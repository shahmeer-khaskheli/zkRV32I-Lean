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

structure ElfLoadableImage extends ElfLoadSpec where
  loadedMemory : Memory
  hEntryAligned : entryPC.toNat % 4 = 0
  hEntryBounded : entryPC.toNat < 2 ^ 32
  hSegmentsBounded : elfLoadableSegmentsBounded toElfLoadSpec = true
  hSegmentsDisjoint : elfLoadableSegmentsDisjoint toElfLoadSpec = true
  hLoadSuccess : image.loadMemory initialMemory = some loadedMemory
  hEntryFetchable : Memory.validRange loadedMemory entryPC.toNat 4 4 = true

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
  simpa [hstart, hfileBacked] using hbytes.symm

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
  ∃ witness : DynamicStepWitness before after, True

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
    obtain ⟨witness, _⟩ := hnonempty
    exact DynamicStepWitness.to_binaryValidTransition before after witness
  · intro hvalid
    obtain ⟨word, instruction, hfetch, hdecode, hstep⟩ := hvalid
    exact ⟨⟨word, instruction, hfetch, hdecode, hstep⟩, trivial⟩

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
    | .beq rs1 rs2 imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bne rs1 rs2 imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .blt rs1 rs2 imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bge rs1 rs2 imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bltu rs1 rs2 imm =>
        let taken := Word32.add state.pc imm
        alignedSuccessors taken ++ [pc']
    | .bgeu rs1 rs2 imm =>
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨_, heq⟩
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
        rcases hstep with ⟨haligned, heq⟩
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
        rcases hstep with ⟨haligned, heq⟩
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
            subst s'
            simp [ht, possibleSuccessors, nextPC]
  | _ =>
      intro s' hstep
      by_cases ht : s.terminal == .halted
      · simp [step, ht] at hstep
      ·
        simp [step, ht] at hstep
        try rcases hstep with ⟨_, heq⟩
        try have hpc := congrArg MachineState.pc heq
        try have hpc := congrArg MachineState.pc hstep
        simp_all [possibleSuccessors, alignedSuccessors, alignedSuccessor, nextPC,
          regWrite, storeValue, loadValue, branch]

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

def boundedBinaryStep (state : MachineState) (fuel : Nat) :
    BoundedBinaryStepOutcome :=
  if state.terminal == .halted then
    .terminated state state
  else
    match fuel with
    | 0 => .timeout state
    | _fuel + 1 =>
        match hfetch : fetch32 state.memory state.pc.toNat with
        | none => .fetchFault state
        | some word =>
            match hdecode : decodeBitVec32 word with
            | .error error => .decodeFault state word error
            | .ok instruction =>
                match hstep : step state instruction with
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
      (∃ faultState word instruction, outcome = .executionFault faultState word instruction) := by
  intro h
  cases outcome with
  | continued before after => exact Or.inl ⟨before, after, rfl⟩
  | terminated before after => exact Or.inr (Or.inl ⟨before, after, rfl⟩)
  | timeout stalled => exact Or.inr (Or.inr (Or.inl ⟨stalled, rfl⟩))
  | fetchFault faultState => exact Or.inr (Or.inr (Or.inr (Or.inl ⟨faultState, rfl⟩)))
  | decodeFault faultState word error =>
      exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl ⟨faultState, word, error, rfl⟩))))
  | executionFault faultState word instruction =>
      exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr ⟨faultState, word, instruction, rfl⟩))))

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
        match hfetch : fetch32 state.memory state.pc.toNat with
        | none => .fetchFault state
        | some word =>
            match hdecode : decodeBitVec32 word with
            | .error error => .decodeFault state word error
            | .ok instruction =>
                match hstep : step state instruction with
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
          refine ⟨(word, instruction), ?_⟩
          exact ⟨by simpa using hfetch, by simpa using hdecode, h⟩

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
  entryCodeBytes : ∀ (index : Nat) (hindex : index < 20),
    loaded.image.fileBytes[segment.fileOffset + index]? =
      entryAddiFourCodeBytes[index]?
  instructionPCAddresses : ∀ (slot : Nat) (hslot : slot < 5),
    (loaded.entryAddiFourPC slot).toNat = loaded.image.header.entry.toNat + 4 * slot
  instructionPCFetchable : ∀ (slot : Nat) (hslot : slot < 5),
    Memory.validRange loaded.memory (loaded.entryAddiFourPC slot).toNat 4 4 = true
  instructionPCExecutable : ∀ (slot : Nat) (hslot : slot < 5),
    loaded.executableAddress (loaded.entryAddiFourPC slot).toNat

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
    (program : LoadedELFImage.EntryAddiFour loaded)
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

theorem LoadedELFImage.EntryAddiFour.stepAt
    (program : LoadedELFImage.EntryAddiFour loaded)
    (slot : Nat) (hslot : slot < 5) :
    step (loaded.entryAddiFourState slot) (entryAddiFourInstruction slot) =
      some (loaded.entryAddiFourState (slot + 1)) := by
  have hslots : slot = 0 ∨ slot = 1 ∨ slot = 2 ∨ slot = 3 ∨ slot = 4 := by omega
  rcases hslots with hslot0 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add] <;> omega
  rcases hslots with hslot1 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add] <;> omega
  rcases hslots with hslot2 | hslots
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState2, LoadedELFImage.entryAddiFourState3,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add] <;> omega
  rcases hslots with hslot3 | hslot4
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourState4,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState5, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add] <;> omega
  · subst slot
    simp [entryAddiFourInstruction, LoadedELFImage.entryAddiFourState,
      LoadedELFImage.entryAddiFourState4, LoadedELFImage.entryAddiFourState5,
      LoadedELFImage.entryAddiFourState1, LoadedELFImage.entryAddiFourState2,
      LoadedELFImage.entryAddiFourState3, LoadedELFImage.entryAddiFourPC,
      step, regRead, regWrite, nextPC, RegisterFile.read, RegisterFile.write,
      MachineState.initial, Word32.add] <;> omega

theorem LoadedELFImage.EntryAddiFour.stateAtPC
    (program : LoadedELFImage.EntryAddiFour loaded)
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
    (program : LoadedELFImage.EntryAddiFour loaded)
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
    (program : LoadedELFImage.EntryAddiFour loaded) : Trace :=
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

theorem BinaryTrace.to_valid_trace (trace : BinaryTrace) :
    valid_trace trace.stateTrace := by
  refine ⟨trace.startsAtLoadedEntry.1, ?_, ?_⟩
  · rw [trace.startsAtLoadedEntry.2]
    exact ⟨trace.loadedImage.image.header.entry, trace.loadedImage.memory, rfl⟩
  intro index hnext
  exact ⟨trace.instructionAt index, (trace.transitions index hnext).2.2⟩

theorem BinaryTrace.to_binaryValidTrace (trace : BinaryTrace) :
    binaryValidTrace trace.stateTrace := by
  refine ⟨trace.startsAtLoadedEntry.1, ?_, ?_⟩
  · rw [trace.startsAtLoadedEntry.2]
    exact ⟨trace.loadedImage.image.header.entry, trace.loadedImage.memory, rfl⟩
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

def SuccessfulBinaryExecution.finalState (execution : SuccessfulBinaryExecution) :
    MachineState :=
  execution.stateTrace.get (execution.stateTrace.length - 1) (by
    have hnonempty := execution.startsAtLoadedEntry.1
    omega)

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

theorem step_entrySetRegister (pc : Word32) (memory : Memory) :
    step (MachineState.initial pc memory) entrySetRegisterInstruction =
      some (regWrite (MachineState.initial pc memory) (Word32.add pc 4)
        ⟨1, by decide⟩ 1) := by
  simp [entrySetRegisterInstruction, step, MachineState.initial, regRead,
    regWrite, nextPC, Word32.add, RegisterFile.read, RegisterFile.write]

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
        step_entrySetRegister loaded.image.header.entry loaded.memory,
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
        rw [hinstruction, step_entrySetRegister] at hstepInitial
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
            execution.loadedImage.memory
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
