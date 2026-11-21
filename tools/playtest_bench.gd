# Run: godot --headless --path . --script res://tools/playtest_bench.gd
# A SCRIPTED PLAYTEST, not a pass/fail suite: it opens the real repair bench, moves a scripted
# pointer the way a player would (brushing strokes, holding the vacuum) for every part and for
# several tool angles, and prints what happened. Used to diagnose reports such as "the brush
# only works at some angles". It never fails the build; read its table in the Actions log.
extends SceneTree

const Dust = preload("res://scripts/bench/dust_sim.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const Ids = preload("res://scripts/data/ids.gd")

const STEP: float = 1.0 / 60.0
var view: Node2D
var smoke: bool = false
var tuning: bool = false


var waited: float = 0.0
var last_progress: float = 0.0   # the frame-time table waits for real frames; it marks progress here


func _initialize() -> void:
    smoke = "--smoke" in OS.get_cmdline_user_args()
    tuning = "--tuning" in OS.get_cmdline_user_args()
    call_deferred("run")


# Watchdog: if a script error stops run() part-way, quit anyway instead of hanging the build.
func _process(delta: float) -> bool:
    waited += delta
    if waited - last_progress > 5.0:
        print("Playtest stopped early (a script error above ended it)")
        return true
    return false


func run() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://playtest_only.json"
    gs.new_game()
    # Loaded here, not preloaded: the bench script uses the GameState autoload, which exists only once the tree runs.
    view = (load("res://scenes/bench.tscn") as PackedScene).instantiate()
    root.add_child(view)
    print("PLAYTEST zones (screen rects):")
    for i in range(view.zones.size()):
        print("  %-13s %s" % [view.zones[i]["id"], str(view._zone_rect(i))])
    print("PLAYTEST bin hose anchor %s, hose length %.0f" % [str(DustBin.hose_anchor()), view.tools.hose.length()])
    print("Diagnostic mode: %s" % ("smoke" if smoke else "full"))
    brush_table()
    vacuum_table()
    reach_table()
    click_table()
    paste_table()
    state_table()
    if not smoke: await frame_time_table()
    if tuning: tuning_table()
    view.queue_free()
    gs.save_path = original_path
    print("Playtest finished")
    quit(0)


func reset_bench(tool_id: int, angle_steps: int) -> void:
    view.holding = false
    view._on_reset_dust()
    view.scripted_pointer = view._zone_rect(0).get_center()
    view._select_tool(tool_id)
    var id: String = view.tools.selected
    view.tools.turns[id] = wrapf(float(angle_steps) * ToolRig.TURN_STEP, -PI, PI)
    for frame in range(30):
        view._physics_process(STEP)


func zone_index(id: String) -> int:
    for i in range(view.zones.size()):
        if view.zones[i]["id"] == id: return i
    return -1


# Brushing: zig-zag strokes across the middle of a part for two seconds.
func brush_table() -> void:
    print("PLAYTEST BRUSH  zone          angle  stroke  tossed/bundles  shed  mean_grip_left  reachable")
    for id: String in ["case_fan", "cooler", "motherboard", "gpu", "psu", "front_filter"]:
        var zi: int = zone_index(id)
        for angle_steps in ([0,6] if smoke else [0,3,6,9,12,15,18,21]):
            for stroke: Vector2 in [Vector2(1, 0), Vector2(0, 1)]:
                reset_bench(Dust.TOOL_BRUSH, angle_steps)
                var dust: RefCounted = view.dust
                var bundles: Array = dust.zone_bundles[zi]
                var center: Vector2 = view._zone_rect(zi).get_center()
                var reachable: int = 0
                for b: int in bundles:
                    if dust.has_access(b, center): reachable += 1
                var start_count: int = dust.count
                var tossed: Dictionary = {}
                view.scripted_pointer = center
                for frame in range(10): view._physics_process(STEP)
                view.holding = true
                for frame in range(120):
                    var t: float = float(frame) * STEP
                    view.scripted_pointer = center + stroke * 25.0 * sin(TAU * 2.5 * t)
                    view._physics_process(STEP)
                    for b: int in bundles:
                        if dust.b_state[b] == Dust.TOSSED: tossed[b] = true
                view.holding = false
                var grip: float = 0.0
                for b: int in bundles: grip += dust.b_loosen[b]
                print("PLAYTEST BRUSH  %-13s %5d  %-6s  %3d/%-3d         %3d   %.2f            %d/%d" % [id, angle_steps * 15,
                    "across" if stroke.x > 0.0 else "down", tossed.size(), bundles.size(), dust.count - start_count,
                    grip / maxf(1.0, float(bundles.size())), reachable, bundles.size()])


# Vacuum: hold the nozzle on the middle of a part for three seconds, circling slightly.
func vacuum_table() -> void:
    print("PLAYTEST VACUUM zone          angle  removed  mean_nozzle_offset  max_offset  bin")
    for id: String in ["case_fan", "cooler", "motherboard", "gpu", "psu", "front_filter"]:
        var zi: int = zone_index(id)
        for angle_steps in ([0] if smoke else [0,6,12,18]):
            reset_bench(Dust.TOOL_VACUUM, angle_steps)
            view.bin.empty()
            var center: Vector2 = view._zone_rect(zi).get_center()
            view.scripted_pointer = center
            for frame in range(30): view._physics_process(STEP)
            view.holding = true
            var offset_sum: float = 0.0
            var offset_max: float = 0.0
            for frame in range(180):
                var t: float = float(frame) * STEP
                view.scripted_pointer = center + Vector2(cos(TAU * t), sin(TAU * t)) * 12.0
                view._physics_process(STEP)
                var off: float = view.tools.contact().distance_to(view.scripted_pointer)
                offset_sum += off
                offset_max = maxf(offset_max, off)
            view.holding = false
            print("PLAYTEST VACUUM %-13s %5d  %5.0f%%   %6.1f px           %6.1f px   %.0f" % [id, angle_steps * 15,
                view.dust.removed_fraction(zi) * 100.0, offset_sum / 180.0, offset_max, view.bin.fill])


# How far the hose lets the nozzle go: park the cursor at points across the bench.
func reach_table() -> void:
    print("PLAYTEST REACH  cursor           nozzle_offset  hose_anchor_to_end")
    for p: Vector2 in [Vector2(60, 130), Vector2(350, 130), Vector2(640, 130), Vector2(60, 320), Vector2(350, 320), Vector2(60, 500)]:
        reset_bench(Dust.TOOL_VACUUM, 0)
        view.scripted_pointer = p
        for frame in range(240): view._physics_process(STEP)
        print("PLAYTEST REACH  %-16s %6.1f px      %6.1f px" % [str(p), view.tools.contact().distance_to(p),
            view.tools.hose_end().distance_to(DustBin.hose_anchor())])


# Clicking: a held tool next to resting tools that it shoved. Does a real left click use the held
# tool, or does it grab the tool lying next to it instead? (Uses real mouse events through _input.)
func click_table() -> void:
    print("PLAYTEST CLICK  held     angle  placed  after_click_holding  now_in_hand")
    for held: int in [Dust.TOOL_VACUUM, Dust.TOOL_BRUSH]:
        for angle_steps in ([0,6] if smoke else [0,3,6,9,12,15,18,21]):
            for placed: Vector2 in ([Vector2(-50,0)] if smoke else [Vector2(-50,0),Vector2(50,0),Vector2(0,60),Vector2(0,-60),Vector2(-40,40)]):
                reset_bench(held, angle_steps)
                var pointer := Vector2(300, 260)
                view.scripted_pointer = pointer
                for frame in range(40): view._physics_process(STEP)
                var held_id: String = view.tools.selected
                for id: String in ["vacuum", "brush", "pick"]:
                    if id == held_id: continue
                    view.tools.bodies[id].active = false
                    view.tools.motions[id].center = view.tools.motions[held_id].center + placed
                    placed = placed.rotated(PI * 0.5)
                for frame in range(40): view._physics_process(STEP)
                var press := InputEventMouseButton.new()
                press.button_index = MOUSE_BUTTON_LEFT
                press.pressed = true
                press.position = pointer
                view._input(press)
                view._physics_process(STEP)
                print("PLAYTEST CLICK  %-7s  %5d  %-14s  %-19s  %s" % [held_id, angle_steps * 15, str(placed), str(view.holding), view.tools.selected])
                var release := InputEventMouseButton.new()
                release.button_index = MOUSE_BUTTON_LEFT
                release.pressed = false
                release.position = pointer
                view._input(release)


# Thermal paste: squeeze a pattern, mount, press for a while, then let the cooler be secured.
func paste_table() -> void:
    print("PLAYTEST PASTE  pattern  squeeze_s  gauge                     press_s  grade        coverage  overflow  syringe_offset")
    view.scripted_pointer = Vector2(320, 350)
    view._select_stage(view.STAGE_PASTE)
    var cpu_center: Vector2 = view.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(view.PASTE_CELL)
    for pattern: String in (["dot"] if smoke else ["dot","x","line","five"]):
        for squeeze in ([2.0] if smoke else [1.5,2.0,2.5,3.5]):
            for press in ([2.5] if smoke else [1.0,2.5,4.0,6.0,10.0]):
                view._on_clear_pressed()
                view.wiping = false
                view.tools.select("syringe", cpu_center)
                var points: Array = [cpu_center]
                if pattern == "x":
                    points = []
                    for k in range(11):
                        var f: float = (float(k) / 10.0 - 0.5) * 2.0
                        points.append(cpu_center + Vector2(f, f) * 110.0)
                    for k in range(11):
                        var f2: float = (float(k) / 10.0 - 0.5) * 2.0
                        points.append(cpu_center + Vector2(f2, -f2) * 110.0)
                elif pattern == "line":
                    points = []
                    for k in range(11): points.append(cpu_center + Vector2((float(k) / 10.0 - 0.5) * 220.0, 0))
                elif pattern == "five":
                    points = [cpu_center, cpu_center + Vector2(-80,-80), cpu_center + Vector2(80,-80), cpu_center + Vector2(-80,80), cpu_center + Vector2(80,80)]
                var frames: int = int(squeeze * 60.0)
                var offset: float = 0.0
                view.scripted_pointer = points[0]
                for frame in range(20): view._physics_process(STEP)
                view.holding = true
                for frame in range(frames):
                    view.scripted_pointer = points[mini(points.size() - 1, frame * points.size() / maxi(1, frames))]
                    view._physics_process(STEP)
                    offset = maxf(offset, view.tools.contact().distance_to(view.scripted_pointer))
                view.holding = false
                var gauge: String = view.paste.gauge_text()
                view._on_mount_pressed()
                view.scripted_pressing = true
                var pressed_frames: int = int(press * 60.0)
                var guard: int = 0
                while view.mount.active and guard < 900:
                    view.scripted_pressing = guard < pressed_frames
                    view._physics_process(STEP)
                    guard += 1
                    if guard == pressed_frames + 30 and view.mount.active: view._finish_mount()
                view.scripted_pressing = null
                var r: Dictionary = view.mount_result
                print("PLAYTEST PASTE  %-7s  %4.1f       %-24s  %4.1f     %-11s  %5.0f%%    %5.0f%%    %.1f" % [pattern, squeeze, gauge, press,
                    str(r.get("grade", "-")), float(r.get("coverage", 0.0)) * 100.0, float(r.get("overflow", 0.0)) * 100.0, offset])


# Frame times (docs/WORK_PLAN.md Phase 1 step 2). For each scene: the time of one physics tick (the
# bench's _physics_process, timed here) and of one redraw (the bench's _draw, timed inside it), over
# real engine frames. Headless: the drawing code runs (that is what we measure: our script's cost of
# building the picture), but nothing reaches a graphics card, so GPU time is NOT included. Numbers are
# from GitHub's machine; compare scenes with each other, not with your PC.
const PERF_FRAMES: int = 180


func frame_time_table() -> void:
    print("PLAYTEST FRAMES scene                  physics_avg_us  physics_worst_us  draw_avg_us  draw_worst_us  frames_drawn  dust_bundles  state")
    view.set_physics_process(false)   # the table steps physics itself, once per frame, so it can time it
    for scene: String in ["idle bench", "brushing", "vacuum + moving hose", "paste flowing", "idle paste stage"]:
        await prepare_scene(scene)
        var physics_total: int = 0
        var physics_worst: int = 0
        var draw_total: int = 0
        var draw_worst: int = 0
        var drawn: int = 0
        for frame in range(PERF_FRAMES):
            drive_scene(scene, frame)
            var started: int = Time.get_ticks_usec()
            view._physics_process(STEP)
            var took: int = Time.get_ticks_usec() - started
            physics_total += took
            physics_worst = maxi(physics_worst, took)
            view.last_draw_usec = -1
            view.queue_redraw()
            await process_frame
            last_progress = waited
            if view.last_draw_usec >= 0:
                drawn += 1
                draw_total += view.last_draw_usec
                draw_worst = maxi(draw_worst, view.last_draw_usec)
        print("PLAYTEST FRAMES %-22s %10d      %10d        %9d    %9d      %5d         %-12d  %s" % [scene, physics_total / PERF_FRAMES,
            physics_worst, draw_total / maxi(1, drawn), draw_worst, drawn, view.dust.count, scene_state(scene)])
    view.holding = false
    view.scripted_pressing = null
    view.set_physics_process(true)


func prepare_scene(scene: String) -> void:
    view.holding = false
    view.scripted_pressing = null
    # Each scene starts from a clean slate: a mount left over from "paste flowing" (10 s long, measured
    # for only 3 s) would otherwise keep the paste simulation running in the next, supposedly idle, scene.
    if view.mount.active:
        view._finish_mount()
    if scene.contains("paste"):
        view._select_stage(view.STAGE_PASTE)
        view._on_clear_pressed()
        var cpu_center: Vector2 = view.PASTE_ORIGIN + Vector2(25.5, 25.5) * float(view.PASTE_CELL)
        view.tools.select("syringe", cpu_center)
        view.scripted_pointer = cpu_center
        if scene == "paste flowing":
            view.holding = true
            for frame in range(120): view._physics_process(STEP)
            view.holding = false
            view._on_mount_pressed()
            view.scripted_pressing = true
    else:
        view._select_stage(view.STAGE_CLEAN)
        reset_bench(Dust.TOOL_BRUSH if scene == "brushing" else Dust.TOOL_VACUUM, 0)
        view.scripted_pointer = view._zone_rect(zone_index("motherboard")).get_center()
        if scene != "idle bench":
            view.holding = true
    await process_frame
    last_progress = waited


# Is the bench in the state the scene claims, at the END of its measured frames? Printed in the table
# so a contaminated measurement is visible (Codex's cross-review of 0.19.3 found one).
func scene_state(scene: String) -> String:
    var ok: bool
    if scene.begins_with("idle"):
        ok = not view.mount.active and not view.holding
    elif scene == "paste flowing":
        ok = view.mount.active
    else:
        ok = view.holding and not view.mount.active
    return ("ok" if ok else "WRONG") + (" (mounting)" if view.mount.active else "") + (" (holding)" if view.holding else "")


func drive_scene(scene: String, frame: int) -> void:
    var t: float = float(frame) * STEP
    var center: Vector2 = view._zone_rect(zone_index("motherboard")).get_center() if not scene.contains("paste") else view.scripted_pointer
    if scene == "brushing":
        view.scripted_pointer = center + Vector2(25.0 * sin(TAU * 2.5 * t), 0.0)
    elif scene == "vacuum + moving hose":
        view.scripted_pointer = center + Vector2(160.0 * sin(TAU * 0.5 * t), 70.0 * cos(TAU * 0.7 * t))


# Hand states (docs/HAND_STATES.md, step 5): walk one action sequence and print the derived state
# after each act. Expected values are printed beside it so a drift is visible in the log.
func state_table() -> void:
    print("PLAYTEST STATE  act                       state            expected")
    view._select_stage(view.STAGE_CLEAN)
    view.holding = false
    var cursor: Vector2 = view._zone_rect(zone_index("motherboard")).get_center()
    view.scripted_pointer = cursor
    view._select_tool(Dust.TOOL_VACUUM)
    for frame in range(10): view._physics_process(STEP)
    state_row("take the vacuum", "USING_TOOL")
    view.tools.park()
    state_row("park it", "FREE")
    view.tools.select(Ids.VACUUM, cursor)
    state_row("pick it up again", "USING_TOOL")
    view.tools.begin_throw(cursor)
    state_row("right-press (wind up)", "THROWING")
    view.tools.release_throw(Vector2(300, 0))
    state_row("release (it flies)", "FREE")
    for frame in range(120): view._physics_process(STEP)
    var grabbed: bool = view.tools.grab_hose(view.tools.hose.pos[8])
    state_row("grab the hose" + ("" if grabbed else " (MISSED)"), "CARRYING_HOSE")
    view.tools.release_hose()
    state_row("let go of the hose", "FREE")
    var clamped: bool = view.tools.begin_clamp_drag(view.tools.clamp_rect().get_center())
    state_row("take the clamp" + ("" if clamped else " (MISSED)"), "DRAGGING_CLAMP")
    view.tools.end_clamp_drag()
    state_row("park the clamp", "FREE")
    var part: bool = view.access.begin(view.access.current_rect(Ids.COOLER).get_center())
    state_row("lift the cooler" + ("" if part else " (MISSED)"), "DRAGGING_PART")
    view.access.finish(view.access.drag_rect.get_center())
    state_row("set the cooler down", "FREE")
    var coin: int = view.items.spawn("coin", view.scripted_pointer)
    view.items.pick(view.scripted_pointer)
    state_row("pick up a loose coin", "CARRYING_ITEM")
    view.items.drop(view.scripted_pointer + Vector2(30, 0), ToolRig.TABLE)
    state_row("drop the coin", "FREE")
    coin = view.items.hit(view.scripted_pointer + Vector2(30, 0))
    if coin >= 0:
        view.items.kinds.remove_at(coin)
        view.items.centers.remove_at(coin)
        view.items.angles.remove_at(coin)
    view._open_replacements()
    state_row("open the stock panel", "PANEL_OPEN")
    view.replacement_panel.hide()
    state_row("close the stock panel", "FREE")
    view._select_stage(view.STAGE_PASTE)
    view._on_clear_pressed()
    view.tools.select(Ids.SYRINGE, view.PASTE_ORIGIN + Vector2(200, 200))
    view.scripted_pointer = view.PASTE_ORIGIN + Vector2(204, 204)
    view.holding = true
    for frame in range(100): view._physics_process(STEP)
    view.holding = false
    view._on_mount_pressed()
    state_row("mount the cooler", "MOUNTING")
    view._finish_mount()
    state_row("pull the lever", "FREE")
    view._select_stage(view.STAGE_CLEAN)


func state_row(act: String, expected: String) -> void:
    var got: String = view.hand_state()
    print("PLAYTEST STATE  %-25s %-16s %s%s" % [act, got, expected, "" if got == expected else "   <-- MISMATCH"])


# Optional tuning observation; no historical balance threshold gates a code change.
func tuning_table() -> void:
    var dust := Dust.new()
    dust.setup(view.zones,Vector2.ZERO,12345)
    var duration: float = 0.0
    while dust.remaining_fraction() > 0.0 and duration < 90.0:
        var target: int = -1
        for b in range(dust.count):
            if dust.b_state[b] != Dust.GONE:
                target = b
                break
        if target < 0: break
        var nodes: PackedVector2Array = dust.shown[target]
        dust.step(STEP,Dust.TOOL_VACUUM,nodes[nodes.size()/2],Vector2.ZERO,true)
        duration += STEP
    print("TUNING vacuum_clear_seconds=%.2f remaining=%.4f (simulation only; no human travel, blockers or bin)" % [duration,dust.remaining_fraction()])
