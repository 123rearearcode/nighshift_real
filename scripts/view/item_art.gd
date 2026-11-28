# The ONE place every scene asks for an item's picture (0.57.8; user, 25 November 2026: "throughout the
# game, when an item is spawned in a scene, it should use the model of that and be represented either from
# on top or from the side"). A part looks the same in the storage, on the hardware board, on the repair
# bench and in the testing bay because all of them take their picture from here. Pure lookup: no rules.
#
# Views (user, 25 November 2026: stay 2D, top and side drawings):
#   storage  - from on top, 44 px per cell, art/storage/ (ART-10)
#   board    - from on top, 64 px per cell master, art/hardware/parts/ (ART-15); scaled to the scene's cell
#   inspect  - the testing-bay close-up, art/hardware/inspect/ (ART-15), with clue overlays (ART-17)
#   side     - from the side: only the closed customer PC so far (art/props/, ART-09); more when a scene needs it
# Every picture is approved by the user before it is installed (D167; hashes in docs/ART_ASSET_LOG.md).
extends RefCounted

const RoomArt = preload("res://scripts/rooms/room_art.gd")
const HARDWARE_README := "res://art/hardware/README.md"
const BENCH_README := "res://art/bench/README.md"
const TOOLS_README := "res://art/tools/README.md"
const BOARD_CELL: int = 64
const PARTS: Array = ["gpu", "ram", "cpu", "cooler", "psu"]
const TOOL_TURNS: int = 24
const TOOL_FRAME: int = 64                       # native px; shown at 2x
const TOOL_ORIGIN := Vector2(32, 32)            # the tool's own origin inside a frame (native px)
# Where each lens spot sits on its inspection picture, as fractions of the bay's part panel (ART-15).
const INSPECT_SPOTS: Dictionary = {
    "gpu": {"Fans": Vector2(0.333, 0.475), "Power connector": Vector2(0.824, 0.208), "PCIe contacts": Vector2(0.444, 0.75), "Capacitors": Vector2(0.918, 0.583), "Back plate": Vector2(0.511, 0.22)},
    "cpu": {"Contact pads": Vector2(0.622, 0.333), "Heat spreader": Vector2(0.267, 0.5), "Edges": Vector2(0.267, 0.77)},
    "ram": {"Gold contacts": Vector2(0.367, 0.713), "Memory chips": Vector2(0.638, 0.495), "Label": Vector2(0.167, 0.45)},
    "psu": {"Fan grille": Vector2(0.522, 0.5), "Cable ends": Vector2(0.907, 0.5), "Smell": Vector2(0.333, 0.5), "Case vents": Vector2(0.162, 0.5)},
    "cooler": {"Fan blades": Vector2(0.222, 0.4), "Fins": Vector2(0.767, 0.483), "Base plate": Vector2(0.767, 0.667), "Fan cable": Vector2(0.531, 0.79)},
    "storage": {"Connector": Vector2(0.822, 0.5), "Label": Vector2(0.622, 0.4), "Casing": Vector2(0.189, 0.783)},
}

static var _cache: Dictionary = {}


static func _load(path: String) -> Texture2D:
    if not _cache.has(path): _cache[path] = RoomArt.texture(path)
    return _cache[path]


static func _dir(readme: String) -> String:
    return readme.get_base_dir() + "/"


# ---- which picture an item uses ----

# The part's picture name from its kind ("gpu", "storage", ...) and model name. "" = no picture yet.
static func part_name(kind: String, model: String = "") -> String:
    var k: String = kind.to_lower()
    if k in PARTS: return k
    if k == "storage":
        var m: String = model.to_upper()
        if "HDD" in m: return "storage_hdd"
        if "SSD" in m: return "storage_ssd"
    return ""


# Category names used by board components ("RAM", "CPU", "GPU", "STORAGE", "PSU", "COOLER").
static func component_name(part: Dictionary) -> String:
    return part_name(str(part.get("category", part.get("kind", ""))), str(part.get("display_name", part.get("model", ""))))


# ---- views ----

static func storage(name: String, turn: int) -> Texture2D:
    return RoomArt.storage_item(name, turn) if name != "" else null


# From on top at board scale. The board view shows the CPU out of its tray.
static func board(name: String, turn: int) -> Texture2D:
    if name == "": return null
    var file: String = "cpu_bare" if name == "cpu" else name
    return _load("%sparts/%s_r%d.png" % [_dir(HARDWARE_README), file, posmod(turn, 4)])


static func inspect(kind: String) -> Texture2D:
    return _load("%sinspect/inspect_%s.png" % [_dir(HARDWARE_README), kind]) if kind != "" else null


# A clue overlay ("gpu_broken", "ram_herring", ...): shown only once that clue has been seen.
static func clue(name: String) -> Texture2D:
    return _load("%sclues/%s.png" % [_dir(HARDWARE_README), name]) if name != "" else null


static func case_interior(profile_id: String) -> Texture2D:
    if profile_id == "laptop": return _load(_dir(HARDWARE_README) + "case_laptop_interior.png")   # 0.59.1: once approved
    return _load(_dir(HARDWARE_README) + "case_tower_interior.png") if profile_id == "tower" else null


static func board_picture(board_id: String) -> Texture2D:
    if board_id == "board_laptop": return _load(_dir(HARDWARE_README) + "board_laptop.png")   # 0.59.1: once approved
    return _load(_dir(HARDWARE_README) + "board_demo_l.png") if board_id == "board_demo_l" else null


# 0.59.1 (D185): the laptop's heatsink with its heatpipes (4 x 3 cells). Null until the user approves it and
# the file is installed (tools/art_batch_f/laptop.py --runtime); the bench then draws a plain plate.
static func laptop_heatsink() -> Texture2D:
    return _load(_dir(HARDWARE_README) + "laptop_heatsink.png")


static func bench(name: String) -> Texture2D:
    return _load(_dir(BENCH_README) + name + ".png")


# Tools are pixel art: wrapped so they stay sharp (nearest filtering) on any canvas, and can tile.
static func tool(name: String) -> Texture2D:
    return pixel(_load(_dir(TOOLS_README) + name + ".png"), name.ends_with("_tile"))


# An illustrated texture that repeats (dust films): smooth filtering, tiling enabled.
static func tiled(tex: Texture2D) -> Texture2D:
    if tex == null: return null
    var key: String = "tiled:%d" % tex.get_instance_id()
    if not _cache.has(key):
        var wrapped := CanvasTexture.new()
        wrapped.diffuse_texture = tex
        wrapped.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        wrapped.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        _cache[key] = wrapped
    return _cache[key]


# A pixel-art texture that keeps its own nearest filtering whatever canvas draws it.
static func pixel(tex: Texture2D, repeat: bool = false) -> Texture2D:
    if tex == null: return null
    var key: String = "pixel:%d:%s" % [tex.get_instance_id(), repeat]
    if not _cache.has(key):
        var wrapped := CanvasTexture.new()
        wrapped.diffuse_texture = tex
        wrapped.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        if repeat: wrapped.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        _cache[key] = wrapped
    return _cache[key]


# A tool turned by `angle` radians: the nearest of its 24 pre-turned pixel frames, and the angle that is
# left over (|rest| <= 7.5 degrees) for the caller to apply, so the drawing stays crisp.
static func tool_frame(tool_id: String, angle: float) -> Dictionary:
    var sheet: Texture2D = tool("tool_%s_turns" % tool_id)
    if sheet == null: return {}
    var step: float = TAU / TOOL_TURNS
    var index: int = posmod(int(round(angle / step)), TOOL_TURNS)
    return {"texture": sheet, "region": Rect2(index * TOOL_FRAME, 0, TOOL_FRAME, TOOL_FRAME), "rest": angle - round(angle / step) * step}


# Draws a picture filling `rect` (already in the canvas's current transform), smooth or sharp as given.
static func draw(canvas: CanvasItem, tex: Texture2D, rect: Rect2, modulate: Color = Color.WHITE) -> void:
    if tex != null: canvas.draw_texture_rect(tex, rect, false, modulate)
