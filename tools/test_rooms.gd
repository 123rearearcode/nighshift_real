# 0.53.0 / D161: the rooms replace the menus. The counter is the main screen; doors lead outside and to
# the workshop; stations, the stock room and the testing bay are reached from the workshop; the morning's
# customers walk in at the counter one at a time. Every room is art + hotspots the artist can replace.
# Transitions use native clicks on the real hotspots.
extends "res://tools/test_support.gd"
const Nav = preload("res://scripts/night/night_navigation.gd")
const Memory = preload("res://scripts/night/navigation_state.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const Hotspot = preload("res://scripts/rooms/hotspot.gd")
const StorageData = preload("res://scripts/storage/storage_data.gd")
const StorageModel = preload("res://scripts/storage/storage_model.gd")
const StorageSources = preload("res://scripts/storage/storage_sources.gd")
const StorageStore = preload("res://scripts/storage/storage_store.gd")
const ROOMS: Array = ["res://scenes/rooms/counter.tscn", "res://scenes/rooms/workshop.tscn", "res://scenes/rooms/outside.tscn"]

func _initialize() -> void:
    call_deferred("run_checks")


func press(button: Button) -> void:
    var at: Vector2 = button.get_global_rect().get_center()
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = at
        event.global_position = at
        root.push_input(event, true)
        await process_frame
    await process_frame


func scene(path: String) -> void:
    change_scene_to_file(path)
    for f in range(3): await process_frame


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "rooms_test.json")
    var manifest: String = gs.save_path + ".night.json"
    var prefs: String = gs.save_path + ".navigation.json"
    for path: String in [manifest, prefs]: _remove_save_files(path)
    gs.new_game(false)
    check(night.start(gs), "a night starts")

    # ---- every room: hotspots with known actions, placeholders until there is art ----
    for path: String in ROOMS:
        var room: Node = load(path).instantiate()
        root.add_child(room)
        await process_frame
        if path == Nav.COUNTER:
            check(not room.hotspots.is_empty() and not room.placeholders and room.get_node_or_null("BatchARoom") != null and room.hotspots.values().all(func(h: Variant) -> bool: return not h.placeholder), "the counter uses its approved layered art and hides placeholder furniture")
        else:
            check(not room.hotspots.is_empty() and room.placeholders and room.hotspots.values().all(func(h: Variant) -> bool: return h.placeholder), "%s draws placeholders while it has no art" % path.get_file())
        for h: Variant in room.hotspots.values():
            var spot: Hotspot = h
            var action: String = spot.action
            var known: bool = action.begins_with("later:") or (action.begins_with("go:") and Nav.PLACES.has(action.trim_prefix("go:")))
            if not known and (action.begins_with("open:") or action == "end_night"): known = room._action(action, spot)
            check(known and spot.label != "" and spot.art_hint != "", "%s/%s: '%s' does something and tells the artist what to paint" % [path.get_file(), spot.name, action])
        check(room.get_node_or_null("PauseButton") != null and room.get_node_or_null("ActivitiesButton") == null, "%s has Pause and no hub button" % path.get_file())
        room.queue_free()
        await process_frame
    var painted: Node = load("res://scenes/rooms/counter.tscn").instantiate()
    var image := Image.create(32, 18, false, Image.FORMAT_RGB8)
    image.fill(Color("335577"))
    (painted.get_node("Background") as TextureRect).texture = ImageTexture.create_from_image(image)
    root.add_child(painted)
    await process_frame
    check(not painted.placeholders and painted.get_node("Background").visible and painted.hotspots.values().all(func(h: Variant) -> bool: return not h.placeholder), "with art in place the placeholders disappear and the hotspots go invisible")
    painted.queue_free()
    await process_frame
    var fallback: Node = load(Nav.COUNTER).instantiate()
    fallback.counter_art.textures.clear()
    root.add_child(fallback)
    await process_frame
    check(fallback.placeholders and fallback.hotspots.values().all(func(h: Variant) -> bool: return h.placeholder), "if the approved counter kit is unavailable, every original hotspot still has its playable placeholder")
    fallback.queue_free()
    await process_frame
    image.save_png("user://rooms_test_art.png")
    check(RoomArt.texture("user://rooms_test_art.png") != null and RoomArt.room("does_not_exist") == null and RoomArt.customer({"id": "nobody", "profession": "nobody"}) == null, "pictures load from their file; a missing picture means placeholder")
    DirAccess.remove_absolute(ProjectSettings.globalize_path("user://rooms_test_art.png"))

    # ---- walking around with real clicks ----
    await scene(Nav.COUNTER)
    check(current_scene.scene_file_path == Nav.COUNTER and not current_scene.visiting(), "the night starts at the counter")
    await press(current_scene.hotspot("FrontDoor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.OUTSIDE, "the front door goes outside")
    await press(current_scene.hotspot("ShopDoor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "the shop door goes back in")
    await press(current_scene.hotspot("BackDoor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.WORKSHOP, "the back door goes to the workshop")
    check(str(current_scene.hotspot("RepairBench").badge).contains(str(gs.job["id"])), "the workshop shows which PC is on the bench")
    var pc: String = str(gs.job["hardware_trial"]["night_session"]["pc"])
    gs.job["hardware_trial"]["night_session"]["pc"] = ""
    await press(current_scene.hotspot("RepairBench"))
    check(current_scene.scene_file_path == Nav.WORKSHOP and current_scene.message.text.contains("No PC on the bench"), "with no PC on the bench the stations say so instead of opening")
    gs.job["hardware_trial"]["night_session"]["pc"] = pc
    await press(current_scene.hotspot("Monitor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.MONITOR, "a station opens with the PC on the bench")
    await press(current_scene.get_node("BackButton"))
    await process_frame
    await press(current_scene.hotspot("CounterDoor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "the workshop door leads back to the counter")
    # 0.55.0 (D162): no tool catalogue on the counter; the store is down the street, apart from the supplier.
    check(current_scene.hotspot("Catalogue") == null, "the counter has no tool catalogue any more")
    await press(current_scene.hotspot("FrontDoor"))
    await process_frame
    check(current_scene.hotspot("Store") != null and current_scene.hotspot("Store").action == "go:shop" and current_scene.hotspot("Supplier").action.begins_with("later:"), "outside, the store and the parts supplier are two different places")
    await press(current_scene.hotspot("Store"))
    await process_frame
    check(current_scene.scene_file_path == Nav.SHOP and current_scene.get_node("BackButton").text == "← Outside", "the store sells the tool upgrades and leads back out to the street")
    await press(current_scene.get_node("BackButton"))
    await process_frame
    check(current_scene.scene_file_path == Nav.OUTSIDE, "← Outside returns to the street")
    await press(current_scene.hotspot("ShopDoor"))
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "and the shop door back in to the counter")
    check(Memory.resume_path(gs) == Nav.COUNTER, "Continue resumes at the room you were in")

    # ---- things on the counter ----
    var counter: Node = current_scene
    await press(counter.hotspot("TicketClipboard"))
    await process_frame
    var open_tickets: int = night.jobs(gs).filter(func(j: Dictionary) -> bool: return j.get("state", "open") != "done").size()
    check(counter.clipboard.visible and counter.clipboard_list.get_child_count() == open_tickets, "the clipboard lists every open ticket")
    # 0.57.3 (ART-06/07, approved 25 November 2026): the clipboard is its own picture on the counter, and
    # the close-up is the approved skin at exactly 2x with the tickets written on its paper.
    var clip_spot: Hotspot = counter.hotspot("TicketClipboard")
    var resting: Texture2D = clip_spot.prop_texture(clip_spot.prop)
    var lifted: Texture2D = clip_spot.prop_texture(clip_spot.prop_hover)
    check(resting != null and Vector2i(resting.get_size()) == Vector2i(54, 36) and lifted != null and Vector2i(lifted.get_size()) == Vector2i(36, 48), "the clipboard on the counter is the approved prop, with its picked-up picture for hover")
    check(counter.clipboard.get_theme_stylebox("panel") is StyleBoxTexture and counter.clipboard.size == Vector2(600, 700) and counter.clipboard.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "the ticket close-up uses the approved clipboard skin at exactly 2x")
    if counter.clipboard_list.get_child_count() > 0:
        var paper_rect: Rect2 = counter.get_script().get_script_constant_map()["CLIPBOARD_PAPER"]
        var paper: Rect2 = Rect2(counter.clipboard.global_position + paper_rect.position, paper_rect.size)
        check(paper.grow(1).encloses(counter.clipboard_list.get_child(0).get_global_rect()), "ticket rows are written on the paper, clear of the clip and the board edge")
    if counter.clipboard_list.get_child_count() > 0:
        await press(counter.clipboard_list.get_child(0))
        await process_frame
        var window: Node = counter.get_node_or_null("TicketWindow")
        check(window != null, "clicking a ticket on the clipboard opens the ticket")
        if window != null:
            window.hide()   # an open dialog would take the next click; close it a frame before clicking on
            window.queue_free()
    counter.clipboard.hide()
    await process_frame
    await process_frame
    await press(counter.hotspot("Till"))
    check(counter.message.text.contains("$%d" % gs.money), "the till shows the cash")
    await press(counter.hotspot("Bin"))
    check(counter.message.text.contains("coming later"), "planned features say they are coming later")
    await press(counter.hotspot("Phone"))
    check(counter.phone.visible, "the phone on the counter opens the review app")
    counter.phone.hide()
    var key := InputEventKey.new()
    key.keycode = KEY_F3
    key.pressed = true
    root.push_input(key, true)
    await process_frame
    check(counter.outlines and counter.hotspots.values().all(func(h: Variant) -> bool: return h.outline), "F3 shows every hotspot's outline (for lining up art)")

    # ---- 06:00 ----
    gs.night_minutes = 480
    await scene(Nav.COUNTER)
    counter = current_scene
    check(counter.hotspot("BackDoor").disabled and counter.hotspot("FrontDoor").disabled and not counter.hotspot("Phone").disabled and not counter.hotspot("Shutter").disabled, "at 06:00 the doors to work close; the shutter and the phone stay")
    gs.night_minutes = 0

    # ---- the morning's customers walk in ----
    night.last_report = {"ok": true, "night": 1, "earned": 40, "cards": [
        {"kind": "new", "customer": "Ana Test", "customer_id": "", "ticket": "T901", "reaction": "New customer. My PC is slow."},
        {"kind": "waiting", "customer": "Bo Test", "customer_id": "", "ticket": "T902", "nights": 2},
        {"kind": "collected", "customer": "Cy Test", "customer_id": "", "ticket": "T903", "paid": 40, "reaction": "Happy with the repair."},
        {"kind": "notice", "customer": "FixFindr", "customer_id": "", "ticket": "", "reaction": "FixFindr removed 3 reviews."}]}
    night.visits_pending = true
    await scene(Nav.COUNTER)
    counter = current_scene
    check(counter.visiting() and counter.arrived == 2 and counter.slip.visible and counter.slip_title.text.contains("2 customers came in") and counter.slip_text.text.contains("Ana Test"), "the shutter goes up: the board counts who came in and the first one speaks")
    check(counter.hotspot("BackDoor").disabled and counter.hotspot("Phone").disabled and not counter.hotspot("CustomerWindow").disabled, "the shop waits while customers are at the counter")
    await press(counter.next_button)
    check(counter.slip_text.text.contains("Cy Test") and counter.next_button.text.contains("open up"), "next customer, the last one")
    await press(counter.next_button)
    check(not counter.visiting() and not night.visits_pending and not counter.slip.visible and not counter.hotspot("BackDoor").disabled, "after the last customer the counter opens for the night")
    check(counter.message.text.contains("Still waiting for their PCs: Bo Test") and counter.message.text.contains("Your phone buzzes"), "who is still waiting and the review site's notice are told after the visits")

    # ---- 0.55.0 (D162): storage under the counter window ----
    var layout_path: String = "user://nightshift_storage.json"
    var had_layout: bool = FileAccess.file_exists(layout_path)
    var old_layout: PackedByteArray = FileAccess.get_file_as_bytes(layout_path) if had_layout else PackedByteArray()
    var sources: Dictionary = StorageSources.collect(gs)
    var m := StorageModel.new()
    m.setup(sources, {})
    check(not m.unit(StorageData.COUNTER_ID).is_empty() and m.units.all(func(u: Dictionary) -> bool: return u["id"] != StorageData.COUNTER_ID) and StorageData.COUNTER["size"] == Vector2i(20, 10), "the under-counter grid is 20 x 10 and is not stock-room furniture")
    check(m.in_unit(StorageData.COUNTER_ID).is_empty(), "nothing is put under the counter on its own")
    var keep: String = str(m.items.keys()[0])
    check(m.place_first(keep, StorageData.COUNTER_ID) and keep in m.in_unit(StorageData.COUNTER_ID), "anything can be kept under the counter")
    m.arrange()
    check(keep in m.in_unit(StorageData.COUNTER_ID), "auto-packing the stock room leaves what is under the counter alone")
    var reloaded := StorageModel.new()
    reloaded.setup(sources, m.snapshot())
    check(keep in reloaded.in_unit(StorageData.COUNTER_ID), "it stays under the counter across saves")
    check(m.to_room(keep) and not keep in m.in_unit(StorageData.COUNTER_ID), "and can go back to the stock room")
    await scene(Nav.COUNTER)
    check(current_scene.hotspot("UnderCounter") != null and not current_scene.hotspot("UnderCounter").closed_at_dawn, "the counter has storage under its window, usable at any hour")
    await press(current_scene.hotspot("UnderCounter"))
    await process_frame
    var under: Node = current_scene
    check(under.scene_file_path == Nav.UNDER_COUNTER and under.get_node("BackButton").text == "← Counter", "it opens under the counter, with the way back")
    var rows: int = under.list_box.get_child_count()
    check(rows == under.model.items.size() - under.here().size(), "the stock room's things are listed to bring over")
    await press(under.list_box.get_child(0))
    await process_frame
    var brought: String = under.selected
    check(brought != "" and brought in under.here(), "clicking one brings it under the counter")
    var saved_model := StorageModel.new()
    saved_model.setup(StorageSources.collect(gs), StorageStore.new().read())
    check(brought in saved_model.in_unit(StorageData.COUNTER_ID), "the choice is saved")
    var from: Vector2 = under.item_rect(brought).position + Vector2(5, 5)
    # B54: never preload a view script from a test (autoloads such as GameState do not exist yet when the
    # test script compiles); read the constant from the running scene's script instead.
    var grid: Rect2 = under.get_script().get_script_constant_map()["GRID"]
    # 0.57.3 (ART-10, approved 25 November 2026): 44 px cells, the size the storage pictures were made for.
    var consts: Dictionary = under.get_script().get_script_constant_map()
    check(consts["CELL"] == 44 and grid == Rect2(40, 140, 880, 440) and grid.size == Vector2(StorageData.COUNTER["size"]) * 44, "the under-counter grid is still 20 x 10, now in 44 px cells")
    var pictured: int = 0
    var fits: bool = true
    for uid: Variant in under.model.items:
        if under.art_name(under.model.items[uid]) == "": continue
        pictured += 1
        for turn in range(4):
            if under.item_texture(str(uid), turn) == null: fits = false
    check(pictured >= 6 and fits, "PCs, tools and parts with art show their picture in every quarter turn, exactly fitting their footprint")
    var all_art: bool = true
    for name: String in ["pc_tower", "pc_compact", "gpu", "ram", "cpu", "cooler", "psu", "storage_hdd", "storage_ssd", "vacuum", "brush", "pick", "cloth", "syringe"]:
        for turn in range(4):
            if RoomArt.storage_item(name, turn) == null: all_art = false
    check(all_art, "all 56 approved storage pictures are present (14 items x 4 turns)")
    var to: Vector2 = grid.end - under.item_rect(brought).size
    for step: Array in [[true, from], [false, to]]:
        var drag := InputEventMouseButton.new()
        drag.button_index = MOUSE_BUTTON_LEFT
        drag.pressed = step[0]
        drag.position = step[1]
        drag.global_position = step[1]
        root.push_input(drag, true)
        await process_frame
    check(under.model.placements[brought]["cell"] != Vector2i.ZERO and brought in under.here(), "dragging rearranges it on the grid")
    await press(under.send_button)
    await process_frame
    check(not brought in under.here(), "Back to the stock room sends it back")
    await press(under.get_node("BackButton"))
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "← Counter returns to the counter")
    if had_layout:
        var f := FileAccess.open(layout_path, FileAccess.WRITE)
        f.store_buffer(old_layout)
        f.close()
    else:
        _remove_save_files(layout_path)

    # ---- retired screens land at the counter ----
    await scene("res://scenes/activities.tscn")
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "an old link to the Activities hub lands at the counter")
    await scene("res://scenes/morning.tscn")
    await process_frame
    check(current_scene.scene_file_path == Nav.COUNTER, "an old link to the morning report lands at the counter")

    for path: String in [manifest, prefs]: _remove_save_files(path)
    restore_save(gs)
    finish("Rooms")
