# Wave 2 first slice: live diagnostic desktop. The rules own reports; views never finish a job.
extends "res://scripts/night/activities_view.gd"
const Checks = preload("res://scripts/rules/software_checks.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Games = preload("res://scripts/data/games.gd")
const Parts = preload("res://scripts/rules/part_states.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
var power_button: Button
var boot_button: Button
var thermal_button: Button
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
    _label("DIAGNOSTIC MONITOR / %s"%GameState.job["id"],Vector2(32,22),Vector2(850,45),28)
    _button("Workshop",Rect2(920,20,168,42),"res://scenes/night_workshop.tscn")
    Navigation.attach(self,_go.bind(Navigation.ACTIVITIES))
    status_label = _label("",Vector2(64,112),Vector2(810,36),20)
    boot_button = _app("Boot check",Rect2(64,162,150,46),_boot)
    thermal_button = _app("Final / thermal check",Rect2(226,162,200,46),_thermal)
    scan_button = _app("Anti-virus · scan",Rect2(438,162,210,46),_scan)
    remove_button = _app("Remove threat",Rect2(660,162,218,46),_remove)
    buy_button = _app("",Rect2(64,225,390,46),_buy)
    run_button = _app("Run Counter Stroke 2",Rect2(466,225,412,46),_game)
    # D132: the overclocker. Heat is visible in every check; instability only shows in a stress test (or at pickup).
    mult_down = _app("Multiplier −",Rect2(64,285,130,40),_oc_step.bind(-1,0))
    mult_up = _app("Multiplier +",Rect2(202,285,130,40),_oc_step.bind(1,0))
    volt_down = _app("Voltage −",Rect2(340,285,110,40),_oc_step.bind(0,-1))
    volt_up = _app("Voltage +",Rect2(458,285,110,40),_oc_step.bind(0,1))
    quick_button = _app("Quick stress",Rect2(578,285,130,40),_stress.bind(false))
    long_button = _app("Long stress · $%d"%Overclock.LONG_TEST_COST,Rect2(716,285,162,40),_stress.bind(true))
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
    var ticket_scroll := ScrollContainer.new()
    ticket_scroll.position = Vector2(982,395)
    ticket_scroll.size = Vector2(264,205)
    ticket_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(ticket_scroll)
    var ticket := Label.new()
    ticket.custom_minimum_size = Vector2(240,0)
    ticket.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ticket.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ticket.add_theme_font_size_override("font_size",17)
    var need: Dictionary = who.get("needs",{})
    need = need.get("stated",{}) if need.has("stated") else need
    var targets: Array[String] = []
    if need.get("quiet",false): targets.append("Quiet operation")
    for target: Dictionary in need.get("games",[]):
        targets.append("%s ≥ %d FPS"%[Games.game(str(target["game_id"])).get("title",target["game_id"]),int(target["min_fps"])])
    ticket.text = "%s\n%s\n\nUses: %s\nRequested: %s\nCollection request: %s\n\nParts: %s"%[GameState.job["customer"],GameState.job["complaint"],who.get("uses","See ticket"),", ".join(targets) if not targets.is_empty() else "Working PC",who.get("patience","Not set"),Parts.summary(GameState.job)]
    ticket_scroll.add_child(ticket)
    cash_label = _label("",Vector2(982,610),Vector2(264,36),18)
    message = _label("Reports only · no completion, payment or trust change. Tests take no shift time in this trial.",Vector2(32,670),Vector2(1216,36),16)
    _refresh()
    _show("PC is off. Turn it on using the case button on the right, then run Boot check." if not _powered() else "PC is on. Start with Boot check, then check heat and the customer's games.")
    if not ready_for_work: _show("No writable customer PC is selected. Return to the workshop.\n"+NightSession.status)

func _app(text: String,rect: Rect2,action: Callable) -> Button:
    var button := _button(text,rect,"")
    button.add_theme_font_size_override("font_size",16)
    button.pressed.connect(action)
    app_buttons.append(button)
    return button

func _powered() -> bool:
    return bool(GameState.job.get("pc_powered",false))

func _refresh() -> void:
    status_label.text = "%s / %s"%[GameState.job["customer"],"POWER ON" if _powered() else "POWER OFF · no live readings"]
    power_button.text = "Switch PC OFF" if _powered() else "Switch PC ON"
    power_button.disabled = not ready_for_work
    for button: Button in app_buttons: button.disabled = not ready_for_work or not _powered()
    var owned: bool = GameState.owns_game("counter_stroke_2")
    var game: Dictionary = Games.game("counter_stroke_2")
    buy_button.text = "Vapor · Counter Stroke 2 · owned" if owned else "Vapor · buy Counter Stroke 2 · $%d"%game["price"]
    buy_button.disabled = not ready_for_work or not _powered() or owned or GameState.money < int(game["price"])
    run_button.disabled = not ready_for_work or not _powered() or not owned
    cash_label.text = "Shop cash: $%d"%GameState.money
    var oc: Dictionary = Overclock.settings(GameState.job)
    oc_label.text = "Overclocker · CPU multiplier +%d / %d · voltage %d / %d · +%.0f°C · CPU power x%.2f"%[oc["mult"],Overclock.MAX_MULT,oc["volt"],Overclock.MAX_VOLT,Overclock.heat(GameState.job),Overclock.cpu_factor(GameState.job)]
    remove_button.disabled = remove_button.disabled or not threat_found or not Malware.infected(GameState.job)
    long_button.disabled = long_button.disabled or GameState.money < Overclock.LONG_TEST_COST
    queue_redraw()

func _show(text: String) -> void:
    output.text = text
    report_scroll.scroll_vertical = 0

func _guard() -> bool:
    if not ready_for_work: return false
    if not _powered():
        _show("Power is off. Use Switch PC ON before running live tests.")
        return false
    return true

func _power() -> void:
    if not ready_for_work: return
    GameState.set_pc_powered(not _powered())
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show(("Power ON. Run Boot check to diagnose startup." if _powered() else "Power OFF. Live readings cleared. Cleaning and repasting remain available at the repair bench.")+("\n"+NightSession.status if not saved else ""))

func _boot() -> void:
    if _guard(): _show(Checks.boot(GameState.job)["message"])

func _thermal() -> void:
    if not _guard(): return
    var boot: Dictionary = Checks.boot(GameState.job)
    if not boot["ok"]:
        _show(boot["message"]+"\nNo live temperature reading: the PC cannot boot.")
        return
    var report: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    _show("%s · %.1f°C / limit %.0f°C\n\n%s\n\nDiagnostic only. No job completion or payment."%["CHECK PASSED" if report["passed"] else "NEEDS ATTENTION",report["temp"],GameState.PASS_TEMP,"\n".join(report["notes"])])

func _buy() -> void:
    if not _guard(): return
    var bought: bool = GameState.buy_game("counter_stroke_2")
    var saved: bool = NightSession.checkpoint(GameState) if bought else true
    _refresh()
    _show(("Counter Stroke 2 purchased for the shop. Its licence can test any customer's PC." if bought else "Purchase unavailable: already owned or not enough shop cash.")+("\n"+NightSession.status if not saved else ""))

func _game() -> void:
    if not _guard(): return
    var report: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    var result: Dictionary = Checks.game_test(GameState.job,GameState.owned_games,"counter_stroke_2",report["temp"])
    _show(result["message"])

# D132: anti-virus. Scanning is always accurate; the remove button only exists after a scan found something.
func _scan() -> void:
    if not _guard(): return
    var report: Dictionary = Checks.antivirus(GameState.job)
    threat_found = bool(report.get("found",false))
    _refresh()
    _show(str(report["message"]))

func _remove() -> void:
    if not _guard() or not threat_found: return
    var removed: bool = GameState.clean_infection()
    threat_found = false
    var saved: bool = NightSession.checkpoint(GameState) if removed else true
    _refresh()
    _show(("Threat removed. Run the scan again to confirm." if removed else "Nothing to remove.")+("\n"+NightSession.status if not saved else ""))

# D132: overclocker settings. Changing them re-saves the job; the PC is not rebooted by the monitor.
func _oc_step(mult_delta: int,volt_delta: int) -> void:
    if not _guard(): return
    var current: Dictionary = Overclock.settings(GameState.job)
    GameState.set_overclock(int(current["mult"])+mult_delta,int(current["volt"])+volt_delta)
    var saved: bool = NightSession.checkpoint(GameState)
    _refresh()
    _show("Settings changed. Run a stress test, then check the heat. A quick test cannot prove stability."+("\n"+NightSession.status if not saved else ""))

func _stress(long_test: bool) -> void:
    if not _guard(): return
    var report: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    var charged: bool = false
    if long_test and int(Overclock.settings(GameState.job)["mult"]) > 0 and Checks.boot(GameState.job)["ok"]:
        if not GameState.charge_long_stress():
            _show("Not enough shop cash for the long test ($%d)."%Overclock.LONG_TEST_COST)
            return
        charged = true
    var result: Dictionary = Checks.stress(GameState.job,report["temp"],long_test)
    if charged: NightSession.checkpoint(GameState)
    _refresh()
    _show(str(result["message"])+("\nElectricity: $%d."%Overclock.LONG_TEST_COST if charged else ""))

func _draw() -> void:
    super._draw()
    draw_rect(Rect2(32,88,878,550),Color("384653"))
    draw_rect(Rect2(48,104,846,516),Color("10191d") if _powered() else Color("0a0d10"))
    draw_rect(Rect2(420,638,100,17),Color("52606b"))
    draw_rect(Rect2(364,654,212,8),Color("52606b"))
    draw_rect(Rect2(1016,159,190,140),Color("283541"))
    draw_rect(Rect2(1030,173,144,112),Color("11191f"))
    draw_circle(Vector2(1190,186),5,Color("75d4b0") if _powered() else Color("56616b"))
