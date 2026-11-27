# 0.58.4: the personal inventory. User, 27 November 2026: "the player can have a personal inventory (he can
# buy backpacks to upgrade)"; "Just carry, no gating". Rules (sizes by backpack owned), the storage model
# (one more unit; never auto-filled; kept by Arrange; whole PCs refused; a smaller backpack spills to the
# room), the store's backpacks, and the Backpack button and view in the rooms.
extends "res://tools/test_support.gd"
const Backpack = preload("res://scripts/rules/backpack.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    var layout_path: String = Store.new().path
    var layout_before: String = FileAccess.get_file_as_string(layout_path) if FileAccess.file_exists(layout_path) else ""
    use_test_save(gs, "backpack_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    gs.new_game(false)
    night.start(gs, false)
    if FileAccess.file_exists(layout_path): DirAccess.remove_absolute(layout_path)

    # ---- rules ----
    check(Backpack.size_for({}) == Vector2i(4, 2) and Backpack.size_for({"backpack_small": true}) == Vector2i(6, 3) and Backpack.size_for({"backpack_small": true, "backpack_large": true}) == Vector2i(8, 4) and Backpack.size_for({"backpack_large": true}) == Vector2i(8, 4), "you always have pockets (4 x 2); backpacks make it 6 x 3 and 8 x 4")

    # ---- the storage model ----
    var m := Model.new()
    m.setup(Sources.collect(gs), {}, Vector2i(4, 2))
    check(m.in_unit(Backpack.ID).is_empty(), "nothing is packed by itself: the backpack is never auto-filled")
    check(m.place_first("tool:kit:brush", Backpack.ID) and m.placements["tool:kit:brush"]["unit"] == Backpack.ID, "a tool fits in your pockets")
    var pc: String = ""
    for uid: String in m.items:
        if str(m.items[uid]["category"]) == "pc": pc = uid
    check(pc != "" and not m.place_first(pc, Backpack.ID), "a whole customer PC does not go in a backpack")
    m.arrange()
    check(m.placements["tool:kit:brush"]["unit"] == Backpack.ID, "Arrange the stock room leaves what you carry alone")
    var saved: Dictionary = m.snapshot()
    var again := Model.new()
    again.setup(Sources.collect(gs), saved, Vector2i(4, 2))
    check(again.placements["tool:kit:brush"]["unit"] == Backpack.ID, "what you carry is saved with the storage layout")
    var tight := Model.new()
    tight.setup(Sources.collect(gs), saved, Vector2i(2, 1))
    check(tight.placements.has("tool:kit:brush") and tight.placements["tool:kit:brush"]["unit"] != Backpack.ID, "if something no longer fits, it goes back to the stock room instead of vanishing")

    # ---- the store ----
    gs.money = 200
    check(gs.buy_upgrade("backpack_small") and int(gs.money) == 200 - int(gs.UPGRADE_PRICES["backpack_small"]) and Backpack.size_for(gs.upgrades) == Vector2i(6, 3), "a small backpack is bought at the store and makes room for more")
    var grown := Model.new()
    grown.setup(Sources.collect(gs), {})
    check(grown.backpack_size == Vector2i(6, 3), "the storage model knows the backpack you own")
    change_scene_to_file("res://scenes/night_shop.tscn")
    for f in range(3): await process_frame
    check(current_scene.upgrade_buttons.has("backpack_large") and current_scene.upgrade_buttons["backpack_small"].disabled, "the store sells backpacks; one you own is marked owned")

    # ---- the rooms: the Backpack button and the view ----
    change_scene_to_file("res://scenes/rooms/workshop.tscn")
    for f in range(3): await process_frame
    var button: Button = current_scene.get_node_or_null("BackpackButton")
    check(button != null and button.visible, "every room has a Backpack button")
    if button != null: button.emit_signal("pressed")
    await process_frame
    var view: Control = current_scene.backpack_view
    check(view != null and view.model.backpack_size == Vector2i(6, 3) and view.title.text.contains("Small backpack"), "it opens your backpack, the size of the one you own")
    if view != null:
        check(view.pack("tool:kit:pick") and "tool:kit:pick" in view.packed(), "pack something from the stock room")
        var reread := Model.new()
        reread.setup(Sources.collect(gs), Store.new().read())
        check(reread.placements["tool:kit:pick"]["unit"] == Backpack.ID, "it stays packed in the saved layout")
        var r: Rect2 = view.item_rect("tool:kit:pick")
        view.press_at(r.get_center())
        check(view.model.held == "tool:kit:pick", "click a packed item to pick it up")
        view.press_at(view.grid_rect().position + Vector2(view.CELL * 2 + 5, view.CELL * 2 + 5))
        check(view.model.held == "" and view.model.placements["tool:kit:pick"]["unit"] == Backpack.ID, "click a free spot in the backpack to put it down")
        view.selected = "tool:kit:pick"
        view._to_counter()
        check(view.model.placements["tool:kit:pick"]["unit"] == "counter" and not "tool:kit:pick" in view.packed(), "put it under the counter from your backpack")
        current_scene.get_node("BackpackView").get_node("BackpackClose").emit_signal("pressed")
        await process_frame
        check(current_scene.backpack_view == null, "close the backpack")
    var key := InputEventKey.new()
    key.keycode = KEY_B
    key.pressed = true
    current_scene._unhandled_input(key)
    await process_frame
    check(current_scene.backpack_view != null, "B opens it too")

    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    if layout_before != "":
        var file := FileAccess.open(layout_path, FileAccess.WRITE)
        file.store_string(layout_before)
        file.close()
    elif FileAccess.file_exists(layout_path): DirAccess.remove_absolute(layout_path)
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Backpack")
