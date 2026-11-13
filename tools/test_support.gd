# Shared helpers for the headless test suites (docs/WORK_PLAN.md, Phase 1 step 1).
# A suite starts with `extends "res://tools/test_support.gd"` instead of `extends SceneTree`, calls
# check() for each expectation and ends with finish("<Suite name>"). The summary line finish() prints,
# "<Suite name> checks: N, failures: M", is what the GitHub workflow looks for. Not part of the game.
extends SceneTree

var checks: int = 0
var failed: int = 0
var _original_save_path: String = ""


# One expectation. A failure is reported as "FAIL: <label>" (an error in the log) and counted.
func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: " + label)


# Point the GameState autoload at a disposable save file, so a suite never touches the player's save.
func use_test_save(gs: Node, file_name: String) -> void:
    _original_save_path = gs.save_path
    gs.save_path = "user://" + file_name
    _remove_save_files(gs.save_path)


# Delete the disposable save (and its .bak/.tmp) and point GameState back at the real save path.
func restore_save(gs: Node) -> void:
    _remove_save_files(gs.save_path)
    if _original_save_path != "":
        gs.save_path = _original_save_path


func _remove_save_files(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(path + suffix):
            DirAccess.remove_absolute(path + suffix)


# A real mouse button event sent straight to a scene's input handler (no window needed).
func click(target: Node, button: int, pressed: bool, at: Vector2) -> void:
    var event := InputEventMouseButton.new()
    event.button_index = button
    event.pressed = pressed
    event.position = at
    target._input(event)


# Print the summary line and quit with exit code 1 if anything failed.
func finish(suite: String) -> void:
    print("%s checks: %d, failures: %d" % [suite, checks, failed])
    quit(1 if failed else 0)
