# New game's actual title -> first-day counter -> acceptance -> night journey, including cold reload.
extends "res://tools/test_support.gd"
const Nav = preload("res://scripts/night/night_navigation.gd")
const Memory = preload("res://scripts/night/navigation_state.gd")
const Store = preload("res://scripts/state/save_store.gd")

func _initialize() -> void:
    call_deferred("run_checks")

func scene(path: String) -> void:
    change_scene_to_file(path)
    for f in range(3): await process_frame

func press(button: Button) -> void:
    var at: Vector2 = button.get_global_rect().get_center()
    for down: bool in [true, false]:
        var e := InputEventMouseButton.new()
        e.button_index = MOUSE_BUTTON_LEFT
        e.pressed = down
        e.position = at
        e.global_position = at
        root.push_input(e, true)
        await process_frame
    for f in range(3): await process_frame

func cold_continue(gs: Node, night: Node) -> void:
    night.bound_path = ""
    night.run_id = ""
    night.tickets = []
    gs.opening_customers = []
    await scene("res://scenes/start.tscn")
    await press(current_scene.load_button)

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "first_customer_test.json")
    var manifest: String = gs.save_path + ".night.json"
    var prefs: String = gs.save_path + ".navigation.json"
    for p: String in [manifest, prefs]: _remove_save_files(p)
    gs.tickets_taken = 0
    gs.new_game(false)
    await scene("res://scenes/start.tscn")
    var new_button: Button
    for child: Node in current_scene.get_children():
        if child is Button and child.text == "New game": new_button = child
    check(new_button != null, "title offers New game")
    await press(new_button)
    var counter: Node = current_scene
    check(counter.scene_file_path == Nav.COUNTER and counter.visiting() and counter.opening_visits, "native New game begins with a customer, not an empty night counter")
    check(counter.slip_title.text.contains("DAY 1") and counter.slip_text.text.contains("Mara V.") and counter.slip_text.text.contains("overheats"), "first customer introduces her existing reported complaint")
    check(counter.slip_text.text.contains("$60") and not counter.slip_text.text.contains("$90"), "agreed fee is shown; hidden true budget is not")
    check(counter.next_button.text.contains("Accept PC") and gs.opening_customers.size() == 2, "opening requires deliberate acceptance and retains both existing customers")
    # 0.57.3 (ART-08/09, approved 25 November 2026): Mara's own sprite and her PC are at the counter.
    var portrait: TextureRect = counter.get_node("CustomerPortrait")
    check(portrait.visible and portrait.texture != null and portrait.texture.resource_path.get_file() == "t001_mara.png" and Vector2i(portrait.texture.get_size()) == Vector2i(120, 172), "Mara's approved sprite stands at the counter window")
    check(portrait.size == Vector2(240, 344) and is_equal_approx(portrait.position.y + portrait.size.y, 488.0) and portrait.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "she is shown at exactly 2x with her waist on the counter top, pixels kept sharp")
    var pc_prop: TextureRect = counter.get_node("CustomerPC")
    check(pc_prop.visible and pc_prop.texture != null and pc_prop.size == Vector2(128, 196), "her PC stands on the counter at 2x while she is there")
    var jobs: Array = night.jobs(gs)
    var ids: Array = jobs.map(func(j: Dictionary) -> String: return str(j["id"]))
    var pcs: Array = jobs.map(func(j: Dictionary) -> String: return str(j["hardware_trial"]["night_session"]["pc"]))
    var stock: Array = gs.player_inventory.duplicate(true)
    var money: int = gs.money
    var seq: int = gs.ticket_sequence
    var infection: String = str(night.ticket_job(gs, str(ids[1])).get("infection", ""))
    check(ids.size() == 2 and pcs.size() == 2 and pcs[0] != pcs[1], "intake introduces the two existing unique jobs and PCs")
    check(gs.night_number == 1 and gs.night_minutes == 0 and night.last_report.is_empty() and not night.visits_pending, "opening is separate from paid collection and end-night reports")
    for f in range(5): await process_frame
    check(gs.night_minutes == 0 and counter.hotspot("BackDoor").disabled and counter.hotspot("Shutter").disabled, "untimed intake holds night work and closing")
    await press(counter.hotspot("BackDoor"))
    check(current_scene == counter and not counter._navigate(Nav.WORKSHOP), "disabled native door and guarded route cannot bypass intake")
    check(not night.switch_pc(gs, str(ids[1])) and not night.end_night(gs).get("ok", true), "PC switching and end-night API cannot bypass the waiting customer")
    check(gs.money == money and gs.player_inventory == stock and gs.night_number == 1, "blocked routes change no money, inventory or day")
    # A real Pause -> Title -> Continue round trip before accepting anyone.
    await press(counter.get_node("PauseButton"))
    var pause: Node = counter.get_node("PauseMenu")
    var title_button: Button
    for b: Node in pause.find_children("*", "Button", true, false):
        if b.text == "Title screen": title_button = b
    check(paused and title_button != null, "opening retains the shared native pause surface")
    await press(title_button)
    check(current_scene.scene_file_path == "res://scenes/start.tscn" and not paused, "Title safely leaves the opening")
    await cold_continue(gs, night)
    counter = current_scene
    check(counter.opening_visits and counter.slip_text.text.contains("Mara V.") and gs.opening_customers.size() == 2, "cold Continue resumes the unaccepted first customer")
    # An unrelated remembered scene must not strand pending intake away from the counter.
    Memory.enter(gs, Nav.WORKSHOP)
    check(Memory.resume_path(gs) == Nav.COUNTER, "pending opening overrides a stale last-scene preference")
    var before_pending: Array = gs.opening_customers.duplicate()
    night.read_only = true
    await press(counter.next_button)
    check(gs.opening_customers == before_pending and counter.slip_text.text.contains("Mara V."), "a protected save cannot acknowledge or skip a customer")
    night.read_only = false
    await press(counter.next_button)
    check(counter.visiting() and counter.slip_text.text.contains("Relu D.") and gs.opening_customers == [ids[1]], "accepting Mara presents the second existing customer")
    var relu_sprite: TextureRect = counter.get_node("CustomerPortrait")
    check(relu_sprite.visible and relu_sprite.texture != null and relu_sprite.texture.resource_path.get_file() == "t002_relu.png", "Relu's own sprite replaces Mara's")
    check(not counter.slip_text.text.to_lower().contains("adware") and infection != "", "the customer's dialogue does not reveal his hidden infection")
    await cold_continue(gs, night)
    counter = current_scene
    check(counter.opening_visits and counter.slip_text.text.contains("Relu D.") and gs.opening_customers == [ids[1]], "cold Continue retains acceptance progress without replaying Mara")
    check(not night.accept_opening_customer(gs, str(ids[0])) and gs.opening_customers == [ids[1]], "repeated/out-of-order acceptance is rejected")
    await press(counter.next_button)
    check(not counter.visiting() and not counter.opening_visits and gs.opening_customers.is_empty() and not counter.slip.visible, "last acceptance ends opening intake")
    check(not counter.get_node("CustomerPortrait").visible and not counter.get_node("CustomerPC").visible, "when the last customer leaves, the window and the counter top are empty again")
    check(gs.night_number == 1 and gs.night_minutes == 0 and counter.message.text.contains("Night 1 begins"), "night one starts without charging time or advancing a night")
    check(gs.money == money and gs.player_inventory == stock and gs.ticket_sequence == seq and night.jobs(gs).map(func(j: Dictionary) -> String: return str(j["id"])) == ids, "acceptance adds no money, stock or extra tickets")
    check(night.jobs(gs).map(func(j: Dictionary) -> String: return str(j["hardware_trial"]["night_session"]["pc"])) == pcs, "physical PC identities survive the opening and reloads")
    check(not night.accept_opening_customer(gs, str(ids[1])) and gs.money == money, "completed opening cannot be accepted twice")
    await cold_continue(gs, night)
    check(not current_scene.visiting() and gs.opening_customers.is_empty(), "completed opening does not replay after cold Continue")
    await press(current_scene.hotspot("BackDoor"))
    check(current_scene.scene_file_path == Nav.WORKSHOP, "after intake the real workshop door works")
    await press(current_scene.hotspot("RepairBench"))
    check(current_scene.scene_file_path == Nav.REPAIR, "the original first PC opens at the repair bench")
    # Compatible old and malformed optional data: never infer a first day from existing progress.
    var raw: Dictionary = Store.read(gs.save_path)
    raw.erase("opening_customers")
    check(Store.write(gs.save_path, raw) and gs.load_game() and gs.opening_customers.is_empty(), "legacy saves without the optional field do not replay opening")
    raw["opening_customers"] = {"not": "a list"}
    check(Store.write(gs.save_path, raw) and gs.load_game() and gs.opening_customers.is_empty(), "wrong optional container is safely ignored")
    raw["opening_customers"] = [str(ids[0]), str(ids[0]), 42, ""]
    check(Store.write(gs.save_path, raw) and gs.load_game() and gs.opening_customers == [ids[0]], "optional queue retains unique nonempty string IDs only")
    gs.opening_customers = ["missing-ticket"]
    check(night.opening_cards(gs).is_empty() and not night.accept_opening_customer(gs, "missing-ticket") and gs.opening_customers == ["missing-ticket"], "missing opening ticket is not manufactured or silently consumed")
    for p: String in [manifest, prefs]: _remove_save_files(p)
    restore_save(gs)
    finish("First customer")
