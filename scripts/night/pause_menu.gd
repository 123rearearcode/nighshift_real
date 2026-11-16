# One pause surface for every night activity. Physics/timed tests stop via SceneTree.paused.
extends CanvasLayer
var route: Callable
var shade: ColorRect
var settings: AcceptDialog
var slider: HSlider
var note: Label
var was_paused: bool = false
var resume_warning: String = ""
func _ready() -> void:
    name = "PauseMenu"
    layer = 100
    process_mode = Node.PROCESS_MODE_ALWAYS
    shade = ColorRect.new()
    shade.color = Color(0,0,0,0.78)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    var panel := PanelContainer.new()
    panel.position = Vector2(420,170)
    panel.size = Vector2(440,360)
    shade.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",16)
    panel.add_child(box)
    var title := Label.new()
    title.text = "PAUSED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    _button(box,"Resume",close)
    _button(box,"Settings",_settings)
    _button(box,"Title screen",_title)
    note = Label.new()
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.custom_minimum_size = Vector2(400,48)
    box.add_child(note)
    settings = AcceptDialog.new()
    settings.title = "Settings"
    settings.ok_button_text = "Done"
    var body := VBoxContainer.new()
    var label := Label.new()
    label.text = "Sound volume"
    body.add_child(label)
    slider = HSlider.new()
    slider.max_value = 100
    slider.custom_minimum_size = Vector2(340,40)
    slider.value_changed.connect(func(value: float) -> void: get_node("/root/GameState").set_sound_volume(value/100.0))
    body.add_child(slider)
    settings.add_child(body)
    add_child(settings)
    shade.hide()
func _button(box: VBoxContainer,text: String,action: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(400,52)
    button.pressed.connect(action)
    box.add_child(button)
func open() -> void:
    if shade.visible: return
    if get_parent().has_method("_pause_activity"): get_parent().call("_pause_activity")
    was_paused = get_tree().paused
    get_tree().paused = true
    note.text = "Activities chooses what to do tonight. Title screen leaves the game session."
    if resume_warning != "": note.text += "\n"+resume_warning
    shade.show()
func close() -> void:
    if not shade.visible: return
    settings.hide()
    shade.hide()
    get_tree().paused = was_paused
    if get_parent().has_method("_resume_activity"): get_parent().call("_resume_activity")
func _settings() -> void:
    slider.set_value_no_signal(get_node("/root/GameState").sound_volume*100.0)
    settings.popup_centered(Vector2i(400,160))
func _title() -> void:
    var tree: SceneTree = get_tree()
    var activity: Node = get_parent()
    if activity.has_method("_resume_activity"): activity.call("_resume_activity")
    if bool(route.call("res://scenes/start.tscn")):
        tree.paused = false
    else:
        if activity.has_method("_pause_activity"): activity.call("_pause_activity")
        note.text = "Could not leave. Resume to finish a running test or resolve the visible save error."
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F10:
            if shade.visible: close()
            else: open()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE and shade.visible:
            if settings.visible: settings.hide()
            else: close()
            get_viewport().set_input_as_handled()
func _exit_tree() -> void:
    if shade != null and shade.visible: get_tree().paused = false
