# Integration contract for approved Batch A source bytes, real hover/confirmation states and capacity.
extends "res://tools/test_support.gd"
const Nav = preload("res://scripts/night/night_navigation.gd")
const Art = preload("res://scripts/rooms/counter_art.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func scene(path: String) -> void:
    change_scene_to_file(path)
    for f in range(3): await process_frame


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
    for f in range(3): await process_frame


func hover(button: Button) -> void:
    var event := InputEventMouseMotion.new()
    event.position = button.get_global_rect().get_center()
    event.global_position = event.position
    root.push_input(event, true)
    for f in range(3): await process_frame


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "counter_art_test.json")
    var manifest: String = gs.save_path + ".night.json"
    var preferences: String = gs.save_path + ".navigation.json"
    for path: String in [manifest, preferences]: _remove_save_files(path)
    gs.new_game(false)
    check(night.start(gs, true), "existing first-day intake starts")
    await scene(Nav.COUNTER)
    var counter: Node = current_scene
    var art: RefCounted = counter.counter_art
    check(art.available() and art.textures.size() == 14, "all fourteen approved source textures load")
    var approved: Variant = JSON.parse_string(FileAccess.get_file_as_string(Art.folder() + "manifest.json"))
    var exact: bool = approved is Dictionary and approved.get("files", []).size() == 14
    if exact:
        for file: Dictionary in approved["files"]:
            if FileAccess.get_sha256(Art.folder() + str(file["file"])) != str(file["sha256"]): exact = false
    check(exact, "every installed raster matches its human-approved revision-02 hash")
    check(not counter.placeholders and counter.room_layer.morning and counter.counter_layer.morning, "intake uses the morning exterior with the real layered room")
    var customer: TextureRect = counter.get_node("CustomerPortrait")
    var pc: TextureRect = counter.get_node("CustomerPC")
    check(customer.position + customer.size == Vector2(800, 488) and pc.position + pc.size == Vector2(1094, 550), "Batch B sprites follow the shared customer/PC anchors without resizing their pixels")
    check(customer.z_index < counter.counter_layer.z_index and pc.z_index > counter.counter_layer.z_index and counter.get_node("Hotspots").z_index > counter.counter_layer.z_index, "counter occludes the customer while the separate PC and clipboard remain above it")
    check(not counter.slip.get_rect().intersects(customer.get_rect()) and not counter.slip.get_rect().intersects(pc.get_rect()), "the intake paper leaves the customer and their PC visible")
    await hover(counter.hotspot("FrontDoor"))
    check(not counter.room_layer.front_open, "gated intake does not visually open the disabled front door")
    var glass: bool = true
    for name: String in ["front-door-closed-v2.png", "front-door-open-v2.png"]:
        var image: Image = art.textures["front_closed" if "closed" in name else "front_open"].get_image()
        if image == null or image.get_pixel(image.get_width() / 2, image.get_height() / 2).a != 0: glass = false
    check(glass, "both front-door panes have genuine transparent centers")
    await press(counter.next_button)
    await press(counter.next_button)
    check(not counter.visiting() and not counter.room_layer.morning and not counter.counter_layer.morning, "finishing intake switches the same room to dusk")
    var money: int = gs.money
    var minutes: float = gs.night_minutes
    await hover(counter.hotspot("FrontDoor"))
    check(counter.room_layer.front_open, "native hover selects the open front-door endpoint")
    await hover(counter.hotspot("BackDoor"))
    check(counter.room_layer.workshop_open and not counter.room_layer.front_open, "native hover moves to the workshop door and closes the front endpoint")
    await press(counter.hotspot("Shutter"))
    check(counter.end_dialog.visible and counter.room_layer.shutter_down, "the existing close-night confirmation previews the down shutter")
    counter.end_dialog.hide()
    await process_frame
    check(not counter.room_layer.shutter_down and gs.money == money and gs.night_minutes == minutes, "canceling the preview restores the shutter without ending or charging the night")
    for name: String in ["WallBoard", "Till", "Phone"]:
        check(counter.hotspot(name).ui_label and not counter.hotspot(name).disabled, "%s remains discoverable without painting another tabletop object" % name)
    # 0.57.7 (user): no storage button; hovering the bottom edge pulls the storage up over the counter.
    await hover(counter.hotspot("UnderCounter"))
    for f in range(30): await process_frame
    check(counter.storage_open and counter.storage_drawer.visible and is_equal_approx(counter.storage_drawer.position.y, 0.0) and current_scene == counter, "hovering the bottom edge pulls the same storage up over the counter")
    var under: Node = counter.storage_drawer
    var constants: Dictionary = under.get_script().get_script_constant_map()
    var grid: Rect2 = constants["GRID"]
    check(constants["CELL"] == 44 and grid.size == Vector2(880, 440) and under.environment.available(), "all 200 square cells retain Batch B's 44-pixel item scale under the approved storage art")
    var rim: Image = under.environment.textures["rim"].get_image()
    var clear: bool = rim != null
    if clear:
        for x in range(21):
            for y in range(11):
                var pixel := Vector2i(Art.STORAGE_INNER.position + Vector2(x * 71, y * 50))
                if rim.get_pixelv(pixel).a > 1.0 / 255.0 + 0.00001: clear = false
    check(clear, "the rim clears the complete 20-by-10 viewport, including outer cell boundaries")
    var mapped: Rect2 = Art.storage_rect(under.environment.textures["rim"], grid)
    var ratio: Vector2 = grid.size / Art.STORAGE_INNER.size
    check((mapped.position + Art.STORAGE_INNER.position * ratio).is_equal_approx(grid.position), "decorative source mapping starts exactly at the existing grid origin")
    var up := InputEventMouseMotion.new()
    up.position = Vector2(640, 20)
    up.global_position = up.position
    root.push_input(up, true)
    for f in range(30): await process_frame
    check(not counter.storage_open and not counter.storage_drawer.visible and current_scene == counter and not counter.visiting(), "moving the mouse up slides the storage away, back at the same counter")
    restore_save(gs)
    for path: String in [manifest, preferences]: _remove_save_files(path)
    finish("Counter art")
