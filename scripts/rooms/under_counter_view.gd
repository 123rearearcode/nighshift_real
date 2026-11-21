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
extends Node2D
const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Navigation = preload("res://scripts/night/night_navigation.gd")
const CELL: int = 30
const GRID := Rect2(40, 140, 600, 300)          # 20 x 10 cells
const LIST_RECT := Rect2(680, 140, 572, 380)

var model := Model.new()
var store := Store.new()
var pointer := Vector2.ZERO
var grab := Vector2.ZERO          # where on the held item the pointer took it (cells)
var selected: String = ""
var list_box: VBoxContainer
var info: Label
var status: Label
var send_button: Button


func _ready() -> void:
    if not GameState.job.get("hardware_trial", {}).get("night_session", {}).is_empty(): NightSession.ensure(GameState)
    model.setup(Sources.collect(GameState), store.read())
    _label("UNDER THE COUNTER", Vector2(210, 24), Vector2(760, 36), 26)
    Navigation.exit(self, "Counter", Navigation.COUNTER)
    _label("Keep anything close at hand: parts, tools, PCs. Drag to arrange; R, Q or E turns what you hold; Esc puts it back.", Vector2(40, 84), Vector2(1180, 44), 16)
    _label("IN THE STOCK ROOM · click to bring it here", LIST_RECT.position - Vector2(0, 30), Vector2(LIST_RECT.size.x, 26), 15)
    var scroll := ScrollContainer.new()
    scroll.position = LIST_RECT.position
    scroll.size = LIST_RECT.size
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.custom_minimum_size = Vector2(LIST_RECT.size.x - 16, 0)
    scroll.add_child(list_box)
    info = _label("", Vector2(40, 452), Vector2(600, 70), 15)
    send_button = Button.new()
    send_button.name = "SendToStockRoom"
    send_button.text = "Back to the stock room"
    send_button.position = Vector2(40, 530)
    send_button.size = Vector2(260, 40)
    send_button.pressed.connect(_send)
    add_child(send_button)
    status = _label(store.status, Vector2(40, 610), Vector2(1200, 50), 16)
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
    draw_rect(GRID.grow(6), Color("3d3229"))
    for x in range(Data.COUNTER["size"].x + 1):
        draw_line(GRID.position + Vector2(x * CELL, 0), GRID.position + Vector2(x * CELL, GRID.size.y), Color("2a2218"), 1.0)
    for y in range(Data.COUNTER["size"].y + 1):
        draw_line(GRID.position + Vector2(0, y * CELL), GRID.position + Vector2(GRID.size.x, y * CELL), Color("2a2218"), 1.0)
    var font: Font = ThemeDB.fallback_font
    for uid: Variant in here():
        if str(uid) == model.held: continue
        var r: Rect2 = item_rect(str(uid))
        var item: Dictionary = model.items[uid]
        var colour: Color = Data.COLOURS.get(str(item["kind"]), Color("8a9aa6"))
        draw_rect(r.grow(-2), colour.darkened(0.15))
        draw_rect(r.grow(-2), Color("ffd27a") if str(uid) == selected else colour.lightened(0.3), false, 2.0)
        draw_string(font, r.position + Vector2(6, 18), str(item["label"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 13, Color("101418"))
    if model.held != "":
        var size := Vector2(Data.footprint(model.items[model.held], model.held_rotation)) * CELL
        var cell: Vector2i = _cell_under(pointer)
        var ok: bool = GRID.has_point(pointer) and model.can_place(model.held, Data.COUNTER_ID, 0, cell, model.held_rotation)
        var ghost := Rect2(GRID.position + Vector2(cell) * CELL, size)
        draw_rect(ghost, Color(0.4, 0.9, 0.5, 0.35) if ok else Color(0.95, 0.35, 0.35, 0.35))
        draw_rect(ghost, Color("6fcf97") if ok else Color("eb5757"), false, 2.0)
