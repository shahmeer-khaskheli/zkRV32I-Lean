#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
lib="$repo_root/rust/src/lib.rs"

if ! grep -Fxq '#![no_std]' "$lib"; then
    echo "rust/src/lib.rs is missing #![no_std]." >&2
    exit 1
fi
if ! grep -Fxq '#![forbid(unsafe_code)]' "$lib"; then
    echo "rust/src/lib.rs is missing #![forbid(unsafe_code)]." >&2
    exit 1
fi

found=0
while IFS= read -r -d '' file; do
    if grep -nE '(^|[^[:alnum:]_])unsafe[[:space:]]+(fn|impl|trait|extern|static)|(^|[^[:alnum:]_])unsafe[[:space:]]*\{' "$file"; then
        found=1
    else
        status=$?
        if [ "$status" -ne 1 ]; then
            exit "$status"
        fi
    fi
done < <(find "$repo_root/rust/src" -type f -name '*.rs' -print0)

if [ "$found" -ne 0 ]; then
    echo "Rust execution source contains unsafe code." >&2
    exit 1
fi
echo "Rust crate attributes are present; no unsafe code found."
