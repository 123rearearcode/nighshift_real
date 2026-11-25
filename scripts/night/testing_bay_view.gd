# Activities > Testing bay (session 3.6 / 0.50.0, D158). The shop's own stock parts: look closely at a
# part's spots (physical inspection), run a quick or long test on the rig, then make your own call:
# mark it working, degraded or dead, or sell it for scrap. Everything costs night time except the
# sticker and the scrap sale. The screen shows only what the shop knows (PART_LIFECYCLE invariant 7):
# the real condition is never displayed, and the label is the player's call, not a verdict.
# 0.56.0 (D162): spots are looked at with the MAGNIFYING GLASS: pick it up, hold it over a spot on the part
# and it takes a close look (one night minute). The lens is placeholder drawing until the parts have art;
# which faults need it is per spot (PartCondition.needs_lens; the user: "there will be multiple types").
extends "res://scripts/night/night_screen.gd"
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const ItemArt = preload("res://scripts/view/item_art.gd")   # 0.57.7: approved inspection pictures and clues

const LIST_RECT := Rect2(32, 132, 360, 500)
const PART_RECT := Rect2(420, 132, 450, 300)
const CARD_RECT := Rect2(896, 132, 352, 300)
const SPOT_AT: Array = [Vector2(0.18, 0.22), Vector2(0.72, 0.2), Vector2(0.46, 0.55), Vector2(0.16, 0.78), Vector2(0.76, 0.78)]
const KIND_COLOURS: Dictionary = {"gpu": Color("8a6fc0"), "ram": Color("5aa77c"), "cpu": Color("b9a27a"), "psu": Color("c99a52"), "cooler": Color("7f93a8"), "storage": Color("5f9db5")}

var selected: String = ""
var cash_label: Label
var list_box: VBoxContainer
var list_buttons: Dictionary = {}
const LENS_RADIUS: float = 58.0
const LENS_DWELL: float = 0.6        # seconds the lens rests on a spot before you have had a close look
const SPOT_REACH: float = 26.0       # how near the lens centre must be to a spot
var lens_button: Button
var lens_held: bool = false
var lens_at := Vector2.ZERO
var dwell_spot: int = -1
var dwell: float = 0.0
var card_text: Label
var quick_button: Button
var long_button: Button
var label_buttons: Dictionary = {}
var scrap_button: Button
var empty_label: Label


func _ready() -> void:
    NightSession.ensure(GameState)
    _label("TESTING BAY / YOUR STOCK", Vector2(210, 24), Vector2(760, 38), 28)
    Navigation.exit(self, "Workshop", Navigation.WORKSHOP)   # 0.53.0: a corner of the workshop
    cash_label = _label("", Vector2(32, 80), Vector2(1216, 44), 16)
    var scroll := ScrollContainer.new()
    scroll.position = LIST_RECT.position
    scroll.size = LIST_RECT.size
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.custom_minimum_size = Vector2(LIST_RECT.size.x - 16, 0)
    scroll.add_child(list_box)
    empty_label = _label("No stock part selected. Parts from salvage, customers' old parts and your own stock appear on the left.", PART_RECT.position + Vector2(20, 120), Vector2(PART_RECT.size.x - 40, 80), 16)
    card_text = _label("", CARD_RECT.position + Vector2(12, 10), CARD_RECT.size - Vector2(24, 20), 14)
    card_text.clip_text = true
    quick_button = _action_button("", Rect2(420, 448, 220, 46), _test.bind(false))
    long_button = _action_button("", Rect2(650, 448, 220, 46), _test.bind(true))
    var x: float = 896
    for label: String in PartCondition.PLAYER_LABELS:
        label_buttons[label] = _action_button("Mark " + label, Rect2(x, 448, 112, 46), _mark.bind(label))
        x += 120
    scrap_button = _action_button("", Rect2(896, 504, 352, 40), _scrap)
    lens_button = _action_button("", Rect2(420, 504, 450, 40), _toggle_lens)
    lens_button.name = "MagnifierButton"
    _label("Pick up the magnifying glass and hold it over a spot on the part for a close look (1 night minute each; Esc or right-click puts it down). The quick test finds dead parts and steady faults; some faults only show in the long test. Your mark is your own call.", Vector2(420, 560), Vector2(828, 70), 15)
    message = _label(NightSession.status, Vector2(32, 646), Vector2(1216, 50), 16)
    _rebuild_list()
    _refresh()


func _action_button(text: String, rect: Rect2, action: Callable) -> Button:
    var b := _button(text, rect, "")
    b.add_theme_font_size_override("font_size", 15)
    b.pressed.connect(action)
    return b


func _record() -> Dictionary:
    return GameState.stock_record(selected) if selected != "" else {}


func _model_name(record: Dictionary) -> String:
    if str(record.get("tier", "")) == "model": return str(Catalog.part(str(record.get("model", ""))).get("name", record.get("model", "")))
    var option: Dictionary = ServiceParts.option(str(record.get("kind", "")), str(record.get("tier", "")))
    return str(option.get("label", str(record.get("kind", "")).to_upper()))


func _kind(record: Dictionary) -> String:
    return str(record.get("kind", ""))


# The list is rebuilt only when parts come or go (never during a button's own signal).
func _rebuild_list() -> void:
    for child: Node in list_box.get_children(): child.queue_free()
    list_buttons.clear()
    var uids: Array = GameState.bay_parts()
    if not selected in uids: selected = "" if uids.is_empty() else str(uids[0])
    for uid: Variant in uids:
        var b := Button.new()
        b.toggle_mode = true
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.add_theme_font_size_override("font_size", 14)
        b.custom_minimum_size = Vector2(LIST_RECT.size.x - 20, 34)
        b.pressed.connect(_select.bind(str(uid)))
        list_box.add_child(b)
        list_buttons[str(uid)] = b


func _select(uid: String) -> void:
    selected = uid
    _refresh()


func _refresh() -> void:
    cash_label.text = "Night %d · %s · shop cash $%d · %d stock part%s on the bay · look 1 min · quick test %d min · long test %d min" % [
        GameState.night_number, NightClock.label(GameState.night_minutes), GameState.money, list_buttons.size(), "" if list_buttons.size() == 1 else "s",
        PartCondition.QUICK_MINUTES, PartCondition.LONG_MINUTES]
    for uid: String in list_buttons:
        var r: Dictionary = GameState.stock_record(uid)
        list_buttons[uid].text = "%s · %s" % [_model_name(r), PartCondition.label_text(r)]
        list_buttons[uid].set_pressed_no_signal(uid == selected)
    var record: Dictionary = _record()
    var has: bool = not record.is_empty()
    var over: bool = NightClock.over(GameState.night_minutes)
    empty_label.visible = not has
    if not has and lens_held: _put_lens_down()
    lens_button.text = ("Put the magnifying glass down" if lens_held else "Pick up the magnifying glass") if has else "Magnifying glass (select a part)"
    lens_button.disabled = not has
    card_text.text = ("%s\n%s\n\n%s" % [_model_name(record), _kind(record).to_upper(), PartCondition.describe(record, 8)]) if has else ""
    quick_button.text = PartCondition.test_name(_kind(record), false) + " · %d min" % PartCondition.QUICK_MINUTES if has else "Quick test"
    long_button.text = PartCondition.test_name(_kind(record), true) + " · %d min" % PartCondition.LONG_MINUTES if has else "Long test"
    quick_button.disabled = not has or over
    long_button.disabled = not has or over
    for label: String in label_buttons: label_buttons[label].disabled = not has
    scrap_button.text = ("Sell for scrap · $%d" % PartCondition.scrap_value(_kind(record))) if has else "Sell for scrap"
    scrap_button.disabled = not has
    queue_redraw()


func _after(text: String) -> void:
    var saved: bool = NightSession.checkpoint(GameState)
    message.text = text + ("" if saved else "\n" + NightSession.status)
    _refresh()


# ---- 0.56.0: the magnifying glass ----

func spot_center(i: int) -> Vector2:
    var at: Vector2 = SPOT_AT[i]
    # 0.57.7: with the approved inspection picture, each spot sits on its real detail (ART-15).
    var record: Dictionary = _record()
    if not record.is_empty():
        var kind: String = _kind(record)
        var spots: Array = PartCondition.spots(kind)
        if i < spots.size() and ItemArt.inspect(kind) != null:
            at = (ItemArt.INSPECT_SPOTS.get(kind, {}) as Dictionary).get(str(spots[i]), at)
    return PART_RECT.position + Vector2(PART_RECT.size.x * at.x, PART_RECT.size.y * at.y)


# 0.57.7: the clue overlay (ART-17) for a spot the player has already looked at, or null. Only what the
# lens actually showed: a healthy part, an unlooked spot or "Nothing unusual" never gets one.
func clue_texture(i: int) -> Texture2D:
    var record: Dictionary = _record()
    if record.is_empty() or not looked(i): return null
    var kind: String = _kind(record)
    var spots: Array = PartCondition.spots(kind)
    if i >= spots.size() or PartCondition.spot_text(record, str(spots[i])) == PartCondition.NEUTRAL: return null
    var condition: String = PartCondition.sanitize_condition(record.get("condition", "working"))
    return ItemArt.clue("%s_%s" % [kind, "herring" if condition == "working" else condition])


func looked(i: int) -> bool:
    var record: Dictionary = _record()
    var spots: Array = PartCondition.spots(_kind(record)) if not record.is_empty() else []
    return i < spots.size() and ("inspect:" + str(spots[i])) in PartCondition.known(record)["tests"]


# The spot under the lens centre, or -1.
func spot_under_lens() -> int:
    var record: Dictionary = _record()
    if record.is_empty(): return -1
    var spots: Array = PartCondition.spots(_kind(record))
    for i in range(mini(spots.size(), SPOT_AT.size())):
        if lens_at.distance_to(spot_center(i)) <= SPOT_REACH and PartCondition.needs_lens(_kind(record), str(spots[i])): return i
    return -1


func _toggle_lens() -> void:
    if lens_held: _put_lens_down()
    elif not _record().is_empty():
        lens_held = true
        lens_at = get_viewport().get_mouse_position()
        if PART_RECT.has_point(lens_at): Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
        message.text = "Magnifying glass in hand: hold it over a spot on the part."
    _refresh()


func _put_lens_down() -> void:
    lens_held = false
    dwell_spot = -1
    dwell = 0.0
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    queue_redraw()


func _input(event: InputEvent) -> void:
    if not lens_held: return
    if event is InputEventMouseMotion:
        lens_at = event.position
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if PART_RECT.grow(LENS_RADIUS).has_point(lens_at) else Input.MOUSE_MODE_VISIBLE)
        queue_redraw()
    elif (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
        _put_lens_down()
        _refresh()
        get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
    if not lens_held: return
    var i: int = spot_under_lens()
    if i < 0 or looked(i) or NightClock.over(GameState.night_minutes):
        dwell_spot = -1
        dwell = 0.0
        return
    if i != dwell_spot:
        dwell_spot = i
        dwell = 0.0
    dwell += delta
    queue_redraw()
    if dwell >= LENS_DWELL:
        dwell_spot = -1
        dwell = 0.0
        _inspect(i)


func _exit_tree() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _inspect(i: int) -> void:
    var record: Dictionary = _record()
    if record.is_empty(): return
    var spots: Array = PartCondition.spots(_kind(record))
    if i >= spots.size(): return
    var result: Dictionary = GameState.inspect_part(selected, str(spots[i]))
    _after(str(result.get("message", "")))


func _test(long_test: bool) -> void:
    if selected == "": return
    _after(str(GameState.test_part(selected, long_test).get("message", "")))


func _mark(label: String) -> void:
    if selected == "": return
    if GameState.label_part(selected, label): _after("Marked %s. That is your call; the notes keep what you actually saw." % label)


func _scrap() -> void:
    if selected == "": return
    var name_text: String = _model_name(_record())
    var cash: int = GameState.scrap_part(selected)
    if cash <= 0: return
    selected = ""
    _rebuild_list()
    _after("%s sold for scrap: +$%d." % [name_text, cash])


func _draw() -> void:
    super._draw()
    draw_rect(LIST_RECT.grow(4), Color("1d2833"))
    draw_rect(PART_RECT, Color("232f2a"))
    draw_rect(PART_RECT, Color("5f7a68"), false, 2.0)
    draw_rect(CARD_RECT, Color("1d2833"))
    draw_rect(CARD_RECT, Color("4a6070"), false, 2.0)
    var record: Dictionary = _record()
    if record.is_empty(): return
    var kind: String = _kind(record)
    var body := Rect2(PART_RECT.position + PART_RECT.size * Vector2(0.1, 0.12), PART_RECT.size * Vector2(0.8, 0.76))
    var colour: Color = KIND_COLOURS.get(kind, Color("7a8a90"))
    var picture: Texture2D = ItemArt.inspect(kind)
    if picture != null:           # 0.57.7: the approved close-up (always a healthy-looking part) + revealed clues
        draw_texture_rect(picture, PART_RECT, false)
        for i in range(PartCondition.spots(kind).size()):
            var clue: Texture2D = clue_texture(i)
            if clue != null: draw_texture_rect(clue, PART_RECT, false)
    else:
        draw_rect(body, colour.darkened(0.25))
        draw_rect(body, colour.lightened(0.3), false, 3.0)
        _draw_part_shape(kind, body, colour)
    _draw_spots(record)
    if lens_held: _draw_lens(record, kind, body, colour)


func _draw_part_shape(kind: String, body: Rect2, colour: Color) -> void:
    match kind:
        "gpu":
            for k in range(2): draw_circle(body.position + Vector2(body.size.x * (0.3 + 0.4 * k), body.size.y * 0.5), body.size.y * 0.3, colour.darkened(0.5))
            draw_rect(Rect2(body.position + Vector2(body.size.x * 0.1, body.size.y - 10), Vector2(body.size.x * 0.6, 10)), Color("d4b25a"))
        "ram":
            for k in range(6): draw_rect(Rect2(body.position + Vector2(body.size.x * (0.08 + 0.15 * k), body.size.y * 0.3), Vector2(body.size.x * 0.1, body.size.y * 0.35)), Color("26302b"))
            draw_rect(Rect2(body.position + Vector2(0, body.size.y - 12), Vector2(body.size.x, 12)), Color("d4b25a"))
        "cpu":
            draw_rect(body.grow(-body.size.y * 0.2), colour.lightened(0.15))
        "psu":
            for k in range(7): draw_line(body.position + Vector2(body.size.x * 0.25, body.size.y * (0.2 + 0.1 * k)), body.position + Vector2(body.size.x * 0.75, body.size.y * (0.2 + 0.1 * k)), colour.darkened(0.5), 3.0)
        "cooler":
            for k in range(9): draw_line(body.position + Vector2(body.size.x * (0.1 + 0.1 * k), body.size.y * 0.1), body.position + Vector2(body.size.x * (0.1 + 0.1 * k), body.size.y * 0.9), colour.lightened(0.2), 2.0)
        "storage":
            draw_rect(Rect2(body.position + body.size * Vector2(0.15, 0.15), body.size * Vector2(0.5, 0.35)), Color("e8e3d4"))


# Placeholder marks for the spots (with art, the spots are simply parts of the picture).
func _draw_spots(record: Dictionary) -> void:
    var spots: Array = PartCondition.spots(_kind(record))
    var font: Font = ThemeDB.fallback_font
    for i in range(mini(spots.size(), SPOT_AT.size())):
        var c: Vector2 = spot_center(i)
        if looked(i):
            draw_circle(c, 7.0, Color("6fcf97"))
            draw_string(font, c + Vector2(10, 5), "✓ " + str(spots[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("cfe9d9"))
        else:
            draw_arc(c, 9.0, 0.0, TAU, 20, Color(1, 1, 1, 0.35), 1.5)


func _draw_lens(_record_shown: Dictionary, kind: String, body: Rect2, colour: Color) -> void:
    var c: Vector2 = lens_at
    var font: Font = ThemeDB.fallback_font
    # The glass: a magnified look at what is under it. With the approved picture it really magnifies (2x).
    var picture: Texture2D = ItemArt.inspect(kind)
    if picture != null and PART_RECT.grow(LENS_RADIUS).has_point(c):
        var ring := PackedVector2Array()
        var uvs := PackedVector2Array()
        for k in range(40):
            var p: Vector2 = c + Vector2.from_angle(k * TAU / 40.0) * LENS_RADIUS
            ring.append(p)
            uvs.append(((c + (p - c) * 0.5) - PART_RECT.position) / PART_RECT.size)
        draw_polygon(ring, PackedColorArray([Color.WHITE]), uvs, picture)
        draw_circle(c, LENS_RADIUS, Color(0.82, 0.9, 1.0, 0.10))
    else:
        draw_circle(c, LENS_RADIUS, Color(0.82, 0.9, 1.0, 0.16) if not body.has_point(c) else colour.lightened(0.15))
    var i: int = spot_under_lens()
    if i >= 0:
        var spots: Array = PartCondition.spots(kind)
        draw_circle(c, 18.0, Color(1, 1, 1, 0.55) if not looked(i) else Color("6fcf97"))
        draw_string(font, c + Vector2(-LENS_RADIUS, LENS_RADIUS + 20), str(spots[i]), HORIZONTAL_ALIGNMENT_CENTER, LENS_RADIUS * 2.0, 15, Color("ffd27a"))
        if dwell_spot == i: draw_arc(c, LENS_RADIUS + 6.0, -PI / 2.0, -PI / 2.0 + TAU * clampf(dwell / LENS_DWELL, 0.0, 1.0), 40, Color("ffd27a"), 4.0)
    draw_arc(c, LENS_RADIUS, 0.0, TAU, 48, Color("c9d2d8"), 5.0)
    draw_line(c + Vector2(LENS_RADIUS * 0.72, LENS_RADIUS * 0.72), c + Vector2(LENS_RADIUS * 1.5, LENS_RADIUS * 1.5), Color("6b4a2e"), 10.0)
