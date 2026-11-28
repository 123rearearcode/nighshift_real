# VIEW + STATE STEP (0.59.2, D186): the repair bench before the work starts. User, 28 November 2026: "In the
# repair bench, there should be extra steps for immersion, moving the PC onto the table, and opening the case",
# and (asked) "unscrew and lift the side panel? For laptops, unscrew the bottom cover?": "Yes and yes".
#
# A PC that has not been opened yet arrives beside the mat (job "case_state" = "off_table"). Drag it onto the
# mat ("closed"); turn out its screws by clicking them (a desktop's two thumbscrews at the rear edge, a laptop's
# eight cover screws); then drag the side panel (or the bottom cover) off onto the tray ("open"). Until then this
# overlay takes every click on the bench table, so nothing inside can be touched through a closed case. Once open
# it frees itself; the bench underneath is the same as before. Old saves and the headless suites have the case
# open already (GameState.desktop_first_ticket under the suites; a save without case_state loads open). Panel art waits for approval (tools/art_batch_f/day1.py); until
# then a plain steel panel is drawn.
extends Node2D

signal opened
signal changed(state: String)   # every step, so a PC left on the mat stays there (bench_view saves it)

const Layout = preload("res://scripts/data/layout.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")

const BENCH_ART_README := "res://art/bench/background/README.md"   # art/bench/case/ sits beside it once approved
const OFF_TABLE := "off_table"
const CLOSED := "closed"
const OPEN := "open"
const SCREW_RADIUS: float = 9.0
const OFF_SCALE: float = 0.45          # the PC beside the mat, before you lift it on
# Screw spots in cells of the PC's own layout (pc_layout.gd): a desktop's thumbscrews on the rear edge, a laptop's
# cover screws around its rim.
const DESKTOP_SCREWS: Array = [Vector2(0.4, 1.0), Vector2(0.4, -1.0)]       # y < 0 counts from the bottom edge
const LAPTOP_SCREWS: Array = [Vector2(1.2, 0.5), Vector2(6.0, 0.5), Vector2(12.8, 0.5), Vector2(0.5, 4.5), Vector2(13.5, 4.5),
    Vector2(1.2, 8.5), Vector2(7.0, 8.5), Vector2(12.8, 8.5)]

var profile_id: String = "tower"
var state: String = OPEN
var screws_out: Array = []
var dragging: bool = false
var drag_offset := Vector2.ZERO
var panel_pos := Vector2.ZERO          # top-left of the PC (off the table) or of the panel (while lifting it off)
var pointer := Vector2.ZERO
var message: String = ""


func setup(profile: String, case_state: String) -> void:
    profile_id = profile
    state = case_state if case_state in [OFF_TABLE, CLOSED, OPEN] else OPEN
    z_index = 30
    panel_pos = _off_rect().position if state == OFF_TABLE else case_rect().position
    message = _hint()


func active() -> bool:
    return state != OPEN


# The PC's outline on the mat, the same rectangle the bench draws it in.
func case_rect() -> Rect2:
    return PCLayout.display(PCLayout.profile(profile_id), Rect2(Layout.BENCH_PC_ORIGIN, DustZones.AREA_SIZE))["case_rect"]


func _cell() -> float:
    return float(PCLayout.display(PCLayout.profile(profile_id), Rect2(Layout.BENCH_PC_ORIGIN, DustZones.AREA_SIZE))["cell"])


func _off_rect() -> Rect2:
    var r: Rect2 = case_rect()
    var size: Vector2 = r.size * OFF_SCALE
    return Rect2(Layout.BENCH_TRAY.get_center() - size * 0.5, size)


func screw_count() -> int:
    return LAPTOP_SCREWS.size() if profile_id == "laptop" else DESKTOP_SCREWS.size()


func screw_center(i: int) -> Vector2:
    var r: Rect2 = case_rect()
    var cell: float = _cell()
    var spot: Vector2 = (LAPTOP_SCREWS if profile_id == "laptop" else DESKTOP_SCREWS)[i]
    var y: float = spot.y * cell if spot.y >= 0.0 else r.size.y + spot.y * cell
    return r.position + Vector2(spot.x * cell, y)


func _hint() -> String:
    match state:
        OFF_TABLE: return "Lift the %s onto the mat: drag it from the tray." % ("laptop" if profile_id == "laptop" else "PC")
        CLOSED:
            if screws_out.size() < screw_count(): return "Turn out the %s: click each one (%d of %d out)." % ["cover screws" if profile_id == "laptop" else "two thumbscrews", screws_out.size(), screw_count()]
            return "Lift the %s off: drag it onto the tray." % ("bottom cover" if profile_id == "laptop" else "side panel")
    return ""


func _input(event: InputEvent) -> void:
    if state == OPEN or not is_visible_in_tree() or not event is InputEventMouse: return
    pointer = (event as InputEventMouse).position
    if not ToolRig.TABLE.has_point(pointer) and not dragging: return   # buttons and the way back stay usable
    var mb := event as InputEventMouseButton
    if mb != null and mb.button_index == MOUSE_BUTTON_LEFT:
        if mb.pressed: press(pointer)
        else: release(pointer)
    elif event is InputEventMouseMotion and dragging:
        panel_pos = pointer - drag_offset
        queue_redraw()
    get_viewport().set_input_as_handled()


func press(at: Vector2) -> void:
    pointer = at
    match state:
        OFF_TABLE:
            if Rect2(panel_pos, _off_rect().size).has_point(at):
                dragging = true
                drag_offset = at - panel_pos
        CLOSED:
            for i in range(screw_count()):
                if not i in screws_out and screw_center(i).distance_to(at) <= SCREW_RADIUS + 4.0:
                    screws_out.append(i)
                    message = _hint()
                    queue_redraw()
                    return
            if screws_out.size() >= screw_count() and Rect2(panel_pos, case_rect().size).has_point(at):
                dragging = true
                drag_offset = at - panel_pos
            elif screws_out.size() < screw_count():
                message = "The %s is still screwed on: %s" % ["cover" if profile_id == "laptop" else "side panel", _hint()]
    queue_redraw()


func release(at: Vector2) -> void:
    pointer = at
    if not dragging: return
    dragging = false
    if state == OFF_TABLE:
        if case_rect().has_point(at):
            state = CLOSED
            panel_pos = case_rect().position
            changed.emit(state)
        else:
            panel_pos = _off_rect().position
    elif state == CLOSED:
        if Layout.BENCH_TRAY.has_point(at) or not case_rect().grow(-20.0).has_point(at):
            state = OPEN
            changed.emit(state)
            opened.emit()
            hide()
        else:
            panel_pos = case_rect().position
    message = _hint()
    queue_redraw()


func _draw() -> void:
    if state == OPEN: return
    var r: Rect2 = case_rect()
    if state == OFF_TABLE:
        draw_rect(r, Color(0.07, 0.09, 0.1, 0.55))                       # the empty mat where it goes
        draw_rect(r, Color("8fb3a3"), false, 2.0)
        draw_string(ThemeDB.fallback_font, r.position + Vector2(12, 24), "drop it here", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("cfe3d8"))
        _draw_closed(Rect2(panel_pos, _off_rect().size), false)
    else:
        draw_rect(r, Color(0.05, 0.06, 0.07, 0.85))                      # what is inside stays hidden until it opens
        _draw_closed(Rect2(panel_pos, r.size), not dragging)
    draw_string(ThemeDB.fallback_font, Vector2(Layout.BENCH_PC_ORIGIN.x, Layout.BENCH_PC_ORIGIN.y - 12), message, HORIZONTAL_ALIGNMENT_LEFT, 620, 15, Color("ffd27a"))


func _panel_texture() -> Texture2D:
    var art_name: String = "laptop_cover" if profile_id == "laptop" else ("side_panel_compact" if profile_id == "compact" else "side_panel_tower")
    return RoomArt.texture(BENCH_ART_README.get_base_dir().get_base_dir() + "/case/%s.png" % art_name)   # only once the user has approved it (the folder is created then)


func _draw_closed(rect: Rect2, with_screws: bool) -> void:
    var tex: Texture2D = _panel_texture()
    if tex != null: draw_texture_rect(tex, rect, false)
    else:
        draw_rect(rect, Color("3b424b") if profile_id == "laptop" else Color("59616c"))
        draw_rect(rect.grow(-rect.size.x * 0.04), Color("2c3137") if profile_id == "laptop" else Color("626b77"), false, 2.0)
        draw_rect(rect, Color("15171b"), false, 2.0)
        draw_string(ThemeDB.fallback_font, rect.position + Vector2(14, rect.size.y * 0.5), "BOTTOM COVER" if profile_id == "laptop" else "SIDE PANEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("c8d0d8"))
    if not with_screws or state != CLOSED: return
    for i in range(screw_count()):
        if i in screws_out: continue
        var c: Vector2 = screw_center(i)
        var hover: bool = c.distance_to(pointer) <= SCREW_RADIUS + 4.0
        draw_circle(c, SCREW_RADIUS, Color("d9dee3") if hover else Color("b9bfc5"))
        draw_arc(c, SCREW_RADIUS, 0.0, TAU, 20, Color("15171b"), 2.0)
        draw_line(c - Vector2(5, 0), c + Vector2(5, 0), Color("4b5158"), 2.0)
        if profile_id == "laptop": draw_line(c - Vector2(0, 5), c + Vector2(0, 5), Color("4b5158"), 2.0)
