"""Planar two-link arm mathematics. Angles in radians, lengths in metres."""

import math

L1 = 0.6
L2 = 0.4
LIMIT = math.pi


def validate_joints(q1, q2):
    if not all(math.isfinite(q) for q in (q1, q2)):
        raise ValueError('Joint angles must be finite.')
    if any(abs(q) > LIMIT for q in (q1, q2)):
        raise ValueError('Each joint angle must be within [-pi, pi].')
    return q1, q2


def forward(q1, q2):
    """Return end-effector (x, y) in base_link."""
    validate_joints(q1, q2)
    return (L1 * math.cos(q1) + L2 * math.cos(q1 + q2),
            L1 * math.sin(q1) + L2 * math.sin(q1 + q2))


def inverse(x, y, branch='positive'):
    """Return one IK branch, selected by the sign of elbow angle q2."""
    if branch not in ('positive', 'negative'):
        raise ValueError('Branch must be positive or negative.')
    if not all(math.isfinite(v) for v in (x, y)):
        raise ValueError('Target coordinates must be finite.')
    radius = math.hypot(x, y)
    if radius < abs(L1 - L2) - 1e-12 or radius > L1 + L2 + 1e-12:
        raise ValueError('Unreachable target: radius must be between 0.2 and 1.0 m.')
    cosine = (x*x + y*y - L1*L1 - L2*L2) / (2 * L1 * L2)
    # Clamp only numerical roundoff after the workspace check above.
    q2 = math.acos(max(-1.0, min(1.0, cosine)))
    if branch == 'negative':
        q2 = -q2
    q1 = math.atan2(y, x) - math.atan2(L2 * math.sin(q2), L1 + L2 * math.cos(q2))
    q1 = math.atan2(math.sin(q1), math.cos(q1))
    return validate_joints(q1, q2)
