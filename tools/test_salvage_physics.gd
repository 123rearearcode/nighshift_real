# Real PhysicsServer2D ticks, native collisions/grip/containers and isolated menu input.
extends "res://tools/test_support.gd"
const Session = preload("res://scripts/salvage/salvage_session.gd")
const World = preload("res://scripts/salvage/salvage_physics.gd")
const Pile = preload("res://scripts/salvage/salvage_pile.gd")
const RIM_GRACE_ZONE := Rect2(624,140,12,210)
var pointer := Vector2.ZERO

func _initialize() -> void: call_deferred("run")

func blank() -> RefCounted:
    var s := Session.new()
    s.depart("mixed")
    s.pile.objects.clear()
    s.pile.order.clear()
    return s

func add(s: RefCounted, uid: String, kind: String, at: Vector2, size: Vector2, parent: String = "") -> void:
    var rng := RandomNumberGenerator.new()
    s.pile.add(kind,at,size,uid,rng,parent)

func ticks(world: Node, s: RefCounted, count: int, at: Vector2 = Vector2.ZERO) -> void:
    for i in range(count):
        await physics_frame
        world.capture()
        s.step(1.0/60.0,at)
        world.sync(s,at)

func run() -> void:
    Engine.max_fps = 120
    await test_stack_and_grip()
    await test_rim_barrier()
    await test_rim_release_and_cargo_spawn()
    await test_containers_and_cargo()
    await test_scene()
    Session.demo = null
    finish("Salvage physics")

func test_stack_and_grip() -> void:
    var s: RefCounted = blank()
    add(s,"support","box",Vector2(230,570),Vector2(108,60))
    add(s,"upper","box",Vector2(230,470),Vector2(76,60))
    var w := World.new()
    root.add_child(w)
    w.sync(s,pointer)
    await ticks(w,s,150)
    var lower: RigidBody2D = w.bodies["support"]
    var upper: RigidBody2D = w.bodies["upper"]
    check(upper.position.y>500,"unsupported object falls under native gravity")
    check(upper.position.y+29 <= lower.position.y-28,"upper box rests on lower box without passing through")
    check(lower.position.y+30 < 624,"solid floor contains falling bodies")
    check(lower.sleeping and upper.sleeping,"settled stack enters native sleep")
    var upper_before: float = upper.position.y
    var grip_start: Vector2 = lower.position
    check(s.start_effort("support","grab"),"physical support can be gripped without an artificial overlay gate")
    w.remember_grab("support",grip_start)
    await ticks(w,s,100,Vector2(480,580))
    check(lower.position.x>360,"bounded mouse spring actually pulls the support sideways")
    check(upper.position.y>upper_before+25,"removing support makes the upper object collapse into the gap")
    var pose: Vector2 = lower.position
    s.cancel_hand()
    w.sync(s,pointer)
    await ticks(w,s,20)
    check(lower.position.x>340 and lower.position.distance_to(pose)<80,"physical cancellation releases in place instead of teleporting under the pile")
    s.paused = true
    w.sync(s,pointer)
    var paused_at: Vector2 = upper.position
    var budget: float = s.remaining
    await ticks(w,s,20)
    check(upper.position == paused_at and s.remaining == budget,"pause freezes native bodies and action time")
    s.paused = false
    w.sync(s,pointer)
    # A buried target still cannot be magically packed by dropping its pointer on the grid.
    check(s.start_effort("upper","grab"),"begin second native grip")
    await ticks(w,s,45,upper.position)
    check(not s.drop_cargo(Vector2i.ZERO) and not s.cargo[s.car].has("upper"),"trunk claim requires physical extraction over the rim")
    w.sync(s,pointer)
    w.free()
    await physics_frame

# D108 (0.28.0, user playtest): a held find must not work as a bulldozer. Only the body you are
# actually carrying may cross the rim; everything else is stopped by the rim barrier.
func test_rim_barrier() -> void:
    var s: RefCounted = blank()
    add(s,"loose","box",Vector2(560,250),Vector2(60,60))
    var w := World.new()
    root.add_child(w)
    w.sync(s,pointer)
    check(w.bodies["loose"].collision_mask == 384,"an idle find collides with the rim barrier")
    w.bodies["loose"].linear_velocity = Vector2(900,-30)
    var escaped: bool = false
    for i in range(150):
        await physics_frame
        w.capture()
        s.step(1.0/60.0,pointer)
        w.sync(s,pointer)
        if w.bodies["loose"].position.x > 632: escaped = true
    check(not escaped,"a find that is not held cannot be knocked out of the dumpster (D108)")
    check(s.start_effort("loose","grab"),"the same find can still be gripped")
    w.remember_grab("loose",w.bodies["loose"].position)
    await ticks(w,s,50)
    check(s.held == "loose" and w.bodies["loose"].collision_mask == 128,"the carried find alone ignores the rim barrier")
    await ticks(w,s,300,Vector2(760,260))
    check(w.bodies["loose"].position.x > 640,"the carried find is lifted over the rim as before")
    w.free()
    await physics_frame

# 0.29.0, from Codex's qualifications on the D108 fix: releasing a find while it overlaps the
# barrier must not fling it (the grace keeps it exempt until clear), and a cargo body must not
# materialise inside a staged find (free-space spawn probe).
func test_rim_release_and_cargo_spawn() -> void:
    var s: RefCounted = blank()
    add(s,"carried","box",Vector2(400,520),Vector2(60,60))
    var w := World.new()
    root.add_child(w)
    w.sync(s,pointer)
    await ticks(w,s,30)
    check(s.start_effort("carried","grab"),"grip the find to carry it to the rim")
    w.remember_grab("carried",w.bodies["carried"].position)
    await ticks(w,s,50)
    await ticks(w,s,200,Vector2(630,250))   # hold it right in the barrier column
    var at_rim: Vector2 = w.bodies["carried"].position
    s.cancel_hand()
    w.sync(s,pointer)
    var calm: bool = true
    for i in range(90):
        await physics_frame
        w.capture()
        s.step(1.0/60.0,pointer)
        w.sync(s,pointer)
        if w.bodies.has("carried") and w.bodies["carried"].linear_velocity.length() > 900.0: calm = false
    check(calm,"release inside the barrier column never flings the find (grace until clear)")
    check(w.bodies["carried"].position.distance_to(at_rim) < 420.0,"the released find settles nearby instead of teleporting")
    if not RIM_GRACE_ZONE.grow(34.0).has_point(w.bodies["carried"].position):
        check(w.bodies["carried"].collision_mask == 384,"the exemption ends once the find is clear of the rim")
    # Cargo re-entry: the old fixed spawn point is occupied by a staged find.
    add(s,"staged","box",Vector2(780,200),Vector2(60,60))
    s.pile.objects["staged"]["zone"] = "sort"
    add(s,"packed","gpu",Vector2(760,560),Vector2(78,26))
    var item: Dictionary = s.pile.objects["packed"]
    s.pile.objects.erase("packed")
    s.pile.order.erase("packed")
    item["zone"] = "cargo"
    s.cargo[s.car]["packed"] = item
    s.grids[s.car].place("packed","gpu",Vector2i(0,0),0)
    w.sync(s,pointer)
    await ticks(w,s,40)
    var staged_at: Vector2 = w.bodies["staged"].position
    check(s.start_effort("packed","grab"),"grip the packed find to bring it back out")
    await ticks(w,s,30)
    check(s.held == "packed" and w.bodies.has("packed"),"the cargo body re-enters the world")
    check(w.bodies["staged"].position.distance_to(staged_at) < 12.0,
        "re-entry does not materialise inside the staged find and knock it away")
    s.cancel_hand()
    w.sync(s,pointer)
    w.free()
    await physics_frame

func test_containers_and_cargo() -> void:
    var s: RefCounted = blank()
    add(s,"bag","bag",Vector2(170,565),Vector2(86,82))
    add(s,"contents","gpu",Vector2.ZERO,Vector2(64,22),"bag")
    add(s,"crate","box",Vector2(400,565),Vector2(110,90))
    add(s,"crate-part","ram",Vector2.ZERO,Vector2(42,18),"crate")
    var w := World.new()
    root.add_child(w)
    w.sync(s,pointer)
    await ticks(w,s,90)
    check(not w.bodies.has("contents") and not w.bodies.has("crate-part"),"closed containers keep pre-generated contents hidden and unsimulated")
    s.start_effort("bag","open")
    await ticks(w,s,62)
    var released_y: float = s.pile.objects["contents"]["center"].y
    await ticks(w,s,55)
    check(w.bodies.has("contents") and w.bodies["contents"].position.y>released_y+20,"opening a bag releases its real contents to gravity")
    check(s.pile.objects["bag"]["size"].y == 18,"opened bag collapses so it no longer supports the old volume")
    var count: int = w.bodies.size()
    check(not s.start_effort("bag","open") and w.bodies.size() == count,"opening again cannot create another reward/body")
    s.start_effort("crate","open")
    await ticks(w,s,75)
    check(w.bodies["crate"].get_child_count() == 3 and w.bodies.has("crate-part"),"open box becomes three solid walls with tangible contents")
    # Fixture already clear of the rim exercises physical-to-grid and rollback handoff.
    add(s,"cargo-part","gpu",Vector2(756,560),Vector2(64,24))
    s.pile.objects["cargo-part"]["zone"] = "sort"
    w.sync(s,pointer)
    await ticks(w,s,30)
    s.start_effort("cargo-part","grab")
    await ticks(w,s,65,Vector2(770,230))
    check(s.drop_cargo(Vector2i(1,1)),"physically extracted part packs into trunk")
    w.sync(s,pointer)
    check(not w.bodies.has("cargo-part") and not s.pile.objects.has("cargo-part"),"packing removes native body and site record, preserving one cargo identity")
    var saved: Dictionary = s.grids[s.car].placements["cargo-part"].duplicate()
    s.start_effort("cargo-part","grab")
    await ticks(w,s,35,Vector2(780,230))
    check(not s.drop_cargo(Vector2i(20,20)),"invalid cargo rearrangement is rejected")
    w.sync(s,pointer)
    w.capture()
    check(s.grids[s.car].placements["cargo-part"] == saved and not w.bodies.has("cargo-part"),"cargo rollback removes transient body and retains committed placement")
    var committed_center: Vector2 = s.cargo[s.car]["cargo-part"]["center"]
    s.start_effort("cargo-part","grab")
    await ticks(w,s,25,Vector2(780,230))
    s.remaining = s.reserve+0.000001
    await ticks(w,s,5,Vector2(770,210))
    w.capture()
    check(s.held == "" and not w.bodies.has("cargo-part") and s.cargo[s.car]["cargo-part"]["center"] == committed_center and s.grids[s.car].placements["cargo-part"] == saved,"time exhaustion removes transient cargo body before pose capture can corrupt rollback")
    w.free()
    await physics_frame

func test_scene() -> void:
    var gs: Node = root.get_node("GameState")
    var money: int = gs.money
    var stock: Array = gs.player_inventory.duplicate(true)
    var job: Dictionary = gs.job.duplicate(true)
    Session.demo = blank()
    add(Session.demo,"input-part","gpu",Vector2(755,560),Vector2(64,24))
    Session.demo.pile.objects["input-part"]["zone"] = "sort"
    var view: Node = load("res://scenes/salvage.tscn").instantiate()
    root.add_child(view)
    view.set_physics_process(false)
    for i in range(60):
        await physics_frame
        view._physics_process(1.0/60.0)
    var at: Vector2 = view.physics.bodies["input-part"].position
    click(view,MOUSE_BUTTON_LEFT,true,at)
    for i in range(80):
        view.pointer = Vector2(780,230)
        await physics_frame
        view._physics_process(1.0/60.0)
    check(view.session.held == "input-part","real scene input grips a native body")
    click(view,MOUSE_BUTTON_LEFT,false,Vector2(906,230))
    check(view.session.cargo[view.session.car].has("input-part"),"real scene release transfers an extracted body into the grid")
    view._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    var budget: float = view.session.remaining
    for i in range(5):
        await physics_frame
        view._physics_process(1.0/60.0)
    check(view.session.paused and view.session.remaining == budget,"focus loss safely pauses the physical scene")
    check(gs.money == money and gs.player_inventory == stock and gs.job == job,"native salvage still has no campaign money/stock/job side effects")
    var expected: RefCounted = view.session
    view.free()
    await physics_frame
    var menu: Node = load("res://scenes/start.tscn").instantiate()
    root.add_child(menu)
    menu._on_salvage()
    await process_frame
    await process_frame
    check(current_scene.session == expected and expected.cargo[expected.car].has("input-part"),"menu route resumes the same isolated cargo/session")
    current_scene._back()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/start.tscn" and gs.job == job,"leaving the physics scene preserves campaign and menu navigation")
    current_scene.free()
    menu.free()
