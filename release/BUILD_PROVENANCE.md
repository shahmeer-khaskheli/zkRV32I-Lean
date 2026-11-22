# Build Provenance

## Verified configuration

- OS: WSL/Linux for the last local verification run
- Lean: 4.19.0
- Elan: installed through the standard Elan toolchain manager
- Lake: resolved from `LAKE_BIN`, `lake`, or `lake.exe`
- Rust: 1.97.1 as reported by the verified environment
- RISC-V target: `riscv32i-unknown-none-elf`

## Gate

The full gate is:

```bash
bash scripts/verify_all.sh
```

The gate passed on 2026-11-21. It runs source policy checks, Lean build,
axiom audit, RISC-V check, host Rust tests, adversarial tests, and transcript
mutation tests.
