# Activities > Testing bay (session 3.6 / 0.50.0, D158). The shop's own stock parts: look closely at a
# part's spots (physical inspection), run a quick or long test on the rig, then make your own call:
# mark it working, degraded or dead, or sell it for scrap. Everything costs night time except the
# sticker and the scrap sale. The screen shows only what the shop knows (PART_LIFECYCLE invariant 7):
# the real condition is never displayed, and the label is the player's call, not a verdict.
extends "res://scripts/night/activities_view.gd"
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")

const LIST_RECT := Rect2(32, 132, 360, 500)
const PART_RECT := Rect2(420, 132, 450, 300)
const CARD_RECT := Rect2(896, 132, 352, 300)
const SPOT_AT: Array = [Vector2(0.18, 0.22), Vector2(0.72, 0.2), Vector2(0.46, 0.55), Vector2(0.16, 0.78), Vector2(0.76, 0.78)]
const KIND_COLOURS: Dictionary = {"gpu": Color("8a6fc0"), "ram": Color("5aa77c"), "cpu": Color("b9a27a"), "psu": Color("c99a52"), "cooler": Color("7f93a8"), "storage": Color("5f9db5")}

var selected: String = ""
var cash_label: Label
var list_box: VBoxContainer
var list_buttons: Dictionary = {}
var spot_buttons: Array[Button] = []
var card_text: Label
var quick_button: Button
var long_button: Button
var label_buttons: Dictionary = {}
var scrap_button: Button
var empty_label: Label


func _ready() -> void:
    NightSession.ensure(GameState)
    _label("TESTING BAY / YOUR STOCK", Vector2(172, 24), Vector2(800, 38), 28)
    Navigation.attach(self, _go.bind(Navigation.ACTIVITIES))
    Navigation.back(self, "Activities", Navigation.ACTIVITIES)
    cash_label = _label("", Vector2(32, 80), Vector2(1216, 44), 16)
    var scroll := ScrollContainer.new()
    scroll.position = LIST_RECT.position
    scroll.size = LIST_RECT.size
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.custom_minimum_size = Vector2(LIST_RECT.size.x - 16, 0)
    scroll.add_child(list_box)
    for i in range(SPOT_AT.size()):
        var spot := Button.new()
        spot.add_theme_font_size_override("font_size", 14)
        spot.size = Vector2(150, 30)
        spot.pressed.connect(_inspect.bind(i))
        add_child(spot)
        spot_buttons.append(spot)
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
    _label("Look at each spot for marks, smells and damage (1 night minute each). The quick test finds dead parts and steady faults; some faults only show in the long test. Your mark is your own call: the bay never decides for you.", Vector2(420, 560), Vector2(828, 70), 15)
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
    var spots: Array = PartCondition.spots(_kind(record)) if has else []
    var tests: Array = PartCondition.known(record)["tests"] if has else []
    for i in range(spot_buttons.size()):
        var b: Button = spot_buttons[i]
        b.visible = i < spots.size()
        if not b.visible: continue
        var at: Vector2 = SPOT_AT[i]
        b.position = PART_RECT.position + Vector2(PART_RECT.size.x * at.x, PART_RECT.size.y * at.y) - b.size * 0.5
        var looked: bool = ("inspect:" + str(spots[i])) in tests
        b.text = ("✓ " if looked else "Look: ") + str(spots[i])
        b.disabled = over and not looked
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
    draw_rect(body, colour.darkened(0.25))
    draw_rect(body, colour.lightened(0.3), false, 3.0)
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
