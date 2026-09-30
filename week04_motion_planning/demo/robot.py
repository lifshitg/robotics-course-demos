"""Two-link geometry and conservative sampled collision checking (metres/radians)."""
import math

L1, L2 = 0.6, 0.4
LIMIT = math.pi
LINK_RADIUS = 0.03
PADDING = 0.01
OBSTACLE = (0.80, 0.0, 0.12)
START, GOAL = (-0.7, 0.6), (0.7, -0.6)
EDGE_STEP = 0.01


def validate(q):
    if len(q) != 2 or not all(math.isfinite(v) and abs(v) <= LIMIT for v in q):
        raise ValueError('Configuration must contain two finite angles within [-pi, pi].')
    return tuple(q)


def forward_points(q):
    q1, q2 = validate(q)
    elbow = (L1 * math.cos(q1), L1 * math.sin(q1))
    tip = (elbow[0] + L2 * math.cos(q1 + q2),
           elbow[1] + L2 * math.sin(q1 + q2))
    return (0.0, 0.0), elbow, tip


def segment_distance(point, a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    length2 = dx * dx + dy * dy
    u = 0 if length2 == 0 else ((point[0]-a[0])*dx + (point[1]-a[1])*dy)/length2
    u = max(0.0, min(1.0, u))
    return math.hypot(point[0]-a[0]-u*dx, point[1]-a[1]-u*dy)


def clearance(q):
    """Physical separation of link capsules from the obstacle (before padding)."""
    base, elbow, tip = forward_points(q)
    center, radius = OBSTACLE[:2], OBSTACLE[2]
    return min(segment_distance(center, base, elbow),
               segment_distance(center, elbow, tip)) - radius - LINK_RADIUS


def configuration_free(q):
    return clearance(q) > PADDING  # Contact with the padded obstacle is rejected.


def interpolate(a, b, step=EDGE_STEP):
    a, b = validate(a), validate(b)
    if not math.isfinite(step) or step <= 0:
        raise ValueError('Interpolation step must be positive and finite.')
    n = max(1, math.ceil(max(abs(x-y) for x, y in zip(a, b))/step))
    return [tuple(x+(y-x)*i/n for x, y in zip(a, b)) for i in range(n+1)]


def edge_free(a, b):
    return all(configuration_free(q) for q in interpolate(a, b))
