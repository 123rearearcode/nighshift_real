extends "res://scripts/salvage/salvage_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
func _button(text: String,rect: Rect2,action: Callable) -> Button:
    if text == "Main menu": return Navigation.exit(self,"Outside",Navigation.OUTSIDE)   # 0.53.0: back out to the street
    if text == "Unload to demo shelf": text = "Unload into stock"   # 0.50.0 (D158): finds become real stock
    return super._button(text,rect,action)

# 0.50.0 (user, D158): unloading at the shop puts the finds into the shop's stock as UNTESTED parts
# (or scrap for what the shop cannot stock). Their real condition stays hidden until the testing bay.
func _unload() -> void:
    var finds: Array = []
    for uid: String in session.cargo[session.car]:
        var item: Dictionary = session.cargo[session.car][uid]
        finds.append({"uid":"%d:%s"%[GameState.night_number,uid],"kind":str(item.get("kind","")),"condition":str(item.get("condition",""))})
    var count: int = session.unload()
    if count > 0:
        var got: Dictionary = GameState.receive_salvage(finds)
        var saved: bool = NightSession.checkpoint(GameState)
        session.message = "%d finds unloaded: %d part%s added to your stock as UNTESTED (check them at the testing bay); the rest sold as scrap for $%d.%s"%[count,(got["added"] as Array).size(),"" if (got["added"] as Array).size() == 1 else "s",int(got["scrap_cash"]),"" if saved else " "+NightSession.status]
    _refresh()
func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 40:
            node.position.x = 210
            node.size.x = 760
func _back() -> void:
    _navigate(Navigation.OUTSIDE)
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
