# Native controls are created once. Text/colour updates never rebuild the LineEdit or SEND Button.
extends Panel
signal finished
signal closed
const Round = preload("res://scripts/rules/antivirus_round.gd")
const Effects = preload("res://scripts/view/antivirus_effects.gd")
var model: RefCounted
var clock_text: String = ""
var selected: String = ""
var row_buttons: Dictionary = {}
var row_text: Dictionary = {}
var row_cpu: Dictionary = {}
var row_end: Dictionary = {}
var heading: Label
var details: Label
var note: Label
var progress: ProgressBar
var counter: Label
var startup_button: Button
var scan_button: Button
var pause_button: Button
var stop_button: Button
var verify_button: Button
var shortcut_button: Button
var advert: Panel
var advert_text: Label
var advert_close: Button
var quiet: Label
var hack: Panel
var hack_title: Label
var hack_status: Label
var word_input: LineEdit
var send_button: Button
var cancel_button: Button
var reported: bool = false
var clues: Label
var italic_font: FontVariation

func _ready() -> void:
    name = "TaskManajer"
    position = Vector2(48,108)
    size = Vector2(846,516)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var style := StyleBoxFlat.new()
    style.bg_color = Color("23372e")
    style.border_color = Color("82ac87")
    style.set_border_width_all(2)
    add_theme_stylebox_override("panel",style)
    _label(self,"TASK MANAJER / TROUBLE AT WORK",Rect2(14,8,545,26),19)
    pause_button = _button(self,"Pause",Rect2(560,8,125,32),_pause)
    stop_button = _button(self,"Stop cleanup",Rect2(695,8,137,32),_close)
    counter = _label(self,"",Rect2(14,42,818,23),14)
    progress = ProgressBar.new()
    progress.position = Vector2(14,70)
    progress.size = Vector2(818,9)
    progress.show_percentage = false
    add_child(progress)
    italic_font = FontVariation.new()
    italic_font.base_font = ThemeDB.fallback_font
    italic_font.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.18, 1), Vector2.ZERO)
    if selected == "": selected = str(model.processes[0]["id"])
    for i in range(model.processes.size()):
        var item: Dictionary = model.processes[i]
        var id: String = str(item["id"])
        var y: float = 86 + i * 38
        row_buttons[id] = _button(self,"",Rect2(14,y,284,34),_select.bind(id))
        row_buttons[id].toggle_mode = true
        row_text[id] = _label(row_buttons[id], "", Rect2(8,2,268,30), 14)
        row_text[id].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        row_text[id].autowrap_mode = TextServer.AUTOWRAP_OFF
        row_text[id].clip_text = true
        row_text[id].text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        row_cpu[id] = _label(self,"",Rect2(302,y+6,44,24),14)
        row_end[id] = _button(self,"Stop",Rect2(350,y,74,34),_end.bind(id))
    heading = _label(self,"WHAT THIS APP DOES",Rect2(450,85,380,26),18)
    details = _label(self,"",Rect2(450,116,380,108),14)
    startup_button = _button(self,"Turn off Start with PC",Rect2(450,230,380,32),_startup)
    advert = Panel.new()
    advert.position = Vector2(450,272)
    advert.size = Vector2(380,158)
    add_child(advert)
    _label(advert,"A COMPLETELY GENUINE OFFER",Rect2(10,6,358,24),15)
    advert_text = _label(advert,"",Rect2(10,34,358,66),17)
    advert_close = _button(advert,"Close advert ×",Rect2(10,112,358,32),_close_ad)
    quiet = _label(self,"Advertisement slot · no pop-up right now",Rect2(450,288,380,50),15)
    scan_button = _button(self,"Read scan clues",Rect2(14,322,410,34),_scan)
    clues = _label(self,"",Rect2(14,364,410,68),15)
    hack = Panel.new()
    hack.position = Vector2(14,314)
    hack.size = Vector2(420,119)
    var hack_style := StyleBoxFlat.new()
    hack_style.bg_color = Color("182b24")
    hack_style.border_color = Color("82ac87")
    hack_style.set_border_width_all(1)
    hack.add_theme_stylebox_override("panel", hack_style)
    add_child(hack)
    hack_title = _label(hack,"",Rect2(10,5,400,24),16)
    hack_status = _label(hack,"Desktop paused while typing. No countdown.",Rect2(10,32,400,25),13)
    word_input = LineEdit.new()
    word_input.name = "MainframeWord"
    word_input.position = Vector2(10,66)
    word_input.size = Vector2(228,38)
    word_input.add_theme_font_size_override("font_size",20)
    word_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
    word_input.text_changed.connect(_uppercase)
    word_input.text_submitted.connect(func(_text: String) -> void: _send())
    hack.add_child(word_input)
    send_button = _button(hack,"SEND",Rect2(246,66,74,38),_send)
    send_button.name = "SendMainframeWord"
    cancel_button = _button(hack,"Cancel",Rect2(328,66,82,38),_cancel_word)
    note = _label(self,"",Rect2(14,439,818,38),14)
    verify_button = _button(self,"Reboot & verify",Rect2(14,478,230,30),_verify)
    shortcut_button = _button(self,"Looks fine · stop cleanup",Rect2(254,478,340,30),_close)
    shortcut_button.tooltip_text = "Stops this attempt without curing the PC. Use the ordinary ticket menu for customer pickup."
    refresh()

func _label(parent: Node,text: String,rect: Rect2,font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = rect.position
    label.size = rect.size
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",font_size)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _button(parent: Node,text: String,rect: Rect2,action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.add_theme_font_size_override("font_size",14)
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func refresh() -> void:
    var interactive: bool = model.interactive()
    var reduced: bool = GameState.reduce_flashing
    for item: Dictionary in model.processes:
        var id: String = str(item["id"])
        var state: String = " · stopped" if item["ended"] else ""
        var face: String = ":{)" if id == "watchdog" and model.returns > 0 else str(item["face"])
        var effect: Dictionary = Effects.sample(model, id, reduced)
        row_text[id].text = "%s %s%s" % [face,effect["text"],state]
        row_text[id].position = Vector2(8,2) + effect["offset"]
        row_text[id].add_theme_color_override("font_color", effect["colour"])
        row_text[id].add_theme_font_override("font", italic_font if effect["italic"] else ThemeDB.fallback_font)
        row_buttons[id].set_pressed_no_signal(id == selected)
        row_buttons[id].tooltip_text = str(item["publisher"]) + " / " + str(item["path"])
        row_cpu[id].text = "%d%%" % int(effect["cpu"])
        row_end[id].text = "Stopped" if item["ended"] else "Stop"
        row_end[id].disabled = not interactive or item["ended"]
    var item: Dictionary = model.process(selected)
    details.text = "%s\n\nFrom: %s\nFolder: %s" % [item["detail"],item["publisher"],item["path"]]
    counter.text = "%s · %d night minutes spent · trouble stopped %d / 2 · pressure %.0f%%" % [clock_text,Round.COST_MINUTES,2-model.remaining(),model.overload]
    progress.value = model.overload
    progress.tooltip_text = model.next_step()
    startup_button.disabled = not interactive or not model.startup or selected != "watchdog"
    startup_button.text = "Turn off Start with PC" if model.startup else "Start with PC is off"
    startup_button.tooltip_text = "Select the app that brings unwanted software back, then turn this off."
    scan_button.disabled = not interactive or model.scanned
    scan_button.text = "Scan clues are below" if model.scanned else "Read scan clues"
    clues.text = model.scan_clues() if model.scanned else "1. Read scan clues.\n2. Click an app to read what it does.\n3. Stop the trouble, then reboot."
    advert.visible = model.advert and model.outcome == "running"
    quiet.visible = not advert.visible
    advert_text.text = Round.OFFERS[model.offer % Round.OFFERS.size()]
    advert_close.disabled = not interactive
    var was_hacking: bool = hack.visible
    hack.visible = not model.pending.is_empty()
    if hack.visible:
        hack_title.text = "HACK THE MAINFRAME · TYPE " + str(model.pending["word"])
        hack_status.text = model.status if model.status.begins_with("ACCESS DENIED. Type") else "Desktop paused while typing. No countdown."
        if not was_hacking:
            word_input.text = ""
            word_input.grab_focus()
    pause_button.disabled = not model.pending.is_empty() or model.outcome != "running"
    pause_button.text = "Resume" if model.paused else "Pause"
    note.text = "PAUSED · click apps to read about them, then Resume." if model.paused else model.status
    note.tooltip_text = model.next_step()
    verify_button.disabled = not interactive
    shortcut_button.disabled = not interactive or model.remaining() > 0
    stop_button.text = "Back to monitor" if model.outcome != "running" else "Stop cleanup"
    if model.outcome != "running" and not reported:
        reported = true
        finished.emit()

func _process(delta: float) -> void:
    model.step(delta)
    refresh()

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT and model != null and model.outcome == "running" and model.pending.is_empty():
        model.paused = true

func _select(id: String) -> void:
    selected = id
    refresh()
func _end(id: String) -> void:
    selected = id
    model.end_task(id)
    refresh()
func _startup() -> void:
    model.disable_startup()
    refresh()
func _scan() -> void:
    model.scan()
    refresh()
func _close_ad() -> void:
    model.close_advert()
    refresh()
func _verify() -> void:
    model.verify()
    refresh()
func _pause() -> void:
    model.paused = not model.paused
    refresh()
func _uppercase(text: String) -> void:
    var caret: int = word_input.caret_column
    if text != text.to_upper():
        word_input.text = text.to_upper()
        word_input.caret_column = caret
func _send() -> void:
    model.submit_word(word_input.text)
    refresh()
func _cancel_word() -> void:
    model.cancel_word()
    refresh()
func _close() -> void:
    model.abort()
    refresh()
    closed.emit()
