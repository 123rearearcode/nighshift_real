# Stable destination header. Cleanup/validation belongs to the current scene, not the tabs.
extends RefCounted
const Memory = preload("res://scripts/night/navigation_state.gd")
const Pause = preload("res://scripts/night/pause_menu.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const ACTIVITIES := "res://scenes/activities.tscn"
const ROOM := "res://scenes/storage.tscn"
const REPAIR := "res://scenes/night_bench.tscn"
const HARDWARE := "res://scenes/night_hardware.tscn"
const MONITOR := "res://scenes/software.tscn"
const BAY := "res://scenes/night_bay.tscn"   # 0.50.0: Activities > Testing bay
const RECT := Rect2(1100,20,152,42)
static func commit(owner: Node,path: String) -> bool:
    if path == "res://scenes/night_workshop.tscn": path = REPAIR # legacy link, no service-menu detour
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
    var button := _button(owner,"PauseButton","Pause",Rect2(1000,20,88,42),layer.open)
    button.tooltip_text = "Pause / settings / title screen · F10. Esc closes pause; outside pause it keeps the activity's controls."
    if owner.scene_file_path != "" and not Memory.enter(owner.get_node("/root/GameState"),owner.scene_file_path):
        layer.resume_warning = "The last-view preference could not be saved. Continue may return to Activities."
static func attach(owner: Node,action: Callable) -> Button:
    pause(owner)
    return _button(owner,"ActivitiesButton","Activities",RECT,action)
static func back(owner: Node,label: String,path: String) -> void:
    _button(owner,"BackButton","← "+label,Rect2(24,20,128,42),func() -> void: _route(owner,path))
static func workbench(owner: Node,selected: String,activities_action: Callable) -> void:
    attach(owner,activities_action)
    back(owner,"Room",ROOM)
    var gs: Node = owner.get_node("/root/GameState")
    var identity := Label.new()
    identity.name = "PCIdentity"
    identity.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    identity.add_theme_font_size_override("font_size",19)
    identity.text = TicketMenu.identity_text(gs.job)
    identity.position = Vector2(172,22)
    identity.size = Vector2(806,34)
    owner.add_child(identity)
    # D134/D135 (0.43.0): the identity IS the ticket. Click opens the ticket; right-click is the pickup menu.
    # It is the ticket's own object, not a navigation or service control, so the header layout is unchanged.
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
        identity.text = TicketMenu.identity_text(gs.job)
        if owner.has_method("_ticket_changed"): owner.call("_ticket_changed",result)
    ticket.pressed.connect(func() -> void: TicketMenu.window(owner,id,after))
    ticket.gui_input.connect(func(event: InputEvent) -> void:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            TicketMenu.popup(owner,id,owner.get_viewport().get_mouse_position(),after))
    var entries: Array = [["repair","Repair",REPAIR],["hardware","Hardware",HARDWARE],["monitor","Diagnostic monitor",MONITOR]]
    for i in range(entries.size()):
        var entry: Array = entries[i]
        var button := _button(owner,entry[0].capitalize()+"Tab",entry[1],Rect2(24+i*230,64,218,32),func() -> void: _route(owner,entry[2]))
        button.tooltip_text = "Same PC, different view. Saves installed work; cancels uncommitted held actions or an unlocked cooler mount."
        button.toggle_mode = true
        button.set_pressed_no_signal(selected == entry[0])
        button.disabled = selected == entry[0]
        # 0.51.0 (D159): a new build has nothing to clean or repaste: its cooler goes on at the hardware bench.
        if entry[0] == "repair" and str(gs.job.get("ticket",{}).get("request","")) == "build":
            button.disabled = true
            button.tooltip_text = "A new build: nothing to clean or repaste. Coolers go on with their pre-applied paste at the hardware bench."
