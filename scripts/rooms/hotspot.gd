@tool
# A clickable spot on a room's picture (0.53.0, D161: the game moves through places and objects, not menus).
#
# FOR THE ARTIST (docs/ROOM_ART_GUIDE.md): every hotspot is a plain rectangle you can move and resize in the
# Godot editor. Open the room's scene (scenes/rooms/<room>.tscn), select a hotspot under "Hotspots" and drag
# its edges over the object you painted. Its "Art Hint" says what belongs there. Nothing else needs code.
# In the editor every hotspot shows as a labelled box; in the game it is invisible over your art and lights
# up when the mouse is over it. Press F3 in the game to see every hotspot's outline.
#
# What a hotspot does is its `action` text, read by the room (room_view.gd):
#   go:<place>      walk there: counter, workshop, outside, stock, repair, hardware, monitor, bay, salvage, shop
#   open:<thing>    open something here (the room decides: phone, tickets, till, board, ...)
#   end_night       the shutter: close the shop for the night
#   later:<idea>    a planned feature; clicking says it is coming later
extends Button

## What clicking does (see the list at the top of this script).
@export var action: String = ""
## The name shown when the mouse is over it (and on the placeholder box when the room has no art yet).
@export var label: String = "":
    set(value):
        label = value
        queue_redraw()
## For the artist: what to paint under this hotspot.
@export_multiline var art_hint: String = ""
## Placeholder box colour, used only until the room has its art.
@export var placeholder_color: Color = Color("3b4853"):
    set(value):
        placeholder_color = value
        queue_redraw()
## At 06:00 the night is over: hotspots that start new work close (doors to work, the salvage run).
@export var closed_at_dawn: bool = false
## 0.57.3: a loose object drawn on this spot, art/props/<name>.png (pixel art, shown at 2x, centred).
## Props are separate from the room picture (the clipboard is not painted into the counter art).
@export var prop: String = "":
    set(value):
        prop = value
        _prop_cache.clear()
        queue_redraw()
## Optional: the prop shown while the mouse is over the spot (the clipboard, picked up).
@export var prop_hover: String = "":
    set(value):
        prop_hover = value
        _prop_cache.clear()
        queue_redraw()

var placeholder: bool = true    # set by the room: true while the room has no picture
var outline: bool = false       # F3: show every hotspot's outline
var badge: String = ""          # a short live line under the placeholder label ("$120", "3 tickets")
var hovered: bool = false
var _prop_cache: Dictionary = {}
const PROPS_README := "res://art/props/README.md"


func _ready() -> void:
    flat = true
    text = ""
    focus_mode = Control.FOCUS_NONE
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    for style: String in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
        add_theme_stylebox_override(style, StyleBoxEmpty.new())
    if tooltip_text == "": tooltip_text = label
    mouse_entered.connect(func() -> void:
        hovered = true
        queue_redraw())
    mouse_exited.connect(func() -> void:
        hovered = false
        queue_redraw())
    resized.connect(queue_redraw)
    if prop != "": texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


# The prop's picture (loaded here rather than through room_art.gd so it also shows in the editor).
func prop_texture(name: String) -> Texture2D:
    if name == "": return null
    if not _prop_cache.has(name):
        var path: String = "%s/%s.png" % [PROPS_README.get_base_dir(), name]
        var found: Texture2D = null
        if ResourceLoader.exists(path):
            var res: Resource = load(path)
            if res is Texture2D: found = res
        if found == null and FileAccess.file_exists(path):
            var image := Image.load_from_file(path)
            if image != null and not image.is_empty(): found = ImageTexture.create_from_image(image)
        _prop_cache[name] = found
    return _prop_cache[name]


# The prop being shown now (the hover picture while hovered, when there is one).
func shown_prop() -> Texture2D:
    var hover_tex: Texture2D = prop_texture(prop_hover) if hovered and not disabled else null
    return hover_tex if hover_tex != null else prop_texture(prop)


func set_badge(value: String) -> void:
    if badge == value: return
    badge = value
    queue_redraw()


func _draw() -> void:
    var r := Rect2(Vector2.ZERO, size)
    var font: Font = ThemeDB.fallback_font
    var editor: bool = Engine.is_editor_hint()
    var art: Texture2D = shown_prop()
    if editor or (placeholder and art == null):     # a spot with its own prop shows the prop, not a box
        var fill: Color = placeholder_color
        if editor and (not placeholder or art != null): fill.a = 0.35
        if disabled and not editor: fill = fill.darkened(0.45)
        draw_rect(r, fill)
        draw_rect(r, fill.lightened(0.35), false, 2.0)
        var lines: Array = [label] + ([badge] if badge != "" and not editor else []) + ([action] if editor else [])
        var y: float = r.size.y * 0.5 - (lines.size() - 1) * 9.0
        for line: Variant in lines:
            var font_size: int = 15 if line == label else 12
            var width: float = font.get_string_size(str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
            draw_string(font, Vector2((r.size.x - width) * 0.5, y + 5.0), str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
                Color("e8eef2") if not disabled or editor else Color("8a959c"))
            y += 18.0
    if art != null:
        var shown := Vector2(art.get_size()) * 2.0
        draw_texture_rect(art, Rect2(((r.size - shown) * 0.5).round(), shown), false, Color(0.6, 0.6, 0.6) if disabled and not editor else Color.WHITE)
    if hovered and not disabled and not editor:
        draw_rect(r.grow(2.0), Color("ffd27a"), false, 3.0)
        var tag: String = label + ("" if badge == "" or (placeholder and art == null) else "  ·  " + badge)
        var tag_width: float = font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 16.0
        var at := Vector2(clampf((r.size.x - tag_width) * 0.5, -position.x + 4.0, 1276.0 - position.x - tag_width), -28.0 if position.y > 30.0 else r.size.y + 4.0)
        draw_rect(Rect2(at, Vector2(tag_width, 24.0)), Color(0.07, 0.08, 0.1, 0.92))
        draw_string(font, at + Vector2(8.0, 17.0), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("ffd27a"))
    elif outline and not editor:
        draw_rect(r, Color("ff5fd2"), false, 1.5)
