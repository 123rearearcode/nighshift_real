# PHYSICS ONLY: the vacuum hose. A chain of points joined by fixed-length links (a "verlet rope").
# One end is fixed to the dust bin. The other end is drawn toward the vacuum nozzle by a spring, so
# when the hose is taut it cannot follow and instead holds the nozzle back (`tug`). Pieces lying on
# the bench are obstacles: the hose lies around them, not through them, and bends round their
# corners in a curve (a hose cannot fold sharply). The player can grab one point of the hose and
# carry it (`pin`). No drawing, no input. Seen from above there is no gravity: friction makes it settle.
extends RefCounted

const POINTS: int = 24
const BASE_LENGTH: float = 560.0      # px; far-left corner needs careful nozzle rotation/routing
const LONG_LENGTH: float = 760.0      # px; with the longer-hose upgrade
const DAMPING: float = 0.78           # share of speed kept each physics step (table friction)
const ITERATIONS: int = 20           # fewer than ~20 lets the bending limit and obstacles fight (found by simulation)
const SMOOTHING: float = 0.0          # bending smoothing: any value above ~0.002 keeps a slack hose wriggling forever (found by simulation), so none
const BEND_LIMIT: float = 0.9         # points two apart stay at least this share of two links apart: no joint bends more than ~52 degrees
const END_STIFFNESS: float = 0.5      # how hard the nozzle end is drawn toward the vacuum each iteration
const POINT_RADIUS: float = 3.5       # half the hose's thickness, used for obstacles
const CORNER_RADIUS: float = 20.0     # obstacles count as boxes with corners rounded up to this much, so the hose curves round them
const SLEEP_SPEED: float = 0.12       # px per step; a hose moving slower than this everywhere comes to a complete stop
const MAX_STEP: float = 18.0          # px; no point may move further than this in one step (stops whipping)
const SETTLE_FRAMES: int = 30         # once nothing has moved for this many steps, the hose lies still (table friction)
const STILL_DISTANCE: float = 0.3     # px; the nozzle or a piece moving less than this per step counts as not moving
const PIN_LIFT: int = 2               # points this close to a grabbed point are lifted off the bench (they pass over obstacles)

var pos := PackedVector2Array()
var prev := PackedVector2Array()
var anchor := Vector2.ZERO
var segment: float = BASE_LENGTH / float(POINTS - 1)
var tug := Vector2.ZERO               # where the hose end is relative to where it was drawn to (0 when slack)
var pin: int = -1                     # index of the point the player is holding, or -1
var pin_point := Vector2.ZERO         # where that point is now
var still_steps: int = 0              # steps in a row in which nothing touching the hose moved
var _last_end := Vector2.INF
var _last_obstacles := Vector2.INF


func length() -> float:
    return segment * float(POINTS - 1)


func set_length(total: float) -> void:
    segment = maxf(total, 100.0) / float(POINTS - 1)


func pinned() -> bool:
    return pin > 0 and pin < POINTS


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
    pin = -1
    still_steps = 0


# Push a point out of an obstacle (a piece lying on the bench). `obstacle` has center, angle, half.
# The obstacle is treated as a box with rounded corners, so a hose bending round it curves.
static func push_out(p: Vector2, obstacle: Dictionary, margin: float) -> Vector2:
    var angle: float = obstacle["angle"]
    var half: Vector2 = obstacle["half"]
    var corner: float = clampf(float(obstacle.get("corner_radius", CORNER_RADIUS)), 0.0, minf(half.x, half.y) * 0.5)
    var inner: Vector2 = half - Vector2(corner, corner)
    var reach: float = corner + margin
    var local: Vector2 = (p - obstacle["center"]).rotated(-angle)
    var nearest := Vector2(clampf(local.x, -inner.x, inner.x), clampf(local.y, -inner.y, inner.y))
    var away: Vector2 = local - nearest
    var distance: float = away.length()
    if distance >= reach:
        return p
    if distance > 0.0001:
        local = nearest + away / distance * reach
    else:
        # Deep inside: leave by the nearest side.
        var gap_x: float = inner.x - absf(local.x)
        var gap_y: float = inner.y - absf(local.y)
        if gap_x < gap_y:
            local.x = (inner.x + reach) * (1.0 if local.x >= 0.0 else -1.0)
        else:
            local.y = (inner.y + reach) * (1.0 if local.y >= 0.0 else -1.0)
    return obstacle["center"] + local.rotated(angle)


# Index of the hose point nearest to `point` within `radius` px, skipping the bin end and the last
# `keep_from_end` points by the nozzle. -1 when the hose is not there.
func nearest_point(point: Vector2, radius: float, keep_from_end: int) -> int:
    var best: int = -1
    var best_distance: float = radius
    for i in range(1, pos.size() - keep_from_end):
        var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, pos[i - 1], pos[i])
        var distance: float = closest.distance_to(point)
        if distance <= best_distance:
            best_distance = distance
            best = i
    return best


func step(delta: float, anchor_point: Vector2, desired_end: Vector2, obstacles: Array = [], pin_index: int = -1, pin_target := Vector2.ZERO) -> void:
    if pos.size() != POINTS:
        reset(anchor_point, desired_end)
        return
    anchor = anchor_point
    pin = pin_index if pin_index > 0 and pin_index < POINTS - 1 else -1
    if pinned():
        # The bin side of the hose cannot stretch: the held point stays within reach of the bin.
        pin_point = anchor_point + (pin_target - anchor_point).limit_length(segment * float(pin) * 0.98)
    if delta <= 0.0:
        return
    # A hose on a table stops once nothing moves it. Without this, the bending limit and the
    # obstacles can keep nudging each other for ever and the hose creeps (found by simulation).
    var obstacle_key := Vector2.ZERO
    for obstacle: Dictionary in obstacles:
        obstacle_key += Vector2(obstacle["center"]) + Vector2(obstacle["half"]) + Vector2(float(obstacle["angle"]), float(obstacle.get("corner_radius", CORNER_RADIUS)) + float(obstacles.size()))
    var quiet: bool = not pinned() and desired_end.distance_to(_last_end) < STILL_DISTANCE \
        and obstacle_key.distance_to(_last_obstacles) < STILL_DISTANCE
    _last_end = desired_end
    _last_obstacles = obstacle_key
    still_steps = still_steps + 1 if quiet else 0
    if still_steps > SETTLE_FRAMES:
        for i in range(1, POINTS):
            prev[i] = pos[i]
        return
    for i in range(1, POINTS):
        var velocity: Vector2 = ((pos[i] - prev[i]) * DAMPING).limit_length(MAX_STEP)
        prev[i] = pos[i]
        pos[i] += velocity
    pos[0] = anchor_point
    prev[0] = anchor_point
    var last: int = POINTS - 1
    var bend_gap: float = 2.0 * segment * BEND_LIMIT
    for iteration in range(ITERATIONS):
        pos[last] = pos[last].lerp(desired_end, END_STIFFNESS)
        if pinned():
            pos[pin] = pin_point
        for i in range(POINTS - 1):
            var link: Vector2 = pos[i + 1] - pos[i]
            var distance: float = link.length()
            if distance < 0.0001:
                continue
            var correction: Vector2 = link * ((distance - segment) / distance)
            var fix_low: bool = i == 0 or i == pin
            var fix_high: bool = i + 1 == pin
            if fix_low and fix_high:
                continue
            if fix_low:
                pos[i + 1] -= correction
            elif fix_high:
                pos[i] += correction
            else:
                pos[i] += correction * 0.5
                pos[i + 1] -= correction * 0.5
        # Bending limit: points two apart may not come closer than bend_gap. This only pushes when the
        # hose folds too sharply, so (unlike smoothing) it adds no energy to a resting hose.
        for i in range(POINTS - 2):
            var span: Vector2 = pos[i + 2] - pos[i]
            var apart: float = span.length()
            if apart >= bend_gap or apart < 0.0001:
                continue
            var push: Vector2 = span * ((apart - bend_gap) / apart)
            var fixed_low: bool = i == 0 or i == pin
            var fixed_high: bool = i + 2 == pin
            if fixed_low and fixed_high:
                continue
            if fixed_low:
                pos[i + 2] -= push
            elif fixed_high:
                pos[i] += push
            else:
                pos[i] += push * 0.5
                pos[i + 2] -= push * 0.5
        for i in range(1, last):
            pos[i] = pos[i].lerp((pos[i - 1] + pos[i + 1]) * 0.5, SMOOTHING)
        for i in range(1, last):   # the nozzle end is exempt: it is always where the vacuum is
            if pinned() and absi(i - pin) <= PIN_LIFT:
                continue   # lifted off the bench by the player's hand
            for obstacle: Dictionary in obstacles:
                pos[i] = push_out(pos[i], obstacle, POINT_RADIUS)
        _clear_housing_links(obstacles)
    pos[0] = anchor_point
    if pinned():
        pos[pin] = pin_point
    tug = pos[last] - desired_end
    var calm: bool = true
    for i in range(1, POINTS):
        if pos[i].distance_to(prev[i]) > SLEEP_SPEED:
            calm = false
            break
    if calm:
        for i in range(1, POINTS):
            prev[i] = pos[i]


# Nodes alone can miss a housing corner between two links. Project samples of those links
# outside the housing too; fixed anchor/held points and the lifted nozzle lead stay free.
func _clear_housing_links(obstacles: Array) -> void:
    for obstacle: Dictionary in obstacles:
        if float(obstacle.get("corner_radius", CORNER_RADIUS)) > 0.0:
            continue
        for i in range(POINTS - 2):
            if pinned() and (absi(i - pin) <= PIN_LIFT or absi(i + 1 - pin) <= PIN_LIFT):
                continue
            for fraction: float in [0.25, 0.5, 0.75]:
                var sample: Vector2 = pos[i].lerp(pos[i + 1], fraction)
                var correction: Vector2 = push_out(sample, obstacle, POINT_RADIUS) - sample
                if correction.length_squared() < 0.0001:
                    continue
                var low: float = 0.0 if i == 0 else 1.0 - fraction
                var high: float = fraction
                var weight: float = low * low + high * high
                pos[i] += correction * low / weight
                pos[i + 1] += correction * high / weight


# A point at `t` along the hose: 0 is the nozzle end, 1 is the bin (used to draw dust inside it).
func point_along(t: float) -> Vector2:
    if pos.size() < 2:
        return anchor
    var f: float = (1.0 - clampf(t, 0.0, 1.0)) * float(POINTS - 1)
    var i: int = mini(int(floor(f)), POINTS - 2)
    return pos[i].lerp(pos[i + 1], f - float(i))


# Largest difference between a link's length and the nominal length (used by the regression suite).
func worst_link_error() -> float:
    var worst: float = 0.0
    for i in range(pos.size() - 1):
        worst = maxf(worst, absf(pos[i].distance_to(pos[i + 1]) - segment))
    return worst
