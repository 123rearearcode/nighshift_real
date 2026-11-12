# PHYSICS ONLY: collisions between pieces lying on the bench (tools and loose parts). Pieces are
# rotated boxes. A pure function: the caller builds one Dictionary per piece, calls resolve(),
# then copies the results back to its own objects. No drawing, no input, no scene access.
#
# A piece Dictionary has these keys (all required):
#   center: Vector2, angle: float, half: Vector2        the box
#   velocity: Vector2, spin: float                       motion (px/s, radians/s)
#   inv_mass: float                                      1 / mass; 0 = held or fixed: it pushes others and is never pushed
#   solid: bool                                          false while flying through the air (it passes over others)
#   touched: bool                                        set to true here when the piece was moved or struck
extends RefCounted

const RESTITUTION: float = 0.12       # bounce (low: tools are dull, they knock rather than ricochet)
const SLOP: float = 0.4               # overlaps smaller than this px are ignored (stops resting jitter)
const SPIN_FROM_SLIDING: float = 0.0015
const MAX_SPEED: float = 1800.0
const MAX_SPIN: float = 4.0
const MAX_SHOVE_SPEED: float = 200.0  # px/s; a piece shoved by a HELD piece never moves faster than this (it is nudged, not batted)
const ITERATIONS: int = 3


static func _radius(piece: Dictionary, axis: Vector2) -> float:
    var half: Vector2 = piece["half"]
    var angle: float = piece["angle"]
    return absf(axis.dot(Vector2.from_angle(angle))) * half.x + absf(axis.dot(Vector2.from_angle(angle + PI * 0.5))) * half.y


# Do two boxes overlap? Returns {} when apart, else {depth, normal} with the normal pointing from a to b.
static func overlap(a: Dictionary, b: Dictionary) -> Dictionary:
    var angle_a: float = a["angle"]
    var angle_b: float = b["angle"]
    var axes: Array = [Vector2.from_angle(angle_a), Vector2.from_angle(angle_a + PI * 0.5),
        Vector2.from_angle(angle_b), Vector2.from_angle(angle_b + PI * 0.5)]
    var between: Vector2 = b["center"] - a["center"]
    var best_depth: float = INF
    var best_axis := Vector2.ZERO
    for axis: Vector2 in axes:
        var along: float = between.dot(axis)
        var depth: float = _radius(a, axis) + _radius(b, axis) - absf(along)
        if depth <= 0.0:
            return {}
        if depth < best_depth:
            best_depth = depth
            best_axis = axis if along >= 0.0 else -axis
    return {"depth": best_depth, "normal": best_axis}


# Push overlapping pieces apart and give them bounce and a little spin. Returns the number of contacts.
static func resolve(pieces: Array) -> int:
    var contacts: int = 0
    for pass_index in range(ITERATIONS):
        for i in range(pieces.size()):
            for j in range(i + 1, pieces.size()):
                var a: Dictionary = pieces[i]
                var b: Dictionary = pieces[j]
                if not bool(a["solid"]) or not bool(b["solid"]):
                    continue
                var inv_a: float = a["inv_mass"]
                var inv_b: float = b["inv_mass"]
                var total: float = inv_a + inv_b
                if total <= 0.0:
                    continue
                var hit: Dictionary = overlap(a, b)
                if hit.is_empty() or float(hit["depth"]) <= SLOP:
                    continue
                contacts += 1
                var normal: Vector2 = hit["normal"]
                var depth: float = float(hit["depth"]) + 0.05   # a hair extra, so they end up clearly apart
                a["center"] -= normal * depth * (inv_a / total)
                b["center"] += normal * depth * (inv_b / total)
                if inv_a > 0.0:
                    a["touched"] = true
                if inv_b > 0.0:
                    b["touched"] = true
                var relative: Vector2 = b["velocity"] - a["velocity"]
                var closing: float = relative.dot(normal)
                if closing < 0.0:
                    var impulse: float = -(1.0 + RESTITUTION) * closing / total
                    a["velocity"] = (a["velocity"] - normal * impulse * inv_a).limit_length(MAX_SPEED)
                    b["velocity"] = (b["velocity"] + normal * impulse * inv_b).limit_length(MAX_SPEED)
                    if inv_a <= 0.0:
                        b["velocity"] = Vector2(b["velocity"]).limit_length(MAX_SHOVE_SPEED)
                    if inv_b <= 0.0:
                        a["velocity"] = Vector2(a["velocity"]).limit_length(MAX_SHOVE_SPEED)
                    var sliding: float = relative.dot(normal.orthogonal())
                    if inv_a <= 0.0 or inv_b <= 0.0:
                        sliding = clampf(sliding, -MAX_SHOVE_SPEED, MAX_SHOVE_SPEED)
                    a["spin"] = clampf(float(a["spin"]) - sliding * SPIN_FROM_SLIDING * inv_a, -MAX_SPIN, MAX_SPIN)
                    b["spin"] = clampf(float(b["spin"]) + sliding * SPIN_FROM_SLIDING * inv_b, -MAX_SPIN, MAX_SPIN)
    return contacts
