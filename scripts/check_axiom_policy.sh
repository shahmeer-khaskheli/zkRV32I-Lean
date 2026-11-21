#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"
found=0
lake_bin=${LAKE_BIN:-}

if [ -z "$lake_bin" ]; then
    lake_bin=$(command -v lake || command -v lake.exe || true)
fi

if [ -z "$lake_bin" ]; then
    echo "Lake executable not found (tried lake and lake.exe)." >&2
    exit 127
fi

while IFS= read -r -d '' file; do
    if grep -nE '^[[:space:]]*((private|protected|unsafe|noncomputable)[[:space:]]+)*axiom[[:space:]]+' "$file"; then
        found=1
    else
        status=$?
        if [ "$status" -ne 1 ]; then
            exit "$status"
        fi
    fi
done < <(find "$repo_root" -type f -name '*.lean' -not -path '*/.lake/*' -print0)

if [ "$found" -ne 0 ]; then
    echo "Lean source declares a project-defined axiom." >&2
    exit 1
fi

axiom_output=$(
    "$lake_bin" env lean --stdin <<'LEAN'
import Lean
import ZkRV32I

open Lean Elab Command

elab "#auditProjectAxioms" : command => do
  let env <- getEnv
  let allowed : List Name := [`propext, `Quot.sound, `Classical.choice, `Lean.ofReduceBool]
  let mut count := 0
  let mut dependencies : Array Name := #[]
  for (name, info) in env.constants.toList do
    if name.toString.startsWith "ZkRV32I." || name == `x0_preserved_by_step then
      match info with
      | .thmInfo _ =>
          count := count + 1
          let axioms <- collectAxioms name
          for axiomName in axioms do
            if !dependencies.contains axiomName then
              dependencies := dependencies.push axiomName
            if !allowed.contains axiomName then
              throwError m!"Unapproved axiom dependency {axiomName} in {name}"
      | _ => pure ()
  logInfo m!"Checked {count} project theorem declarations (including the root theorem); dependencies={dependencies}"

#auditProjectAxioms
LEAN
)
printf '%s\n' "$axiom_output"

echo "No project-defined axioms; all project theorem dependencies are allowlisted."
