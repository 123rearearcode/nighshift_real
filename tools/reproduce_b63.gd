# Optional observation of PR #88's cross-run morning backups, never a required bug-must-remain test.
# Uses one disposable slot and removes only its own generated files. Run on a tree with PR #88's module.
extends SceneTree
const BACKUPS_SCRIPT: String = "scripts/state/save_backups.gd"


func _initialize() -> void:
    call_deferred("run")


func run() -> void:
    if not FileAccess.file_exists("res://" + BACKUPS_SCRIPT):
        print("B63 diagnostic needs PR #88's save_backups.gd; no save was changed.")
        quit()
        return
    var backups: Variant = load("res://" + BACKUPS_SCRIPT)
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    var original: String = gs.save_path
    gs.save_path = "user://b63_review_%d_%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
    gs.new_game(false)
    if not night.start(gs, true):
        push_error("B63 fixture could not start: " + night.status)
        quit(1)
        return
    var old_run: String = night.run_id
    gs.money = 777
    for day in [20, 21, 22]:
        gs.night_number = day
        if not night.checkpoint(gs) or not backups.take(gs.save_path, day):
            push_error("B63 fixture could not save its morning.")
            quit(1)
            return
    gs.new_game(false)
    night.start(gs, true)
    print("B63 new_run_differs=", old_run != night.run_id, " cash=", gs.money, " retained=", backups.mornings(gs.save_path))
    for extra: String in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(gs.save_path + ".night.json" + extra)
    night.bound_path = ""
    night.run_id = ""
    night.tickets = []
    gs.load_game()
    var protected: bool = not night.ensure(gs)
    var restored: bool = night.restore_morning(gs)
    print("B63 protected=", protected, " restored=", restored, " cash=", gs.money,
        " night=", gs.night_number, " restored_old_run=", night.run_id == old_run)
    var dir: String = backups.folder(gs.save_path)
    for sub: String in DirAccess.get_directories_at(dir):
        for file: String in DirAccess.get_files_at(dir.path_join(sub)):
            DirAccess.remove_absolute(dir.path_join(sub).path_join(file))
        DirAccess.remove_absolute(dir.path_join(sub))
    DirAccess.remove_absolute(dir)
    for suffix: String in ["", ".night.json", ".navigation.json"]:
        for extra: String in ["", ".bak", ".tmp"]:
            DirAccess.remove_absolute(gs.save_path + suffix + extra)
    gs.save_path = original
    quit()
