# VIEW for the shop screen: shows the repair ticket and cash, and links to the other screens.
# This is a stand-in for the future day/night loop, kept deliberately plain.
extends Node2D
const Layout = preload("res://scripts/data/layout.gd")

const COLOR_BG := Color(0.11, 0.12, 0.15)
const COLOR_CARD := Color(0.17, 0.19, 0.24)
const DustZones = preload("res://scripts/data/dust_zones.gd")
const Customers = preload("res://scripts/data/customers.gd")

var title_label: Label
var cash_label: Label
var ticket_label: Label
var result_label: Label
var customer_label: Label
var tab_check: Button
var tab_customer: Button
var note_label: Label
var version_label: Label
var upgrade_button: Button
var hose_button: Button


func _ready() -> void:
    title_label = _make_label(Vector2(40, 16), Vector2(900, 70), 20)
    title_label.text = "NIGHTSHIFT - shop (foundation trial)\nA plain stand-in for the future day/night loop. One repair ticket to complete."
    cash_label = _make_label(Vector2(940, 20), Vector2(300, 40), 28)
    ticket_label = _make_label(Vector2(60, 125), Vector2(560, 300), 19)
    # The lower card has two tabs: the final-check result, and what the shop knows about the customer.
    var tabs := ButtonGroup.new()
    tab_check = _make_button("Final check", Vector2(60, 462), Vector2(130, 32), _show_tab.bind(0))
    tab_customer = _make_button("Customer", Vector2(196, 462), Vector2(130, 32), _show_tab.bind(1))
    for t: Button in [tab_check, tab_customer]:
        t.toggle_mode = true
        t.button_group = tabs
    tab_check.set_pressed_no_signal(true)
    result_label = _make_label(Vector2(60, 500), Vector2(560, 160), 18)
    customer_label = _make_label(Vector2(60, 500), Vector2(560, 160), 15)
    customer_label.visible = false
    note_label = _make_label(Vector2(700, 490), Vector2(520, 170), 15)
    note_label.text = "Fix the ticket: clean, repaste, replace what is broken, then run the final check. Dust is not a blocker: it only adds temperature. The PC passes while it stays under the limit and every part works. All numbers are demo values. Progress and cash are saved automatically."

    _make_button("Open repair bench (clean + paste)", Vector2(700, 110), Vector2(420, 50), _go.bind("res://scenes/bench.tscn"))
    _make_button("Hardware bench (shaped board trial)", Vector2(700, 180), Vector2(420, 50), _go.bind("res://scenes/main.tscn"))
    _make_button("Run final check", Vector2(700, 250), Vector2(420, 50), _on_check_pressed)
    upgrade_button = _make_button("Buy square cloth", Vector2(700, 320), Vector2(420, 44), _on_upgrade_pressed)
    hose_button = _make_button("Buy longer hose", Vector2(700, 372), Vector2(420, 44), _on_hose_pressed)
    _make_button("Main menu", Vector2(700, 424), Vector2(420, 44), _on_main_menu_pressed)
    version_label = _make_label(Vector2(40, 686), Vector2(900, 24), 13)
    version_label.text = "Nightshift foundation trial v%s  |  save format %d" % [GameState.game_version(), GameState.SAVE_FORMAT]
    version_label.add_theme_color_override("font_color", Color(0.6, 0.62, 0.7))
    _refresh()


func _make_label(pos: Vector2, size: Vector2, font_size: int) -> Label:
    var l := Label.new()
    l.position = pos
    l.size = size
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", font_size)
    add_child(l)
    return l


func _make_button(text: String, pos: Vector2, size: Vector2, callback: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.position = pos
    b.size = size
    b.focus_mode = Control.FOCUS_NONE
    b.pressed.connect(callback)
    b.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(b)
    return b


func _go(path: String) -> void:
    get_tree().change_scene_to_file(path)


func _check_mark(done: bool) -> String:
    return "[x]" if done else "[ ]"


func _refresh() -> void:
    var job: Dictionary = GameState.job
    cash_label.text = "Cash: $%d" % GameState.money
    var cleaned: bool = bool(job["cleaned"])
    var parts_total: int = DustZones.zones().size()
    var parts_clean: int = GameState.parts_clean_count()
    if GameState.has_upgrade("square_cloth"):
        upgrade_button.text = "Square cloth: owned"
        upgrade_button.disabled = true
    else:
        upgrade_button.text = "Buy square cloth ($%d)" % int(GameState.UPGRADE_PRICES["square_cloth"])
        upgrade_button.disabled = false
    if GameState.has_upgrade("long_hose"):
        hose_button.text = "Longer vacuum hose: owned"
        hose_button.disabled = true
    else:
        hose_button.text = "Buy longer vacuum hose ($%d)" % int(GameState.UPGRADE_PRICES["long_hose"])
        hose_button.disabled = false
    var grade: String = str(job["paste_grade"])
    var done: bool = job["state"] == "done"
    var temp: float = float(job["temp"])
    var paste_text: String = "(no result yet)" if grade == "" else "(result: %s)" % grade
    var check_text: String = "(not run yet)" if temp <= 0.0 else "(last: %d C, limit %d C)" % [roundi(temp), roundi(GameState.PASS_TEMP)]
    var who: Dictionary = Customers.customer(str(job.get("customer_id", "")))
    if not who.is_empty():
        customer_label.text = "%s\n%s\n\nUses: %s\nHabits: %s\nTime: %s\nPays $%d on completion." % [
            str(who["name"]), str(who["about"]), str(who["uses"]), str(who["habits"]), str(who["patience"]), int(job["payout"])]
    ticket_label.text = "TICKET %s - %s\nComplaint: %s\nPayment on completion: $%d\n\n%s 1. Clean the whole PC  (%d of %d parts)\n%s 2. Apply fresh thermal paste  %s\n%s 3. Final check passes  %s\n\nStatus: %s" % [
        job["id"], job["customer"], job["complaint"], int(job["payout"]),
        _check_mark(cleaned), parts_clean, parts_total, _check_mark(grade != ""), paste_text,
        _check_mark(done), check_text,
        "COMPLETED" if done else "OPEN"]
    queue_redraw()


func _show_tab(which: int) -> void:
    result_label.visible = which == 0
    customer_label.visible = which == 1
    tab_check.set_pressed_no_signal(which == 0)
    tab_customer.set_pressed_no_signal(which == 1)


func _on_check_pressed() -> void:
    _show_tab(0)
    var r: Dictionary = GameState.run_final_check()
    AudioFeedback.request(self,"check.pass" if r["passed"] else "check.fail",{"temperature":r["temp"]})
    var temp: int = roundi(float(r["temp"]))
    var lines: String = ""
    var notes: Array = r["notes"]
    for n in notes:
        lines += "\n- " + str(n)
    if r["passed"]:
        if int(r["paid"]) > 0:
            result_label.text = "FINAL CHECK PASSED: %d C. Payment received: $%d." % [temp, int(r["paid"])]
        else:
            result_label.text = "FINAL CHECK PASSED: %d C. (This ticket was already paid.)" % temp
        result_label.add_theme_color_override("font_color", Color(0.25, 0.95, 0.35))
    else:
        result_label.text = "FINAL CHECK FAILED: %d C (limit %d C). Reasons:%s" % [temp, roundi(GameState.PASS_TEMP), lines]
        result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    if r["passed"] and not lines.is_empty(): result_label.text += lines
    _refresh()


func _on_upgrade_pressed() -> void:
    if GameState.buy_upgrade("square_cloth"):
        result_label.text = "Bought the square cloth. It wipes a square patch on the paste bench."
        result_label.add_theme_color_override("font_color", Color(0.25, 0.95, 0.35))
    else:
        result_label.text = "Not enough cash for the square cloth ($%d needed)." % int(GameState.UPGRADE_PRICES["square_cloth"])
        result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    _refresh()


func _on_hose_pressed() -> void:
    if GameState.buy_upgrade("long_hose"):
        result_label.text = "Bought the longer hose. The vacuum reaches about 35% further from the bin."
        result_label.add_theme_color_override("font_color", Color(0.25, 0.95, 0.35))
    else:
        result_label.text = "Not enough cash for the longer hose ($%d needed)." % int(GameState.UPGRADE_PRICES["long_hose"])
        result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    _refresh()


func _on_main_menu_pressed() -> void:
    GameState.save_game()
    _go("res://scenes/start.tscn")


func _draw() -> void:
    draw_rect(Layout.SCREEN, COLOR_BG)
    draw_rect(Layout.SHOP_JOB_CARD, COLOR_CARD)
    draw_rect(Layout.SHOP_JOB_CARD, Color(0.6, 0.62, 0.7), false, 2.0)
    draw_rect(Layout.SHOP_LOWER_CARD, COLOR_CARD)
    draw_rect(Layout.SHOP_LOWER_CARD, Color(0.6, 0.62, 0.7), false, 2.0)
