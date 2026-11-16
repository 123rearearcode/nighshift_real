# Compatibility route only: old bookmarks open the selected PC directly, never an extra menu.
extends Node2D
func _ready() -> void:
    call_deferred("_redirect")
func _redirect() -> void:
    if not NightSession.ensure(GameState) or GameState.job.get("hardware_trial",{}).get("night_session",{}).get("pc","") == "":
        get_tree().change_scene_to_file("res://scenes/storage.tscn")
        return
    get_tree().change_scene_to_file("res://scenes/night_bench.tscn")
