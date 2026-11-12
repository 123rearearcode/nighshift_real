# PHYSICS ONLY: dust bundles and a vacuum. No drawing, no input.
# Dust contains independent one-node specks plus BUNDLES of 3 to 14 nodes,
# anchored at one end. The vacuum pulls toward its nozzle; it never pushes anything away.
# Each bundle has a grip. Suction builds up "pull" on a bundle while the nozzle is near it
# (stronger when closer); when pull reaches the grip the bundle comes loose and is sucked in.
# A longer bundle has a stronger grip, so the nozzle has to be held on it for longer. Pull fades
# away if the nozzle leaves. The brush never removes dust: it loosens bundles (lowers their grip)
# so the vacuum is faster afterwards.
# v0.8.0 reduces density and speeds suction; regression timing runs this GDScript in Godot.
extends RefCounted

const DustZones = preload("res://scripts/data/dust_zones.gd")

const TOOL_VACUUM: int = 0
const TOOL_BRUSH: int = 1

const STUCK: int = 0
const LOOSE: int = 1
const GONE: int = 2

# Bundle shape and grip
const NODE_SPACING: float = 6.0
const MIN_NODES: int = 3
const EXTRA_NODES: int = 12           # nodes = 3 + floor(rand^2 * 12): mostly short, a few long
const GRIP_BASE: float = 0.8
const GRIP_PER_NODE: float = 0.3      # grip = (0.8 + 0.3 * nodes) * random 0.85 .. 1.15
const GRIP_JITTER_LOW: float = 0.85
const GRIP_JITTER_HIGH: float = 1.15
const ANCHOR_MARGIN: float = 10.0
const WIGGLE: float = 0.35            # how much a bundle bends from node to node (radians)

# Vacuum
const VAC_RADIUS: float = 50.0        # suction reaches this far from the nozzle
const VAC_FALLOFF: float = 1.5        # suction = (1 - distance / radius) ^ 1.5
const INTAKE_RADIUS: float = 14.0     # a loose bundle this close to the nozzle is swallowed
const RAMP_UP: float = 0.2           # seconds for suction to build to full
const RAMP_DOWN: float = 0.15
const PULL_RATE: float = 4.0          # faster trial suction; exact feel remains provisional
const PULL_DECAY: float = 0.6         # pull lost per second when the nozzle is not close
const LOOSE_SPEED: float = 520.0      # px per second toward the nozzle once a bundle is free
const MAX_LOOSE_LIFE: float = 1.5     # a free bundle that never reaches the nozzle vanishes after this
const STRETCH_MAX: float = 10.0       # how far a gripped bundle's free end stretches toward the nozzle

# Brush
const BRUSH_RADIUS: float = 34.0
const BRUSH_LOOSEN_RATE: float = 1.6  # grip share lost per second at full brushing speed
const BRUSH_SPEED_REF: float = 500.0  # mouse speed (px/s) that counts as full speed
const LOOSEN_FLOOR: float = 0.2       # brushing can lower a grip to 20% of normal, never to zero
const BRUSH_TOUCH: float = 12.0       # a bristle tip this close to a bundle's nodes touches it
const FLICK_AT: float = 0.35          # once grip is loosened below this share, a moving brush flicks the bundle off
const FLICK_SPEED: float = 240.0      # px per second a flicked bundle flies along the stroke
const FLICK_MIN_K: float = 0.25       # brushing slower than this share of full speed only loosens
const FLICK_LIFE: float = 1.2         # flicked bundles start this old, so they vanish after a short flight

var brush_contacts := PackedVector2Array()
var blockers: Array = []
var hidden_zones: Dictionary = {}
var count: int = 0
var vac_ramp: float = 0.0

# One entry per bundle (parallel arrays).
var b_zone: PackedInt32Array = PackedInt32Array()
var b_n: PackedInt32Array = PackedInt32Array()
var b_state: PackedInt32Array = PackedInt32Array()
var b_grip: PackedFloat32Array = PackedFloat32Array()
var b_pull: PackedFloat32Array = PackedFloat32Array()
var b_loosen: PackedFloat32Array = PackedFloat32Array()   # 1 = full grip, down to LOOSEN_FLOOR
var b_stress: PackedFloat32Array = PackedFloat32Array()   # pull / grip, 0 .. 1 (drives the stretch)
var b_life: PackedFloat32Array = PackedFloat32Array()
var b_vel: PackedVector2Array = PackedVector2Array()
var b_center: PackedVector2Array = PackedVector2Array()
var b_radius: PackedFloat32Array = PackedFloat32Array()
var rest: Array = []     # PackedVector2Array per bundle: where the nodes sit
var shown: Array = []    # PackedVector2Array per bundle: where to draw them (stretched or flying)

var b_remaining: PackedFloat64Array = PackedFloat64Array()

var zone_weight: PackedFloat32Array = PackedFloat32Array()    # dust amount per zone (sum of nodes)
var zone_removed: PackedFloat32Array = PackedFloat32Array()
var zone_bundles: Array = []   # Array of Array[int]: bundle indices per zone

var _zones: Array = []
var _origin: Vector2 = Vector2.ZERO
var _seed: int = 1


# Build the dust for every zone. Positions are in screen coordinates (zone rect + origin).
func setup(zones: Array, origin: Vector2, seed_value: int) -> void:
    _zones = zones
    _origin = origin
    _seed = seed_value
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    count = 0
    blockers = []
    hidden_zones = {}
    b_remaining = PackedFloat64Array()
    vac_ramp = 0.0
    b_zone = PackedInt32Array()
    b_n = PackedInt32Array()
    b_state = PackedInt32Array()
    b_grip = PackedFloat32Array()
    b_pull = PackedFloat32Array()
    b_loosen = PackedFloat32Array()
    b_stress = PackedFloat32Array()
    b_life = PackedFloat32Array()
    b_vel = PackedVector2Array()
    b_center = PackedVector2Array()
    b_radius = PackedFloat32Array()
    rest = []
    shown = []
    zone_weight = PackedFloat32Array()
    zone_removed = PackedFloat32Array()
    zone_bundles = []
    for zi in range(zones.size()):
        var z: Dictionary = zones[zi]
        var area: Rect2 = z["rect"]
        area.position += origin
        zone_weight.append(0.0)
        zone_removed.append(0.0)
        var list: Array = []
        for k in range(int(z["bundles"]) + int(z.get("specks", 0))):
            var speck: bool = k >= int(z["bundles"])
            var n: int = 1 if speck else MIN_NODES + int(floor(pow(rng.randf(), 2.0) * EXTRA_NODES))
            var ang: float = rng.randf() * TAU
            var p := Vector2(
                rng.randf_range(area.position.x + ANCHOR_MARGIN, area.end.x - ANCHOR_MARGIN),
                rng.randf_range(area.position.y + ANCHOR_MARGIN, area.end.y - ANCHOR_MARGIN))
            var nodes := PackedVector2Array()
            var sum := Vector2.ZERO
            for i in range(n):
                var q := Vector2(
                    clampf(p.x, area.position.x + 2.0, area.end.x - 2.0),
                    clampf(p.y, area.position.y + 2.0, area.end.y - 2.0))
                nodes.append(q)
                sum += q
                p += Vector2(cos(ang), sin(ang)) * NODE_SPACING
                ang += rng.randf_range(-WIGGLE, WIGGLE)
            var idx: int = b_zone.size()
            b_zone.append(zi)
            b_n.append(n)
            b_remaining.append(float(n))
            b_state.append(STUCK)
            b_grip.append((0.55 if speck else GRIP_BASE + GRIP_PER_NODE * n) * rng.randf_range(GRIP_JITTER_LOW, GRIP_JITTER_HIGH))
            b_pull.append(0.0)
            b_loosen.append(1.0)
            b_stress.append(0.0)
            b_life.append(0.0)
            b_vel.append(Vector2.ZERO)
            b_center.append(sum / float(n))
            b_radius.append(n * NODE_SPACING)
            rest.append(nodes)
            shown.append(nodes)
            list.append(idx)
            zone_weight[zi] += float(n)
        zone_bundles.append(list)
    count = b_zone.size()


# Put all the dust back exactly as it started.
func reset() -> void:
    setup(_zones, _origin, _seed)


func zone_count() -> int:
    return zone_bundles.size()


# Share (0..1) of a zone's dust that has been removed.
func removed_fraction(zone: int) -> float:
    if zone < 0 or zone >= zone_weight.size() or zone_weight[zone] <= 0.0:
        return 0.0
    return clampf(zone_removed[zone] / zone_weight[zone], 0.0, 1.0)


# Share (0..1) of all the dust in the case that is still there.
func remaining_fraction() -> float:
    var total: float = 0.0
    var removed: float = 0.0
    for z in range(zone_weight.size()):
        total += zone_weight[z]
        removed += zone_removed[z]
    if total <= 0.0:
        return 0.0
    return 1.0 - removed / total


func _remove(b: int) -> void:
    if b_state[b] == GONE:
        return
    b_state[b] = GONE
    var zi: int = b_zone[b]
    zone_removed[zi] += b_remaining[b]
    b_remaining[b] = 0.0


# The last few bundles of a zone drop away once it counts as clean.
func shake_off_zone(zone: int) -> void:
    if zone < 0 or zone >= zone_bundles.size():
        return
    var list: Array = zone_bundles[zone]
    for b: int in list:
        _remove(b)


# Restore an exact removed fraction, including partial bundle weight (no reload rounding gains).
func apply_progress(zone: int, fraction: float) -> void:
    if zone < 0 or zone >= zone_bundles.size():
        return
    var target: float = clampf(fraction, 0.0, 1.0) * zone_weight[zone]
    var list: Array = zone_bundles[zone]
    for b: int in list:
        var needed: float = target - zone_removed[zone]
        if needed <= 0.00001:
            break
        if b_remaining[b] <= needed + 0.00001:
            _remove(b)
        else:
            b_remaining[b] -= needed
            zone_removed[zone] += needed
            break


func clear_all() -> void:
    for zi in range(zone_bundles.size()):
        shake_off_zone(zi)


# Access restrictions affect vacuum AND brush, not just the drawing.
func set_blockers(new_blockers: Array) -> void:
    blockers = new_blockers.duplicate(true)
    for blocker: Dictionary in blockers:
        var r: Rect2 = blocker["rect"]
        blocker["corners"] = [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
    hidden_zones.clear()
    for zi in range(_zones.size()):
        var cover: String = str(_zones[zi].get("covered_by", ""))
        for blocker: Dictionary in blockers:
            if cover != "" and blocker["id"] == cover: hidden_zones[zi] = true

func is_hidden(b: int) -> bool:
    return hidden_zones.has(b_zone[b])

func has_access(b: int, tool_pos: Vector2) -> bool:
    if is_hidden(b): return false
    var zone_id: String = str(_zones[b_zone[b]]["id"])
    var target: Vector2 = b_center[b]
    for blocker: Dictionary in blockers:
        if blocker["id"] == zone_id: continue # its own top surface is accessible
        var r: Rect2 = blocker["rect"]
        if r.has_point(tool_pos) or r.has_point(target): return false
        var corners: Array = blocker["corners"]
        for i in range(4):
            if Geometry2D.segment_intersects_segment(tool_pos, target, corners[i], corners[(i + 1) % 4]) != null:
                return false
    return true

# Surface dust follows the removed component instead of remaining at its old mount.
func translate_zone(zone: int, offset: Vector2) -> void:
    if offset.is_zero_approx(): return
    for b: int in zone_bundles[zone]:
        var resting: PackedVector2Array = rest[b].duplicate()
        var visible: PackedVector2Array = shown[b].duplicate()
        for i in range(resting.size()): resting[i] += offset
        for i in range(visible.size()): visible[i] += offset
        rest[b] = resting
        shown[b] = visible
        b_center[b] += offset

func _nearest_dist(nodes: PackedVector2Array, p: Vector2) -> float:
    var best: float = INF
    for v: Vector2 in nodes:
        best = minf(best, v.distance_squared_to(p))
    return sqrt(best)


func _nearest_index(nodes: PackedVector2Array, p: Vector2) -> int:
    var best: float = INF
    var idx: int = 0
    for i in range(nodes.size()):
        var d: float = nodes[i].distance_squared_to(p)
        if d < best:
            best = d
            idx = i
    return idx


# One physics tick. `active` is true while the player holds the tool button.
func step(delta: float, tool_id: int, tool_pos: Vector2, tool_vel: Vector2, active: bool) -> void:
    var vac_on: bool = active and tool_id == TOOL_VACUUM
    var brushing: bool = active and tool_id == TOOL_BRUSH
    if vac_on:
        vac_ramp = minf(1.0, vac_ramp + delta / RAMP_UP)
    else:
        vac_ramp = maxf(0.0, vac_ramp - delta / RAMP_DOWN)
    var brush_k: float = clampf(tool_vel.length() / BRUSH_SPEED_REF, 0.0, 1.0)
    for b in range(count):
        var st: int = b_state[b]
        if st == GONE or is_hidden(b):
            continue
        if st == STUCK:
            _step_stuck(b, delta, tool_pos, tool_vel, vac_on, brushing, brush_k)
        else:
            _step_loose(b, delta, tool_pos)


func _step_stuck(b: int, delta: float, tool_pos: Vector2, tool_vel: Vector2, vac_on: bool, brushing: bool, brush_k: float) -> void:
    var near: bool = b_center[b].distance_to(tool_pos) <= b_radius[b] + VAC_RADIUS
    var dmin: float = INF
    var reachable: bool = near and has_access(b,tool_pos)
    if reachable:
        dmin = _nearest_dist(rest[b], tool_pos)
    var brush_distance: float = dmin
    if brushing and reachable and not brush_contacts.is_empty():
        brush_distance = INF
        for point: Vector2 in brush_contacts: brush_distance = minf(brush_distance,_nearest_dist(rest[b],point))
    if brushing and near and brush_distance < (BRUSH_TOUCH if not brush_contacts.is_empty() else BRUSH_RADIUS):
        b_loosen[b] = maxf(LOOSEN_FLOOR, b_loosen[b] - BRUSH_LOOSEN_RATE * brush_k * delta)
        if b_loosen[b] <= FLICK_AT and brush_k >= FLICK_MIN_K:
            # Loosened enough: the stroke sweeps the bundle off the part.
            b_state[b] = LOOSE
            b_life[b] = FLICK_LIFE
            b_vel[b] = tool_vel.normalized() * FLICK_SPEED
            b_stress[b] = 0.0
            shown[b] = (rest[b] as PackedVector2Array).duplicate()
            return
    if vac_on and dmin < VAC_RADIUS:
        var s: float = pow(1.0 - dmin / VAC_RADIUS, VAC_FALLOFF) * vac_ramp
        b_pull[b] += s * PULL_RATE * delta
    else:
        b_pull[b] = maxf(0.0, b_pull[b] - PULL_DECAY * delta)
    var grip_now: float = b_grip[b] * b_loosen[b]
    if b_pull[b] >= grip_now:
        b_state[b] = LOOSE
        b_life[b] = 0.0
        b_vel[b] = Vector2.ZERO
        b_stress[b] = 0.0
        var own: PackedVector2Array = rest[b]
        shown[b] = own.duplicate()   # a separate copy, so flying never moves the resting nodes
        return
    var stress: float = clampf(b_pull[b] / grip_now, 0.0, 1.0)
    b_stress[b] = stress
    if stress < 0.02:
        shown[b] = rest[b]
        return
    # Stretch: nodes further from the anchor lean toward the nozzle.
    var nodes: PackedVector2Array = rest[b]
    var out := PackedVector2Array()
    var last: float = maxf(1.0, float(nodes.size() - 1))
    for i in range(nodes.size()):
        var lean: Vector2 = (tool_pos - nodes[i]).limit_length(STRETCH_MAX)
        out.append(nodes[i] + lean * stress * (float(i) / last))
    shown[b] = out


func _step_loose(b: int, delta: float, tool_pos: Vector2) -> void:
    b_life[b] += delta
    var nodes: PackedVector2Array = shown[b]
    var idx: int = _nearest_index(nodes, tool_pos)
    var d: float = nodes[idx].distance_to(tool_pos)
    if vac_ramp > 0.0:
        var dir: Vector2 = (tool_pos - nodes[idx]).normalized()
        b_vel[b] = b_vel[b].lerp(dir * LOOSE_SPEED, 1.0 - exp(-26.0 * delta))
    else:
        b_life[b] += delta * 2.0   # no suction: it drops away quickly
        b_vel[b] = b_vel[b] * exp(-3.0 * delta)   # a flicked bundle slows as it flies
    var move: Vector2 = b_vel[b] * delta
    for i in range(nodes.size()):
        nodes[i] += move
    shown[b] = nodes
    if d <= INTAKE_RADIUS or b_life[b] > MAX_LOOSE_LIFE:
        _remove(b)


# Controlled exception to access blocking, reserved for the risky service pick.
func trapped_count(part_id: String) -> int:
    var total: int = 0
    for b in range(count):
        if b_state[b] != GONE and str(_zones[b_zone[b]].get("covered_by", "")) == part_id:
            total += 1
    return total

func pick_extract(part_id: String) -> bool:
    for b in range(count):
        if b_state[b] != GONE and str(_zones[b_zone[b]].get("covered_by", "")) == part_id:
            _remove(b)
            return true
    return false


func visible_count() -> int:
    var n: int = 0
    for b in range(count):
        if b_state[b] != GONE and not is_hidden(b): n += 1
    return n

func transform_zone(zone_index: int, old_center: Vector2, new_center: Vector2, angle_delta: float) -> void:
    if old_center.is_equal_approx(new_center) and absf(angle_delta) < 0.00001: return
    for b in zone_bundles[zone_index]:
        var r: PackedVector2Array = rest[b].duplicate()
        var s: PackedVector2Array = shown[b].duplicate()
        for i in range(r.size()): r[i] = new_center+(r[i]-old_center).rotated(angle_delta)
        for i in range(s.size()): s[i] = new_center+(s[i]-old_center).rotated(angle_delta)
        rest[b] = r
        shown[b] = s
        b_center[b] = new_center+(b_center[b]-old_center).rotated(angle_delta)
