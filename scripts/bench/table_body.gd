# Shared tabletop dynamics. Surface position + independent vertical hop; no input/drawing.
extends RefCounted
const RESTITUTION: float = 0.60
const FLOOR_BOUNCE: float = 0.33
const GRAVITY: float = 950.0
var center := Vector2.ZERO
var velocity := Vector2.ZERO
var half_size := Vector2(15,15)
var angle: float = 0.0
var angular_velocity: float = 0.0
var height: float = 0.0
var vertical_velocity: float = 0.0
var impacts: int = 0
var active: bool = false

func launch(point: Vector2, speed: Vector2, half: Vector2, rotation: float = 0.0) -> void:
    center = point
    velocity = speed.limit_length(1800.0)
    half_size = half
    angle = rotation
    angular_velocity = clampf(speed.x*0.006-speed.y*0.002,-7.0,7.0)
    height = 5.0
    vertical_velocity = clampf(speed.length()*0.17,85.0,280.0)
    impacts = 0
    active = true

func extent() -> Vector2:
    return Vector2(absf(cos(angle))*half_size.x+absf(sin(angle))*half_size.y,
        absf(sin(angle))*half_size.x+absf(cos(angle))*half_size.y)

func step(delta: float, bounds: Rect2) -> void:
    if not active: return
    var left: float = minf(maxf(delta,0.0),0.25)
    while left > 0.000001:
        var dt: float = minf(left,1.0/120.0)
        left -= dt
        var old_angle: float = angle
        angle += angular_velocity*dt
        var turning_extent: Vector2 = extent()
        if turning_extent.x*2 > bounds.size.x or turning_extent.y*2 > bounds.size.y:
            angle = old_angle
            angular_velocity *= -0.60
            impacts += 1
        center += velocity*dt
        var edge: Vector2 = extent()
        for axis in range(2):
            var lo: float = bounds.position[axis]+edge[axis]
            var hi: float = bounds.end[axis]-edge[axis]
            if lo > hi:
                center[axis] = bounds.get_center()[axis]
                velocity[axis] = 0.0
            elif center[axis] < lo or center[axis] > hi:
                var hit_low: bool = center[axis] < lo
                center[axis] = clampf(center[axis],lo,hi)
                if (hit_low and velocity[axis] < 0) or (not hit_low and velocity[axis] > 0):
                    velocity[axis] *= -RESTITUTION
                    angular_velocity *= -0.72
                    impacts += 1
        vertical_velocity -= GRAVITY*dt
        height += vertical_velocity*dt
        if height < 0:
            height = 0.0
            if vertical_velocity < -45:
                vertical_velocity *= -FLOOR_BOUNCE
                impacts += 1
                velocity *= 0.84
            else: vertical_velocity = 0.0
        velocity *= exp(-(0.7 if height > 0.1 else 3.8)*dt)
        angular_velocity *= exp(-2.7*dt)
    if height == 0 and velocity.length() < 5.0 and absf(vertical_velocity) < 1.0:
        velocity = Vector2.ZERO
        angular_velocity = 0.0
        active = false
