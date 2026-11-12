# Run: godot --headless --path . --script res://tools/test_regressions.gd
# Uses a dedicated test save path and restores the autoload's original in-memory state.
extends SceneTree
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
const PieceCollision = preload("res://scripts/bench/piece_collision.gd")
const Bin = preload("res://scripts/bench/dust_bin.gd")
const Motes = preload("res://scripts/bench/dust_motes.gd")
var failed: int = 0
var checks: int = 0

func _initialize() -> void:
    call_deferred("run_checks")

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: " + label)

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://regression_test_only.json"
    gs.new_game()
    check(not gs.run_final_check()["passed"] and gs.money == 100, "unrepaired PC cannot collect payment")
    var z: Array = Zones.zones()
    var dust: RefCounted = Dust.new()
    dust.setup(z, Vector2.ZERO, 12345)
    check(dust.count == 85 and is_equal_approx(dust.remaining_fraction(), 1.0), "new PC has visible dust without Reset")
    for fraction: float in [0.0, 0.123, 0.499, 0.91, 1.0]:
        var value: float = fraction
        for k in range(20):
            dust.setup(z, Vector2.ZERO, 12345)
            dust.apply_progress(0, value)
            value = dust.removed_fraction(0)
        check(absf(value - fraction) < 0.00001, "no dust reload drift: " + str(fraction))
    var duration: float = 0.0
    dust.setup(z, Vector2.ZERO, 12345)
    while dust.remaining_fraction() > 0.0 and duration < 90:
        var target: int = -1
        for b in range(dust.count):
            if dust.b_state[b] != Dust.GONE:
                target = b
                break
        if target < 0: break
        var nodes: PackedVector2Array = dust.shown[target]
        dust.step(1.0 / 60.0, Dust.TOOL_VACUUM, nodes[nodes.size() / 2], Vector2.ZERO, true)
        duration += 1.0 / 60.0
    print("Scripted vacuum clear time: %.2f seconds (not human play time)" % duration)
    check(duration > 8.2 and duration < 65, "restrained vacuum pace remains below old 80s model")
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
    var extra_syringes: int = 0
    for child: Node in bench.get_children():
        if child is Button and child.text.contains("Apply paste / syringe"): extra_syringes += 1
    check(extra_syringes == 0, "duplicate syringe button removed")
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
    check(clean_bench.status_label.text.contains("Resumed saved PC"), "clean resume clearly explained")
    clean_bench.free()
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
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
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(gs.save_path + suffix)
    gs.save_path = original_path
    print("Regression checks: %d, failures: %d" % [checks, failed])
    quit(1 if failed else 0)


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
    for i in range(47): check(tool.step(1.0 / 60.0, "gpu", true, 0.99).is_empty(), "no per-frame risk rolls")
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
    check(original == 7, "inspection counts bundles and independent specks")
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
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
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
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    check(gs.buy_service_stock("cooler","budget"), "cooler purchase charges before installation")
    check(gs.replace_service_part("cooler", "budget") and gs.money == 93 and gs.job["paste_grade"] == "", "new cooler needs fresh paste")
    gs.set_dust(fractions)
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
    final = gs.run_final_check()
    check(is_equal_approx(final["temp"], 50.0), "budget cooler imposes real temperature penalty")
    gs.new_game()
    gs.set_dust(fractions)
    gs.set_paste({"grade":"PERFECT", "coverage":1.0, "overflow":0.0})
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
    for frame in range(60): slow.step(0.1,Dust.TOOL_BRUSH,slow.rest[0][0],Vector2(20,0),true)
    check(slow.b_state[0] == Dust.STUCK and slow.count == 85, "a nearly still brush neither tosses nor sheds dust")
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
    check(bench.dust.visible_count() >= 70, "new repair bench displays dust immediately before any Reset")
    bench._select_stage(1)
    bench.tools.park()
    var cloth_press := InputEventMouseButton.new()
    cloth_press.button_index = MOUSE_BUTTON_LEFT
    cloth_press.pressed = true
    cloth_press.position = bench.tools.motions["cloth"].center
    bench._input(cloth_press)
    check(bench.tools.equipped and bench.tools.selected == "cloth" and bench.wiping,"paste-stage cloth can be picked from rack outside CPU work area")
    bench._select_stage(0)
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
    check(bench.dust.visible_count() >= 70 and bench.dust.remaining_fraction() > 0.99, "next PC starts dusty without pressing Reset")
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
            if dust.b_state[b] != Dust.GONE and not inside_zone(dust,b): always_inside = false
    check(tossed_seen and kicked_seen, "a brushed bundle is tossed and reports where")
    check(farthest > 8.0, "tossing really moves the dust")
    check(never_gone and dust.removed_fraction(dust.b_zone[0]) == 0.0, "the brush removes nothing")
    check(always_inside, "tossed and shed dust stays inside its own part")
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
    check(Vector2(held[0]["center"]) == Vector2(100,100) and not bool(held[0]["touched"]) and Vector2(held[1]["center"]).x >= 139.9 and Vector2(held[1]["velocity"]).x > 300.0, "a held piece shoves others and is never pushed")
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
    gs.new_game()
    gs.money = 100
    check(gs.buy_upgrade("long_hose") and gs.money == 60 and gs.has_upgrade("long_hose") and not gs.buy_upgrade("long_hose"), "the longer hose is bought once")
