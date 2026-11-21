# Known Limitations

## ELF

- ELF bytes are bounded to 1 MiB.
- Transcript memory is bounded to 64 KiB.
- One or more loadable segments are accepted only if disjoint and within the
  bounded window.
- Dynamic linking, relocations, PIE, and general ELF ABI behavior are not
  implemented by the transcript profile.

## Transcript

- A fuel-limit record is not external execution attestation.
- A fault record is checked against modeled state and names.
- A transcript proves the checked row path; it does not prove how an external
  runner produced that path.

## Rust and hardware

- `rust/src/lib.rs` is not extracted into Lean.
- Rust tests do not prove compiler or machine-code equivalence.
- No processor, RTL, FPGA, timing, or side-channel result exists.

## ZK

- No production AIR/R1CS, prover, verifier, commitment scheme, or
  cryptographic soundness result exists.
