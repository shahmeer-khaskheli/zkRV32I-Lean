#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "$0")/.." && pwd)
lean_machine="$repo_root/formal/ZkRV32I/Machine.lean"
lean_finite="$repo_root/formal/ZkRV32I/Refinement/Step.lean"
rust_core="$repo_root/rust/src/lib.rs"

instructions=(
    lui auipc jal jalr beq bne blt bge bltu bgeu
    lb lh lw lbu lhu sb sh sw
    addi slti sltiu xori ori andi slli srli srai
    add sub sll slt sltu xor srl sra or and
    fence ecall ebreak
)

for instruction in "${instructions[@]}"; do
    if ! grep -Fq "| .$instruction" "$lean_machine"; then
        echo "Lean machine step is missing .$instruction." >&2
        exit 1
    fi
    if ! grep -Fq "| .$instruction" "$lean_finite"; then
        echo "Lean finite refinement model is missing .$instruction." >&2
        exit 1
    fi
    rust_variant="${instruction^}"
    if ! grep -Fq "Instruction::$rust_variant" "$rust_core"; then
        echo "Rust step is missing Instruction::$rust_variant." >&2
        exit 1
    fi
done

echo "All 40 RV32I instruction variants have Lean machine, Lean finite-model, and Rust step cases."
