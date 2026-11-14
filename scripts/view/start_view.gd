# Title/menu presentation only. The existing shop is the current playable demo.
extends Node2D
const Layout = preload("res://scripts/data/layout.gd")

const DEMO: String = "res://scenes/shop.tscn"
var load_button: Button
var status_label: Label
var replace_dialog: ConfirmationDialog
var achievements_dialog: AcceptDialog
var settings_dialog: AcceptDialog
var volume_slider: HSlider
var volume_label: Label


func _ready() -> void:
    _label("NIGHTSHIFT", Vector2(440, 140), Vector2(400, 65), 48)
    _label("PC REPAIR / FOUNDATION DEMO", Vector2(440, 208), Vector2(400, 36), 17)
    var first: Button = _button("New game", 284, _on_new_game)
    load_button = _button("Load game", 342, _on_load_game)
    load_button.disabled = not GameState.has_saved_game()
    load_button.tooltip_text = "Resume your saved demo." if not load_button.disabled else "No readable save yet. Start a new game."
    _button("Achievements", 400, _on_achievements)
    _button("Salvage demo", 458, _on_salvage)
    _button("Settings", 516, _on_settings)
    status_label = _label("New game opens the repair shop. The salvage demo never touches your save.", Vector2(420, 578), Vector2(440, 42), 13)
    _label("v%s" % GameState.game_version(), Vector2(440, 660), Vector2(400, 24), 13)
    replace_dialog = ConfirmationDialog.new()
    replace_dialog.title = "Start a new game?"
    replace_dialog.dialog_text = "This replaces your saved demo progress."
    replace_dialog.ok_button_text = "Start new game"
    replace_dialog.confirmed.connect(_start_new_game)
    add_child(replace_dialog)
    achievements_dialog = AcceptDialog.new()
    achievements_dialog.title = "Achievements"
    achievements_dialog.dialog_text = "Achievements are not available in this demo yet."
    add_child(achievements_dialog)
    _build_settings_dialog()
    first.grab_focus()


func _label(text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    add_child(label)
    return label


func _button(text: String, y: float, action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.position = Vector2(460, y)
    button.size = Vector2(360, 52)
    button.add_theme_font_size_override("font_size", 22)
    button.pressed.connect(action)
    button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(button)
    return button


func _on_new_game() -> void:
    if GameState.has_saved_game():
        replace_dialog.popup_centered(Vector2i(440, 160))
    else:
        _start_new_game()


func _start_new_game() -> void:
    GameState.new_game()
    get_tree().change_scene_to_file(DEMO)


func _on_load_game() -> void:
    if GameState.load_game():
        get_tree().change_scene_to_file(DEMO)
    else:
        load_button.disabled = true
        status_label.text = "No readable save was found. Start a new game."


func _on_salvage() -> void:
    get_tree().change_scene_to_file("res://scenes/salvage.tscn")


# Settings (D107): just the sound slider for now. The value applies as it moves and is kept
# in its own settings file, so it survives new games and never touches the save.
func _build_settings_dialog() -> void:
    settings_dialog = AcceptDialog.new()
    settings_dialog.title = "Settings"
    settings_dialog.ok_button_text = "Done"
    var box := VBoxContainer.new()
    box.custom_minimum_size = Vector2(360, 86)
    box.add_theme_constant_override("separation", 12)
    volume_label = Label.new()
    volume_label.add_theme_font_size_override("font_size", 17)
    box.add_child(volume_label)
    volume_slider = HSlider.new()
    volume_slider.min_value = 0
    volume_slider.max_value = 100
    volume_slider.step = 1
    volume_slider.custom_minimum_size = Vector2(340, 24)
    volume_slider.value_changed.connect(_on_volume_changed)
    box.add_child(volume_slider)
    settings_dialog.add_child(box)
    add_child(settings_dialog)


func _on_settings() -> void:
    volume_slider.set_value_no_signal(roundf(GameState.sound_volume * 100.0))
    _update_volume_label()
    settings_dialog.popup_centered(Vector2i(420, 190))


func _on_volume_changed(value: float) -> void:
    GameState.set_sound_volume(value / 100.0)
    _update_volume_label()


func _update_volume_label() -> void:
    volume_label.text = "Sound volume: %d%%" % roundi(volume_slider.value)


func _on_achievements() -> void:
    achievements_dialog.popup_centered(Vector2i(440, 160))


func _draw() -> void:
    draw_rect(Layout.SCREEN, Color("141b24"))
    draw_rect(Layout.START_CARD, Color("202d39"))
    draw_rect(Layout.START_CARD, Color("526d7a"), false, 2.0)
    draw_line(Vector2(460, 266), Vector2(820, 266), Color("dfad66"), 3.0)
