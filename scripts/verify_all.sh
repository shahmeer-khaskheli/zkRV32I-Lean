#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

lake_bin=${LAKE_BIN:-}
if [ -z "$lake_bin" ]; then
    lake_bin=$(command -v lake || command -v lake.exe || true)
fi
if [ -z "$lake_bin" ]; then
    echo "Lake executable not found (tried lake and lake.exe)." >&2
    exit 127
fi
export LAKE_BIN="$lake_bin"

if ! command -v cargo >/dev/null 2>&1 &&
    [ -x "${HOME:-}/.cargo/bin/cargo" ]; then
    PATH="${HOME}/.cargo/bin:$PATH"
    export PATH
fi

bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_isa_coverage.sh
bash scripts/check_no_unsafe.sh
bash scripts/check_alloc_policy.sh
"$lake_bin" build
bash scripts/check_axiom_policy.sh
cargo check --locked --target riscv32i-unknown-none-elf
rust_host_target=$(rustc -vV | sed -n 's/^host: //p')
cargo test --locked --target "$rust_host_target"
cargo test --locked --manifest-path adversarial/Cargo.toml --target "$rust_host_target"
cargo build --locked --manifest-path adversarial/Cargo.toml --target "$rust_host_target"

host_runner="$repo_root/adversarial/target/$rust_host_target/debug/zkrv32i-adversarial"
if [ ! -x "$host_runner" ]; then
    echo "Host transcript runner was not produced at $host_runner." >&2
    exit 1
fi
python3 scripts/check_transcript_adversarial.py "$host_runner" "$lake_bin"
