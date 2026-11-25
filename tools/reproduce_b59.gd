# Diagnostic for PRs #77/#78, revalidated against 0.57.6 / 842d0c2 for 0.57.7.
# Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
# Reports behavior, not a fixed-bug regression or a required CI suite. See docs/REVIEW_CONSOLIDATION.md.
# Only uniquely named disposable saves are written; no speed threshold or gameplay change.
extends SceneTree
const Store = preload("res://scripts/state/save_store.gd")
const Memory = preload("res://scripts/night/navigation_state.gd")
const COUNTER := "res://scenes/rooms/counter.tscn"
const WORKSHOP := "res://scenes/rooms/workshop.tscn"
var setup_failures: int = 0

func _initialize() -> void:
    call_deferred("run_probe")

func require(ok: bool, label: String) -> void:
    if not ok:
        setup_failures += 1
        push_error("Probe setup failed: " + label)

func remove_files(path: String) -> void:
    for suffix: String in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func put(path: String, text: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    require(file != null, "open fixture " + path)
    if file != null:
        file.store_string(text)
        file.close()

func cold(night: Node) -> void:
    night.bound_path = ""
    night.run_id = ""
    night.tickets = []

func run_probe() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    var original_path: String = gs.save_path
    for mode: String in ["valid", "missing_primary_valid_backup", "unparseable_primary_valid_backup", "unparseable_primary_valid_tmp", "no_manifest", "wrong_run_valid_backup", "inactive_pending", "active_pending", "no_pending", "valid_manifest_missing_pending_ticket"]:
        gs.save_path = "user://review_b59_%d_%s.json" % [OS.get_process_id(), mode]
        var manifest: String = gs.save_path + ".night.json"
        for path: String in [gs.save_path, manifest, gs.save_path + ".navigation.json"]: remove_files(path)
        gs.new_game(false)
        require(night.start(gs, true), "start " + mode)
        var valid: Dictionary = Store.read(manifest)
        var ids: Array = gs.opening_customers.duplicate()
        if mode == "inactive_pending": gs.opening_customers = [ids[1]]
        if mode == "active_pending": gs.opening_customers = [ids[0]]
        if mode == "no_pending": gs.opening_customers = []
        gs.save_game()
        remove_files(manifest)
        match mode:
            "valid": put(manifest, JSON.stringify(valid))
            "missing_primary_valid_backup": put(manifest + ".bak", JSON.stringify(valid))
            "unparseable_primary_valid_backup":
                put(manifest, "{broken")
                put(manifest + ".bak", JSON.stringify(valid))
            "unparseable_primary_valid_tmp":
                put(manifest, "{broken")
                put(manifest + ".tmp", JSON.stringify(valid))
            "wrong_run_valid_backup":
                var wrong := valid.duplicate(true)
                wrong["run"] = "another-run"
                put(manifest, JSON.stringify(wrong))
                put(manifest + ".bak", JSON.stringify(valid))
            "valid_manifest_missing_pending_ticket":
                var incomplete := valid.duplicate(true)
                incomplete["tickets"] = [valid["tickets"][0]]
                put(manifest, JSON.stringify(incomplete))
        cold(night)
        require(gs.load_game(), "main reload " + mode)
        var ensured: bool = night.ensure(gs)
        change_scene_to_file(COUNTER)
        for frame in range(3): await process_frame
        var counter: Node = current_scene
        var before: Array = gs.opening_customers.duplicate()
        var money: int = gs.money
        var stock: Array = gs.player_inventory.duplicate(true)
        var active: Dictionary = gs.job.duplicate(true)
        var result := {
            "case": mode, "ensure": ensured, "read_only": night.read_only,
            "pending": before.size(), "cards": night.opening_cards(gs).size(),
            "visiting": counter.visiting(), "back_door_disabled": counter.hotspot("BackDoor").disabled,
            "resume_counter": Memory.resume_path(gs) == COUNTER,
            "navigate_workshop": counter._navigate(WORKSHOP),
            "switch_pc": night.switch_pc(gs, str(ids[1])),
            "end_night": night.end_night(gs).get("ok", false)
        }
        result["accept"] = night.accept_opening_customer(gs, str(before[0])) if not before.is_empty() else false
        result["queue_unchanged"] = gs.opening_customers == before
        require(gs.money == money and gs.player_inventory == stock and gs.job == active, "ownership unchanged " + mode)
        print("B59 " + JSON.stringify(result))
        if mode == "no_manifest":
            put(manifest, JSON.stringify(valid))
            var warm: bool = night.ensure(gs)
            cold(night)
            require(gs.load_game(), "restored main reload")
            var recovered: bool = night.ensure(gs)
            print("B59 " + JSON.stringify({"case": "restore_manifest", "warm_ensure": warm, "cold_ensure": recovered, "cards": night.opening_cards(gs).size()}))
        change_scene_to_file("res://scenes/start.tscn")
        for frame in range(2): await process_frame
        for path: String in [gs.save_path, manifest, gs.save_path + ".navigation.json"]: remove_files(path)
    gs.save_path = original_path
    print("B59 probe setup/ownership failures: %d" % setup_failures)
    quit(1 if setup_failures else 0)
