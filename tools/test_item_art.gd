# 0.57.8: the one picture lookup (scripts/view/item_art.gd) and the approved Batch C files it serves.
# Pure file/lookup checks: every scene that draws an item asks ItemArt, so these pictures are the models.
extends "res://tools/test_support.gd"
const ItemArt = preload("res://scripts/view/item_art.gd")
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const Ids = preload("res://scripts/data/ids.gd")

const FOOTPRINTS: Dictionary = {"gpu": Vector2i(8, 1), "ram": Vector2i(1, 4), "cpu": Vector2i(3, 3), "cooler": Vector2i(2, 2),
    "psu": Vector2i(3, 2), "storage_hdd": Vector2i(2, 1), "storage_ssd": Vector2i(2, 1)}


func _initialize() -> void:
    call_deferred("run_checks")


func run_checks() -> void:
    check(ItemArt.part_name("GPU") == "gpu" and ItemArt.part_name("storage", "Seagait 500 GB HDD") == "storage_hdd" and ItemArt.part_name("storage", "870 EVA 500 GB SSD") == "storage_ssd" and ItemArt.part_name("storage", "990 PRA 1 TB NVMe") == "", "each part kind (and drive type) maps to one picture; an NVMe drive has none yet")
    check(ItemArt.component_name({"category": "COOLER", "display_name": "Stock cooler"}) == "cooler", "board components use the same names")
    var board_ok: bool = true
    for name: String in FOOTPRINTS:
        for turn in range(4):
            var tex: Texture2D = ItemArt.board(name, turn)
            var cells: Vector2i = FOOTPRINTS[name] if turn % 2 == 0 else Vector2i(FOOTPRINTS[name].y, FOOTPRINTS[name].x)
            if tex == null or Vector2i(tex.get_size()) != cells * ItemArt.BOARD_CELL: board_ok = false
    check(board_ok, "every part has its board picture in four turns, exactly 64 px per cell")
    var case_art: Texture2D = ItemArt.case_interior("tower")
    var board_art: Texture2D = ItemArt.board_picture("board_demo_l")
    check(case_art != null and Vector2i(case_art.get_size()) == Vector2i(18, 16) * 64 and board_art != null and Vector2i(board_art.get_size()) == Vector2i(10, 10) * 64, "the open tower case and the demo L board match their cell grids")
    check(ItemArt.case_interior("compact") == null and ItemArt.board_picture("board_compact_step") == null, "layouts without art keep their drawn fallback")
    var spots_ok: bool = true
    for kind: String in ["gpu", "cpu", "ram", "psu", "cooler", "storage"]:
        var pic: Texture2D = ItemArt.inspect(kind)
        if pic == null or Vector2i(pic.get_size()) != Vector2i(900, 600): spots_ok = false
        var names: Array = (ItemArt.INSPECT_SPOTS[kind] as Dictionary).keys()
        names.sort()
        var expected: Array = PartCondition.spots(kind).duplicate()
        expected.sort()
        if names != expected: spots_ok = false
    check(spots_ok, "one inspection picture per part kind, with a lens spot for exactly each inspectable spot")
    var clues_ok: bool = true
    for kind: String in PartCondition.TELLS:
        for condition: String in PartCondition.TELLS[kind]:
            var clue: Texture2D = ItemArt.clue("%s_%s" % [kind, condition])
            var visual: bool = not (kind == "psu" and condition == "broken")    # a smell has no picture
            if visual and (clue == null or Vector2i(clue.get_size()) != Vector2i(900, 600)): clues_ok = false
            if not visual and clue != null: clues_ok = false
        if ItemArt.clue("%s_herring" % kind) == null: clues_ok = false
    check(clues_ok, "every visible fault clue and red herring has its overlay on the inspection canvas")
    var tools_ok: bool = true
    for id: String in [Ids.VACUUM, Ids.BRUSH, Ids.PICK, Ids.SYRINGE, Ids.SCREWDRIVER]:
        var frame: Dictionary = ItemArt.tool_frame(id, 0.0)
        if frame.is_empty() or Vector2i((frame["texture"] as Texture2D).get_size()) != Vector2i(ItemArt.TOOL_FRAME * ItemArt.TOOL_TURNS, ItemArt.TOOL_FRAME): tools_ok = false
    check(tools_ok, "every bench tool has 24 pre-turned pixel frames")
    var quarter: Dictionary = ItemArt.tool_frame(Ids.PICK, PI / 2.0)
    var nudge: Dictionary = ItemArt.tool_frame(Ids.PICK, -0.1)
    check((quarter["region"] as Rect2).position.x == 6 * ItemArt.TOOL_FRAME and absf(float(quarter["rest"])) < 0.0001 and (nudge["region"] as Rect2).position.x == 0 and is_equal_approx(float(nudge["rest"]), -0.1), "a turn picks the nearest frame and leaves only the small remainder to apply")
    check(ItemArt.tool("hose_clamp") is CanvasTexture and (ItemArt.tool("hose_clamp") as CanvasTexture).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and (ItemArt.tool("cloth_tile") as CanvasTexture).texture_repeat == CanvasItem.TEXTURE_REPEAT_ENABLED, "pixel tools stay sharp on any canvas and the cloth texture tiles")
    var layers_ok: bool = true
    for name: String in ["dust/dust_film_light", "dust/dust_film_medium", "dust/dust_film_heavy", "dust/dust_bunny_1", "dust/dust_mote", "paste/paste_socket_stage", "paste/paste_thickness_ramp", "paste/paste_old_dried", "fan/fan_rotor", "fan/fan_frame", "fan/fan_blur"]:
        if ItemArt.bench(name) == null: layers_ok = false
    check(layers_ok and Vector2i(ItemArt.bench("paste/paste_socket_stage").get_size()) == Vector2i(816, 816), "the bench layers are present; the paste stage is the 51-cell grid at 2x")
    finish("Item art")
