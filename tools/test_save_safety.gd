# 0.57.11 (B59): save safety. A ticket book from another run no longer hides the good backup beside it;
# every morning is backed up and the last 3 are kept; a damaged ticket book at the counter offers the
# morning backup instead of a dead end, and a restore never deletes the player's own files.
# User, 27 November 2026: "automatically save every morning, and keep backups up to 3 days before";
# "try to restore it". Fixtures follow tools/reproduce_b59.gd (Codex's diagnostic).
extends "res://tools/test_support.gd"
const Store = preload("res://scripts/state/save_store.gd")
const Backups = preload("res://scripts/state/save_backups.gd")
const COUNTER := "res://scenes/rooms/counter.tscn"


func _initialize() -> void:
    call_deferred("run_checks")


func put(path: String, text: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file != null:
        file.store_string(text)
        file.close()


func remove_family(path: String) -> void:
    for suffix: String in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)


func cold(night: Node) -> void:
    night.bound_path = ""
    night.run_id = ""
    night.tickets = []


func clear_backups(gs: Node) -> void:
    var dir: String = Backups.folder(gs.save_path)
    if not DirAccess.dir_exists_absolute(dir): return
    for sub: String in DirAccess.get_directories_at(dir):
        for file: String in DirAccess.get_files_at(dir.path_join(sub)): DirAccess.remove_absolute(dir.path_join(sub).path_join(file))
        DirAccess.remove_absolute(dir.path_join(sub))


func set_asides(gs: Node) -> Array:
    var dir: String = Backups.folder(gs.save_path)
    if not DirAccess.dir_exists_absolute(dir): return []
    return Array(DirAccess.get_directories_at(dir)).filter(func(name: String) -> bool: return name.begins_with("damaged_"))


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "save_safety_test.json")
    var manifest: String = gs.save_path + ".night.json"
    for path: String in [manifest, gs.save_path + ".navigation.json"]: remove_family(path)
    clear_backups(gs)

    # ---- SaveStore: a refused candidate is skipped like a damaged one ----
    var probe: String = "user://save_safety_probe.json"
    put(probe, JSON.stringify({"run": "a"}))
    put(probe + ".bak", JSON.stringify({"run": "b"}))
    var plain: Variant = Store.read(probe)
    var picky: Variant = Store.read(probe, func(data: Dictionary) -> bool: return data.get("run", "") == "b")
    var none: Variant = Store.read(probe, func(_data: Dictionary) -> bool: return false)
    check(plain is Dictionary and plain["run"] == "a" and picky is Dictionary and picky["run"] == "b" and none == null, "a save the reader refuses is skipped and the backup beside it is read instead")
    remove_family(probe)

    # ---- the first morning is backed up when the game starts ----
    gs.new_game(false)
    check(night.start(gs, true) and gs.opening_customers.size() == 2, "a new game starts with its two opening customers")
    var first: String = "morning_%04d" % int(gs.night_number)
    check(Backups.mornings(gs.save_path) == [first], "the first morning is backed up as soon as the game starts")
    var kept: String = Backups.folder(gs.save_path).path_join(first)
    check(FileAccess.file_exists(kept.path_join(gs.save_path.get_file())) and FileAccess.file_exists(kept.path_join(manifest.get_file())), "the backup holds the save and its ticket book")

    # ---- B59, second fault: a ticket book from another run hid the good backup ----
    var valid: Dictionary = Store.read(manifest)
    var wrong: Dictionary = valid.duplicate(true)
    wrong["run"] = "another-run"
    remove_family(manifest)
    put(manifest, JSON.stringify(wrong))
    put(manifest + ".bak", JSON.stringify(valid))
    cold(night)
    check(gs.load_game() and night.ensure(gs) and not night.read_only and night.opening_cards(gs).size() == 2, "B59: a ticket book from another run no longer hides the good backup beside it")

    # ---- B59: the ticket book is gone while customers wait at the counter ----
    remove_family(manifest)
    cold(night)
    gs.load_game()
    change_scene_to_file(COUNTER)
    for f in range(4): await process_frame
    var counter: Node = current_scene
    var recovery: Control = counter.get_node_or_null("RecoverySlip")
    check(recovery != null and recovery.visible and counter.restore_button != null and not counter.slip.visible, "B59: with the ticket book gone, the counter offers the morning backup instead of a dead end")
    var save_before: String = FileAccess.get_file_as_string(gs.save_path)
    if counter.restore_button != null: counter.restore_button.emit_signal("pressed")
    for f in range(6): await process_frame
    check(night.ensure(gs) and not night.read_only and gs.opening_customers.size() == 2 and night.opening_cards(gs).size() == 2, "B59: restoring brings back this morning's ticket book with both waiting customers")
    var again: Node = current_scene
    check(again != counter and again.slip.visible and not again.recovery_slip.visible and str(again.message.text).contains("morning of night"), "the counter starts again from that morning, with the first customer and a note saying what was restored")
    var aside: Array = set_asides(gs)
    check(aside.size() == 1 and FileAccess.get_file_as_string(Backups.folder(gs.save_path).path_join(str(aside[0])).path_join(gs.save_path.get_file())) == save_before, "the damaged files are kept aside, never deleted")
    check(night.accept_opening_customer(gs, str(gs.opening_customers[0])) and night.accept_opening_customer(gs, str(gs.opening_customers[0])) and gs.opening_customers.is_empty(), "both customers can be accepted again")

    # ---- every morning is backed up ----
    var report: Dictionary = night.end_night(gs)
    check(bool(report.get("ok", false)) and Backups.mornings(gs.save_path)[0] == "morning_%04d" % int(gs.night_number), "ending the night backs up the new morning")

    # ---- a backup that does not fix it is not left in place ----
    clear_backups(gs)
    remove_family(manifest)
    check(Backups.take(gs.save_path, 99), "a backup can be taken without a ticket book (to test a useless one)")
    cold(night)
    gs.load_game()
    var own: String = FileAccess.get_file_as_string(gs.save_path)
    check(not night.restore_morning(gs) and night.read_only and FileAccess.get_file_as_string(gs.save_path) == own and set_asides(gs).size() == 2, "a backup that cannot fix it is refused and the player's own save is put back (and also kept aside)")

    # ---- only the last 3 mornings are kept ----
    clear_backups(gs)
    for n in range(5): Backups.take(gs.save_path, 20 + n)
    check(Backups.mornings(gs.save_path) == ["morning_0024", "morning_0023", "morning_0022"], "only the newest three mornings are kept")

    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [manifest, gs.save_path + ".navigation.json"]: remove_family(path)
    cold(night)
    restore_save(gs)
    check(not DirAccess.dir_exists_absolute(Backups.folder("user://save_safety_test.json")), "a disposable test save takes its backups with it")
    finish("Save safety")
