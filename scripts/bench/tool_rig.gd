# Shared tactile tool handling: selected follow, right-drag/release toss, persistent resting bodies.
extends RefCounted
const Motion = preload("res://scripts/view/part_motion.gd")
const Body = preload("res://scripts/bench/table_body.gd")
const Brush = preload("res://scripts/bench/brush_shape.gd")
const Hose = preload("res://scripts/bench/hose_sim.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const IDS: Array = ["vacuum","brush","pick","cloth","syringe"]
const TIP := Vector2(-18,24)
const TABLE := Rect2(40,105,620,545)
const TURN_STEP: float = PI / 12.0   # one Q/E press turns the held tool 15 degrees
const HALF_SIZE := Vector2(30,42)    # half of the 60 x 84 box a tool occupies (before turning)
const HOSE_ATTACH := Vector2(21,-31) # where the hose joins the vacuum, in the vacuum's own frame
const HOSE_TUG: float = 0.5          # share of the taut hose's pull that drags the vacuum back each step
const HOSE_STRETCH_LIMIT: float = 1.12 # the hose never stretches past this multiple of its length
const COLLIDE_HALF := Vector2(20,34) # half size of the box tools collide with
const SOLID_HEIGHT: float = 16.0     # a tool hopping higher than this flies over others
const MASSES: Dictionary = {"vacuum": 3.0, "brush": 0.6, "pick": 0.4, "cloth": 0.3, "syringe": 0.4}
var motions: Dictionary = {}
var turns: Dictionary = {}           # id -> chosen angle in radians, kept while the tool rests
var bodies: Dictionary = {}
var brush := Brush.new()
var hose := Hose.new()
var hose_obstacles: Array = []       # pieces on the bench the hose has to lie around (set by the view each step)
var selected: String = "vacuum"
var equipped: bool = true
var carrying: bool = false
var active: bool = false
var point := Vector2.ZERO
var speed := Vector2.ZERO
var last_tip := Vector2.ZERO

func _init() -> void:
    for i in range(IDS.size()):
        var motion := Motion.new()
        motion.snap(Vector2(616,160+i*85),0)
        motions[IDS[i]] = motion
        bodies[IDS[i]] = Body.new()
        turns[IDS[i]] = 0.0
    hose.reset(DustBin.hose_anchor(), hose_end())

func select(id: String, mouse: Vector2) -> void:
    if not id in IDS: return
    if equipped: park()
    selected = id
    bodies[id].active = false
    equipped = true
    carrying = false
    var target: Vector2 = keep_inside(mouse-TIP.rotated(float(turns[id])),float(turns[id]))
    motions[id].snap(target,0)
    motions[id].angle = float(turns[id])
    last_tip = contact()
    speed = Vector2.ZERO

func begin_throw(mouse: Vector2) -> void:
    if not equipped:
        var id: String = hit(mouse)
        if id != "": select(id,mouse)
    if equipped: carrying = true

func release_throw(mouse_velocity: Vector2) -> void:
    if not carrying: return
    var motion: RefCounted = motions[selected]
    bodies[selected].launch(motion.center,mouse_velocity*0.8,Vector2(30,42),motion.angle)
    equipped = false
    carrying = false
    active = false

func hit(mouse: Vector2, visible: Array = IDS) -> String:
    var order: Array = visible.duplicate()
    if selected in order:
        order.erase(selected)
        order.append(selected)
    order.reverse()
    for id: String in order:
        if id == selected and equipped: continue
        var motion: RefCounted = motions[id]
        if Rect2(motion.center-Vector2(30,42),Vector2(60,84)).has_point(mouse): return id
    return ""

# The table area a tool's centre may occupy when the tool is turned by `angle`.
static func keep_inside(center: Vector2, angle: float) -> Vector2:
    var edge := Vector2(absf(cos(angle))*HALF_SIZE.x+absf(sin(angle))*HALF_SIZE.y,
        absf(sin(angle))*HALF_SIZE.x+absf(cos(angle))*HALF_SIZE.y)
    return center.clamp(TABLE.position+edge,TABLE.end-edge)

func hose_end() -> Vector2:
    var motion: RefCounted = motions["vacuum"]
    return motion.center+HOSE_ATTACH.rotated(motion.angle)

# Turn the held tool by `direction` (+1 clockwise, -1 anticlockwise). The working tip stays on the cursor.
func rotate_held(direction: int) -> void:
    if not equipped or carrying: return
    turns[selected] = wrapf(float(turns[selected]) + direction * TURN_STEP, -PI, PI)

func contact() -> Vector2:
    var motion: RefCounted = motions[selected]
    return motion.center+TIP.rotated(motion.angle)

func step(delta: float, mouse: Vector2, using: bool) -> void:
    point = mouse
    for id: String in IDS:
        var body: RefCounted = bodies[id]
        var motion: RefCounted = motions[id]
        if body.active:
            body.step(delta,TABLE)
            motion.center = body.center
            motion.angle = body.angle
            motion.lift = body.height/60.0
        elif id == selected and equipped:
            # The held tool follows the cursor but can never leave the table, even with the cursor outside it.
            motion.step(delta,keep_inside(mouse-TIP.rotated(motion.angle),motion.angle),0,true,float(turns[id]))
            motion.center = keep_inside(motion.center,motion.angle)
    active = using and equipped and not carrying
    var tip: Vector2 = contact()
    speed = ((tip-last_tip)/maxf(delta,0.00001)).limit_length(2500)
    last_tip = tip
    brush.step(delta,speed,active and selected in ["brush","cloth"])
    hose.step(delta,DustBin.hose_anchor(),hose_end(),hose_obstacles)
    _apply_hose_tug()


# The "longer hose" upgrade makes the hose longer.
func set_long_hose(owned: bool) -> void:
    hose.set_length(Hose.LONG_LENGTH if owned else Hose.BASE_LENGTH)

# A taut hose holds the vacuum back: it drags the vacuum toward the bin, and never lets it stretch the
# hose past HOSE_STRETCH_LIMIT times its length. Works for a held, resting or thrown vacuum.
func _apply_hose_tug() -> void:
    var motion: RefCounted = motions["vacuum"]
    var body: RefCounted = bodies["vacuum"]
    var held: bool = selected == "vacuum" and equipped
    var pull: Vector2 = hose.tug * HOSE_TUG
    var anchor_point: Vector2 = DustBin.hose_anchor()
    var reach: Vector2 = hose_end() - anchor_point
    var limit: float = hose.length() * HOSE_STRETCH_LIMIT
    if reach.length() > limit:
        pull += reach.normalized() * (limit - reach.length())
    if pull.length() < 0.05: return
    if held:
        motion.center += pull
        motion.center = keep_inside(motion.center,motion.angle)
    else:
        if not body.active:
            body.center = motion.center
            body.angle = motion.angle
            body.half_size = HALF_SIZE
            body.velocity = Vector2.ZERO
            body.angular_velocity = 0.0
            body.height = 0.0
            body.vertical_velocity = 0.0
            body.active = true
        body.center += pull
        motion.center = body.center

# The boxes tools collide with, for scripts/bench/piece_collision.gd. `visible` lists the tools on the bench now.
func collision_pieces(visible: Array) -> Array:
    var out: Array = []
    for id: String in visible:
        if not id in IDS: continue
        var motion: RefCounted = motions[id]
        var body: RefCounted = bodies[id]
        var held: bool = id == selected and equipped
        out.append({"id": id, "kind": "tool", "center": motion.center, "angle": motion.angle, "half": COLLIDE_HALF,
            "velocity": motion.velocity if held else body.velocity,
            "spin": 0.0 if held else body.angular_velocity,
            "inv_mass": 0.0 if held else 1.0 / float(MASSES[id]),
            "solid": held or not body.active or body.height < SOLID_HEIGHT,
            "touched": false})
    return out

# Copy collision results back: tools that were struck or pushed start sliding (a resting tool wakes up).
func apply_collisions(pieces: Array) -> void:
    for piece: Dictionary in pieces:
        if piece["kind"] != "tool" or not bool(piece["touched"]): continue
        var id: String = piece["id"]
        if id == selected and equipped: continue
        var body: RefCounted = bodies[id]
        var motion: RefCounted = motions[id]
        var was_active: bool = body.active
        body.center = keep_inside(piece["center"],float(piece["angle"]))
        body.angle = piece["angle"]
        body.velocity = piece["velocity"]
        body.angular_velocity = piece["spin"]
        body.half_size = HALF_SIZE
        if not was_active:
            body.height = 0.0
            body.vertical_velocity = 0.0
            body.active = true
        motion.center = body.center
        motion.angle = body.angle

func park() -> void:
    var motion: RefCounted = motions[selected]
    motion.center = keep_inside(motion.center,motion.angle)
    motion.velocity = Vector2.ZERO
    equipped = false
    carrying = false
    active = false
