# 0.58.3 (D173): the cable box. Rules (moving tangles loose cables, ties prevent it, knots, breaking,
# supplies), its file (per playthrough, in the morning backups), the physics (pulling the open end frees a
# knot, pulling the other end snaps the cable), the rooms (open, carry, put down elsewhere) and the store.
# User, 27 November 2026: one box, "can be moved from room to room"; tangles "when the box is moved and there
# are loose cables inside"; "more physics-based"; things from the shop help; cables "can break".
extends "res://tools/test_support.gd"
const CableBox = preload("res://scripts/rules/cable_box.gd")
const CableStore = preload("res://scripts/state/cable_store.gd")
const CableBoxView = preload("res://scripts/view/cable_box_view.gd")
const Backups = preload("res://scripts/state/save_backups.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func one_knot(open_a: int) -> Dictionary:
    var state: Dictionary = CableBox.fresh("test")
    state["knots"] = [{"a": "c1", "b": "c3", "open_a": open_a, "open_b": 0, "at_a": 0.5, "at_b": 0.5, "strain": 0.0}]
    return state


func far_corner(view: Control, from: Vector2) -> Vector2:
    var r: Rect2 = view.FLOOR
    var best := r.position
    for c: Vector2 in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
        if c.distance_to(from) > best.distance_to(from): best = c
    return best


func pull(view: Control, id: String, end: int, steps: int) -> void:
    view.grab(id, end)
    view.drag_to(far_corner(view, view.anchors[0]))
    for i in range(steps):
        if view.held_id == "": break
        view.step(1.0 / 60.0)


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")

    # ---- rules ----
    var box: Dictionary = CableBox.fresh("r")
    check((box["cables"] as Array).size() == 5 and box["room"] == "workshop" and (box["knots"] as Array).is_empty() and int(box["zip_ties"]) == 0, "a new box: five loose cables (two 24-pin, three 8-pin) in the workshop, no knots, no ties")
    check(CableBox.put_down(box, "workshop") == 0 and int(box["moves"]) == 0, "putting the box back where it was tangles nothing")
    CableBox.pick_up(box)
    var made: int = CableBox.put_down(box, "counter")
    check(made > 0 and made == (box["knots"] as Array).size() and box["room"] == "counter" and not bool(box["carried"]) and int(box["moves"]) == 1, "moved to another room, the loose cables tangle (%d knots)" % made)
    var again: Dictionary = CableBox.fresh("r")
    CableBox.put_down(again, "counter")
    check(again["knots"] == box["knots"], "the same move tangles the same way (no hidden randomness between runs)")
    check(CableBox.put_down(box, "attic") == -1, "the box only stands in rooms that can hold it")
    var tidy: Dictionary = CableBox.fresh("r")
    tidy["zip_ties"] = 3
    tidy["velcro"] = 2
    for id: String in ["c1", "c2", "c3"]: CableBox.tie(tidy, id, "zip")
    for id: String in ["c4", "c5"]: CableBox.tie(tidy, id, "velcro")
    check(int(tidy["zip_ties"]) == 0 and int(tidy["velcro"]) == 0 and CableBox.loose(tidy).is_empty(), "ties use up zip ties and straps")
    check(CableBox.put_down(tidy, "outside") == 0 and (tidy["knots"] as Array).is_empty(), "tied cables never tangle, however far the box goes")
    check(CableBox.untie(tidy, "c4") and int(tidy["velcro"]) == 1 and CableBox.untie(tidy, "c1") and int(tidy["zip_ties"]) == 0, "a velcro strap goes back in the box; a zip tie is cut off and used up")
    var knotted: Dictionary = one_knot(0)
    knotted["zip_ties"] = 1
    check(not CableBox.can_tie(knotted, "c1", "zip") and CableBox.can_tie(knotted, "c2", "zip") and not CableBox.can_tie(knotted, "c2", "velcro"), "a cable caught in a knot cannot be tied; tying needs the right supply")
    check(not ("c1" in CableBox.usable(knotted, "atx24")) and "c2" in CableBox.usable(knotted, "atx24"), "a knotted cable is not ready to use")
    check(not CableBox.strain(knotted, 0, "c1", 0.6) and CableBox.strain(knotted, 0, "c1", 0.6) and bool(CableBox.cable(knotted, "c1")["broken"]) and (knotted["knots"] as Array).is_empty(), "pulled too hard, a cable snaps and its knot falls apart")
    check(not ("c1" in CableBox.usable(knotted, "atx24")) and CableBox.throw_away(knotted, "c1") and CableBox.cable(knotted, "c1").is_empty() and not CableBox.throw_away(knotted, "c2"), "a broken cable is useless and can be thrown away; a whole one cannot")
    var odd: Dictionary = CableBox.sanitize({"version": 1, "room": "moon", "cables": [{"id": "x", "kind": "atx24", "tie": "zip"}, {"id": "y", "kind": "pcie8"}, {"id": "y", "kind": "pcie8"}, {"id": "z", "kind": "hdmi"}],
        "knots": [{"a": "x", "b": "y"}, {"a": "y", "b": "nobody"}], "zip_ties": -4}, "r")
    check(odd["room"] == "workshop" and (odd["cables"] as Array).size() == 2 and (odd["knots"] as Array).is_empty() and int(odd["zip_ties"]) == 0 and CableBox.sanitize("junk", "r")["cables"].size() == 5, "a damaged box file is cleaned: unknown rooms, kinds, duplicate ids, knots on tied or missing cables are dropped")

    # ---- the file, per playthrough ----
    use_test_save(gs, "cable_box_test.json")
    var cables_file: String = CableStore.path(gs.save_path)
    for path: String in [cables_file, gs.save_path + ".night.json", gs.save_path + ".navigation.json"]: _remove_save_files(path)
    gs.new_game(false)
    check(night.start(gs, false), "a game starts")
    var mine: Dictionary = CableStore.load_box(gs)
    mine["zip_ties"] = 7
    check(CableStore.save_box(gs, mine) and int(CableStore.load_box(gs)["zip_ties"]) == 7 and CableStore.load_box(gs)["run"] == night.run_id, "the box is saved next to the save, for this playthrough")
    check(FileAccess.file_exists(Backups.run_folder(gs.save_path, night.run_id).path_join("morning_%04d" % int(gs.night_number)).path_join(gs.save_path.get_file() + ".night.json")) and Backups.SUFFIXES.has(CableStore.SUFFIX), "the morning backups include the cable box")
    gs.new_game(false)
    night.start(gs, false)
    check(int(CableStore.load_box(gs)["zip_ties"]) == 0, "a new game starts with a fresh box, not the old game's")

    # ---- physics ----
    var view: Control = CableBoxView.new()
    root.add_child(view)
    view.open(null, one_knot(0))
    check(view.ropes.size() == 5 and view.anchors.size() == 1, "open: every loose cable is a rope; the knot holds two of them")
    pull(view, "c1", 0, 600)
    check((view.state["knots"] as Array).is_empty() and not bool(CableBox.cable(view.state, "c1")["broken"]), "pulling a cable by the end it can slip out of slides it through the knot and frees it")
    view.queue_free()
    var view2: Control = CableBoxView.new()
    root.add_child(view2)
    view2.open(null, one_knot(0))
    pull(view2, "c1", 1, 600)
    check(bool(CableBox.cable(view2.state, "c1")["broken"]) and (view2.state["knots"] as Array).is_empty() and view2.held_id == "", "pulling the other end only tightens the knot, until the cable snaps")
    view2.queue_free()
    await process_frame

    # ---- rooms: open, carry, put down elsewhere ----
    change_scene_to_file("res://scenes/rooms/workshop.tscn")
    for f in range(3): await process_frame
    var spot: Button = current_scene.get_node_or_null("CableBoxSpot")
    check(spot != null and spot.visible and not current_scene.cable_drop.visible, "the cable box stands in the workshop")
    current_scene.open_cable_box()
    check(current_scene.cable_view != null and current_scene.cable_view.get_node_or_null("CableBox_carry") != null, "clicking it opens the box")
    current_scene.cable_view.get_node("CableBox_carry").emit_signal("pressed")
    await process_frame
    check(not spot.visible and current_scene.cable_drop.visible and bool(CableStore.load_box(gs)["carried"]), "carry the box: it leaves the room with you")
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    for f in range(3): await process_frame
    var drop: Button = current_scene.get_node_or_null("CableBoxDrop")
    check(drop != null and drop.visible and not current_scene.cable_spot.visible, "at the counter you can put it down")
    drop.emit_signal("pressed")
    var moved: Dictionary = CableStore.load_box(gs)
    check(moved["room"] == "counter" and not bool(moved["carried"]) and current_scene.cable_spot.visible and not drop.visible and str(current_scene.message.text).contains("cable box down"), "put down at the counter: it stands there now, and the loose cables shifted on the way")

    # ---- the store sells supplies ----
    gs.money = 100
    change_scene_to_file("res://scenes/night_shop.tscn")
    for f in range(3): await process_frame
    var buy: Button = current_scene.get_node_or_null("Supply_zip_ties")
    check(buy != null and not buy.disabled, "the store sells zip ties for the cable box")
    if buy != null: buy.emit_signal("pressed")
    check(int(gs.money) == 100 - int(CableBox.SUPPLIES["zip_ties"]["price"]) and int(CableStore.load_box(gs)["zip_ties"]) == int(CableBox.SUPPLIES["zip_ties"]["count"]), "bought zip ties are paid for and go in the box")
    gs.money = 1
    current_scene._refresh()
    check(current_scene.supply_buttons["velcro"].disabled and not gs.spend_cash(5) and int(gs.money) == 1, "without the cash, nothing is bought")

    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [cables_file, gs.save_path + ".night.json", gs.save_path + ".navigation.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Cable box")
