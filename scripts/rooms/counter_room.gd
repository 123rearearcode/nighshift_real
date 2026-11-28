# The shop counter: the main screen (0.53.0, D161). You stand behind the counter; customers come to the
# window. The front door (left) goes outside, the back door goes to the workshop. On the counter: the
# till, the ticket clipboard and your phone; on the wall, the board with the night and
# the clock, and the shutter that closes the shop for the night. 0.55.0 (D162): the tool catalogue left the
# counter (tools are bought at the store down the street); storage under the counter window took its place.
#
# 0.57.0: title New game starts with untimed opening intake, then the existing first night.
# Mornings (user, 21 November 2026): every customer walks in at the start of the day, one at a time, and
# the board shows how many came in. There is no clock on this; it is about their stories. Their visit is
# the old morning report's card, spoken across the counter (morning_text.gd).
#
# Scam hooks left open on purpose (user: "yes leave room for all this"): what you tell customers across the
# counter (the quote, the excuse), the till (overcharging, a "diagnostic fee"), the bin (where "disposed"
# parts really go) and nosy customers who open the case at the counter. The bin is a "later:" hotspot.
extends "res://scripts/rooms/room_view.gd"

const Laptop = preload("res://scripts/rules/laptop.gd")   # 0.59.1 (D185)
const TicketRule = preload("res://scripts/rules/ticket.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const MorningText = preload("res://scripts/night/morning_text.gd")
const Phone = preload("res://scripts/night/phone_panel.gd")
const CounterArt = preload("res://scripts/rooms/counter_art.gd")
const DialogueBox = preload("res://scripts/ui/dialogue_box.gd")   # 0.58.9 (D181): customers talk first
const StorageModel = preload("res://scripts/storage/storage_model.gd")    # 0.59.2: what waits on the counter top
const StorageSources = preload("res://scripts/storage/storage_sources.gd")
const StorageStore = preload("res://scripts/storage/storage_store.gd")
const StorageData = preload("res://scripts/storage/storage_data.gd")
const SLIDE_SECONDS: float = 0.45      # 0.59.2 (D186; user: "Simple slide for now"): customers come in and go out
const SLIDE_FROM: float = -240.0       # px to the left (the door side) where a customer starts and leaves to
const VISITORS: Array = ["collected", "comeback", "new"]   # cards of people who walk in (waiting ones did not come)
const SLIP_RECT := Rect2(24, 176, 416, 374)
# 0.57.3: the ticket clipboard close-up is the approved skin (art/ui/ticket_clipboard.png, 300 x 350 at
# 2x). The paper rectangle is where the game writes; the clip and the board edge stay clear.
const CLIPBOARD_RECT := Rect2(660, 10, 600, 700)
const CLIPBOARD_PAPER := Rect2(56, 136, 488, 492)
const CLIPBOARD_SKIN := "ticket_clipboard"
# 0.57.3: customers stand behind the counter; a pixel-art customer (ART-08) is shown at exactly 2x with
# the bottom of the sprite (the waist) on the counter-top line. Larger painted portraits keep the old fit.
const COUNTER_TOP_Y: float = CounterArt.COUNTER_TOP_Y
const PORTRAIT_FIT := Rect2(510, 144, 340, 344)
const PIXEL_SPRITE_MAX_HEIGHT: int = 200
# The customer's PC on the counter while they are at the window (ART-09), base on the counter top.
const CUSTOMER_PC_PROP := "pc_tower_closed"
const CUSTOMER_PC_BASE := CounterArt.CUSTOMER_PC_BASE     # bottom centre on the foreground worktop

var counter_art := CounterArt.new()
var dialogue: Control                  # 0.58.9 (D181): the customer's lines unroll; the slip comes after
# 0.57.8 (user, 25 November 2026): no storage button; hovering the bottom edge pulls the storage up.
const STORAGE_SLIDE: float = 0.22       # seconds to slide fully open or closed
const STORAGE_CLOSE_Y: float = 64.0     # moving the mouse above this line (with nothing held) slides it back down
var storage_drawer: Node2D
var storage_open: bool = false
var storage_tween: Tween
var room_layer: CounterArt.Layer
var counter_layer: CounterArt.Layer

var phone: Panel
var end_dialog: ConfirmationDialog
var clipboard: Panel
var clipboard_list: VBoxContainer
var slip: Panel
var slip_title: Label
var slip_text: Label
var next_button: Button
var recovery_slip: Panel   # B59 (0.57.11): shown when the ticket book is damaged
var restore_button: Button
var portrait: TextureRect
var customer_pc: TextureRect
var visits: Array = []
var visit_index: int = -1
var arrived: int = 0
var opening_visits: bool = false


func _room_ready() -> void:
    portrait = get_node_or_null("CustomerPortrait")
    if portrait != null:
        portrait.z_index = 1       # in front of the window spot's placeholder tint
        portrait.hide()
    customer_pc = TextureRect.new()
    customer_pc.name = "CustomerPC"
    customer_pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    customer_pc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    customer_pc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    customer_pc.stretch_mode = TextureRect.STRETCH_SCALE
    customer_pc.texture = RoomArt.prop(CUSTOMER_PC_PROP)
    if customer_pc.texture != null:
        customer_pc.size = Vector2(customer_pc.texture.get_size()) * RoomArt.PIXEL_SCALE
        customer_pc.position = (CUSTOMER_PC_BASE - Vector2(customer_pc.size.x * 0.5, customer_pc.size.y)).round()
    customer_pc.z_index = 3
    customer_pc.hide()
    add_child(customer_pc)
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
    phone.bought.connect(refresh)   # B85: the till badge shows the money the reviews cost
    add_child(phone)
    _setup_counter_art()
    _build_storage_drawer()
    _build_recovery_slip()
    dialogue = DialogueBox.new()
    add_child(dialogue)
    dialogue.finished.connect(_dialogue_done)
    if NightSession.needs_recovery(GameState):
        _show_recovery()
    elif not GameState.opening_customers.is_empty():
        _begin_opening()
    elif NightSession.visits_pending:
        _begin_visits()
    if NightSession.restored_note != "":
        say(NightSession.restored_note)
        NightSession.restored_note = ""


func _setup_counter_art() -> void:
    counter_art.wall_finish = GameState.wall_finish   # 0.58.9 (D180): the wall finish the shop has up
    # Preserve the existing explicit flat-background override used by artists and fallback tests.
    var flat_background: TextureRect = get_node_or_null("Background")
    if flat_background != null and flat_background.texture != null: return
    if not counter_art.available(): return
    placeholders = false
    for h: Variant in hotspots.values():
        var spot: Hotspot = h
        spot.placeholder = false
        spot.mouse_entered.connect(_sync_counter_art)
        spot.mouse_exited.connect(_sync_counter_art)
        spot.queue_redraw()
    get_node("Hotspots").z_index = 4
    room_layer = CounterArt.Layer.new()
    room_layer.name = "BatchARoom"
    room_layer.art = counter_art
    room_layer.z_index = -10
    add_child(room_layer)
    counter_layer = CounterArt.Layer.new()
    counter_layer.name = "BatchACounter"
    counter_layer.art = counter_art
    counter_layer.foreground = true
    counter_layer.z_index = 2     # the customer's lower body is behind the counter, their PC is above it
    add_child(counter_layer)
    for rect: Rect2 in [Rect2(0, 0, 1280, 54), Rect2(0, 652, 1280, 68)]:
        var backing := ColorRect.new()
        backing.position = rect.position
        backing.size = rect.size
        backing.color = Color("13232b")
        backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
        backing.z_index = -2 if rect.position.y == 0 else 10
        add_child(backing)
    title.z_index = 20
    title.position = Vector2(24, 14)
    message.z_index = 20
    clipboard.z_index = 30
    slip.z_index = 30
    phone.z_index = 30
    end_dialog.visibility_changed.connect(_sync_counter_art)
    _sync_counter_art()


func _sync_counter_art() -> void:
    if room_layer == null: return
    var front: Hotspot = hotspot("FrontDoor")
    var back: Hotspot = hotspot("BackDoor")
    room_layer.morning = visiting()
    room_layer.front_open = front != null and front.hovered and not front.disabled
    room_layer.workshop_open = back != null and back.hovered and not back.disabled
    # Closing is a visual preview while the existing confirmation is open. Cancel restores the up state.
    room_layer.shutter_down = is_instance_valid(end_dialog) and end_dialog.visible
    counter_layer.morning = room_layer.morning
    room_layer.queue_redraw()
    counter_layer.queue_redraw()


# 0.59.2: the backpack does not slide in over the open under-counter drawer.
func edge_blocked() -> bool:
    return storage_open


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
        "open:storage": open_storage()
        _: return false
    return true


# ---- 0.57.8: the storage under the counter, pulled up from the bottom edge ----

func _build_storage_drawer() -> void:
    storage_drawer = load(Navigation.UNDER_COUNTER).instantiate()
    storage_drawer.name = "StorageDrawer"
    storage_drawer.embedded = true
    storage_drawer.is_open = false
    storage_drawer.position = Vector2(0, 720)
    storage_drawer.z_index = 40
    storage_drawer.visible = false
    add_child(storage_drawer)
    var edge: Hotspot = hotspot("UnderCounter")
    if edge != null: edge.mouse_entered.connect(func() -> void: if not edge.disabled: open_storage())


func open_storage() -> void:
    if storage_drawer == null or storage_open: return
    storage_open = true
    storage_drawer.visible = true
    storage_drawer.is_open = true
    _slide_storage(0.0)


func close_storage() -> bool:
    if storage_drawer == null or not storage_open or storage_drawer.model.held != "": return false
    storage_open = false
    storage_drawer.is_open = false
    _slide_storage(720.0)
    _show_counter_top()   # 0.59.2: what you put away leaves the counter top
    return true


func _slide_storage(target_y: float) -> void:
    if storage_tween != null and storage_tween.is_valid(): storage_tween.kill()
    storage_tween = create_tween()
    storage_tween.tween_property(storage_drawer, "position:y", target_y, STORAGE_SLIDE)
    if target_y > 0.0: storage_tween.tween_callback(func() -> void: if not storage_open: storage_drawer.visible = false)


func _input(event: InputEvent) -> void:
    if not storage_open: return
    if event is InputEventMouseMotion and event.position.y < STORAGE_CLOSE_Y: close_storage()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and storage_drawer.model.held == "":
        close_storage()


func _open_tickets() -> Array:
    return NightSession.jobs(GameState).filter(func(job: Dictionary) -> bool: return job.get("state", "open") != "done")


func _called() -> Array:
    return _open_tickets().filter(func(job: Dictionary) -> bool: return TicketRule.status(job) == TicketRule.CALLED)


func _till_text() -> String:
    var earned: int = int(NightSession.last_report.get("earned", 0)) if not NightSession.last_report.is_empty() else 0
    return "The till: $%d in cash.%s" % [GameState.money, (" This morning's customers paid $%d." % earned) if not NightSession.last_report.is_empty() else ""]


func _board_text() -> String:
    if not GameState.opening_customers.is_empty(): return "DAY 1 · customer intake. Night work begins after the customers leave."
    return "Night %d · %s · %.1f★ online · %s · %d open ticket%s." % [GameState.night_number, NightClock.label(GameState.night_minutes),
        GameState.shop_rating(), GameState.standing_text(), _open_tickets().size(), "" if _open_tickets().size() == 1 else "s"]


func _refresh_room() -> void:
    var over: bool = NightClock.over(GameState.night_minutes)
    _badge("Till", "$%d" % GameState.money)
    _badge("TicketClipboard", "%d open" % _open_tickets().size())
    _badge("Phone", "%.1f★" % GameState.shop_rating())
    _badge("WallBoard", "Day 1 · customer intake" if opening_visits else (("%d came in" % arrived) if visiting() else "Night %d · %s" % [GameState.night_number, NightClock.label(GameState.night_minutes)]))
    _badge("Shutter", "06:00: close up" if over else "%d to collect" % _called().size())
    _badge("CustomerWindow", str(visits[visit_index].get("customer", "")) if visiting() else "")
    # While customers are at the counter, serve them first: the rest of the shop waits.
    for h: Variant in hotspots.values():
        var spot: Hotspot = h
        var waiting_on_customers: bool = (visiting() or not GameState.opening_customers.is_empty()) and str(spot.name) != "CustomerWindow"
        spot.disabled = waiting_on_customers or (spot.closed_at_dawn and over)
        spot.tooltip_text = "Serve the customers at the counter first." if waiting_on_customers else ("06:00: the night is over. Close the shutter." if spot.closed_at_dawn and over else spot.label)
    _sync_counter_art()
    if not visiting(): _show_counter_top()   # 0.59.2 (D186)
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

func _begin_opening() -> void:
    opening_visits = true
    visits = NightSession.opening_cards(GameState)
    arrived = visits.size()
    if visits.is_empty():
        say(NightSession.status)
        return
    _show_visit(0)

func _navigate(path: String) -> bool:
    if not GameState.opening_customers.is_empty() and not path in [Navigation.COUNTER, "res://scenes/start.tscn"]:
        say("Serve the customers at the counter first; night work has not begun.")
        return false
    return super._navigate(path)

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
    if opening_visits:
        slip_title.text = "DAY 1 · NEW CUSTOMER · %d of %d" % [index + 1, arrived]
        slip_text.text = MorningText.opening_text(card, person)
        var what: String = "laptop" if _visit_is_laptop(card) else "PC"   # 0.59.1 (D185)
        next_button.text = ("Accept %s · next customer" % what) if index < visits.size() - 1 else ("Accept %s · begin night 1" % what)
    else:
        slip_title.text = "MORNING · %d customer%s came in · %d of %d" % [arrived, "" if arrived == 1 else "s", index + 1, arrived]
        slip_text.text = MorningText.card_text(card)
        next_button.text = "Next customer ▸" if index < visits.size() - 1 else "That's everyone: open up for the night"
    _show_customer(person, card)
    # 0.58.9 (D181): the customer speaks first (click or Space unrolls each line); the ticket slip follows.
    slip.hide()
    var said: Array = MorningText.opening_lines(card, person) if opening_visits else MorningText.visit_lines(card, person)
    dialogue.play(str(card.get("customer", person.get("name", ""))), said)
    refresh()


func _dialogue_done() -> void:
    if visit_index < 0: return
    slip.show()
    refresh()


# 0.59.1 (D185): does this visitor bring a laptop (their ticket's PC)?
func _visit_is_laptop(card: Dictionary) -> bool:
    return str(NightSession.ticket_job(GameState, str(card.get("ticket", ""))).get("layout", "")) == "laptop"


# The customer at the window and their PC on the counter. 0.59.1: a laptop customer's laptop lies there
# instead of the tower (its picture once the user approves it; until then nothing is shown, never a tower).
func _show_customer(person: Dictionary, card: Dictionary = {}) -> void:
    if customer_pc != null:
        var laptop: bool = _visit_is_laptop(card)
        var job: Dictionary = NightSession.ticket_job(GameState, str(card.get("ticket", ""))) if laptop else {}
        customer_pc.texture = RoomArt.prop(("laptop_closed_" + Laptop.finish_of(job)) if laptop else CUSTOMER_PC_PROP)
        if customer_pc.texture != null:
            customer_pc.size = Vector2(customer_pc.texture.get_size()) * RoomArt.PIXEL_SCALE
            customer_pc.position = (CUSTOMER_PC_BASE - Vector2(customer_pc.size.x * 0.5, customer_pc.size.y)).round()
        customer_pc.visible = customer_pc.texture != null
    if portrait == null: return
    var tex: Texture2D = RoomArt.customer(person)
    portrait.texture = tex
    portrait.visible = tex != null
    if tex == null: return
    if tex.get_height() <= PIXEL_SPRITE_MAX_HEIGHT:
        var shown := Vector2(tex.get_size()) * RoomArt.PIXEL_SCALE
        var window: Hotspot = hotspot("CustomerWindow")
        var centre_x: float = window.position.x + window.size.x * 0.5 if window != null else 640.0
        portrait.stretch_mode = TextureRect.STRETCH_SCALE
        portrait.position = Vector2(roundf(centre_x - shown.x * 0.5), COUNTER_TOP_Y - shown.y)
        portrait.size = shown
    else:
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.position = PORTRAIT_FIT.position
        portrait.size = PORTRAIT_FIT.size
    _slide_in(portrait)


# 0.59.2 (D186): a customer slides in from the door side and fades in; leaving, a copy slides back out and fades
# (so the next customer can already come in). Only x and alpha change: where they stand is unchanged.
func _slide_in(node: TextureRect) -> void:
    var target: Vector2 = node.position
    node.position = target + Vector2(SLIDE_FROM, 0)
    node.modulate.a = 0.0
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(node, "position:x", target.x, SLIDE_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(node, "modulate:a", 1.0, SLIDE_SECONDS * 0.6)


func _slide_out(node: TextureRect) -> void:
    if node == null or not node.visible or node.texture == null: return
    var ghost := TextureRect.new()
    ghost.name = "LeavingCustomer"
    ghost.texture = node.texture
    ghost.stretch_mode = node.stretch_mode
    ghost.expand_mode = node.expand_mode
    ghost.texture_filter = node.texture_filter
    ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ghost.position = node.position
    ghost.size = node.size
    ghost.z_index = node.z_index
    add_child(ghost)
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(ghost, "position:x", node.position.x + SLIDE_FROM, SLIDE_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(ghost, "modulate:a", 0.0, SLIDE_SECONDS)
    tween.chain().tween_callback(ghost.queue_free)


func _hide_customer() -> void:
    _slide_out(portrait)   # 0.59.2: they walk out
    if portrait != null: portrait.hide()
    if customer_pc != null: customer_pc.hide()
    _show_counter_top()


# 0.59.2 (D186; user: "PC just disappears into inv. It must be moved"): what was handed over stays ON the counter
# (storage unit "counter_top") until you put it under the counter or pick it up. Between customers the counter
# shows the first of them.
func counter_top() -> Array:
    var m := StorageModel.new()
    m.setup(StorageSources.collect(GameState), StorageStore.new().read())
    return m.in_unit(StorageData.TOP_ID).map(func(uid: String) -> Dictionary: return m.items[uid])


func _show_counter_top() -> void:
    if customer_pc == null or visiting(): return
    var top: Array = counter_top()
    if top.is_empty():
        customer_pc.hide()
        return
    var first: Dictionary = top[0]
    customer_pc.texture = RoomArt.prop(("laptop_closed_" + str(first.get("finish", "graphite"))) if bool(first.get("stackable", false)) else CUSTOMER_PC_PROP)
    if customer_pc.texture != null:
        customer_pc.size = Vector2(customer_pc.texture.get_size()) * RoomArt.PIXEL_SCALE
        customer_pc.position = (CUSTOMER_PC_BASE - Vector2(customer_pc.size.x * 0.5, customer_pc.size.y)).round()
    customer_pc.visible = customer_pc.texture != null


func _next_visit() -> void:
    if dialogue != null and dialogue.active: dialogue.skip_all()   # 0.58.9: never leave a customer talking over the room
    if opening_visits and not NightSession.accept_opening_customer(GameState, str(visits[visit_index]["ticket"])):
        say(NightSession.status)
        return
    AudioFeedback.request(self, "ui.click")
    if visit_index < visits.size() - 1: _show_visit(visit_index + 1)
    elif opening_visits:
        visit_index = -1
        opening_visits = false
        slip.hide()
        _hide_customer()
        say("Intake complete. Night 1 begins: the PCs and their tickets are in the shop. Go to the workshop when ready.")
        refresh()
    else: _end_visits()


func _end_visits() -> void:
    visit_index = -1
    NightSession.visits_pending = false
    slip.hide()
    _hide_customer()
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


# ---- B59 (0.57.11): a damaged ticket book ----
# The user (27 November 2026): "try to restore it". Instead of a counter that refuses everything, a slip
# explains what happened and offers this morning's backup (the last 3 mornings are kept).

func _build_recovery_slip() -> void:
    recovery_slip = _paper(SLIP_RECT, "RecoverySlip")
    _ink(recovery_slip, "THE TICKET BOOK IS DAMAGED", Vector2(16, 12), Vector2(SLIP_RECT.size.x - 32, 40), 15)
    var text: Label = _ink(recovery_slip, "The shop's list of tonight's repair tickets could not be read, so the game has stopped switching PCs and saving to keep every customer's PC safe.\n\nYou can put the shop back the way it was this morning, from the automatic morning backup. Anything done since then is lost; the damaged files are kept next to the save.", Vector2(16, 56), Vector2(SLIP_RECT.size.x - 32, SLIP_RECT.size.y - 130), 15)
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    restore_button = Button.new()
    restore_button.name = "RestoreBackupButton"
    restore_button.text = "Restore this morning's backup"
    restore_button.position = Vector2(14, SLIP_RECT.size.y - 60)
    restore_button.size = Vector2(SLIP_RECT.size.x - 28, 46)
    restore_button.add_theme_font_size_override("font_size", 16)
    restore_button.pressed.connect(_restore_backup)
    recovery_slip.add_child(restore_button)
    recovery_slip.hide()


func _show_recovery() -> void:
    slip.hide()
    recovery_slip.show()
    say(NightSession.status)


func _restore_backup() -> void:
    AudioFeedback.request(self, "ui.click")
    if not NightSession.restore_morning(GameState):
        say(NightSession.status)
        return
    Navigation.commit(self, Navigation.COUNTER)   # the counter again, from the restored morning


func _build_clipboard() -> void:
    clipboard = _paper(CLIPBOARD_RECT, "TicketClipboardPanel")
    var skin: Texture2D = RoomArt.ui(CLIPBOARD_SKIN)
    if skin != null:          # the approved clipboard picture, at exactly 2x (no stretching: the rect is 2x its size)
        var style := StyleBoxTexture.new()
        style.texture = skin
        clipboard.add_theme_stylebox_override("panel", style)
        clipboard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var paper: Rect2 = CLIPBOARD_PAPER
    _ink(clipboard, "TICKETS · click one to read it; right-click to mark it ready or call the customer", paper.position, Vector2(paper.size.x - 100, 48), 15)
    var close := Button.new()
    close.name = "ClipboardClose"
    close.text = "Close"
    close.position = Vector2(paper.end.x - 88, paper.position.y)
    close.size = Vector2(88, 32)
    close.pressed.connect(clipboard.hide)
    clipboard.add_child(close)
    var scroll := ScrollContainer.new()
    scroll.position = paper.position + Vector2(0, 56)
    scroll.size = paper.size - Vector2(0, 56)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    clipboard.add_child(scroll)
    clipboard_list = VBoxContainer.new()
    clipboard_list.custom_minimum_size = Vector2(paper.size.x - 16, 0)
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
        row.custom_minimum_size = Vector2(CLIPBOARD_PAPER.size.x - 20, 40)
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
