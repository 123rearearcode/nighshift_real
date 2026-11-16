# End-to-end menu paths: mode gates, workbench tabs, safe exits, pause/Continue, UI preference safety.
extends "res://tools/test_support.gd"
const Nav = preload("res://scripts/night/night_navigation.gd")
const Memory = preload("res://scripts/night/navigation_state.gd")
const SafeStore = preload("res://scripts/state/save_store.gd")
func _initialize() -> void: call_deferred("run_checks")
func press(button: Button) -> void:
    var at: Vector2 = button.get_global_rect().get_center()
    for down: bool in [true,false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = at
        event.global_position = at
        root.push_input(event,true)
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
    use_test_save(gs,"menu_navigation_test.json")
    var manifest: String = gs.save_path+".night.json"
    var prefs: String = gs.save_path+".navigation.json"
    var layout: String = "user://menu_navigation_layout.json"
    for path: String in [manifest,prefs,layout]: _remove_save_files(path)
    gs.new_game(false)
    night.start(gs)
    var ticket: String = gs.job["id"]
    var money: int = gs.money
    var stock: Array = gs.player_inventory.duplicate(true)
    var room: Node = load("res://scripts/storage/storage_view.gd").new()
    room.store.path = layout
    root.add_child(room)
    current_scene = room
    await process_frame
    check(not room.arranging and room.edit_buttons.all(func(b: Button) -> bool: return not b.visible),"normal room hides furniture edit controls")
    check(button(room,"Save layout") == null and button(room,"Refresh contents") == null,"routine save and refresh are absent")
    var before: Dictionary = room.model.snapshot()
    var header: Vector2 = room.header_rect(0).get_center()
    click(room,MOUSE_BUTTON_LEFT,true,header)
    check(room.held_furniture == "" and room.model.snapshot() == before,"normal mode cannot accidentally move furniture")
    click(room,MOUSE_BUTTON_LEFT,false,header)
    await press(room.arrange_toggle)
    check(room.arranging and room.edit_buttons.all(func(b: Button) -> bool: return b.visible),"Arrange room reveals add/remove/packing actions")
    await press(button(room,"+ Add furniture"))
    # Popup child has a separate embedded viewport; real controls tested in test_storage.
    room._add_unit("rack")
    check(room.model.units.size() == 2 and room.store.read().get("units",[]).size() == 2,"furniture edits autosave without Save layout button")
    check(not room._choose_workshop_pc(room._workshop_uid()),"arrange mode does not select a PC while editing furniture")
    DirAccess.make_dir_absolute(layout+".tmp")
    room._save()
    check(room.retry_save.visible and not room._navigate(Nav.ACTIVITIES),"failed layout save reveals retry and blocks losing layout on exit")
    DirAccess.remove_absolute(layout+".tmp")
    await press(room.retry_save)
    check(not room.retry_save.visible and room.layout_saved,"native Retry restores autosave status")
    await press(room.arrange_toggle)
    check(not room.arranging and room.saved_label.text == "Layout saved","Done arranging returns to uncluttered room")
    await press(room.workshop_button)
    await process_frame
    check(current_scene.scene_file_path == Nav.REPAIR,"Resume work opens bench directly with no service menu")
    var repair: Node = current_scene
    repair.set_physics_process(false)
    repair._select_stage(repair.STAGE_PASTE)
    repair.paste.material = "super"
    repair.paste.deposit(25,25,30)
    var field: PackedFloat32Array = repair.paste.h.duplicate()
    check(not repair.title_label.visible and repair.get_node("PCIdentity").text.contains(ticket),"one shared header identifies the PC instead of overlapping old titles")
    var controls: Array = repair.get_children().filter(func(n: Node) -> bool: return n is Button and n.visible)
    var separated: bool = true
    for i in range(controls.size()):
        for j in range(i+1,controls.size()): separated = separated and not controls[i].get_global_rect().intersects(controls[j].get_global_rect())
    check(separated,"shared header navigation and service action buttons do not overlap")
    await press(repair.get_node("HardwareTab"))
    await process_frame
    check(current_scene.scene_file_path == Nav.HARDWARE and gs.job["id"] == ticket,"Hardware tab changes view of the same selected PC")
    var hardware: Node = current_scene
    check(hardware._title_text().contains("own PC"),"hardware is the connected customer PC, not a relabeled shop sandbox")
    await press(hardware.get_node("MonitorTab"))
    await process_frame
    check(current_scene.scene_file_path == Nav.MONITOR and gs.job["id"] == ticket,"Monitor tab keeps ticket identity")
    var monitor: Node = current_scene
    monitor._run_timed("Navigation check",30,func() -> void: pass)
    await press(monitor.get_node("RepairTab"))
    check(current_scene == monitor and monitor.message.text.contains("test is running"),"running monitor tests must finish/cancel before switching views")
    var pause: Node = monitor.get_node("PauseMenu")
    await press(monitor.get_node("PauseButton"))
    var time: float = monitor.busy_left
    await process_frame
    await process_frame
    check(paused and pause.shade.visible and monitor.busy_left == time,"Pause freezes a running test, not merely an overlay")
    pause._title()
    check(current_scene == monitor and paused,"title exit cannot bypass an in-progress test")
    var settings_path: String = gs.settings_path
    var volume: float = gs.sound_volume
    gs.settings_path = "user://menu_navigation_settings.json"
    pause._settings()
    pause.slider.value = 40
    check(is_equal_approx(gs.sound_volume,0.4),"pause Settings controls existing sound setting")
    pause.settings.hide()
    pause.close()
    check(not paused,"Resume unpauses the game")
    monitor._power() # existing cancel path; no synthetic timed result is awarded
    pause.open()
    var title_button: Button
    for node: Node in pause.find_children("*","Button",true,false):
        if node.text == "Title screen": title_button = node
    await press(title_button)
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/start.tscn" and not paused,"title screen is reached through Pause and cannot remain paused")
    check(current_scene.load_button.text == "Continue","title offers Continue rather than redundant single-save Load menu")
    await press(current_scene.load_button)
    await process_frame
    check(current_scene.scene_file_path == Nav.MONITOR and gs.job["id"] == ticket,"Continue restores last activity and selected PC")
    await press(current_scene.get_node("RepairTab"))
    await process_frame
    check(current_scene.stage == current_scene.STAGE_PASTE and current_scene.paste.h == field,"returning to Repair restores its thermal subview and physical paste")
    var back: Button = current_scene.get_node("BackButton")
    check(back.text == "← Room" and current_scene.get_node("ActivitiesButton").get_global_rect() == Nav.RECT,"back destination and global Activities have distinct consistent roles")
    await press(back)
    await process_frame
    check(current_scene.scene_file_path == Nav.ROOM and not current_scene.arranging,"Back returns directly to normal room, never an intermediate menu")
    check(gs.money == money and gs.player_inventory == stock,"menu paths do not charge, restock or finish repairs")
    # UI preferences cannot execute arbitrary scene paths or overwrite future formats.
    var job: Dictionary = gs.job.duplicate(true)
    SafeStore.write(prefs,{"run":night.run_id,"garbage":true})
    check(Memory.enter(gs,Nav.ROOM) and Memory.resume_path(gs) == Nav.ROOM,"missing UI schema fields safely rebuild preferences")
    SafeStore.write(prefs,{"version":1,"run":night.run_id,"scene":"res:"+"//unknown.tscn"})
    check(Memory.resume_path(gs) == Nav.ACTIVITIES,"unknown resume scenes safely fall back to Activities")
    SafeStore.write(prefs,{"version":999,"run":night.run_id,"sentinel":"keep"})
    check(not Memory.enter(gs,Nav.REPAIR) and SafeStore.read(prefs)["sentinel"] == "keep","newer UI preference format is never overwritten")
    check(gs.job == job,"UI preference loading never changes repair state")
    for path: String in [prefs]: _remove_save_files(path)
    Memory.enter(gs,Nav.MONITOR)
    gs.new_game(false)
    night.start(gs)
    check(Memory.resume_path(gs) == Nav.ACTIVITIES,"new run cannot resume a previous run's PC/view")
    await scene("res://scenes/night_workshop.tscn")
    await process_frame
    check(current_scene.scene_file_path == Nav.REPAIR,"legacy workshop links redirect directly to the bench")
    current_scene.free()
    gs.set_sound_volume(volume)
    _remove_save_files(gs.settings_path)
    gs.settings_path = settings_path
    for path: String in [manifest,prefs,layout]: _remove_save_files(path)
    restore_save(gs)
    finish("Menu navigation")
