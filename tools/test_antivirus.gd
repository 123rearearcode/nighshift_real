# The calm approved loop, native SEND/Enter and the real monitor -> save -> pickup journey.
extends "res://tools/test_support.gd"
const Round = preload("res://scripts/rules/antivirus_round.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")
func _initialize() -> void: call_deferred("run_checks")

func press(button: Button) -> void:
    for down: bool in [true,false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = button.get_global_rect().get_center()
        event.global_position = event.position
        root.push_input(event,true)
        await process_frame
    await process_frame

func key(code: Key, unicode_value: int = 0) -> void:
    for down: bool in [true,false]:
        var event := InputEventKey.new()
        event.keycode = code
        event.pressed = down
        event.unicode = unicode_value
        root.push_input(event,true)
        await process_frame

func run_checks() -> void:
    var a := Round.new(Malware.ADWARE)
    var ids: Array = a.processes.map(func(p: Dictionary) -> String: return str(p["id"]))
    check(a.processes.size() == 6 and a.remaining() == 2 and a.advert,"adware round is actual adware plus its watchdog, not a fabricated miner")
    a.close_advert()
    a.step(11.9)
    check(not a.advert,"adverts are sparse rather than a cascade")
    a.step(0.2)
    check(a.advert,"one advert returns after twelve seconds")
    a.step(36.0)
    check(a.advert and a.processes.size() == 6,"unclosed adverts remain one bounded window and rows never spawn")
    a.end_task("source")
    a.step(24.0)
    check(not a.advert and not a.active("source"),"ending the adware parent stops all its adverts")
    check(a.processes.map(func(p: Dictionary) -> String: return str(p["id"])) == ids,"ending processes never removes/reorders rows")
    a.end_task("watchdog")
    a.step(5.0)
    check(a.active("watchdog") and a.returns == 1,"watchdog returns to the same row if auto-start remains")
    a.end_task("watchdog")
    a.verify()
    check(a.outcome == "running" and a.active("watchdog"),"reboot exposes forgotten persistence rather than certifying a temporary stop")
    a.disable_startup()
    a.end_task("watchdog")
    a.verify()
    check(a.outcome == "won" and a.remaining() == 0,"ending the source and watchdog plus removing persistence passes verification")
    var frozen_report: String = a.report()
    a.verify()
    a.end_task("invoice")
    check(a.report() == frozen_report,"completed round cannot be resolved twice")
    var m := Round.new(Malware.MINER)
    check(not m.advert and m.label("source") == "CoolCoin.exe","miner does not invent adware symptoms")
    m.step(8.1)
    check(m.label("source") == "SystemHeater.exe" and m.processes.size() == 6,"only the miner changes its alias slowly in its fixed row")
    m.end_task("source")
    var elapsed: float = m.elapsed
    var load_before: float = m.overload
    m.step(600.0)
    check(m.elapsed == elapsed and m.overload == load_before and not m.pending.is_empty(),"typing pauses overload, aliases and respawns indefinitely; no countdown")
    check(not m.submit_word("wrong") and m.active("source") and m.status.contains("ACCESS DENIED"),"wrong word has visible feedback and permits retry")
    check(m.submit_word(" banana ") and not m.active("source"),"word matching accepts normalized uppercase/lowercase and surrounding spaces")
    check(not m.submit_word("BANANA"),"duplicate SEND cannot end or record a task twice")
    m.end_task("invoice")
    check(m.outcome == "running" and m.process("invoice")["ended"],"closing an ordinary program is recoverable")
    m.end_task("desktop")
    check(m.outcome == "crashed","only a critical system process blue-screens the attempt")
    var invalid := Round.new("unknown")
    check(invalid.outcome == "invalid" and invalid.processes.is_empty(),"clean/unknown infections cannot fabricate a cleanup success")
    var aborted := Round.new(Malware.ADWARE)
    aborted.abort()
    aborted.verify()
    check(aborted.outcome == "aborted","stopping is not verified removal")
    var timed_out := Round.new(Malware.ADWARE)
    timed_out.step(600)
    check(timed_out.outcome == "overloaded","gentle overload still supplies a recoverable failure state")

    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs,"antivirus_test.json")
    for suffix: String in [".night.json",".navigation.json"]: _remove_save_files(gs.save_path+suffix)
    gs.new_game(false)
    check(night.start(gs),"real night starts")
    var first: String = night.active_id
    var second: String = night.tickets[1]["id"]
    check(night.switch_pc(gs,second),"select the actual infected customer's PC")
    gs.job["infection"] = Malware.MINER
    gs.job["broken_parts"] = []
    gs.job["removed_parts"] = []
    gs.job["paste_grade"] = "GOOD"
    gs.job["paste_done"] = true
    gs.set_pc_powered(true)
    var cash: int = gs.money
    var stock: Array = gs.player_inventory.duplicate(true)
    var view: Node = load("res://scenes/software.tscn").instantiate()
    root.add_child(view)
    current_scene = view
    await process_frame
    view._remove()
    check(view.antivirus_panel == null,"cleanup requires the deliberate scan first")
    await press(view.scan_button)
    check(view.threat_found and not view.remove_button.disabled,"native scan reveals the real infection and offers cleanup")
    var start: int = gs.night_minutes
    await press(view.remove_button)
    var panel: Node = view.antivirus_panel
    panel.set_process(false)
    check(panel != null and panel.model.strain == Malware.MINER and Malware.infected(gs.job),"Remove threat opens the real minigame and cannot instantly cure")
    check(gs.night_minutes == start+Round.COST_MINUTES,"attempt costs its night minutes once on entry")
    check(not view._navigate(Nav.REPAIR) and view.boot_button.disabled,"active cleanup blocks navigation and competing monitor tests")
    var positions: Dictionary = {}
    for id: String in panel.row_buttons: positions[id] = panel.row_buttons[id].position
    await press(panel.row_end["source"])
    check(panel.hack.visible and panel.word_input.has_focus(),"native protected-process button opens and focuses the typing prompt")
    await key(KEY_B,98)
    await key(KEY_A,97)
    check(panel.word_input.text == "BA","real lowercase key input immediately appears uppercase")
    var word: String = panel.word_input.text
    panel._process(120)
    check(panel.word_input.text == word and panel.model.elapsed < 5,"time updates never recreate input or consume a typing countdown")
    panel._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    check(not panel.model.paused,"focus loss during the already-frozen prompt cannot trap SEND behind a disabled Resume button")
    await press(panel.send_button)
    check(panel.hack.visible and panel.hack_status.text.contains("ACCESS DENIED"),"native SEND with a wrong word keeps the prompt and shows the error")
    panel.word_input.text = "BANANA"
    await press(panel.send_button)
    check(not panel.hack.visible and not panel.model.active("source") and Malware.infected(gs.job),"real SEND click works, closes prompt and stops the source without premature cure")
    var saved_rows: Array = panel.row_buttons.keys()
    panel._process(15)
    check(panel.row_buttons.keys() == saved_rows and positions.keys().all(func(id: String) -> bool: return panel.row_buttons[id].position == positions[id]),"all native row positions/identities survive process ending and clock updates")
    var pause: Node = view.get_node("PauseMenu")
    await press(view.get_node("PauseButton"))
    var time_before: float = panel.model.elapsed
    await process_frame
    check(paused and panel.model.elapsed == time_before,"shared Pause freezes the real cleanup")
    pause.close()
    await press(panel.startup_button)
    await press(panel.row_end["watchdog"])
    await press(panel.verify_button)
    check(panel.model.outcome == "won" and not Malware.infected(gs.job),"native full cleanup cures only after verification")
    var findings_size: int = gs.job["findings"].size()
    view._antivirus_finished()
    check(gs.job["findings"].size() == findings_size and gs.night_minutes == start+Round.COST_MINUTES,"replaying completion cannot charge/log/cure twice")
    check(gs.money == cash and gs.player_inventory == stock and gs.job["state"] != "done","cleanup changes no money, parts, collection, payment or ticket completion")
    check(gs.load_game() and not Malware.infected(gs.job) and gs.night_minutes == start+Round.COST_MINUTES,"cure and paid attempt survive reload")
    check(gs.findings_text().contains("Task Manajer") and gs.findings_text().contains(Clock.label(gs.night_minutes)),"Findings uses the actual canonical night clock")
    await press(panel.stop_button)
    check(view.antivirus_panel == null,"Back to monitor closes the finished panel through native input")

    # Second journey: Enter submission, power cancellation, 06:00, boot failure and ticket isolation.
    gs.job["infection"] = Malware.MINER
    view._scan()
    view._remove()
    panel = view.antivirus_panel
    panel.set_process(false)
    await press(panel.row_end["source"])
    panel.word_input.text = "BANANA"
    panel.word_input.grab_focus()
    await key(KEY_ENTER)
    check(not panel.model.active("source") and not panel.hack.visible,"real Enter submits the same override path as SEND")
    start = gs.night_minutes
    await press(view.power_button)
    check(view.antivirus_panel == null and Malware.infected(gs.job) and not gs.job["pc_powered"],"switching power off stops cleanup without curing")
    check(gs.night_minutes == start and gs.load_game() and Malware.infected(gs.job),"cancelled cleanup keeps the paid cost and infection after reload")
    gs.set_pc_powered(true)
    gs.night_minutes = Clock.SHIFT_MINUTES- Round.COST_MINUTES + 1
    view._scan()
    view._remove()
    check(view.antivirus_panel == null and gs.night_minutes == Clock.SHIFT_MINUTES-Round.COST_MINUTES+1,"attempt that would pass 06:00 is refused before charge")
    gs.night_minutes = 0
    gs.job["removed_parts"] = ["gpu"]
    view._remove()
    check(view.antivirus_panel == null and gs.night_minutes == 0,"broken boot cannot start or charge cleanup even after a stale scan")
    gs.job["removed_parts"] = []
    view._scan()
    var blocked: String = gs.save_path+".night.json.tmp"
    DirAccess.make_dir_absolute(blocked)
    view._remove()
    check(view.antivirus_panel == null and gs.night_minutes == 0 and Malware.infected(gs.job),"failed save preflight cannot open, charge or cure a cleanup attempt")
    DirAccess.remove_absolute(blocked)
    view._remove()
    panel = view.antivirus_panel
    panel.set_process(false)
    check(night.switch_pc(gs,first),"test switches authoritative ticket behind a stale panel")
    gs.job["infection"] = Malware.MINER
    panel.model.disable_startup()
    panel.model.end_task("source")
    panel.model.submit_word("BANANA")
    panel.model.end_task("watchdog")
    panel.model.verify()
    panel.refresh()
    check(Malware.infected(gs.job) and panel.note.text.contains("PC changed"),"stale round never cures another customer even with the same strain")
    view.queue_free()
    await process_frame
    for suffix: String in [".night.json",".navigation.json"]: _remove_save_files(gs.save_path+suffix)
    restore_save(gs)
    finish("Antivirus")
