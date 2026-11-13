# Physical dust transport + first-entry/reopen/reset input regression. Dedicated test save only.
extends SceneTree
const Dust = preload("res://scripts/bench/dust_sim.gd")
const Snapshot = preload("res://scripts/bench/dust_snapshot.gd")
const Zones = preload("res://scripts/data/dust_zones.gd")
const Access = preload("res://scripts/bench/service_access.gd")
const Rig = preload("res://scripts/bench/tool_rig.gd")
var checks: int = 0
var failed: int = 0

func _initialize() -> void: call_deferred("run_checks")
func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: " + label)

func mass(dust: RefCounted) -> float:
    var total: float = 0.0
    for left: float in dust.b_remaining: total += left
    return total

func put(dust: RefCounted, b: int, center: Vector2) -> void:
    var nodes: PackedVector2Array = dust.rest[b].duplicate()
    var offset: Vector2 = center-dust.b_center[b]
    for i in range(nodes.size()): nodes[i] += offset
    dust.rest[b] = nodes
    dust.shown[b] = nodes.duplicate()
    dust.b_center[b] = center

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://dust_flow_test_only.json"
    gs.new_game()
    change_scene_to_file("res://scenes/bench.tscn")
    await process_frame
    await process_frame
    for path: String in ["first entry","saved reopen","legacy save","New dirty PC","Reset helper"]:
        var bench: Node = current_scene
        bench.set_physics_process(false)
        check(bench.dust.visible_count() > 0 and bench.tools.equipped, path + ": tools/dust ready without reset")
        var b: int = -1
        for i in range(bench.dust.count):
            if bench.dust.b_state[i] != Dust.GONE and not bench.dust.is_hidden(i):
                b = i
                break
        check(b >= 0, path + ": accessible dirt exists")
        if b < 0: break
        var before: float = mass(bench.dust)
        bench.scripted_pointer = bench.dust.b_center[b]
        bench._select_tool(0)
        var press := InputEventMouseButton.new()
        press.button_index = MOUSE_BUTTON_LEFT
        press.pressed = true
        press.position = bench.scripted_pointer
        bench._input(press)
        for frame in range(180): bench._physics_process(1.0/60.0)
        check(mass(bench.dust) < before, path + ": actual held vacuum removes dust on first use")
        bench.holding = false
        var brushed: int = -1
        for i in range(bench.dust.count):
            if bench.dust.b_state[i] == Dust.STUCK and not bench.dust.is_hidden(i):
                brushed = i
                break
        if brushed >= 0:
            var center: Vector2 = bench.dust.b_center[brushed]
            var loosen: float = bench.dust.b_loosen[brushed]
            bench.scripted_pointer = center
            bench._select_tool(1)
            press.position = center
            bench._input(press)
            var responds: bool = false
            for frame in range(150):
                bench.scripted_pointer = center+Vector2(sin(float(frame)*0.14)*12.0,0)
                bench._physics_process(1.0/60.0)
                responds = responds or bench.dust.b_loosen[brushed] < loosen-0.02 or bench.dust.b_state[brushed] == Dust.TOSSED
            check(responds, path + ": actual brush bristles loosen dust on first use")
        bench.holding = false
        if path == "first entry":
            bench._save_dust()
            check(not gs.job["dust_state"].is_empty(), "bench saves physical dust rather than only percentages")
            gs.load_game()
            reload_current_scene()
        elif path == "saved reopen":
            gs.set_dust(bench._dust_fractions())
            gs.load_game()
            # Avoid scene-exit autosave replacing the intentionally legacy test fixture.
            bench.loaded_job_id = "legacy-fixture"
            reload_current_scene()
        elif path == "legacy save":
            bench._new_ticket()
        elif path == "New dirty PC":
            bench._on_reset_dust()
        else: break
        await process_frame
        await process_frame
    current_scene.free()
    test_transport()
    test_clamp()
    for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(gs.save_path+suffix)
    gs.save_path = original_path
    gs.new_game(false)
    print("Dust flow checks: %d, failures: %d" % [checks,failed])
    quit(1 if failed else 0)

func test_transport() -> void:
    var dust := Dust.new()
    var zones: Array = Zones.zones()
    dust.setup(zones,Vector2.ZERO,12345)
    var before: float = mass(dust)
    var old: Vector2 = dust.b_center[0]
    dust._toss(0,Vector2(700,0))
    for frame in range(30): dust.step(1.0/60.0,Dust.TOOL_BRUSH,Vector2(-999,-999),Vector2.ZERO,false)
    check(dust.b_center[0].distance_to(old) > 40.0 and dust.b_zone[0] != 0, "overbrushing carries dirt beyond its component")
    check(absf(mass(dust)-before) < 0.001 and dust.remaining_fraction() > 0.999, "moving dust is never counted as vacuum removal")
    for frame in range(240): dust.step(1.0/60.0,Dust.TOOL_BRUSH,Vector2(-999,-999),Vector2.ZERO,false)
    var contained: bool = true
    for i in range(dust.count):
        for point: Vector2 in dust.shown[i]: contained = contained and dust.case_bounds.has_point(point)
    check(contained, "case walls contain every displaced node")
    var access := Access.new()
    access.setup(zones,Vector2.ZERO,[])
    dust.set_blockers(access.blockers())
    var gpu: Rect2 = access.homes["gpu"]
    put(dust,0,Vector2(gpu.position.x-16,gpu.get_center().y))
    dust._toss(0,Vector2(700,0))
    dust.b_vel[0] = Vector2(650,0)
    for frame in range(12): dust.step(1.0/60.0,Dust.TOOL_BRUSH,Vector2(-999,-999),Vector2.ZERO,false)
    check(dust.b_zone[0] == Zones.index_of("under_gpu") and dust.is_hidden(0), "fast brush stroke catches dirt under installed GPU")
    check(dust.trapped_count("gpu") == 8, "pick inspection includes newly trapped dirt")
    var trapped: float = mass(dust)
    for frame in range(120): dust.step(1.0/60.0,Dust.TOOL_VACUUM,dust.b_center[0],Vector2.ZERO,true)
    check(dust.b_state[0] != Dust.GONE, "installed GPU protects transported dirt from vacuum")
    # Snapshot survives JSON decoding, preserving trap/location/grip and exact cleaning fractions.
    var saved: Dictionary = JSON.parse_string(JSON.stringify(Snapshot.capture(dust)))
    var resumed := Dust.new()
    resumed.setup(zones,Vector2.ZERO,12345)
    resumed.set_blockers(access.blockers())
    check(Snapshot.restore(resumed,saved), "physical dust snapshot restores through JSON")
    check(resumed.is_hidden(0) and resumed.b_center[0].distance_to(dust.b_center[0]) < 0.001 and absf(mass(resumed)-mass(dust)) < 0.001, "reopen preserves transported location, protection and mass")
    access.set_removed("gpu",true)
    resumed.set_blockers(access.blockers())
    for frame in range(180): resumed.step(1.0/60.0,Dust.TOOL_VACUUM,resumed.b_center[0],Vector2.ZERO,true)
    check(resumed.b_state[0] == Dust.GONE and mass(resumed) < trapped, "removing GPU exposes displaced dust for vacuum")
    var filter_zone: int = Zones.index_of("front_filter")
    var filter: Rect2 = zones[filter_zone]["rect"]
    dust.shake_off_zone(filter_zone)
    check(is_equal_approx(dust.removed_fraction(filter_zone),1.0), "filter can start physically clean")
    dust.set_blockers([])
    put(dust,1,Vector2(filter.position.x-15,filter.get_center().y))
    dust._toss(1,Vector2(700,0))
    dust.b_vel[1] = Vector2(650,0)
    for frame in range(10): dust.step(1.0/60.0,Dust.TOOL_BRUSH,Vector2(-999,-999),Vector2.ZERO,false)
    check(dust.b_zone[1] == Zones.index_of("front_filter") and dust.b_state[1] == Dust.STUCK, "filter catches displaced dust")
    check(dust.removed_fraction(filter_zone) < Zones.CLEAN_AT, "incoming dirt can dirty an already-clean filter again")
    var base_grip: float = 0.55 if dust.b_n[1] == 1 else Dust.GRIP_BASE+Dust.GRIP_PER_NODE*dust.b_n[1]
    check(is_equal_approx(dust.b_grip[1],base_grip*1.5), "filter gives caught dust its stronger grip")
    # A vacuum that is switched off cannot delete a formerly loose bundle on a timeout.
    dust.b_state[2] = Dust.LOOSE
    var lost_before: float = mass(dust)
    for frame in range(240): dust.step(1.0/60.0,Dust.TOOL_VACUUM,Vector2(-999,-999),Vector2.ZERO,false)
    check(absf(mass(dust)-lost_before) < 0.001, "vacuum-off dust settles without disappearing")
    var invalid: Dictionary = saved.duplicate(true)
    invalid["records"][0]["nodes"] = [["bad",0]]
    var clean := Dust.new()
    clean.setup(zones,Vector2.ZERO,12345)
    var fresh_mass: float = mass(clean)
    check(not Snapshot.restore(clean,invalid) and is_equal_approx(mass(clean),fresh_mass), "bad snapshot rejects atomically without losing dirt")

func test_clamp() -> void:
    var rig := Rig.new()
    rig.clamp_pc = Rect2(120,105,450,400)
    check(rig.begin_clamp_drag(rig.clamp_position), "right-drag can pick up clamp")
    check(rig.move_clamp(Vector2(450,615)), "clamp can move on desk outside PC")
    var parked: Vector2 = rig.clamp_position
    check(not rig.move_clamp(Vector2(400,300)) and rig.clamp_position == parked, "clamp rejects placement inside PC")
    check(not rig.move_clamp(Vector2(120,300)), "whole clamp footprint cannot overlap case edge")
    check(not rig.move_clamp(Vector2(610,570)), "clamp cannot overlap dust bin")
    rig.hose_grab = 8
    rig.release_hose(rig.clamp_position)
    for frame in range(30): rig.step(1.0/60.0,rig.clamp_position,false)
    check(rig.hose_clamp == 8 and rig.hose.pos[8].distance_to(rig.clamp_position) < 0.1, "hose parks at moved clamp rather than old coordinate")
    rig.end_clamp_drag()
    rig.select("brush",Vector2(300,300))
    check(not rig.clamp_dragging and rig.hose_clamp == 8, "tool can be selected after parking on moved clamp")
