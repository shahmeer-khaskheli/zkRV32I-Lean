#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_isa_coverage.sh
bash scripts/check_no_unsafe.sh
bash scripts/check_alloc_policy.sh
lake build
bash scripts/check_axiom_policy.sh
cargo check --locked
cargo test --locked
