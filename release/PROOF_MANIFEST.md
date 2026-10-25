# Historical Proof Manifest Snapshot

> **Historical snapshot.** This manifest does not include the later ELF-loader
> and binary-trace declarations. The current theorem scope and axiom audit are
> described in [README.md](../README.md) and
> [TECHNICAL_WHITEPAPER.md](../TECHNICAL_WHITEPAPER.md).

This manifest lists the theorem declarations present in the Lean source and their
current `#print axioms` audit. “Established” describes only the stated Lean
proposition; it does not imply correctness of a production circuit or verifier.

## Register and step properties

| Theorem | What it establishes |
|---|---|
| `ZkRV32I.RegisterFile.x0_write_invariant` | The `RegisterFile.x0` accessor returns zero after any `RegisterFile.write`. In this model the accessor is defined as the constant zero; this is not a theorem about an independently stored x0 cell. |
| `ZkRV32I.x0_preserved_by_step` | For a successful `step`, the successor's `regs.x0` accessor equals zero. The accessor is constant, so the statement is vacuous about the stored register function. |
| `_root_.x0_preserved_by_step` | The same constant-accessor property at the root namespace; the proof is `rfl` and does not use the successful-step hypothesis. |

## Trace properties

| Theorem | What it establishes |
|---|---|
| `ZkRV32I.valid_trace_length_bounds` | A valid trace has at least one row and no more than `MAX_TRACE`; the upper bound is also stored in the `Trace` structure. |
| `ZkRV32I.zero_length_trace_invalid` | A trace with length zero is not valid. |
| `ZkRV32I.singleton_valid_trace` | A singleton trace containing an `initial` state is valid. |
| `ZkRV32I.adjacent_rows_are_valid_transitions` | Every adjacent pair of rows in a valid trace satisfies `valid_transition`, which is defined by existence of an instruction whose existing `step` returns the next state. |
| `ZkRV32I.x0_zero_throughout_valid_trace` | Every row's `regs.x0` accessor is zero. The accessor is constant, so this does not establish stored-register preservation independently of that definition. |

## Field lemmas

| Theorem | What it establishes |
|---|---|
| `ZkRV32I.Circuit.field_add_self` | Addition of an element to itself is zero in the Boolean F₂ encoding. |
| `ZkRV32I.Circuit.field_add_comm` | Encoded addition is commutative. |
| `ZkRV32I.Circuit.field_add_assoc` | Encoded addition is associative. |
| `ZkRV32I.Circuit.field_mul_comm` | Encoded multiplication is commutative. |
| `ZkRV32I.Circuit.field_mul_assoc` | Encoded multiplication is associative. |
| `ZkRV32I.Circuit.field_add_zero` | Zero is a right identity for encoded addition. |
| `ZkRV32I.Circuit.field_mul_one` | One is a right identity for encoded multiplication. |
| `ZkRV32I.Circuit.field_mul_add` | Encoded multiplication distributes over encoded addition. |
| `ZkRV32I.Circuit.field_mul_inv_of_nonzero` | For a nonzero Boolean element, the provided `fieldInv` multiplies to one. |

## Constraint correspondence

| Theorem | Direction | What it establishes |
|---|---|---|
| `ZkRV32I.Circuit.completeness_valid_trace_encoding_satisfies_constraints` | Completeness | A `valid_trace` and its current `encode` result satisfy the defined `constraintsSatisfied` predicate. The encoding stores the trace and an empty gate list. |
| `ZkRV32I.Circuit.soundness_transition_constraints_imply_isa_transitions` | Soundness (transition predicate only) | The `transitionConstraints` hypothesis implies each adjacent pair satisfies `valid_transition`. This follows directly because `transitionConstraints` is defined as that predicate. It is not soundness of an algebraic or cryptographic verifier. |

## Axiom dependencies

`#print axioms` reports only Lean's standard `propext` and `Quot.sound`
dependencies for the listed theorems. The field algebra lemmas other than
`field_mul_inv_of_nonzero` report no axioms; that inverse lemma reports
`propext`. No project-defined axioms, `sorry`, or `admit` declarations were found
by the source scan.
