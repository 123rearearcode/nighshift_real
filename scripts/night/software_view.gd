# Wave 2 first slice: live diagnostic desktop. The rules own reports; views never finish a job.
extends "res://scripts/night/night_screen.gd"
const ItemArt = preload("res://scripts/view/item_art.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Games = preload("res://scripts/data/games.gd")
const Parts = preload("res://scripts/rules/part_states.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const StressLab = preload("res://scripts/rules/stress_lab.gd")
const Findings = preload("res://scripts/rules/findings.gd")
const AntivirusRound = preload("res://scripts/rules/antivirus_round.gd")
const AntivirusPanel = preload("res://scripts/night/antivirus_panel.gd")
var antivirus_panel: Panel
var antivirus_ticket: String = ""
var antivirus_strain: String = ""
var antivirus_resolved: bool = false
var power_button: Button
var boot_button: Button
var hardware_button: Button
var work_tab: Button
var client_tab: Button
var findings_tab: Button
var tab: String = "work"     # 0.47.0: "work" (Work + match), "findings" (the notebook) or "client"
var busy_what: String = ""   # the timed test that is running, for the notebook if it is stopped
var busy_start: int = 0
var side_text: Label
var side_scroll: ScrollContainer
var client_text: String = ""
var needs: Dictionary = {}
var run_seconds: float = 3.0    # real seconds a timed test keeps the monitor busy (tests set 0)
var busy_left: float = 0.0
var busy_total: float = 0.0
var busy_done: Callable = Callable()
var buy_button: Button
var run_button: Button
var scan_button: Button
var remove_button: Button
var mult_down: Button
var mult_up: Button
var volt_down: Button
var volt_up: Button
var quick_button: Button
var long_button: Button
var oc_label: Label
var threat_found: bool = false
var output: Label
var status_label: Label
var cash_label: Label
var app_buttons: Array[Button] = []
var report_scroll: ScrollContainer
var ready_for_work: bool = false

func _ready() -> void:
    ready_for_work = NightSession.ensure(GameState) and not NightSession.read_only
    var marker: Dictionary = GameState.job.get("hardware_trial",{}).get("night_session",{})
    ready_for_work = ready_for_work and str(marker.get("pc","")) != ""
    Navigation.workbench(self,"monitor",_go.bind(Navigation.ACTIVITIES))
    status_label = _label("",Vector2(64,112),Vector2(810,36),20)
    boot_button = _app("Boot check",Rect2(64,162,150,46),_boot)
    hardware_button = _app("Hardware check",Rect2(226,162,200,46),_hardware)
    scan_button = _app("Anti-virus · scan",Rect2(438,162,210,46),_scan)
    remove_button = _app("Remove threat",Rect2(660,162,218,46),_remove)
    buy_button = _app("",Rect2(64,225,300,46),_buy)
    run_button = _app("Run Counter Stroke 2",Rect2(376,225,250,46),_game)
    # D150 (0.47.0): the long load test is its own app, the Stress lab, no longer an overclocker button.
    long_button = _app("Stress lab · %d min · $%d"%[Clock.LONG_STRESS_MINUTES,Overclock.LONG_TEST_COST],Rect2(638,225,240,46),_stress.bind(true))
    # D132: the overclocker. Heat is visible in every check; instability only shows in a stress test (or at pickup).
    mult_down = _app("Multiplier −",Rect2(64,285,150,40),_oc_step.bind(-1,0))
    mult_up = _app("Multiplier +",Rect2(222,285,150,40),_oc_step.bind(1,0))
    volt_down = _app("Voltage −",Rect2(380,285,150,40),_oc_step.bind(0,-1))
    volt_up = _app("Voltage +",Rect2(538,285,150,40),_oc_step.bind(0,1))
    quick_button = _app("Quick stress",Rect2(696,285,182,40),_stress.bind(false))
    oc_label = _label("",Vector2(64,332),Vector2(814,30),18)
    report_scroll = ScrollContainer.new()
    report_scroll.position = Vector2(64,368)
    report_scroll.size = Vector2(814,222)
    report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(report_scroll)
    output = Label.new()
    output.custom_minimum_size = Vector2(788,0)
    output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    output.add_theme_font_size_override("font_size",19)
    report_scroll.add_child(output)
    _label("CUSTOMER PC",Vector2(982,110),Vector2(264,34),22)
    power_button = _button("",Rect2(982,324,264,52),"")
    power_button.pressed.connect(_power)
    var who: Dictionary = GameState.customer_view(str(GameState.job["customer_id"]))
    # D133: tabs beside the monitor. Work + match first; 0.47.0 adds the Findings notebook; client last.
    work_tab = _button("Work",Rect2(982,384,80,34),"")
    work_tab.add_theme_font_size_override("font_size",15)
    work_tab.pressed.connect(_show_tab.bind("work"))
    findings_tab = _button("Findings",Rect2(1066,384,96,34),"")
    findings_tab.add_theme_font_size_override("font_size",15)
    findings_tab.pressed.connect(_show_tab.bind("findings"))
    client_tab = _button("Client",Rect2(1166,384,80,34),"")
    client_tab.add_theme_font_size_override("font_size",15)
    client_tab.pressed.connect(_show_tab.bind("client"))
    side_scroll = ScrollContainer.new()
    side_scroll.position = Vector2(982,424)
    side_scroll.size = Vector2(264,180)
    side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(side_scroll)
    side_text = Label.new()
    side_text.custom_minimum_size = Vector2(240,0)
    side_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    side_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    side_text.add_theme_font_size_override("font_size",15)
    side_scroll.add_child(side_text)
    needs = who.get("needs",{})
    needs = needs.get("stated",{}) if needs.has("stated") else needs
    var targets: Array[String] = []
    if needs.get("quiet",false): targets.append("Quiet operation")
    for target: Dictionary in needs.get("games",[]):
        targets.append("%s ≥ %d FPS"%[Games.game(str(target["game_id"])).get("title",target["game_id"]),int(target["min_fps"])])
    client_text = "%s\n%s\n\nUses: %s\nRequested: %s\nCollection request: %s"%[GameState.job["customer"],GameState.job["complaint"],who.get("uses","See ticket"),", ".join(targets) if not targets.is_empty() else "Working PC",who.get("patience","Not set")]
    cash_label = _label("",Vector2(982,610),Vector2(264,36),18)
    message = _label("Game tests take %d night minutes, the Stress lab %d. Results go into Findings. Reports only: no completion or payment."%[Clock.GAME_TEST_MINUTES,Clock.LONG_STRESS_MINUTES],Vector2(32,670),Vector2(1216,36),16)
    _refresh()
    _show("PC is off. Turn it on using the case button on the right, then run Boot check." if not _powered() else "PC is on. Start with Boot check and Hardware check, then test the customer's games.")
    if not ready_for_work: _show("No writable customer PC is selected. Return to the workshop.\n"+NightSession.status)

func _navigate(path: String) -> bool:
    if is_instance_valid(antivirus_panel):
        message.text = "Close Task Manajer with Stop cleanup / Back to monitor before changing views."
        return false
    if busy_left > 0.0:
        message.text = "A test is running. Finish it, or use the PC power button to cancel it before changing views."
        return false
    return super._navigate(path)

func _app(text: String,rect: Rect2,action: Callable) -> Button:
    var button := _button(text,rect,"")
    button.add_theme_font_size_override("font_size",16)
    button.pressed.connect(action)
    app_buttons.append(button)
    return button

func _powered() -> bool:
    return bool(GameState.job.get("pc_powered",false))

func _refresh() -> void:
    status_label.text = "%s / %s · %s"%[GameState.job["customer"],"POWER ON" if _powered() else "POWER OFF · no live readings",Clock.line(GameState.night_minutes)]
    power_button.text = "Switch PC OFF" if _powered() else "Switch PC ON"
    power_button.disabled = not ready_for_work
    for button: Button in app_buttons: button.disabled = not ready_for_work or not _powered() or busy_left > 0.0 or is_instance_valid(antivirus_panel)
    var owned: bool = GameState.owns_game("counter_stroke_2")
    var game: Dictionary = Games.game("counter_stroke_2")
    buy_button.text = "Vapor · Counter Stroke 2 · owned" if owned else "Vapor · buy Counter Stroke 2 · $%d"%game["price"]
    buy_button.disabled = buy_button.disabled or owned or GameState.money < int(game["price"])
    run_button.disabled = run_button.disabled or not owned
    cash_label.text = "Shop cash: $%d"%GameState.money
    var oc: Dictionary = Overclock.settings(GameState.job)
    oc_label.text = "Overclocker · CPU multiplier +%d / %d · voltage %d / %d · +%.0f°C · CPU power x%.2f"%[oc["mult"],Overclock.MAX_MULT,oc["volt"],Overclock.MAX_VOLT,Overclock.heat(GameState.job),Overclock.cpu_factor(GameState.job)]
    remove_button.disabled = remove_button.disabled or not threat_found or not Malware.infected(GameState.job)
    long_button.disabled = long_button.disabled or GameState.money < Overclock.LONG_TEST_COST
    work_tab.disabled = tab == "work"
    findings_tab.disabled = tab == "findings"
    client_tab.disabled = tab == "client"
    if tab == "work": side_text.text = WorkReport.text(GameState.job,needs,GameState.PASS_TEMP)
    elif tab == "findings": side_text.text = GameState.findings_text()
    else: side_text.text = client_text+"\n\nParts: "+Parts.summary(GameState.job)
    queue_redraw()

func _show(text: String) -> void:
    output.text = text
    report_scroll.scroll_vertical = 0

func _show_tab(which: String) -> void:
    tab = which
    side_scroll.scroll_vertical = 0
    _refresh()
    # The notebook is long: it also opens on the big screen. Reading it costs no night time.
    if which == "findings": _show(GameState.findings_text())

# D150 (0.47.0): a test result goes into Findings as a measurement, stamped with the night clock.
func _measured(text: String,until: int = -1,minute: int = -1,incomplete: bool = false) -> void:
    GameState.record_finding(Findings.MEASUREMENT,text,"monitor",until,incomplete,minute)

# D133: a timed test keeps the monitor busy for `run_seconds`, then spends its night minutes and reports.
func _run_timed(what: String,minutes: int,done: Callable) -> void:
    busy_what = what
    busy_start = GameState.night_minutes
    if run_seconds <= 0.0:
        done.call()
        return
    busy_total = run_seconds
    busy_left = run_seconds
    busy_done = done
    _refresh()
    _show("%s is running... this takes %d minutes of the night."%[what,minutes])

func _process(delta: float) -> void:
    if busy_left <= 0.0: return
    busy_left -= delta
    queue_redraw()
    if busy_left <= 0.0:
        busy_left = 0.0
        var done: Callable = busy_done
        busy_done = Callable()
        if done.is_valid(): done.call()

func _guard() -> bool:
    if not ready_for_work or busy_left > 0.0 or is_instance_valid(antivirus_panel): return false
    if not _powered():
        _show("Power is off. Use Switch PC ON before running live tests.")
        return false
    return true

func _power() -> void:
    if not ready_for_work: return
    if is_instance_valid(antivirus_panel):
        antivirus_panel.model.abort()
        antivirus_panel.refresh()
        _close_antivirus()
    if busy_left > 0.0:
        # D150: a stopped test is noted as incomplete, with no result: nothing was measured to the end.
        _measured("%s stopped: the PC was switched off before it finished. No result."%busy_what,-1,busy_start,true)
    busy_left = 0.0   # switching the power cancels a running test; no night time is spent
    busy_done = Callable()
    GameState.set_pc_powered(not _powered())
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(("Power ON. Run Boot check to diagnose startup." if _powered() else "Power OFF. Live readings cleared. Cleaning and repasting remain available at the repair bench.")+("\n"+NightSession.status if not saved else ""))

func _boot() -> void:
    if not _guard(): return
    var text: String = str(Checks.boot(GameState.job)["message"])
    _measured("Boot check: "+text)
    NightSession.checkpoint(GameState)
    _refresh()
    _show(text)

# D133: only "is everything in place": parts fitted and working, cooler locked. No temperature here.
func _hardware() -> void:
    if not _guard(): return
    var result: Dictionary = WorkReport.hardware_check(GameState.job)
    GameState.record_test("hardware",{"ok":bool(result["ok"])})
    _measured(str(result["message"]).get_slice("\n\nThis check",0))
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(str(result["message"])+("\n"+NightSession.status if not saved else ""))

func _buy() -> void:
    if not _guard(): return
    var bought: bool = GameState.buy_game("counter_stroke_2")
    var saved: bool = NightSession.checkpoint(GameState) if bought else true
    _refresh()
    _show(("Counter Stroke 2 purchased for the shop. Its licence can test any customer's PC." if bought else "Purchase unavailable: already owned or not enough shop cash.")+("\n"+NightSession.status if not saved else ""))

# D136 (0.44.0): at 06:00 the night is over; timed tests no longer fit in it.
func _night_over(minutes: int = 0) -> bool:
    if Clock.over(GameState.night_minutes):
        _show("It is 06:00: the night is over. Go to Activities and end the night; called customers collect now.")
        return true
    # 0.47.0 (D150): a timed test must end by 06:00; nothing is charged for one that cannot.
    if not Clock.fits(GameState.night_minutes,minutes):
        _show("It is %s: this test takes %d minutes and would run past 06:00. Not started, nothing charged."%[Clock.label(GameState.night_minutes),minutes])
        return true
    return false

func _game() -> void:
    if not _guard() or _night_over(Clock.GAME_TEST_MINUTES): return
    var report: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    var result: Dictionary = Checks.game_test(GameState.job,GameState.owned_games,"counter_stroke_2",report["temp"])
    if not result["ok"]:
        _show(result["message"])
        return
    _run_timed("The Counter Stroke 2 test",Clock.GAME_TEST_MINUTES,_game_done.bind(result,float(report["temp"])))

func _game_done(result: Dictionary,temp: float) -> void:
    var start: int = GameState.night_minutes
    GameState.advance_night(Clock.GAME_TEST_MINUTES)
    GameState.record_test("games",{"fps":int(result["fps"]),"temp":temp},"counter_stroke_2")
    GameState.record_test("temp",{"value":temp})
    _measured("Game test: "+str(result["message"]),start+Clock.GAME_TEST_MINUTES,start)
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(str(result["message"])+"\nThe test took %d night minutes."%Clock.GAME_TEST_MINUTES+("\n"+NightSession.status if not saved else ""))

# D132: anti-virus. Scanning is always accurate; the remove button only exists after a scan found something.
func _scan() -> void:
    if not _guard(): return
    var report: Dictionary = Checks.antivirus(GameState.job)
    threat_found = bool(report.get("found",false))
    if Checks.boot(GameState.job)["ok"]:
        _measured("Anti-virus scan: "+str(report["message"]))
        NightSession.checkpoint(GameState)
    _refresh()
    _show(str(report["message"]))

func _remove() -> void:
    if not _guard() or not threat_found or _night_over(AntivirusRound.COST_MINUTES): return
    var boot: Dictionary = Checks.boot(GameState.job)
    if not bool(boot["ok"]):
        _show(str(boot["message"]))
        return
    var strain: String = Malware.strain(GameState.job)
    if strain == "" or str(GameState.job.get("state","open")) == "done": return
    if not NightSession.checkpoint(GameState):
        _show("Cleanup not started, nothing charged. Resolve the save error first.\n"+NightSession.status)
        return
    # A whole attempt is paid once BEFORE playing. Stopping, crashing, closing or reloading cannot
    # grant a free attempt. Round seconds are not an independent night clock. No new save shape.
    GameState.advance_night(AntivirusRound.COST_MINUTES)
    GameState.record_finding(Findings.WORK,"Started Task Manajer cleanup; %d night minutes spent." % AntivirusRound.COST_MINUTES,"antivirus")
    if not NightSession.checkpoint(GameState):
        _show("Cleanup could not start: the checkpoint failed. Resolve the save error before retrying.\n"+NightSession.status)
        return
    antivirus_ticket = str(GameState.job["id"])
    antivirus_strain = strain
    antivirus_resolved = false
    antivirus_panel = AntivirusPanel.new()
    antivirus_panel.model = AntivirusRound.new(strain, "%s:%s" % [NightSession.run_id, antivirus_ticket])
    antivirus_panel.clock_text = "Night %d · %s" % [GameState.night_number,Clock.label(GameState.night_minutes)]
    antivirus_panel.finished.connect(_antivirus_finished)
    antivirus_panel.closed.connect(_close_antivirus)
    add_child(antivirus_panel)
    _refresh()

func _antivirus_finished() -> void:
    if not is_instance_valid(antivirus_panel) or antivirus_resolved: return
    antivirus_resolved = true
    var round_model: RefCounted = antivirus_panel.model
    # Bind completion to the actual scanned ticket/strain. A stale panel can never cure another PC.
    if str(GameState.job.get("id","")) != antivirus_ticket or Malware.strain(GameState.job) != antivirus_strain:
        antivirus_panel.note.text = "This PC changed. No removal was applied. Close and scan again."
        return
    var won: bool = round_model.outcome == "won" and bool(Checks.boot(GameState.job)["ok"])
    GameState.record_finding(Findings.WORK,round_model.report(),"antivirus",-1,not won)
    if round_model.outcome == "crashed": GameState.set_pc_powered(false)
    if won:
        GameState.clean_infection()
        threat_found = false
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(("Threat removed after a clean reboot. Scan again to confirm." if won else "Cleanup not verified. The infection remains. The attempt's night time stays spent.")+("\n"+NightSession.status if not saved else ""))
    if not saved: antivirus_panel.note.text = "Save failed: " + NightSession.status

func _close_antivirus() -> void:
    if not is_instance_valid(antivirus_panel): return
    antivirus_panel.queue_free()
    antivirus_panel = null
    _refresh()

func _exit_tree() -> void:
    # The attempt cost was already saved. An interrupted round cannot become a completed cure.
    if is_instance_valid(antivirus_panel) and antivirus_panel.model.outcome == "running":
        antivirus_panel.model.abort()
        _antivirus_finished()

# D132: overclocker settings. Changing them re-saves the job; the PC is not rebooted by the monitor.
func _oc_step(mult_delta: int,volt_delta: int) -> void:
    if not _guard(): return
    var current: Dictionary = Overclock.settings(GameState.job)
    GameState.set_overclock(int(current["mult"])+mult_delta,int(current["volt"])+volt_delta)
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show("Settings changed. Run a stress test, then check the heat. A quick test cannot prove stability."+("\n"+NightSession.status if not saved else ""))

func _stress(long_test: bool) -> void:
    if not _guard() or (long_test and _night_over(StressLab.minutes())): return
    if not Checks.boot(GameState.job)["ok"]:
        _show(Checks.boot(GameState.job)["message"])
        return
    if long_test:
        if not GameState.charge_long_stress():
            _show("Not enough shop cash for the long test ($%d)."%Overclock.LONG_TEST_COST)
            return
        _refresh()
        _run_timed("The Stress lab run",StressLab.minutes(),_stress_done.bind(true))
    else:
        _stress_done(false)

func _stress_done(long_test: bool) -> void:
    var report: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    if long_test:
        _lab_done(float(report["temp"]))
        return
    var result: Dictionary = Checks.stress(GameState.job,report["temp"],false)
    GameState.record_test("temp",{"value":float(report["temp"])})
    _measured("Quick stress: "+str(result["message"]))
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(str(result["message"])+("\n"+NightSession.status if not saved else ""))

# D150 (0.47.0): the Stress lab. Readings on the night clock; a crash ends the run early, and only the
# minutes actually run are spent. The temperature is recorded only when the run reached its settled load.
func _lab_done(load: float) -> void:
    var start: int = GameState.night_minutes
    var result: Dictionary = StressLab.run(GameState.job,load,start)
    GameState.advance_night(int(result["minutes"]))
    if int(result["minutes"]) >= StressLab.WARM_UP: GameState.record_test("temp",{"value":load})
    var text: String = StressLab.message(result,start)
    _measured(text,start+int(result["minutes"]),start)
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(text+"\nElectricity: $%d. The run took %d night minutes."%[Overclock.LONG_TEST_COST,int(result["minutes"])]+("\n"+NightSession.status if not saved else ""))

func _draw() -> void:
    super._draw()
    var bezel: Texture2D = ItemArt.pixel(RoomArt.ui("monitor_bezel"))
    if bezel == null:
        draw_rect(Rect2(32,88,878,550),Color("384653"))
    draw_rect(Rect2(48,104,846,516),Color("10191d") if _powered() else Color("0a0d10"))
    if bezel != null:             # 0.57.8: the approved monitor frame (ART-18): bezel, neck and foot, screen left open
        draw_texture_rect(bezel, Rect2(32,88,878,574), false)
    else:
        draw_rect(Rect2(420,638,100,17),Color("52606b"))
        draw_rect(Rect2(364,654,212,8),Color("52606b"))
    draw_rect(Rect2(1016,159,190,140),Color("283541"))
    draw_rect(Rect2(1030,173,144,112),Color("11191f"))
    draw_circle(Vector2(1190,186),5,Color("75d4b0") if _powered() else Color("56616b"))
    if busy_left > 0.0 and busy_total > 0.0:
        draw_rect(Rect2(64,598,814,12),Color("23323a"))
        draw_rect(Rect2(64,598,814*(1.0-busy_left/busy_total),12),Color("75d4b0"))
