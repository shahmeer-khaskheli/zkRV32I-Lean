# Build Provenance

## Verified configuration

- OS: WSL/Linux against `/mnt/c/Users/HARRY POTTER/zk-verifier-core`
- Lean: 4.19.0
- Elan cache: `/mnt/d/elan-linux`
- Lake: `/mnt/d/elan-linux/toolchains/leanprover--lean4---v4.19.0/bin/lake`
- Rust: 1.97.1 as reported by the verified environment
- RISC-V target: `riscv32i-unknown-none-elf`

## Gate

The full gate is:

```bash
LAKE_BIN="$LAKE_BIN" bash scripts/verify_all.sh
```

The gate passed on 2026-11-21. It runs source policy checks, Lean build,
axiom audit, RISC-V check, host Rust tests, adversarial tests, and transcript
mutation tests.
