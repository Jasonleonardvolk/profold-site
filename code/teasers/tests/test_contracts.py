# Tests ensure the **contract** exists and stays stable. They do not execute kernels.

import importlib
import inspect
import pytest

def test_invariant_api_contract():
    api = importlib.import_module("site.code.teasers.invariant_api".replace("/", "."))
    assert hasattr(api, "TopologySpec")
    assert hasattr(api, "InvariantEngine")

    Engine = api.InvariantEngine
    # Constructor exists and is intentionally unimplemented
    with pytest.raises(NotImplementedError):
        Engine(seed=42)

    # Methods exist and are intentionally unimplemented
    with pytest.raises(NotImplementedError):
        Engine.__init__(object, 0)  # type: ignore

    for meth in ("load_topology_schedule", "run", "inject_curvature_field"):
        assert hasattr(Engine, meth)
        assert inspect.isfunction(getattr(Engine, meth))

def test_no_kernel_leakage():
    # Ensure the teaser files do not mention sensitive identifiers
    import pathlib
    sensitive = ("np.exp(", "exp(1j", "momentum", "hamilton", "allocator", "solver")
    root = pathlib.Path(__file__).resolve().parents[2]
    for p in (root / "site" / "code" / "teasers").rglob("*.py"):
        text = p.read_text(encoding="utf-8").lower()
        for token in sensitive:
            assert token not in text, f"Sensitive token leaked in {p.name}: {token}"
