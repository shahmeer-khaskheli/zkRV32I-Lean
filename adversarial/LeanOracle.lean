import ZkRV32I.Machine
import ZkRV32I.Refinement.AddiBridge

open ZkRV32I
open ZkRV32I.Refinement

private def parseNat (arg : String) : Option Nat :=
  arg.toNat?

private def parseWord32 (arg : String) : Option Word32 := do
  let value ← parseNat arg
  if value < 4294967296 then
    some (Word32.ofNat value)
  else
    none

private def parseByte (arg : String) : Option UInt8 := do
  let value ← parseNat arg
  if value < 256 then
    some (UInt8.ofNat value)
  else
    none

private def parseWords (arg : String) : Option (List Word32) :=
  (arg.splitOn ",").mapM parseWord32

private def parseBytes (arg : String) : Option (List UInt8) :=
  (arg.splitOn ",").mapM parseByte

private def parseTerminal (arg : String) : Option TerminalState :=
  match arg with
  | "running" => some .running
  | "halted" => some .halted
  | _ => none

private def parseSnapshot (pcArg terminalArg registersArg baseArg bytesArg : String) :
    Option AddiBridgeSnapshot := do
  let pc ← parseWord32 pcArg
  let terminal ← parseTerminal terminalArg
  let registers ← parseWords registersArg
  let memoryBase ← parseWord32 baseArg
  let memoryBytes ← parseBytes bytesArg
  pure ⟨pc, terminal, registers, memoryBase, memoryBytes⟩

private def parseAddiBridgeError (arg : String) : Option AddiBridgeError :=
  match arg with
  | "halted" => some .halted
  | "invalid_register" => some .invalidRegisterIndex
  | "misaligned_pc" => some .misalignedInstructionAddress
  | "other" => some .other
  | _ => none

private def parseAddiBridgeRecord (fields : List String) : Option AddiBridgeRecord := do
  match fields with
  | ["addi", wordArg, rdArg, rs1Arg, immArg,
      inputPc, inputTerminal, inputRegisters, inputBase, inputBytes,
      "ok", outputPc, outputTerminal, outputRegisters, outputBase, outputBytes] => do
      let instructionWord ← parseWord32 wordArg
      let rd ← parseNat rdArg
      let rs1 ← parseNat rs1Arg
      let immediate ← parseWord32 immArg
      let input ← parseSnapshot inputPc inputTerminal inputRegisters inputBase inputBytes
      let output ← parseSnapshot outputPc outputTerminal outputRegisters outputBase outputBytes
      pure ⟨instructionWord, ⟨rd, rs1, immediate⟩, input, .success output⟩
  | ["addi", wordArg, rdArg, rs1Arg, immArg,
      inputPc, inputTerminal, inputRegisters, inputBase, inputBytes,
      "err", errorArg] => do
      let instructionWord ← parseWord32 wordArg
      let rd ← parseNat rdArg
      let rs1 ← parseNat rs1Arg
      let immediate ← parseWord32 immArg
      let input ← parseSnapshot inputPc inputTerminal inputRegisters inputBase inputBytes
      let error ← parseAddiBridgeError errorArg
      pure ⟨instructionWord, ⟨rd, rs1, immediate⟩, input, .error error⟩
  | _ => none

private def parseAddBridgeRecord (fields : List String) : Option AddBridgeRecord := do
  match fields with
  | ["add", wordArg, rdArg, rs1Arg, rs2Arg,
      inputPc, inputTerminal, inputRegisters, inputBase, inputBytes,
      "ok", outputPc, outputTerminal, outputRegisters, outputBase, outputBytes] => do
      let instructionWord ← parseWord32 wordArg
      let rd ← parseNat rdArg
      let rs1 ← parseNat rs1Arg
      let rs2 ← parseNat rs2Arg
      let input ← parseSnapshot inputPc inputTerminal inputRegisters inputBase inputBytes
      let output ← parseSnapshot outputPc outputTerminal outputRegisters outputBase outputBytes
      pure ⟨instructionWord, ⟨rd, rs1, rs2⟩, input, .success output⟩
  | ["add", wordArg, rdArg, rs1Arg, rs2Arg,
      inputPc, inputTerminal, inputRegisters, inputBase, inputBytes,
      "err", errorArg] => do
      let instructionWord ← parseWord32 wordArg
      let rd ← parseNat rdArg
      let rs1 ← parseNat rs1Arg
      let rs2 ← parseNat rs2Arg
      let input ← parseSnapshot inputPc inputTerminal inputRegisters inputBase inputBytes
      let error ← parseAddiBridgeError errorArg
      pure ⟨instructionWord, ⟨rd, rs1, rs2⟩, input, .error error⟩
  | _ => none

private def outputState (state : MachineState) : String := Id.run do
  let registers := (List.range 32).map fun index =>
    toString (state.regs.read ⟨index % 32, Nat.mod_lt _ (by decide)⟩).toNat
  let memory := (List.range 64).map fun index =>
    match Memory.load state.memory index 1 1 with
    | some value => toString value.toNat
    | none => "fault"
  return String.intercalate "|" [
    "ok",
    toString state.pc.toNat,
    if state.terminal == .halted then "halted" else "running",
    String.intercalate "," registers,
    String.intercalate "," memory
  ]

def main (args : List String) : IO Unit := do
  match args with
  | ["--addi-record", recordArg] =>
      match parseAddiBridgeRecord (recordArg.splitOn "|") with
      | some record =>
          IO.println (if checkAddiBridgeRecord record then "accepted" else "rejected")
      | none => IO.println "bad_addi_record"
  | ["--add-record", recordArg] =>
      match parseAddBridgeRecord (recordArg.splitOn "|") with
      | some record =>
          IO.println (if checkAddBridgeRecord record then "accepted" else "rejected")
      | none => IO.println "bad_add_record"
  | [pcArg, x1Arg, x2Arg, instructionArg] =>
      match parseNat pcArg, parseNat x1Arg, parseNat x2Arg, parseNat instructionArg with
      | some pc, some x1, some x2, some instruction =>
          let initial := MachineState.initial (Word32.ofNat pc) (Memory.empty 0 64)
          let initial := { initial with regs :=
            (initial.regs.write 1 (Word32.ofNat x1)).write 2 (Word32.ofNat x2) }
          match decode (Word32.ofNat instruction) with
          | .error .illegalEncoding => IO.println "decode_illegal"
          | .error .unsupportedInstruction => IO.println "decode_unsupported"
          | .ok decoded =>
              match step initial decoded with
              | none => IO.println "fault"
              | some result => IO.println (outputState result)
      | _, _, _, _ => IO.println "bad_input"
  | _ => IO.println "bad_input"
