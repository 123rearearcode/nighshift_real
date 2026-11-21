# PRESENTATION: a small card that fades in near the mouse.
# It only displays the title and lines it is given; it knows nothing about hardware.
extends Node2D
const Layout = preload("res://scripts/data/layout.gd")

const PADDING: float = 10.0
const LINE_HEIGHT: float = 20.0
const FADE_SPEED: float = 7.0
const SCREEN_SIZE: Vector2 = Layout.SCREEN_SIZE

var font: Font
var title: String = ""
var lines: Array = []
var anchor: Vector2 = Vector2.ZERO
var wanted: bool = false
var card_size: Vector2 = Vector2.ZERO


func _ready() -> void:
    font = ThemeDB.fallback_font
    z_index = 100
    modulate.a = 0.0


func show_card(new_title: String, new_lines: Array, mouse_pos: Vector2) -> void:
    title = new_title
    lines = new_lines
    anchor = mouse_pos
    wanted = true
    var width: float = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
    for line in lines:
        width = maxf(width, font.get_string_size(str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x)
    card_size = Vector2(width + PADDING * 2.0, PADDING * 2.0 + 24.0 + LINE_HEIGHT * lines.size())
    queue_redraw()


func hide_card() -> void:
    wanted = false


func _process(delta: float) -> void:
    var target: float = 1.0 if wanted else 0.0
    if modulate.a != target:
        modulate.a = move_toward(modulate.a, target, delta * FADE_SPEED)


func _draw() -> void:
    if title == "":
        return
    var pos: Vector2 = anchor + Vector2(18, 18)
    pos.x = minf(pos.x, SCREEN_SIZE.x - card_size.x - 4.0)
    pos.y = minf(pos.y, SCREEN_SIZE.y - card_size.y - 4.0)
    var rect := Rect2(pos, card_size)
    draw_rect(rect, Color(0.07, 0.08, 0.11, 0.96))
    draw_rect(rect, Color(0.85, 0.85, 0.95), false, 2.0)
    draw_string(font, pos + Vector2(PADDING, PADDING + 14.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.85, 0.35))
    var y: float = PADDING + 24.0 + 14.0
    for line in lines:
        draw_string(font, pos + Vector2(PADDING, y), str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.92, 0.92, 0.92))
        y += LINE_HEIGHT
