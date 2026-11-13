# Save/restore physical dust. Validate the entire snapshot before changing a live simulation.
# Old saves without snapshots still restore their fractional cleaning progress.
extends RefCounted

static func capture(dust: RefCounted) -> Dictionary:
    var records: Array = []
    for b in range(dust.count):
        var nodes: Array = []
        for point: Vector2 in dust.shown[b]: nodes.append([point.x,point.y])
        records.append({"zone":int(dust.b_zone[b]),"launch":int(dust.b_launch_zone[b]),
            "state":int(dust.b_state[b]),"remaining":float(dust.b_remaining[b]),
            "loosen":float(dust.b_loosen[b]),"grip":float(dust.b_grip[b]),
            "velocity":[dust.b_vel[b].x,dust.b_vel[b].y],"nodes":nodes})
    return {"version":1,"case":[dust.case_bounds.position.x,dust.case_bounds.position.y,dust.case_bounds.size.x,dust.case_bounds.size.y],
        "records":records,"weights":Array(dust.zone_weight),"removed":Array(dust.zone_removed)}


static func _number(value: Variant) -> bool:
    return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value))


static func _vector(value: Variant) -> bool:
    return value is Array and value.size() == 2 and _number(value[0]) and _number(value[1])


static func restore(dust: RefCounted, saved: Dictionary) -> bool:
    if saved.get("version") != 1: return false
    var geometry: Variant = saved.get("case")
    if not geometry is Array or geometry.size() != 4: return false
    for value: Variant in geometry:
        if not _number(value): return false
    var saved_case := Rect2(float(geometry[0]),float(geometry[1]),float(geometry[2]),float(geometry[3]))
    if not dust.case_bounds.is_equal_approx(saved_case): return false
    var records: Variant = saved.get("records")
    var weights: Variant = saved.get("weights")
    var removed: Variant = saved.get("removed")
    var zones: int = dust.zone_count()
    if not records is Array or records.is_empty() or records.size() > dust.MAX_BUNDLES: return false
    if not weights is Array or not removed is Array or weights.size() != zones or removed.size() != zones: return false
    var total: float = 0.0
    var expected: float = 0.0
    var mass: Array = []
    mass.resize(zones)
    mass.fill(0.0)
    for zi in range(zones):
        if not _number(weights[zi]) or not _number(removed[zi]): return false
        if float(removed[zi]) < 0.0 or float(weights[zi]) < float(removed[zi]): return false
        total += float(weights[zi])
        expected += dust.zone_weight[zi]
    if absf(total-expected) > 0.02: return false
    var allowed: Rect2 = dust.case_bounds
    for zi in range(zones):
        allowed = allowed.merge(Rect2(dust.zone_center[zi]-dust.zone_half[zi]*2.0,dust.zone_half[zi]*4.0))
    allowed = allowed.grow(20.0)
    for item: Variant in records:
        if not item is Dictionary: return false
        for key: String in ["zone","launch","state"]:
            if not _number(item.get(key)) or float(item[key]) != floor(float(item[key])): return false
        var zi: int = int(item["zone"])
        if zi < 0 or zi >= zones or int(item["launch"]) < 0 or int(item["launch"]) >= zones: return false
        if not int(item["state"]) in [dust.STUCK,dust.LOOSE,dust.GONE,dust.TOSSED]: return false
        var nodes: Variant = item.get("nodes")
        if not nodes is Array or nodes.is_empty() or nodes.size() > dust.MIN_NODES+dust.EXTRA_NODES: return false
        for key: String in ["remaining","loosen","grip"]:
            if not _number(item.get(key)): return false
        var left: float = float(item["remaining"])
        if left < 0.0 or left > float(nodes.size())+0.001: return false
        if (int(item["state"]) == dust.GONE) != (left <= 0.0): return false
        if float(item["loosen"]) < dust.LOOSEN_FLOOR-0.0001 or float(item["loosen"]) > 1.001: return false
        if float(item["grip"]) <= 0.0 or float(item["grip"]) > 100.0: return false
        if not _vector(item.get("velocity")): return false
        for xy: Variant in nodes:
            if not _vector(xy) or not allowed.has_point(Vector2(float(xy[0]),float(xy[1]))): return false
        mass[zi] += left
    for zi in range(zones):
        if absf(float(mass[zi])+float(removed[zi])-float(weights[zi])) > 0.02: return false
    # Commit only after every record passes; a bad snapshot leaves fractional recovery intact.
    dust.zone_weight = PackedFloat32Array(weights)
    dust.zone_removed = PackedFloat32Array(removed)
    dust.zone_bundles = []
    for zi in range(zones): dust.zone_bundles.append([])
    dust.b_zone = PackedInt32Array()
    dust.b_launch_zone = PackedInt32Array()
    dust.b_n = PackedInt32Array()
    dust.b_state = PackedInt32Array()
    dust.b_remaining = PackedFloat64Array()
    dust.b_grip = PackedFloat32Array()
    dust.b_pull = PackedFloat32Array()
    dust.b_loosen = PackedFloat32Array()
    dust.b_stress = PackedFloat32Array()
    dust.b_life = PackedFloat32Array()
    dust.b_vel = PackedVector2Array()
    dust.b_spin = PackedFloat32Array()
    dust.b_center = PackedVector2Array()
    dust.b_radius = PackedFloat32Array()
    dust.rest = []
    dust.shown = []
    for item: Dictionary in records:
        var b: int = dust.b_zone.size()
        var nodes := PackedVector2Array()
        var center := Vector2.ZERO
        for xy: Array in item["nodes"]:
            var point := Vector2(float(xy[0]),float(xy[1]))
            nodes.append(point)
            center += point
        var zi: int = int(item["zone"])
        dust.b_zone.append(zi)
        dust.b_launch_zone.append(int(item["launch"]))
        dust.zone_bundles[zi].append(b)
        dust.b_n.append(nodes.size())
        dust.b_state.append(int(item["state"]))
        dust.b_remaining.append(float(item["remaining"]))
        dust.b_grip.append(float(item["grip"]))
        dust.b_pull.append(0.0)
        dust.b_loosen.append(float(item["loosen"]))
        dust.b_stress.append(0.0)
        dust.b_life.append(0.0)
        dust.b_vel.append(Vector2(float(item["velocity"][0]),float(item["velocity"][1])).limit_length(dust.TOSS_MAX_SPEED))
        dust.b_spin.append(0.0)
        dust.b_center.append(center/float(nodes.size()))
        dust.b_radius.append(nodes.size()*dust.NODE_SPACING)
        dust.rest.append(nodes.duplicate())
        dust.shown.append(nodes)
    dust.count = records.size()
    dust.vac_ramp = 0.0
    dust.brush_contacts.clear()
    dust.swallowed = 0.0
    return true
