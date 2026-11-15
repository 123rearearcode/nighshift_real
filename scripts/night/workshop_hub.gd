# PC selection and read-only diagnostics. This is not the future daytime shop.
extends "res://scripts/night/activities_view.gd"
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
var report: Label
var ticket: Label
var work_buttons: Array[Button] = []
var upgrade_buttons: Dictionary = {}
var cash_label: Label
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("WORKSHOP / NIGHT SHIFT",Vector2(32,24),Vector2(1000,48),28)
    _label("Change PCs in the room: drag one into the workshop slot.",Vector2(32,94),Vector2(630,48),18)
    _button("Room / choose another PC",Rect2(710,346,530,50),"res://scenes/storage.tscn")
    Navigation.attach(self,_go.bind(Navigation.ACTIVITIES))
    var ticket_scroll := ScrollContainer.new()
    ticket_scroll.position = Vector2(32,158)
    ticket_scroll.size = Vector2(630,243)
    ticket_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(ticket_scroll)
    ticket = Label.new()
    ticket.custom_minimum_size = Vector2(606,0)
    ticket.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ticket.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ticket.add_theme_font_size_override("font_size",18)
    ticket_scroll.add_child(ticket)
    work_buttons.append(_button("Repair bench · clean + paste",Rect2(710,94,530,60),"res://scenes/night_bench.tscn"))
    work_buttons.append(_button("Hardware bench · shop stock",Rect2(710,170,530,60),"res://scenes/night_hardware.tscn"))
    var check_button := _button("Diagnostic monitor · boot + game tests",Rect2(710,246,530,60),"")
    check_button.pressed.connect(_go.bind("res://scenes/software.tscn"))
    work_buttons.append(check_button)
    var x: float = 710
    for id: String in ["square_cloth","long_hose"]:
        var button := _button("",Rect2(x,490,255,46),"")
        button.pressed.connect(_buy_upgrade.bind(id))
        upgrade_buttons[id] = button
        x += 275
    cash_label = _label("",Vector2(710,564),Vector2(530,40),20)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(32,425)
    scroll.size = Vector2(630,225)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    report = Label.new()
    report.custom_minimum_size = Vector2(606,0)
    report.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    report.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    report.add_theme_font_size_override("font_size",17)
    scroll.add_child(report)
    message = _label("",Vector2(32,669),Vector2(1210,34),14)
    _refresh_ticket()
    _refresh_upgrades()
func _refresh_upgrades() -> void:
    cash_label.text = "Shop cash: $%d"%GameState.money
    for id: String in upgrade_buttons:
        var owned: bool = GameState.has_upgrade(id)
        upgrade_buttons[id].text = ("Square cloth" if id == "square_cloth" else "Longer hose")+(" · owned" if owned else " · $%d"%GameState.UPGRADE_PRICES[id])
        upgrade_buttons[id].disabled = owned
func _buy_upgrade(id: String) -> void:
    var bought: bool = GameState.buy_upgrade(id)
    if bought: NightSession.checkpoint(GameState)
    message.text = ("Upgrade bought · cash $%d"%GameState.money) if bought else "Not enough cash for this upgrade."
    if NightSession.status != "": message.text = NightSession.status
    _refresh_upgrades()
func _refresh_ticket() -> void:
    var job: Dictionary = GameState.job
    ticket.text = "TICKET %s / %s\n\n%s\n\nCollection request: %s\nQuote: $%d · paid at pickup, not by this check.\n\nSwitch PCs whenever you want; each keeps its own repair progress."%[job["id"],job["customer"],job["complaint"],str(GameState.customer_view(job["customer_id"]).get("patience","Collection date not set")),job["payout"]]
    ticket.text += "\n\nParts: "+PartStates.summary(job)
    report.text = "Open the diagnostic monitor. Switch the PC on, then run boot, temperature or owned game tests. A pass does not finish this job or pay you. Customer pickup will be a separate daytime action."
    message.text = NightSession.status
    var marker: Dictionary = job["hardware_trial"].get("night_session",{})
    for button: Button in work_buttons: button.disabled = str(marker.get("pc","")) == "" or NightSession.read_only
func _check() -> void:
    var result: Dictionary = Diagnostics.evaluate(GameState.job,GameState.owned_games)
    report.text = "%s\n\n%s\n\nReport only. Keep working or switch PCs."%["CHECK PASSED" if result["passed"] else "CHECK NEEDS ATTENTION","\n".join(result["notes"])]
