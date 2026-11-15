extends "res://tools/test_support.gd"
# D130: the cooler install technique. Film and screw mistakes are recorded at the lever, stay
# invisible to the shop's own final check, and cost the customer's pickup score.
const Ids = preload("res://scripts/data/ids.gd")
const Faults = preload("res://scripts/rules/install_faults.gd")
const Pickup = preload("res://scripts/rules/pickup_score.gd")
const Customers = preload("res://scripts/data/customers.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")

func _initialize() -> void: call_deferred("run_checks")

func take_screwdriver(bench: Node) -> void:
    # D131: the press must finish first, then the screwdriver is right-clicked on the bench.
    bench.mount.time_left = 0.0
    if bench.tools.equipped: bench._park_tool()
    var at: Vector2 = bench.tools.motions[Ids.SCREWDRIVER].center
    click(bench, MOUSE_BUTTON_RIGHT, true, at)
    click(bench, MOUSE_BUTTON_RIGHT, false, at)

func lock_with(bench: Node, order: Array) -> void:
    take_screwdriver(bench)
    var centers: Array = Faults.screw_centers(bench._socket_region())
    for screw: int in order:
        click(bench, MOUSE_BUTTON_LEFT, true, centers[screw])
        click(bench, MOUSE_BUTTON_LEFT, false, centers[screw])
    var lever: Vector2 = bench.SECURE_LEVER.get_center()
    click(bench, MOUSE_BUTTON_LEFT, true, lever)
    click(bench, MOUSE_BUTTON_LEFT, false, lever)

func mounted_bench(gs: Node, peel: bool) -> Node:
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    bench._select_stage(1)
    if peel: bench._on_film_pressed()
    bench.paste.deposit(25.5, 25.5, 80)
    bench._on_mount_pressed()
    return bench

func prepare_pickup(gs: Node, faults: Array) -> Dictionary:
    gs.new_game(false)
    gs.tickets_taken = 0
    var fractions: Dictionary = {}
    for z: Dictionary in DustZones.zones(): fractions[z["id"]] = 1.0
    gs.set_dust(fractions)
    gs.set_pc_powered(true)   # PCs now start switched off; the live check needs it on
    gs.job["paste_grade"] = "PERFECT"
    gs.job["paste_done"] = true
    gs.job["install_faults"] = faults
    return gs.run_final_check()

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs, "install_technique_test.json")

    # Pure rule.
    var good: Array = [0, 3, 1, 2, 0, 3, 1, 2]
    check(Faults.evaluate(true, good).is_empty(), "peeled film and a cross-pattern, two-pass tightening make no mistake")
    check(Faults.evaluate(false, good) == [Faults.FILM], "film left on is the only fault when screws are right")
    check(Faults.evaluate(true, []) == [Faults.LOOSE], "no screws turned leaves the cooler loose")
    check(Faults.evaluate(true, [0, 3, 1, 2]) == [Faults.LOOSE], "only one pass leaves the screws loose")
    check(Faults.evaluate(true, [0, 1, 2, 3, 0, 1, 2, 3]) == [Faults.UNEVEN], "tightening round the square makes it uneven")
    check(Faults.evaluate(true, [0, 3, 1, 3, 0, 3, 1, 2]).is_empty(), "one wrong pair is forgiven")
    check(Faults.evaluate(false, []) == [Faults.FILM, Faults.LOOSE], "film and loose screws can combine")
    check(not Faults.can_turn([0, 0], 0) and Faults.can_turn([0], 0) and not Faults.can_turn([], 4), "a screw takes two turns at most and only corners exist")
    check(Faults.sanitize(["film_left", "junk", "film_left", 5]) == [Faults.FILM], "saved faults are rebuilt from known ids only")
    check(Faults.screw_at(Rect2(120, 150, 408, 408), Faults.screw_centers(Rect2(120, 150, 408, 408))[3]) == 3 and Faults.screw_at(Rect2(120, 150, 408, 408), Vector2(300, 300)) == -1, "screw hit test finds a corner screw and ignores the middle")

    # Pickup score: the mistake costs the customer's check, never the shop's.
    var who: Dictionary = Customers.customer(Customers.IDS[0])
    var clean: Dictionary = Pickup.score(who, 50.0, 100.0, 100.0, 16.0, 75.0, [])
    var film: Dictionary = Pickup.score(who, 50.0, 100.0, 100.0, 16.0, 75.0, [Faults.FILM])
    check(int(film["score"]) < int(clean["score"]) - 25 and int(film["score"]) < Pickup.HAPPY_FROM, "film left on sends an ordinary customer home unhappy")
    check(str(film["misses"]).contains("plastic film"), "the complaint names the film")
    var crooked: Dictionary = Pickup.score(who, 50.0, 100.0, 100.0, 16.0, 75.0, [Faults.UNEVEN])
    check(int(crooked["score"]) >= Pickup.HAPPY_FROM and not (crooked["misses"] as Array).is_empty(), "a small crooked mount is noticed but forgiven")

    # The shop's own final check never shows the fault; only the pickup does.
    var clean_run: Dictionary = prepare_pickup(gs, [])
    var faulty_run: Dictionary = prepare_pickup(gs, [Faults.FILM, Faults.LOOSE])
    check(bool(faulty_run["passed"]) and is_equal_approx(float(faulty_run["temp"]), float(clean_run["temp"])), "the shop's final check temperature ignores install faults")
    check(not str(faulty_run["notes"]).contains("film") and not str(faulty_run["notes"]).contains("screw"), "the final check notes never mention the hidden faults")
    var clean_pick: Dictionary = clean_run.get("pickup", {})
    var faulty_pick: Dictionary = faulty_run.get("pickup", {})
    check(not clean_pick.is_empty() and not faulty_pick.is_empty() and int(faulty_pick["score"]) < int(clean_pick["score"]) and str(faulty_pick["misses"]).contains("film"), "the customer's pickup reports the mistake")

    # Save round trip.
    gs.job["install_faults"] = [Faults.FILM]
    gs.job["cooler_film_peeled"] = true
    gs.save_game()
    check(gs.load_game() and gs.job["install_faults"] == [Faults.FILM] and bool(gs.job["cooler_film_peeled"]), "faults and film state survive save and load")

    # Bench flow, with real clicks.
    var bench: Node = mounted_bench(gs, true)
    check(bool(gs.job["cooler_film_peeled"]) and bench.film_button.disabled, "peeling the film is recorded once")
    var early: Vector2 = Faults.screw_centers(bench._socket_region())[0]
    click(bench, MOUSE_BUTTON_LEFT, true, early)
    click(bench, MOUSE_BUTTON_LEFT, false, early)
    check(gs.job["install_faults"].is_empty() and not bench.tools.equipped, "screws cannot be touched without the screwdriver in hand")
    lock_with(bench, good)
    check(gs.job["install_faults"].is_empty() and str(gs.job["paste_grade"]) != "", "film off and cross-pattern screws lock with no fault")
    bench.queue_free()
    await process_frame

    bench = mounted_bench(gs, false)
    lock_with(bench, [])
    check(gs.job["install_faults"] == [Faults.FILM, Faults.LOOSE], "forgetting the film and the screws is recorded without any warning")
    check(not str(bench.status_label.text).contains("film") and not str(bench.status_label.text).contains("screw"), "the bench status never names the hidden mistakes")
    bench._on_clear_pressed()
    check(gs.job["install_faults"].is_empty(), "taking the cooler off and resetting clears the recorded faults")
    bench.queue_free()
    await process_frame

    bench = mounted_bench(gs, true)
    lock_with(bench, [0, 1, 2, 3, 0, 1, 2, 3])
    check(gs.job["install_faults"] == [Faults.UNEVEN], "screws tightened round the square are recorded as uneven")
    bench.queue_free()
    await process_frame
    restore_save(gs)
    finish("Install technique")
