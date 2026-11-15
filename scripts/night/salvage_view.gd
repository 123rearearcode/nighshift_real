extends "res://scripts/salvage/salvage_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
func _button(text: String,rect: Rect2,action: Callable) -> Button:
    if text == "Main menu": return Navigation.attach(self,action)
    return super._button(text,rect,action)
func _back() -> void:
    physics.capture()
    session.cancel_hand()
    physics.sync(session,pointer)
    physics.capture()
    physics.clear_bodies()
    AudioFeedback.stop_owner(self)
    get_tree().change_scene_to_file("res://scenes/activities.tscn")
