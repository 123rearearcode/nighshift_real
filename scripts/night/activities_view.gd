extends Node2D
const Navigation = preload("res://scripts/night/night_navigation.gd")
const NightClock = preload("res://scripts/rules/night_clock.gd")
const TicketRule = preload("res://scripts/rules/ticket.gd")
const MORNING_SCENE := "res://scenes/morning.tscn"
var message: Label
var end_button: Button
var activity_buttons: Array[Button] = []
var end_dialog: ConfirmationDialog
const Phone = preload("res://scripts/night/phone_panel.gd")
var phone: Panel
var phone_button: Button
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("NIGHTSHIFT / AFTER HOURS",Vector2(60,72),Vector2(1160,60),32)
    _label("Choose your next activity. Your PCs stay where you left them.",Vector2(60,140),Vector2(1160,40),20)
    activity_buttons.append(_button("WORKSHOP ROOM\nDrag a PC into the workshop slot",Rect2(60,235,356,150),"res://scenes/storage.tscn"))
    activity_buttons.append(_button("SALVAGE DUMP\nDrive out and search the pile",Rect2(462,235,356,150),"res://scenes/night_salvage.tscn"))
    # 0.50.0 (D158): look at and test the shop's own parts.
    activity_buttons.append(_button("TESTING BAY\nInspect and test your stock",Rect2(864,235,356,150),Navigation.BAY))
    activity_buttons.append(_button("SHOP\nBuy tool upgrades",Rect2(60,430,550,140),"res://scenes/night_shop.tscn"))
    # D136 (0.44.0): ending the night is tonight's last activity. At 06:00 it is the only one left.
    end_button = _button("",Rect2(670,430,550,140),"")
    end_button.name = "EndNightButton"
    end_button.pressed.connect(_ask_end_night)
    end_dialog = ConfirmationDialog.new()
    end_dialog.title = "End the night"
    end_dialog.ok_button_text = "End the night"
    end_dialog.confirmed.connect(_end_night)
    add_child(end_dialog)
    Navigation.pause(self)
    message = _label(NightSession.status,Vector2(60,620),Vector2(1160,65),17)
    # 0.52.0 (D160): the phone: reviews, trustworthiness and the shop level, and bought reviews.
    phone = Phone.new()
    phone.position = Vector2(440,60)
    phone.z_index = 10
    phone.hide()
    add_child(phone)
    phone_button = _button("Phone",Rect2(840,20,148,42),"")
    phone_button.name = "PhoneButton"
    phone_button.add_theme_font_size_override("font_size",17)
    phone_button.tooltip_text = "Your phone: the shop's reviews, its trustworthiness and level."
    phone_button.pressed.connect(_toggle_phone)
    _refresh_end()

func _toggle_phone() -> void:
    if phone.visible: phone.hide()
    else: phone.open()

func _called() -> Array:
    return NightSession.jobs(GameState).filter(func(job: Dictionary) -> bool: return job.get("state","open") != "done" and TicketRule.status(job) == TicketRule.CALLED)

func _refresh_end() -> void:
    var over: bool = NightClock.over(GameState.night_minutes)
    var called: int = _called().size()
    var who: String = "%d customer%s called"%[called,"" if called == 1 else "s"]
    end_button.text = ("06:00 · THE NIGHT IS OVER\nSee the morning (%s)" if over else "END THE NIGHT · %s\nNight %d · %s · called customers collect")%([who] if over else [NightClock.label(GameState.night_minutes),GameState.night_number,who])
    for button: Button in activity_buttons: button.disabled = over

func _ask_end_night() -> void:
    var names: Array = _called().map(func(job: Dictionary) -> String: return str(job["customer"]))
    end_dialog.dialog_text = ("End night %d now?\n\n"%GameState.night_number)+("Collecting in the morning: %s.\nThey take their PCs exactly as they are now."%", ".join(names) if not names.is_empty() else "Nobody was called: no PC leaves and nobody pays.\nRight-click a PC in the workshop room to call its customer.")
    end_dialog.popup_centered()

func _end_night() -> void:
    var report: Dictionary = NightSession.end_night(GameState)
    if not bool(report.get("ok",false)):
        message.text = str(report.get("message","The night could not end. Nothing was changed."))
        return
    Navigation.commit(self,MORNING_SCENE)

func _label(text: String,at: Vector2,area: Vector2,size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",size)
    add_child(label)
    return label
func _button(text: String,rect: Rect2,path: String) -> Button:
    var button := Button.new()
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.add_theme_font_size_override("font_size",20)
    if path != "": button.pressed.connect(_go.bind(path))
    button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(button)
    return button
func _go(path: String) -> void:
    _navigate(path)
func _navigate(path: String) -> bool:
    if not NightSession.checkpoint(GameState):
        if is_instance_valid(message): message.text = NightSession.status
        return false
    return Navigation.commit(self,path)
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
