# Draw-only child of a clipped Control. The parent owns input and room rules.
extends Node2D
var view: Node
func _draw() -> void:
    if is_instance_valid(view): view.draw_room(self)
