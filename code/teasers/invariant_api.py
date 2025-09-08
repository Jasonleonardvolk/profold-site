# Invariant Public Teaser License - View-Only / No-Derivatives / No-Reverse-Engineering
# (c) 2025 Invariant. Patent Pending. For contracts and demos: bids@invariant.pro
# This file exposes a **public API contract** only. All implementations are NDA-protected.

from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Dict, List, Optional

@dataclass(frozen=True)
class TopologySpec:
    """
    Declarative topology specification for scheduling morphology changes.
    Example (public-safe):
      TopologySpec(name="ring", params={"wrap": True})
    Implementation details (operators, solvers, kernels) are NDA-only.
    """
    name: str
    params: Dict[str, Any]

class InvariantEngine:
    """
    Public contract (interface only):

    Guarantees (as verified on Canonical Proof runs):
      - Machine-precision conservation target: Delta Energy_rel <= 1.2e-16
      - Deterministic replay: psi-replay == 0.0
      - Stability: largest Lyapunov < 0 under published schedules

    Notes:
      - All numerical methods, state formats, operators, and seeds are NDA-only.
      - This class is a placeholder for integration contracts, not an implementation.
    """

    def __init__(self, seed: int, *, device: Optional[str] = None) -> None:
        """
        Initialize a deterministic engine instance bound to a reproducible seed.
        `device` is a hint (e.g., "cpu", "gpu"); binding behavior is NDA-only.
        """
        raise NotImplementedError("NDA required: implementation not provided.")

    def load_topology_schedule(self, schedule: List[TopologySpec]) -> None:
        """
        Load an externally-specified, declarative topology schedule.
        Contract: schedule application preserves conservation guarantees.
        """
        raise NotImplementedError("NDA required: implementation not provided.")

    def run(self, steps: int) -> Dict[str, Any]:
        """
        Execute the canonical closed-world computation for `steps`.
        Returns a public-safe metrics dict (e.g., dH_rel_max, R_mean, lambda_max, sps, latency).
        No state, weights, or operators are exposed.
        """
        raise NotImplementedError("NDA required: implementation not provided.")

    def inject_curvature_field(self, *args: Any, **kwargs: Any) -> None:
        """
        Public contract ONLY:
          - Applies a curvature-driven adjustment consistent with conservation targets.
          - Does not break deterministic replay (psi-replay must remain 0.0).
        Implementation is NDA-only and not included in public artifacts.
        """
        raise NotImplementedError("NDA required: implementation not provided.")
