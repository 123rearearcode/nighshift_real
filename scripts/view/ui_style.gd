# Presentation helpers shared by the renderers and views: colours, text and progress bars.
# Presentation only; no rules, physics or input here.
extends RefCounted

const COLOR_TEXT := Color(0.95, 0.95, 0.95)
const TONE_COLORS := [Color(0.92, 0.92, 0.92), Color(0.25, 0.95, 0.35), Color(1.0, 0.8, 0.25), Color(1.0, 0.3, 0.3)]


static func label(canvas: CanvasItem, pos: Vector2, message: String, size: int = 16, color: Color = COLOR_TEXT) -> void:
    canvas.draw_string(ThemeDB.fallback_font, pos, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


# A filled progress bar. `mark` (0..1, optional) draws a white target line across it.
static func bar(canvas: CanvasItem, rect: Rect2, fraction: float, color: Color, mark: float = -1.0) -> void:
    canvas.draw_rect(rect, Color(0.2, 0.2, 0.24))
    canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0.0, 1.0), rect.size.y)), color)
    canvas.draw_rect(rect, Color(0.8, 0.8, 0.85), false, 2.0)
    if mark >= 0.0:
        var mx: float = rect.position.x + rect.size.x * mark
        canvas.draw_line(Vector2(mx, rect.position.y - 4.0), Vector2(mx, rect.end.y + 4.0), Color(1, 1, 1, 0.85), 2.0)
