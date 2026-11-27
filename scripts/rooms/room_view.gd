# A place in the shop (0.53.0, D161; user, 21 November 2026: "get rid of the menus ... everything ties
# together visually instead of with menus"). A room is one picture with hotspots on it (hotspot.gd). Its
# scene (scenes/rooms/<room>.tscn) holds a Background (the art; empty = placeholder drawing) and the
# hotspots, so the artist only paints and drags rectangles (docs/ROOM_ART_GUIDE.md). This script turns
# clicks into actions; rooms add their own (counter_room.gd, workshop_room.gd, outside_room.gd).
# Game rules stay in GameState and the rules scripts: a room never decides anything about a PC.
extends Node2D

const Navigation = preload("res://scripts/night/night_navigation.gd")
const NightClock = preload("res://scripts/rules/night_clock.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const Hotspot = preload("res://scripts/rooms/hotspot.gd")
const WORKBENCH: Array = ["repair", "hardware", "monitor"]
const CableBox = preload("res://scripts/rules/cable_box.gd")          # 0.58.3 (D173): the movable cable box
const CableStore = preload("res://scripts/state/cable_store.gd")
const CableBoxView = preload("res://scripts/view/cable_box_view.gd")
const BackpackView = preload("res://scripts/view/backpack_view.gd")   # 0.58.4: the personal inventory
const BACKPACK_BUTTON := Rect2(1150, 650, 110, 34)
# Where the box stands in each room that can hold it (screen px).
const CABLE_SPOTS: Dictionary = {"counter": Rect2(236, 498, 140, 62), "workshop": Rect2(560, 540, 150, 66), "outside": Rect2(520, 470, 140, 62)}

## The room's picture file name in art/rooms/ (without ".png"), used when the Background node has no
## texture set. "counter" loads art/rooms/counter.png when that file exists.
@export var art_name: String = ""
## Shown top-left so the player always knows where they are.
@export var room_title: String = ""
## Placeholder colours, used only until the room has its art.
@export var wall_color: Color = Color("1c2630")
@export var floor_color: Color = Color("232c33")

var placeholders: bool = true
var outlines: bool = false
var hotspots: Dictionary = {}     # node name -> hotspot
var message: Label
var title: Label
var cable_place: String = ""       # this room's place name, if the cable box can stand here
var cable_spot: Button             # the box itself, standing here
var cable_drop: Button             # "Put the cable box down here" while carrying it
var cable_view: Control            # the open box
var backpack_button: Button        # 0.58.4: opens your backpack, in every room
var backpack_view: Control


func _ready() -> void:
    NightSession.ensure(GameState)
    var background: TextureRect = get_node_or_null("Background")
    if background != null:
        if background.texture == null: background.texture = RoomArt.room(art_name)
        placeholders = background.texture == null
        background.visible = not placeholders
    for node: Node in find_children("*", "", true, false):
        if node.get_script() == Hotspot:
            var spot: Hotspot = node as Hotspot
            hotspots[str(spot.name)] = spot
            spot.placeholder = placeholders
            spot.pressed.connect(_press.bind(spot))
    title = _label(room_title, Vector2(24, 24), Vector2(700, 36), 24)
    message = _label(NightSession.status, Vector2(24, 664), Vector2(1100, 50), 16)
    Navigation.pause(self)
    _room_ready()
    _setup_cable_box()
    _setup_backpack()
    refresh()
    queue_redraw()


# For the room scripts.
func _room_ready() -> void:
    pass


# ---- your backpack (0.58.4: "the player can have a personal inventory (he can buy backpacks to upgrade)") ----

func _setup_backpack() -> void:
    backpack_button = Button.new()
    backpack_button.name = "BackpackButton"
    backpack_button.text = "Backpack (B)"
    backpack_button.position = BACKPACK_BUTTON.position
    backpack_button.size = BACKPACK_BUTTON.size
    backpack_button.z_index = 5
    backpack_button.pressed.connect(open_backpack)
    add_child(backpack_button)


func open_backpack() -> void:
    if backpack_view != null or cable_view != null: return
    var view: Control = BackpackView.new()
    add_child(view)
    view.open()
    view.closed.connect(_close_backpack)
    backpack_view = view


func _close_backpack() -> void:
    if backpack_view != null: backpack_view.queue_free()
    backpack_view = null


# ---- the cable box (0.58.3, D173: "can be moved from room to room") ----

func _setup_cable_box() -> void:
    for place: String in Navigation.PLACES:
        if Navigation.PLACES[place] == scene_file_path: cable_place = place
    if not CABLE_SPOTS.has(cable_place): return
    var spot: Rect2 = CABLE_SPOTS[cable_place]
    cable_spot = Button.new()
    cable_spot.name = "CableBoxSpot"
    cable_spot.flat = true
    cable_spot.tooltip_text = "The cable box"
    cable_spot.position = spot.position
    cable_spot.size = spot.size
    cable_spot.z_index = 4
    cable_spot.draw.connect(_draw_cable_box.bind(cable_spot))
    cable_spot.pressed.connect(open_cable_box)
    add_child(cable_spot)
    cable_drop = Button.new()
    cable_drop.name = "CableBoxDrop"
    cable_drop.text = "Put the cable box down here"
    cable_drop.position = Vector2(spot.position.x - 30, spot.position.y - 44)
    cable_drop.size = Vector2(spot.size.x + 60, 36)
    cable_drop.z_index = 4
    cable_drop.pressed.connect(put_cable_box_down)
    add_child(cable_drop)
    _show_cable_box()


func _show_cable_box() -> void:
    if cable_spot == null: return
    var box: Dictionary = CableStore.load_box(GameState)
    cable_spot.visible = not bool(box["carried"]) and str(box["room"]) == cable_place
    cable_drop.visible = bool(box["carried"])


func open_cable_box() -> void:
    if cable_view != null: return
    var view: Control = CableBoxView.new()
    add_child(view)
    view.open(GameState, CableStore.load_box(GameState))
    view.closed.connect(_close_cable_box)
    view.carry_requested.connect(_carry_cable_box)
    cable_view = view


func _close_cable_box() -> void:
    if cable_view != null: cable_view.queue_free()
    cable_view = null
    _show_cable_box()


func _carry_cable_box() -> void:
    var box: Dictionary = cable_view.state if cable_view != null else CableStore.load_box(GameState)
    CableBox.pick_up(box)
    CableStore.save_box(GameState, box)
    _close_cable_box()
    say("You pick up the cable box. Put it down in the room where you need it.")


func put_cable_box_down() -> void:
    var box: Dictionary = CableStore.load_box(GameState)
    var loose: int = CableBox.loose(box).size()
    var moved: bool = str(box["room"]) != cable_place
    var knots: int = CableBox.put_down(box, cable_place)
    if knots < 0: return
    CableStore.save_box(GameState, box)
    _show_cable_box()
    if not moved: say("You put the cable box back down.")
    elif knots > 0: say("You put the cable box down. The loose cables rattled around on the way: %d new knot%s." % [knots, "" if knots == 1 else "s"])
    elif loose > 0: say("You put the cable box down. The loose cables shifted, but nothing tangled this time.")
    else: say("You put the cable box down. Everything is tied, so nothing tangled.")


func _draw_cable_box(spot: Button) -> void:
    # Placeholder until the box art is approved (D167): a dark plastic crate with cables showing.
    var r := Rect2(Vector2.ZERO, spot.size)
    spot.draw_rect(r, Color("2b2f36"))
    spot.draw_rect(r.grow(-6), Color("4a4f57"))
    for i in range(3):
        var y: float = 14.0 + i * 12.0
        spot.draw_line(Vector2(14, y), Vector2(r.size.x - 14, y + 6.0 * (1 - i)), Color("15171b"), 5.0)
    spot.draw_rect(r, Color("111317"), false, 3.0)
    spot.draw_string(ThemeDB.fallback_font, Vector2(8, r.size.y - 6), "CABLES", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e8e2d0"))


func hotspot(name: String) -> Hotspot:
    return hotspots.get(name, null)


# Live state: dawn closes the hotspots that start new work; rooms add their own badges.
func refresh() -> void:
    var over: bool = NightClock.over(GameState.night_minutes)
    for h: Variant in hotspots.values():
        var spot: Hotspot = h
        if spot.closed_at_dawn:
            spot.disabled = over
            spot.tooltip_text = "06:00: the night is over. Close the shutter." if over else spot.label
    _refresh_room()


func _refresh_room() -> void:
    pass


func _press(spot: Hotspot) -> void:
    AudioFeedback.request(self, "ui.click")
    if spot.disabled: return
    act(str(spot.action), spot)


func act(action: String, spot: Hotspot = null) -> void:
    if action.begins_with("go:"):
        go(action.trim_prefix("go:"))
    elif action.begins_with("later:"):
        say("%s: coming later." % (spot.label if spot != null else action.trim_prefix("later:")))
    elif not _action(action, spot):
        say("Nothing happens.")


# The room's own actions (open:..., end_night). Return true when handled.
func _action(_action_name: String, _spot: Hotspot) -> bool:
    return false


func say(text: String) -> void:
    if is_instance_valid(message): message.text = text


func go(place: String) -> bool:
    var path: String = str(Navigation.PLACES.get(place, ""))
    if path == "":
        say("That way is not open yet.")
        return false
    if place in WORKBENCH:
        if str(GameState.job.get("hardware_trial", {}).get("night_session", {}).get("pc", "")) == "":
            say("No PC on the bench. Bring one in from the stock room first.")
            return false
        if place == "repair" and str(GameState.job.get("ticket", {}).get("request", "")) == "build":
            path = Navigation.HARDWARE   # 0.51.0: a new build has nothing to clean or repaste
    return _navigate(path)


# A scene path directly (for scripts and old callers; the player uses hotspots).
func _go(path: String) -> void:
    _navigate(path)


func _navigate(path: String) -> bool:
    if not NightSession.checkpoint(GameState):
        say(NightSession.status)
        return false
    return Navigation.commit(self, path)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_B and backpack_view == null:
        open_backpack()
        get_viewport().set_input_as_handled()
        return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
        outlines = not outlines
        for h: Variant in hotspots.values():
            var spot: Hotspot = h
            spot.outline = outlines
            spot.queue_redraw()
        say("Hotspot outlines %s (F3)." % ("on" if outlines else "off"))


func _label(text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.text = text
    label.position = at
    label.size = area
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)
    return label


func _draw() -> void:
    if not placeholders: return
    draw_rect(Rect2(0, 0, 1280, 470), wall_color)
    draw_rect(Rect2(0, 470, 1280, 250), floor_color)
    draw_line(Vector2(0, 470), Vector2(1280, 470), wall_color.lightened(0.25), 3.0)
    _draw_placeholder()


# Extra placeholder shapes a room draws under its hotspots (only while it has no art).
func _draw_placeholder() -> void:
    pass
