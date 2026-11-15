extends "res://tools/test_support.gd"
const Materials = preload("res://scripts/data/paste_materials.gd")
const Renderer = preload("res://scripts/view/paste_renderer.gd")
const Layout = preload("res://scripts/data/layout.gd")
const Bin = preload("res://scripts/bench/dust_bin.gd")
const Snapshot = preload("res://scripts/night/paste_snapshot.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Paste = preload("res://scripts/bench/paste_sim.gd")
func _initialize() -> void: call_deferred("run_checks")
func press(button: Button) -> void:
    var at: Vector2 = button.get_global_rect().get_center()
    for down: bool in [true,false]:
        var e := InputEventMouseButton.new()
        e.position = at
        e.global_position = at
        e.button_index = MOUSE_BUTTON_LEFT
        e.pressed = down
        root.push_input(e,true)
        await process_frame
func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs,"thermal_service_test.json")
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    var first: StyleBoxFlat = bench.stage_buttons[0].get_theme_stylebox("normal")
    var second: StyleBoxFlat = bench.stage_buttons[1].get_theme_stylebox("normal")
    check(first.bg_color != second.bg_color and first.border_color != second.border_color,"cleaning and thermal tabs use different persistent colors")
    await press(bench.stage_buttons[1])
    check(bench.stage == 1 and bench.stage_buttons[1].button_pressed and not bench.stage_buttons[0].button_pressed,"native tab click selects thermal and synchronizes highlight")
    check(not "wipe_button" in bench and not bench.get_children().any(func(n: Node) -> bool: return n is Button and (n.text.contains("switch to cloth") or n.text.contains("Wipe with cloth"))),"obsolete tool-toggle widget is removed rather than renamed")
    check(not bench.mount_button.visible,"mount action is absent on a bare CPU")
    var menu: PopupMenu = bench.material_button.get_popup()
    check(menu.item_count == 3,"material menu exposes exactly normal, super-paste and toothpaste")
    await press(bench.material_button)
    check(menu.visible,"native material click opens actual choice menu")
    menu.set_focused_item(1)
    var choose := InputEventKey.new()
    choose.keycode = KEY_ENTER
    choose.pressed = true
    root.push_input(choose,true)
    await process_frame
    check(bench.paste.material == "super" and bench.material_button.text.contains("Super-paste"),"super-paste can be selected")
    var normal: Color = Renderer.material_color("thermal",0.5)
    var premium: Color = Renderer.material_color("super",0.5)
    check(premium != normal and premium.b > premium.r and premium.b > premium.g,"super-paste has a distinct subtle blue/purple tint")
    bench.paste.deposit(25.5,25.5,80)
    bench._sync_paste_controls()
    check(bench.mount_button.visible and bench.mount_button.position.y > bench.PASTE_ORIGIN.y+Paste.GRID*bench.PASTE_CELL,"mount appears under the socket after depositing paste")
    bench._on_material_selected(2)
    check(bench.paste.material == "super","deposited material cannot be relabeled or mixed")
    await press(bench.mount_button)
    check(bench.mount.active and not bench.mount_button.visible,"native mount click starts pressing and hides the mount action")
    bench._cancel_unlocked_mount()
    bench._on_clear_pressed()
    check(not bench.mount_button.visible,"reset restores bare-CPU mount visibility")
    bench._on_material_selected(2)
    check(bench.paste.material == "toothpaste","toothpaste remains available after wiping")
    bench._on_material_selected(0)
    check(bench.paste.material == "thermal","normal paste remains selectable")
    # Same grade and hardware: premium benefit must reach both actual temperature paths.
    for id: String in gs.job["dust"]: gs.job["dust"][id] = 1.0
    gs.job["paste_grade"] = "PERFECT"
    gs.job["paste_done"] = true
    gs.set_pc_powered(true)
    var base: float = Diagnostics.evaluate(gs.job,[])["temp"]
    gs.job["paste_done"] = false
    var money: int = gs.money
    gs.money = 5
    check(not gs.complete_repaste("super")["ok"] and gs.money == 5 and not gs.job["paste_done"],"unaffordable premium paste cannot charge or complete")
    gs.money = money
    check(gs.complete_repaste("super")["ok"] and gs.money == money-int(Materials.material("super")["cost"]),"super-paste completion charges its canonical price once")
    check(not gs.complete_repaste("super")["ok"] and gs.money == money-6,"repeat completion cannot double charge")
    var lower: float = Diagnostics.evaluate(gs.job,[])["temp"]
    check(lower < base and is_equal_approx(lower,base-4),"super-paste lowers night diagnostic temperature for equal contact")
    var final: Dictionary = gs.run_final_check()
    check(is_equal_approx(final["temp"],lower) and not str(final["notes"]).contains("dries out"),"legacy final check honors the same cooling benefit without scam warning")
    check(gs.job["scams"].is_empty() and gs.load_game() and gs.job["paste_material"] == "super","premium material saves as honest work")
    var p := Paste.new()
    p.material = "super"
    p.deposit(25,25,10)
    var restored := Paste.new()
    check(Snapshot.restore(restored,JSON.parse_string(JSON.stringify(Snapshot.capture(p)))) and restored.material == "super","physical premium field survives PC snapshot roundtrip")
    bench._on_clear_pressed()
    bench._select_stage(1)
    bench.paste.deposit(25,25,10)
    bench.mount_result = {"grade":"GOOD ENOUGH"}
    bench._sync_paste_controls()
    check(not bench.mount_button.visible,"already graded cooler never shows a new Mount button")
    bench._select_stage(0)
    bench.bin.fill = 30
    var fill: float = bench.bin.fill
    check(Layout.BENCH_BIN.encloses(bench.retract_button.get_global_rect()),"retract control is physically on the bin")
    await press(bench.retract_button)
    check(bench.tools.spool_retracting and bench.bin.fill == fill,"native bin retract click reels hose without emptying dust")
    for i in range(300): bench._physics_process(1.0/60.0)
    check(not bench.tools.spool_retracting and bench.tools.hose.length() == bench.tools.MIN_DEPLOYED,"bin button actually shortens deployed hose")
    click(bench,MOUSE_BUTTON_LEFT,true,Vector2(540,566))
    click(bench,MOUSE_BUTTON_LEFT,false,Vector2(540,566))
    check(not bench.tools.spool_retracting,"old standalone spool location cannot trigger retraction")
    bench.queue_free()
    await process_frame
    restore_save(gs)
    finish("Thermal service")
