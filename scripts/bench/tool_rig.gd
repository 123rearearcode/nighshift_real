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
var motions: Dictionary = {}
var turns: Dictionary = {}           # id -> chosen angle in radians, kept while the tool rests
var bodies: Dictionary = {}
var brush := Brush.new()
var hose := Hose.new()
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
    hose.step(delta,DustBin.hose_anchor(),hose_end())


func park() -> void:
    var motion: RefCounted = motions[selected]
    motion.center = keep_inside(motion.center,motion.angle)
    motion.velocity = Vector2.ZERO
    equipped = false
    carrying = false
    active = false
