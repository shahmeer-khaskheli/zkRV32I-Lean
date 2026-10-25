#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
found=0

while IFS= read -r -d '' file; do
    if grep -nE '(^|[^[:alnum:]_])(extern[[:space:]]+crate[[:space:]]+alloc|alloc::|std::|Vec|Box|String|HashMap|BTreeMap|Rc|Arc|Cow)([^[:alnum:]_]|$)|vec!|format!' "$file"; then
        found=1
    else
        status=$?
        if [ "$status" -ne 1 ]; then
            exit "$status"
        fi
    fi
done < <(find "$repo_root/rust/src" -type f -name '*.rs' -print0)

if [ "$found" -ne 0 ]; then
    echo "Rust execution source contains a standard heap-allocation API." >&2
    exit 1
fi
echo "No standard heap-allocation APIs found in the Rust execution source."
