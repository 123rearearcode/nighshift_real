extends "res://scripts/view/workshop_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 32:
            node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            node.add_theme_font_size_override("font_size",18)
            node.size.x = 1040
    Navigation.attach(self,_activities)
func _activities() -> void:
    inventory.cancel()
    _settle_all_throws()
    _save_inventory()
    if NightSession.checkpoint(GameState): get_tree().change_scene_to_file(Navigation.ACTIVITIES)
    else: status_label.text = NightSession.status
func _button(text: String,pos: Vector2,size: Vector2,callback: Callable) -> void:
    if text == "Back to shop":
        super._button("Workshop / room",pos,size,func() -> void: get_tree().change_scene_to_file("res://scenes/night_workshop.tscn"))
    else: super._button(text,pos,size,callback)
