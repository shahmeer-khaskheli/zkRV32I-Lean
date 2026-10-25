# Historical Build Provenance Snapshot

> **Historical snapshot.** The commands and outcomes below record an earlier
> Windows environment before the linked firmware ELF and Lean runtime ELF
> verification were added. They are not a current full-build report. Current
> reproduction commands and verification boundaries are in
> [README.md](../README.md) and
> [TECHNICAL_WHITEPAPER.md](../TECHNICAL_WHITEPAPER.md).

## Environment

- Rust: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
- Cargo: `cargo 1.97.1 (c980f4866 2026-06-30)`
- Rust target/toolchain pin: `1.97.1`, `x86_64-pc-windows-msvc`
- Lean: `Lean (version 4.19.0, x86_64-w64-mingw32, commit 6caaee842e94, Release)`
- Lake: `Lake version 5.0.0-6caaee8 (Lean version 4.19.0)`
- Lean toolchain pin: `leanprover/lean4:v4.19.0`
- Host: Windows; MSVC `link.exe` unavailable.

## Pipeline commands and observed results

Commands below were run from the repository root. Exit codes and outputs are
recorded as observed.

### Lean build

Command:

```powershell
$env:PATH = "$HOME\.elan\bin;" + $env:PATH; lake build
```

Exit code: `0`

Output:

```text
Build completed successfully.
exit code: 0
```

### Rust core

Command:

```powershell
cargo check --manifest-path rust\Cargo.toml
```

Exit code: `0`

Output:

```text
Checking zkrv32i v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\rust)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.50s
exit code: 0
```

Command:

```powershell
cargo check --tests --manifest-path rust\Cargo.toml
```

Exit code: `0`

Output:

```text
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.03s
exit code: 0
```

Command:

```powershell
cargo test --manifest-path rust\Cargo.toml
```

Exit code: `101`

Output:

```text
Compiling zkrv32i v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\rust)
error: linker `link.exe` not found
  |
  = note: program not found

note: the msvc targets depend on the msvc linker but `link.exe` was not found

note: please ensure that Visual Studio 2017 or later, or Build Tools for Visual Studio were installed with the Visual C++ option

note: VS Code is a different product, and is not sufficient

error: could not compile `zkrv32i` (lib test) due to 1 previous error

note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

### Adversarial crate

Commands:

```powershell
cargo check --manifest-path adversarial\Cargo.toml
cargo check --tests --manifest-path adversarial\Cargo.toml
```

Both commands exited `0`. Observed output:

```text
Checking zkrv32i v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\rust)
Checking zkrv32i-adversarial v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\adversarial)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.95s
cargo check exit code: 0
Checking zkrv32i-adversarial v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\adversarial)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.50s
cargo check --tests exit code: 0
```

Command:

```powershell
cargo run --manifest-path adversarial\Cargo.toml
```

Exit code: `101`

Output:

```text
Compiling zkrv32i v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\rust)
Compiling zkrv32i-adversarial v0.1.0 (C:\Users\HARRY POTTER\zk-verifier-core\adversarial)
error: linker `link.exe` not found
  |
  = note: program not found

note: the msvc targets depend on the msvc linker but `link.exe` was not found

note: please ensure that Visual Studio 2017 or later, or Build Tools for Visual Studio were installed with the Visual C++ option

note: VS Code is a different product, and is not sufficient

error: could not compile `zkrv32i-adversarial` (bin "zkrv32i-adversarial") due to 1 previous error
```

### Policy scripts

Command executed each script with Bash:

```powershell
$names = @('check_no_sorry.sh','check_no_admit.sh','check_axiom_policy.sh','check_no_unsafe.sh','check_alloc_policy.sh','check_isa_coverage.sh','verify_all.sh'); $failed = 0; foreach ($name in $names) { $script = './scripts/' + $name; bash $script; $code = $LASTEXITCODE; Write-Output ("{0}: exit code {1}" -f $script,$code); if ($code -ne 0) { $failed++ } }; Write-Output ("Policy scripts: {0}; failures: {1}" -f $names.Count,$failed); if ($failed -ne 0) { exit 1 }
```

Exit code: `0`

Output:

```text
./scripts/check_no_sorry.sh: exit code 0
./scripts/check_no_admit.sh: exit code 0
./scripts/check_axiom_policy.sh: exit code 0
./scripts/check_no_unsafe.sh: exit code 0
./scripts/check_alloc_policy.sh: exit code 0
./scripts/check_isa_coverage.sh: exit code 0
./scripts/verify_all.sh: exit code 0
Policy scripts: 7; failures: 0
```

Inspection showed all seven scripts contain only a shell header and `exit 0`;
these results are not substantive policy checks.

### Lean corpus

Each line in `adversarial\corpus.txt` was passed to
`lake env lean --run adversarial/LeanOracle.lean` and compared with its expected
classification.

Exit code: `0`

Output:

```text
PASS addi_x1_imm1: Lean ok
PASS add_x3_x1_x2: Lean ok
PASS beq_equal_taken: Lean ok
PASS beq_unequal_not_taken: Lean ok
PASS beq_misaligned_pc: Lean fault
PASS lw_aligned: Lean ok
PASS lw_misaligned: Lean fault
PASS lw_out_of_bounds: Lean fault
PASS write_x0: Lean ok
PASS illegal_zero_word: Lean decode_error
Corpus cases: 10; passed: 10; failed: 0
```

### Theorem dependency and source scans

The command `lake env lean --stdin` imported `ZkRV32I` and
`ZkRV32I.Circuit.Constraints`, then ran `#print axioms` on every theorem listed
in `PROOF_MANIFEST.md`. It exited `0`. Reported dependencies were `propext` and
`Quot.sound` only; field lemmas other than `field_mul_inv_of_nonzero` reported
no axioms.

The Lean input was:

```lean
import ZkRV32I
import ZkRV32I.Circuit.Constraints
#print axioms ZkRV32I.RegisterFile.x0_write_invariant
#print axioms ZkRV32I.x0_preserved_by_step
#print axioms _root_.x0_preserved_by_step
#print axioms ZkRV32I.valid_trace_length_bounds
#print axioms ZkRV32I.zero_length_trace_invalid
#print axioms ZkRV32I.singleton_valid_trace
#print axioms ZkRV32I.adjacent_rows_are_valid_transitions
#print axioms ZkRV32I.x0_zero_throughout_valid_trace
#print axioms ZkRV32I.Circuit.field_add_self
#print axioms ZkRV32I.Circuit.field_add_comm
#print axioms ZkRV32I.Circuit.field_add_assoc
#print axioms ZkRV32I.Circuit.field_mul_comm
#print axioms ZkRV32I.Circuit.field_mul_assoc
#print axioms ZkRV32I.Circuit.field_add_zero
#print axioms ZkRV32I.Circuit.field_mul_one
#print axioms ZkRV32I.Circuit.field_mul_add
#print axioms ZkRV32I.Circuit.field_mul_inv_of_nonzero
#print axioms ZkRV32I.Circuit.completeness_valid_trace_encoding_satisfies_constraints
#print axioms ZkRV32I.Circuit.soundness_transition_constraints_imply_isa_transitions
```

Output:

```text
'ZkRV32I.RegisterFile.x0_write_invariant' depends on axioms: [propext]
'ZkRV32I.x0_preserved_by_step' depends on axioms: [propext, Quot.sound]
'x0_preserved_by_step' depends on axioms: [propext]
'ZkRV32I.valid_trace_length_bounds' depends on axioms: [propext]
'ZkRV32I.zero_length_trace_invalid' depends on axioms: [propext, Quot.sound]
'ZkRV32I.singleton_valid_trace' depends on axioms: [propext]
'ZkRV32I.adjacent_rows_are_valid_transitions' depends on axioms: [propext]
'ZkRV32I.x0_zero_throughout_valid_trace' depends on axioms: [propext]
'ZkRV32I.Circuit.field_add_self' does not depend on any axioms
'ZkRV32I.Circuit.field_add_comm' does not depend on any axioms
'ZkRV32I.Circuit.field_add_assoc' does not depend on any axioms
'ZkRV32I.Circuit.field_mul_comm' does not depend on any axioms
'ZkRV32I.Circuit.field_mul_assoc' does not depend on any axioms
'ZkRV32I.Circuit.field_add_zero' does not depend on any axioms
'ZkRV32I.Circuit.field_mul_one' does not depend on any axioms
'ZkRV32I.Circuit.field_mul_add' does not depend on any axioms
'ZkRV32I.Circuit.field_mul_inv_of_nonzero' depends on axioms: [propext]
'ZkRV32I.Circuit.completeness_valid_trace_encoding_satisfies_constraints' depends on axioms: [propext, Quot.sound]
'ZkRV32I.Circuit.soundness_transition_constraints_imply_isa_transitions' depends on axioms: [propext]
```

The `rg` source scan for `sorry`, `admit`, or project-level `axiom` declarations
in Lean files returned “No matches found” (ripgrep exit code `1`, meaning no
matches).

The Rust source scan used the pattern `\bunsafe\b|alloc::|\bVec\b|\bBox\b|\bString\b|\bHashMap\b`
on `rust/**/*.rs`; it returned “No matches found” (ripgrep exit code `1`,
meaning no matches). A direct inspection confirmed the only Rust core source
file begins with:

```text
#![no_std]
#![forbid(unsafe_code)]
```

## Reproducibility notes

- `cargo check` and `cargo check --tests` validate compilation but do not execute
  tests.
- `cargo test` and `cargo run` need a compatible linker and were not completed.
- The ten Lean corpus cases are finite examples, not exhaustive testing.
- Policy scripts currently exit successfully without checking their named
  policies.
- No package installation, source changes outside the four release files, or
  generated build artifacts are part of this release record.
