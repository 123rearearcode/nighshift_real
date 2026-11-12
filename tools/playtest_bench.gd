# Run: godot --headless --path . --script res://tools/playtest_bench.gd
# A SCRIPTED PLAYTEST, not a pass/fail suite: it opens the real repair bench, moves a scripted
# pointer the way a player would (brushing strokes, holding the vacuum) for every part and for
# several tool angles, and prints what happened. Used to diagnose reports such as "the brush
# only works at some angles". It never fails the build; read its table in the Actions log.
extends SceneTree

const BenchScene = preload("res://scenes/bench.tscn")
const Dust = preload("res://scripts/bench/dust_sim.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")

const STEP: float = 1.0 / 60.0
var view: Node2D


func _initialize() -> void:
    call_deferred("run")


func run() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://playtest_only.json"
    gs.new_game()
    view = BenchScene.instantiate()
    root.add_child(view)
    print("PLAYTEST zones (screen rects):")
    for i in range(view.zones.size()):
        print("  %-13s %s" % [view.zones[i]["id"], str(view._zone_rect(i))])
    print("PLAYTEST bin hose anchor %s, hose length %.0f" % [str(DustBin.hose_anchor()), view.tools.hose.length()])
    brush_table()
    vacuum_table()
    reach_table()
    view.queue_free()
    gs.save_path = original_path
    print("Playtest finished")
    quit(0)


func reset_bench(tool: int, angle_steps: int) -> void:
    view.holding = false
    view._on_reset_dust()
    view.scripted_pointer = view._zone_rect(0).get_center()
    view._select_tool(tool)
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
