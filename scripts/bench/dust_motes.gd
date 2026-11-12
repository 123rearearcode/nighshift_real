# PHYSICS (cosmetic only): tiny dust motes that float in the air. They drift above dusty spots,
# burst up when the brush kicks dust, and the vacuum draws them in. They are never counted
# anywhere: cleaning progress, the dust bin and saves do not know they exist. No drawing, no input.
extends RefCounted

const DustSim = preload("res://scripts/bench/dust_sim.gd")

const MAX_MOTES: int = 140
const AMBIENT_RATE: float = 6.0       # new motes per second while the PC is completely dusty
const DRAG: float = 1.8               # speed lost per second
const DRIFT: float = 26.0             # strength of the lazy wandering
const SUCTION_RANGE: float = 90.0
const SUCTION_PULL: float = 900.0
const SWALLOW_RADIUS: float = 12.0

var pos := PackedVector2Array()
var vel := PackedVector2Array()
var age := PackedFloat32Array()
var life := PackedFloat32Array()
var size := PackedFloat32Array()
var _rng := RandomNumberGenerator.new()
var _time: float = 0.0
var _ambient: float = 0.0


func _init(seed_value: int = 4242) -> void:
    _rng.seed = seed_value


func count() -> int:
    return pos.size()


func spawn(point: Vector2, velocity: Vector2, amount: int = 1, spread: float = 40.0) -> void:
    for k in range(amount):
        if pos.size() >= MAX_MOTES:
            return
        pos.append(point + Vector2(_rng.randf_range(-4.0, 4.0), _rng.randf_range(-4.0, 4.0)))
        vel.append(velocity + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(0.2, 1.0) * spread)
        age.append(0.0)
        life.append(_rng.randf_range(1.6, 3.6))
        size.append(_rng.randf_range(0.9, 1.9))


func _kill(i: int) -> void:
    var last: int = pos.size() - 1
    pos[i] = pos[last]
    vel[i] = vel[last]
    age[i] = age[last]
    life[i] = life[last]
    size[i] = size[last]
    pos.resize(last)
    vel.resize(last)
    age.resize(last)
    life.resize(last)
    size.resize(last)


# `dust` is the dust simulation (only read). `suction` is the vacuum strength 0..1 at `nozzle`.
func step(delta: float, dust: DustSim, nozzle: Vector2, suction: float) -> void:
    _time += delta
    _ambient += AMBIENT_RATE * dust.remaining_fraction() * delta
    while _ambient >= 1.0:
        _ambient -= 1.0
        for attempt in range(6):
            var b: int = _rng.randi_range(0, maxi(0, dust.count - 1))
            if dust.count > 0 and dust.b_state[b] == DustSim.STUCK and not dust.is_hidden(b):
                var nodes: PackedVector2Array = dust.shown[b]
                spawn(nodes[_rng.randi_range(0, nodes.size() - 1)], Vector2.ZERO, 1, 14.0)
                break
    var i: int = pos.size() - 1
    while i >= 0:
        age[i] += delta
        var swallowed: bool = false
        if age[i] >= life[i]:
            _kill(i)
        else:
            var wander: Vector2 = Vector2(sin(_time * 1.3 + float(i) * 2.1), cos(_time * 1.7 + float(i) * 1.3))
            vel[i] += wander * DRIFT * delta
            if suction > 0.0:
                var to_nozzle: Vector2 = nozzle - pos[i]
                var distance: float = to_nozzle.length()
                if distance < SWALLOW_RADIUS:
                    swallowed = true
                elif distance < SUCTION_RANGE:
                    vel[i] += to_nozzle / distance * SUCTION_PULL * suction * (1.0 - distance / SUCTION_RANGE) * delta
            vel[i] *= exp(-DRAG * delta)
            pos[i] += vel[i] * delta
            if swallowed:
                _kill(i)
        i -= 1
