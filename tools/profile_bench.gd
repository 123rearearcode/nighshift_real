# Quick CPU profile, not a timing gate. Run with --headless --script res://tools/profile_bench.gd.
# Fixed 60 Hz simulation ticks, nearest-rank percentiles; GPU/display latency is not measured.
extends "res://tools/test_support.gd"
const STEP: float = 1.0/60.0
var bench: Node

func _initialize() -> void: call_deferred("run")

func report(label: String, values: Array) -> void:
    values.sort()
    var total: float = 0
    for value in values: total += value
    print("PROFILE %s n=%d avg_us=%.1f p50_us=%d p95_us=%d p99_us=%d max_us=%d" % [label,values.size(),total/values.size(),values[ceili(values.size()*0.50)-1],values[ceili(values.size()*0.95)-1],values[ceili(values.size()*0.99)-1],values[-1]])

func run() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs,"quick_profile_only.json")
    for scenario: String in ["clean_idle_free","clean_idle_clamped","brush","vacuum_moving","paste_idle_clamped","paste_flow"]:
        gs.new_game(false)
        bench = load("res://scenes/bench.tscn").instantiate()
        root.add_child(bench)
        bench.set_process(false)
        bench.set_physics_process(false)
        bench.scripted_pointer = Vector2(300,300)
        bench._select_stage(1 if scenario.begins_with("paste") else 0)
        bench.tools.park()
        if "clamped" in scenario:
            bench.tools.hose_grab = 8
            bench.tools.release_hose(bench.tools.clamp_position)
        if scenario in ["brush","vacuum_moving"]:
            bench._select_tool(1 if scenario == "brush" else 0)
            bench.holding = true
        if scenario == "paste_flow":
            bench.paste.deposit(25,25,130)
            bench.mount.start()
        var samples: Array = []
        for frame in range(300):
            if scenario in ["brush","vacuum_moving"]: bench.scripted_pointer = Vector2(250+sin(frame*0.15)*80,300)
            if scenario == "paste_flow": bench.scripted_pressing = true
            var started: int = Time.get_ticks_usec()
            bench._physics_process(STEP)
            if frame >= 60: samples.append(Time.get_ticks_usec()-started)
        report(scenario+"/physics",samples)
        var draws: Array = []
        for frame in range(32):
            bench.queue_redraw()
            await process_frame
            if frame > 1: draws.append(bench.last_draw_usec)
        report(scenario+"/draw_cpu",draws)
        if "clamped" in scenario: print("PROFILE clamp_engaged=",bench.tools.hose_clamp >= 0)
        # End-to-end real autosave, including physical snapshot, JSON, readback and backup rotation.
        if scenario == "clean_idle_free":
            var saves: Array = []
            for sample in range(30):
                var started: int = Time.get_ticks_usec()
                bench._save_dust()
                saves.append(Time.get_ticks_usec()-started)
            report("save/full_dirty_pc",saves)
        bench.free()
    restore_save(gs)
    print("Profile finished (headless CPU only; not an FPS benchmark)")
    quit()
