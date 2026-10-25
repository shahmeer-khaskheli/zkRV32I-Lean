#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
found=0

while IFS= read -r -d '' file; do
    if grep -nE '(^|[^[:alnum:]_])sorry([^[:alnum:]_]|$)' "$file"; then
        found=1
    else
        status=$?
        if [ "$status" -ne 1 ]; then
            exit "$status"
        fi
    fi
done < <(find "$repo_root" -type f -name '*.lean' -not -path '*/.lake/*' -print0)

if [ "$found" -ne 0 ]; then
    echo "Lean source contains sorry." >&2
    exit 1
fi
echo "Lean source contains no sorry."
