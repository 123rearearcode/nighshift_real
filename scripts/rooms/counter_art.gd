# Approved Batch A revision 02 (0.57.5). Original PNG bytes and human approval are recorded in
# art/rooms/counter_batch_a/manifest.json. This is presentation only: no clock, inventory or PC state.
# Source art is mapped at draw time; it has not been repainted onto a different native pixel grid.
extends RefCounted

const RoomArt = preload("res://scripts/rooms/room_art.gd")
const README := "res://art/rooms/counter_batch_a/README.md"
const SOURCE := Vector2(1672, 941)
const SCREEN := Vector2(1280, 720)
const COUNTER_TOP_Y: float = 488.0
const CUSTOMER_PC_BASE := Vector2(1030, 550)
const STORAGE_INNER := Rect2(120, 276, 1420, 500)
const FILES := {
    "shell": "room-shell-v2.png", "counter": "counter-foreground-v2.png",
    "dusk": "exterior-dusk-v2.png", "morning": "exterior-morning-v2.png",
    "front_closed": "front-door-closed-v2.png", "front_open": "front-door-open-v2.png",
    "sign": "hanging-sign-v2.png", "workshop_closed": "workshop-door-closed-v2.png",
    "workshop_open": "workshop-door-open-v2.png", "shutter_up": "shutter-up-v2.png",
    "shutter_down": "shutter-down-v2.png", "storage": "storage-interior-v2.png",
    "rim": "storage-rim-v2.png", "light": "light-overlay-v2.png"
}
# Visible source bounds, not a raster edit. Paired door states share the same screen hinge side.
const CROPS := {
    "front_closed": Rect2(242, 108, 540, 1325), "front_open": Rect2(298, 84, 419, 1409),
    "workshop_closed": Rect2(225, 114, 579, 1308), "workshop_open": Rect2(246, 20, 536, 1494),
    "shutter_up": Rect2(82, 87, 1611, 142), "shutter_down": Rect2(82, 87, 1610, 717),
    "sign": Rect2(269, 249, 486, 984)
}

var textures: Dictionary = {}


class Layer extends Node2D:
    var art: Variant
    var foreground: bool = false
    var morning: bool = false
    var front_open: bool = false
    var workshop_open: bool = false
    var shutter_down: bool = false

    func _ready() -> void:
        texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    func _draw() -> void:
        if art == null or not art.available(): return
        if foreground: art.draw_counter(self, morning)
        else: art.draw_room(self, morning, front_open, workshop_open, shutter_down)


func _init() -> void:
    for key: String in FILES:
        textures[key] = RoomArt.texture(folder() + str(FILES[key]))


static func folder() -> String:
    return README.get_base_dir() + "/"


func available() -> bool:
    for key: String in FILES:
        if textures.get(key) == null: return false
    return true


func _full(canvas: CanvasItem, key: String, tint: Color = Color.WHITE) -> void:
    var tex: Texture2D = textures.get(key)
    if tex == null: return
    canvas.draw_texture_rect(tex, Rect2(Vector2.ZERO, Vector2(tex.get_size()) * SCREEN / SOURCE), false, tint)


func _sprite(canvas: CanvasItem, key: String, destination: Rect2) -> void:
    var tex: Texture2D = textures.get(key)
    if tex != null: canvas.draw_texture_rect_region(tex, destination, CROPS[key])


func draw_room(canvas: CanvasItem, morning: bool, front_open: bool, workshop_open: bool, shutter_down: bool) -> void:
    canvas.draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("15232b"))
    # Exterior is limited to the left glazing. The room's genuine alpha holes reveal it.
    var outside: Texture2D = textures.get("morning" if morning else "dusk")
    var glazing := Rect2(0, 0, 464, 610)
    # 0.57.7 (user, 25 November 2026: the outside should be at street level): frame the street at eye level:
    # the far pavement meets the room's floor line, with the parked cars, road and ground-floor shops behind.
    var sample := Rect2(Vector2(280, 302), glazing.size * 1.032)
    if outside != null: canvas.draw_texture_rect_region(outside, glazing, sample)
    _full(canvas, "shell")
    _sprite(canvas, "front_open" if front_open else "front_closed", Rect2(60, 115, 132 if front_open else 172, 450))
    _sprite(canvas, "sign", Rect2(262, 128, 60, 122))
    # 0.57.7 (user: "the door to the workshop is slightly off"): the leaf now fills the painted doorway
    # (1062..1248 x 118..490) with its hinge side on the frame, closed and open alike.
    _sprite(canvas, "workshop_open" if workshop_open else "workshop_closed",
        Rect2(1109, 100, 139, 395) if workshop_open else Rect2(1062, 118, 186, 372))
    _sprite(canvas, "shutter_down" if shutter_down else "shutter_up",
        Rect2(48, 58, 416, 530) if shutter_down else Rect2(48, 58, 416, 37))


func draw_counter(canvas: CanvasItem, morning: bool) -> void:
    _full(canvas, "counter")
    if not morning: _full(canvas, "light", Color(1, 1, 1, 0.25))


# Keep the existing 44-pixel square grid and Batch B item scale. Only the decorative art is mapped
# around it; every usable source pixel in STORAGE_INNER is clear in the foreground rim.
static func storage_rect(tex: Texture2D, grid: Rect2) -> Rect2:
    var scale: Vector2 = grid.size / STORAGE_INNER.size
    return Rect2(grid.position - STORAGE_INNER.position * scale, Vector2(tex.get_size()) * scale)


func draw_storage(canvas: CanvasItem, grid: Rect2, foreground: bool = false) -> void:
    var tex: Texture2D = textures.get("rim" if foreground else "storage")
    if tex != null: canvas.draw_texture_rect(tex, storage_rect(tex, grid), false)
