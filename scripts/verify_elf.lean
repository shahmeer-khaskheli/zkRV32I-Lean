import ZkRV32I.Binary

open ZkRV32I
open ZkRV32I.Binary

def verifyFirmware (path : String) : IO Unit := do
  let raw ← IO.FS.readBinFile path
  let image ←
    match parseELF32 raw.data with
    | some image => pure image
    | none => throw <| IO.userError "ELF32 parser rejected the firmware image"
  if image.header.objectType != 2 then
    throw <| IO.userError "firmware ELF is not ET_EXEC"
  if image.header.programHeaderCount != image.programHeaders.size then
    throw <| IO.userError "program-header count mismatch"
  let entryIsExecutable := image.programHeaders.any fun header =>
    header.isLoadableExecutable &&
      header.virtualAddress ≤ image.header.entry.toNat &&
      image.header.entry.toNat + 4 ≤ header.virtualAddress + header.memorySize
  if !entryIsExecutable then
    throw <| IO.userError "ELF entry is not within a loadable executable segment"
  let memory := Memory.empty (Word32.ofNat 0x80000000) 0x10000
  let loaded ←
    match image.loadMemory memory with
    | some memory => pure memory
    | none => throw <| IO.userError "ELF PT_LOAD segments do not fit formal memory"
  let entry := image.header.entry.toNat
  if !Memory.validRange loaded entry 4 4 then
    throw <| IO.userError "ELF entry does not point to a valid aligned loaded word"
  let word ←
    match fetch32 loaded entry with
    | some word => pure word
    | none => throw <| IO.userError "instruction fetch failed at ELF entry"
  match decodeBitVec32 word with
  | .ok _ =>
      IO.println s!"Parsed, loaded, fetched, and decoded ELF entry 0x{entry}."
  | .error _ =>
      throw <| IO.userError "ELF entry bytes do not decode as a supported instruction"

def main (args : List String) : IO Unit := do
  match args with
  | path :: _ => verifyFirmware path
  | [] => throw <| IO.userError "usage: lake env lean --run scripts/verify_elf.lean <firmware.elf>"
