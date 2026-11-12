# Presentation-only critically damped following, lift, sway and quarter-turn rotation.
# Logical placement never depends on these visual positions.
extends RefCounted
var center := Vector2.ZERO
var velocity := Vector2.ZERO
var angle: float = 0.0
var lift: float = 0.0
var initialized: bool = false

func snap(point: Vector2, rotation: int) -> void:
    center = point
    velocity = Vector2.ZERO
    angle = rotation * PI / 2.0
    initialized = true

func step(delta: float, target: Vector2, rotation: int, held: bool, turn: float = 0.0) -> void:
    if not initialized: snap(target, rotation)
    var dt: float = minf(delta, 0.05)
    var frequency: float = 30.0 if held else 23.0
    var offset: Vector2 = center - target
    var impulse: Vector2 = (velocity + frequency * offset) * dt
    var decay: float = exp(-frequency * dt)
    center = target + (offset + impulse) * decay
    velocity = (velocity - frequency * impulse) * decay
    lift = lerpf(lift, 1.0 if held else 0.0, 1.0 - exp(-20.0 * dt))
    var sway: float = clampf(-velocity.x * 0.00012, -0.065, 0.065) if held else 0.0
    angle = lerp_angle(angle, rotation * PI / 2.0 + turn + sway, 1.0 - exp(-22.0 * dt))
