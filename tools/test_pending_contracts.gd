# Known defects, not passing coverage. Non-blocking CI report until the owning agent fixes them.
# Promote these cases to the normal interaction suite when fixed; do not weaken their expectations.
extends "res://tools/test_support.gd"

func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs,"pending_contracts_test_only.json")
    for stage: int in [1,0]:
        gs.new_game(false)
        var bench: Node = load("res://scenes/bench.tscn").instantiate()
        root.add_child(bench)
        bench.set_physics_process(false)
        bench._select_stage(1)
        bench.paste.deposit(25,25,120.0)
        bench._on_mount_pressed()
        check(bench.mount.active, "fixture starts a real mount")
        bench._select_stage(stage)
        check(bench.mount_result.is_empty() and str(gs.job["paste_grade"]) == "",
            "KNOWN DEFECT D57: stage %d cannot secure/grade a mount without the lever" % stage)
        bench.free()
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_tool(0)
    bench.tools.park()
    for frame in range(30): bench.tools.step(1.0/60.0,Vector2(300,300),false)
    check(bench.tools.grab_hose(bench.tools.hose.pos[8]), "fixture holds hose before testing refused selection")
    var key := InputEventKey.new()
    key.keycode = KEY_2
    key.pressed = true
    bench._input(key)
    var selection_matches: bool = true
    for index in range(bench.tool_buttons.size()):
        selection_matches = selection_matches and (bench.tool_buttons[index].button_pressed == (index == bench.active_tool))
    check(selection_matches,
        "KNOWN DEFECT: refused brush selection keeps actual tool highlighted")
    bench.free()
    restore_save(gs)
    gs.new_game(false)
    finish("Pending contracts")
