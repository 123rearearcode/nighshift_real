# The morning report (D136, Wave 3 session 3.2): one card per PC. Collected (reaction, pay, trust),
# came back (a hidden fault surfaced at home), still waiting, or a new ticket. Hover a card to see the
# PC's state as it left or as it stands. Reads NightSession.last_report; changes nothing itself.
extends Node2D
const Navigation = preload("res://scripts/night/night_navigation.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const CARD_SIZE := Vector2(282,170)
const COLORS: Dictionary = {"collected":Color("6fcf97"),"comeback":Color("eb5757"),"waiting":Color("f2c94c"),"new":Color("8eafc3")}
const TITLES: Dictionary = {"collected":"COLLECTED","comeback":"CAME BACK","waiting":"STILL HERE","new":"NEW TICKET"}
var report: Dictionary = {}
var cards: Array[Panel] = []
var detail: Label
var next_button: Button

func _ready() -> void:
    report = NightSession.last_report
    var night: int = int(report.get("night",GameState.night_number-1))
    _label("MORNING AFTER NIGHT %d"%night,Vector2(60,28),Vector2(900,48),30)
    _label("Cash earned this morning: $%d · shop cash now $%d"%[int(report.get("earned",0)),GameState.money],Vector2(60,80),Vector2(1160,32),19)
    var list: Array = report.get("cards",[])
    if list.is_empty():
        _label("Nothing to report.",Vector2(60,140),Vector2(600,32),18)
    for i in range(list.size()):
        cards.append(_card(list[i],Vector2(60+(i%3)*(CARD_SIZE.x+16),130+(i/3)*(CARD_SIZE.y+14))))
    _label("PC DETAILS (hover a card)",Vector2(960,130),Vector2(280,24),15)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(960,158)
    scroll.size = Vector2(292,440)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    detail = Label.new()
    detail.custom_minimum_size = Vector2(270,0)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size",14)
    detail.text = "Hover a card to see the PC as it left the shop, or as it stands now."
    scroll.add_child(detail)
    next_button = Button.new()
    next_button.name = "NextNightButton"
    next_button.text = "Start night %d"%GameState.night_number
    next_button.position = Vector2(960,612)
    next_button.size = Vector2(292,56)
    next_button.add_theme_font_size_override("font_size",20)
    next_button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    next_button.pressed.connect(_next_night)
    add_child(next_button)
    Navigation.pause(self)

func _card(card: Dictionary,at: Vector2) -> Panel:
    var kind: String = str(card.get("kind","new"))
    var panel := Panel.new()
    panel.position = at
    panel.size = CARD_SIZE
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    var style := StyleBoxFlat.new()
    style.bg_color = Color("1d2731")
    style.border_color = COLORS.get(kind,Color.WHITE)
    style.set_border_width_all(2)
    panel.add_theme_stylebox_override("panel",style)
    add_child(panel)
    var text := Label.new()
    text.position = Vector2(10,8)
    text.size = CARD_SIZE-Vector2(20,16)
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    text.clip_text = true
    text.add_theme_font_size_override("font_size",14)
    text.mouse_filter = Control.MOUSE_FILTER_IGNORE
    text.text = card_text(card)
    panel.add_child(text)
    panel.mouse_entered.connect(_show_detail.bind(card))
    return panel

static func card_text(card: Dictionary) -> String:
    var kind: String = str(card.get("kind","new"))
    var lines: Array = ["%s · %s · %s"%[TITLES.get(kind,""),str(card.get("customer","")),str(card.get("ticket",""))],str(card.get("reaction",""))]
    if kind == "collected": lines.append("Paid $%d · trust %+d (now %d)"%[int(card.get("paid",0)),int(card.get("trust_change",0)),int(card.get("trust",0))])
    if kind == "comeback": lines.append("Trust %+d (now %d)"%[int(card.get("trust_change",0)),int(card.get("trust",0))])
    for miss: Variant in card.get("misses",[]): lines.append("· "+str(miss))
    return "\n".join(lines)

# What hovering shows: the PC's state (as collected, or as it stands), never hidden faults.
static func detail_text(card: Dictionary) -> String:
    var job: Dictionary = card.get("job",{})
    if job.is_empty(): return card_text(card)
    var lines: Array = ["%s · %s · %s PC"%[str(job.get("customer","")),str(job.get("id","")),str(job.get("layout","tower")).capitalize()]]
    if card.get("kind","") == "collected": lines.append("As it left the shop (%.0f°C in the shop's own check)."%float(card.get("temp",0.0)))
    else: lines.append("As it stands in your shop.")
    lines.append("")
    lines.append_array(WorkReport.work_lines(job))
    lines.append("")
    lines.append("Parts: "+PartStates.summary(job))
    return "\n".join(lines)

func _show_detail(card: Dictionary) -> void:
    detail.text = detail_text(card)

func _next_night() -> void:
    Navigation.commit(self,Navigation.ACTIVITIES)

func _label(text: String,at: Vector2,area: Vector2,size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",size)
    add_child(label)
    return label

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
