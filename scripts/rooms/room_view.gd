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
    refresh()
    queue_redraw()


# For the room scripts.
func _room_ready() -> void:
    pass


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
