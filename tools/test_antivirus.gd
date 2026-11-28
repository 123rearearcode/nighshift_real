# The calm approved loop, native SEND/Enter and the real monitor -> save -> pickup journey.
extends "res://tools/test_support.gd"
const Round = preload("res://scripts/rules/antivirus_round.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")
const Effects = preload("res://scripts/view/antivirus_effects.gd")
const Store = preload("res://scripts/state/save_store.gd")
func _initialize() -> void: call_deferred("run_checks")

func press(button: Button) -> void:
    for down: bool in [true,false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = button.get_global_rect().get_center()
        event.global_position = event.position
        button.get_viewport().push_input(event,true)
        await process_frame
    await process_frame

# 0.59.0 (D182): the monitor's apps are buttons in Windough 98 windows; click them where they are drawn.
func press_at(at: Vector2) -> void:
    for down: bool in [true,false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = at
        event.global_position = at
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

    # D163: lightweight deduction and per-PC variety, never a shuffled/moving target during play.
    var keyed := Round.new(Malware.MINER, "customer-pc-a")
    var retry := Round.new(Malware.MINER, "customer-pc-a")
    check(keyed.processes == retry.processes and keyed.case_variant == retry.case_variant, "the same PC keeps its names and layout on retry")
    var layouts: Dictionary = {}
    for n in range(12):
        var varied := Round.new(Malware.ADWARE, "customer-pc-%d" % n)
        layouts[str(varied.processes.map(func(p: Dictionary) -> String: return str(p["id"])))] = true
    check(layouts.size() > 1, "different customer PCs can have different fixed layouts")
    var named := Round.new(Malware.ADWARE, "customer-pc-a")
    var app_name: String = named.label("source")
    named.end_task("source")
    check(named.status.begins_with(app_name + ":"), "adware reactions name the app actually stopped, including per-PC aliases")
    keyed.scan()
    check(keyed.scanned and keyed.scan_clues().contains("coins") and not keyed.scan_clues().contains("Zombie") and not keyed.scan_clues().contains(".exe"), "scan clues explain behaviour without naming exact targets or requiring computer knowledge")
    check(a.scan_clues().contains("adverts") and keyed.process("watchdog")["detail"].contains("Start with PC"), "adware and miner have distinct plain-language leads and the helper explains recovery")
    var stable_clue: String = keyed.process("source")["detail"]
    var live_start: Dictionary = Effects.sample(keyed,"source",false)
    keyed.step(1.3)
    var live_after: Dictionary = Effects.sample(keyed,"source",false)
    check(live_start["text"] != live_after["text"] and stable_clue == keyed.process("source")["detail"], "miner names garble while its readable inspection clue stays fixed")
    var live_seconds: float = keyed.elapsed
    keyed.paused = true
    keyed.step(20)
    check(keyed.elapsed == live_seconds and Effects.sample(keyed,"source",false) == live_after, "pause freezes presentation as well as the simulation")
    keyed.paused = false
    keyed.elapsed = 2.1
    var reduced_before: Dictionary = Effects.sample(keyed,"source",true)
    keyed.elapsed = 2.9
    var reduced_after: Dictionary = Effects.sample(keyed,"source",true)
    check(reduced_before == reduced_after and reduced_after["offset"] == Vector2.ZERO, "reduced effects keep names and CPU values fixed within a second and remove shake")
    var colourful := Round.new(Malware.ADWARE)
    var colour_before: Color = Effects.sample(colourful,"source",false)["colour"]
    colourful.step(2)
    check(Effects.sample(colourful,"source",false)["colour"] != colour_before and Effects.sample(colourful,"source",true)["colour"] == reduced_after["colour"], "adware colour cycles become a steady accent with reduced effects")
    keyed.end_task("source")
    keyed.submit_word("BANANA")
    check(Effects.sample(keyed,"source",false)["cpu"] == 0 and Effects.sample(keyed,"source",false)["offset"] == Vector2.ZERO, "stopped malware immediately loses its CPU load and interference")
    var stopped_alias: String = keyed.label("source")
    keyed.step(Round.ALIAS_SECONDS * 2.0)
    check(keyed.label("source") == stopped_alias, "a stopped miner keeps its final alias while the rest of the cleanup continues")

    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    var old_settings: String = gs.settings_path
    var old_volume: float = gs.sound_volume
    var old_reduced: bool = gs.reduce_flashing
    gs.settings_path = "user://antivirus_settings_test.json"
    _remove_save_files(gs.settings_path)
    use_test_save(gs,"antivirus_test.json")
    for suffix: String in [".night.json",".navigation.json"]: _remove_save_files(gs.save_path+suffix)
    gs.new_game(false)
    gs.set_reduce_flashing(true)
    gs.set_sound_volume(0.35)
    gs.set_reduce_flashing(false,false)
    gs.set_sound_volume(1.0,false)
    gs._load_settings()
    check(gs.reduce_flashing and is_equal_approx(gs.sound_volume,0.35), "volume changes preserve reduced effects and both preferences survive reload")
    Store.write(gs.settings_path,{"sound_volume":0.4})
    gs._load_settings()
    check(not gs.reduce_flashing and is_equal_approx(gs.sound_volume,0.4), "old volume-only settings load with normal effects")
    Store.write(gs.settings_path,{"sound_volume":0.4,"reduce_flashing":"wrong-type"})
    gs._load_settings()
    check(not gs.reduce_flashing, "malformed optional effects preference safely uses its default")
    var title: Node = load("res://scenes/start.tscn").instantiate()
    root.add_child(title)
    current_scene = title
    await process_frame
    title._on_settings()
    await process_frame
    # AcceptDialog is a separate native Window: test its actual CheckButton signal here; the graphical
    # pass exercises pointer routing across that window. Root viewport events cannot stand in for it.
    title.reduce_flashing_toggle.button_pressed = true
    check(gs.reduce_flashing and Store.read(gs.settings_path).get("reduce_flashing",false) == true, "title Settings control saves the reduced-effects preference")
    title.settings_dialog.hide()
    title.queue_free()
    await process_frame
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
    view.windough.open("taskmanajer")
    check(view.windough.state == "desktop" and view.windough.open_app == "taskmanajer" and view.windough.button_rect("Scan").has_area(), "the PC is on: Task Manajer opens in a Windough window with its Scan button")
    await press_at(view.windough.button_rect("Scan").get_center())
    check(view.threat_found and not view.remove_button.disabled,"native scan reveals the real infection and offers cleanup")
    var start: int = gs.night_minutes
    await press_at(view.windough.button_rect("Remove threat").get_center())
    var panel: Node = view.antivirus_panel
    panel.set_process(false)
    check(panel != null and panel.model.strain == Malware.MINER and Malware.infected(gs.job),"Remove threat opens the real minigame and cannot instantly cure")
    check(gs.night_minutes == start+Round.COST_MINUTES,"attempt costs its night minutes once on entry")
    check(not view._navigate(Nav.REPAIR) and view.boot_button.disabled,"active cleanup blocks navigation and competing monitor tests")
    var positions: Dictionary = {}
    for id: String in panel.row_buttons: positions[id] = [panel.row_buttons[id].get_rect(), panel.row_end[id].get_rect()]
    await press(panel.scan_button)
    check(panel.clues.text == panel.model.scan_clues() and panel.row_buttons.values().all(func(b: Button) -> bool: return b.modulate == Color.WHITE), "native scan offers readable leads without automatically tagging the hidden bad rows")
    await press(panel.row_buttons["source"])
    var inspection: String = panel.details.text
    panel._process(2)
    check(panel.details.text == inspection and panel.row_text["source"].text != panel.model.label("source"), "clicking an app exposes a stable plain-language clue while its name is corrupted")
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
    check(panel.row_buttons.keys() == saved_rows and positions.keys().all(func(id: String) -> bool: return [panel.row_buttons[id].get_rect(), panel.row_end[id].get_rect()] == positions[id]),"all native row and End-button rectangles survive effects, process ending and clock updates")
    var pause: Node = view.get_node("PauseMenu")
    await press(view.get_node("PauseButton"))
    var time_before: float = panel.model.elapsed
    await process_frame
    check(paused and panel.model.elapsed == time_before,"shared Pause freezes the real cleanup")
    pause._settings()
    await process_frame
    check(pause.reduce_flashing_toggle.button_pressed, "pause Settings reads the preference selected on the title screen")
    pause.reduce_flashing_toggle.button_pressed = false
    check(not gs.reduce_flashing and Store.read(gs.settings_path).get("reduce_flashing",true) == false, "pause Settings control can change and save the same preference")
    pause.close()
    await press(panel.row_buttons["watchdog"])
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
    _remove_save_files(gs.settings_path)
    gs.settings_path = old_settings
    gs.set_sound_volume(old_volume,false)
    gs.set_reduce_flashing(old_reduced,false)
    finish("Antivirus")
