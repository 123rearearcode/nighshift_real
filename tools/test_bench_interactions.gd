# Regression for the user's put-down/pick-up recording and parts-mode click priority.
# Uses real bench input handlers and a dedicated disposable save.
extends "res://tools/test_support.gd"
const Dust = preload("res://scripts/bench/dust_sim.gd")
const Rig = preload("res://scripts/bench/tool_rig.gd")
const Access = preload("res://scripts/bench/service_access.gd")

func _initialize() -> void: call_deferred("run_checks")


func bench_for(gs: Node) -> Node:
    gs.new_game()
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    return bench

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original: String = gs.save_path
    gs.save_path = "user://bench_interaction_test_only.json"
    for id: int in [0,1]:
        var bench: Node = bench_for(gs)
        var at: Vector2 = bench.dust.b_center[0]
        bench.scripted_pointer = at
        bench._select_tool(id)
        # Put it down through the same right-button path as play, not a direct flag edit.
        click(bench,MOUSE_BUTTON_RIGHT,true,at)
        click(bench,MOUSE_BUTTON_RIGHT,false,at)
        for frame in range(240): bench._physics_process(1.0/60.0)
        check(not bench.tools.equipped, "tool is resting after put-down")
        var before: float = bench.dust.remaining_fraction()
        var loosen: float = bench.dust.b_loosen[0]
        var tool_id: String = "vacuum" if id == 0 else "brush"
        var pick_at: Vector2 = bench.tools.motions[tool_id].center + Rig.TIP.rotated(bench.tools.motions[tool_id].angle)
        bench.scripted_pointer = pick_at
        click(bench,MOUSE_BUTTON_LEFT,true,pick_at)
        check(bench.tools.equipped and bench.tools.selected == tool_id and bench.holding, tool_id + " pickup starts the same held-left stroke")
        var responded: bool = false
        for frame in range(180):
            bench.scripted_pointer = at + Vector2(sin(float(frame)*0.18)*10.0 if id == 1 else 0.0,0)
            bench._physics_process(1.0/60.0)
            responded = responded or bench.dust.b_loosen[0] < loosen-0.02 or bench.dust.b_state[0] == Dust.TOSSED
        if id == 0:
            check(bench.dust.remaining_fraction() < before, "picked-up vacuum works without another click or reset")
        else:
            check(responded, "picked-up brush loosens dust without another click or reset")
        click(bench,MOUSE_BUTTON_LEFT,false,bench.scripted_pointer)
        check(not bench.holding, "left release stops tool use")
        bench.free()
    for part: String in ["gpu","cooler"]:
        var bench: Node = bench_for(gs)
        var home: Vector2 = bench.access.homes[part].get_center()
        bench.scripted_pointer = home
        bench._select_tool(0)
        bench._select_tool(2) # puts the vacuum down directly over the selected part
        click(bench,MOUSE_BUTTON_LEFT,true,home)
        for frame in range(int(bench.PART_LIFT_SECONDS * 60.0) + 8): bench._physics_process(1.0/60.0)   # D89: unscrewing takes time
        check(bench.active_tool == 2 and bench.access.dragging == part, "Move parts selects " + part + " even with a resting vacuum on top")
        bench.scripted_pointer = Access.TRAY.get_center()
        for frame in range(45): bench._physics_process(1.0/60.0)
        click(bench,MOUSE_BUTTON_LEFT,false,bench.scripted_pointer)
        check(part in bench.access.removed_ids() and part in gs.job["removed_parts"], part + " can be removed to service tray")
        var under: int = 7 if part == "gpu" else 6
        check(not bench.dust.hidden_zones.has(under), part + " removal exposes underlying dust")
        bench.scripted_pointer = bench.dust.b_center[bench.dust.zone_bundles[under][0]]
        bench._select_tool(0)
        click(bench,MOUSE_BUTTON_LEFT,true,bench.scripted_pointer)
        for frame in range(180): bench._physics_process(1.0/60.0)
        check(bench.dust.removed_fraction(under) > 0.0, "exposed dust under " + part + " can actually be vacuumed")
        click(bench,MOUSE_BUTTON_LEFT,false,bench.scripted_pointer)
        bench._select_tool(2)
        for frame in range(90): bench._physics_process(1.0/60.0)
        var loose: Vector2 = bench._part_rects()[part].get_center()
        bench.scripted_pointer = loose
        click(bench,MOUSE_BUTTON_LEFT,true,loose)
        check(bench.access.dragging == part, part + " can be picked up again from tray")
        bench.scripted_pointer = home
        for frame in range(45): bench._physics_process(1.0/60.0)
        click(bench,MOUSE_BUTTON_LEFT,false,home)
        check(not part in bench.access.removed_ids() and bench.dust.hidden_zones.has(under), part + " refits and restores access blocking")
        bench.free()
    for id: String in ["cloth","syringe"]:
        var bench: Node = bench_for(gs)
        bench._select_stage(1)
        # Start outside the CPU surface, like picking a tool out of the rack.
        var at := Vector2(610,450)
        bench.tools.select(id,at)
        bench.tools.park()
        bench.scripted_pointer = at
        click(bench,MOUSE_BUTTON_LEFT,true,at)
        check(bench.tools.selected == id and bench.tools.equipped and bench.holding, id + " rack pickup preserves held-left stroke")
        bench.scripted_pointer = bench.PASTE_ORIGIN+Vector2(25,25)*bench.PASTE_CELL
        for frame in range(30): bench._physics_process(1.0/60.0)
        if id == "syringe":
            check(bench.paste.total_deposited > 0.0, "syringe works on entering CPU without release/reclick")
        else:
            check(bench.wiping and bench.tools.active, "cloth is active on entering CPU without release/reclick")
        click(bench,MOUSE_BUTTON_LEFT,false,bench.scripted_pointer)
        check(not bench.holding, id + " release stops work")
        bench.free()
    for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(gs.save_path+suffix)
    gs.save_path = original
    gs.new_game(false)
    finish("Bench interaction")
