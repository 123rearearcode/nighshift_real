# Native rigid body. Mouse grip applies bounded forces inside the physics integrator.
extends RigidBody2D
const STIFFNESS: float = 180.0
const MAX_FORCE: float = 9500.0
var gripped: bool = false
var grip_local := Vector2.ZERO
var target := Vector2.ZERO
var target_angle: float = 0.0
var signature: String = ""

func configure(item: Dictionary) -> void:
    var key: String = str([item["kind"],item["size"],item["opened"]])
    if signature == key: return
    signature = key
    mass = float(item["mass"])
    collision_layer = 128
    collision_mask = 128
    continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE if item["kind"] in ["ram","gpu","drive"] or item["opened"] else RigidBody2D.CCD_MODE_DISABLED
    linear_damp = 0.65
    angular_damp = 1.5
    can_sleep = true
    max_contacts_reported = 4
    contact_monitor = true
    var material := PhysicsMaterial.new()
    material.friction = 0.65
    material.bounce = 0.035
    physics_material_override = material
    for child: Node in get_children():
        remove_child(child)
        child.queue_free()
    var size: Vector2 = item["size"]
    if bool(item["opened"]) and item["kind"] in ["box","pc"]:
        _rectangle(Vector2(size.x,6),Vector2(0,size.y*0.5-3))
        _rectangle(Vector2(6,size.y),Vector2(-size.x*0.5+3,0))
        _rectangle(Vector2(6,size.y),Vector2(size.x*0.5-3,0))
    elif item["kind"] == "bag" and not item["opened"]:
        _rectangle(size*Vector2(0.88,0.90),Vector2.ZERO)
    else: _rectangle(size,Vector2.ZERO)

func _rectangle(size: Vector2, at: Vector2) -> void:
    var shape := RectangleShape2D.new()
    shape.size = size
    var collider := CollisionShape2D.new()
    collider.shape = shape
    collider.position = at
    add_child(collider)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    if not gripped: return
    var offset: Vector2 = state.transform.basis_xform(grip_local)
    var point: Vector2 = state.transform.origin+offset
    var velocity: Vector2 = state.linear_velocity+Vector2(-offset.y,offset.x)*state.angular_velocity
    var force: Vector2 = ((target-point)*STIFFNESS-velocity*25.0*sqrt(mass)).limit_length(MAX_FORCE)
    state.apply_force(force,offset)
    var turn: float = angle_difference(state.transform.get_rotation(),target_angle)
    state.apply_torque(clampf(turn*850.0-state.angular_velocity*110.0,-1800,1800)*mass)
    # Safety caps bound rare violent contacts without moving bodies through their neighbours.
    state.linear_velocity = state.linear_velocity.limit_length(1100)
    state.angular_velocity = clampf(state.angular_velocity,-6,6)
