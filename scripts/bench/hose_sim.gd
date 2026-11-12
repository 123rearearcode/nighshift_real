# PHYSICS ONLY: the vacuum hose. A chain of points joined by fixed-length links (a "verlet rope").
# One end is fixed to the dust bin. The other end is drawn toward the vacuum nozzle by a spring, so
# when the hose is taut it cannot follow and instead holds the nozzle back (`tug`). Pieces lying on
# the bench are obstacles: the hose lies around them, not through them. No drawing, no input.
# Seen from above there is no gravity: friction makes the hose settle.
extends RefCounted

const POINTS: int = 24
const BASE_LENGTH: float = 640.0      # px; reaches every part of the PC from the bin
const LONG_LENGTH: float = 860.0      # px; with the "longer hose" upgrade
const DAMPING: float = 0.78           # share of speed kept each physics step (table friction)
const ITERATIONS: int = 14
const SMOOTHING: float = 0.05         # pulls each point toward its neighbours' middle, so it bends smoothly
const END_STIFFNESS: float = 0.5      # how hard the nozzle end is drawn toward the vacuum each iteration
const POINT_RADIUS: float = 3.0       # half the hose's thickness, used for obstacles
const SLEEP_SPEED: float = 0.12       # px per step; a hose moving slower than this everywhere comes to a complete stop
const MAX_STEP: float = 18.0          # px; no point may move further than this in one step (stops whipping)

var pos := PackedVector2Array()
var prev := PackedVector2Array()
var anchor := Vector2.ZERO
var segment: float = BASE_LENGTH / float(POINTS - 1)
var tug := Vector2.ZERO               # where the hose end is relative to where it was drawn to (0 when slack)


func length() -> float:
    return segment * float(POINTS - 1)


func set_length(total: float) -> void:
    segment = maxf(total, 100.0) / float(POINTS - 1)


# Lay the hose out as a gentle bow between the two ends (the bow uses up any slack).
func reset(anchor_point: Vector2, end_point: Vector2) -> void:
    anchor = anchor_point
    pos.resize(POINTS)
    prev.resize(POINTS)
    var line: Vector2 = end_point - anchor_point
    var distance: float = maxf(line.length(), 1.0)
    var slack: float = maxf(0.0, length() - distance)
    var bow: float = sqrt(3.0 * distance * slack / 8.0)
    var side: Vector2 = line.normalized().orthogonal()
    for i in range(POINTS):
        var t: float = float(i) / float(POINTS - 1)
        var p: Vector2 = anchor_point.lerp(end_point, t) + side * sin(t * PI) * bow
        pos[i] = p
        prev[i] = p
    tug = Vector2.ZERO


# Push a point out of an obstacle box (a piece lying on the bench). `obstacle` has center, angle, half.
static func push_out(p: Vector2, obstacle: Dictionary, margin: float) -> Vector2:
    var angle: float = obstacle["angle"]
    var half: Vector2 = obstacle["half"] + Vector2(margin, margin)
    var local: Vector2 = (p - obstacle["center"]).rotated(-angle)
    if absf(local.x) >= half.x or absf(local.y) >= half.y:
        return p
    var gap_x: float = half.x - absf(local.x)
    var gap_y: float = half.y - absf(local.y)
    if gap_x < gap_y:
        local.x = half.x * (1.0 if local.x >= 0.0 else -1.0)
    else:
        local.y = half.y * (1.0 if local.y >= 0.0 else -1.0)
    return obstacle["center"] + local.rotated(angle)


func step(delta: float, anchor_point: Vector2, desired_end: Vector2, obstacles: Array = []) -> void:
    if pos.size() != POINTS:
        reset(anchor_point, desired_end)
        return
    anchor = anchor_point
    if delta <= 0.0:
        return
    for i in range(1, POINTS):
        var velocity: Vector2 = ((pos[i] - prev[i]) * DAMPING).limit_length(MAX_STEP)
        prev[i] = pos[i]
        pos[i] += velocity
    pos[0] = anchor_point
    prev[0] = anchor_point
    var last: int = POINTS - 1
    for iteration in range(ITERATIONS):
        pos[last] = pos[last].lerp(desired_end, END_STIFFNESS)
        for i in range(POINTS - 1):
            var link: Vector2 = pos[i + 1] - pos[i]
            var distance: float = link.length()
            if distance < 0.0001:
                continue
            var correction: Vector2 = link * ((distance - segment) / distance)
            if i == 0:
                pos[1] -= correction
            else:
                pos[i] += correction * 0.5
                pos[i + 1] -= correction * 0.5
        for i in range(1, last):
            pos[i] = pos[i].lerp((pos[i - 1] + pos[i + 1]) * 0.5, SMOOTHING)
        for i in range(1, last):   # the nozzle end is exempt: it is always where the vacuum is
            for obstacle: Dictionary in obstacles:
                pos[i] = push_out(pos[i], obstacle, POINT_RADIUS)
    pos[0] = anchor_point
    tug = pos[last] - desired_end
    var calm: bool = true
    for i in range(1, POINTS):
        if pos[i].distance_to(prev[i]) > SLEEP_SPEED:
            calm = false
            break
    if calm:
        for i in range(1, POINTS):
            prev[i] = pos[i]


# Largest difference between a link's length and the nominal length (used by the regression suite).
func worst_link_error() -> float:
    var worst: float = 0.0
    for i in range(pos.size() - 1):
        worst = maxf(worst, absf(pos[i].distance_to(pos[i + 1]) - segment))
    return worst
