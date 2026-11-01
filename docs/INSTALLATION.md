# Installation and Compilation Guide

## Supported Environment

The repository pins Lean 4 v4.19.0 in `lean-toolchain`.

Required tools:

- Git;
- Lean 4 v4.19.0;
- Lake, distributed with the Lean toolchain;
- Bash for repository policy scripts; and
- Rust 1.97.1 only when Rust checks or the Rust firmware target are needed.

The Lean build itself does not require Rust.

## Linux and macOS

### 1. Install prerequisites

Ubuntu/Debian:

```sh
sudo apt-get update
sudo apt-get install -y git curl bash build-essential
```

Fedora:

```sh
sudo dnf install -y git curl bash @development-tools
```

macOS with Homebrew:

```sh
brew install git
```

### 2. Install elan and Lean

`elan` is the standard Lean toolchain manager.

```sh
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

During installation, accept the default shell integration. Open a new terminal
or reload the shell:

```sh
source "$HOME/.cargo/env"
```

Verify the tools:

```sh
git --version
elan --version
lean --version
lake --version
```

`lean --version` must report Lean 4.19.0.

### 3. Clone and enter the repository

```sh
git clone https://github.com/shahmeer-khaskheli/zkRV32I-Lean.git
cd zkRV32I-Lean
```

`lean-toolchain` selects Lean 4.19.0 for commands executed in this directory.

### 4. Resolve and build

```sh
lake update
lake build
```

`lake update` is normally unnecessary after a clean checkout, because this
project currently has no external Lake dependency. It is safe to run and is
included for a complete workflow. If Lake reports that `lake update` changed
cache state, rerun `lake build`.

## Windows

### PowerShell

Install Git with an existing package manager or the official Git for Windows
installer. From an elevated PowerShell session, install `winget` packages if
available:

```powershell
winget install --id Git.Git -e
winget install --id Microsoft.PowerShell -e
```

Restart PowerShell, then install elan:

```powershell
curl.exe https://elan.lean-lang.org/elan-init.ps1 -sSf | powershell -
```

Alternatively, download the official elan installer from the Lean website and
execute it. Restart the terminal so `lean`, `lake`, and `elan` enter `PATH`.

Verify:

```powershell
git --version
elan --version
lean --version
lake --version
```

Clone and build:

```powershell
git clone https://github.com/shahmeer-khaskheli/zkRV32I-Lean.git
Set-Location zkRV32I-Lean
lake update
lake build
```

### Git Bash

Policy scripts use Bash. Git Bash provides Bash and common Unix utilities on
Windows:

```sh
git clone https://github.com/shahmeer-khaskheli/zkRV32I-Lean.git
cd zkRV32I-Lean
lake build
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
```

Run `lake` from the directory that contains `lean-toolchain`.

## Verification Commands

Run these commands from the repository root:

```sh
lake build
bash scripts/check_no_sorry.sh
bash scripts/check_no_admit.sh
bash scripts/check_axiom_policy.sh
bash scripts/check_isa_coverage.sh
```

Expected policy checks:

```text
Lean source contains no sorry.
Lean source contains no admit.
No project-defined axioms; theorem dependencies are allowlisted.
```

`lake build` should finish with `Build completed successfully`.

Run the complete convenience verification where available:

```sh
bash scripts/verify_all.sh
```

## Rust Toolchain

Rust is optional for the Lean-only build. To validate the Rust workspace, pin
the repository toolchain and install required targets:

```sh
rustup override set 1.97.1
rustup target add riscv32i-unknown-none-elf
rustup target add x86_64-unknown-linux-gnu
cargo check --locked
cargo test --locked
```

On macOS or Windows, substitute the appropriate host Rust target for
`x86_64-unknown-linux-gnu`.

## Common Problems

### Lean version mismatch

Symptoms:

- missing libraries;
- unexpected elaboration behavior; or
- Lake selecting another toolchain.

Fix:

```sh
cd zkRV32I-Lean
elan override set leanprover/lean4:v4.19.0
lean --version
lake build
```

The repository's `lean-toolchain` should already select the same version.

### `lake` is not found

Linux/macOS:

```sh
source "$HOME/.cargo/env"
command -v lake
```

Windows:

1. reopen PowerShell or Git Bash;
2. run `elan which lake`;
3. add the elan `bin` directory to `PATH` if it remains unresolved.

### Bash script execution fails

Linux/macOS:

```sh
bash scripts/check_no_sorry.sh
```

Windows:

Run Git Bash from the repository root:

```sh
bash scripts/check_no_sorry.sh
```

Do not execute `.sh` files directly with PowerShell.

### Cached build output is stale

Lean cache files are build outputs and are safe to rebuild:

```sh
lake clean
lake build
```

If a clean build fails because dependencies are unavailable, restore or update
the pinned Lean toolchain before rebuilding.
