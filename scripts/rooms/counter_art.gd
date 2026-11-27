# Approved Batch A revision 02 (0.57.5). Original PNG bytes and human approval are recorded in
# art/rooms/counter_batch_a/manifest.json. This is presentation only: no clock, inventory or PC state.
# Source art is mapped at draw time; it has not been repainted onto a different native pixel grid.
# 0.57.9: the same approved pixels laid out on a flat front wall (see draw_room).
# 0.58.5 (D174): the approved termopan set (art/rooms/counter_termopan/, manifest with hashes) replaces the
# doors, shutter and frame, and adds the radiator and the linoleum floor, when all of it is present.
extends RefCounted

const RoomArt = preload("res://scripts/rooms/room_art.gd")
const WallFinishes = preload("res://scripts/data/wall_finishes.gd")   # 0.58.9 (D180)
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

# 0.57.9 flat front wall (user's sketch, 26 November 2026). Screen positions; FLOOR_Y is the shell's floor line.
const FLOOR_Y: float = 505.0
const GLASS := Rect2(52, 106, 552, 399)             # door + shop window, from the top rail to the floor
const DOOR := Rect2(52, 106, 161, 399)              # the approved glass door, its own frame on the left
const FRAME_W: float = 18.0
const DOOR_STILE := Rect2(242, 450, 60, 650)        # a hinge-free stretch of the door's left stile (source px)
const DOOR_RAIL := Rect2(330, 107, 300, 64)         # a stretch of the door's top rail (source px)
const SHUTTER := Rect2(44, 56, 568, 50)             # the shutter box, flat over the whole glass
const SHUTTER_BAND := Vector2(291, 698)             # ten whole slats of the down shutter (source y)
const SIGN := Rect2(390, 128, 60, 122)
const TILE_STRIP := Rect2(606, 0, 169, 941)         # five whole tiles of the shell's flat wall (source px)
const TILE_ROWS: Array = [28, 62, 95, 128, 161, 193, 226, 257, 288, 319, 349, 381, 412, 445, 478, 511, 544, 577, 610]
const TILE_SHIFTS: Array = [0, 6, 13, 3, 9]         # row index each strip starts its tiles from

# 0.58.5: the termopan set (user, 27 November 2026: "aight go on with the PVC"). Full-canvas layers.
const TERMOPAN_README := "res://art/rooms/counter_termopan/README.md"
const TERMOPAN_FILES := {
    "floor": "floor-linoleum.png", "radiator": "radiator.png", "frame": "termopan-front-frame.png",
    "door_closed": "termopan-front-door-closed.png", "door_open": "termopan-front-door-open.png",
    "ws_closed": "termopan-workshop-closed.png", "ws_open": "termopan-workshop-open.png",
    "box_up": "pvc-shutter-up.png", "box_down": "pvc-shutter-down.png",
}
const WINDOW := Rect2(213, 106, 391, 304)           # the termopan shop window, down to its sill (screen px)

var textures: Dictionary = {}
var termopan: Dictionary = {}
# 0.58.9 (D180): the wall finish the shop has up (data/wall_finishes.gd). The counter room sets it from the save.
var wall_finish: String = WallFinishes.DEFAULT
var wall_pictures: Dictionary = {}


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
    for key: String in TERMOPAN_FILES:
        termopan[key] = RoomArt.texture(TERMOPAN_README.get_base_dir() + "/" + str(TERMOPAN_FILES[key]))


# 0.58.5: the whole termopan set is installed (otherwise the 0.57.9 flat layout of Batch A is drawn).
# The approved picture of a wall finish ({} for the teal tiles, which are the shell's own wall).
func wall_picture(id: String) -> Texture2D:
    if not wall_pictures.has(id): wall_pictures[id] = RoomArt.texture(WallFinishes.path(id))
    return wall_pictures[id]


func termopan_ready() -> bool:
    for key: String in TERMOPAN_FILES:
        if termopan.get(key) == null: return false
    return true


func _layer(canvas: CanvasItem, tex: Texture2D) -> void:
    if tex != null: canvas.draw_texture_rect(tex, Rect2(Vector2.ZERO, Vector2(tex.get_size()) * SCREEN / SOURCE), false)


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
    _full(canvas, "shell")
    # 0.57.9 (user, 26 November 2026, approving the layout from their sketch: "the design of the layout looks
    # good. we will push this as a change to the layout of things, with the existing current assets"): the
    # front wall faces the player flat. The shell's painted corner glazing is covered by its own flat tiles,
    # and the glass door, shop window, shutter and street all sit flat on that wall. Existing pixels only.
    _flat_wall(canvas)
    if termopan_ready():
        _draw_termopan(canvas, morning, front_open, workshop_open, shutter_down)
        return
    var outside: Texture2D = textures.get("morning" if morning else "dusk")
    # The street at eye level (0.57.8 mapping kept): source = (280, 302) + screen position * 1.032.
    if outside != null:
        canvas.draw_texture_rect_region(outside, GLASS, Rect2(Vector2(280, 302) + GLASS.position * 1.032, GLASS.size * 1.032))
    _glass_frame(canvas)
    if front_open:
        var closed: Rect2 = CROPS["front_closed"]
        var opened: Rect2 = CROPS["front_open"]
        var leaf: Vector2 = opened.size * (DOOR.size.y / closed.size.y)
        _sprite(canvas, "front_open", Rect2(DOOR.position.x, DOOR.position.y - (leaf.y - DOOR.size.y) * 0.5, leaf.x, leaf.y))
    else:
        _sprite(canvas, "front_closed", DOOR)
    _sprite(canvas, "sign", SIGN)
    # 0.57.8 (user: "the door to the workshop is slightly off"): the leaf fills the painted doorway
    # (1062..1248 x 118..490) with its hinge side on the frame, closed and open alike.
    _sprite(canvas, "workshop_open" if workshop_open else "workshop_closed",
        Rect2(1109, 100, 139, 395) if workshop_open else Rect2(1062, 118, 186, 372))
    if shutter_down: _shutter_down(canvas)
    else: _sprite(canvas, "shutter_up", SHUTTER)


# 0.58.5 (D174): white PVC termopan, clear glass, a radiator under the window, a linoleum floor. The same flat
# layout (D171); the window now stops at its sill so the radiator fits under it. The street keeps the 0.57.8
# eye-level mapping, seen through the door and the window.
func _draw_termopan(canvas: CanvasItem, morning: bool, front_open: bool, workshop_open: bool, shutter_down: bool) -> void:
    var wall: Texture2D = wall_picture(wall_finish)
    if wall != null: canvas.draw_texture_rect(wall, Rect2(Vector2.ZERO, wall.get_size()), false)   # 1:1 over the flat tiles; the lamp, pipe and doorway are holes in it
    _layer(canvas, termopan["floor"])
    var outside: Texture2D = textures.get("morning" if morning else "dusk")
    if outside != null:
        for glass: Rect2 in [DOOR, WINDOW]:
            canvas.draw_texture_rect_region(outside, glass, Rect2(Vector2(280, 302) + glass.position * 1.032, glass.size * 1.032))
    _layer(canvas, termopan["radiator"])
    _layer(canvas, termopan["frame"])
    _layer(canvas, termopan["door_open" if front_open else "door_closed"])
    _sprite(canvas, "sign", Rect2(400, 128, 60, 122))
    _layer(canvas, termopan["ws_open" if workshop_open else "ws_closed"])
    _layer(canvas, termopan["box_down" if shutter_down else "box_up"])


# The shell's own flat wall (5 whole tiles, source x 606..775), repeated leftwards over the painted corner.
# Each strip moves its tile rows round by a whole number of rows so stains do not line up; the grimy last row
# and the floor stay in place, so the floor line stays level at FLOOR_Y.
func _flat_wall(canvas: CanvasItem) -> void:
    var tex: Texture2D = textures.get("shell")
    if tex == null: return
    var k: Vector2 = SCREEN / SOURCE
    var w: float = TILE_STRIP.size.x * k.x
    var top: float = float(TILE_ROWS[0])
    var body_end: float = float(TILE_ROWS[TILE_ROWS.size() - 1])
    var i: int = 0
    var x: float = TILE_STRIP.position.x * k.x - w
    while x > -w:
        var cut: float = float(TILE_ROWS[int(TILE_SHIFTS[i % TILE_SHIFTS.size()])])
        var pieces: Array = [Vector2(0, top), Vector2(cut, body_end), Vector2(top, cut), Vector2(body_end, SOURCE.y)]
        var y: float = 0.0
        for p: Vector2 in pieces:
            if p.y <= p.x: continue
            var h: float = (p.y - p.x) * k.y
            canvas.draw_texture_rect_region(tex, Rect2(x, y, w + 0.5, h + 0.5), Rect2(TILE_STRIP.position.x, p.x, TILE_STRIP.size.x, p.y - p.x))
            y += h
        x -= w
        i += 1


# Jambs, the mullion beside the door and the top rail: stretches of the approved door's own frame.
func _glass_frame(canvas: CanvasItem) -> void:
    var tex: Texture2D = textures.get("front_closed")
    if tex == null: return
    for x: float in [GLASS.position.x, DOOR.end.x - FRAME_W, GLASS.end.x - FRAME_W]:
        canvas.draw_texture_rect_region(tex, Rect2(x, GLASS.position.y, FRAME_W, GLASS.size.y), DOOR_STILE)
    canvas.draw_texture_rect_region(tex, Rect2(GLASS.position, Vector2(GLASS.size.x, FRAME_W + 1)), DOOR_RAIL)


# The down shutter over the whole glass: its box and first slats, whole slat bands repeated, its bottom bar
# on the floor line. Same horizontal scale throughout, so the slats keep their shape.
func _shutter_down(canvas: CanvasItem) -> void:
    var tex: Texture2D = textures.get("shutter_down")
    if tex == null: return
    var crop: Rect2 = CROPS["shutter_down"]
    var s: float = SHUTTER.size.x / crop.size.x
    var head: float = SHUTTER_BAND.x - crop.position.y
    var tail: float = crop.end.y - SHUTTER_BAND.y
    var y: float = SHUTTER.position.y
    canvas.draw_texture_rect_region(tex, Rect2(SHUTTER.position.x, y, SHUTTER.size.x, head * s), Rect2(crop.position.x, crop.position.y, crop.size.x, head))
    y += head * s
    var end: float = FLOOR_Y - tail * s
    while y < end - 0.5:
        var h: float = minf((SHUTTER_BAND.y - SHUTTER_BAND.x) * s, end - y)
        canvas.draw_texture_rect_region(tex, Rect2(SHUTTER.position.x, y, SHUTTER.size.x, h + 0.5), Rect2(crop.position.x, SHUTTER_BAND.x, crop.size.x, h / s))
        y += h
    canvas.draw_texture_rect_region(tex, Rect2(SHUTTER.position.x, end, SHUTTER.size.x, tail * s), Rect2(crop.position.x, SHUTTER_BAND.y, crop.size.x, tail))


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
