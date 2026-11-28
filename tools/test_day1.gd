# 0.59.2 (D186): the first day from the notebook of 28 November 2026. B85 (the till shows what the fake reviews
# cost right away), the counter top and your arms (what is handed over waits on the counter; one thing carried),
# the 8 x 6 backpack that takes a laptop but not a desktop, laptops cracking under a pile, the repair bench's
# new first steps (lift the PC onto the mat, turn out the screws, lift the panel off), the thermal manual, the
# customer's slide in and out, and the backpack sliding in from the right edge.
extends "res://tools/test_support.gd"
const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Backpack = preload("res://scripts/rules/backpack.gd")
const Laptop = preload("res://scripts/rules/laptop.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const Reviews = preload("res://scripts/rules/reviews.gd")
const Layout = preload("res://scripts/data/layout.gd")
const BenchCase = preload("res://scripts/view/bench_case.gd")
const BenchManual = preload("res://scripts/ui/bench_manual.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func sample(id: String, size: Vector2i, stackable: bool, handed: bool) -> Dictionary:
    return {"id": id, "source_uid": id, "category": "pc", "kind": "pc", "label": id, "model": id, "size": size,
        "owner": "Customer", "condition": "", "reserved": false, "stackable": stackable, "finish": "silver", "note": "", "at_counter": handed}


func tool_item(id: String) -> Dictionary:
    return {"id": id, "source_uid": id, "category": "tool", "kind": "brush", "label": id, "model": id, "size": Vector2i(1, 2),
        "owner": "Shop property", "condition": "working", "reserved": false, "note": ""}


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    var layout_path: String = Store.new().path
    var layout_before: String = FileAccess.get_file_as_string(layout_path) if FileAccess.file_exists(layout_path) else ""
    use_test_save(gs, "day1_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    if FileAccess.file_exists(layout_path): DirAccess.remove_absolute(layout_path)

    # ---- rules ----
    check(Backpack.size_for({"backpack_small": true}) == Vector2i(8, 6) and Backpack.size_for({"backpack_large": true}) == Vector2i(10, 7), "a small backpack is 8 x 6, a hiking one 10 x 7")
    check(is_zero_approx(Laptop.pile_damage_chance(0)) and is_equal_approx(Laptop.pile_damage_chance(1), 0.05) and is_equal_approx(Laptop.pile_damage_chance(2), 0.10), "a laptop under one thing cracks 5% of nights, more with more on top")
    var cracked_job: Dictionary = {Laptop.LID_CRACKED: true}
    check(Laptop.pickup_faults(cracked_job) == [Laptop.LID_CRACKED] and Laptop.pickup_faults({}).is_empty(), "a cracked lid is something the customer finds at pickup")
    var fine: Dictionary = PickupScore.score({}, 40.0, 0.0, 0.0, 8.0, 90.0, [])
    var cracked: Dictionary = PickupScore.score({}, 40.0, 0.0, 0.0, 8.0, 90.0, [Laptop.LID_CRACKED])
    check(int(cracked["score"]) == int(fine["score"]) - int(Laptop.LID_ANNOYANCE) and "the laptop's lid is cracked" in cracked["misses"], "the customer is unhappy about it and says so")

    # ---- the approved laptop art (revision 1) is in the game byte for byte ----
    var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/laptop/manifest.json"))
    var hashes: Dictionary = manifest.get("sha256", {}) if manifest is Dictionary else {}
    var art_ok: bool = hashes.size() == 11 and str(manifest.get("approval_quote", "")) == "The art is approved, btw"
    for art_path: String in hashes:
        if FileAccess.get_sha256("res://" + art_path) != str(hashes[art_path]): art_ok = false
    check(art_ok, "the approved laptop art is installed exactly as approved (11 files, hashes in art/laptop/manifest.json)")

    # ---- storage: the counter top, your arms, the backpack ----
    var m := Model.new()
    m.setup({"lap": sample("lap", Laptop.SIZE, true, true), "desk": sample("desk", Vector2i(8, 6), false, true),
        "old": sample("old", Vector2i(8, 6), false, false), "brush": tool_item("brush"), "pick": tool_item("pick")}, {}, Vector2i(8, 6))
    check(m.placements["lap"]["unit"] == Data.TOP_ID and m.placements["desk"]["unit"] == Data.TOP_ID, "what a customer just handed over waits on the counter top")
    check(m.placements["old"]["unit"] != Data.TOP_ID, "a PC that was not just handed over goes to the stock room")
    check(m.place_first("brush", Data.ARMS_ID) and m.placements["brush"]["unit"] == Data.ARMS_ID, "you can carry one thing in your arms")
    check(not m.place_first("pick", Data.ARMS_ID), "only one thing at a time")
    m.placements.erase("brush")
    check(m.place_first("desk", Data.ARMS_ID), "a whole desktop can be carried in your arms")
    check(m.place_first("lap", Backpack.ID) and m.placements["lap"]["unit"] == Backpack.ID, "a laptop fits in a small backpack")
    check(not m.place_first("old", Backpack.ID), "a desktop does not")
    m.arrange()
    check(m.placements["desk"]["unit"] == Data.ARMS_ID and m.placements["lap"]["unit"] == Backpack.ID, "Arrange leaves what you carry alone")
    var pile := Model.new()
    pile.setup({"tower": sample("tower", Vector2i(8, 6), false, false), "a": sample("a", Laptop.SIZE, true, false), "b": sample("b", Laptop.SIZE, true, false)}, {}, Vector2i(8, 6))
    var rack: String = str(pile.placements["tower"]["unit"])
    var at: Vector2i = pile.placements["tower"]["cell"]
    var shelf: int = int(pile.placements["tower"]["shelf"])
    pile.placements.erase("a")
    pile.placements.erase("b")
    check(pile.place("a", rack, shelf, at, 0) and pile.place("b", rack, shelf, at, 0), "two laptops piled on a tower")
    check(pile.above_count("tower") == 2 and pile.above_count("a") == 1 and pile.above_count("b") == 0, "each knows how much lies on top of it")

    # ---- B85: the till badge after buying reviews ----
    gs.desktop_first_ticket = true
    gs.new_game(false)
    night.start(gs, false)
    gs.money = 200
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    for f in range(3): await process_frame
    var counter: Node = current_scene
    await finish_dialogue(counter)
    counter.phone.open()
    counter.phone._buy()
    await process_frame
    check(int(gs.money) == 200 - int(Reviews.FAKE_PRICE), "buying reviews costs money")
    check(counter.hotspot("Till").badge == "$%d" % int(gs.money), "B85: the till on the top bar shows the new cash right away (%s)" % counter.hotspot("Till").badge)

    # ---- the customer's slide ----
    var person := TextureRect.new()
    person.texture = load("res://art/props/pc_tower_closed.png")
    person.position = Vector2(500, 100)
    person.size = Vector2(40, 40)
    counter.add_child(person)
    counter._slide_in(person)
    check(is_equal_approx(person.position.x, 500.0 + counter.SLIDE_FROM) and is_zero_approx(person.modulate.a), "a customer starts by the door, unseen")
    await create_timer(counter.SLIDE_SECONDS + 0.2).timeout
    check(is_equal_approx(person.position.x, 500.0) and is_equal_approx(person.modulate.a, 1.0), "and slides in to the counter")
    counter._slide_out(person)
    check(counter.get_node_or_null("LeavingCustomer") != null, "leaving, they slide out")
    await create_timer(counter.SLIDE_SECONDS + 0.2).timeout
    check(counter.get_node_or_null("LeavingCustomer") == null, "and are gone")
    check(counter.edge_blocked() == counter.storage_open, "the backpack does not slide in over the open drawer")

    # ---- the first day: handed over, the PCs wait on the counter ----
    gs.desktop_first_ticket = false
    gs.tickets_taken = 0
    gs.new_game(false)
    check(str(gs.job["case_state"]) == BenchCase.OFF_TABLE, "a new ticket's PC still has to be put on the mat and opened")
    check(night.start(gs, true), "the first-day intake starts")
    check(bool(gs.job.get("at_counter", false)), "Mara's laptop is handed over at the counter")
    if FileAccess.file_exists(layout_path): DirAccess.remove_absolute(layout_path)
    var day := Model.new()
    day.setup(Sources.collect(gs), {}, Vector2i(8, 6))
    var on_top: Array = day.in_unit(Data.TOP_ID)
    check(on_top.any(func(uid: String) -> bool: return str(day.items[uid]["source_uid"]) == str(gs.job["id"])), "her laptop waits on the counter top, not in the stock room")

    # ---- the repair bench: lift it on, unscrew, lift the panel off ----
    var cover := BenchCase.new()
    root.add_child(cover)
    cover.setup("tower", BenchCase.OFF_TABLE)
    var states: Array = []
    cover.changed.connect(func(value: String) -> void: states.append(value))
    var was_opened: Array = [false]
    cover.opened.connect(func() -> void: was_opened[0] = true)
    check(cover.active() and cover.message.contains("onto the mat"), "it starts beside the mat")
    cover.press(cover.panel_pos + Vector2(4, 4))
    cover.release(cover.case_rect().get_center())
    check(cover.state == BenchCase.CLOSED and states == [BenchCase.CLOSED], "drag it onto the mat")
    cover.press(cover.case_rect().get_center())
    check(cover.state == BenchCase.CLOSED and not cover.dragging and cover.message.contains("still screwed"), "the side panel does not come off while screwed on")
    check(cover.screw_count() == 2, "a desktop has two thumbscrews")
    for i in range(cover.screw_count()): cover.press(cover.screw_center(i))
    check(cover.screws_out.size() == 2 and cover.message.contains("Lift the side panel"), "click each screw out")
    cover.press(cover.case_rect().get_center())
    cover.release(Layout.BENCH_TRAY.get_center())
    check(cover.state == BenchCase.OPEN and was_opened[0] and not cover.visible and states.back() == BenchCase.OPEN, "drag the panel onto the tray: the case is open")
    cover.queue_free()
    var lid := BenchCase.new()
    root.add_child(lid)
    lid.setup("laptop", BenchCase.CLOSED)
    check(lid.screw_count() == 8 and lid.message.contains("cover screws"), "a laptop's bottom cover has eight screws")
    lid.queue_free()
    gs.set_case_state("nonsense")
    check(str(gs.job["case_state"]) == BenchCase.OFF_TABLE, "an unknown case state is ignored")
    gs.set_case_state(BenchCase.OPEN)
    check(str(gs.job["case_state"]) == BenchCase.OPEN, "opening it is saved with the ticket")
    gs.set_case_state(BenchCase.OFF_TABLE)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    await process_frame
    await process_frame
    check(bench.case_cover != null and bench.case_cover.active() and bench.case_cover.profile_id == "laptop", "the repair bench starts with her closed laptop beside the mat")
    check(bench.manual != null and not bench.manual.visible, "the thermal manual waits for the paste step")
    bench.queue_free()
    await process_frame

    # ---- the thermal manual ----
    var book := BenchManual.new()
    root.add_child(book)
    book.follow(2, "NOW: press and screw down")
    check(book.page == 2 and book.now_line.contains("NOW"), "the manual opens at the step you are on")
    book.turn(1)
    book.follow(2, "NOW: press and screw down")
    check(book.page == 3, "a page you turned to yourself stays while your step is the same")
    book.follow(3, "NOW: lock the lever")
    book.turn(5)
    check(book.page == BenchManual.PAGES.size() - 1, "pages stop at the last one")
    book.follow(1, "NOW: a pea of paste")
    check(book.page == 1, "and it turns with you when your step changes")
    book.queue_free()

    # ---- your backpack slides in from the right edge ----
    gs.desktop_first_ticket = true
    gs.new_game(false)
    night.start(gs, false)
    change_scene_to_file("res://scenes/rooms/workshop.tscn")
    for f in range(3): await process_frame
    var room: Node = current_scene
    room.open_backpack(true)
    check(room.backpack_view != null and room.backpack_view.position.x > 600.0, "it starts off the right edge")
    await create_timer(room.BACKPACK_SLIDE + 0.2).timeout
    check(is_zero_approx(room.backpack_view.position.x), "and slides in")
    var view: Control = room.backpack_view
    check(view.carry("tool:kit:brush") and "tool:kit:brush" in view.carried(), "take a tool in your arms")
    check(not view.carry("tool:kit:pick"), "your arms hold one thing")
    view.selected = "tool:kit:brush"
    view._unpack()
    check(not "tool:kit:brush" in view.carried(), "put it back in the stock room")
    room._close_backpack()
    check(room.backpack_view == null and not room.edge_armed, "closed, it does not slide straight back in: the pointer has to leave the edge first")
    await process_frame

    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    if layout_before != "":
        var file := FileAccess.open(layout_path, FileAccess.WRITE)
        file.store_string(layout_before)
        file.close()
    elif FileAccess.file_exists(layout_path): DirAccess.remove_absolute(layout_path)
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Day 1")
