# Flexible bristle tips. Contact points drive loosening, not just decoration.
extends RefCounted
const COUNT: int = 13
var bend := Vector2.ZERO
var bend_velocity := Vector2.ZERO
var compression: float = 0.0

func step(delta: float, surface_velocity: Vector2, contact: bool) -> void:
    var dt: float = minf(maxf(delta,0.0),0.05)
    var target: Vector2 = -surface_velocity.limit_length(1200.0)*0.017 if contact else Vector2.ZERO
    var offset: Vector2 = bend-target
    var impulse: Vector2 = (bend_velocity+22.0*offset)*dt
    var decay: float = exp(-22.0*dt)
    bend = target+(offset+impulse)*decay
    bend_velocity = (bend_velocity-22.0*impulse)*decay
    compression = lerpf(compression,1.0 if contact else 0.0,1.0-exp(-18.0*dt))

func roots() -> PackedVector2Array:
    var out := PackedVector2Array()
    for i in range(COUNT): out.append(Vector2((i-6)*2.7,-12))
    return out

func tips() -> PackedVector2Array:
    var out := PackedVector2Array()
    for i in range(COUNT):
        var spread: float = (i-6)*2.7*(1.0+compression*0.25)
        out.append(Vector2(spread,5.0-compression*4.0)+bend*(0.7+0.3*sin(float(i)*1.7)))
    return out
