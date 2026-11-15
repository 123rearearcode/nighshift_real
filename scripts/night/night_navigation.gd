# Common night-hub exit. Scene owners supply cleanup/save behavior before navigating.
extends RefCounted
const ACTIVITIES := "res://scenes/activities.tscn"
const RECT := Rect2(1100,20,152,42)
static func attach(owner: Node,action: Callable) -> Button:
    var button := Button.new()
    button.name = "ActivitiesButton"
    button.text = "Activities"
    button.position = RECT.position
    button.size = RECT.size
    button.add_theme_font_size_override("font_size",17)
    button.pressed.connect(func() -> void: owner.get_node("/root/AudioFeedback").request(owner,"ui.click"))
    button.pressed.connect(action)
    owner.add_child(button)
    return button
