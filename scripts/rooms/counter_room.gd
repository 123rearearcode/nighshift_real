# The shop counter: the main screen (0.53.0, D161). You stand behind the counter; customers come to the
# window. The front door (left) goes outside, the back door goes to the workshop. On the counter: the
# till, the ticket clipboard, your phone and the tool catalogue; on the wall, the board with the night and
# the clock, and the shutter that closes the shop for the night.
#
# Mornings (user, 21 November 2026): every customer walks in at the start of the day, one at a time, and
# the board shows how many came in. There is no clock on this; it is about their stories. Their visit is
# the old morning report's card, spoken across the counter (morning_text.gd).
#
# Scam hooks left open on purpose (user: "yes leave room for all this"): what you tell customers across the
# counter (the quote, the excuse), the till (overcharging, a "diagnostic fee"), the bin (where "disposed"
# parts really go) and nosy customers who open the case at the counter. The bin is a "later:" hotspot.
extends "res://scripts/rooms/room_view.gd"

const TicketRule = preload("res://scripts/rules/ticket.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const MorningText = preload("res://scripts/night/morning_text.gd")
const Phone = preload("res://scripts/night/phone_panel.gd")
const VISITORS: Array = ["collected", "comeback", "new"]   # cards of people who walk in (waiting ones did not come)
const SLIP_RECT := Rect2(820, 84, 430, 470)
const CLIPBOARD_RECT := Rect2(300, 96, 520, 500)

var phone: Panel
var end_dialog: ConfirmationDialog
var clipboard: Panel
var clipboard_list: VBoxContainer
var slip: Panel
var slip_title: Label
var slip_text: Label
var next_button: Button
var portrait: TextureRect
var visits: Array = []
var visit_index: int = -1
var arrived: int = 0


func _room_ready() -> void:
    portrait = get_node_or_null("CustomerPortrait")
    if portrait != null: portrait.hide()
    end_dialog = ConfirmationDialog.new()
    end_dialog.name = "EndNightDialog"
    end_dialog.title = "Close the shutter"
    end_dialog.ok_button_text = "End the night"
    end_dialog.confirmed.connect(_end_night)
    add_child(end_dialog)
    _build_clipboard()
    _build_slip()
    phone = Phone.new()   # 0.52.0: the phone, now lying on the counter
    phone.position = Vector2(440, 60)
    phone.z_index = 20
    phone.hide()
    add_child(phone)
    if NightSession.visits_pending: _begin_visits()


func visiting() -> bool:
    return visit_index >= 0


func _action(action_name: String, _spot: Hotspot) -> bool:
    match action_name:
        "open:phone":
            if phone.visible: phone.hide()
            else: phone.open()
        "open:tickets": _open_clipboard()
        "open:till": say(_till_text())
        "open:board": say(_board_text())
        "open:customer":
            if visiting(): say("%s is at the counter." % str(visits[visit_index].get("customer", "")))
            else: say("Nobody at the counter. Customers come in when the shutter goes up in the morning.")
        "end_night": _ask_end_night()
        _: return false
    return true


func _open_tickets() -> Array:
    return NightSession.jobs(GameState).filter(func(job: Dictionary) -> bool: return job.get("state", "open") != "done")


func _called() -> Array:
    return _open_tickets().filter(func(job: Dictionary) -> bool: return TicketRule.status(job) == TicketRule.CALLED)


func _till_text() -> String:
    var earned: int = int(NightSession.last_report.get("earned", 0)) if not NightSession.last_report.is_empty() else 0
    return "The till: $%d in cash.%s" % [GameState.money, (" This morning's customers paid $%d." % earned) if not NightSession.last_report.is_empty() else ""]


func _board_text() -> String:
    return "Night %d · %s · %.1f★ online · %s · %d open ticket%s." % [GameState.night_number, NightClock.label(GameState.night_minutes),
        GameState.shop_rating(), GameState.standing_text(), _open_tickets().size(), "" if _open_tickets().size() == 1 else "s"]


func _refresh_room() -> void:
    var over: bool = NightClock.over(GameState.night_minutes)
    _badge("Till", "$%d" % GameState.money)
    _badge("TicketClipboard", "%d open" % _open_tickets().size())
    _badge("Phone", "%.1f★" % GameState.shop_rating())
    _badge("WallBoard", ("%d came in" % arrived) if visiting() else "Night %d · %s" % [GameState.night_number, NightClock.label(GameState.night_minutes)])
    _badge("Shutter", "06:00: close up" if over else "%d to collect" % _called().size())
    _badge("CustomerWindow", str(visits[visit_index].get("customer", "")) if visiting() else "")
    # While customers are at the counter, serve them first: the rest of the shop waits.
    for h: Variant in hotspots.values():
        var spot: Hotspot = h
        var waiting_on_customers: bool = visiting() and str(spot.name) != "CustomerWindow"
        spot.disabled = waiting_on_customers or (spot.closed_at_dawn and over)
        spot.tooltip_text = "Serve the customers at the counter first." if waiting_on_customers else ("06:00: the night is over. Close the shutter." if spot.closed_at_dawn and over else spot.label)
    queue_redraw()


func _badge(name: String, value: String) -> void:
    var spot: Hotspot = hotspot(name)
    if spot != null: spot.set_badge(value)


# ---- end of the night (D136): the shutter ----

func _ask_end_night() -> void:
    var names: Array = _called().map(func(job: Dictionary) -> String: return str(job["customer"]))
    end_dialog.dialog_text = ("Close the shutter on night %d?\n\n" % GameState.night_number) + ("Coming to collect in the morning: %s.\nThey take their PCs exactly as they are now." % ", ".join(names) if not names.is_empty() else "Nobody was called: no PC leaves and nobody pays.\nCall a customer from their ticket (the clipboard, or right-click a PC in the stock room).")
    end_dialog.popup_centered()


func _end_night() -> void:
    var report: Dictionary = NightSession.end_night(GameState)
    if not bool(report.get("ok", false)):
        say(str(report.get("message", "The night could not end. Nothing was changed.")))
        return
    Navigation.commit(self, Navigation.COUNTER)   # the shutter goes up: the counter again, with the morning's customers


# ---- the morning's customers, one at a time ----

func _begin_visits() -> void:
    var report: Dictionary = NightSession.last_report
    visits = (report.get("cards", []) as Array).filter(func(card: Dictionary) -> bool: return str(card.get("kind", "")) in VISITORS)
    arrived = visits.size()
    if visits.is_empty():
        _end_visits()
        return
    _show_visit(0)


func _show_visit(index: int) -> void:
    visit_index = index
    var card: Dictionary = visits[index]
    var person: Dictionary = GameState.person(str(card.get("customer_id", "")))
    slip_title.text = "MORNING · %d customer%s came in · %d of %d" % [arrived, "" if arrived == 1 else "s", index + 1, arrived]
    slip_text.text = MorningText.card_text(card)
    next_button.text = "Next customer ▸" if index < visits.size() - 1 else "That's everyone: open up for the night"
    slip.show()
    if portrait != null:
        portrait.texture = RoomArt.customer(person)
        portrait.visible = portrait.texture != null
    refresh()


func _next_visit() -> void:
    AudioFeedback.request(self, "ui.click")
    if visit_index < visits.size() - 1: _show_visit(visit_index + 1)
    else: _end_visits()


func _end_visits() -> void:
    visit_index = -1
    NightSession.visits_pending = false
    slip.hide()
    if portrait != null: portrait.hide()
    var report: Dictionary = NightSession.last_report
    var notes: Array = ["%d customer%s came in this morning; they paid $%d." % [arrived, "" if arrived == 1 else "s", int(report.get("earned", 0))]]
    var waiting: Array = (report.get("cards", []) as Array).filter(func(card: Dictionary) -> bool: return str(card.get("kind", "")) == "waiting")
    if not waiting.is_empty(): notes.append("Still waiting for their PCs: " + ", ".join(waiting.map(func(c: Dictionary) -> String: return str(c.get("customer", "")))) + ".")
    for card: Dictionary in report.get("cards", []):
        if str(card.get("kind", "")) == "notice": notes.append("Your phone buzzes: " + str(card.get("reaction", "")))
    if str(report.get("standing", "")) != "":
        var change: int = int(report.get("level", 1)) - int(report.get("level_before", report.get("level", 1)))
        notes.append(str(report["standing"]) + (" · LEVEL UP!" if change > 0 else (" · the shop lost a level" if change < 0 else "")))
    say(" ".join(notes))
    refresh()


# ---- the paper things on the counter ----

func _paper(rect: Rect2, name: String) -> Panel:
    var panel := Panel.new()
    panel.name = name
    panel.position = rect.position
    panel.size = rect.size
    panel.z_index = 10
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    var style := StyleBoxFlat.new()
    style.bg_color = Color("efe6cf")
    style.border_color = Color("8c7a58")
    style.set_border_width_all(3)
    style.set_corner_radius_all(4)
    panel.add_theme_stylebox_override("panel", style)
    panel.hide()
    add_child(panel)
    return panel


func _ink(parent: Control, text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color("2b2418"))
    parent.add_child(label)
    return label


func _build_slip() -> void:
    slip = _paper(SLIP_RECT, "CustomerSlip")
    slip_title = _ink(slip, "", Vector2(16, 12), Vector2(SLIP_RECT.size.x - 32, 40), 15)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(14, 54)
    scroll.size = Vector2(SLIP_RECT.size.x - 28, SLIP_RECT.size.y - 124)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    slip.add_child(scroll)
    slip_text = Label.new()
    slip_text.custom_minimum_size = Vector2(SLIP_RECT.size.x - 48, 0)
    slip_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    slip_text.add_theme_font_size_override("font_size", 15)
    slip_text.add_theme_color_override("font_color", Color("2b2418"))
    scroll.add_child(slip_text)
    next_button = Button.new()
    next_button.name = "NextCustomerButton"
    next_button.position = Vector2(14, SLIP_RECT.size.y - 60)
    next_button.size = Vector2(SLIP_RECT.size.x - 28, 46)
    next_button.add_theme_font_size_override("font_size", 16)
    next_button.pressed.connect(_next_visit)
    slip.add_child(next_button)


func _build_clipboard() -> void:
    clipboard = _paper(CLIPBOARD_RECT, "TicketClipboardPanel")
    _ink(clipboard, "TICKETS · click one to read it; right-click to mark it ready or call the customer", Vector2(16, 12), Vector2(CLIPBOARD_RECT.size.x - 120, 44), 15)
    var close := Button.new()
    close.name = "ClipboardClose"
    close.text = "Close"
    close.position = Vector2(CLIPBOARD_RECT.size.x - 90, 10)
    close.size = Vector2(76, 32)
    close.pressed.connect(clipboard.hide)
    clipboard.add_child(close)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(14, 62)
    scroll.size = CLIPBOARD_RECT.size - Vector2(28, 76)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    clipboard.add_child(scroll)
    clipboard_list = VBoxContainer.new()
    clipboard_list.custom_minimum_size = Vector2(CLIPBOARD_RECT.size.x - 48, 0)
    scroll.add_child(clipboard_list)


func _open_clipboard() -> void:
    _fill_clipboard()
    clipboard.show()


# Rows are rebuilt here only (never inside a row's own signal: the ticket window calls back later).
func _fill_clipboard() -> void:
    for child: Node in clipboard_list.get_children(): child.queue_free()
    var open: Array = _open_tickets()
    if open.is_empty():
        _ink(clipboard_list, "No open tickets.", Vector2.ZERO, Vector2(400, 30), 15)
    for job: Dictionary in open:
        var id: String = str(job["id"])
        var row := Button.new()
        row.alignment = HORIZONTAL_ALIGNMENT_LEFT
        row.custom_minimum_size = Vector2(CLIPBOARD_RECT.size.x - 52, 40)
        row.add_theme_font_size_override("font_size", 15)
        row.text = TicketMenu.identity_text(job)
        row.pressed.connect(func() -> void: TicketMenu.window(self, id, _ticket_changed))
        row.gui_input.connect(func(event: InputEvent) -> void:
            if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
                TicketMenu.popup(self, id, get_viewport().get_mouse_position(), _ticket_changed))
        clipboard_list.add_child(row)


func _ticket_changed(result: Dictionary) -> void:
    say(str(result.get("message", "")))
    call_deferred("_fill_clipboard")
    refresh()


func _draw() -> void:
    super._draw()
    # A customer without a portrait yet: a simple silhouette at the window (until art/customers/ has one).
    if visiting() and (portrait == null or portrait.texture == null):
        var spot: Hotspot = hotspot("CustomerWindow")
        if spot != null:
            var r := Rect2(spot.position, spot.size)
            var c := Vector2(r.get_center().x, r.position.y + r.size.y * 0.38)
            draw_circle(c, r.size.y * 0.14, Color("9aa7b0"))
            draw_rect(Rect2(c.x - r.size.x * 0.2, c.y + r.size.y * 0.16, r.size.x * 0.4, r.size.y * 0.44), Color("9aa7b0"))


func _draw_placeholder() -> void:
    draw_rect(Rect2(180, 410, 920, 38), Color("5a4a3a"))      # the counter top
    draw_rect(Rect2(180, 448, 920, 200), Color("3d3229"))     # its front
    draw_rect(Rect2(420, 80, 440, 320), Color("0f1418"))      # the window onto the street
