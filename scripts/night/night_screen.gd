# Shared helpers for the plain close-up screens (the testing bay, the tool shop). Until 0.52.0 this file was
# the Activities hub (activities_view.gd); 0.53.0 (D161) replaced the hub with the shop's rooms
# (scripts/rooms/), and only these helpers remain.
extends Node2D
const Navigation = preload("res://scripts/night/night_navigation.gd")
const NightClock = preload("res://scripts/rules/night_clock.gd")
var message: Label

func _label(text: String,at: Vector2,area: Vector2,size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",size)
    add_child(label)
    return label
func _button(text: String,rect: Rect2,path: String) -> Button:
    var button := Button.new()
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.add_theme_font_size_override("font_size",20)
    if path != "": button.pressed.connect(_go.bind(path))
    button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(button)
    return button
func _go(path: String) -> void:
    _navigate(path)
func _navigate(path: String) -> bool:
    if not NightSession.checkpoint(GameState):
        if is_instance_valid(message): message.text = NightSession.status
        return false
    return Navigation.commit(self,path)
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
