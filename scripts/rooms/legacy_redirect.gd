# 0.53.0 (D161): the Activities hub and the morning report screen were retired; the counter replaced both.
# Old links and saved preferences that still name those scenes land here and continue at the counter.
extends Node
func _ready() -> void:
    get_tree().call_deferred("change_scene_to_file", "res://scenes/rooms/counter.tscn")
