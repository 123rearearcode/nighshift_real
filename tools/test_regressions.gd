# Run: godot --headless --path . --script res://tools/test_regressions.gd
# Uses a dedicated test save path and restores the autoload's original in-memory state.
extends "res://tools/test_support.gd"
const TableBody = preload("res://scripts/bench/table_body.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const BrushShape = preload("res://scripts/bench/brush_shape.gd")
const GridInventory = preload("res://scripts/bench/grid_inventory.gd")
const PartMotion = preload("res://scripts/view/part_motion.gd")
const Pick = preload("res://scripts/bench/dust_pick.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const Access = preload("res://scripts/bench/service_access.gd")
const LayoutRules = preload("res://scripts/rules/layout_rules.gd")
const Layout = preload("res://scripts/data/pc_layout.gd")
const Zones = preload("res://scripts/data/dust_zones.gd")
const Dust = preload("res://scripts/bench/dust_sim.gd")
const Rules = preload("res://scripts/rules/placement_rules.gd")
const Data = preload("res://scripts/data/component_data.gd")
const SaveStore = preload("res://scripts/state/save_store.gd")
const PasteSim = preload("res://scripts/bench/paste_sim.gd")
const Hose = preload("res://scripts/bench/hose_sim.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const PieceCollision = preload("res://scripts/bench/piece_collision.gd")
const Bin = preload("res://scripts/bench/dust_bin.gd")
const Motes = preload("res://scripts/bench/dust_motes.gd")
const HoseFlow = preload("res://scripts/bench/hose_flow.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")
const MountSession = preload("res://scripts/bench/mount_session.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const Ids = preload("res://scripts/data/ids.gd")
const BenchItems = preload("res://scripts/bench/bench_items.gd")
const LayoutData = preload("res://scripts/data/layout.gd")

func _initialize() -> void:
    call_deferred("run_checks")


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://regression_test_only.json"
    gs.new_game()
    check(not gs.run_final_check()["passed"] and gs.money == 100, "unrepaired PC cannot collect payment")
    var z: Array = Zones.zones()
    var dust: RefCounted = Dust.new()
    dust.setup(z, Vector2.ZERO, 12345)
    var expected_groups: int = 0
    for zone: Dictionary in z: expected_groups += int(zone["bundles"]) + int(zone.get("specks",0))
    check(expected_groups > 0 and dust.count == expected_groups and is_equal_approx(dust.remaining_fraction(), 1.0), "new PC spawns configured bundles and specks without Reset")
    for fraction: float in [0.0, 0.123, 0.499, 0.91, 1.0]:
        var value: float = fraction
        for k in range(20):
            dust.setup(z, Vector2.ZERO, 12345)
            dust.apply_progress(0, value)
            value = dust.removed_fraction(0)
        check(absf(value - fraction) < 0.00001, "no dust reload drift: " + str(fraction))
    for id: String in ["tower", "compact"]:
        var pc: Dictionary = Layout.profile(id)
        check(LayoutRules.validate(pc).is_empty(), id + " case and board valid")
        var part: Dictionary = Data.ram_stick()
        var board: Dictionary = pc["board"]
        check(Rules.check_placement(board, part, 0, Vector2i(5, 0), {}, pc["depth"])["ok"], id + " RAM fits")
        check(not Rules.check_placement(board, part, 1, Vector2i(5, 0), {}, pc["depth"])["ok"], "rotation rejected")
        check(not Rules.check_placement(board, part, 0, Vector2i(5, 0), {"ram_1":"other"}, pc["depth"])["ok"], "occupied rejected")
        check(not Rules.check_placement(board, part, 0, Vector2i(8, 0), {}, pc["depth"])["ok"], "cutout rejected")
        part["height"] = 99
        check(not Rules.check_placement(board, part, 0, Vector2i(5, 0), {}, pc["depth"])["ok"], "case depth rejected")
        for area: Rect2 in [Rect2(0,0,620,520), Rect2(0,0,300,220), Rect2(0,0,1000,900)]:
            var fit: Dictionary = Layout.display(pc, area)
            check(area.encloses(fit["case_rect"]), "case display fits available area")
            var br: Rect2 = Layout.board_rect(pc, fit)
            for c: Dictionary in board["connectors"]:
                check(br.encloses(Layout.connector_rect(pc, fit, c["id"])), "connector remains on board bounds")
    var service: RefCounted = Access.new()
    service.setup(z, Vector2.ZERO, [])
    dust.setup(z, Vector2.ZERO, 12345)
    dust.set_blockers(service.blockers())
    var hidden_index: int = Zones.index_of("under_gpu")
    var hidden_bundle: int = dust.zone_bundles[hidden_index][0]
    var hidden_point: Vector2 = dust.b_center[hidden_bundle]
    for i in range(180):
        dust.step(1.0/60.0, Dust.TOOL_VACUUM, hidden_point, Vector2.ZERO, true)
        dust.step(1.0/60.0, Dust.TOOL_BRUSH, hidden_point, Vector2(500,0), true)
    check(dust.removed_fraction(hidden_index) == 0, "installed GPU blocks vacuum and brush underneath")
    check(dust.is_hidden(hidden_bundle), "covered dust hidden visually")
    service.set_removed("gpu", true)
    dust.set_blockers(service.blockers())
    check(not dust.is_hidden(hidden_bundle) and dust.has_access(hidden_bundle, hidden_point), "removal exposes reachable dust")
    for i in range(180): dust.step(1.0/60.0, Dust.TOOL_VACUUM, hidden_point, Vector2.ZERO, true)
    check(dust.removed_fraction(hidden_index) > 0, "exposed hidden dust can be cleaned")
    check(dust.b_n.has(1), "independent specks spawn")
    var before_pos: Vector2 = dust.b_center[0]
    dust.translate_zone(0, Vector2(20,10))
    check(dust.b_center[0].is_equal_approx(before_pos + Vector2(20,10)), "surface dust translates with its part")
    var blocker := {"id":"wall", "rect": Rect2(hidden_point - Vector2(12,12), Vector2(24,24))}
    dust.set_blockers([blocker])
    check(not dust.has_access(hidden_bundle, hidden_point + Vector2(100,0)), "other component blocks suction path")
    for profile: String in ["tower", "compact"]:
        var service_zones: Array = Zones.zones(profile)
        service.setup(service_zones, Vector2(40,110), [])
        for id: String in Access.MOVABLE:
            check(Access.TRAY.encloses(service.parked[id]), "service tray fits " + profile + " " + id)
        var home: Rect2 = service.homes["gpu"]
        check(service.begin(home.get_center()), "pick GPU up")
        service.move(Access.TRAY.get_center())
        service.finish(Access.TRAY.get_center())
        check("gpu" in service.removed_ids(), "drag to tray removes GPU")
        check(service.begin(service.current_rect("gpu").get_center()), "pick parked GPU up")
        service.finish(Vector2(-100,-100))
        check("gpu" in service.removed_ids(), "invalid drop preserves removed state")
        service.begin(service.current_rect("gpu").get_center())
        service.finish(home.get_center())
        check(service.removed_ids().is_empty(), "drag to mount refits GPU")
    var bad: Dictionary = Data.demo_board()
    bad["rows"] = ["#"]
    check(not Rules.validate_board(bad).is_empty(), "malformed board rejected safely")
    # Instantiate actual screen to exercise tool/stage state, not a Python model.
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    # Check action wiring, not the spelling of a button removed several versions ago.
    var toggles: int = 0
    var redundant_dispense: int = 0
    for child: Node in bench.get_children():
        if not child is Button: continue
        for connection: Dictionary in child.get_signal_connection_list("pressed"):
            var callback: Callable = connection["callable"]
            if callback.get_object() != bench: continue
            if callback.get_method() == "_on_wipe_toggled": toggles += 1
            if callback.get_method() == "_select_dispense": redundant_dispense += 1
    check(toggles == 1 and redundant_dispense == 0, "one cloth/syringe toggle without a duplicate dispensing button")
    check(bench.dust.remaining_fraction() > 0.99, "actual fresh bench initially dusty")
    bench._select_tool(2)
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = bench.access.current_rect("gpu").get_center()
    bench._input(press)
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    release.position = Access.TRAY.get_center()
    bench._input(release)
    check("gpu" in bench.access.removed_ids(), "queued mouse events use event positions for reliable drags")
    bench._select_stage(1)
    bench.wipe_button.button_pressed = true
    bench._on_wipe_toggled()
    check(bench.wiping, "cloth selectable")
    bench._select_stage(1)
    check(not bench.wiping and not bench.wipe_button.button_pressed, "Apply thermal paste selects syringe")
    bench.wipe_button.button_pressed = true
    bench._on_wipe_toggled()
    bench._select_dispense()
    check(not bench.wiping, "explicit syringe button exits cloth")
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    bench.holding = true
    bench._step_paste(1.0 / 60.0, bench.PASTE_ORIGIN + Vector2(25,25) * bench.PASTE_CELL)
    check(gs.job["paste_grade"] == "", "new deposit invalidates saved grade")
    bench.free()
    var fractions: Dictionary = {}
    for zone: Dictionary in z: fractions[zone["id"]] = 1.0
    gs.set_dust(fractions)
    gs.save_game()
    gs.load_game()
    var clean_bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(clean_bench)
    clean_bench.set_physics_process(false)
    check(clean_bench.dust.remaining_fraction() < 0.00001, "saved clean PC stays clean")
    check(clean_bench.status_label.text.contains("Cleanliness target met") and clean_bench.status_label.text.contains("0 real dust groups remain"), "clean resume clearly explained")
    clean_bench.free()
    pasted(gs)
    gs.job["removed_parts"] = ["gpu"]
    gs.save_game()
    gs.load_game()
    check(gs.job["removed_parts"] == ["gpu"], "removed parts survive save/load")
    check(not gs.run_final_check()["passed"] and gs.money == 100, "missing part blocks payment")
    gs.job["removed_parts"] = []
    var money: int = gs.money
    var result: Dictionary = gs.run_final_check()
    check(result["passed"] and result["paid"] == 60 and gs.money == money + 60, "completed repair pays exactly once")
    check(gs.run_final_check()["paid"] == 0, "repeated check does not repay")
    gs.money = -999
    check(gs.load_game() and gs.money == money + 60, "saved cash restored")
    check(gs.run_final_check()["paid"] == 0, "reload does not repay")
    check(gs.buy_upgrade("square_cloth") and gs.money == money + 20, "upgrade deducts once")
    check(not gs.buy_upgrade("square_cloth"), "duplicate upgrade rejected")
    gs.load_game()
    check(gs.has_upgrade("square_cloth"), "upgrade survives load")
    test_pick_service(gs)
    test_free_inventory(gs)
    test_tabletop_and_shared_stock(gs)
    test_save_store()
    test_brush_dust()
    test_bounds()
    test_hose_bin_motes()
    test_piece_physics(gs)
    test_hose_handling()
    test_hand_machine(gs)
    test_bench_0_20(gs)
    test_promoted_contracts(gs)
    test_0_21(gs)
    test_0_22(gs)
    test_bench_clicks(gs)
    test_hose_housing_and_clamp(gs)
    test_repaste_and_toothpaste(gs)
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(gs.save_path + suffix)
    gs.save_path = original_path
    finish("Regression")


func test_pick_service(gs: Node) -> void:
    var tool := Pick.new()
    check(tool.step(1.0, "gpu", false, 0.0).is_empty(), "hover inspection cannot damage")
    check(tool.step(0.4, "gpu", true, 0.0).is_empty(), "short hold cannot damage")
    check(tool.step(0.4, "cooler", true, 0.0).is_empty(), "changing target resets stroke")
    tool.reset()
    var safe: Dictionary = tool.step(0.8, "gpu", true, 0.99)
    check(not safe["damaged"], "safe forced roll")
    var accident: Dictionary = tool.step(0.8, "gpu", true, 0.0)
    check(accident["damaged"], "forced damage roll")
    tool.reset()
    var premature_attempt: bool = false
    for i in range(47): premature_attempt = not tool.step(1.0 / 60.0, "gpu", true, 0.99).is_empty() or premature_attempt
    check(not premature_attempt, "no attempt or risk roll before the complete stroke")
    check(not tool.step(1.0 / 60.0, "gpu", true, 0.99).is_empty(), "60Hz stroke reaches one attempt")
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_tool(3)
    check(bench.tool_buttons.size() == 4 and bench.tool_buttons[3].button_pressed, "pick selectable as fourth tool")
    var point: Vector2 = bench.access.current_rect("gpu").get_center()
    check(bench._pick_target(point) == "gpu", "installed GPU inspect target")
    var original: int = bench.dust.trapped_count("gpu")
    var hidden: Dictionary = bench.zones[Zones.index_of("under_gpu")]
    check(original == int(hidden["bundles"]) + int(hidden.get("specks",0)), "inspection counts configured hidden bundles and independent specks")
    var generator := RandomNumberGenerator.new()
    var safe_seed: int = -1
    var damage_seed: int = -1
    for seed_id in range(100):
        generator.seed = seed_id
        var roll: float = generator.randf()
        if roll < Pick.DAMAGE_CHANCE: damage_seed = seed_id
        else: safe_seed = seed_id
    check(safe_seed >= 0 and damage_seed >= 0, "deterministic seeds available for both outcomes")
    bench.pick.rng.seed = safe_seed
    bench.holding = true
    bench._step_clean(0.8, point)
    check(bench.dust.trapped_count("gpu") == original - 1, "successful pick extracts protected clump")
    check(gs.job["broken_parts"].is_empty(), "successful extraction leaves component installed/working")
    check(not "gpu" in gs.job["removed_parts"], "pick does not remove GPU")
    bench.pick.rng.seed = damage_seed
    bench.holding = true
    bench._step_clean(0.8, point)
    check("gpu" in gs.job["broken_parts"], "actual bench pick can cause damage")
    check(not bench.holding, "damage immediately stops picking")
    var count_after: int = bench.dust.trapped_count("gpu")
    bench.holding = true
    bench._step_clean(1.0, point)
    check(bench.dust.trapped_count("gpu") == count_after, "broken part cannot be farmed for more pick attempts")
    check(not gs.run_final_check()["passed"] and gs.money == 100, "damage blocks payment")
    gs.load_game()
    check(gs.job["broken_parts"] == ["gpu"], "damage persists across reload")
    check(not gs.replace_service_part("gpu", "budget") and gs.money == 100, "must remove broken component before fitting replacement")
    bench.access.set_removed("gpu", true)
    gs.job["removed_parts"] = ["gpu"]
    bench._open_replacements()
    check(bench.replacement_panel.visible and not bench.replacement_buttons[3]["button"].disabled, "budget GPU purchase available in replacement window")
    check(gs.buy_service_stock("gpu","budget"), "buy adds a budget GPU to shared stock")
    bench._replace_part("gpu", "budget")
    check(gs.money == 82 and gs.job["broken_parts"].is_empty(), "budget transaction charges once and clears damage")
    check(gs.job["removed_parts"].is_empty() and not "gpu" in bench.access.removed_ids(), "purchase fits replacement")
    check(gs.job["service_replacements"].get("gpu") == "budget", "inferior specification recorded")
    check(not gs.replace_service_part("gpu", "budget") and gs.money == 82, "repeat purchase cannot deduct cash")
    check(not gs.replace_service_part("gpu", "invalid"), "unknown tier rejected")
    bench.replacement_panel.hide()
    bench.free()
    gs.load_game()
    check(gs.money == 82 and gs.job["service_replacements"].get("gpu") == "budget", "cash and downgraded replacement persist")
    var fractions: Dictionary = {}
    for zone: Dictionary in Zones.zones(): fractions[zone["id"]] = 1.0
    gs.set_dust(fractions)
    pasted(gs)
    var final: Dictionary = gs.run_final_check()
    check(final["passed"] and final["paid"] == 60, "functional downgrade may complete repair")
    check(str(final["notes"]).contains("Downgrade"), "final check exposes lower specification")
    check(gs.run_final_check()["paid"] == 0, "downgraded repair also pays only once")
    check(not gs.damage_service_part("gpu"), "completed customer PC cannot be damaged after payout")
    gs.new_game()
    check(not gs.damage_service_part("motherboard"), "unsupported part cannot be damaged by trial tool")
    gs.damage_service_part("cooler")
    gs.job["removed_parts"] = ["cooler"]
    gs.money = 0
    check(not gs.buy_service_stock("cooler", "similar") and "cooler" in gs.job["broken_parts"], "insufficient funds prevents stock purchase and preserves damage")
    gs.money = 100
    pasted(gs)
    check(gs.buy_service_stock("cooler","budget"), "cooler purchase charges before installation")
    check(gs.replace_service_part("cooler", "budget") and gs.money == 93 and gs.job["paste_grade"] == "", "new cooler needs fresh paste")
    gs.set_dust(fractions)
    pasted(gs)
    final = gs.run_final_check()
    check(is_equal_approx(final["temp"], 50.0), "budget cooler imposes real temperature penalty")
    gs.new_game()
    gs.set_dust(fractions)
    pasted(gs)
    gs.damage_service_part("gpu")
    var damaged_check: Dictionary = gs.run_final_check()
    check(not damaged_check["passed"] and damaged_check["paid"] == 0 and gs.money == 100, "broken GPU alone blocks otherwise perfect repair payment")
    check(is_equal_approx(damaged_check["temp"], 42.0), "damage gate independent from thermal success")
    gs.job["removed_parts"] = ["gpu"]
    check(gs.buy_service_stock("gpu","similar"), "equivalent GPU restocked")
    check(gs.replace_service_part("gpu", "similar") and gs.money == 60, "equivalent replacement priced and fitted")
    check(ServiceParts.option("gpu", "similar")["performance"] == 100, "equivalent restores original spec")
    gs.job["broken_parts"] = "malformed"
    gs.job["service_replacements"] = {"gpu":"invented", "cpu":"budget"}
    gs.save_game()
    gs.load_game()
    check(gs.job["broken_parts"].is_empty() and gs.job["service_replacements"].is_empty(), "malformed new saved fields safely filtered")
    gs.job.erase("broken_parts")
    gs.job.erase("service_replacements")
    gs.save_game()
    gs.load_game()
    check(gs.job["broken_parts"].is_empty() and gs.job["service_replacements"].is_empty(), "older saves default to working original parts")


func test_free_inventory(gs: Node) -> void:
    for profile: String in ["tower", "compact"]:
        var pc: Dictionary = Layout.profile(profile)
        var inventory := GridInventory.new()
        inventory.setup(pc["board"], pc["depth"])
        check(inventory.items.size() == 3, "three sample pieces for packing experiments")
        for i in range(3): check(inventory.can_store(i,inventory.items[i]["cell"]), "initial stock fits without overlap")
        inventory.begin(0)
        inventory.rotate(1)
        check(inventory.footprint(0) == Vector2i(4,1), "drawer rotation changes occupied footprint")
        check(inventory.store(Vector2i(6,4)), "part can be stored away from original position")
        check(inventory.items[0]["cell"] == Vector2i(6,4), "drawer commits chosen cell")
        inventory.begin(1)
        inventory.rotate(1)
        check(not inventory.store(Vector2i(7,4)), "overlap rejected without stacking")
        check(inventory.held == 1, "failed store does not lose held object")
        inventory.cancel()
        inventory.begin(0)
        inventory.rotate(-1)
        check(not inventory.store(Vector2i(12,0)), "right boundary rejects overflow")
        check(not inventory.store(Vector2i(0,6)), "bottom boundary rejects rotated size overflow")
        var install: Dictionary = inventory.install(Vector2i(5,1))
        check(install["ok"] and inventory.items[0]["location"] == "ram_1", "cursor within matching slot magnetically installs")
        inventory.begin(1)
        check(not inventory.install(Vector2i(5,1))["ok"], "occupied motherboard slot still enforced")
        inventory.cancel()
        inventory.begin(0)
        check(inventory.occupied().is_empty(), "pickup frees installed slot")
        inventory.rotate(1)
        check(inventory.store(Vector2i(6,5)), "installed part can return to arbitrary rotated storage")
        inventory.begin(2)
        check(inventory.install(Vector2i(0,6))["ok"], "larger GPU installs in matching PCIe footprint")
        var saved: Dictionary = inventory.snapshot()
        var restored := GridInventory.new()
        restored.setup(pc["board"],pc["depth"],saved)
        check(restored.snapshot() == saved, "all stored/installed positions and rotations roundtrip")
        restored.begin(0)
        restored.rotate(1)
        check(restored.snapshot() == saved, "saving during drag preserves last committed placement")
        restored.cancel()
        check(restored.snapshot() == saved, "cancel restores location and orientation")
        var corrupted: Dictionary = {"trial_ram_a":{"location":"drawer","cell":[99,99],"rotation":1},"trial_ram_b":{"location":"missing_slot","rotation":"bad"},"trial_gpu":{"location":"drawer","cell":"bad"}}
        restored.setup(pc["board"],pc["depth"],corrupted)
        for i in range(3): check(restored.can_store(i,restored.items[i]["cell"]), "malformed saved locations recover to free cells")
    var grid := GridInventory.new()
    var pc: Dictionary = Layout.profile("tower")
    grid.setup(pc["board"],pc["depth"])
    var rng := RandomNumberGenerator.new()
    rng.seed = 8181
    var safe: bool = true
    for trial in range(500):
        var i: int = rng.randi_range(0,2)
        grid.begin(i)
        grid.rotate(rng.randi_range(-3,3))
        if not grid.store(Vector2i(rng.randi_range(-1,12),rng.randi_range(-1,7))): grid.cancel()
        for j in range(3): safe = safe and grid.can_store(j,grid.items[j]["cell"])
    check(safe and grid.items.size() == 3, "500 rearrangements preserve all pieces and prevent overlap/off-grid storage")
    for fps: int in [30,60,144]:
        var motion := PartMotion.new()
        motion.snap(Vector2.ZERO,0)
        for frame in range(fps): motion.step(1.0/fps,Vector2(500,200),1,true)
        check(motion.center.distance_to(Vector2(500,200)) < 0.01, "pickup converges at " + str(fps) + "fps")
        check(absf(angle_difference(motion.angle,PI/2)) < 0.001, "animated rotation settles at target quarter turn")
        for frame in range(fps): motion.step(1.0/fps,Vector2(480,180),1,false)
        check(motion.center.distance_to(Vector2(480,180)) < 0.01 and motion.lift < 0.001, "drop settles without endless movement")
    gs.new_game()
    var view: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(view)
    view.set_process(false)
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = view._item_rect(0).get_center()
    view._input(press)
    check(view.inventory.held == 0, "actual view can pick up RAM")
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    release.position = view.DRAWER_GRID_ORIGIN + Vector2(7.5,5.0)*30.0
    view._input(release)
    check(view.inventory.items[0]["cell"] == Vector2i(7,3), "mouse release stores RAM in chosen drawer cells")
    check(view.inventory.held == -1 and view.status_label.text.begins_with("Stored"), "ordinary drawer drop produces success, no motherboard error")
    view.pointer = view._item_rect(0).get_center()
    view._rotate_part(1)
    check(view.inventory.items[0]["rotation"] == 1, "hover rotation works in storage")
    var gpu_rect: Rect2 = view._item_rect(2)
    view._try_pick_up(gpu_rect.get_center())
    view._rotate_part(1)
    view._drop(view.DRAWER_GRID_ORIGIN + Vector2(0.5,4.0)*30.0)
    check(view.inventory.items[2]["rotation"] == 1 and view.inventory.can_store(2,view.inventory.items[2]["cell"]), "drawer depth permits larger GPU to turn vertically")
    var snapshot: Dictionary = view.inventory.snapshot()
    view._try_pick_up(view._item_rect(0).get_center())
    view._rotate_part(1)
    var escape := InputEventKey.new()
    escape.keycode = KEY_ESCAPE
    escape.pressed = true
    view._input(escape)
    check(view.inventory.snapshot() == snapshot and view.inventory.held == -1, "Esc restores last committed piece placement")
    view._try_pick_up(view._item_rect(0).get_center())
    view._drop(Vector2(-100,-100))
    check(view.inventory.snapshot() == snapshot and not view.status_label.text.contains("INVALID"), "outside drop is gentle and never loses part")
    view._change_profile("compact")
    view._change_profile("tower")
    check(view.inventory.snapshot() == snapshot, "case preview switch preserves each sandbox arrangement")
    view.free()
    gs.load_game()
    var reopened: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(reopened)
    reopened.set_process(false)
    check(reopened.inventory.snapshot() == snapshot, "inventory placement persists across scene re-entry and save/load")
    reopened.free()


func test_tabletop_and_shared_stock(gs: Node) -> void:
    var bounds := Rect2(0,0,600,400)
    for fps: int in [30,60,144]:
        var body := TableBody.new()
        body.launch(Vector2(550,180),Vector2(1600,200),Vector2(35,20),0.3)
        var contained: bool = true
        var touched_floor: bool = false
        var positive_hop: bool = false
        for frame in range(fps*12):
            body.step(1.0/fps,bounds)
            var e: Vector2 = body.extent()
            contained = contained and bounds.grow(0.01).encloses(Rect2(body.center-e,e*2))
            positive_hop = positive_hop or body.height > 10
            touched_floor = touched_floor or (body.height == 0 and body.impacts > 1)
        check(contained, "rotating thrown object stays inside edges at " + str(fps))
        check(body.impacts > 1 and positive_hop and touched_floor, "object bounces off edges and tabletop")
        check(not body.active and body.velocity.length() < 0.01, "friction/hop damping eventually settles")
    var long_body := TableBody.new()
    var drawer_bounds := Rect2(0,0,360,240)
    long_body.launch(Vector2(180,120),Vector2(1400,300),Vector2(120,15))
    var long_fits: bool = true
    for frame in range(900):
        long_body.step(1.0/60,drawer_bounds)
        long_fits = long_fits and drawer_bounds.grow(0.01).encloses(Rect2(long_body.center-long_body.extent(),long_body.extent()*2))
    check(long_fits,"large rotating GPU cannot clip through drawer boundaries")
    var wall := TableBody.new()
    wall.launch(Vector2(580,200),Vector2(1400,0),Vector2(10,10))
    wall.step(1.0/60.0,bounds)
    check(wall.velocity.x < 0, "edge impact reverses velocity rather than clamping silently")
    var brush := BrushShape.new()
    var initial: PackedVector2Array = brush.tips()
    for frame in range(20): brush.step(1.0/60,Vector2(800,0),true)
    check(brush.bend.x < -5 and brush.compression > 0.9, "bristles trail movement and compress against surface")
    check(brush.tips()[6].distance_to(initial[6]) > 3, "brush geometry actually deforms")
    for frame in range(120): brush.step(1.0/60,Vector2.ZERO,false)
    check(brush.bend.length() < 0.01 and brush.compression < 0.001, "bristles relax after lifting")
    var dust := Dust.new()
    dust.setup(Zones.zones(),Vector2.ZERO,12345)
    var point: Vector2 = dust.rest[0][0]
    var grip: float = dust.b_loosen[0]
    dust.brush_contacts = PackedVector2Array([point+Vector2(150,0)])
    dust.step(0.1,Dust.TOOL_BRUSH,point,Vector2(500,0),true)
    check(dust.b_loosen[0] == grip, "brush cannot loosen dust outside its bristles")
    dust.brush_contacts = PackedVector2Array([point])
    dust.step(0.1,Dust.TOOL_BRUSH,point,Vector2(500,0),true)
    check(dust.b_loosen[0] < grip, "bristle-tip contact drives dust loosening")
    var slow := Dust.new()
    slow.setup(Zones.zones(),Vector2.ZERO,12345)
    slow.brush_contacts = PackedVector2Array([slow.rest[0][0]])
    var initial_slow_count: int = slow.count
    for frame in range(60): slow.step(0.1,Dust.TOOL_BRUSH,slow.rest[0][0],Vector2(20,0),true)
    check(slow.b_state[0] == Dust.STUCK and slow.count == initial_slow_count, "a nearly still brush neither tosses nor sheds dust")
    var paste := PasteSim.new()
    paste.deposit(2.0,2.0,30.0)
    var outside_gauge: float = paste.total_deposited
    check(outside_gauge == 0.0, "paste squeezed beside the CPU never counts on the gauge")
    paste.deposit(25.0,25.0,60.0)
    var on_cpu: float = paste.total_deposited
    check(on_cpu > 50.0, "paste on the CPU counts on the gauge")
    paste.wipe(2.0,2.0,4.5,0.5,false)
    check(paste.total_deposited == on_cpu, "wiping outside the CPU leaves the gauge alone")
    paste.wipe(25.0,25.0,4.5,0.5,false)
    check(paste.total_deposited < on_cpu, "wiping on the CPU lowers the gauge")
    var turner := ToolRig.new()
    turner.select("brush",Vector2(300,300))
    turner.rotate_held(1)
    turner.rotate_held(1)
    check(is_equal_approx(float(turner.turns["brush"]),ToolRig.TURN_STEP*2.0), "E turns the held tool clockwise in steps")
    for frame in range(120): turner.step(1.0/60,Vector2(300,300),false)
    check(absf(turner.motions["brush"].angle-ToolRig.TURN_STEP*2.0) < 0.05, "tool angle follows the turn")
    check(turner.contact().distance_to(Vector2(300,300)) < 2.0, "rotated tool keeps its working tip on the cursor")
    turner.rotate_held(-1)
    check(is_equal_approx(float(turner.turns["brush"]),ToolRig.TURN_STEP), "Q turns anticlockwise")
    turner.begin_throw(Vector2(300,300))
    turner.release_throw(Vector2.ZERO)
    var kept: float = float(turner.turns["brush"])
    turner.rotate_held(1)
    check(float(turner.turns["brush"]) == kept, "a tool that is not held cannot be turned")
    var rig := ToolRig.new()
    for id: String in ToolRig.IDS:
        rig.select(id,Vector2(250,250))
        rig.step(1.0/60,Vector2(400,250),true)
        check(rig.contact().x < 400 and rig.equipped, id + " follows with tactile lag")
        rig.begin_throw(Vector2(400,250))
        rig.release_throw(Vector2(1600,0))
        check(not rig.equipped and rig.bodies[id].active, id + " can be thrown")
        for frame in range(600): rig.step(1.0/60,Vector2(400,250),true)
        check(rig.bodies[id].impacts > 0 and not rig.bodies[id].active, id + " bounces and settles")
        check(not rig.active, "resting/thrown tool cannot work remotely")
        check(rig.hit(rig.motions[id].center) != "", "resting tool remains pickable")
    var stacked := ToolRig.new()
    stacked.motions["brush"].center = stacked.motions["vacuum"].center
    stacked.selected = "brush"
    stacked.equipped = false
    check(stacked.hit(stacked.motions["brush"].center,["vacuum","brush"]) == "brush", "overlapping tool pickup matches visible topmost tool")
    check(stacked.hit(stacked.motions["cloth"].center,["vacuum","brush","pick"]) == "", "hidden-stage tools cannot intercept clicks")
    gs.new_game()
    check(gs.player_inventory.size() == 6, "one shared initial stock list")
    var cash: int = gs.money
    var stock: int = gs.stock_count("gpu","budget")
    check(gs.buy_service_stock("gpu","budget") and gs.money == cash-18, "buying stock charges the advertised price")
    check(gs.stock_count("gpu","budget") == stock+1, "purchase adds a physical inventory item")
    gs.damage_service_part("gpu")
    gs.job["removed_parts"] = ["gpu"]
    cash = gs.money
    var old_count: int = gs.player_inventory.size()
    check(gs.replace_service_part("gpu","budget") and gs.money == cash, "fitting owned stock has no second charge")
    check(gs.player_inventory.size() == old_count-1 and gs.stock_count("gpu","budget") == stock, "fit consumes exactly one physical part")
    var consumed: String = gs.job["service_replacement_ids"]["gpu"]
    check(not gs.stock_available(consumed), "installed customer replacement cannot also remain player stock")
    check(gs.job["removed_component_records"].size() == 1 and gs.job["removed_component_records"][0]["owner"] == "customer", "broken original retains customer ownership")
    check(not gs.fit_inventory_part("gpu",consumed), "same part cannot be fitted twice")
    gs.load_game()
    check(gs.player_inventory.size() == old_count-1 and not gs.stock_available(consumed), "inventory consumption survives save/load")
    var view: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(view)
    view.set_process(false)
    check(view.inventory.items.size() == gs.player_inventory.size(), "hardware drawer uses the same current player stock")
    var absent: bool = true
    for item: Dictionary in view.inventory.items: absent = absent and item["part"]["id"] != consumed
    check(absent, "consumed replacement does not regenerate in hardware drawer")
    view.free()
    gs.new_game()
    gs.inventory_layout["trial_gpu"] = {"location":"pcie","cell":[0,0],"rotation":0}
    gs.damage_service_part("gpu")
    gs.job["removed_parts"] = ["gpu"]
    check(not gs.fit_inventory_part("gpu","trial_gpu"), "part installed in hardware PC unavailable for repair stock")
    gs.inventory_layout["trial_gpu"]["location"] = "drawer"
    check(gs.fit_inventory_part("gpu","trial_gpu"), "returning to drawer makes same UID available")
    gs.new_game()
    gs.money = 10000
    var purchases: int = 0
    while purchases < 20 and gs.buy_service_stock("gpu","budget"): purchases += 1
    var full_cash: int = gs.money
    var full_stock: int = gs.player_inventory.size()
    check(purchases > 0 and purchases < 20, "physical inventory capacity eventually stops purchasing")
    check(not gs.buy_service_stock("gpu","budget") and gs.money == full_cash and gs.player_inventory.size() == full_stock, "full stock purchase loses no cash and grants no item")
    gs.player_inventory = []
    gs.inventory_layout = {}
    gs.save_game()
    gs.load_game()
    var empty := GridInventory.new()
    var pc: Dictionary = Layout.profile("tower")
    empty.setup(pc["board"],pc["depth"],{},gs.inventory_components())
    check(gs.player_inventory.is_empty() and empty.items.is_empty(), "empty stock never respawns free samples")
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    # First-use and rack pickup are covered by test_dust_flow/test_bench_interactions.
    bench.dust.apply_progress(0,0.4)
    bench._save_dust()
    bench.free()
    bench = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    check(bench.dust.visible_count() > 0 and absf(bench.dust.removed_fraction(0)-0.4) < 0.0001, "partial dirty ticket reopens visibly and preserves work")
    bench.dust.clear_all()
    for i in range(bench.zone_done.size()): bench.zone_done[i] = true
    bench._save_dust()
    cash = gs.money
    var owned: int = gs.player_inventory.size()
    gs.start_repair_ticket()
    bench.free()
    check(gs.money == cash and gs.player_inventory.size() == owned and gs.dust_fraction("cooler") == 0, "new dirty PC keeps money/stock and stale scene cannot overwrite fresh dust")
    bench = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    check(bench.dust.visible_count() > 0 and bench.dust.remaining_fraction() > 0.99, "next PC starts dusty without pressing Reset")
    bench._select_tool(2)
    var gpu_home: Rect2 = bench.access.homes["gpu"]
    check(bench._begin_part_drag(gpu_home.get_center()), "service component can be picked up")
    bench.part_motions["gpu"].center = Vector2(480,420)
    bench.event_velocity = Vector2(1500,200)
    bench.pointer_tick = Time.get_ticks_msec()
    bench._finish_part_drag(Vector2(480,420))
    check(bench.part_bodies.has("gpu") and "gpu" in gs.job["removed_parts"], "repair-bench GPU flick starts tabletop motion and marks removal")
    var service_body: RefCounted = bench.part_bodies["gpu"]
    for frame in range(600): bench._step_clean(1.0/60,Vector2(300,300))
    check(service_body.impacts > 1 and not service_body.active, "service component bounces and settles on repair table")
    check(bench._begin_part_drag(bench._part_rects()["gpu"].get_center()), "thrown service part remains pickable at its physical position")
    bench.event_velocity = Vector2.ZERO
    bench._finish_part_drag(gpu_home.get_center())
    check(not "gpu" in gs.job["removed_parts"], "thrown component can be recovered and refitted")
    bench.free()
    gs.new_game()
    view = load("res://scenes/main.tscn").instantiate()
    root.add_child(view)
    view.set_process(false)
    view._try_pick_up(view._item_rect(0).get_center())
    view._rotate_part(1)
    view.throw_velocity = Vector2(1700,150)
    view.last_pointer_tick = Time.get_ticks_msec()
    view._drop(view.DRAWER_GRID_ORIGIN+Vector2(180,120),true)
    check(view.thrown.has(0), "hardware drawer supports actual flick throw")
    var drawer_body: RefCounted = view.thrown[0]
    for frame in range(800): view._process(1.0/60)
    check(view.thrown.is_empty() and drawer_body.impacts > 1, "drawer throw settles after physical edge/table impacts")
    var packed: bool = true
    for i in range(view.inventory.items.size()): packed = packed and view.inventory.can_store(i,view.inventory.items[i]["cell"])
    check(packed and view.inventory.items.size() == 6, "throw and resnap preserves all shared items without overlaps")
    check(view.inventory.items[0]["rotation"] == 1, "rotation selected before throw is retained on settling")
    view.free()
    # Legacy migration is scoped to this suite's isolated file.
    gs.new_game()
    gs.job["hardware_trial"] = {"tower":{"trial_ram_a":{"location":"drawer","cell":[5,4],"rotation":1}}}
    var legacy: Dictionary = {"save_format":1,"money":77,"job":gs.job,"upgrades":{}}
    var file := FileAccess.open(gs.save_path,FileAccess.WRITE)
    file.store_string(JSON.stringify(legacy))
    file.close()
    gs.load_game()
    check(gs.player_inventory.size() == 6 and gs.money == 77,"older save gains starter stock exactly once without resetting money")
    check(gs.inventory_layout.get("trial_ram_a",{}).get("rotation",0) == 1,"older active-profile drawer arrangement migrates")
    gs.save_game()
    gs.load_game()
    check(gs.player_inventory.size() == 6,"migration does not repeat or duplicate stock on reload")


func _write_raw(path: String, text: String) -> void:
    var raw := FileAccess.open(path, FileAccess.WRITE)
    raw.store_string(text)
    raw.close()


func test_save_store() -> void:
    var path: String = "user://save_store_test_only.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(path + suffix)
    check(SaveStore.read(path) == null, "reading with no save file returns null")
    check(SaveStore.write(path, {"n": 1}), "first write succeeds")
    check(SaveStore.read(path).get("n") == 1 and not FileAccess.file_exists(path + ".tmp"), "first save reads back and leaves no temp file")
    check(SaveStore.write(path, {"n": 2}), "second write succeeds")
    check(SaveStore.read(path).get("n") == 2, "second save is the one read")
    check(FileAccess.file_exists(path + ".bak") and SaveStore._parse(path + ".bak").get("n") == 1, "previous save is kept as .bak")
    _write_raw(path, "{ this is not json")
    check(SaveStore.read(path).get("n") == 1, "damaged main save recovers from .bak")
    _write_raw(path + ".bak", "also damaged")
    check(SaveStore.read(path) == null, "all copies damaged returns null instead of a crash")
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(path + suffix)


func inside_zone(dust: RefCounted, b: int) -> bool:
    for p: Vector2 in dust.shown[b]:
        if p.distance_to(dust.confine(dust.b_zone[b], p)) > 0.01: return false
    return true

func test_brush_dust() -> void:
    var dust := Dust.new()
    dust.setup(Zones.zones(),Vector2.ZERO,12345)
    var start_count: int = dust.count
    var weight: float = 0.0
    for w: float in dust.zone_weight: weight += w
    var home: Vector2 = dust.b_center[0]
    var farthest: float = 0.0
    var tossed_seen: bool = false
    var kicked_seen: bool = false
    var always_inside: bool = true
    var never_gone: bool = true
    for frame in range(150):
        var contact: Vector2 = dust.shown[0][0]
        dust.brush_contacts = PackedVector2Array([contact])
        dust.step(1.0/60.0,Dust.TOOL_BRUSH,contact,Vector2(500,0),true)
        tossed_seen = tossed_seen or dust.b_state[0] == Dust.TOSSED
        kicked_seen = kicked_seen or dust.kicked.size() > 0
        farthest = maxf(farthest,dust.b_center[0].distance_to(home))
        never_gone = never_gone and dust.b_state[0] != Dust.GONE
        for b in range(dust.count):
            if dust.b_state[b] != Dust.GONE:
                for point: Vector2 in dust.shown[b]:
                    if not dust.case_bounds.has_point(point): always_inside = false
    check(tossed_seen and kicked_seen, "a brushed bundle is tossed and reports where")
    check(farthest > 8.0, "tossing really moves the dust")
    check(never_gone and dust.removed_fraction(dust.b_zone[0]) == 0.0, "the brush removes nothing")
    check(always_inside, "tossed and shed dust stays inside the case")
    var remaining: float = 0.0
    for b in range(dust.count): remaining += dust.b_remaining[b]
    check(absf(remaining-weight) < 0.001, "brushing never changes the total amount of dust")
    for frame in range(120): dust.step(1.0/60.0,Dust.TOOL_BRUSH,Vector2(-999,-999),Vector2.ZERO,false)
    check(dust.b_state[0] == Dust.STUCK, "tossed dust settles and sticks again")
    var swallowed_before: float = dust.swallowed
    var gone: bool = false
    for frame in range(900):
        var nodes: PackedVector2Array = dust.shown[0]
        dust.step(1.0/60.0,Dust.TOOL_VACUUM,nodes[nodes.size()/2],Vector2.ZERO,true)
        if dust.b_state[0] == Dust.GONE:
            gone = true
            break
    check(gone and dust.take_swallowed() > swallowed_before, "tossed dust can still be vacuumed, and the vacuum reports what it took")
    var shedder := Dust.new()
    shedder.setup(Zones.zones(),Vector2.ZERO,12345)
    var parent_nodes: int = shedder.b_n[0]
    var total_before: float = 0.0
    for w: float in shedder.zone_weight: total_before += w
    shedder._shed(0,Vector2(400,0))
    var last: int = shedder.count - 1
    check(shedder.count == start_count + 1 and shedder.b_state[last] == Dust.TOSSED and shedder.b_n[last] == 1, "a brushed chain sheds one separate speck")
    check(shedder.b_n[0] == parent_nodes - 1 and shedder.rest[0].size() == parent_nodes - 1, "the chain gets one node shorter")
    var total_after: float = 0.0
    for b in range(shedder.count): total_after += shedder.b_remaining[b]
    check(absf(total_after-total_before) < 0.001, "shedding keeps the dust weight the same")
    check(shedder.zone_bundles[shedder.b_zone[0]].has(last), "the shed speck belongs to the same part")

func test_bounds() -> void:
    var corners: Array = [Vector2(-900,-900),Vector2(3000,3000),Vector2(-900,3000),Vector2(3000,-900)]
    for turns in [0,6,3]:
        for corner: Vector2 in corners:
            var rig := ToolRig.new()
            rig.select("vacuum",Vector2(300,300))
            for k in range(turns): rig.rotate_held(1)
            for frame in range(180): rig.step(1.0/60.0,corner,false)
            var center: Vector2 = rig.motions["vacuum"].center
            check(center.distance_to(ToolRig.keep_inside(center,rig.motions["vacuum"].angle)) < 0.01 and ToolRig.TABLE.has_point(center),
                "a held tool stays on the bench with the cursor far outside (turns %d)" % turns)
    var acc := Access.new()
    acc.setup(Zones.zones(),Vector2(40,110),[])
    check(acc.begin(acc.homes["cooler"].get_center()), "the cooler can be picked up")
    for corner: Vector2 in corners:
        acc.move(corner)
        check(Access.BOUNDS.grow(0.01).encloses(acc.drag_rect), "a dragged part cannot leave the bench")

func test_hose_bin_motes() -> void:
    var anchor := Vector2(600,550)
    var hose := Hose.new()
    hose.reset(anchor,Vector2(300,300))
    for frame in range(300): hose.step(1.0/60.0,anchor,Vector2(300,300))
    check(hose.pos[0] == anchor and hose.pos[Hose.POINTS-1].distance_to(Vector2(300,300)) < 2.0, "the hose stays attached at both ends")
    check(hose.worst_link_error() < hose.segment*0.2, "hose links keep their length")
    var before: Vector2 = hose.pos[Hose.POINTS/2]
    for frame in range(300): hose.step(1.0/60.0,anchor,Vector2(150,200))
    check(hose.pos[Hose.POINTS-1].distance_to(Vector2(150,200)) < 2.0 and hose.pos[Hose.POINTS/2].distance_to(before) > 20.0, "the middle of the hose follows when the nozzle moves")
    for frame in range(60): hose.step(1.0/60.0,anchor,Vector2(-1500,-1500))
    check(hose.pos[Hose.POINTS/2].is_finite() and hose.tug.length() > 100.0, "a stretched hose stays stable and reports the pull")
    var bin := Bin.new()
    check(bin.add(40.0) == 40.0 and is_equal_approx(bin.fraction(),40.0/Bin.CAPACITY), "the bin fills with dust")
    check(bin.add(1000.0) == Bin.CAPACITY-40.0 and bin.is_full() and bin.add(5.0) == 0.0, "the bin cannot hold more than its capacity")
    check(bin.empty() == Bin.CAPACITY and bin.fill == 0.0 and not bin.is_full(), "emptying the bin resets it")
    var dust := Dust.new()
    dust.setup(Zones.zones(),Vector2.ZERO,12345)
    var motes := Motes.new()
    for frame in range(600): motes.step(1.0/60.0,dust,Vector2(300,300),0.0)
    check(motes.count() > 0 and motes.count() <= Motes.MAX_MOTES, "floating dust appears above dusty parts")
    motes.spawn(Vector2.ZERO,Vector2.ZERO,1000)
    check(motes.count() <= Motes.MAX_MOTES, "floating dust is capped")
    var calm := Motes.new()
    calm.spawn(Vector2(300,300),Vector2.ZERO,20,0.0)
    calm.step(1.0/60.0,dust,Vector2(300,300),1.0)
    check(calm.count() == 0, "the vacuum swallows motes at the nozzle")


func piece(center: Vector2, half: Vector2, inv_mass: float, velocity: Vector2 = Vector2.ZERO, angle: float = 0.0) -> Dictionary:
    return {"id":"x","kind":"tool","center":center,"angle":angle,"half":half,"velocity":velocity,"spin":0.0,
        "inv_mass":inv_mass,"solid":true,"touched":false}

func attach_distance(rig: RefCounted) -> float:
    return rig.hose_end().distance_to(Bin.hose_anchor())

func test_piece_physics(gs: Node) -> void:
    var a: Dictionary = piece(Vector2(100,100),Vector2(20,34),1.0)
    var hit: Dictionary = PieceCollision.overlap(a,piece(Vector2(130,100),Vector2(20,34),1.0))
    check(not hit.is_empty() and absf(float(hit["depth"])-10.0) < 0.01 and Vector2(hit["normal"]).is_equal_approx(Vector2.RIGHT), "overlapping boxes report depth and direction")
    check(PieceCollision.overlap(a,piece(Vector2(200,100),Vector2(20,34),1.0)).is_empty(), "boxes that are apart do not collide")
    check(PieceCollision.overlap(a,piece(Vector2(150,100),Vector2(34,20),1.0,Vector2.ZERO,PI*0.5)).is_empty(), "a turned box is measured turned")
    check(not PieceCollision.overlap(a,piece(Vector2(138,100),Vector2(34,20),1.0,Vector2.ZERO,PI*0.5)).is_empty(), "a turned box that reaches over the edge collides")
    var pair: Array = [piece(Vector2(100,100),Vector2(20,34),1.0,Vector2(200,0)),piece(Vector2(130,100),Vector2(20,34),1.0)]
    check(PieceCollision.resolve(pair) > 0 and PieceCollision.overlap(pair[0],pair[1]).is_empty(), "overlapping pieces are pushed apart")
    check(Vector2(pair[1]["velocity"]).x > 100.0 and Vector2(pair[0]["velocity"]).x < 100.0 and bool(pair[0]["touched"]) and bool(pair[1]["touched"]), "a moving piece hands speed to the one it hits")
    var held: Array = [piece(Vector2(100,100),Vector2(20,34),0.0,Vector2(300,0)),piece(Vector2(130,100),Vector2(20,34),1.0)]
    PieceCollision.resolve(held)
    check(Vector2(held[0]["center"]) == Vector2(100,100) and not bool(held[0]["touched"]) and Vector2(held[1]["center"]).x >= 139.9 and Vector2(held[1]["velocity"]).x > 100.0, "a held piece shoves others and is never pushed")
    check(Vector2(held[1]["velocity"]).length() <= PieceCollision.MAX_SHOVE_SPEED + 0.01, "a shoved piece is nudged, not batted across the bench")
    var flying: Array = [piece(Vector2(100,100),Vector2(20,34),1.0),piece(Vector2(110,100),Vector2(20,34),1.0)]
    flying[1]["solid"] = false
    check(PieceCollision.resolve(flying) == 0 and Vector2(flying[0]["center"]) == Vector2(100,100), "a piece in the air passes over others")
    var rig := ToolRig.new()
    rig.select("brush",Vector2(400,300))
    for frame in range(30): rig.step(1.0/60.0,Vector2(400,300),false)
    var held_center: Vector2 = rig.motions["brush"].center
    rig.motions["pick"].center = held_center + Vector2(30,0)
    var pieces: Array = rig.collision_pieces(["vacuum","brush","pick"])
    var contacts: int = PieceCollision.resolve(pieces)
    rig.apply_collisions(pieces)
    check(contacts > 0 and rig.motions["pick"].center.x > held_center.x + 39.0, "a held tool shoves a resting tool aside")
    check(rig.motions["brush"].center == held_center, "the held tool itself is not pushed")
    for frame in range(120): rig.step(1.0/60.0,Vector2(400,300),false)
    check(not rig.bodies["pick"].active, "a shoved tool comes to rest")
    var wall: Dictionary = {"center":Vector2(300,300),"angle":0.0,"half":Vector2(20,34)}
    check(Hose.push_out(Vector2(305,300),wall,4.0).x >= 323.9 and Hose.push_out(Vector2(500,300),wall,4.0) == Vector2(500,300), "the hose is pushed out of a piece and left alone elsewhere")
    var hose := Hose.new()
    var blocker: Dictionary = {"center":Vector2(450,430),"angle":0.0,"half":Vector2(60,60)}
    hose.reset(Vector2(600,550),Vector2(300,300))
    for frame in range(300): hose.step(1.0/60.0,Vector2(600,550),Vector2(300,300),[blocker])
    var clear: bool = true
    for i in range(1,Hose.POINTS): clear = clear and Hose.push_out(hose.pos[i],blocker,Hose.POINT_RADIUS).distance_to(hose.pos[i]) < 0.6
    check(clear, "the hose lies around a piece instead of through it")
    var base_rig := ToolRig.new()
    base_rig.select("vacuum",Vector2(400,300))
    var long_rig := ToolRig.new()
    long_rig.set_long_hose(true)
    long_rig.select("vacuum",Vector2(400,300))
    for frame in range(300):
        base_rig.step(1.0/60.0,Vector2(50,115),false)
        long_rig.step(1.0/60.0,Vector2(50,115),false)
    var base_reach: float = attach_distance(base_rig)
    var long_reach: float = attach_distance(long_rig)
    check(base_reach <= Hose.BASE_LENGTH*ToolRig.HOSE_STRETCH_LIMIT + 1.0, "the hose never stretches past its limit (reach %.1f)" % base_reach)
    check(base_reach < long_reach - 8.0, "a taut hose holds the vacuum back, and a longer hose reaches further (base %.1f, long %.1f)" % [base_reach, long_reach])
    # Turning the vacuum must not make the hose drag the nozzle off the cursor, even with pieces around.
    for turns in [0, 3, 6, 9, 12, -3, -6]:
        var spin_rig := ToolRig.new()
        spin_rig.hose_obstacles = [{"center":Vector2(520,470),"angle":0.0,"half":Vector2(20,34)},
            {"center":Vector2(380,330),"angle":0.4,"half":Vector2(30,30)}]
        spin_rig.select("vacuum",Vector2(300,300))
        spin_rig.rotate_steps(turns)
        for frame in range(240): spin_rig.step(1.0/60.0,Vector2(300,300),true)
        check(spin_rig.contact().distance_to(Vector2(300,300)) < 2.0, "a vacuum turned %d steps keeps its nozzle on the cursor (off by %.1f)" % [turns, spin_rig.contact().distance_to(Vector2(300,300))])
    var quiet := Hose.new()
    quiet.reset(Vector2(600,550),Vector2(300,300))
    for frame in range(400): quiet.step(1.0/60.0,Vector2(600,550),Vector2(300,300))
    var before: PackedVector2Array = quiet.pos.duplicate()
    for frame in range(30): quiet.step(1.0/60.0,Vector2(600,550),Vector2(300,300))
    var drift: float = 0.0
    for i in range(Hose.POINTS): drift = maxf(drift, quiet.pos[i].distance_to(before[i]))
    check(drift < 0.5, "a hose left alone stops wriggling (drift %.2f)" % drift)
    var filter_zone: Dictionary = {}
    for zone: Dictionary in DustZones.zones():
        if zone["id"] == "front_filter": filter_zone = zone
    check(float(filter_zone.get("grip_scale",1.0)) > 1.0, "the clogged filter grips its dust harder")
    gs.new_game()
    gs.money = 100
    check(gs.buy_upgrade("long_hose") and gs.money == 60 and gs.has_upgrade("long_hose") and not gs.buy_upgrade("long_hose"), "the longer hose is bought once")


# 0.14.2: rounded hose corners, bending limit, grabbing the hose, dust riding the hose to the bin.
func test_hose_handling() -> void:
    var box: Dictionary = {"center":Vector2(300,300),"angle":0.0,"half":Vector2(30,30)}
    var corner: Vector2 = Hose.push_out(Vector2(325,325),box,Hose.POINT_RADIUS)
    var round_reach: float = corner.distance_to(Vector2(300,300) + Vector2(15,15))
    check(absf(round_reach - (15.0 + Hose.POINT_RADIUS)) < 0.01, "obstacle corners are rounded, so the hose curves round them (reach %.2f)" % round_reach)
    var hose := Hose.new()
    hose.reset(Vector2(600,550),Vector2(300,300))
    for frame in range(120):
        var t: float = float(frame) / 120.0
        hose.step(1.0/60.0,Vector2(600,550),Vector2(300+200*sin(t*TAU*2.0),300+80*cos(t*TAU*3.0)),[box])
    for frame in range(60): hose.step(1.0/60.0,Vector2(600,550),Vector2(300,380),[box])
    var sharpest: float = 0.0
    for i in range(1,Hose.POINTS-1):
        sharpest = maxf(sharpest,absf((hose.pos[i]-hose.pos[i-1]).angle_to(hose.pos[i+1]-hose.pos[i])))
    check(rad_to_deg(sharpest) < 62.0, "a hose lying round a piece never folds sharply (sharpest joint %.0f degrees)" % rad_to_deg(sharpest))
    for frame in range(400): hose.step(1.0/60.0,Vector2(600,550),Vector2(300,300))
    var before: PackedVector2Array = hose.pos.duplicate()
    for frame in range(30): hose.step(1.0/60.0,Vector2(600,550),Vector2(300,300))
    var drift: float = 0.0
    for i in range(Hose.POINTS): drift = maxf(drift,hose.pos[i].distance_to(before[i]))
    check(drift < 0.5, "the bending limit does not make a resting hose wriggle (drift %.2f)" % drift)
    var rig := ToolRig.new()
    rig.select("vacuum",Vector2(300,300))
    for frame in range(200): rig.step(1.0/60.0,Vector2(300,300),false)
    var grab_at: Vector2 = rig.hose.pos[8]
    check(rig.hose_hit(grab_at) and not rig.hose_hit(Vector2(-500,-500)), "the hose can be found under the cursor")
    check(rig.grab_hose(grab_at) and not rig.equipped and rig.hose_grab > 0, "grabbing the hose puts the held tool down")
    var target: Vector2 = Bin.hose_anchor() + (grab_at - Bin.hose_anchor()).rotated(0.3) * 0.7
    for frame in range(90): rig.step(1.0/60.0,target,false)
    check(rig.hose.pos[rig.hose_grab].distance_to(target) < 1.0, "the grabbed point follows the cursor")
    var far := Vector2(60,130)
    for frame in range(240): rig.step(1.0/60.0,far,false)
    var held_index: int = rig.hose_grab
    check(rig.hose.pos[held_index].distance_to(Bin.hose_anchor()) <= rig.hose.segment*float(held_index) + 0.5, "the bin side of the hose cannot be stretched by hand")
    check(rig.hose.worst_link_error() < 2.0, "a hose carried by hand keeps its length (worst link error %.2f)" % rig.hose.worst_link_error())
    rig.release_hose()
    check(rig.hose_grab == -1, "releasing lets go of the hose")
    var flow := HoseFlow.new()
    flow.add(5.0)
    var got: float = flow.step(0.3,1.0,100.0)
    check(got == 0.0 and flow.count() == 1, "swallowed dust takes time to ride the hose")
    var waited: float = 0.0
    for frame in range(60): waited += flow.step(1.0/60.0,0.0,100.0)
    check(waited == 0.0 and flow.count() == 1, "with the suction off, dust stays in the hose")
    for frame in range(60): got += flow.step(1.0/60.0,1.0,100.0)
    check(absf(got-5.0) < 0.001 and flow.count() == 0, "with suction, the dust reaches the bin")
    flow.add(10.0)
    var room_left: float = 0.0
    for frame in range(120): room_left += flow.step(1.0/60.0,1.0,4.0-room_left)
    check(absf(room_left-4.0) < 0.001 and absf(flow.carried()-6.0) < 0.001, "a full bin leaves the rest waiting in the hose")


# 0.14.2: a left click with a tool in hand must use THAT tool, at every angle, even with other tools
# shoved right up against it (before the fix, about one click in four grabbed the neighbouring tool).
func test_bench_clicks(gs: Node) -> void:
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    var wrong: int = 0
    var tried: int = 0
    for held: int in [0, 1]:
        for angle_steps in [0, 3, 6, 9, 12, 15, 18, 21]:
            for placed: Vector2 in [Vector2(-50,0), Vector2(50,0), Vector2(0,60), Vector2(0,-60), Vector2(-40,40)]:
                bench.holding = false
                bench._select_tool(held)
                var held_id: String = bench.tools.selected
                bench.tools.turns[held_id] = wrapf(float(angle_steps) * ToolRig.TURN_STEP, -PI, PI)
                bench.scripted_pointer = Vector2(300,260)
                for frame in range(40): bench._physics_process(1.0/60.0)
                var offset: Vector2 = placed
                for id: String in ["vacuum","brush","pick"]:
                    if id == held_id: continue
                    bench.tools.bodies[id].active = false
                    bench.tools.motions[id].center = bench.tools.motions[held_id].center + offset
                    offset = offset.rotated(PI * 0.5)
                for frame in range(40): bench._physics_process(1.0/60.0)
                var press := InputEventMouseButton.new()
                press.button_index = MOUSE_BUTTON_LEFT
                press.pressed = true
                press.position = Vector2(300,260)
                bench._input(press)
                tried += 1
                if bench.tools.selected != held_id or not bench.holding: wrong += 1
                var release := InputEventMouseButton.new()
                release.button_index = MOUSE_BUTTON_LEFT
                release.pressed = false
                release.position = Vector2(300,260)
                bench._input(release)
    check(wrong == 0, "a left click always uses the tool in hand (%d of %d clicks grabbed another tool)" % [wrong, tried])
    bench.tools.park()
    var resting_at: Vector2 = bench.tools.motions["brush"].center
    var pick_up := InputEventMouseButton.new()
    pick_up.button_index = MOUSE_BUTTON_LEFT
    pick_up.pressed = true
    pick_up.position = resting_at
    bench._input(pick_up)
    check(bench.tools.equipped and bench.tools.selected == "brush", "with empty hands, clicking a resting tool picks it up")
    bench.scripted_pointer = null
    bench.queue_free()


# A finished, completed thermal-paste repaste (what the bench's Complete repaste button leaves behind).
func pasted(gs: Node) -> void:
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    gs.job["paste_done"] = true
    gs.job["paste_material"] = "thermal"


# 0.15.0: the repaste only counts once completed; toothpaste is a free scam that runs hotter.
func test_repaste_and_toothpaste(gs: Node) -> void:
    var fractions: Dictionary = {}
    for zone: Dictionary in Zones.zones(): fractions[zone["id"]] = 1.0
    gs.new_game()
    gs.set_dust(fractions)
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    var unfinished: Dictionary = gs.run_final_check()
    check(not unfinished["passed"] and str(unfinished["notes"]).contains("not completed"), "a mount that was never completed does not count as a repaste")
    gs.set_paste({"grade":"BALD SPOTS", "coverage":0.7, "overflow":0.0})
    check(not gs.can_complete_repaste() and not gs.complete_repaste("thermal")["ok"] and gs.money == 100, "a bad result cannot be completed and costs nothing")
    gs.set_paste({"grade":"GOOD ENOUGH", "coverage":0.9, "overflow":0.1})
    var cost: int = int(PasteMaterials.material("thermal")["cost"])
    check(gs.complete_repaste("thermal")["ok"] and gs.money == 100 - cost and gs.job["paste_done"] and gs.job["scams"].is_empty(), "completing with thermal paste charges for the paste once")
    check(not gs.complete_repaste("thermal")["ok"] and gs.money == 100 - cost, "a completed repaste cannot be completed (or charged) twice")
    var honest: Dictionary = gs.run_final_check()
    check(honest["passed"] and honest["paid"] == 60, "a completed thermal repaste on a clean PC passes and pays")
    gs.new_game()
    gs.set_dust(fractions)
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    check(gs.complete_repaste("toothpaste")["ok"] and gs.money == 100 and gs.job["scams"] == ["toothpaste"], "toothpaste is free and is recorded as a scam")
    gs.save_game()
    gs.load_game()
    check(gs.job["paste_material"] == "toothpaste" and gs.job["paste_done"] and gs.job["scams"] == ["toothpaste"], "the toothpaste scam survives save and load")
    var scam: Dictionary = gs.run_final_check()
    check(scam["passed"] and scam["paid"] == 60 and is_equal_approx(scam["temp"], GameState_base(gs) + float(PasteMaterials.material("toothpaste")["heat_penalty"])), "toothpaste passes today's check, runs hotter, and the customer still pays")
    check(str(scam["notes"]).contains("Toothpaste"), "the final check tells the player what is under the cooler")
    gs.new_game()
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    gs.complete_repaste("toothpaste")
    gs.clear_paste()
    check(not gs.job["paste_done"] and gs.job["scams"].is_empty(), "wiping the paste off undoes the completed repaste and the scam record")
    # Older saves: a stored grade without the new field counts as a completed thermal repaste.
    gs.new_game()
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    var data: Dictionary = SaveStore.read(gs.save_path)
    data["job"].erase("paste_done")
    data["job"].erase("paste_material")
    data["job"].erase("scams")
    SaveStore.write(gs.save_path, data)
    gs.load_game()
    check(gs.job["paste_done"] and gs.job["paste_material"] == "thermal" and gs.job["scams"].is_empty(), "an older save's paste grade still counts as a completed repaste")
    # The physics: toothpaste is stiffer, so the same press spreads it less.
    var thermal := PasteSim.new()
    var tooth := PasteSim.new()
    tooth.material = "toothpaste"
    for sim: RefCounted in [thermal, tooth]:
        sim.deposit(25.0, 25.0, 130.0)
        for k in range(150): sim.step(PasteSim.yield_for_pressure(0.6))
    check(float(tooth.measure()["coverage"]) < float(thermal.measure()["coverage"]) - 0.05, "toothpaste spreads less than thermal paste under the same press")
    check(MountSession.TARGET_COVER == PasteSim.PERFECT_COVER and MountSession.OVERFLOW_LIMIT == PasteSim.MESSY_OVERFLOW, "the mounting bars use the same lines as the grade")
    # On the bench: squeeze, press, release, secure, complete.
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_stage(1)
    var cpu_center: Vector2 = bench.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(bench.PASTE_CELL)
    bench.scripted_pointer = cpu_center
    for frame in range(20): bench._physics_process(1.0/60.0)
    bench.holding = true
    for frame in range(120): bench._physics_process(1.0/60.0)
    bench.holding = false
    bench.material_button.button_pressed = true
    bench._on_material_toggled()
    check(bench.paste.material == "thermal", "the paste cannot be switched to toothpaste while paste is on the CPU")
    bench._on_mount_pressed()
    bench.scripted_pressing = true
    for frame in range(170): bench._physics_process(1.0/60.0)
    bench.scripted_pressing = false
    for frame in range(20): bench._physics_process(1.0/60.0)
    for frame in range(600): bench._physics_process(1.0/60.0)
    check(bench.mount.active and bench.mount_result.is_empty(), "running out of time never secures the cooler by itself")
    var miss := InputEventMouseButton.new()
    miss.button_index = MOUSE_BUTTON_LEFT
    miss.pressed = true
    miss.position = Vector2(700, 600)
    bench._input(miss)
    check(bench.mount.active, "clicking somewhere else does not secure the cooler")
    var lever := InputEventMouseButton.new()
    lever.button_index = MOUSE_BUTTON_LEFT
    lever.pressed = true
    lever.position = bench.SECURE_LEVER.get_center()
    bench._input(lever)
    check(not bench.mount.active and not bench.mount_result.is_empty(), "clicking the lever beside the socket secures the cooler")
    bench._physics_process(1.0/60.0)
    var grade: String = str(bench.mount_result.get("grade", ""))
    check(grade in ["PERFECT", "GOOD ENOUGH"], "a pea-sized dot pressed for about 3 seconds gives a good result (got %s)" % grade)
    check(bench.complete_button.visible and not bench.complete_button.disabled, "the Complete repaste button is offered after a good mount")
    bench._on_complete_pressed()
    bench._physics_process(1.0/60.0)
    check(gs.job["paste_done"] and bench.complete_button.disabled and gs.money == 100 - cost, "Complete repaste finishes the job step and pays for the paste")
    bench.scripted_pointer = null
    bench.scripted_pressing = null
    bench.queue_free()


func GameState_base(gs: Node) -> float:
    return gs.BASE_TEMP


# 0.16.0: full housings, continuous hose picking, held-tool priority and optional parking.
func test_hose_housing_and_clamp(gs: Node) -> void:
    var rig := ToolRig.new()
    var housing: Dictionary = {"id":"cooler", "center":Vector2(300,300), "angle":0.4, "half":Vector2(40,32)}
    var brush_piece: Dictionary = {"id":"brush", "kind":"tool", "solid":true, "inv_mass":0.0}
    var loose: Dictionary = housing.duplicate()
    loose.merge({"id":"gpu", "kind":"part", "solid":true, "inv_mass":0.4}, true)
    rig.set_hose_obstacles([brush_piece,loose], [housing])
    check(rig.hose_obstacles.size() == 2, "hose ignores tools but follows both loose and fitted component housings")
    var edge: Vector2 = housing["center"] + Vector2(39,31).rotated(0.4)
    var pushed: Vector2 = Hose.push_out(edge, rig.hose_obstacles[1], Hose.POINT_RADIUS)
    var local: Vector2 = (pushed - Vector2(housing["center"])).rotated(-0.4)
    check(absf(local.x) >= 40.0 or absf(local.y) >= 32.0, "hose clears rotated outer housing corner instead of following fan circle")
    var home: Rect2 = Zones.zones()[1]["rect"]
    home.position += Vector2(40,105)
    var route := ToolRig.new()
    route.select("vacuum", Vector2(100,140))
    route.set_hose_obstacles([], [{"id":"cooler","center":home.get_center(),"angle":0.0,"half":home.size*0.5}])
    for frame in range(300): route.step(1.0/60.0, Vector2(100,140), false)
    var clips: int = 0
    for i in range(1,Hose.POINTS-1):
        for sample in range(10):
            if home.grow(-1.0).has_point(route.hose.pos[i-1].lerp(route.hose.pos[i],float(sample)/10.0)):
                clips += 1
    check(clips == 0, "hose links, not only rope nodes, clear cooler housing corners")
    check(route.hose.worst_link_error() < route.hose.segment*0.25, "housing collision retains hose length")
    loose["inv_mass"] = 0.0
    rig.set_hose_obstacles([brush_piece,loose], [])
    check(rig.hose_obstacles.is_empty(), "carried parts and tools pass above hose without trapping it")
    rig.hose.pos[7] = Vector2(300,200)
    rig.hose.pos[8] = Vector2(338,200)
    check(rig.hose_hit(Vector2(319,200)), "hose can be grabbed between its simulation nodes")
    check(rig.grab_hose(Vector2(319,200)), "continuous hose pick starts a carry")
    rig.release_hose(ToolRig.CLAMP_POINT)
    check(rig.hose_clamp > 0 and rig.hose_grab == -1, "dropping carried hose into desk clamp parks it")
    var clamp_index: int = rig.hose_clamp
    rig.select("brush", Vector2(300,250))
    for frame in range(120): rig.step(1.0/60.0, Vector2(380,260), false)
    check(rig.hose_clamp == clamp_index and rig.hose.pos[clamp_index].distance_to(ToolRig.CLAMP_POINT) < 0.1, "clamp stays pinned while another tool is used")
    check(rig.contact().distance_to(Vector2(380,260)) < 1.0, "brush follows cursor independently of clamped hose")
    rig.unclamp_hose()
    check(rig.hose_clamp == -1, "player can release the desk clamp")
    rig.hose_grab = 1
    rig.release_hose(ToolRig.CLAMP_POINT)
    # 0.21.0 (D80): instead of refusing (which read as "the hose does not attach"), the nearest
    # section that CAN stay stretched here is clipped; the short section itself is never stretched.
    check(rig.hose_clamp > 1 and rig.hose.segment * float(rig.hose_clamp) * 0.98 >= Bin.hose_anchor().distance_to(rig.clamp_position),
        "a too-short bin-side drop clips the nearest reachable section instead")
    rig.unclamp_hose()
    rig.hose_grab = 8
    rig.release_hose(Vector2(200,200))
    check(rig.hose_clamp == -1 and rig.hose_grab == -1, "ordinary drops release hose without auto-clamping")
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_tool(1)
    var mouse := Vector2(300,300)
    bench.tools.hose.pos[7] = mouse
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_RIGHT
    press.pressed = true
    press.position = mouse
    bench._input(press)
    check(bench.tools.carrying and bench.tools.hose_grab < 0, "right-drag of held brush is not stolen by hose underneath")
    bench.tools.release_throw(Vector2.ZERO)
    press.shift_pressed = true
    bench._input(press)
    check(bench.tools.hose_grab > 0, "Shift-right-drag explicitly picks up hose")
    bench.tools.hose_grab = 8
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_RIGHT
    release.position = ToolRig.CLAMP_POINT
    bench._input(release)
    check(bench.tools.hose_clamp == 8, "bench mouse release connects hose carry to visible clamp")
    press.shift_pressed = false
    press.position = ToolRig.CLAMP_POINT
    press.button_index = MOUSE_BUTTON_LEFT
    bench._input(press)
    release.button_index = MOUSE_BUTTON_LEFT
    bench._input(release)
    check(bench.tools.hose_clamp < 0, "empty-hand click releases parked hose")
    press.button_index = MOUSE_BUTTON_RIGHT
    bench.tools.motions["pick"].center = mouse
    press.shift_pressed = true
    press.position = mouse
    bench._input(press)
    check(bench.tools.hose_grab > 0 and not bench.tools.equipped, "explicit hose gesture wins over a tool below it with empty hands")
    bench.tools.release_hose()
    bench._select_tool(2)
    bench._input(press)
    check(bench.tools.hose_grab > 0, "explicit hose pickup also works in move-parts mode")
    bench.free()


# 0.19.7: the hand-state machine (docs/HAND_STATES.md). The rules themselves, then the bench refusing
# the moves the table forbids, in situations that were physically possible before.
func test_hand_machine(gs: Node) -> void:
    check(HandState.allowed(HandState.FREE, HandState.USING_TOOL), "free hands may take a tool")
    check(HandState.allowed(HandState.USING_TOOL, HandState.THROWING), "a held tool may be thrown")
    check(HandState.allowed(HandState.MOUNTING, HandState.FREE), "letting go is always allowed")
    check(not HandState.allowed(HandState.MOUNTING, HandState.USING_TOOL), "no tool may be taken mid-mount")
    check(not HandState.allowed(HandState.CARRYING_HOSE, HandState.USING_TOOL), "no tool may be taken while carrying the hose")
    check(not HandState.allowed(HandState.THROWING, HandState.USING_TOOL), "a throw cannot turn into a tool switch")
    check(not HandState.allowed(HandState.DRAGGING_CLAMP, HandState.DRAGGING_PART), "the clamp and a part cannot be carried together")
    for from: String in HandState.MOVES:
        for to: String in HandState.MOVES[from]:
            check(to in HandState.MOVES, "move target %s exists" % to)
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    # Mid-mount, nothing can be taken into the hands.
    bench._select_stage(1)
    var cpu_center: Vector2 = bench.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(bench.PASTE_CELL)
    bench.scripted_pointer = cpu_center
    for frame in range(20): bench._physics_process(1.0/60.0)
    bench.holding = true
    for frame in range(120): bench._physics_process(1.0/60.0)
    bench.holding = false
    bench._on_mount_pressed()
    check(bench.hand_state() == HandState.MOUNTING, "mounting is its own hand state")
    var cloth_at: Vector2 = bench.tools.motions[Ids.CLOTH].center
    click(bench, MOUSE_BUTTON_RIGHT, true, cloth_at)
    check(not bench.tools.carrying and not bench.tools.equipped and bench.hand_state() == HandState.MOUNTING, "mid-mount, a right-press cannot take or throw a tool")
    click(bench, MOUSE_BUTTON_RIGHT, false, cloth_at)
    var wiping_before: bool = bench.wiping
    bench.wipe_button.button_pressed = not wiping_before
    bench._on_wipe_toggled()
    check(bench.wiping == wiping_before and not bench.tools.equipped, "mid-mount, the wipe toggle is refused and reverted")
    bench._select_dispense()
    check(not bench.tools.equipped and bench.hand_state() == HandState.MOUNTING, "mid-mount, the syringe cannot be taken")
    # Stage navigation must not stand in for a lever. The existing defect is reproduced
    # in test_pending_contracts.gd until Claude fixes it; do not assert it as correct here.
    bench._cancel_unlocked_mount()
    bench._select_stage(0)
    # While carrying the hose, tools stay out of the hands.
    bench.tools.park()
    for frame in range(60): bench._physics_process(1.0/60.0)
    check(bench.tools.grab_hose(bench.tools.hose.pos[8]), "the parked hose can be grabbed")
    check(bench.hand_state() == HandState.CARRYING_HOSE, "carrying the hose is its own hand state")
    bench._select_tool(Dust.TOOL_BRUSH)
    check(not bench.tools.equipped and bench.active_tool != Dust.TOOL_BRUSH, "keyboard tool switch is refused while carrying the hose")
    var vacuum_at: Vector2 = bench.tools.motions[Ids.VACUUM].center
    click(bench, MOUSE_BUTTON_LEFT, true, vacuum_at)
    check(not bench.tools.equipped and bench.hand_state() == HandState.CARRYING_HOSE, "a left click on a resting tool is refused while carrying the hose")
    click(bench, MOUSE_BUTTON_LEFT, false, vacuum_at)
    bench.tools.release_hose(bench.tools.hose.pos[8])
    check(bench.hand_state() == HandState.FREE, "letting go of the hose frees the hands")
    bench._select_tool(Dust.TOOL_BRUSH)
    check(bench.tools.equipped and bench.tools.selected == Ids.BRUSH, "with free hands the same switch works")
    bench.scripted_pointer = null
    bench.queue_free()


# 0.20.0: the user's bug reports and the new bench furniture.
func test_bench_0_20(gs: Node) -> void:
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    # LIVE repro of "cannot remove components": keyboard 3, real clicks, physics stepped like play.
    var key3 := InputEventKey.new()
    key3.keycode = KEY_3
    key3.pressed = true
    bench._input(key3)
    check(bench.active_tool == 2 and bench.hand_state() == "FREE", "key 3 enters Move parts with free hands")
    var cooler_home: Vector2 = bench.access.homes[Ids.COOLER].get_center()
    bench.scripted_pointer = cooler_home
    for frame in range(10): bench._physics_process(1.0/60.0)
    click(bench, MOUSE_BUTTON_LEFT, true, cooler_home)
    check(bench.access.dragging == Ids.COOLER, "left press in Move parts lifts the cooler")
    var tray_spot: Vector2 = Access.TRAY.get_center() + Vector2(120, 0)
    for frame in range(30):
        bench.scripted_pointer = cooler_home.lerp(tray_spot, float(frame) / 29.0)
        bench._physics_process(1.0/60.0)
    click(bench, MOUSE_BUTTON_LEFT, false, tray_spot)
    check(Ids.COOLER in bench.access.removed_ids(), "releasing on the tray removes the cooler")
    check(Ids.COOLER in gs.job["removed_parts"], "the removal reaches the save state")
    for frame in range(90): bench._physics_process(1.0/60.0)   # the parked part eases to its spot; click where it is DRAWN, like a player
    var drawn: Vector2 = (bench._part_rects()[Ids.COOLER] as Rect2).get_center()
    click(bench, MOUSE_BUTTON_LEFT, true, drawn)
    check(bench.access.dragging == Ids.COOLER, "the removed cooler can be lifted from the tray")
    var home_spot: Vector2 = bench.access.homes[Ids.COOLER].get_center()
    for frame in range(40):
        bench.scripted_pointer = drawn.lerp(home_spot, float(frame) / 39.0)
        bench._physics_process(1.0/60.0)
    click(bench, MOUSE_BUTTON_LEFT, false, home_spot)
    check(not Ids.COOLER in bench.access.removed_ids(), "releasing on the mount refits the cooler")
    # Wiping the squeezed-out paste beside the CPU must not cost the mounted result.
    bench._select_stage(1)
    var cpu_center: Vector2 = bench.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(bench.PASTE_CELL)
    bench.scripted_pointer = cpu_center
    for frame in range(20): bench._physics_process(1.0/60.0)
    bench.holding = true
    for frame in range(130): bench._physics_process(1.0/60.0)
    bench.holding = false
    bench._on_mount_pressed()
    bench.scripted_pressing = true
    for frame in range(170): bench._physics_process(1.0/60.0)
    bench.scripted_pressing = null
    click(bench, MOUSE_BUTTON_LEFT, true, bench.SECURE_LEVER.get_center())
    var grade: String = str(bench.mount_result.get("grade", ""))
    check(grade in ["PERFECT", "GOOD ENOUGH"], "the lever secures a good mount (got %s)" % grade)
    var outside: Vector2 = bench.PASTE_ORIGIN + Vector2(3.0, 25.0) * float(bench.PASTE_CELL)   # left of the CPU square
    bench.scripted_pointer = outside   # the cloth equips snapped to the cursor, so it starts here, off the CPU
    bench.wipe_button.button_pressed = true
    bench._on_wipe_toggled()
    check(bench.wiping and bench.tools.selected == Ids.CLOTH, "after the lever the cloth can be taken")
    for frame in range(10): bench._physics_process(1.0/60.0)
    bench.holding = true
    for frame in range(40): bench._physics_process(1.0/60.0)
    bench.holding = false
    check(not bench.mount_result.is_empty() and gs.can_complete_repaste(), "tidying the squeezed-out paste keeps the result and Complete repaste")
    bench.scripted_pointer = cpu_center
    bench.holding = true
    for frame in range(40): bench._physics_process(1.0/60.0)
    bench.holding = false
    check(bench.mount_result.is_empty() and not gs.can_complete_repaste(), "wiping the CPU itself still clears the result")
    # The spool reels the vacuum in (0.22.0: it retracts, not just re-lays).
    bench._select_stage(0)
    bench._select_tool(0)
    var corner := Vector2(90, 150)
    bench.scripted_pointer = corner
    for frame in range(240): bench._physics_process(1.0/60.0)
    bench.tools.park()
    click(bench, MOUSE_BUTTON_LEFT, true, LayoutData.BENCH_SPOOL.get_center())
    check(bench.tools.spool_retracting and bench.tools.hose_clamp == -1, "clicking the spool starts reeling and unclips")
    click(bench, MOUSE_BUTTON_LEFT, false, LayoutData.BENCH_SPOOL.get_center())
    var reeled: int = 0
    while bench.tools.spool_retracting and reeled < 300:
        bench._physics_process(1.0/60.0)
        reeled += 1
    check(not bench.tools.spool_retracting and reeled < 300, "the spool finishes reeling (%d frames)" % reeled)
    check(bench.tools.motions[Ids.VACUUM].center.distance_to(LayoutData.BENCH_SPOOL.get_center()) < 90.0, "the vacuum ends up at the spool")
    check(bench.tools.hose.worst_link_error() < 1.0, "the reeled-in hose lies tidily")
    bench._select_tool(0)
    bench.scripted_pointer = Vector2(300, 300)
    for frame in range(5): bench._physics_process(1.0/60.0)
    click(bench, MOUSE_BUTTON_LEFT, true, LayoutData.BENCH_SPOOL.get_center())
    click(bench, MOUSE_BUTTON_LEFT, false, LayoutData.BENCH_SPOOL.get_center())
    check(bench.tools.spool_retracting, "the spool can start with a tool in hand (it is put down first)")
    bench._equip_tool(Ids.VACUUM, Vector2(300, 300))
    check(not bench.tools.spool_retracting, "taking the vacuum stops the reel")
    # Loose items: pick up with empty hands, not past the machine, and the trash can eats them.
    bench._select_tool(2)
    var spot := Vector2(400, 300)
    var item: int = bench.items.spawn("coin", spot)
    check(item == 0 and bench.items.count() == 1, "a coin can be spawned for the tests")
    click(bench, MOUSE_BUTTON_LEFT, true, spot)
    check(bench.items.carried == 0 and bench.hand_state() == "CARRYING_ITEM", "empty hands pick the coin up (CARRYING_ITEM)")
    var over_trash: Vector2 = LayoutData.BENCH_TRASH.get_center()
    bench.scripted_pointer = over_trash
    for frame in range(10): bench._physics_process(1.0/60.0)
    check(bench.items.centers[0].distance_to(over_trash) < 1.0, "the carried coin rides the cursor")
    click(bench, MOUSE_BUTTON_LEFT, false, over_trash)
    check(bench.items.count() == 0 and bench.items.carried == -1 and bench.hand_state() == "FREE", "dropping it on the trash can bins it")
    bench.items.spawn("screw", spot)
    bench._select_tool(0)
    click(bench, MOUSE_BUTTON_LEFT, true, spot)
    check(bench.items.carried == -1 and bench.holding, "with a tool in hand, a click uses the tool, not the screw")
    click(bench, MOUSE_BUTTON_LEFT, false, spot)
    bench._select_tool(2)
    click(bench, MOUSE_BUTTON_LEFT, true, spot)
    check(bench.items.carried == 0, "in Move parts mode free hands still pick the screw up")
    click(bench, MOUSE_BUTTON_LEFT, false, Vector2(420, 320))
    check(bench.items.count() == 1 and bench.items.carried == -1, "dropping it elsewhere keeps it on the bench")
    check(HandState.allowed(HandState.FREE, HandState.CARRYING_ITEM) and not HandState.allowed(HandState.USING_TOOL, HandState.CARRYING_ITEM), "the machine allows item pickup only with free hands")
    bench.scripted_pointer = null
    bench.queue_free()
    # The menu screen shows the version.
    var start: Node = load("res://scenes/start.tscn").instantiate()
    root.add_child(start)
    var found: bool = false
    for child in start.get_children():
        if child is Label and str((child as Label).text) == "v" + gs.game_version():
            found = true
    check(found, "the menu screen shows v%s" % gs.game_version())
    start.queue_free()


# Promoted from Codex's pending-contracts lane (PR 25), fixed in 0.21.0.
func test_promoted_contracts(gs: Node) -> void:
    for stage: int in [1, 0]:
        gs.new_game(false)
        var bench: Node = load("res://scenes/bench.tscn").instantiate()
        root.add_child(bench)
        bench.set_physics_process(false)
        bench._select_stage(1)
        bench.paste.deposit(25, 25, 120.0)
        var units: float = bench.paste.total_deposited
        bench._on_mount_pressed()
        check(bench.mount.active, "fixture starts a real mount")
        bench._select_stage(stage)
        check(not bench.mount.active and bench.mount_result.is_empty() and str(gs.job["paste_grade"]) == "",
            "D57: a stage switch (to %d) lifts the cooler off without securing or grading" % stage)
        check(bench.paste.total_deposited > units * 0.5, "the pressed paste survives the lifted-off cooler")
        bench._select_stage(1)
        bench._on_mount_pressed()
        check(bench.mount.active, "mounting can simply be started again")
        bench._finish_mount()
        check(str(bench.mount_result.get("grade", "")) != "", "the lever still grades as before")
        bench.free()
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_tool(0)
    bench.tools.park()
    for frame in range(30): bench.tools.step(1.0 / 60.0, Vector2(300, 300), false)
    check(bench.tools.grab_hose(bench.tools.hose.pos[8]), "fixture holds hose before testing refused selection")
    var key := InputEventKey.new()
    key.keycode = KEY_2
    key.pressed = true
    bench._input(key)
    var selection_matches: bool = true
    for index in range(bench.tool_buttons.size()):
        selection_matches = selection_matches and (bench.tool_buttons[index].button_pressed == (index == bench.active_tool))
    check(selection_matches, "a refused tool switch leaves the real tool highlighted")
    bench.free()


# 0.21.0: rotatable clamp, hose always clips to a reachable section, 95% wipe threshold, GPU power.
func test_0_21(gs: Node) -> void:
    var rig := ToolRig.new()
    check(rig.begin_clamp_drag(rig.clamp_position), "fixture grabs the clamp")
    rig.rotate_held(1)
    check(absf(rig.clamp_angle - PI / 12.0) < 0.001, "wheel/Q/E turns the carried clamp, not a tool")
    var tip: Vector2 = rig.clamp_position + Vector2(rig.CLAMP_RECT.size.x * 0.5 - 2.0, 0).rotated(rig.clamp_angle)
    check(rig.clamp_hit(tip), "the turned clamp is hit where it is drawn")
    rig.end_clamp_drag()
    check(not rig.clamp_dragging, "clamp parks turned")
    rig.rotate_held(1)
    check(absf(rig.clamp_angle - PI / 12.0) < 0.001, "a parked clamp does not turn")
    var near_bin := ToolRig.new()
    near_bin.hose_grab = 2   # a section too close to the bin to stay stretched at the clamp
    near_bin.release_hose(near_bin.clamp_position)
    check(near_bin.hose_clamp > 2 and near_bin.hose.segment * float(near_bin.hose_clamp) * 0.98 >= Bin.hose_anchor().distance_to(near_bin.clamp_position),
        "dropping a too-short section on the clamp clips the nearest section that reaches (got %d)" % near_bin.hose_clamp)
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_tool(0)
    bench.tools.park()
    for frame in range(60): bench._physics_process(1.0 / 60.0)
    check(bench.tools.grab_hose(bench.tools.hose.pos[8]), "fixture grabs the hose")
    click(bench, MOUSE_BUTTON_RIGHT, false, bench.tools.clamp_position)
    check(bench.tools.hose_clamp > 0, "dropping the hose on the clamp clips it")
    bench.tools.rewind_hose()
    # Wiping a graded CPU: the result survives until the paste falls below 95% of its graded amount.
    bench._select_stage(1)
    var cpu_center: Vector2 = bench.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(bench.PASTE_CELL)
    bench.scripted_pointer = cpu_center
    for frame in range(20): bench._physics_process(1.0 / 60.0)
    bench.holding = true
    for frame in range(130): bench._physics_process(1.0 / 60.0)
    bench.holding = false
    bench._on_mount_pressed()
    bench.scripted_pressing = true
    for frame in range(170): bench._physics_process(1.0 / 60.0)
    bench.scripted_pressing = null
    click(bench, MOUSE_BUTTON_LEFT, true, bench.SECURE_LEVER.get_center())
    var graded: float = float(gs.job["paste_graded_units"])
    check(str(bench.mount_result.get("grade", "")) in ["PERFECT", "GOOD ENOUGH"] and graded > 0.0, "grading records the paste on the CPU")
    bench.wipe_button.button_pressed = true
    bench.scripted_pointer = cpu_center
    bench._on_wipe_toggled()
    bench.holding = true
    var frames_wiped: int = 0
    while not bench.mount_result.is_empty() and frames_wiped < 600:
        bench._physics_process(1.0 / 60.0)
        frames_wiped += 1
        if bench.paste.total_deposited >= graded * bench.KEEP_GRADE_ABOVE:
            check(not bench.mount_result.is_empty(), "the grade survives while at least 95%% of the graded paste remains (%.0f of %.0f)" % [bench.paste.total_deposited, graded])
            break
    bench.holding = false
    if not bench.mount_result.is_empty():
        bench.holding = true
        while not bench.mount_result.is_empty() and frames_wiped < 1200:
            bench._physics_process(1.0 / 60.0)
            frames_wiped += 1
        bench.holding = false
    check(bench.mount_result.is_empty() and bench.paste.total_deposited < graded * bench.KEEP_GRADE_ABOVE,
        "wiping on until below 95%% clears the grade (%.0f of %.0f after %d frames)" % [bench.paste.total_deposited, graded, frames_wiped])
    bench.scripted_pointer = null
    bench.queue_free()
    # GPU power (D79): a dead GPU outputs 0 and fails; a fitted replacement outputs its tier's power.
    var fractions: Dictionary = {}
    for zone: Dictionary in Zones.zones(): fractions[zone["id"]] = 1.0
    gs.new_game()
    gs.set_dust(fractions)
    pasted(gs)
    check(int(gs.job["required_power"]) == 60, "the trial job needs 60 graphics power")
    gs.damage_service_part("gpu")
    var dead: Dictionary = gs.run_final_check()
    check(not dead["passed"] and str(dead["notes"]).contains("Graphics output is 0"), "a dead GPU outputs 0 and the check says so")
    gs.job["removed_parts"].append("gpu")
    check(gs.replace_service_part("gpu", "budget"), "a budget GPU can be fitted from stock")
    var fitted: Dictionary = gs.run_final_check()
    check(fitted["passed"] and not str(fitted["notes"]).contains("Graphics output is"), "a 65-power budget GPU meets this PC's 60 and the job passes")
    gs.job["required_power"] = 100
    var demanding: Dictionary = gs.run_final_check()
    check(not demanding["passed"] and str(demanding["notes"]).contains("needs at least 100"), "a PC that needs 100 rejects the 65-power budget card")
    gs.save_game()
    gs.load_game()
    check(int(gs.job["required_power"]) == 100, "the power requirement survives save and load")


# 0.22.0: the hose end is attached to the vacuum, the clipped hose is a short leash, the PC power
# button, and a stress test for "tools disappear when there is no room".
func test_0_22(gs: Node) -> void:
    var rig := ToolRig.new()
    rig.select(Ids.VACUUM, Vector2(560, 380))
    rig.park()
    for frame in range(60): rig.step(1.0/60.0, Vector2(560, 380), false)
    rig.hose_grab = Hose.POINTS - ToolRig.HOSE_GRAB_KEEP - 1   # a section near the nozzle
    rig.release_hose(rig.clamp_position)
    var pin: int = rig.hose_clamp
    check(pin == Hose.POINTS - ToolRig.HOSE_GRAB_KEEP - 1, "the hose is clipped near its nozzle end")
    for frame in range(360): rig.step(1.0/60.0, Vector2(100, 200), false)
    var last: int = Hose.POINTS - 1
    check(rig.hose.pos[last].distance_to(rig.hose_end()) < 0.01, "the hose end stays ON the vacuum (no detaching)")
    var leash: float = rig.hose.segment * float(last - pin) * ToolRig.HOSE_STRETCH_LIMIT
    var apart: float = rig.hose.pin_point.distance_to(rig.hose_end())
    check(apart <= leash + 3.0, "a hose clipped near the nozzle keeps the vacuum on a short leash (%.0f of %.0f px)" % [apart, leash])
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    # PC power button: fans stop while off, and the switch survives save and load.
    check(bool(gs.job["pc_powered"]), "a new job starts powered on")
    for frame in range(30): bench._physics_process(1.0/60.0)
    click(bench, MOUSE_BUTTON_LEFT, true, LayoutData.BENCH_POWER.get_center())
    click(bench, MOUSE_BUTTON_LEFT, false, LayoutData.BENCH_POWER.get_center())
    check(not bool(gs.job["pc_powered"]), "clicking the case button powers the PC off")
    for frame in range(400): bench._physics_process(1.0/60.0)
    check(bench.cooler_rpm < 1.0 and bench.case_rpm < 1.0, "the fans wind down to a stop (%.1f / %.1f RPM)" % [bench.cooler_rpm, bench.case_rpm])
    gs.save_game()
    gs.load_game()
    check(not bool(gs.job["pc_powered"]), "the power state survives save and load")
    click(bench, MOUSE_BUTTON_LEFT, true, LayoutData.BENCH_POWER.get_center())
    click(bench, MOUSE_BUTTON_LEFT, false, LayoutData.BENCH_POWER.get_center())
    for frame in range(240): bench._physics_process(1.0/60.0)
    check(bool(gs.job["pc_powered"]) and bench.case_rpm > 5.0, "powering back on spins the fans up")
    # Stress: hurl tools into the crowded tray corner; nothing may vanish or leave the table.
    var generator := RandomNumberGenerator.new()
    generator.seed = 777
    for throw in range(12):
        var id: String = ["vacuum", "brush", "pick"][throw % 3]
        bench._select_tool({"vacuum": 0, "brush": 1, "pick": 3}[id])
        var start := Vector2(generator.randf_range(80, 600), generator.randf_range(140, 600))
        bench.scripted_pointer = start
        for frame in range(3): bench._physics_process(1.0/60.0)
        bench.tools.begin_throw(start)
        bench.tools.release_throw((Vector2(620, 620) - start).normalized() * generator.randf_range(600, 1500))
        for frame in range(100): bench._physics_process(1.0/60.0)
    var lost: Array = []
    for id: String in ["vacuum", "brush", "pick"]:
        var at: Vector2 = bench.tools.motions[id].center
        if not is_finite(at.x) or not is_finite(at.y) or not ToolRig.TABLE.grow(4.0).has_point(at):
            lost.append("%s at %s" % [id, str(at)])
    check(lost.is_empty(), "after 12 corner throws every tool is still on the table (%s)" % str(lost))
    check(bench.tools.hose.pos[Hose.POINTS - 1].distance_to(bench.tools.hose_end()) < 0.01, "the hose end is still on the vacuum after the barrage")
    bench.scripted_pointer = null
    bench.queue_free()
