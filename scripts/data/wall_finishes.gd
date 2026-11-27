# DATA ONLY (0.58.9, D180): the counter room's wall finishes. The user, 27 November 2026, on the four wall drafts:
# "i kinda f with all of them. Later on in the game, you can change wallpaper, so you start w the second one but
# all should be included", and (answering) the finishes are bought at the store; once bought you can switch
# back and forth for free. The shop starts with B, the two-tone oil paint. The old teal tiles stay a choice.
# Pictures: art/rooms/counter_walls/ (approved; hashes in its manifest). Prices are proposals.
extends RefCounted

const README := "res://art/rooms/counter_walls/README.md"
const DEFAULT := "oil_paint"
const LIST: Array = [
    {"id": "oil_paint", "label": "Two-tone oil paint", "short": "Oil paint", "file": "wall_oil_paint.png", "price": 0,
        "blurb": "Whitewash over glossy green paint. The shop's walls when you start."},
    {"id": "cream_tiles", "label": "Cream faience tiles", "short": "Cream tiles", "file": "wall_cream_tiles.png", "price": 60,
        "blurb": "Cream tiles with a brown band at waist height."},
    {"id": "pine_wallpaper", "label": "Pine panelling, 70s wallpaper", "short": "Pine & wallpaper", "file": "wall_pine_wallpaper.png", "price": 80,
        "blurb": "Varnished pine boards below, ochre wallpaper with orange circles above."},
    {"id": "blue_plaster", "label": "Pale blue plaster", "short": "Blue plaster", "file": "wall_blue_plaster.png", "price": 40,
        "blurb": "Cracked blue plaster with a dark painted skirting."},
    {"id": "teal_tiles", "label": "Teal tiles", "short": "Teal tiles", "file": "", "price": 20,
        "blurb": "The old teal tiles, as the shop was first painted."},
]


static func finish(id: String) -> Dictionary:
    for entry: Dictionary in LIST:
        if entry["id"] == id: return entry
    return {}


static func upgrade_id(id: String) -> String:
    return "wall_" + id


static func path(id: String) -> String:
    var file: String = str(finish(id).get("file", ""))
    return README.get_base_dir() + "/" + file if file != "" else ""
