extends "res://tools/test_support.gd"
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const SafeStore = preload("res://scripts/state/save_store.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Paste = preload("res://scripts/bench/paste_sim.gd")
const Snapshot = preload("res://scripts/night/paste_snapshot.gd")
func _initialize() -> void:
    call_deferred("run_checks")
func pcs(items: Dictionary) -> int:
    var count: int = 0
    for item: Dictionary in items.values():
        if item["category"] == "pc": count += 1
    return count
func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs,"night_workshop_test.json")
    var manifest: String = gs.save_path+".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0 # deterministic fixture; real New game retains the shop rotation counter
    gs.new_game(false)
    check(night.start(gs),"new night manifests save successfully")
    check(night.tickets.size() == 2 and pcs(Sources.collect(gs)) == 2,"two actual repair tickets produce two customer PCs")
    var first: String = night.active_id
    var second: String = night.tickets[1]["id"]
    check(night.tickets[0]["customer_id"] != night.tickets[1]["customer_id"],"extra repair belongs to the other existing customer")
    var model := Model.new()
    model.setup(Sources.collect(gs))
    check(model.overflow().is_empty() and model.can_place("missing","missing",0,Vector2i.ZERO,0) == false,"three-shelf starter rack fits both PCs and current stock")
    var money: int = gs.money
    var stock: Array = gs.player_inventory.duplicate(true)
    gs.job["dust"]["cooler"] = 0.42
    gs.job["removed_parts"] = ["cooler"]
    gs.job["scams"] = ["toothpaste"]
    gs.job["hardware_trial"]["night_paste"] = {"test":"first-only"}
    check(night.switch_pc(gs,second),"switch accepts another actual PC without completing first")
    check(gs.job["id"] == second and gs.job["removed_parts"].is_empty() and gs.job["dust"]["cooler"] == 0,"second PC starts with its own dirty and assembled state")
    check(gs.money == money and gs.player_inventory == stock,"switch does not pay or clone stock")
    gs.job["dust"]["gpu"] = 0.76
    gs.job["removed_parts"] = ["gpu"]
    check(gs.replace_service_part("gpu","similar"),"existing repair stock can be fitted to the second ticket")
    var remaining: int = gs.player_inventory.size()
    check(remaining == stock.size()-1,"replacement consumes one canonical owned part")
    check(night.switch_pc(gs,first),"unfinished PC can be selected again")
    check(gs.job["removed_parts"] == ["cooler"] and is_equal_approx(gs.job["dust"]["cooler"],0.42) and gs.job["scams"] == ["toothpaste"],"dust, removed parts and scams stay with the first PC")
    check(gs.job["hardware_trial"]["night_paste"] == {"test":"first-only"},"paste payload stays with the correct PC")
    check(night.switch_pc(gs,second) and gs.player_inventory.size() == remaining and gs.job["service_replacements"].get("gpu","") == "similar","switching never restocks a fitted replacement")
    check(is_equal_approx(gs.job["dust"]["gpu"],0.76),"second PC progress survives a round trip")
    check(night.checkpoint(gs),"queue and active PC checkpoint succeeds")
    night.run_id = ""
    check(gs.load_game() and night.ensure(gs),"load reconstructs queue alongside legacy main save")
    check(night.active_id == second and night.tickets.size() == 2,"active PC identity survives restart")
    check(night.switch_pc(gs,first) and is_equal_approx(gs.job["dust"]["cooler"],0.42),"inactive repair progress survives JSON reload")
    var order: Dictionary = gs.job.duplicate(true)
    order["id"] = "B001"
    order["hardware_trial"]["night_session"] = {"run":night.run_id,"ticket":"B001","kind":"build","pc":""}
    night.tickets.append(order)
    check(pcs(Sources.collect(gs)) == 2,"build ticket with no client PC creates no rack object")
    var before: Dictionary = gs.job.duplicate(true)
    check(not night.switch_pc(gs,"B001") and gs.job == before,"unbuilt order cannot impersonate a physical repair PC")
    check(not night.switch_pc(gs,"missing") and gs.job == before,"unknown PC selection is safely rejected")
    # A diagnosis can be repeated, passed or failed: never a pickup transaction.
    var healthy: Dictionary = gs.job.duplicate(true)
    healthy["broken_parts"] = []
    healthy["removed_parts"] = []
    healthy["paste_grade"] = "PERFECT"
    healthy["paste_done"] = true
    healthy["paste_material"] = "thermal"
    healthy["pc_powered"] = true
    for id: String in healthy["dust"]: healthy["dust"][id] = 1.0
    var customers: Dictionary = gs.customer_state.duplicate(true)
    money = gs.money
    var taken: int = gs.tickets_taken
    check(Diagnostics.evaluate(healthy,[])["passed"],"fully working cool PC passes read-only diagnostics")
    Diagnostics.evaluate(healthy,[])
    check(gs.money == money and gs.customer_state == customers and gs.tickets_taken == taken and gs.job == before,"repeat checks do not complete, pay, record pickup or alter active PC")
    healthy["broken_parts"] = ["gpu"]
    check(not Diagnostics.evaluate(healthy,[])["boots"],"broken part produces a failed boot diagnosis")
    healthy["broken_parts"] = []
    healthy["removed_parts"] = ["cooler"]
    check(not Diagnostics.evaluate(healthy,[])["passed"],"removed part prevents a passed check")
    healthy["removed_parts"] = []
    healthy["pc_powered"] = false
    check(not Diagnostics.evaluate(healthy,[])["boots"],"powered-off PC cannot report a successful boot")
    healthy["pc_powered"] = true
    healthy["paste_grade"] = ""
    check(not Diagnostics.evaluate(healthy,[])["passed"],"missing paste reports thermal failure")
    # Keep full physical paste when switching screens, not merely its grade.
    var paste := Paste.new()
    paste.deposit(25,25,120)
    var saved: Dictionary = JSON.parse_string(JSON.stringify(Snapshot.capture(paste)))
    var restored := Paste.new()
    check(Snapshot.restore(restored,saved) and restored.h == paste.h and is_equal_approx(restored.total_deposited,paste.total_deposited),"physical paste height-field survives JSON roundtrip")
    var damaged: Dictionary = saved.duplicate(true)
    var bad_field: PackedFloat32Array = paste.h.duplicate()
    bad_field[10] = -1
    damaged["height_bytes"] = Marshalls.raw_to_base64(bad_field.to_byte_array())
    var original: PackedFloat32Array = restored.h.duplicate()
    check(not Snapshot.restore(restored,damaged) and restored.h == original,"bad paste snapshot leaves current field intact")
    # Save failures must block a switch, never drop the current repair on the floor.
    DirAccess.make_dir_absolute(manifest+".tmp")
    check(not night.switch_pc(gs,second) and night.active_id == first and gs.job == before,"failed manifest write leaves old PC selected")
    check(night.status.contains("could not be saved"),"manifest failure is reported")
    DirAccess.remove_absolute(manifest+".tmp")
    gs.job["temp"] += 1.0
    DirAccess.make_dir_absolute(gs.save_path+".tmp")
    check(not night.switch_pc(gs,second) and night.active_id == first,"failed main save blocks PC switching")
    DirAccess.remove_absolute(gs.save_path+".tmp")
    check(night.checkpoint(gs),"checkpoint can be retried after failure")
    # Main-save active marker wins over an old manifest pointer/snapshot after interrupted switch.
    check(night.switch_pc(gs,second),"switch writes the target's active marker")
    gs.job["dust"]["gpu"] = 0.91
    gs.save_game()
    night.run_id = ""
    check(gs.load_game() and night.ensure(gs) and is_equal_approx(gs.job["dust"]["gpu"],0.91),"main active job wins over stale manifest snapshot on recovery")
    var raw: Dictionary = SafeStore.read(manifest)
    raw["version"] = 999
    SafeStore.write(manifest,raw)
    night.run_id = ""
    check(not night.ensure(gs) and night.read_only and not night.checkpoint(gs),"future manifest is protected against overwrite")
    check(SafeStore.read(manifest)["version"] == 999,"protected manifest remains intact")
    # Legacy single-job migration does not fabricate a second customer's PC.
    gs.new_game(false)
    gs.job["dust"]["cooler"] = 0.33
    night.run_id = ""
    check(night.ensure(gs) and night.tickets.size() == 1 and is_equal_approx(gs.job["dust"]["cooler"],0.33),"legacy migration preserves one real existing ticket and repair progress")
    # Real screen routes and lever-based automatic commit.
    change_scene_to_file("res://scenes/start.tscn")
    await process_frame
    await process_frame
    check(not current_scene.get_children().any(func(n: Node) -> bool: return n is Button and n.text == "Salvage demo"),"start flow no longer exposes old salvage-demo menu entry")
    current_scene._start_new_game()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/activities.tscn" and night.tickets.size() == 2,"New game enters activity hub with two playable tickets")
    night.run_id = ""
    change_scene_to_file("res://scenes/storage.tscn")
    await process_frame
    await process_frame
    check(pcs(current_scene.model.items) == 2,"opening rack from a loaded title restores inactive customer PCs too")
    current_scene._leave()
    await process_frame
    await process_frame
    current_scene._go("res://scenes/night_workshop.tscn")
    await process_frame
    await process_frame
    current_scene._check()
    check(current_scene.report.text.contains("Report only") and gs.job["state"] == "open","workshop final check diagnoses without completing ticket")
    money = gs.money
    current_scene._buy_upgrade("square_cloth")
    check(gs.has_upgrade("square_cloth") and gs.money == money-gs.UPGRADE_PRICES["square_cloth"],"existing tool upgrades remain purchasable from workshop")
    money = gs.money
    current_scene._buy_upgrade("square_cloth")
    check(gs.money == money,"owned workshop upgrade cannot be charged twice")
    current_scene._switch(1)
    check(gs.job["id"] == night.tickets[1]["id"],"real picker changes the active customer PC")
    current_scene._go("res://scenes/night_bench.tscn")
    await process_frame
    await process_frame
    var bench: Node = current_scene
    bench.set_physics_process(false)
    bench._select_stage(bench.STAGE_PASTE)
    check(not bench.complete_button.visible,"night paste screen has no completion button")
    bench.paste.clear()
    for y in range(Paste.CPU_MIN,Paste.CPU_MAX):
        for x in range(Paste.CPU_MIN,Paste.CPU_MAX): bench.paste.h[y*Paste.GRID+x] = 0.1
    bench.paste.total_deposited = 122.5
    bench.paste.min_x = Paste.CPU_MIN
    bench.paste.max_x = Paste.CPU_MAX-1
    bench.paste.min_y = Paste.CPU_MIN
    bench.paste.max_y = Paste.CPU_MAX-1
    bench.paste.mark_changed()
    bench.mount.start()
    money = gs.money
    bench._finish_mount()
    check(gs.job["paste_done"] and gs.money == money-3 and gs.job["state"] == "open","locking a good cooler mount commits paste automatically without finishing job")
    bench._finish_mount()
    check(gs.money == money-3,"idle lever call cannot charge paste twice")
    var field: PackedFloat32Array = bench.paste.h.duplicate()
    bench._on_back_pressed()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/night_workshop.tscn","repair bench returns to PC selection")
    current_scene._go("res://scenes/night_bench.tscn")
    await process_frame
    await process_frame
    check(current_scene.paste.h == field and gs.job["paste_done"],"returning to repair bench restores that PC's physical paste and committed mount")
    current_scene._on_back_pressed()
    await process_frame
    await process_frame
    current_scene._go("res://scenes/night_hardware.tscn")
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/night_hardware.tscn","workshop hardware bench route loads")
    change_scene_to_file("res://scenes/activities.tscn")
    await process_frame
    await process_frame
    current_scene._go("res://scenes/night_salvage.tscn")
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/night_salvage.tscn","activity hub opens salvage dump")
    current_scene._back()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/activities.tscn","salvage returns to activities instead of initial menu")
    current_scene.free()
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Night workshop")
