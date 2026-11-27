# Static drawing commands live on their own CanvasItem; animated parent redraws
# no longer rebuild the case/grid/tray. No physics or input.
extends Node2D
const Layout = preload("res://scripts/data/layout.gd")
const Access = preload("res://scripts/bench/service_access.gd")
const PC = preload("res://scripts/view/pc_renderer.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
# 0.58.8: the user's desk painting, rebuilt for the bench and approved ("Approve, put it in"; hash in the
# folder's manifest.json). Without the file the bench keeps its plain colour.
const BACKGROUND_README := "res://art/bench/background/README.md"
static var _picture: Texture2D = null
static var _looked: bool = false
var clean: bool = true
var profile: String = ""
var area := Rect2()
var background := Color(0.11,0.12,0.15)
var draw_count: int = 0

func configure(is_clean: bool, model: String, rect: Rect2, color: Color) -> void:
    if clean == is_clean and profile == model and area == rect and background == color: return
    clean = is_clean
    profile = model
    area = rect
    background = color
    queue_redraw()

static func picture() -> Texture2D:
    if not _looked:
        _looked = true
        _picture = RoomArt.texture(BACKGROUND_README.get_base_dir() + "/bench_background.png")
    return _picture

func _draw() -> void:
    draw_count += 1
    var art: Texture2D = picture()
    if art != null: draw_texture_rect(art,Layout.SCREEN,false)
    else: draw_rect(Layout.SCREEN,background)
    if not clean: return
    if art == null: draw_rect(Access.TRAY,Color("283644"))   # with the picture, the tray is the mat itself
    draw_rect(Access.TRAY,Color("9ba7a9"),false,2.0)
    draw_string(ThemeDB.fallback_font,Access.TRAY.position+Vector2(8,16),"SERVICE TRAY / move parts here, then refit",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.95,0.95,0.95))
    PC.draw_static_pc(self,profile,area)
