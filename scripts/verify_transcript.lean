import Lean
import ZkRV32I.Transcript

open Lean
open ZkRV32I.Binary.TranscriptV1

private structure BatchCase where
  name : String
  elf_path : String
  transcript_path : String
  expect_accept : Bool
  deriving FromJson

private structure Batch where
  cases : Array BatchCase
  deriving FromJson

def verifyTranscript (elfPath transcriptPath : String) : IO Unit := do
  let elfBytes ← IO.FS.readBinFile elfPath
  let transcriptJson ← IO.FS.readFile transcriptPath
  let transcript ←
    match parse transcriptJson with
    | .ok transcript => pure transcript
    | .error error => throw <| IO.userError s!"invalid transcript: {error}"
  match check elfBytes.data transcript with
  | none => throw <| IO.userError "transcript rejected by the Lean checker"
  | some verified =>
      let trace := verified.verifiedPrefix.binaryTrace
      let stop := if verified.stopReason.isHalt then "halt"
        else match transcript.stop.getObjValAs? String "kind" with
          | .ok kind => kind
          | .error _ => "invalid"
      IO.println s!"accepted: {trace.stateTrace.length} states; prefix verified; stop={stop}"

def verifyTranscriptBatch (path : String) : IO Unit := do
  let contents ← IO.FS.readFile path
  let json ←
    match Json.parse contents with
    | .ok json => pure json
    | .error error => throw <| IO.userError s!"invalid batch manifest: {error}"
  let batch ←
    match (fromJson? (α := Batch) json) with
    | .ok batch => pure batch
    | .error error => throw <| IO.userError s!"invalid batch manifest: {error}"
  for testCase in batch.cases do
    let elfBytes ← IO.FS.readBinFile testCase.elf_path
    let transcriptText ← IO.FS.readFile testCase.transcript_path
    let accepted :=
      match parse transcriptText with
      | .error _ => false
      | .ok transcript => (check elfBytes.data transcript).isSome
    if accepted != testCase.expect_accept then
      let expected := if testCase.expect_accept then "acceptance" else "rejection"
      throw <| IO.userError
        s!"{testCase.name}: expected {expected}"
    let result := if accepted then "accepted" else "rejected"
    IO.println s!"{testCase.name}: {result}"

def main (args : List String) : IO Unit := do
  match args with
  | ["batch", path] => verifyTranscriptBatch path
  | [elfPath, transcriptPath] => verifyTranscript elfPath transcriptPath
  | _ =>
      throw <| IO.userError
        "usage: lake env lean --run scripts/verify_transcript.lean <firmware.elf> <transcript.json> | batch <manifest.json>"
