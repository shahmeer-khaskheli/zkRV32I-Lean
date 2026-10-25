import ZkRV32I.Machine

open ZkRV32I

private def parseNat (arg : String) : Option Nat :=
  arg.toNat?

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
  | [pcArg, x1Arg, x2Arg, instructionArg] =>
      match parseNat pcArg, parseNat x1Arg, parseNat x2Arg, parseNat instructionArg with
      | some pc, some x1, some x2, some instruction =>
          let initial := MachineState.initial (Word32.ofNat pc) (Memory.empty 0 64)
          let initial := { initial with regs :=
            (initial.regs.write 1 (Word32.ofNat x1)).write 2 (Word32.ofNat x2) }
          match decode (Word32.ofNat instruction) with
          | .error _ => IO.println "decode_error"
          | .ok decoded =>
              match step initial decoded with
              | none => IO.println "fault"
              | some result => IO.println (outputState result)
      | _, _, _, _ => IO.println "bad_input"
  | _ => IO.println "bad_input"
