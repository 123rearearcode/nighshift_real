# Visible trapped tails, real clamp input, short hose reach and mount-phase put-down regression.
extends SceneTree
const Dust = preload("res://scripts/bench/dust_sim.gd")
const Zones = preload("res://scripts/data/dust_zones.gd")
const Access = preload("res://scripts/bench/service_access.gd")
const Rig = preload("res://scripts/bench/tool_rig.gd")
const Hose = preload("res://scripts/bench/hose_sim.gd")
var checks: int = 0
var failed: int = 0

func _initialize() -> void: call_deferred("run_checks")
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: "+message)

func click(bench: Node, button: int, pressed: bool, at: Vector2) -> void:
    var event := InputEventMouseButton.new()
    event.button_index = button
    event.pressed = pressed
    event.position = at
    bench._input(event)

func new_bench(gs: Node) -> Node:
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    return bench

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original: String = gs.save_path
    gs.save_path = "user://bench_feedback_test_only.json"
    test_tails()
    var bench: Node = new_bench(gs)
    var blocked_by_ui: bool = false
    for child: Node in bench.get_children():
        if child is Button and child.visible and child.get_global_rect().intersects(bench.tools.clamp_rect()): blocked_by_ui = true
    check(not blocked_by_ui,"clamp has no overlapping button swallowing mouse input")
    var start: Vector2 = bench.tools.clamp_position
    click(bench,MOUSE_BUTTON_LEFT,true,start)
    bench.scripted_pointer = Vector2(450,625)
    for frame in range(20): bench._physics_process(1.0/60.0)
    click(bench,MOUSE_BUTTON_LEFT,false,bench.scripted_pointer)
    check(bench.tools.clamp_position.distance_to(start) > 100.0 and not bench.tools.clamp_dragging,"ordinary left drag moves and releases clamp")
    var moved: Vector2 = bench.tools.clamp_position
    click(bench,MOUSE_BUTTON_LEFT,true,moved)
    click(bench,MOUSE_BUTTON_LEFT,false,bench.dust.case_bounds.get_center())
    check(bench.tools.clamp_position == moved,"dragging clamp into PC leaves its last valid position")
    click(bench,MOUSE_BUTTON_RIGHT,true,moved)
    click(bench,MOUSE_BUTTON_RIGHT,false,Vector2(500,625))
    check(bench.tools.clamp_position.distance_to(Vector2(500,625)) < 1.0,"right drag also moves fixture without an intervening physics frame")
    bench.tools.hose_grab = 8
    bench.tools.release_hose(bench.tools.clamp_position)
    click(bench,MOUSE_BUTTON_LEFT,true,bench.tools.clamp_position)
    click(bench,MOUSE_BUTTON_LEFT,false,bench.tools.clamp_position)
    check(bench.tools.hose_clamp == -1,"stationary left click still unclips parked hose")
    var before_switch: Vector2 = bench.tools.clamp_position
    click(bench,MOUSE_BUTTON_LEFT,true,before_switch)
    bench._select_tool(0)
    click(bench,MOUSE_BUTTON_LEFT,false,bench.dust.case_bounds.get_center())
    check(bench.tools.clamp_position == before_switch and not bench.tools.clamp_dragging and bench.clamp_button == 0,"switching tools cancels clamp capture without a later phantom move")
    bench.free()
    for profile: String in ["tower","compact"]:
        bench = new_bench(gs)
        if profile == "compact":
            bench.free()
            gs.job["layout"] = profile
            bench = load("res://scenes/bench.tscn").instantiate()
            root.add_child(bench)
            bench.set_physics_process(false)
        var corner: Vector2 = bench.dust.case_bounds.position
        bench.scripted_pointer = corner
        bench._select_tool(0)
        bench.tools.rotate_steps(6)
        for frame in range(240): bench._physics_process(1.0/60.0)
        var error: float = bench.tools.contact().distance_to(corner)
        var span: float = bench.tools.hose_end().distance_to(bench.tools.hose.anchor)
        check(error < 22.0,profile+" base hose can just reach far-left corner with nozzle rotated (error %.1f)"%error)
        check(span > Hose.BASE_LENGTH*0.98 and span < Hose.BASE_LENGTH*Rig.HOSE_STRETCH_LIMIT+1.0,profile+" far corner requires a nearly taut hose")
        bench.scripted_pointer = corner-Vector2(80,0)
        for frame in range(240): bench._physics_process(1.0/60.0)
        check(bench.tools.contact().distance_to(bench.scripted_pointer) > 35.0,profile+" base hose has no spare reach far beyond case")
        bench.free()
    bench = new_bench(gs)
    bench._select_tool(2) # mode from the cleaning stage must not block paste-tool put-down
    bench._select_stage(1)
    var at := Vector2(610,450)
    bench.tools.select("syringe",at)
    click(bench,MOUSE_BUTTON_RIGHT,true,at)
    click(bench,MOUSE_BUTTON_RIGHT,false,at)
    check(not bench.tools.equipped,"paste tools can be put down after entering from Move parts mode")
    bench.paste.deposit(25,25,117.0)
    bench.tools.select("syringe",at)
    bench._on_mount_pressed()
    check(bench.mount.active and not bench.tools.equipped,"starting cooler press sets held tool down automatically")
    for expired: bool in [false,true]:
        if expired: bench.mount.time_left = 0.0
        bench.tools.select("cloth",at)
        var before: float = bench.mount.time_left
        click(bench,MOUSE_BUTTON_RIGHT,true,at)
        click(bench,MOUSE_BUTTON_RIGHT,false,at)
        check(not bench.tools.equipped and not bench.tools.carrying,"tool can be put down while cooler waits for lever (expired=%s)"%expired)
        check(bench.mount.active and bench.mount.time_left == before and bench.mount_result.is_empty(),"put-down does not finish/reset cooler or fake a lever action")
    bench.free()
    for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(gs.save_path+suffix)
    gs.save_path = original
    gs.new_game(false)
    print("Bench feedback checks: %d, failures: %d"%[checks,failed])
    quit(1 if failed else 0)

func test_tails() -> void:
    var dust := Dust.new()
    dust.setup(Zones.zones(),Vector2.ZERO,12345)
    var access := Access.new()
    access.setup(Zones.zones(),Vector2.ZERO,[])
    dust.set_blockers(access.blockers())
    var under: int = Zones.index_of("under_gpu")
    var b: int = -1
    for index: int in dust.zone_bundles[under]:
        if dust.b_n[index] > 1 and not dust.tail_nodes(index).is_empty(): b = index
    var tail: PackedVector2Array = dust.tail_nodes(b)
    check(dust.is_hidden(b) and tail.size() == 4,"hidden GPU dust has a visible partial chain")
    var rect: Rect2 = access.homes["gpu"]
    check(not rect.has_point(tail[tail.size()-1]) and dust.case_bounds.has_point(tail[tail.size()-1]),"chain protrudes beyond housing and stays inside case")
    var visible: int = 0
    for index: int in dust.zone_bundles[under]:
        if not dust.tail_nodes(index).is_empty(): visible += 1
    check(visible == Dust.TAIL_LIMIT,"a few representative chains avoid exposing whole hidden dust field")
    var target: Vector2 = tail[tail.size()-1]
    var before: float = dust.remaining_fraction()
    for frame in range(180): dust.step(1.0/60.0,Dust.TOOL_BRUSH,target,Vector2(500,0),true)
    check(dust.b_state[b] != Dust.GONE and dust.remaining_fraction() == before,"brush cannot delete pinned dust through a visible tail")
    for frame in range(120): dust.step(1.0/60.0,Dust.TOOL_VACUUM,dust.b_center[b],Vector2.ZERO,true)
    check(dust.b_state[b] != Dust.GONE,"vacuum on covered center still cannot bypass housing")
    var elapsed: float = 0.0
    while dust.b_state[b] != Dust.GONE and elapsed < 25.0:
        tail = dust.tail_nodes(b)
        target = tail[tail.size()-1]
        dust.step(1.0/60.0,Dust.TOOL_VACUUM,target,Vector2.ZERO,true)
        elapsed += 1.0/60.0
    check(dust.b_state[b] == Dust.GONE and dust.take_swallowed() > 0.0,"precise suction eventually extracts a real pinned chain")
    check(elapsed > 3.0,"pinned tail needs a deliberate slow pull (%.2f s)"%elapsed)
    check(dust.tail_nodes(b).is_empty() and dust.removed_fraction(under) > 0.0,"extraction removes its indication and credits actual hidden mass")
    access.set_removed("gpu",true)
    dust.set_blockers(access.blockers())
    var still_there: int = dust.zone_bundles[under][0]
    check(dust.tail_nodes(still_there).is_empty() and dust.has_access(still_there,dust.b_center[still_there]),"removing GPU reveals normal dirt instead of keeping tail-only restriction")
