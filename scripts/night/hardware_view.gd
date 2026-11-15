extends "res://scripts/view/workshop_view.gd"
func _button(text: String,pos: Vector2,size: Vector2,callback: Callable) -> void:
    if text == "Back to shop":
        super._button("Workshop / choose PC",pos,size,func() -> void: get_tree().change_scene_to_file("res://scenes/night_workshop.tscn"))
    else: super._button(text,pos,size,callback)
