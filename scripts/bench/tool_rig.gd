# Shared tactile tool handling: selected follow, right-drag/release toss, persistent resting bodies.
extends RefCounted
const Motion = preload("res://scripts/view/part_motion.gd")
const Body = preload("res://scripts/bench/table_body.gd")
const Brush = preload("res://scripts/bench/brush_shape.gd")
const Hose = preload("res://scripts/bench/hose_sim.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const HoseFlow = preload("res://scripts/bench/hose_flow.gd")
const IDS: Array = ["vacuum","brush","pick","cloth","syringe"]
const TIP := Vector2(-18,24)
const TABLE := Rect2(40,105,620,545)
const TURN_STEP: float = PI / 12.0   # one Q/E press turns the held tool 15 degrees
const HALF_SIZE := Vector2(30,42)    # half of the 60 x 84 box a tool occupies (before turning)
const HOSE_ATTACH := Vector2(21,-31) # where the hose joins the vacuum, in the vacuum's own frame
const HOSE_TUG: float = 0.5          # share of the taut hose's pull that drags the vacuum back each step
const HOSE_TUG_DEADBAND: float = 4.0 # a hose lagging less than this many px is slack, not taut
const HOSE_TAUT_FROM: float = 0.9     # the hose counts as taut once its two ends are this share of its length apart
const HOSE_PULL_BACK: float = 0.35   # share of the stretch past the hose's length that is pulled back each step
const CLAMP_RECT := Rect2(550, 612, 88, 30)
const CLAMP_POINT := Vector2(594, 627)
const HOSE_GRAB_RADIUS: float = 12.0  # px; how close to the hose a right click must be to grab it
const HOSE_GRAB_KEEP: int = 3         # the last points by the nozzle cannot be grabbed (that is the vacuum itself)
const HOSE_STRETCH_LIMIT: float = 1.04 # the hose never stretches past this multiple of its length
const COLLIDE_HALF := Vector2(20,34) # half size of the box tools collide with
const SOLID_HEIGHT: float = 16.0     # a tool hopping higher than this flies over others
const MASSES: Dictionary = {"vacuum": 3.0, "brush": 0.6, "pick": 0.4, "cloth": 0.3, "syringe": 0.4}
var motions: Dictionary = {}
var turns: Dictionary = {}           # id -> chosen angle in radians, kept while the tool rests
var bodies: Dictionary = {}
var brush := Brush.new()
var hose := Hose.new()
var flow := HoseFlow.new()           # dust inside the hose on its way to the bin (moved by the view)
var hose_obstacles: Array = []       # pieces on the bench the hose has to lie around (set by the view each step)
var hose_grab: int = -1              # hose point the player is carrying with the right mouse button, or -1
var hose_grab_point := Vector2.ZERO
var clamp_position: Vector2 = CLAMP_POINT
var clamp_dragging: bool = false
var clamp_blocked: bool = false
var clamp_offset := Vector2.ZERO
var clamp_pc := Rect2()
var hose_clamp: int = -1             # parked rope point; session-local desk arrangement
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
    end_clamp_drag()
    release_hose()   # selecting another tool never leaves an invisible hand gripping the hose
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

# Which resting tool is under `mouse` (its turned box), or "". Only asked while the hand is empty:
# with a tool in hand, a click always uses that tool.
func hit(mouse: Vector2, visible: Array = IDS) -> String:
    var order: Array = visible.duplicate()
    if selected in order:
        order.erase(selected)
        order.append(selected)
    order.reverse()
    for id: String in order:
        if id == selected and equipped: continue
        var motion: RefCounted = motions[id]
        var local: Vector2 = (mouse-motion.center).rotated(-motion.angle)
        if absf(local.x) <= HALF_SIZE.x and absf(local.y) <= HALF_SIZE.y: return id
    return ""

# The table area a tool's centre may occupy when the tool is turned by `angle`.
static func keep_inside(center: Vector2, angle: float) -> Vector2:
    var edge := Vector2(absf(cos(angle))*HALF_SIZE.x+absf(sin(angle))*HALF_SIZE.y,
        absf(sin(angle))*HALF_SIZE.x+absf(cos(angle))*HALF_SIZE.y)
    return center.clamp(TABLE.position+edge,TABLE.end-edge)

func hose_end() -> Vector2:
    var motion: RefCounted = motions["vacuum"]
    return motion.center+HOSE_ATTACH.rotated(motion.angle)

# Turn the held tool by a number of 15 degree steps (used by the mouse wheel and middle-button drag).
func rotate_steps(steps: int) -> void:
    if steps == 0: return
    rotate_held(1 if steps > 0 else -1)
    rotate_steps(steps - (1 if steps > 0 else -1))

# Turn the held tool by `direction` (+1 clockwise, -1 anticlockwise). The working tip stays on the cursor.
func rotate_held(direction: int) -> void:
    if not equipped or carrying: return
    turns[selected] = wrapf(float(turns[selected]) + direction * TURN_STEP, -PI, PI)

func contact() -> Vector2:
    var motion: RefCounted = motions[selected]
    return motion.center+TIP.rotated(motion.angle)

func step(delta: float, mouse: Vector2, using: bool) -> void:
    point = mouse
    if clamp_dragging: move_clamp(mouse)
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
    # The bristles bend in the tool's own frame, so the sweep speed is turned into that frame first.
    brush.step(delta,speed.rotated(-float(motions[selected].angle)),active and selected in ["brush","cloth"])
    if hose_grab >= 0:
        hose_grab_point = mouse.clamp(TABLE.position + Vector2.ONE * 6.0, TABLE.end - Vector2.ONE * 6.0)
    var pinned_index: int = hose_grab if hose_grab >= 0 else hose_clamp
    var pinned_at: Vector2 = hose_grab_point if hose_grab >= 0 else clamp_position
    hose.step(delta,DustBin.hose_anchor(),hose_end(),hose_obstacles,pinned_index,pinned_at)
    _apply_hose_tug()


# Right mouse on the hose picks it up so it can be moved out of the way. A held tool is put down first.
func hose_hit(point: Vector2) -> bool:
    return hose.nearest_point(point,HOSE_GRAB_RADIUS,HOSE_GRAB_KEEP) > 0

func grab_hose(point: Vector2) -> bool:
    var index: int = hose.nearest_point(point,HOSE_GRAB_RADIUS,HOSE_GRAB_KEEP)
    if index <= 0: return false
    if equipped: park()
    hose_clamp = -1
    hose_grab = index
    hose_grab_point = point
    return true

# Drop a carried section into the visible clamp. Too-short sections remain free.
func release_hose(drop_point: Vector2 = Vector2.INF) -> void:
    if hose_grab > 0 and clamp_rect().has_point(drop_point):
        var reach: float = hose.segment * float(hose_grab) * 0.98
        if DustBin.hose_anchor().distance_to(clamp_position) <= reach:
            hose_clamp = hose_grab
    hose_grab = -1


func unclamp_hose() -> void:
    hose_clamp = -1


# The hose slides below tools, including held tools, so picking one up cannot trap it.
# Component housings remain obstacles and use their full rectangular silhouette.
func set_hose_obstacles(pieces: Array, fitted: Array) -> void:
    hose_obstacles = []
    for piece: Dictionary in pieces:
        if piece.get("kind", "") != "part" or not bool(piece.get("solid", false)):
            continue
        # A lifted/dragged component passes above the hose, like a held tool.
        if float(piece.get("inv_mass", 0.0)) <= 0.0:
            continue
        var housing: Dictionary = piece.duplicate()
        housing["corner_radius"] = 0.0
        hose_obstacles.append(housing)
    for piece: Dictionary in fitted:
        var housing: Dictionary = piece.duplicate()
        housing["corner_radius"] = 0.0
        hose_obstacles.append(housing)


# The "longer hose" upgrade makes the hose longer.
func set_long_hose(owned: bool) -> void:
    hose.set_length(Hose.LONG_LENGTH if owned else Hose.BASE_LENGTH)

# A taut hose holds the vacuum back: it drags the vacuum toward the bin, and never lets it stretch the
# hose past HOSE_STRETCH_LIMIT times its length. Works for a held, resting or thrown vacuum.
func _apply_hose_tug() -> void:
    var motion: RefCounted = motions["vacuum"]
    var body: RefCounted = bodies["vacuum"]
    var held: bool = selected == "vacuum" and equipped
    var pull := Vector2.ZERO
    # The hose runs from the bin, through the point the player holds (if any), to the vacuum.
    var from: Vector2 = hose.pin_point if hose.pinned() else DustBin.hose_anchor()
    var used: float = hose.segment*float(hose.pin) if hose.pinned() else 0.0
    var reach: Vector2 = hose_end() - from
    var length: float = hose.length()
    var span: float = used + reach.length()
    # Only a nearly straight hose is taut. A bent hose lagging behind (caught on a piece) never drags the vacuum.
    if hose.tug.length() > HOSE_TUG_DEADBAND and span > length * HOSE_TAUT_FROM:
        pull += hose.tug.normalized() * (hose.tug.length() - HOSE_TUG_DEADBAND) * HOSE_TUG
    if span > length:
        pull -= reach.normalized() * (span - length) * HOSE_PULL_BACK
    var limit: float = length * HOSE_STRETCH_LIMIT
    var after: Vector2 = reach + pull
    if used + after.length() > limit:
        pull -= after.normalized() * (used + after.length() - limit)
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


func clamp_rect() -> Rect2:
    return Rect2(clamp_position-CLAMP_RECT.size*0.5,CLAMP_RECT.size)


# A desk fixture: no physics throws and its WHOLE footprint must stay outside the case.
func begin_clamp_drag(point: Vector2) -> bool:
    if not clamp_rect().has_point(point): return false
    if equipped: park()
    clamp_dragging = true
    clamp_blocked = false
    clamp_offset = point-clamp_position
    return true


func move_clamp(point: Vector2) -> bool:
    clamp_blocked = true
    var half: Vector2 = CLAMP_RECT.size*0.5
    var candidate: Vector2 = (point-clamp_offset).clamp(TABLE.position+half,TABLE.end-half)
    var footprint := Rect2(candidate-half,CLAMP_RECT.size)
    if clamp_pc.has_area() and footprint.intersects(clamp_pc.grow(3.0)): return false
    if footprint.intersects(DustBin.RECT.grow(3.0)): return false
    if hose_clamp > 0 and DustBin.hose_anchor().distance_to(candidate) > hose.segment*float(hose_clamp)*0.98: return false
    clamp_position = candidate
    clamp_blocked = false
    return true


func end_clamp_drag() -> void:
    clamp_dragging = false
    clamp_blocked = false
