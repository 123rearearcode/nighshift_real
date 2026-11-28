# VIEW (0.58.4): your backpack, the personal inventory. User, 27 November 2026: "the player can have a
# personal inventory (he can buy backpacks to upgrade)"; "Just carry, no gating". Opened from any room (the
# Backpack button or B). Pack things from the stock room or from under the counter; unpack them back.
# Click a packed item to pick it up, click a cell to put it down; R or right-click turns it; Esc cancels.
# The backpack is one more unit of the storage layout (scripts/storage/storage_model.gd, rules in
# scripts/rules/backpack.gd), saved with it. Presentation only: no part changes owner or becomes usable.
extends Control

signal closed

const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Backpack = preload("res://scripts/rules/backpack.gd")
const ItemArt = preload("res://scripts/view/item_art.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const UnderCounter = preload("res://scripts/rooms/under_counter_view.gd")

const CELL: int = 44
const PANEL := Rect2(50, 80, 1180, 560)
const GRID_AT := Vector2(80, 170)
const LIST_RECT := Rect2(720, 160, 480, 300)
# 0.59.2 (D186; user: "there should also be a way to carry 1 pc/thing in your arms"): beside the backpack, what
# you carry in your arms (one thing of any size), drawn small. Drag between them; Carry from the list.
const ARMS_BOX := Rect2(548, 170, 152, 152)
const ARMS_CELL: int = 19

var model := Model.new()
var store := Store.new()
var selected: String = ""
var pointer := Vector2.ZERO
var title: Label
var info: Label
var status: Label
var list_box: VBoxContainer
var unpack_button: Button
var counter_button: Button
var close_button: Button
var _art: Dictionary = {}


func open() -> void:
    name = "BackpackView"
    position = Vector2.ZERO
    size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 60
    model.setup(Sources.collect(GameState), store.read())
    var level: Dictionary = Backpack.level(GameState.upgrades)
    title = _label("YOUR BACKPACK · %s (%d x %d)" % [level["name"], model.backpack_size.x, model.backpack_size.y], PANEL.position + Vector2(24, 18), Vector2(800, 34), 22)
    info = _label("", Vector2(GRID_AT.x, GRID_AT.y + model.backpack_size.y * CELL + 16), Vector2(440, 90), 14)
    status = _label("Bigger backpacks are sold at the store down the street.", Vector2(PANEL.position.x + 24, PANEL.end.y - 40), Vector2(1100, 30), 14)
    _label("PACK SOMETHING (from the stock room or under the counter)", LIST_RECT.position - Vector2(0, 30), Vector2(LIST_RECT.size.x, 26), 15)
    var scroll := ScrollContainer.new()
    scroll.position = LIST_RECT.position
    scroll.size = LIST_RECT.size
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    list_box = VBoxContainer.new()
    scroll.add_child(list_box)
    _label("IN YOUR ARMS", ARMS_BOX.position - Vector2(0, 28), Vector2(ARMS_BOX.size.x + 20, 26), 15)
    unpack_button = _button("Unpack to the stock room", Rect2(LIST_RECT.position.x, LIST_RECT.end.y + 14, 234, 38), _unpack)
    counter_button = _button("Put it under the counter", Rect2(LIST_RECT.position.x + 246, LIST_RECT.end.y + 14, 234, 38), _to_counter)
    close_button = _button("Close the backpack", Rect2(PANEL.end.x - 250, PANEL.position.y + 14, 226, 36), func() -> void: closed.emit())
    close_button.name = "BackpackClose"
    _rebuild_list()
    _refresh()


func _label(text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var l := Label.new()
    l.text = text
    l.position = at
    l.size = area
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", Color("e8e2d0"))
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(l)
    return l


func _button(text: String, rect: Rect2, action: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.position = rect.position
    b.size = rect.size
    b.add_theme_font_size_override("font_size", 15)
    b.pressed.connect(action)
    add_child(b)
    return b


func packed() -> Array:
    return model.in_unit(Backpack.ID)


func carried() -> Array:
    return model.in_unit(Data.ARMS_ID)


func grid_rect() -> Rect2:
    return Rect2(GRID_AT, Vector2(model.backpack_size) * CELL)


func where(uid: String) -> String:
    var p: Dictionary = model.placements.get(uid, {})
    if p.is_empty(): return "waiting for space"
    return "under the counter" if p["unit"] == Data.COUNTER_ID else "stock room"


func _rebuild_list() -> void:
    for child: Node in list_box.get_children(): child.queue_free()
    var away: Array = model.items.keys().filter(func(uid: String) -> bool: return not uid in packed() and not uid in carried())
    away.sort()
    for uid: Variant in away:
        var item: Dictionary = model.items[uid]
        var line := HBoxContainer.new()
        var carry_button := Button.new()   # 0.59.2: anything, one at a time, in your arms
        carry_button.name = "Carry_" + str(uid)
        carry_button.text = "Carry"
        carry_button.custom_minimum_size = Vector2(70, 32)
        carry_button.disabled = store.read_only or not carried().is_empty()
        carry_button.pressed.connect(carry.bind(str(uid)))
        line.add_child(carry_button)
        var row := Button.new()
        row.name = "Pack_" + str(uid)
        row.alignment = HORIZONTAL_ALIGNMENT_LEFT
        row.custom_minimum_size = Vector2(LIST_RECT.size.x - 96, 32)
        row.add_theme_font_size_override("font_size", 14)
        var fits: bool = str(item["category"]) != "pc" or bool(item.get("stackable", false))   # a desktop is carried, not packed
        row.text = ("Pack: %s · %s  (%s)" if fits else "%s · %s  (%s): carry it") % [item["label"], item["model"], where(str(uid))]
        row.disabled = store.read_only or not fits
        row.pressed.connect(pack.bind(str(uid)))
        line.add_child(row)
        list_box.add_child(line)
    if away.is_empty():
        var none := Label.new()
        none.text = "Nothing else to pack."
        list_box.add_child(none)


func _refresh() -> void:
    var item: Dictionary = model.items.get(selected, {})
    var count: int = packed().size()
    info.text = ("%s · %s · %s" % [item["label"], item["model"], item["condition"]]) if not item.is_empty() else \
        ("%d thing%s in your backpack. Click one to pick it up or select it." % [count, "" if count == 1 else "s"]) if count > 0 else "Your backpack is empty."
    var mine: bool = (selected in packed() or selected in carried()) and model.held == "" and not store.read_only
    unpack_button.disabled = not mine
    counter_button.disabled = not mine
    queue_redraw()


func _save() -> bool:
    if store.write(model): return true
    status.text = store.status
    return false


func pack(uid: String) -> bool:
    if store.read_only or model.held != "": return false
    if not model.place_first(uid, Backpack.ID):
        status.text = "That does not fit in your backpack. Make room, or buy a bigger backpack at the store."
        return false
    selected = uid
    _save()
    status.text = "%s is in your backpack." % model.items[uid]["label"]
    call_deferred("_rebuild_list")
    _refresh()
    return true


# 0.59.2: take something in your arms (one thing at a time).
func carry(uid: String) -> bool:
    if store.read_only or model.held != "": return false
    var keep: Dictionary = model.placements.get(uid, {}).duplicate()
    model.placements.erase(uid)
    if not model.place_first(uid, Data.ARMS_ID):
        if not keep.is_empty(): model.placements[uid] = keep
        status.text = "Your arms are full: put down what you carry first."
        return false
    selected = uid
    _save()
    status.text = "You carry %s in your arms." % model.items[uid]["label"]
    call_deferred("_rebuild_list")
    _refresh()
    return true


func _unpack() -> void:
    if not (selected in packed() or selected in carried()) or not model.to_room(selected): return
    var label: String = str(model.items[selected]["label"])
    _save()
    status.text = "%s went back to the stock room%s." % [label, "" if model.placements.has(selected) else " (no shelf space there: it waits for space)"]
    selected = ""
    call_deferred("_rebuild_list")
    _refresh()


func _to_counter() -> void:
    if not (selected in packed() or selected in carried()): return
    var keep: Dictionary = model.placements[selected].duplicate()
    model.placements.erase(selected)
    if not model.place_first(selected, Data.COUNTER_ID):
        model.placements[selected] = keep
        status.text = "No room under the counter for that."
        return
    _save()
    status.text = "%s is under the counter now." % model.items[selected]["label"]
    selected = ""
    call_deferred("_rebuild_list")
    _refresh()


# ---- picking up and putting down inside the backpack ----

func item_rect(uid: String) -> Rect2:
    var p: Dictionary = model.placements.get(uid, {})
    if not p.is_empty() and p["unit"] == Data.ARMS_ID:
        return Rect2(ARMS_BOX.position + Vector2(p["cell"]) * ARMS_CELL, Vector2(Data.footprint(model.items[uid], p["rotation"])) * ARMS_CELL)
    if p.is_empty() or p["unit"] != Backpack.ID: return Rect2()
    return Rect2(GRID_AT + Vector2(p["cell"]) * CELL, Vector2(Data.footprint(model.items[uid], p["rotation"])) * CELL)


func _cell_under(at: Vector2) -> Vector2i:
    return Vector2i(((at - GRID_AT) / CELL).floor())


func press_at(at: Vector2) -> void:
    pointer = at
    if model.held != "":
        if grid_rect().has_point(at) and model.drop(Backpack.ID, 0, _cell_under(at)):
            _save()
            status.text = "Put down."
        elif ARMS_BOX.has_point(at) and model.drop(Data.ARMS_ID, 0, Vector2i.ZERO):
            _save()
            status.text = "In your arms."
        else:
            status.text = "It does not fit there."
        _refresh()
        return
    for uid: Variant in packed() + carried():
        if item_rect(str(uid)).has_point(at):
            selected = str(uid)
            model.begin(selected)
            _refresh()
            return
    selected = ""
    _refresh()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT: press_at(mb.position)
        elif mb.button_index == MOUSE_BUTTON_RIGHT and model.held != "": model.rotate(1)
        accept_event()
        queue_redraw()
    elif event is InputEventMouseMotion:
        pointer = (event as InputEventMouseMotion).position
        if model.held != "": queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key == null or not key.pressed or key.echo: return
    if key.keycode == KEY_R and model.held != "": model.rotate(1)
    elif key.keycode == KEY_ESCAPE:
        if model.held != "": model.cancel()
        else: closed.emit()
    else: return
    get_viewport().set_input_as_handled()
    _refresh()


func item_texture(uid: String, rotation: int) -> Texture2D:
    var item: Dictionary = model.items.get(uid, {})
    var art: String = UnderCounter.art_name(item) if not item.is_empty() else ""
    if art == "": return null
    var key: String = "%s_r%d" % [art, posmod(rotation, 4)]
    if not _art.has(key):
        var tex: Texture2D = ItemArt.storage(art, rotation)
        var cells: Vector2i = Data.footprint(item, rotation)
        if tex != null and not Vector2i(tex.get_size()) in [cells * CELL, cells * CELL / RoomArt.PIXEL_SCALE]: tex = null
        _art[key] = tex
    return _art[key]


func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
    draw_rect(PANEL, Color("1d2128"))
    draw_rect(PANEL, Color("111317"), false, 3.0)
    var g: Rect2 = grid_rect()
    draw_rect(g.grow(8), Color("5a4630"))       # placeholder canvas backpack (no art yet)
    draw_rect(g, Color("3d3024"))
    for x in range(model.backpack_size.x + 1): draw_line(g.position + Vector2(x * CELL, 0), g.position + Vector2(x * CELL, g.size.y), Color("7a6a55"), 1.0)
    for y in range(model.backpack_size.y + 1): draw_line(g.position + Vector2(0, y * CELL), g.position + Vector2(g.size.x, y * CELL), Color("7a6a55"), 1.0)
    var font: Font = ThemeDB.fallback_font
    for uid: Variant in packed():
        if str(uid) == model.held: continue
        var r: Rect2 = item_rect(str(uid))
        var item: Dictionary = model.items[uid]
        var tex: Texture2D = item_texture(str(uid), int(model.placements[uid]["rotation"]))
        if tex != null: draw_texture_rect(tex, r, false)
        else:
            var colour: Color = Data.COLOURS.get(str(item["kind"]), Color("8a9aa6"))
            draw_rect(r.grow(-2), colour.darkened(0.15))
            draw_string(font, r.position + Vector2(6, 18), str(item["label"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 10, 13, Color("101418"))
        if str(uid) == selected: draw_rect(r.grow(-1), Color("ffd27a"), false, 2.0)
    draw_rect(ARMS_BOX, Color("1f2a30"))   # 0.59.2: your arms
    draw_rect(ARMS_BOX, Color("6c8a98"), false, 2.0)
    if carried().is_empty(): draw_string(font, ARMS_BOX.position + Vector2(10, ARMS_BOX.size.y * 0.5 + 5), "empty", HORIZONTAL_ALIGNMENT_LEFT, ARMS_BOX.size.x - 20, 13, Color("6c7a80"))
    for uid: Variant in carried():
        if str(uid) == model.held: continue
        var r: Rect2 = item_rect(str(uid))
        var colour: Color = Data.COLOURS.get(str(model.items[uid]["kind"]), Color("8a9aa6"))
        draw_rect(r.grow(-1), colour.darkened(0.15))
        draw_string(font, r.position + Vector2(4, 14), str(model.items[uid]["label"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 6, 11, Color("101418"))
        if str(uid) == selected: draw_rect(r.grow(-1), Color("ffd27a"), false, 2.0)
    if model.held != "":
        var cells: Vector2i = Data.footprint(model.items[model.held], model.held_rotation)
        var cell: Vector2i = _cell_under(pointer)
        var ok: bool = g.has_point(pointer) and model.can_place(model.held, Backpack.ID, 0, cell, model.held_rotation)
        var ghost := Rect2(GRID_AT + Vector2(cell) * CELL, Vector2(cells) * CELL)
        var held_tex: Texture2D = item_texture(model.held, model.held_rotation)
        if held_tex != null: draw_texture_rect(held_tex, ghost, false, Color(1, 1, 1, 0.7))
        draw_rect(ghost, Color(0.4, 0.9, 0.5, 0.25) if ok else Color(0.95, 0.35, 0.35, 0.3))
        draw_rect(ghost, Color("6fcf97") if ok else Color("eb5757"), false, 2.0)
