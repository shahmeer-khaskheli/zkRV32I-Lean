# Proof Manifest

## Lean audit

The 2026-11-21 axiom audit checked 1,631 project theorem declarations,
including the root theorem. Allowlisted dependencies were:

- `propext`
- `Quot.sound`
- `Classical.choice`
- `Lean.ofReduceBool`

The audit found no project-defined axioms.

## Proof boundaries

This manifest does not count proof strength or implementation coverage.
It reports the declarations and policy evidence available at the pinned tool
and source revision.

Relevant proof areas include ELF geometry, disjoint segment writes,
`BinaryTrace`, stop reasons, and finite Rust-memory/step refinement.
External source, compiler, hardware, and cryptographic boundaries remain open.
