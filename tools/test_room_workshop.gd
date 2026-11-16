# Input-route regressions: physical PC selection, old furniture sequence, consistent night exit.
extends "res://tools/test_support.gd"
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")
func _initialize() -> void:
    call_deferred("run_checks")
func mouse(at: Vector2,down: bool) -> void:
    var e := InputEventMouseButton.new()
    e.position = at
    e.global_position = at
    e.button_index = MOUSE_BUTTON_LEFT
    e.pressed = down
    root.push_input(e,true)
    await process_frame
func press(button: Button) -> void:
    var viewport: Viewport = button.get_viewport()
    var at: Vector2 = button.get_global_rect().get_center()
    if viewport is Window and viewport != root and viewport.is_embedded():
        at += Vector2(viewport.position)
        viewport = root
    for down: bool in [true,false]:
        var e := InputEventMouseButton.new()
        e.position = at
        e.global_position = at
        e.button_index = MOUSE_BUTTON_LEFT
        e.pressed = down
        viewport.push_input(e,true)
        await process_frame
    await process_frame
func button(view: Node,text: String) -> Button:
    for child: Node in view.get_children():
        if child is Button and child.text == text: return child
    return null
func scene(path: String) -> void:
    change_scene_to_file(path)
    await process_frame
    await process_frame
func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs,"room_workshop_test.json")
    var manifest: String = gs.save_path+".night.json"
    var layout: String = "user://room_workshop_layout_test.json"
    _remove_save_files(manifest)
    _remove_save_files(layout)
    gs.new_game(false)
    night.start(gs)
    var first: String = night.active_id
    var other: String = night.tickets[1]["id"]
    gs.job["dust"]["cooler"] = 0.37
    night.checkpoint(gs)
    var cash: int = gs.money
    var stock: Array = gs.player_inventory.duplicate(true)
    var room: Node = load("res://scripts/storage/storage_view.gd").new()
    room.store.path = layout
    root.add_child(room)
    current_scene = room
    await process_frame
    check(not room.get_children().any(func(n: Node) -> bool: return n is OptionButton or (n is Button and n.text.contains("Steel rack"))),"no rack selector buttons or PC dropdown exist in room")
    var tool: String = "tool:kit:brush"
    var before: Dictionary = room.model.snapshot()
    await mouse(room.item_rect(tool).get_center(),true)
    await mouse(room.WORKSHOP_SLOT.get_center(),false)
    check(current_scene == room and night.active_id == first and room.model.snapshot() == before and room.model.held == "","part/tool slot drop quietly restores custody and never selects a PC")
    room.store.read_only = true
    var uid: String = ""
    for id: String in room.model.items:
        if room.model.items[id]["category"] == "pc" and room.model.items[id]["source_uid"] == other: uid = id
    check(not room._choose_workshop_pc(uid) and night.active_id == first,"protected layout cannot change workbench selection")
    room.store.read_only = false
    check(not room._choose_workshop_pc("pc:unknown") and night.active_id == first,"stale/fabricated PC is rejected")
    # Repeat the video's sort/save/add/title-selection sequence using native control events.
    await press(room.arrange_toggle)
    await press(button(room,"Auto-pack shelves"))
    await press(button(room,"+ Add furniture"))
    await press(room.choice_buttons[0])
    await press(button(room,"+ Add furniture"))
    await press(room.choice_buttons[2])
    room._fit_room()
    var ids: Array = room.get_children().map(func(n: Node) -> int: return n.get_instance_id())
    for i in range(room.model.units.size()):
        var at: Vector2 = room.header_rect(i).get_center()
        await mouse(at,true)
        await mouse(at,false)
    check(room.get_children().map(func(n: Node) -> int: return n.get_instance_id()) == ids,"real furniture header clicks preserve every control; no self-freeing signal emitter")
    check(room.model.units.size() == 3,"multiple additions remain physical room furniture")
    room._set_arranging(false)
    room._fit_used()
    var origin: Rect2 = room.item_rect(uid)
    before = room.model.snapshot()
    await mouse(origin.get_center(),true)
    check(room.model.held == uid,"native press picks the other actual customer PC")
    await mouse(room.WORKSHOP_SLOT.get_center(),false)
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/night_bench.tscn" and night.active_id == other and gs.job["id"] == other,"native drag into slot opens workshop with correct ticket")
    check(gs.money == cash and gs.player_inventory == stock and Sources.collect(gs).values().filter(func(item: Dictionary) -> bool: return item["category"] == "pc").size() == 2,"selection neither duplicates PCs nor consumes stock or money")
    check(not current_scene.get_children().any(func(n: Node) -> bool: return n is OptionButton),"service hub has no alternate PC-selection dropdown")
    check(current_scene.get_node("PCIdentity").text.contains(other),"workbench header identifies the active ticket")
    var hub: Node = current_scene
    DirAccess.make_dir_absolute(manifest+".tmp")
    await press(hub.get_node("ActivitiesButton"))
    check(current_scene == hub and hub.status_label.text.contains("could not be saved"),"failed checkpoint keeps player on current screen with a visible error")
    DirAccess.remove_absolute(manifest+".tmp")
    # Same top-right position and actual return route on every playable night screen.
    for path: String in ["res://scenes/night_bench.tscn","res://scenes/night_hardware.tscn","res://scenes/software.tscn","res://scenes/night_salvage.tscn","res://scenes/storage.tscn"]:
        await scene(path)
        var exit: Button = current_scene.get_node_or_null("ActivitiesButton")
        check(exit != null and exit.get_global_rect() == Nav.RECT,"Activities has common top-right rectangle in "+path)
        var exits: Array = current_scene.get_children().filter(func(n: Node) -> bool: return n is Button and n.text == "Activities")
        check(exits.size() == 1,"exactly one Activities control in "+path)
        await press(exit)
        await process_frame
        check(current_scene.scene_file_path == Nav.ACTIVITIES,"native Activities click returns to night hub from "+path)
    check(night.switch_pc(gs,first) and is_equal_approx(gs.job["dust"]["cooler"],0.37),"first PC progress survives selection, all exits and reselect")
    check(night.switch_pc(gs,other) and gs.load_game() and gs.job["id"] == other,"chosen workbench ticket survives save/reload")
    await press(button(current_scene,"WORKSHOP ROOM\nDrag a PC into the workshop slot"))
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/storage.tscn","activity Workshop now opens room selection rather than old dropdown")
    current_scene.free()
    _remove_save_files(layout)
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Room workshop")
