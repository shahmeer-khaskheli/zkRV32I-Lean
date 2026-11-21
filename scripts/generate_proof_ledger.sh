#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

lake_bin=${LAKE_BIN:-}
if [ -z "$lake_bin" ]; then
    lake_bin=$(command -v lake || command -v lake.exe || true)
fi
if [ -z "$lake_bin" ]; then
    echo "Lake executable not found (tried lake and lake.exe)." >&2
    exit 127
fi

python3 scripts/proof_ledger_source_scan.py |
    "$lake_bin" env lean --stdin

python3 scripts/proof_ledger_individual_review.py >> PROOF_LEDGER.md
