# PHYSICS ONLY: dust bundles and a vacuum. No drawing, no input.
# Dust contains independent one-node specks plus BUNDLES of 3 to 14 nodes,
# anchored at one end. The vacuum pulls toward its nozzle; it never pushes anything away.
# Each bundle has a grip. Suction builds up "pull" on a bundle while the nozzle is near it
# (stronger when closer); when pull reaches the grip the bundle comes loose and is sucked in.
# A longer bundle has a stronger grip, so the nozzle has to be held on it for longer. Pull fades
# away if the nozzle leaves. The brush never removes dust: it loosens bundles (lowers their grip),
# tosses loosened bundles across the case (they slide, spin, catch under parts
# or in the filter, and settle) and chips small specks off long chains. Only the vacuum removes dust.
# v0.8.0 reduces density and speeds suction; regression timing runs this GDScript in Godot.
extends RefCounted

const DustZones = preload("res://scripts/data/dust_zones.gd")

const TAIL_LIMIT: int = 3             # show only a few representative threads per installed part
const TAIL_REACH: float = 12.0        # precision suction: the nozzle must touch an exposed thread
const TAIL_PULL: float = 0.9          # slower than ordinary 4.0 pull; disassembly remains faster
const TAIL_GRIP: float = 1.8          # extra resistance from the part pinning the chain
const TOOL_VACUUM: int = 0
const TOOL_BRUSH: int = 1

const STUCK: int = 0
const LOOSE: int = 1
const GONE: int = 2
const TOSSED: int = 3                 # a bundle the brush flicked: sliding and spinning until it settles

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
const STRETCH_MAX: float = 10.0       # how far a gripped bundle's free end stretches toward the nozzle

# Brush
const BRUSH_RADIUS: float = 34.0
const BRUSH_LOOSEN_RATE: float = 1.6  # grip share lost per second at full brushing speed
const BRUSH_SPEED_REF: float = 500.0  # mouse speed (px/s) that counts as full speed
const LOOSEN_FLOOR: float = 0.2       # brushing can lower a grip to 20% of normal, never to zero
const BRUSH_TOUCH: float = 12.0       # a bristle tip this close to a bundle's nodes touches it
const FLICK_AT: float = 0.35          # once grip is loosened below this share, a moving brush flicks the bundle off
const FLICK_MIN_K: float = 0.25       # brushing slower than this share of full speed only loosens
const TOSS_PUSH: float = 0.6          # share of the brush speed a tossed bundle starts with
const TOSS_MAX_SPEED: float = 700.0   # brush speeds above this count as this
const TOSS_FRICTION: float = 3.2      # speed lost per second while sliding
const TOSS_SETTLE_SPEED: float = 14.0 # a tossed bundle slower than this settles
const TOSS_MAX_TIME: float = 1.6      # and never slides longer than this
const TOSS_SPIN: float = 4.0          # largest spin (radians per second) given to a tossed bundle
const TOSS_LOOSEN: float = 0.75       # a settled bundle grips at this share of its normal grip again
const ZONE_MARGIN: float = 2.0        # tossed dust stays this far inside its part's edge
const SHED_RATE: float = 1.4          # chance per second, at full brush speed, that a touched chain chips off a speck
const SHED_MIN_NODES: int = 3         # only chains with at least this many nodes shed (they keep two)
const SHED_SPEED: float = 0.35        # share of the brush speed a shed speck starts with
const MAX_BUNDLES: int = 420          # safety cap on the number of bundles including shed specks

var last_brush_contacts: int = 0
var brush_contacts := PackedVector2Array()
var kicked := PackedVector2Array()    # where dust was tossed or shed during the last step (for dust motes)
var swallowed: float = 0.0            # dust weight the vacuum took in since take_swallowed() was last called
var blockers: Array = []
var hidden_zones: Dictionary = {}
var count: int = 0
var vac_ramp: float = 0.0

# One entry per bundle (parallel arrays).
var case_bounds := Rect2()
var floor_zone: int = -1
var motion_changed: bool = false
var b_launch_zone := PackedInt32Array()
var b_zone: PackedInt32Array = PackedInt32Array()
var b_n: PackedInt32Array = PackedInt32Array()
var b_state: PackedInt32Array = PackedInt32Array()
var b_grip: PackedFloat32Array = PackedFloat32Array()
var b_pull: PackedFloat32Array = PackedFloat32Array()
var b_loosen: PackedFloat32Array = PackedFloat32Array()   # 1 = full grip, down to LOOSEN_FLOOR
var b_stress: PackedFloat32Array = PackedFloat32Array()   # pull / grip, 0 .. 1 (drives the stretch)
var b_life: PackedFloat32Array = PackedFloat32Array()
var b_vel: PackedVector2Array = PackedVector2Array()
var b_spin: PackedFloat32Array = PackedFloat32Array()
var b_center: PackedVector2Array = PackedVector2Array()
var b_radius: PackedFloat32Array = PackedFloat32Array()
var rest: Array = []     # PackedVector2Array per bundle: where the nodes sit
var shown: Array = []    # PackedVector2Array per bundle: where to draw them (stretched or flying)

var b_remaining: PackedFloat64Array = PackedFloat64Array()

var zone_weight: PackedFloat32Array = PackedFloat32Array()    # dust amount per zone (sum of nodes)
var zone_removed: PackedFloat32Array = PackedFloat32Array()
var zone_bundles: Array = []   # Array of Array[int]: bundle indices per zone
# Current component surfaces; attached dirt follows a part, while dislodged dirt uses the case.
var zone_center: PackedVector2Array = PackedVector2Array()
var zone_angle: PackedFloat32Array = PackedFloat32Array()
var zone_half: PackedVector2Array = PackedVector2Array()

var _zones: Array = []
var _origin: Vector2 = Vector2.ZERO
var _seed: int = 1
var _rng := RandomNumberGenerator.new()


# Build the dust for every zone. Positions are in screen coordinates (zone rect + origin).
func setup(zones: Array, origin: Vector2, seed_value: int) -> void:
    _zones = zones
    _origin = origin
    _seed = seed_value
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    _rng.seed = seed_value + 1
    kicked = PackedVector2Array()
    brush_contacts.clear()
    motion_changed = false
    floor_zone = -1
    case_bounds = Rect2()
    b_launch_zone = PackedInt32Array()
    swallowed = 0.0
    b_spin = PackedFloat32Array()
    zone_center = PackedVector2Array()
    zone_angle = PackedFloat32Array()
    zone_half = PackedVector2Array()
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
        if str(z["id"]) == "case_interior":
            floor_zone = zi
            case_bounds = area
        zone_weight.append(0.0)
        zone_removed.append(0.0)
        zone_center.append(area.get_center())
        zone_angle.append(0.0)
        zone_half.append(area.size * 0.5)
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
            b_launch_zone.append(zi)
            b_n.append(n)
            b_remaining.append(float(n))
            b_state.append(STUCK)
            b_grip.append((0.55 if speck else GRIP_BASE + GRIP_PER_NODE * n) * rng.randf_range(GRIP_JITTER_LOW, GRIP_JITTER_HIGH) * float(z.get("grip_scale", 1.0)))
            b_pull.append(0.0)
            b_loosen.append(1.0)
            b_stress.append(0.0)
            b_life.append(0.0)
            b_vel.append(Vector2.ZERO)
            b_spin.append(0.0)
            b_center.append(sum / float(n))
            b_radius.append(n * NODE_SPACING)
            rest.append(nodes)
            shown.append(nodes)
            list.append(idx)
            zone_weight[zi] += float(n)
        zone_bundles.append(list)
    count = b_zone.size()
    if not case_bounds.has_area():
        for z: Dictionary in zones:
            var area: Rect2 = z["rect"]
            area.position += origin
            case_bounds = case_bounds.merge(area) if case_bounds.has_area() else area


# Put all the dust back exactly as it started.
func reset() -> void:
    setup(_zones, _origin, _seed)


func zone_count() -> int:
    return zone_bundles.size()


# Share (0..1) of a zone's dust that has been removed.
func removed_fraction(zone: int) -> float:
    if zone < 0 or zone >= zone_weight.size():
        return 0.0
    if zone_weight[zone] <= 0.00001:
        return 1.0
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


# Real trapped dirt, represented by a short visible thread beyond the housing edge.
# This creates no extra particles/mass and never reveals the whole hidden bundle.
func tail_nodes(b: int) -> PackedVector2Array:
    var out := PackedVector2Array()
    if b_state[b] == GONE or not is_hidden(b): return out
    var list: Array = zone_bundles[b_zone[b]]
    var candidates: Array = []
    for index in range(list.size()-1,-1,-1):
        var other: int = int(list[index])
        if b_state[other] != GONE and b_n[other] > 1: candidates.append(other)
    if candidates.is_empty():
        for index in range(list.size()-1,-1,-1):
            var other: int = int(list[index])
            if b_state[other] != GONE: candidates.append(other)
    var rank: int = candidates.find(b)
    if rank < 0 or rank >= TAIL_LIMIT: return out
    var cover: String = str(_zones[b_zone[b]].get("covered_by",""))
    for blocker: Dictionary in blockers:
        if str(blocker["id"]) != cover: continue
        var rect: Rect2 = blocker["rect"]
        var at: Vector2 = b_center[b].clamp(rect.position+Vector2.ONE*3.0,rect.end-Vector2.ONE*3.0)
        var gaps: Array = [at.x-rect.position.x,rect.end.x-at.x,at.y-rect.position.y,rect.end.y-at.y]
        var normals: Array = [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
        var side: int = 0
        for edge in range(1,4):
            if float(gaps[edge]) < float(gaps[side]): side = edge
        var normal: Vector2 = normals[side]
        var lip: Vector2 = at+normal*float(gaps[side])
        var length: float = (18.0+float(b%3)*3.0 if b_n[b] > 1 else 9.0)+b_stress[b]*4.0
        var points: int = 4 if b_n[b] > 1 else 2
        for k in range(points):
            var along: float = float(k)/float(points-1)
            var wobble: float = sin(float(b*5+k*2)+b_life[b]*18.0)*b_stress[b]*1.0
            var point: Vector2 = lip+normal*(-1.0+along*length)+normal.orthogonal()*(sin(float(b+k*2))*2.0+wobble)
            out.append(point.clamp(case_bounds.position+Vector2.ONE,case_bounds.end-Vector2.ONE))
        return out
    return out


func _step_tail(b: int, delta: float, tool_pos: Vector2, vac_on: bool) -> void:
    var tail: PackedVector2Array = tail_nodes(b)
    var outside: bool = true
    for blocker: Dictionary in blockers:
        if (blocker["rect"] as Rect2).grow(1.0).has_point(tool_pos): outside = false
    if vac_on and outside and not tail.is_empty() and _nearest_dist(tail,tool_pos) <= TAIL_REACH:
        b_pull[b] += TAIL_PULL*vac_ramp*delta
        b_life[b] += delta
    else:
        b_pull[b] = maxf(0.0,b_pull[b]-PULL_DECAY*delta)
    var target: float = b_grip[b]*TAIL_GRIP
    b_stress[b] = clampf(b_pull[b]/target,0.0,1.0)
    if b_pull[b] >= target:
        swallowed += b_remaining[b]
        _remove(b)
        motion_changed = true

func has_access(b: int, tool_pos: Vector2) -> bool:
    if is_hidden(b): return false
    var zone_id: String = str(_zones[b_zone[b]]["id"])
    var target: Vector2 = b_center[b]
    if zone_id != "case_interior" and _on_surface(b_zone[b], tool_pos) and _on_surface(b_zone[b], target):
        return true
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
    zone_center[zone] += offset
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
    if brushing: brush_k = maxf(0.2, brush_k)   # light contact still loosens; fast strokes create tosses
    kicked.clear()
    motion_changed = false
    last_brush_contacts = 0
    # Bundles shed during this loop are appended after `count`, so they wait for the next step.
    var existing: int = count
    for b in range(existing):
        var st: int = b_state[b]
        if st == GONE: continue
        if is_hidden(b):
            _step_tail(b,delta,tool_pos,vac_on)
            continue
        if st == STUCK:
            _step_stuck(b, delta, tool_pos, tool_vel, vac_on, brushing, brush_k)
        elif st == TOSSED:
            # Vacuum can collect moving dust immediately, without waiting for it to settle.
            if vac_on and has_access(b, tool_pos) and _nearest_dist(shown[b], tool_pos) < VAC_RADIUS:
                b_state[b] = LOOSE
                b_life[b] = 0.0
                _step_loose(b, delta, tool_pos, true)
            else:
                _step_tossed(b, delta)
        else:
            _step_loose(b, delta, tool_pos, vac_on)


func _step_stuck(b: int, delta: float, tool_pos: Vector2, tool_vel: Vector2, vac_on: bool, brushing: bool, brush_k: float) -> void:
    var near: bool = (vac_on or brushing) and b_center[b].distance_to(tool_pos) <= b_radius[b] + VAC_RADIUS
    var dmin: float = INF
    var reachable: bool = near and has_access(b,tool_pos)
    if reachable:
        dmin = _nearest_dist(rest[b], tool_pos)
    var brush_distance: float = dmin
    if brushing and reachable and not brush_contacts.is_empty():
        brush_distance = INF
        for point: Vector2 in brush_contacts: brush_distance = minf(brush_distance,_nearest_dist(rest[b],point))
    if brushing and near and brush_distance < (BRUSH_TOUCH if not brush_contacts.is_empty() else BRUSH_RADIUS):
        last_brush_contacts += 1
        b_loosen[b] = maxf(LOOSEN_FLOOR, b_loosen[b] - BRUSH_LOOSEN_RATE * brush_k * delta)
        if brush_k >= FLICK_MIN_K and b_n[b] >= SHED_MIN_NODES and b_remaining[b] >= 1.5 and count < MAX_BUNDLES \
                and _rng.randf() < SHED_RATE * brush_k * delta:
            _shed(b, tool_vel)
        if b_loosen[b] <= FLICK_AT and brush_k >= FLICK_MIN_K:
            # Loosened enough: the stroke flicks the bundle through the PC.
            _toss(b, tool_vel)
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


func _step_loose(b: int, delta: float, tool_pos: Vector2, vac_on: bool) -> void:
    var nodes: PackedVector2Array = shown[b]
    var reachable: bool = vac_on and has_access(b, tool_pos) and _nearest_dist(nodes, tool_pos) < VAC_RADIUS * 1.5
    if not reachable:
        # A stopped/blocked vacuum cannot remove dust remotely or erase it on a timer.
        rest[b] = nodes.duplicate()
        _toss(b, b_vel[b])
        return
    b_life[b] += delta
    var idx: int = _nearest_index(nodes, tool_pos)
    var distance: float = nodes[idx].distance_to(tool_pos)
    b_vel[b] = b_vel[b].lerp((tool_pos - nodes[idx]).normalized() * LOOSE_SPEED, 1.0 - exp(-26.0 * delta))
    var move: Vector2 = b_vel[b] * minf(delta, distance / maxf(b_vel[b].length(), 1.0))
    var sum := Vector2.ZERO
    for i in range(nodes.size()):
        nodes[i] += move
        sum += nodes[i]
    shown[b] = nodes
    b_center[b] = sum / float(nodes.size())
    motion_changed = true
    if _nearest_dist(nodes, tool_pos) <= INTAKE_RADIUS:
        swallowed += b_remaining[b]
        _remove(b)


func take_swallowed() -> float:
    var amount: float = swallowed
    swallowed = 0.0
    return amount


# Keep a point inside its part's dust area (the area moves and turns with the part).
func confine(zone: int, p: Vector2) -> Vector2:
    var angle: float = zone_angle[zone]
    var half: Vector2 = (zone_half[zone] - Vector2(ZONE_MARGIN, ZONE_MARGIN)).max(Vector2.ZERO)
    var local: Vector2 = (p - zone_center[zone]).rotated(-angle)
    return zone_center[zone] + local.clamp(-half, half).rotated(angle)


# The brush flicks a loosened bundle: it slides along the stroke, spinning a little.
func _toss(b: int, tool_vel: Vector2) -> void:
    b_state[b] = TOSSED
    b_launch_zone[b] = b_zone[b]
    if floor_zone >= 0 and case_bounds.has_point(b_center[b]):
        _move_zone(b, floor_zone)
    motion_changed = true
    b_life[b] = 0.0
    b_pull[b] = 0.0
    b_stress[b] = 0.0
    b_vel[b] = tool_vel.limit_length(TOSS_MAX_SPEED) * TOSS_PUSH + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(10.0, 40.0)
    b_spin[b] = _rng.randf_range(-TOSS_SPIN, TOSS_SPIN)
    shown[b] = (rest[b] as PackedVector2Array).duplicate()
    kicked.append(b_center[b])


func _on_surface(zone: int, point: Vector2) -> bool:
    var local: Vector2 = (point - zone_center[zone]).rotated(-zone_angle[zone])
    return absf(local.x) <= zone_half[zone].x and absf(local.y) <= zone_half[zone].y


# Move physical mass between areas. Moving dirt is not removal and cannot improve case totals.
func _move_zone(b: int, target: int) -> void:
    var old: int = b_zone[b]
    if old == target or target < 0: return
    var amount: float = b_remaining[b]
    zone_weight[old] = maxf(zone_removed[old], zone_weight[old] - amount)
    zone_weight[target] += amount
    zone_bundles[old].erase(b)
    zone_bundles[target].append(b)
    b_zone[b] = target
    b_grip[b] = (0.55 if b_n[b] == 1 else GRIP_BASE + GRIP_PER_NODE * b_n[b]) * float(_zones[target].get("grip_scale",1.0))
    motion_changed = true


func _segment_hits(rect: Rect2, start: Vector2, finish: Vector2) -> bool:
    if rect.has_point(start) or rect.has_point(finish): return true
    var corners: Array = [rect.position, Vector2(rect.end.x,rect.position.y), rect.end, Vector2(rect.position.x,rect.end.y)]
    for i in range(4):
        if Geometry2D.segment_intersects_segment(start,finish,corners[i],corners[(i+1)%4]) != null: return true
    return false


func _settle(b: int, target: int) -> void:
    _move_zone(b,target)
    rest[b] = (shown[b] as PackedVector2Array).duplicate()
    b_state[b] = STUCK
    b_vel[b] = Vector2.ZERO
    b_spin[b] = 0.0
    b_loosen[b] = TOSS_LOOSEN
    b_pull[b] = 0.0


func _step_tossed(b: int, delta: float) -> void:
    b_life[b] += delta
    motion_changed = true
    var zone: int = b_zone[b]
    var nodes: PackedVector2Array = shown[b]
    var velocity: Vector2 = b_vel[b]
    var center: Vector2 = b_center[b]
    var bounds: Rect2 = case_bounds.grow(-ZONE_MARGIN)
    # Dust still on an extracted part stays on its service tray; it cannot teleport into the PC.
    var on_tray: bool = not case_bounds.has_point(center) and zone != floor_zone
    var moved_center: Vector2 = center + velocity * delta
    var target: int = -1
    if not on_tray:
        for blocker: Dictionary in blockers:
            var rect: Rect2 = blocker["rect"]
            var launch_id: String = str(_zones[b_launch_zone[b]]["id"])
            if launch_id == str(blocker["id"]) and rect.has_point(center): continue
            if _segment_hits(rect,center,moved_center):
                target = _zone_index("under_" + str(blocker["id"]))
                moved_center = moved_center.clamp(rect.position+Vector2.ONE*5.0,rect.end-Vector2.ONE*5.0)
                break
        if target < 0:
            var filter: int = _zone_index("front_filter")
            if filter >= 0:
                var rect := Rect2(zone_center[filter]-zone_half[filter],zone_half[filter]*2.0)
                if b_launch_zone[b] != filter and _segment_hits(rect,center,moved_center):
                    target = filter
                    moved_center = moved_center.clamp(rect.position+Vector2.ONE*2.0,rect.end-Vector2.ONE*2.0)
    var sum := Vector2.ZERO
    var bounced: bool = false
    for i in range(nodes.size()):
        var moved: Vector2 = moved_center + (nodes[i]-center).rotated(b_spin[b]*delta)
        var inside: Vector2 = confine(zone,moved) if on_tray else moved.clamp(bounds.position,bounds.end)
        if target >= 0: inside = confine(target,moved)
        if not moved.is_equal_approx(inside): bounced = true
        nodes[i] = inside
        sum += inside
    shown[b] = nodes
    b_center[b] = sum / float(maxi(1,nodes.size()))
    if target >= 0:
        _settle(b,target)
        return
    if bounced: velocity *= -0.4
    velocity *= exp(-TOSS_FRICTION*delta)
    b_vel[b] = velocity
    b_spin[b] *= exp(-TOSS_FRICTION*delta)
    if velocity.length() < TOSS_SETTLE_SPEED or b_life[b] > TOSS_MAX_TIME:
        target = zone if on_tray else floor_zone
        if not on_tray:
            for zi in range(_zones.size()):
                if zi == floor_zone or _zones[zi].has("covered_by"): continue
                if _on_surface(zi,b_center[b]):
                    target = zi
                    break
        _settle(b,target if target >= 0 else zone)


func _zone_index(id: String) -> int:
    for zi in range(_zones.size()):
        if str(_zones[zi]["id"]) == id: return zi
    return -1


# A touched chain chips its free end off as a separate speck. The weight moves with it, so the
# part's total dust (and its cleaning progress) does not change.
func _shed(b: int, tool_vel: Vector2) -> void:
    var nodes: PackedVector2Array = rest[b]
    var n: int = nodes.size()
    if n < SHED_MIN_NODES:
        return
    var end_point: Vector2 = nodes[n - 1]
    nodes.resize(n - 1)
    rest[b] = nodes
    shown[b] = nodes.duplicate()
    b_n[b] = n - 1
    b_remaining[b] = maxf(0.05, b_remaining[b] - 1.0)
    b_grip[b] = maxf(0.4, b_grip[b] - GRIP_PER_NODE)
    b_radius[b] = float(n - 1) * NODE_SPACING
    var sum := Vector2.ZERO
    for v: Vector2 in nodes:
        sum += v
    b_center[b] = sum / float(nodes.size())
    _spawn_speck(b_zone[b], end_point, tool_vel)


func _spawn_speck(zone: int, point: Vector2, tool_vel: Vector2) -> void:
    var index: int = b_zone.size()
    b_zone.append(zone)
    b_launch_zone.append(zone)
    b_n.append(1)
    b_remaining.append(1.0)
    b_state.append(TOSSED)
    b_grip.append(0.55 * _rng.randf_range(GRIP_JITTER_LOW, GRIP_JITTER_HIGH))
    b_pull.append(0.0)
    b_loosen.append(1.0)
    b_stress.append(0.0)
    b_life.append(0.0)
    b_vel.append(tool_vel.limit_length(TOSS_MAX_SPEED) * SHED_SPEED + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(20.0, 70.0))
    b_spin.append(0.0)
    b_center.append(point)
    b_radius.append(NODE_SPACING)
    var nodes := PackedVector2Array([point])
    rest.append(nodes)
    shown.append(nodes.duplicate())
    var list: Array = zone_bundles[zone]
    list.append(index)
    count = b_zone.size()
    kicked.append(point)


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
    zone_center[zone_index] = new_center + (zone_center[zone_index] - old_center).rotated(angle_delta)
    zone_angle[zone_index] += angle_delta
    for b in zone_bundles[zone_index]:
        if b_state[b] == TOSSED: continue
        var r: PackedVector2Array = rest[b].duplicate()
        var s: PackedVector2Array = shown[b].duplicate()
        for i in range(r.size()): r[i] = new_center+(r[i]-old_center).rotated(angle_delta)
        for i in range(s.size()): s[i] = new_center+(s[i]-old_center).rotated(angle_delta)
        rest[b] = r
        shown[b] = s
        b_center[b] = new_center+(b_center[b]-old_center).rotated(angle_delta)
