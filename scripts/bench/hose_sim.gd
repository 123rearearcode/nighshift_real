# PHYSICS ONLY: the vacuum hose. A chain of points joined by fixed-length links (a "verlet rope").
# One end is fixed to the dust bin, the other end is pinned to the vacuum nozzle. The points in
# between swing, trail and settle on their own, so the hose reacts when the vacuum is moved or
# thrown. No drawing, no input. Seen from above there is no gravity: friction makes it settle.
extends RefCounted

const POINTS: int = 24
const SEGMENT: float = 32.0           # px between points; hose length = (POINTS - 1) * SEGMENT
const DAMPING: float = 0.90           # share of speed kept each physics step (table friction)
const ITERATIONS: int = 8
const SMOOTHING: float = 0.05         # pulls each point toward its neighbours' middle, so it bends smoothly

var pos := PackedVector2Array()
var prev := PackedVector2Array()
var anchor := Vector2.ZERO


static func total_length() -> float:
    return SEGMENT * float(POINTS - 1)


# Lay the hose out as a gentle bow between the two ends (the bow uses up any slack).
func reset(anchor_point: Vector2, end_point: Vector2) -> void:
    anchor = anchor_point
    pos.resize(POINTS)
    prev.resize(POINTS)
    var line: Vector2 = end_point - anchor_point
    var distance: float = maxf(line.length(), 1.0)
    var slack: float = maxf(0.0, total_length() - distance)
    var bow: float = sqrt(3.0 * distance * slack / 8.0)
    var side: Vector2 = line.normalized().orthogonal()
    for i in range(POINTS):
        var t: float = float(i) / float(POINTS - 1)
        var p: Vector2 = anchor_point.lerp(end_point, t) + side * sin(t * PI) * bow
        pos[i] = p
        prev[i] = p


func step(delta: float, anchor_point: Vector2, end_point: Vector2) -> void:
    if pos.size() != POINTS:
        reset(anchor_point, end_point)
        return
    anchor = anchor_point
    if delta <= 0.0:
        return
    for i in range(1, POINTS - 1):
        var velocity: Vector2 = (pos[i] - prev[i]) * DAMPING
        prev[i] = pos[i]
        pos[i] += velocity
    pos[0] = anchor_point
    prev[0] = anchor_point
    pos[POINTS - 1] = end_point
    prev[POINTS - 1] = end_point
    for iteration in range(ITERATIONS):
        for i in range(POINTS - 1):
            var link: Vector2 = pos[i + 1] - pos[i]
            var distance: float = link.length()
            if distance < 0.0001:
                continue
            var correction: Vector2 = link * ((distance - SEGMENT) / distance)
            var weight_a: float = 0.0 if i == 0 else 1.0
            var weight_b: float = 0.0 if i + 1 == POINTS - 1 else 1.0
            var total: float = weight_a + weight_b
            if total <= 0.0:
                continue
            pos[i] += correction * (weight_a / total)
            pos[i + 1] -= correction * (weight_b / total)
        for i in range(1, POINTS - 1):
            pos[i] = pos[i].lerp((pos[i - 1] + pos[i + 1]) * 0.5, SMOOTHING)
    pos[0] = anchor_point
    pos[POINTS - 1] = end_point


# Largest difference between a link's length and SEGMENT (used by the regression suite).
func worst_link_error() -> float:
    var worst: float = 0.0
    for i in range(pos.size() - 1):
        worst = maxf(worst, absf(pos[i].distance_to(pos[i + 1]) - SEGMENT))
    return worst
