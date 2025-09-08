# Validates the public Canonical Proof JSON against the published schema.
# Uses jsonschema if available; otherwise performs minimal shape checks.

import json
import pathlib
import pytest

schema_path = pathlib.Path(__file__).resolve().parents[2] / "site" / "code" / "teasers" / "proof_json_schema.json"
proof_path  = pathlib.Path(__file__).resolve().parents[3] / "site" / "proof" / "canonical_run_proof.json"

def _has_jsonschema():
    try:
        import jsonschema  # type: ignore
        return True
    except Exception:
        return False

@pytest.mark.skipif(not proof_path.exists(), reason="Canonical proof JSON not present locally")
def test_proof_json_shape():
    data = json.loads(proof_path.read_text(encoding="utf-8"))
    if _has_jsonschema():
        import jsonschema  # type: ignore
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        jsonschema.validate(instance=data, schema=schema)
    else:
        # Minimal fallback shape check
        for k in ("invariants", "psi_replay", "coherence", "stability", "performance"):
            assert k in data
        inv = data["invariants"]
        assert "H0" in inv and "H_series" in inv and isinstance(inv["H_series"], list)
