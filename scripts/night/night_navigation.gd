# Stable destination header. Cleanup/validation belongs to the current scene, not the tabs.
extends RefCounted
const Memory = preload("res://scripts/night/navigation_state.gd")
const Pause = preload("res://scripts/night/pause_menu.gd")
const ACTIVITIES := "res://scenes/activities.tscn"
const ROOM := "res://scenes/storage.tscn"
const REPAIR := "res://scenes/night_bench.tscn"
const HARDWARE := "res://scenes/night_hardware.tscn"
const MONITOR := "res://scenes/software.tscn"
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
    identity.text = "%s · %s · %s PC"%[gs.job["customer"],gs.job["id"],str(gs.job.get("layout","tower")).capitalize()]
    identity.position = Vector2(172,22)
    identity.size = Vector2(806,34)
    owner.add_child(identity)
    var entries: Array = [["repair","Repair",REPAIR],["hardware","Hardware",HARDWARE],["monitor","Diagnostic monitor",MONITOR]]
    for i in range(entries.size()):
        var entry: Array = entries[i]
        var button := _button(owner,entry[0].capitalize()+"Tab",entry[1],Rect2(24+i*230,64,218,32),func() -> void: _route(owner,entry[2]))
        button.tooltip_text = "Same PC, different view. Saves installed work; cancels uncommitted held actions or an unlocked cooler mount."
        button.toggle_mode = true
        button.set_pressed_no_signal(selected == entry[0])
        button.disabled = selected == entry[0]
