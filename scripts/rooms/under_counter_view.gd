# Under the counter (0.55.0, D162; user, 21 November 2026: storage slots under the counter window "where
# players can choose to keep stuff ... all of these [parts, tools, PCs] ... a 10x20 grid for now").
# One grid, 20 cells wide and 10 high, opened from the counter. Bring things here from the stock room,
# arrange them by dragging (R / Q / E rotate, Esc puts the held item back), send them back to the stock
# room. It is the same layout as the stock room (storage_model.gd, one save file), so nothing is copied:
# GameState still owns every part, tool and PC; this screen only says where it sits.
#
# Scam hook kept open (user: "yes to counter slots, the police will be a thing in this game"): this is
# where a customer's swapped-out part, or anything you would rather nobody saw, can be kept out of sight.
# A later police search can read what sits under the counter (`model.in_unit(Data.COUNTER_ID)`).
#
# 0.57.3 (ART-10, approved by the user 25 November 2026): items are drawn with their storage pictures
# (art/storage/<name>_r<turn>.png). Cells are 44 px, the size the pictures were made for: parts are
# illustrated at 1:1, PCs and tools are pixel art at exactly 2x. Anything without a matching picture
# (an NVMe drive, a future item) keeps the plain coloured box, so nothing ever disappears.
extends Node2D
const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Navigation = preload("res://scripts/night/night_navigation.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const CounterArt = preload("res://scripts/rooms/counter_art.gd")
const CELL: int = 44
const GRID := Rect2(40, 140, 880, 440)          # 20 x 10 cells
const LIST_RECT := Rect2(944, 140, 308, 440)
const PART_ART: Array = ["gpu", "ram", "cpu", "cooler", "psu"]

var model := Model.new()
var store := Store.new()
var pointer := Vector2.ZERO
var grab := Vector2.ZERO          # where on the held item the pointer took it (cells)
var selected: String = ""
var list_box: VBoxContainer
var info: Label
var status: Label
var send_button: Button
var _art: Dictionary = {}          # "<name>_r<turn>" -> Texture2D or null
var environment := CounterArt.new()


func _ready() -> void:
    if not GameState.job.get("hardware_trial", {}).get("night_session", {}).is_empty(): NightSession.ensure(GameState)
    model.setup(Sources.collect(GameState), store.read())
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _label("UNDER THE COUNTER", Vector2(210, 24), Vector2(760, 36), 26)
    Navigation.exit(self, "Counter", Navigation.COUNTER)
    _label("Keep anything close at hand: parts, tools, PCs. Drag to arrange; R, Q or E turns what you hold; Esc puts it back.", Vector2(40, 74), Vector2(1180, 30), 16)
    _label("IN THE STOCK ROOM · click to bring it here", LIST_RECT.position - Vector2(0, 30), Vector2(LIST_RECT.size.x, 26), 15)
    var scroll := ScrollContainer.new()
    scroll.position = LIST_RECT.position
    scroll.size = LIST_RECT.size
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.custom_minimum_size = Vector2(LIST_RECT.size.x - 16, 0)
    scroll.add_child(list_box)
    info = _label("", Vector2(40, 592), Vector2(620, 60), 15)
    send_button = Button.new()
    send_button.name = "SendToStockRoom"
    send_button.text = "Back to the stock room"
    send_button.position = Vector2(680, 596)
    send_button.size = Vector2(240, 40)
    send_button.pressed.connect(_send)
    add_child(send_button)
    status = _label(store.status, Vector2(40, 660), Vector2(1200, 50), 16)
    _rebuild_list()
    _refresh()


func _label(text: String, at: Vector2, area: Vector2, size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    add_child(label)
    return label


func here() -> Array:
    return model.in_unit(Data.COUNTER_ID)


# The rows are rebuilt only from here (never inside a row button's own signal: _bring defers it).
func _rebuild_list() -> void:
    for child: Node in list_box.get_children(): child.queue_free()
    var away: Array = model.items.keys().filter(func(uid: String) -> bool: return not uid in here())
    away.sort()
    for uid: Variant in away:
        var item: Dictionary = model.items[uid]
        var row := Button.new()
        row.alignment = HORIZONTAL_ALIGNMENT_LEFT
        row.custom_minimum_size = Vector2(LIST_RECT.size.x - 24, 34)
        row.add_theme_font_size_override("font_size", 14)
        row.text = "%s · %s%s" % [item["label"], item["model"], "" if model.placements.has(uid) else "  (waiting for space)"]
        row.disabled = store.read_only
        row.pressed.connect(_bring.bind(str(uid)))
        list_box.add_child(row)
    if away.is_empty():
        var none := Label.new()
        none.text = "Everything you have is already under the counter."
        list_box.add_child(none)


func _refresh() -> void:
    var item: Dictionary = model.items.get(selected, {})
    info.text = ("%s · %s\n%s · %s" % [item["label"], item["model"], item["owner"], item["condition"]]) if not item.is_empty() else "%d thing%s under the counter. Click one to select it." % [here().size(), "" if here().size() == 1 else "s"]
    send_button.disabled = store.read_only or not selected in here() or model.held != ""
    queue_redraw()


func _save() -> void:
    if store.write(model): status.text = "Saved."
    else: status.text = store.status


func _bring(uid: String) -> void:
    if store.read_only or model.held != "": return
    if model.place_first(uid, Data.COUNTER_ID):
        selected = uid
        _save()
        status.text = "%s is under the counter now." % model.items[uid]["label"]
    else:
        status.text = "No room for that under the counter: move something or send it back first."
    call_deferred("_rebuild_list")
    _refresh()


func _send() -> void:
    if selected == "" or not model.to_room(selected): return
    var label: String = str(model.items[selected]["label"])
    _save()
    status.text = "%s went back to the stock room%s." % [label, "" if model.placements.has(selected) else " (no shelf space there: it waits for space)"]
    selected = ""
    call_deferred("_rebuild_list")
    _refresh()


func item_rect(uid: String) -> Rect2:
    var p: Dictionary = model.placements.get(uid, {})
    if p.is_empty() or p["unit"] != Data.COUNTER_ID: return Rect2()
    return Rect2(GRID.position + Vector2(p["cell"]) * CELL, Vector2(Data.footprint(model.items[uid], p["rotation"])) * CELL)


# Which storage picture an item uses ("" = none: draw the plain box).
static func art_name(item: Dictionary) -> String:
    var kind: String = str(item.get("kind", ""))
    match str(item.get("category", "")):
        "pc": return "pc_compact" if item.get("size", Vector2i.ZERO) == Vector2i(7, 5) else "pc_tower"
        "tool": return kind if kind in Data.TOOL_SIZES else ""
        "part":
            if kind in PART_ART: return kind
            if kind == "storage":
                var model_name: String = str(item.get("model", "")).to_upper()
                if "HDD" in model_name: return "storage_hdd"
                if "SSD" in model_name: return "storage_ssd"
    return ""


# The picture for an item at a quarter turn, only when it exactly fits the item's footprint (1:1 for
# illustrated parts, 2x for pixel art); otherwise null and the box is drawn.
func item_texture(uid: String, rotation: int) -> Texture2D:
    var item: Dictionary = model.items.get(uid, {})
    var name: String = art_name(item) if not item.is_empty() else ""
    if name == "": return null
    var key: String = "%s_r%d" % [name, posmod(rotation, 4)]
    if not _art.has(key):
        var tex: Texture2D = RoomArt.storage_item(name, rotation)
        var cells: Vector2i = Data.footprint(item, rotation)
        if tex != null and not Vector2i(tex.get_size()) in [cells * CELL, cells * CELL / RoomArt.PIXEL_SCALE]: tex = null
        _art[key] = tex
    return _art[key]


func _hit(at: Vector2) -> String:
    for uid: Variant in here():
        if item_rect(str(uid)).has_point(at): return str(uid)
    return ""


func _cell_under(at: Vector2) -> Vector2i:
    return Vector2i(((at - GRID.position) / CELL - grab + Vector2(0.5, 0.5)).floor())


func _navigate(path: String) -> bool:
    if model.held != "": model.cancel()
    if not GameState.job.get("hardware_trial", {}).get("night_session", {}).is_empty() and not NightSession.checkpoint(GameState):
        status.text = NightSession.status
        return false
    return Navigation.commit(self, path)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        pointer = event.position
        if model.held != "": queue_redraw()
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE and model.held != "":
            model.cancel()
            _refresh()
        elif model.held != "" and event.keycode in [KEY_R, KEY_Q, KEY_E]:
            model.rotate(-1 if event.keycode == KEY_Q else 1)
            grab = Vector2(grab.y, grab.x)
            queue_redraw()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        pointer = event.position
        if store.read_only: return
        if event.pressed and GRID.has_point(pointer) and model.held == "":
            var uid: String = _hit(pointer)
            selected = uid
            if uid != "" and model.begin(uid):
                grab = ((pointer - item_rect(uid).position) / CELL).floor()
                AudioFeedback.request(self, "handling.pickup")
            _refresh()
        elif not event.pressed and model.held != "":
            var moved: String = model.held
            if GRID.has_point(pointer) and model.drop(Data.COUNTER_ID, 0, _cell_under(pointer)):
                selected = moved
                _save()
            else:
                model.cancel()
            _refresh()


func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("151e27"))
    if environment.available(): environment.draw_storage(self, GRID)
    else: draw_rect(GRID.grow(6), Color("3d3229"))
    for x in range(Data.COUNTER["size"].x + 1):
        draw_line(GRID.position + Vector2(x * CELL, 0), GRID.position + Vector2(x * CELL, GRID.size.y), Color("597175"), 1.0)
    for y in range(Data.COUNTER["size"].y + 1):
        draw_line(GRID.position + Vector2(0, y * CELL), GRID.position + Vector2(GRID.size.x, y * CELL), Color("597175"), 1.0)
    var font: Font = ThemeDB.fallback_font
    for uid: Variant in here():
        if str(uid) == model.held: continue
        var r: Rect2 = item_rect(str(uid))
        var item: Dictionary = model.items[uid]
        var tex: Texture2D = item_texture(str(uid), int(model.placements[uid]["rotation"]))
        if tex != null:
            draw_texture_rect(tex, r, false)
            if str(uid) == selected: draw_rect(r.grow(-1), Color("ffd27a"), false, 2.0)
            continue
        var colour: Color = Data.COLOURS.get(str(item["kind"]), Color("8a9aa6"))
        draw_rect(r.grow(-2), colour.darkened(0.15))
        draw_rect(r.grow(-2), Color("ffd27a") if str(uid) == selected else colour.lightened(0.3), false, 2.0)
        draw_string(font, r.position + Vector2(6, 18), str(item["label"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 13, Color("101418"))
    if model.held != "":
        var size := Vector2(Data.footprint(model.items[model.held], model.held_rotation)) * CELL
        var cell: Vector2i = _cell_under(pointer)
        var ok: bool = GRID.has_point(pointer) and model.can_place(model.held, Data.COUNTER_ID, 0, cell, model.held_rotation)
        var ghost := Rect2(GRID.position + Vector2(cell) * CELL, size)
        var held_tex: Texture2D = item_texture(model.held, model.held_rotation)
        if held_tex != null: draw_texture_rect(held_tex, ghost, false, Color(1, 1, 1, 0.7))
        draw_rect(ghost, Color(0.4, 0.9, 0.5, 0.25) if ok else Color(0.95, 0.35, 0.35, 0.3))
        draw_rect(ghost, Color("6fcf97") if ok else Color("eb5757"), false, 2.0)
    if environment.available():
        environment.draw_storage(self, GRID, true)
        # Live controls stay on a readable backing, outside all 200 usable cells.
        draw_rect(Rect2(0, 0, 1280, 110), Color("13232b"))
        draw_rect(Rect2(934, 110, 346, 478), Color("13232b"))
        draw_rect(Rect2(0, 588, 1280, 132), Color("13232b"))
