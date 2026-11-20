# Additive navigation/automatic paste commit only; legacy bench input/physics stays untouched.
extends "res://scripts/view/bench_view.gd"
var navigation_ready: bool = false
const Navigation = preload("res://scripts/night/night_navigation.gd")
func _on_back_pressed() -> void:
    _return_to(Navigation.ROOM)
func _navigate(path: String) -> bool:
    return _return_to(path)
func _return_to(path: String) -> bool:
    _cancel_unlocked_mount()
    _save_dust()
    if not NightSession.checkpoint(GameState):
        _set_status(NightSession.status,2)
        return false
    Navigation.Memory.set_repair_stage(GameState,stage)
    return Navigation.commit(self,path)
# 0.48.1: closing the game on the bench is leaving it too: an unlocked press is cancelled (no result),
# the paste stays as pressed and is saved with the PC, and the vacuum keeps its contents.
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST and loaded_job_id == str(GameState.job["id"]):
        _cancel_unlocked_mount()
        _save_dust()
        NightSession.checkpoint(GameState)
func _new_ticket() -> void:
    _on_back_pressed() # never destroy the selected customer's PC from a practice/reset button
func _build_ui() -> void:
    super._build_ui()
    title_label.hide()
    Navigation.workbench(self,"repair",_return_to.bind(Navigation.ACTIVITIES))
    # 0.51.0 (D159): a build has nothing to clean or repaste; an old link or preference lands here only by
    # mistake. Leave for the hardware bench without saving anything from this bench.
    if str(GameState.job.get("ticket",{}).get("request","")) == "build":
        set_process(false)
        set_process_input(false)
        call_deferred("_leave_build")
    for node: Node in get_children():
        if node is Button and node.text == "Back to shop": node.hide()
        elif node is Button and node.text.contains("dirty PC"): node.hide()
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
    for node: Node in get_children():
        if node is Button and node.text.contains("dirty PC"): node.hide()
    if stage == STAGE_CLEAN and _done_count() == zones.size():
        _set_status("Cleaning target met. Continue to Thermal service, or change PCs in Room.",1)
    if navigation_ready: Navigation.Memory.set_repair_stage(GameState,which)

const PasteSnapshot = preload("res://scripts/night/paste_snapshot.gd")
const Findings = preload("res://scripts/rules/findings.gd")
func _ready() -> void:
    super._ready()
    if PasteSnapshot.restore(paste,GameState.job["hardware_trial"].get("night_paste",{})):
        if str(GameState.job["paste_grade"]) != "": mount_result = paste.evaluate()
        paste_dirty = true
        _refresh_material_button()
        _refresh_paste_image()
    _select_stage(Navigation.Memory.repair_stage(GameState))
    navigation_ready = true
    # D150 (0.47.0): opening the case is an inspection; Findings keeps what it shows.
    GameState.record_finding(Findings.OBSERVATION, Findings.repair_bench_observation(GameState.job), "repair_bench")
func _save_dust() -> void:
    if loaded_job_id == str(GameState.job["id"]):
        GameState.job["hardware_trial"]["night_paste"] = PasteSnapshot.capture(paste)
    super._save_dust()
func _material_charge_note() -> String:
    return ", charged automatically when a good cooler mount is locked"

func _pause_activity() -> void:
    holding = false
    tools.active = false
    AudioFeedback.stop_owner(self)
func _leave_build() -> void:
    if is_inside_tree(): Navigation.commit(self,Navigation.HARDWARE)
