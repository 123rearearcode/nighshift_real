# Title/menu presentation only. The existing shop is the current playable demo.
extends Node2D
const Layout = preload("res://scripts/data/layout.gd")

const DEMO: String = "res://scenes/shop.tscn"
var load_button: Button
var status_label: Label
var replace_dialog: ConfirmationDialog
var achievements_dialog: AcceptDialog


func _ready() -> void:
    _label("NIGHTSHIFT", Vector2(440, 140), Vector2(400, 65), 48)
    _label("PC REPAIR / FOUNDATION DEMO", Vector2(440, 208), Vector2(400, 36), 17)
    var first: Button = _button("New game", 300, _on_new_game)
    load_button = _button("Load game", 366, _on_load_game)
    load_button.disabled = not GameState.has_saved_game()
    load_button.tooltip_text = "Resume your saved demo." if not load_button.disabled else "No readable save yet. Start a new game."
    _button("Achievements", 432, _on_achievements)
    status_label = _label("New game opens the current repair-shop demo.", Vector2(380, 515), Vector2(520, 60), 16)
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


func _on_achievements() -> void:
    achievements_dialog.popup_centered(Vector2i(440, 160))


func _draw() -> void:
    draw_rect(Layout.SCREEN, Color("141b24"))
    draw_rect(Layout.START_CARD, Color("202d39"))
    draw_rect(Layout.START_CARD, Color("526d7a"), false, 2.0)
    draw_line(Vector2(460, 266), Vector2(820, 266), Color("dfad66"), 3.0)
