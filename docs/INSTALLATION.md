# Installation and verification

## Prerequisites

Use Linux, macOS, or WSL. The repository pins Lean 4.19.0 in
`lean-toolchain` and Rust 1.97.1 in `rust-toolchain.toml`.

Install Elan and Rust through their standard installers:

```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
rustup toolchain install 1.97.1
rustup target add riscv32i-unknown-none-elf
```

Run commands from the repository root. `verify_all.sh` resolves Lake from
`LAKE_BIN`, `lake`, or `lake.exe`.

## Lean build

```bash
${LAKE_BIN:-lake} build
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
bash scripts/verify_all.sh
```

The script requires Bash, Cargo, the pinned Lake binary or a compatible `lake`
on `PATH`, the RISC-V Rust target, Python 3, and a host target supported by the
workspace.
