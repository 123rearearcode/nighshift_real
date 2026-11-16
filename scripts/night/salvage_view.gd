extends "res://scripts/salvage/salvage_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
func _button(text: String,rect: Rect2,action: Callable) -> Button:
    if text == "Main menu": return Navigation.attach(self,action)
    return super._button(text,rect,action)
func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 40:
            node.position.x = 172
            node.size.x = 800
    Navigation.back(self,"Activities",Navigation.ACTIVITIES)
func _back() -> void:
    _navigate(Navigation.ACTIVITIES)
func _navigate(path: String) -> bool:
    physics.capture()
    session.cancel_hand()
    physics.sync(session,pointer)
    physics.capture()
    if not NightSession.checkpoint(GameState):
        status.text = NightSession.status
        return false
    physics.clear_bodies()
    AudioFeedback.stop_owner(self)
    return Navigation.commit(self,path)

var _paused_before_menu: bool = false
func _pause_activity() -> void:
    _paused_before_menu = session.paused
    physics.capture()
    session.cancel_hand()
    session.paused = true
    physics.sync(session,pointer)
    _refresh()
func _resume_activity() -> void:
    session.paused = _paused_before_menu
    physics.sync(session,pointer)
    _refresh()
