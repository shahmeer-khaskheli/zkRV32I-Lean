# Trusted Computing Base

## Trusted components

- Lean 4.19.0 and its kernel;
- the pinned Lake build;
- the Lean definitions under `formal/`;
- Bash and Python used to run repository checks;
- the Rust host toolchain used for tests and transcript emission.

## Attested properties

The verification gate reports source integrity, build correctness, axiom
allowlisting, instruction coverage, and test execution. It does not attest an
external processor or machine-code artifact.

## Transcript trust

Transcript v2 is a structured input to Lean. Lean verifies internal consistency
and modeled transitions, but the record can only be as trustworthy as the
process that emitted it.

In particular:

- `fuel_limit` is not hardware attestation;
- halt evidence is the Lean terminal state after checked modeled steps;
- fault evidence is matched against Lean's modeled state and error name;
- snapshot matching proves that a JSON record equals the Lean snapshot
  construction, not that the host hardware guaranteed it.
