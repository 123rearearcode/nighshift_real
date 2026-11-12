# Run: godot --headless --path . --script res://tools/playtest_bench.gd
# A SCRIPTED PLAYTEST, not a pass/fail suite: it opens the real repair bench, moves a scripted
# pointer the way a player would (brushing strokes, holding the vacuum) for every part and for
# several tool angles, and prints what happened. Used to diagnose reports such as "the brush
# only works at some angles". It never fails the build; read its table in the Actions log.
extends SceneTree

const Dust = preload("res://scripts/bench/dust_sim.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")

const STEP: float = 1.0 / 60.0
var view: Node2D


var waited: float = 0.0


func _initialize() -> void:
    call_deferred("run")


# Watchdog: if a script error stops run() part-way, quit anyway instead of hanging the build.
func _process(delta: float) -> bool:
    waited += delta
    if waited > 5.0:
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
    brush_table()
    vacuum_table()
    reach_table()
    click_table()
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
        for angle_steps in [0, 3, 6, 9, 12, 15, 18, 21]:
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
        for angle_steps in [0, 6, 12, 18]:
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
        for angle_steps in [0, 3, 6, 9, 12, 15, 18, 21]:
            for placed: Vector2 in [Vector2(-50, 0), Vector2(50, 0), Vector2(0, 60), Vector2(0, -60), Vector2(-40, 40)]:
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
