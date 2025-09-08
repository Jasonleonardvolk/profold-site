# Invariant - Public API Teaser Pack (SAFE)

This folder contains **interface-only** files and **verifier/contract tests** that
demonstrate how external systems would interact with Invariant's engine, without
revealing internal kernels, parameters, or numerical methods.

## Contents
- `invariant_api.py` - Public-facing interface skeleton (raises NotImplementedError).
- `phase_metrics.py` - Commodity circular statistics helpers (no engine logic).
- `proof_json_schema.json` - JSON Schema for validating the Canonical Proof JSON.
- `tests\test_contracts.py` - Ensures the public API contract exists (no kernels).
- `tests\test_proof_schema.py` - Validates the proof JSON shape (no internals).

## Safety & License
- These files are **view-only** and **no-derivatives**.
- Reverse-engineering is prohibited by site ToS and file headers.
- For functional demos and kernels, see **ProofKit under NDA**.

## Public anchors
- `/proof/canonical_run_proof.json`
- `/papers/Zero_Drift_Neural_Computation.pdf`
- `/validation/first-vs-canonical.html`
