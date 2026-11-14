# Additive navigation/automatic paste commit only; legacy bench input/physics stays untouched.
extends "res://scripts/view/bench_view.gd"
func _on_back_pressed() -> void:
    _cancel_unlocked_mount()
    _save_dust()
    NightSession.checkpoint(GameState)
    get_tree().change_scene_to_file("res://scenes/night_workshop.tscn")
func _new_ticket() -> void:
    _on_back_pressed() # never destroy the selected customer's PC from a practice/reset button
func _build_ui() -> void:
    super._build_ui()
    for node: Node in get_children():
        if node is Button and node.text == "Back to shop": node.text = "Switch PC / workshop"
        elif node is Button and node.text.contains("dirty PC"): node.text = "Choose another PC"
    complete_button.visible = false
func _step_paste(delta: float,mouse: Vector2) -> void:
    super._step_paste(delta,mouse)
    complete_button.visible = false
func _finish_mount() -> void:
    if not mount.active: return
    super._finish_mount()
    if GameState.can_complete_repaste():
        var result: Dictionary = GameState.complete_repaste(paste.material)
        if not result["ok"]: _set_status(result["message"],2)
        else: _sound("cooler.complete",{"material":paste.material,"grade":str(GameState.job["paste_grade"])})

func _select_stage(which: int) -> void:
    super._select_stage(which)
    var instruction: String = title_label.text.get_slice("\n",1)
    title_label.text = "NIGHTSHIFT / %s / %s\n%s"%[GameState.job["id"],GameState.job["customer"],instruction]
    complete_button.visible = false

const PasteSnapshot = preload("res://scripts/night/paste_snapshot.gd")
func _ready() -> void:
    super._ready()
    if PasteSnapshot.restore(paste,GameState.job["hardware_trial"].get("night_paste",{})):
        if str(GameState.job["paste_grade"]) != "": mount_result = paste.evaluate()
        paste_dirty = true
        _refresh_material_button()
        _refresh_paste_image()
func _save_dust() -> void:
    if loaded_job_id == str(GameState.job["id"]):
        GameState.job["hardware_trial"]["night_paste"] = PasteSnapshot.capture(paste)
    super._save_dust()
func _on_material_toggled() -> void:
    super._on_material_toggled()
    if paste.material == "thermal": _set_status("Thermal paste is charged automatically when a good cooler mount is locked with the lever.",0)
