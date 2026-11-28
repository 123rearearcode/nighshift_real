# VIEW (0.59.2, D186): the thermal paste manual. User, 28 November 2026: "For the thermal paste, I need the steps in
# the bottom right to be more nicely represented, as pages in a manual that is movable and scrollable by the player,
# which also is tied to where the player currently is"; asked about other bench steps: "Lets start w thermal paste
# only". A small booklet on the thermal stage: one page per step (the same six as BenchThermal.GUIDE), with the live
# NOW instruction printed on the current step's page. Drag it by its spine; the mouse wheel over it (or the arrows)
# turns pages. It opens at the step you are on and turns with you when your step changes; a page you turned to
# yourself stays until you reach the next step. Display only: the rules stay in install_faults.gd and paste_sim.gd.
extends Control

const PAGES: Array = [
    {"title": "1 · Peel the film", "body": "A new cooler arrives with a clear plastic film on its plate. Peel it off first: left on, it melts into a layer that keeps the heat in, and the customer feels it at home. Your own check will not notice."},
    {"title": "2 · A pea of paste", "body": "Right-click the syringe. Hold the left button on the middle of the CPU and let a pea-sized dot form: stop in the green zone. Too little leaves bare corners; too much squeezes out over the edge."},
    {"title": "3 · Press and screw down", "body": "Click Mount cooler, then hold Space to press it evenly. While pressing, take the screwdriver and turn the four corner screws in a cross: one corner, then the opposite one. Two passes."},
    {"title": "4 · Lock the lever", "body": "With every screw tight, click the lever beside the socket. The cooler is locked; the grade of your mount is decided now."},
    {"title": "5 · Wipe the extra", "body": "Paste that squeezed out around the CPU goes with the cloth: right-click it and wipe around the socket, never on the CPU itself."},
    {"title": "6 · Done", "body": "A good result counts once you press Complete repaste. A poor one is not good enough: clear all the paste and start again from page 2. Then check the temperature at the diagnostic monitor."},
]
const SIZE := Vector2(300, 196)
const SPINE: float = 22.0
const PAPER := Color("efe6cf")
const INK := Color("2b2620")

var page: int = 0
var followed_step: int = -1      # the step the manual last turned to by itself
var now_line: String = ""
var drag_from := Vector2.ZERO
var dragging: bool = false


func _ready() -> void:
    name = "ThermalManual"
    size = SIZE
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 25


# Called by the bench each frame on the thermal stage: the step the player is on and its NOW line.
func follow(step: int, now: String) -> void:
    if step != followed_step:
        followed_step = step
        page = clampi(step, 0, PAGES.size() - 1)
        queue_redraw()
    if now != now_line:
        now_line = now
        queue_redraw()


func turn(delta: int) -> void:
    page = clampi(page + delta, 0, PAGES.size() - 1)
    queue_redraw()


func _gui_input(event: InputEvent) -> void:
    var mb := event as InputEventMouseButton
    if mb != null:
        if mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN: turn(1)
        elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP: turn(-1)
        elif mb.button_index == MOUSE_BUTTON_LEFT:
            if mb.pressed and mb.position.x <= SPINE + 4.0:
                dragging = true
                drag_from = mb.position
            elif mb.pressed and Rect2(SIZE.x - 34, SIZE.y - 28, 28, 22).has_point(mb.position): turn(1)
            elif mb.pressed and Rect2(SPINE + 6, SIZE.y - 28, 28, 22).has_point(mb.position): turn(-1)
            elif not mb.pressed: dragging = false
        accept_event()
    elif event is InputEventMouseMotion and dragging:
        var moved: Vector2 = (event as InputEventMouseMotion).position - drag_from
        position = (position + moved).clamp(Vector2.ZERO, Vector2(1280, 720) - SIZE)
        accept_event()


func _draw() -> void:
    var font: Font = ThemeDB.fallback_font
    draw_rect(Rect2(Vector2(4, 5), SIZE), Color(0, 0, 0, 0.35))                      # shadow on the bench
    draw_rect(Rect2(Vector2.ZERO, SIZE), PAPER)
    draw_rect(Rect2(Vector2.ZERO, Vector2(SPINE, SIZE.y)), Color("7a4a2e"))           # cloth spine: drag here
    for y in range(14, int(SIZE.y) - 10, 18): draw_circle(Vector2(SPINE * 0.5, y), 2.5, Color("3a2416"))
    draw_rect(Rect2(Vector2.ZERO, SIZE), Color("5a4a36"), false, 2.0)
    var p: Dictionary = PAGES[page]
    var x: float = SPINE + 10.0
    draw_string(font, Vector2(x, 22), "THERMAL SERVICE · MANUAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("8a7a62"))
    draw_string(font, Vector2(x, 42), str(p["title"]), HORIZONTAL_ALIGNMENT_LEFT, SIZE.x - x - 8, 16, INK)
    draw_multiline_string(font, Vector2(x, 62), str(p["body"]), HORIZONTAL_ALIGNMENT_LEFT, SIZE.x - x - 10, 12, -1, INK)
    if page == followed_step and now_line != "":                                      # you are here
        draw_rect(Rect2(x - 4, SIZE.y - 66, SIZE.x - x - 4, 34), Color("f7d98a"))
        draw_multiline_string(font, Vector2(x, SIZE.y - 52), now_line, HORIZONTAL_ALIGNMENT_LEFT, SIZE.x - x - 10, 11, 2, Color("3a2a10"))
    draw_string(font, Vector2(SPINE + 10, SIZE.y - 10), "‹", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK if page > 0 else Color("b8ad96"))
    draw_string(font, Vector2(SIZE.x - 24, SIZE.y - 10), "›", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK if page < PAGES.size() - 1 else Color("b8ad96"))
    draw_string(font, Vector2(SIZE.x * 0.5, SIZE.y - 10), "%d / %d" % [page + 1, PAGES.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("8a7a62"))
