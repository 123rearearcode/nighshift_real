# Places and exits. 0.53.0 (D161, user 21 November 2026: "get rid of the menus... everything ties together
# visually"): the night is a set of rooms you walk between by clicking doors and objects (scripts/rooms/).
# Close-up screens (the benches, the monitor, the stock room, the testing bay, the salvage run, the tool
# shop) keep one exit, "← <the room you came from>", plus Pause. No hub, no tabs, no global hub button.
# Cleanup/validation belongs to the current scene (its _navigate), not to these controls.
extends RefCounted
const Memory = preload("res://scripts/night/navigation_state.gd")
const Pause = preload("res://scripts/night/pause_menu.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const COUNTER := "res://scenes/rooms/counter.tscn"     # the main screen: the shop counter
const WORKSHOP := "res://scenes/rooms/workshop.tscn"   # behind the counter: the benches and the testing bay
const OUTSIDE := "res://scenes/rooms/outside.tscn"     # through the front door: the street and the dump
const ACTIVITIES := COUNTER                            # legacy name (0.42.0–0.52.0 hub); it means the counter now
const ROOM := "res://scenes/storage.tscn"              # the stock room (PC shelves; choose the PC for the bench)
const REPAIR := "res://scenes/night_bench.tscn"
const HARDWARE := "res://scenes/night_hardware.tscn"
const MONITOR := "res://scenes/software.tscn"
const BAY := "res://scenes/night_bay.tscn"             # 0.50.0 testing bay (a corner of the workshop)
const SALVAGE := "res://scenes/night_salvage.tscn"
const SHOP := "res://scenes/night_shop.tscn"           # tool upgrades (the catalogue on the counter)
# Hotspot "go:<place>" names (scripts/rooms/hotspot.gd).
const PLACES: Dictionary = {"counter": COUNTER, "workshop": WORKSHOP, "outside": OUTSIDE, "stock": ROOM, "repair": REPAIR,
    "hardware": HARDWARE, "monitor": MONITOR, "bay": BAY, "salvage": SALVAGE, "shop": SHOP}
const BACK_RECT := Rect2(24,20,170,42)
static func commit(owner: Node,path: String) -> bool:
    if path == "res://scenes/night_workshop.tscn": path = REPAIR # legacy link, no service-menu detour
    if path in ["res://scenes/activities.tscn","res://scenes/morning.tscn"]: path = COUNTER # 0.53.0: retired screens
    return owner.get_tree().change_scene_to_file(path) == OK
static func _route(owner: Node,path: String) -> bool:
    return bool(owner.call("_navigate",path))
static func _button(owner: Node,name: String,text: String,rect: Rect2,action: Callable) -> Button:
    var button := Button.new()
    button.name = name
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.add_theme_font_size_override("font_size",17)
    button.pressed.connect(func() -> void: owner.get_node("/root/AudioFeedback").request(owner,"ui.click"))
    button.pressed.connect(action)
    owner.add_child(button)
    return button
static func pause(owner: Node) -> void:
    var layer := Pause.new()
    layer.route = func(path: String) -> bool: return _route(owner,path)
    owner.add_child(layer)
    var button := _button(owner,"PauseButton","Pause",Rect2(1164,20,88,42),layer.open)
    button.tooltip_text = "Pause / settings / title screen · F10. Esc closes pause; outside pause it keeps the activity's controls."
    if owner.scene_file_path != "" and not Memory.enter(owner.get_node("/root/GameState"),owner.scene_file_path):
        layer.resume_warning = "The last-view preference could not be saved. Continue may return to the counter."
# A close-up screen's way out: Pause, and "← <room>" back to the place it belongs to. Returns the back button.
static func exit(owner: Node,label: String,path: String) -> Button:
    pause(owner)
    return back(owner,label,path)
static func back(owner: Node,label: String,path: String) -> Button:
    return _button(owner,"BackButton","← "+label,BACK_RECT,func() -> void: _route(owner,path))
# The three workbench close-ups (repair bench, hardware board, diagnostic monitor): back to the workshop,
# where every station stands; the centre identity is the PC's ticket. `_unused` kept for old callers.
static func workbench(owner: Node,selected: String,_unused: Callable = Callable()) -> void:
    exit(owner,"Workshop",WORKSHOP)
    var gs: Node = owner.get_node("/root/GameState")
    var identity := Label.new()
    identity.name = "PCIdentity"
    identity.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    identity.add_theme_font_size_override("font_size",19)
    identity.text = TicketMenu.identity_text(gs.job) + "  ·  " + {"repair":"repair bench","hardware":"hardware board","monitor":"diagnostic monitor"}.get(selected,"")
    identity.position = Vector2(210,22)
    identity.size = Vector2(930,34)
    owner.add_child(identity)
    # D134/D135 (0.43.0): the identity IS the ticket. Click opens the ticket; right-click is the pickup menu.
    var ticket := Button.new()
    ticket.name = "TicketButton"
    ticket.flat = true
    ticket.focus_mode = Control.FOCUS_NONE
    ticket.position = identity.position
    ticket.size = Vector2(minf(identity.size.x,ThemeDB.fallback_font.get_string_size(identity.text,HORIZONTAL_ALIGNMENT_LEFT,-1,19).x+16.0),identity.size.y)
    ticket.tooltip_text = "This PC's ticket. Click to open it; right-click to mark it ready for pickup or call the customer."
    owner.add_child(ticket)
    var id: String = str(gs.job["id"])
    var after := func(result: Dictionary) -> void:
        identity.text = TicketMenu.identity_text(gs.job) + "  ·  " + {"repair":"repair bench","hardware":"hardware board","monitor":"diagnostic monitor"}.get(selected,"")
        if owner.has_method("_ticket_changed"): owner.call("_ticket_changed",result)
    ticket.pressed.connect(func() -> void: TicketMenu.window(owner,id,after))
    ticket.gui_input.connect(func(event: InputEvent) -> void:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            TicketMenu.popup(owner,id,owner.get_viewport().get_mouse_position(),after))
