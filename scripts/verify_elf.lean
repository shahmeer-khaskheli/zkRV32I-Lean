import ZkRV32I.Binary

open ZkRV32I
open ZkRV32I.Binary

def verifyModelEdgeCases : IO Unit := do
  let wrapped := Word32.add (Word32.ofNat 0xffffffff) (Word32.ofNat 1)
  if wrapped != 0 then
    throw <| IO.userError "32-bit word arithmetic wraparound check failed"
  let boundedMemory := Memory.empty (Word32.ofNat 0) 8
  if Memory.validRange boundedMemory 1 4 4 then
    throw <| IO.userError "unaligned memory access was accepted"
  if Memory.validRange boundedMemory 0xffffffff 4 1 then
    throw <| IO.userError "overflowing memory range was accepted"
  let initial := MachineState.initial (Word32.ofNat 0) boundedMemory
  let overflowState := {
    initial with
    regs := initial.regs.write ⟨1, by decide⟩ (Word32.ofNat 0xffffffff)
  }
  let overflowResult ←
    match step overflowState (.addi ⟨2, by decide⟩ ⟨1, by decide⟩ (Word32.ofNat 1)) with
    | some state => pure state
    | none => throw <| IO.userError "overflowing ADDI did not execute"
  if overflowResult.regs.read ⟨2, by decide⟩ != 0 then
    throw <| IO.userError "register result did not wrap to 32 bits"
  let halted ←
    match step initial .ecall with
    | some state => pure state
    | none => throw <| IO.userError "ECALL did not produce a modeled terminal state"
  if halted.terminal != .halted then
    throw <| IO.userError "ECALL terminal-state check failed"
  if (step halted .fence).isSome then
    throw <| IO.userError "halted state accepted another instruction"
  let boundaryTrace : Trace := {
    length := MAX_TRACE
    rows := fun _ => initial
    bounded := Nat.le_refl MAX_TRACE
  }
  if boundaryTrace.length != MAX_TRACE ||
      decide (MAX_TRACE + 1 ≤ MAX_TRACE) then
    throw <| IO.userError "trace boundary check failed"

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
      let initial := MachineState.initial image.header.entry loaded
      let next ←
        match binaryStep initial with
        | some next => pure next
        | none => throw <| IO.userError "binary instruction execution failed at ELF entry"
      IO.println s!"Parsed, loaded, fetched, decoded, and executed ELF entry 0x{entry}; next PC is 0x{next.pc.toNat}."
  | .error _ =>
      throw <| IO.userError "ELF entry bytes do not decode as a supported instruction"
  verifyModelEdgeCases
  IO.println "Model edge cases passed: ADDI register wraparound, unaligned and overflowing memory ranges, ECALL halt behavior, and MAX_TRACE boundary."

def main (args : List String) : IO Unit := do
  match args with
  | path :: _ => verifyFirmware path
  | [] => throw <| IO.userError "usage: lake env lean --run scripts/verify_elf.lean <firmware.elf>"
