# 0.58.9 (D181): dialogue that unrolls. User, 27 November 2026: "when a customer comes in, you should be able to
# click/space for dialogue to unroll. so dialogue needs to be work in that way, as the game will be story
# driven anyhow." The box on its own (typing, click/Space/Enter, speakers, finishing), then the counter: the
# first customer talks before the ticket slip shows, and talking never reveals hidden faults.
extends "res://tools/test_support.gd"
const Box = preload("res://scripts/ui/dialogue_box.gd")
const MorningText = preload("res://scripts/night/morning_text.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func click_at(at: Vector2) -> void:
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = at
        event.global_position = at
        root.push_input(event, true)
        await process_frame


func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    root.push_input(event, true)
    await process_frame


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")

    # ---- the box on its own ----
    var box: Control = Box.new()
    root.add_child(box)
    await process_frame
    var done: Array = [0]
    box.finished.connect(func() -> void: done[0] += 1)
    box.play("Mara V.", ["Good morning.", {"speaker": "You", "text": "Morning! What can I do for you?"}, "", "It overheats."])
    await process_frame
    check(box.active and box.visible and box.index == 0 and box.typing() and box.text_label.visible_characters < "Good morning.".length(), "a line starts typing out letter by letter")
    var started: int = Time.get_ticks_msec()
    while box.typing() and Time.get_ticks_msec() - started < 3000: await process_frame
    check(not box.typing() and box.text_label.visible_characters == -1 and box.hint.text.contains("Space"), "left alone, the whole line appears and the box waits")
    await click_at(Vector2(640, 400))
    check(box.index == 1 and box.current_speaker() == "You" and box.name_label.text == "You", "a click goes to the next line, with its own speaker")
    await key(KEY_SPACE)
    check(box.index == 1 and not box.typing() and box.text_label.visible_characters == -1, "Space while typing shows the whole line at once")
    await key(KEY_ENTER)
    check(box.index == 2 and box.current_text() == "It overheats." and box.current_speaker() == "Mara V.", "Enter goes on; empty lines are skipped; the first speaker is back")
    await key(KEY_SPACE)
    await key(KEY_SPACE)
    check(not box.active and not box.visible and done[0] == 1, "after the last line the box closes and says it is finished, once")
    await key(KEY_SPACE)
    check(done[0] == 1, "a closed box ignores further keys")
    box.play("Relu D.", ["One.", "Two."])
    box.skip_all()
    check(not box.active and done[0] == 2, "a scene can close it at once")
    box.play("Nobody", [])
    check(not box.active and done[0] == 3, "nothing to say closes straight away")
    check(box.position.y >= 60.0, "the top bar (Pause, the way back) stays clickable while someone talks")
    box.queue_free()
    await process_frame

    # ---- what customers say ----
    var mara: Dictionary = gs.person("t001_mara")
    var said: Array = MorningText.opening_lines({"complaint": mara["complaint"]}, mara)
    check(said.size() == 4 and said[0] == mara["greeting"] and said[1] == mara["complaint"] and str(said[2]).begins_with("I use it for office work") and said[3] == mara["patience_line"], "Mara greets, says what is wrong, what she uses it for and when she needs it")
    var plain: Array = MorningText.opening_lines({"complaint": "It is slow."}, {"uses": "Games."})
    check(plain == ["Good morning. Is this the computer repair shop?", "It is slow.", "I use it for games."], "a customer without written lines gets plain ones")
    check(MorningText.visit_lines({"kind": "collected", "reaction": "Furious: the PC does not even start."}, {})[0].contains("doesn't even turn on") and MorningText.visit_lines({"kind": "comeback"}, {})[0].contains("acting up"), "collections and comebacks say how it went")

    # ---- at the counter ----
    use_test_save(gs, "dialogue_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    gs.new_game(false)
    check(night.start(gs, true), "the first-day intake starts")
    change_scene_to_file(Nav.COUNTER)
    for f in range(3): await process_frame
    var counter: Node = current_scene
    check(counter.visiting() and counter.dialogue.active and not counter.slip.visible and counter.dialogue.name_label.text == "Mara V.", "Mara comes in and talks first; the ticket slip waits")
    var infection: String = ""
    for id: String in gs.opening_customers:
        infection += str(night.ticket_job(gs, id).get("infection", ""))
    var all_said: String = ""
    for line: Variant in counter.dialogue.lines: all_said += Box._line_text(line) + " "
    check(not all_said.to_lower().contains("adware") and not all_said.to_lower().contains("miner") and not all_said.contains("$"), "what she says gives away no hidden fault and no money")
    var minutes: float = gs.night_minutes
    await click_at(counter.hotspot("BackDoor").get_global_rect().get_center())
    check(current_scene == counter and counter.dialogue.active and gs.night_minutes == minutes, "clicking the room while she talks only moves the talk on")
    var guard: int = 0
    while counter.dialogue.active and guard < 40:
        await key(KEY_SPACE)
        guard += 1
    check(not counter.dialogue.active and counter.slip.visible and counter.slip_text.text.contains("Mara V.") and counter.next_button.visible, "Space through her lines, then the ticket slip shows with Accept")
    counter.next_button.pressed.emit()
    await process_frame
    check(counter.dialogue.active and counter.dialogue.name_label.text == "Relu D." and not counter.slip.visible, "accepting her brings the next customer, who talks first too")
    counter.dialogue.skip_all()
    await process_frame
    check(counter.slip.visible and counter.slip_text.text.contains("Relu D."), "his slip follows his lines")
    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Dialogue")
