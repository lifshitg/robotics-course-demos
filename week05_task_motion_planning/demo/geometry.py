"""Swept-disk checks against axis-aligned rectangles; contact is collision."""
import json
import math
from pathlib import Path


def load_scene(path=None):
    scene = json.loads(Path(path or Path(__file__).with_name('scene.json')).read_text())
    validate_scene(scene)
    return scene


def validate_scene(scene):
    try:
        width, height = scene['size']
        radii = scene['empty_radius'], scene['loaded_radius']
        if not all(math.isfinite(v) and v > 0 for v in (width, height, *radii)):
            raise ValueError('Sizes and radii must be finite and positive.')
        if radii[1] < radii[0] or 2 * radii[1] >= min(width, height):
            raise ValueError('Loaded radius must be at least the empty radius and fit the workspace.')
        if not scene['locations']:
            raise ValueError('At least one named location is required.')
        for p in scene['locations'].values():
            if len(p) != 2 or not all(math.isfinite(v) for v in p):
                raise ValueError('Location coordinates must be finite xy pairs.')
            if not (0 <= p[0] <= width and 0 <= p[1] <= height):
                raise ValueError('Location outside workspace.')
        for rect in scene['obstacles']:
            x0, x1, y0, y1 = rect
            if not all(math.isfinite(v) for v in rect) or not (0 <= x0 < x1 <= width and 0 <= y0 < y1 <= height):
                raise ValueError('Invalid obstacle rectangle.')
        for a, b in scene['connections']:
            if a == b or a not in scene['locations'] or b not in scene['locations']:
                raise ValueError('Connections need two distinct known locations.')
    except (KeyError, TypeError) as error:
        raise ValueError('Malformed scene data.') from error


def point_segment_distance(p, a, b):
    dx, dy = b[0]-a[0], b[1]-a[1]
    squared = dx*dx+dy*dy
    t = 0 if squared == 0 else ((p[0]-a[0])*dx+(p[1]-a[1])*dy)/squared
    t = max(0., min(1., t))
    return math.hypot(p[0]-a[0]-t*dx, p[1]-a[1]-t*dy)


def segment_rectangle_distance(a, b, rect):
    x0, x1, y0, y1 = rect
    # Slab intersection: does the center segment pass through the rectangle?
    low, high = 0., 1.
    for start, end, minimum, maximum in ((a[0], b[0], x0, x1), (a[1], b[1], y0, y1)):
        delta = end-start
        if delta == 0:
            if not minimum <= start <= maximum:
                low, high = 1., 0.
                break
        else:
            t0, t1 = sorted(((minimum-start)/delta, (maximum-start)/delta))
            low, high = max(low, t0), min(high, t1)
    if low <= high:
        return 0.
    def point_rectangle(p):
        return math.hypot(max(x0-p[0], 0., p[0]-x1), max(y0-p[1], 0., p[1]-y1))
    return min(point_rectangle(a), point_rectangle(b),
               *(point_segment_distance(c, a, b) for c in ((x0,y0),(x0,y1),(x1,y0),(x1,y1))))


def check_motion(scene, a, b, radius):
    """Return (valid, reason) for the entire straight segment, not sampled points."""
    if not math.isfinite(radius) or radius <= 0 or any(
            len(p) != 2 or not all(math.isfinite(v) for v in p) for p in (a,b)):
        raise ValueError('Motion needs finite xy pairs and a positive finite radius.')
    width, height = scene['size']
    # Convex workspace: endpoint containment implies segment containment.
    if any(not (radius < p[0] < width-radius and radius < p[1] < height-radius) for p in (a,b)):
        return False, 'Footprint touches or crosses the workspace boundary.'
    for i, rect in enumerate(scene['obstacles']):
        distance = segment_rectangle_distance(a, b, rect)
        if distance <= radius + 1e-12:
            return False, f'Wall {i+1}: centerline clearance {distance:.3f} m <= radius {radius:.3f} m.'
    return True, 'Swept disk is clear.'
