extends "res://tools/test_support.gd"
const Checks = preload("res://scripts/rules/software_checks.gd")
const Rig = preload("res://scripts/bench/tool_rig.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Paste = preload("res://scripts/bench/paste_sim.gd")
const Zones = preload("res://scripts/data/dust_zones.gd")
func _initialize() -> void:
    call_deferred("run_checks")
func run_checks() -> void:
    var bench_script: Script = load("res://scripts/view/bench_view.gd")
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs,"software_test.json")
    var manifest: String = gs.save_path+".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.owned_games = []
    gs.customer_state = {}
    gs.new_game(false)
    check(not gs.job["pc_powered"],"new customer PC is switched off")
    check(night.start(gs) and not night.tickets[1]["pc_powered"],"both demonstration repair PCs start off")
    var first: String = night.active_id
    var second: String = night.tickets[1]["id"]
    check(not Checks.boot(gs.job)["ok"],"off PC cannot boot")
    check(not Checks.game_test(gs.job,["counter_stroke_2"],"counter_stroke_2",42)["ok"],"off PC cannot produce game readings")
    var raw: Dictionary = gs.job.duplicate(true)
    raw.erase("pc_powered")
    check(not Checks.boot(raw)["ok"],"missing power flag means off")
    gs.job["paste_grade"] = "PERFECT"
    gs.job["paste_done"] = true
    for id: String in gs.job["dust"]: gs.job["dust"][id] = 1.0
    var cash: int = gs.money
    check(not gs.run_final_check()["passed"] and gs.money == cash and gs.job["state"] == "open", "legacy final check cannot pay a switched-off PC")
    var view: Node = load("res://scenes/software.tscn").instantiate()
    root.add_child(view)
    await process_frame
    check(view.boot_button.disabled and view.run_button.disabled and view.output.text.contains("off"),"desktop makes the initial power requirement clear")
    check(view.showing_work and view.work_tab.disabled and view.side_text.text.contains("WORK DONE") and view.side_text.text.contains("[??] Working PC"),"Work + match is the main tab and starts with nothing measured")
    view._show_tab(false)
    check(view.side_text.text.contains(str(gs.job["customer"])) and not view.side_text.text.contains("WORK DONE"),"client details are the second tab")
    view._show_tab(true)
    # Real GUI hit testing, not a direct method-only assertion.
    var at: Vector2 = view.power_button.get_global_rect().get_center()
    for down: bool in [true,false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = at
        root.push_input(event,true)
        await process_frame
    check(gs.job["pc_powered"] and not view.boot_button.disabled,"native case-button click powers the PC and enables tests")
    view._boot()
    check(view.output.text.contains("Boot OK"),"boot app reports startup success")
    view._game()
    check(not view.output.text.contains("simulated FPS"),"unowned game cannot fake a benchmark")
    var start_job: Dictionary = gs.job.duplicate(true)
    var trust: Dictionary = gs.customer_state.duplicate(true)
    view._hardware()
    check(view.output.text.contains("HARDWARE CHECK PASSED") and not view.output.text.contains("°C /") and gs.job["state"] == start_job["state"] and gs.money == cash and gs.customer_state == trust,"hardware check only says the parts are in place; it never pays, completes or changes trust")
    check(view.side_text.text.contains("[OK] Working PC"),"a passed hardware check shows in the match tab")
    view._buy()
    check(gs.owns_game("counter_stroke_2") and gs.money == cash-12,"Vapor buys one shop licence at its existing price")
    view._buy()
    check(gs.money == cash-12,"repeated purchase cannot charge twice")
    var night_before: int = gs.night_minutes
    view._game()
    check(view.busy_left > 0.0 and not view.output.text.contains("simulated FPS") and gs.night_minutes == night_before and view.run_button.disabled,"a game test takes time: no result and no other test while it runs")
    view._process(view.run_seconds + 0.1)
    check(view.output.text.contains("simulated FPS") and gs.night_minutes == night_before + 30 and view.busy_left == 0.0,"the finished game test reports and spends 30 night minutes")
    check(gs.job["tests"]["games"].has("counter_stroke_2") and view.side_text.text.contains("FPS measured"),"the measured frame rate is stored and shown against the request")
    view.run_seconds = 0.0
    var good: int = Checks.game_test(gs.job,gs.owned_games,"counter_stroke_2",42)["fps"]
    gs.job["service_replacements"]["gpu"] = "budget"
    check(Checks.game_test(gs.job,gs.owned_games,"counter_stroke_2",42)["fps"]<good,"budget GPU changes the reported game performance")
    gs.job["broken_parts"] = ["gpu"]
    view._game()
    check(view.output.text.contains("Boot FAILED") and not view.output.text.contains("simulated FPS"),"broken PC reports failure rather than a misleading benchmark")
    view._hardware()
    check(view.output.text.contains("HARDWARE CHECK PASSED") and not view.output.text.contains("BROKEN"),"a hidden fault is not revealed by the hardware check (D150): everything is fitted")
    gs.job["removed_parts"] = ["gpu"]
    view._hardware()
    check(view.output.text.contains("HARDWARE CHECK FAILED") and view.side_text.text.contains("[NO] Working PC"),"a part out of the PC fails the hardware check")
    gs.job["removed_parts"] = []
    gs.job["broken_parts"] = []
    var unchanged: Dictionary = gs.job.duplicate(true)
    view._scan()
    check(gs.job == unchanged and view.output.text.contains("no threats"),"a scan of a clean PC reports clean and changes nothing")
    view._power()
    check(not gs.job["pc_powered"] and view.output.text.contains("readings cleared"),"powering down clears the live report")
    check(night.switch_pc(gs,second) and not gs.job["pc_powered"],"other customer's PC retains its own off switch")
    gs.set_pc_powered(true)
    check(night.switch_pc(gs,first) and not gs.job["pc_powered"],"switching back preserves first PC off state")
    check(night.switch_pc(gs,second) and gs.job["pc_powered"],"second PC retains its on state")
    gs.save_game()
    check(gs.load_game() and gs.job["pc_powered"],"explicit powered-on save is respected")
    var old_money: int = gs.money
    check(not Checks.game_test(gs.job,gs.owned_games,"unknown",42)["ok"] and gs.money == old_money,"unknown game report is rejected without transaction")
    var data: Dictionary = load("res://scripts/state/save_store.gd").read(gs.save_path)
    data["job"].erase("pc_powered")
    load("res://scripts/state/save_store.gd").write(gs.save_path,data)
    check(gs.load_game() and not gs.job["pc_powered"],"old save lacking power migrates off")
    view.queue_free()
    await process_frame
    night.read_only = true
    var protected_view: Node = load("res://scenes/software.tscn").instantiate()
    root.add_child(protected_view)
    await process_frame
    check(protected_view.power_button.disabled and protected_view.boot_button.disabled and protected_view.output.text.contains("No writable"),"protected ticket manifest cannot be edited from the monitor")
    protected_view._power()
    check(not gs.job["pc_powered"],"direct protected power action cannot bypass read-only state")
    protected_view.queue_free()
    await process_frame
    night.read_only = false
    var rig := Rig.new()
    rig.park()
    var pose: RefCounted = rig.motions[Ids.CLOTH]
    pose.center = Vector2(350,300)
    pose.angle = 0.7
    var inside: Vector2 = pose.center+Rig.TIP.rotated(pose.angle)
    check(rig.hit(inside,[Ids.CLOTH]) == Ids.CLOTH,"cloth pickup follows its actual rotated fabric")
    check(rig.hit(pose.center+(Rig.TIP+Vector2(-23.8,-15.8)).rotated(pose.angle),[Ids.CLOTH]) == "","cloth pickup excludes the one-pixel inset edge")
    check(is_equal_approx(bench_script.WIPE_RADIUS_CELLS*bench_script.PASTE_CELL,35.0),"wiping reach shrinks one world pixel, not an entire grid cell")
    var paste := Paste.new()
    paste.deposit(30.5,30.5,5)
    var before: float = paste.h[30*Paste.GRID+30]
    paste.wipe(30.5+35.5/8,30.5,bench_script.WIPE_RADIUS_CELLS,1.0)
    check(paste.h[30*Paste.GRID+30] == before,"paste in the removed one-pixel fringe stays untouched")
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Software")
