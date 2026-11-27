# 0.58.9 (D181): spoken lines that unroll. The user, 27 November 2026: "when a customer comes in, you should be
# able to click/space for dialogue to unroll. so dialogue needs to be work in that way, as the game will be
# story driven anyhow."
#
# One line at a time, typed out letter by letter. A click anywhere below the top bar, Space or Enter finishes the
# line being typed; the next click or key goes to the next line; after the last line the box closes and
# `finished` is emitted. A line is a String (said by the current speaker) or {"speaker": ..., "text": ...}, so
# later scenes can switch speakers (the player answering, a second customer). The catcher behind the box takes
# those clicks, so nothing in the room underneath is clicked by accident while someone is talking; the top bar
# (Pause, the way back) stays usable.
extends Control

signal finished
signal line_started(index: int)

const CHARS_PER_SECOND := 48.0
const BOX := Rect2(300, 552, 680, 148)
const TOP_BAR := 70.0                     # Pause and the way back stay clickable above this

var lines: Array = []
var index: int = -1
var speaker: String = ""
var shown: float = 0.0
var active: bool = false
var panel: Panel
var name_label: Label
var text_label: Label
var hint: Label


func _ready() -> void:
    name = "Dialogue"
    position = Vector2(0, TOP_BAR)
    size = Vector2(1280, 720 - TOP_BAR)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 40
    panel = Panel.new()
    panel.name = "DialogueBox"
    panel.position = BOX.position - position
    panel.size = BOX.size
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.07, 0.08, 0.10, 0.92)
    style.border_color = Color("e1d7bd")
    style.set_border_width_all(2)
    style.set_corner_radius_all(4)
    panel.add_theme_stylebox_override("panel", style)
    add_child(panel)
    name_label = _text(Vector2(18, 10), Vector2(BOX.size.x - 36, 26), 17, Color("f0c06a"))
    text_label = _text(Vector2(18, 40), Vector2(BOX.size.x - 36, 78), 20, Color("f2eee4"))
    hint = _text(Vector2(BOX.size.x - 230, BOX.size.y - 30), Vector2(214, 22), 14, Color("b9b2a0"))
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hide()


func _text(at: Vector2, area: Vector2, font_size: int, colour: Color) -> Label:
    var label := Label.new()
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", colour)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(label)
    return label


# Start talking. Empty `say` finishes at once.
func play(who: String, say: Array) -> void:
    speaker = who
    lines = say.filter(func(line: Variant) -> bool: return _line_text(line) != "")
    index = -1
    active = true
    show()
    _next()


func typing() -> bool:
    return active and shown < float(current_text().length())


func current_text() -> String:
    return _line_text(lines[index]) if index >= 0 and index < lines.size() else ""


func current_speaker() -> String:
    if index >= 0 and index < lines.size() and lines[index] is Dictionary:
        return str((lines[index] as Dictionary).get("speaker", speaker))
    return speaker


# Click, Space or Enter: finish the line being typed, else go on.
func advance() -> void:
    if not active: return
    if typing():
        shown = float(current_text().length())
        _show()
    else:
        _next()


# Close at once (tests, or a scene that must interrupt).
func skip_all() -> void:
    if not active: return
    index = lines.size()
    _close()


func _next() -> void:
    index += 1
    if index >= lines.size():
        _close()
        return
    shown = 0.0
    name_label.text = current_speaker()
    _show()
    line_started.emit(index)


func _close() -> void:
    active = false
    hide()
    finished.emit()


func _show() -> void:
    text_label.text = current_text()
    text_label.visible_characters = int(shown) if typing() else -1
    hint.text = "click or Space ▸" if not typing() else ""
    if not typing() and index == lines.size() - 1: hint.text = "click or Space ✓"


func _process(delta: float) -> void:
    if not active or not typing(): return
    shown = minf(float(current_text().length()), shown + CHARS_PER_SECOND * delta)
    _show()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        advance()
        accept_event()


func _unhandled_input(event: InputEvent) -> void:
    if not active: return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
        advance()
        get_viewport().set_input_as_handled()


static func _line_text(line: Variant) -> String:
    if line is Dictionary: return str((line as Dictionary).get("text", ""))
    return str(line) if line != null else ""
