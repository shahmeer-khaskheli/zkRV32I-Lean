#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"
found=0

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
    printf '%s\n' \
        'import ZkRV32I.Refinement.Step' \
        '#print axioms ZkRV32I.Refinement.master_end_to_end_refinement' |
        lake env lean --stdin
)
printf '%s\n' "$axiom_output"

dependencies=$(printf '%s\n' "$axiom_output" |
    sed -n 's/.*depends on axioms: \[\(.*\)\]/\1/p')
for dependency in $(printf '%s' "$dependencies" | tr ',' ' '); do
    case "$dependency" in
        propext|Quot.sound|Classical.choice) ;;
        *)
            echo "Unapproved theorem axiom: $dependency" >&2
            exit 1
            ;;
    esac
done
echo "No project-defined axioms; theorem dependencies are allowlisted."
