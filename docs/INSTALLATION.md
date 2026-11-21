# Installation and verification

## Verified environment

The documented WSL verification environment uses Lean 4.19.0 from Elan cache
`/mnt/d/elan-linux`.

```bash
export ELAN_HOME=/mnt/d/elan-linux
export LAKE_BIN=/mnt/d/elan-linux/toolchains/leanprover--lean4---v4.19.0/bin/lake
export PATH="$ELAN_HOME/toolchains/leanprover--lean4---v4.19.0/bin:$PATH"
cd "/mnt/c/Users/HARRY POTTER/zk-verifier-core"
```

The repository currently accepts Rust `1.97.1` in WSL for the tested
workflow.

## Lean build

```bash
"$LAKE_BIN" build
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
```

The expected axiom output reports the allowlisted Lean foundations
`propext`, `Quot.sound`, `Classical.choice`, and `Lean.ofReduceBool`, with no
project-defined axioms.

## Rust checks

Host target:

```bash
host_target=$(rustc -vV | sed -n 's/^host: //p')
cargo check --locked
cargo test --locked --target "$host_target"
cargo test --locked --manifest-path adversarial/Cargo.toml --target "$host_target"
cargo build --locked --manifest-path adversarial/Cargo.toml --target "$host_target"
```

RISC-V target:

```bash
cargo check --locked --target riscv32i-unknown-none-elf
```

`rust/src/lib.rs` must retain `#![no_std]` and
`#![forbid(unsafe_code)]`. Cargo success does not prove Rust source extraction
or binary-level equivalence.

## Full gate

```bash
LAKE_BIN="$LAKE_BIN" bash scripts/verify_all.sh
```

The script requires Bash, Cargo, the pinned Lake binary or a compatible `lake`
on `PATH`, the RISC-V Rust target, Python 3, and a host target supported by the
workspace.
