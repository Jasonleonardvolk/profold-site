# Invariant Public Teaser License - View-Only / No-Derivatives / No-Reverse-Engineering
# (c) 2025 Invariant. Patent Pending. Commodity math utilities only.

import math
from typing import Iterable

def r_order_parameter(phases: Iterable[float]) -> float:
    """
    Kuramoto-style coherence estimator (commodity circular statistics).
    This is **not** an engine kernel; usable for independent validation scripts.
    """
    phases = list(phases)
    if not phases:
        return 0.0
    s = sum(math.sin(t) for t in phases)
    c = sum(math.cos(t) for t in phases)
    return (s*s + c*c) ** 0.5 / len(phases)
