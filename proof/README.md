# Verification Sample

This directory contains a reproducible sample trace from the INVARIANT ZeroDrift engine.

## Files

- `sample_proof.json` - 10,000 step conservation proof with hash chain
- `verify_sample.py` - Python script to independently verify the trace (coming soon)

## What This Proves

The sample demonstrates:
- Energy conservation to 5.27×10⁻¹³ (machine precision)
- Deterministic replay via SHA256 hash chain
- Topology swap invariance (3 swaps with zero drift)
- Negative Lyapunov exponent (stable dynamics)

## Running Verification

```python
# Coming soon - minimal numpy-only verification script
python verify_sample.py sample_proof.json
```

## Full ProofKit

The complete ProofKit includes:
- Extended benchmarks (10⁶+ steps)
- Multiple topologies and parameter sweeps
- GPU/TPU implementations
- Complete verifier logs

Available under NDA. Contact: jason@invariant.pro
