.PHONY: check lean rust riscv-object firmware verify-firmware test differential mutation verify release-check

check: lean rust

lean:
	lake build

rust:
	cargo check --manifest-path rust/Cargo.toml

riscv-object: firmware

firmware:
	cargo build --manifest-path rust/Cargo.toml --release --bin firmware --target riscv32i-unknown-none-elf

verify-firmware: firmware lean
	lake env lean --run scripts/verify_elf.lean target/riscv32i-unknown-none-elf/release/firmware

test:
	cargo check --tests --manifest-path rust/Cargo.toml

differential:
	cargo run --manifest-path adversarial/Cargo.toml

mutation:
	cargo run --manifest-path adversarial/Cargo.toml

verify: check

release-check: check
