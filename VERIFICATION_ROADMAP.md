# Verification Roadmap

## Completed

1. Lean RV32I state and step model.
2. Restricted ELF32 parser and loader.
3. Transcript v1 and stop-reason separation.
4. Transcript v2 with bounded multi-segment loading.
5. Disjoint-write commutativity proofs.
6. Transcript-step finite-memory/step refinement.
7. Mutation harness for ELF, snapshots, operands, and stop reasons.

## Next milestone

The next work must strengthen one boundary at a time:

1. Add a Rust or ELF loader theorem based on the exact host implementation.
2. Replace the transcript trust assumption with independently produced
   execution evidence or a signed runner attestation.
3. Expand ELF coverage only after the bounded profile is explicitly preserved.
4. Extend instruction and fault coverage from selected modeled cases to a
   defined RV32I conformance scope.
5. Connect a verified machine trace to a real constraint or circuit model.
6. Add cryptographic proof-system verification only after the constraint
   construction is complete.

No milestone should be described as complete until it has kernel-checked
proofs and a passing `bash scripts/verify_all.sh` run.
