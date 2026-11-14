# Scene-owned physics world; item dictionaries retain identity, never own Node references.
extends Node2D
const Body = preload("res://scripts/salvage/salvage_body.gd")
const Pile = preload("res://scripts/salvage/salvage_pile.gd")
var bodies: Dictionary = {}
var bound_pile: RefCounted
var active_session: RefCounted
var terrain: Node2D
var last_held: String = ""
var pending_uid: String = ""
var pending_local := Vector2.ZERO
var angular_offset: float = 0.0
var previous_grip_position := Vector2.ZERO
var is_paused: bool = false
var paused_velocities: Dictionary = {}

func _ready() -> void:
    terrain = Node2D.new()
    add_child(terrain)
    # Shared floor catches pieces on the sorting side; dumpster rim must be cleared to leave.
    wall(Rect2(24,622,842,18))
    wall(Rect2(24,140,12,482))
    wall(Rect2(854,140,12,482))
    wall(Rect2(24,130,842,10))
    wall(Rect2(36,350,12,272))
    wall(Rect2(624,350,12,272))
    # D108 (user playtest): the find you HOLD must be lifted over the rim, but it must not be
    # usable as a bulldozer that shoves OTHER finds out of the dumpster for free. This barrier
    # continues the right rim up to the ceiling on layer 256; every body collides with it except
    # the held one (sync drops its barrier bit), so only a carried find can cross the rim.
    barrier(Rect2(624,140,12,210))

func barrier(rect: Rect2) -> void:
    var solid := StaticBody2D.new()
    solid.position = rect.get_center()
    solid.collision_layer = 256
    solid.collision_mask = 0
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    var collider := CollisionShape2D.new()
    collider.shape = shape
    solid.add_child(collider)
    terrain.add_child(solid)

func wall(rect: Rect2) -> void:
    var solid := StaticBody2D.new()
    solid.position = rect.get_center()
    solid.collision_layer = 128
    solid.collision_mask = 128
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    var collider := CollisionShape2D.new()
    collider.shape = shape
    solid.add_child(collider)
    terrain.add_child(solid)

func clear_bodies() -> void:
    for uid: String in bodies: _remove(uid)
    bodies.clear()
    bound_pile = null
    active_session = null
    last_held = ""
    pending_uid = ""
    is_paused = false
    paused_velocities.clear()

func _remove(uid: String) -> void:
    var body: RigidBody2D = bodies[uid]
    remove_child(body)
    body.queue_free()

func capture() -> void:
    if bound_pile == null: return
    for uid: String in bodies:
        var item: Dictionary = _item(uid)
        if item.is_empty(): continue
        var body: RigidBody2D = bodies[uid]
        item["center"] = body.position
        item["angle"] = body.rotation
        item["velocity"] = body.linear_velocity
        item["spin"] = body.angular_velocity
        if active_session == null or active_session.held != uid:
            item["rotation"] = posmod(roundi(body.rotation/(PI/2)),4)
        if item["zone"] != "cargo":
            item["zone"] = "sort" if body.position.x > 640 else "pile"

func _item(uid: String) -> Dictionary:
    if active_session != null:
        var item: Dictionary = active_session.find(uid)
        if not item.is_empty(): return item
    if bound_pile != null: return bound_pile.objects.get(uid,{})
    return {}

func remember_grab(uid: String, at: Vector2) -> void:
    pending_uid = uid
    pending_local = bodies[uid].to_local(at) if bodies.has(uid) else Vector2.ZERO

func sync(session: RefCounted, pointer: Vector2) -> void:
    if session.site == "":
        if bound_pile != null: clear_bodies()
        return
    session.physics_mode = true
    if bound_pile != session.pile:
        clear_bodies()
        bound_pile = session.pile
    active_session = session
    var wanted: Dictionary = {}
    for uid: String in bound_pile.order:
        if bound_pile.objects[uid]["zone"] in ["pile","sort"]: wanted[uid] = bound_pile.objects[uid]
    if session.held != "": wanted[session.held] = session.find(session.held)
    for uid: String in bodies.keys():
        if not wanted.has(uid):
            _remove(uid)
            bodies.erase(uid)
    for uid: String in wanted:
        var item: Dictionary = wanted[uid]
        if not bodies.has(uid):
            var body := Body.new()
            body.set_meta("salvage_uid",uid)
            body.configure(item)
            body.position = Vector2(780,220) if item["zone"] == "cargo" else Vector2(item["center"])
            body.rotation = float(item["rotation"])*PI/2 if item["zone"] == "cargo" else float(item["angle"])
            body.linear_velocity = item["velocity"]
            body.angular_velocity = float(item["spin"])
            body.body_entered.connect(func(_other: Node) -> void:
                if bound_pile != null: bound_pile.impacts += 1)
            add_child(body)
            bodies[uid] = body
        else: bodies[uid].configure(item)
    for uid: String in bodies:
        var body: RigidBody2D = bodies[uid]
        var held: bool = uid == session.held
        body.gripped = held
        body.can_sleep = not held
        body.collision_mask = 128 if held else 384   # only the carried find may pass the rim barrier (D108)
        if held:
            if last_held != uid:
                body.grip_local = pending_local if pending_uid == uid else Vector2.ZERO
                # Prevent a stale pointer selecting a grip far outside the actual shape.
                body.grip_local = body.grip_local.clamp(-Vector2(wanted[uid]["size"])*0.5,Vector2(wanted[uid]["size"])*0.5)
                angular_offset = body.rotation-float(session.rotation)*PI/2
                previous_grip_position = body.position
                body.sleeping = false
            else:
                var distance: float = body.position.distance_to(previous_grip_position)
                session.charge_motion(distance)
                if session.held != uid:
                    body.gripped = false
                    body.can_sleep = true
                    continue
                previous_grip_position = body.position
            body.target = Vector2(clampf(pointer.x,52,800),clampf(pointer.y,156,600))
            body.target_angle = angular_offset+float(session.rotation)*PI/2
    # Exhausted search time can cancel a cargo grip inside charge_motion above.
    # Remove that transient body before the next capture overwrites committed cargo poses.
    if last_held != "" and session.held != last_held and bodies.has(last_held):
        var released: Dictionary = _item(last_held)
        if released.get("zone","") == "cargo":
            _remove(last_held)
            bodies.erase(last_held)
    last_held = session.held
    _pause(session.paused)

func _pause(value: bool) -> void:
    if value == is_paused: return
    is_paused = value
    for uid: String in bodies:
        var body: RigidBody2D = bodies[uid]
        if value:
            paused_velocities[uid] = [body.linear_velocity,body.angular_velocity]
            body.freeze = true
        else:
            body.freeze = false
            if paused_velocities.has(uid):
                body.linear_velocity = paused_velocities[uid][0]
                body.angular_velocity = paused_velocities[uid][1]
    if not value: paused_velocities.clear()

func at(point: Vector2) -> String:
    if not is_inside_tree() or bound_pile == null: return ""
    var query := PhysicsPointQueryParameters2D.new()
    query.position = point
    query.collision_mask = 128
    var hits: Dictionary = {}
    for result: Dictionary in get_world_2d().direct_space_state.intersect_point(query,32):
        var uid: String = str(result["collider"].get_meta("salvage_uid",""))
        if uid != "": hits[uid] = true
    for i in range(bound_pile.order.size()-1,-1,-1):
        if hits.has(bound_pile.order[i]): return bound_pile.order[i]
    return ""
