# Finds the picture for a room or a customer (0.53.0, D161). Pure lookup, no game rules.
# A picture dropped into the project in the Godot editor is imported and loaded normally. A picture that
# was not imported yet (copied in while the editor was closed) is still read straight from the file, so
# the artist's new art always shows. No picture = null, and the caller draws its placeholder.
extends RefCounted

# Each art folder is named by its README (which says what goes there), so the folders always exist.
const ROOMS_README := "res://art/rooms/README.md"
const CUSTOMERS_README := "res://art/customers/README.md"
const PROPS_README := "res://art/props/README.md"            # 0.57.3: loose objects on top of a room (clipboard, customer PC)
const STORAGE_README := "res://art/storage/README.md"        # 0.57.3: storage pictures, one per item and quarter turn
const UI_README := "res://art/ui/README.md"                  # 0.57.3: close-up skins (the ticket clipboard)
## Pixel-art sprites are painted at half size (native 640 x 360) and always shown at exactly 2x.
const PIXEL_SCALE: int = 2


static func rooms_folder() -> String:
    return ROOMS_README.get_base_dir() + "/"


static func customers_folder() -> String:
    return CUSTOMERS_README.get_base_dir() + "/"


# A room's picture: art/rooms/<name>.png.
static func room(name: String) -> Texture2D:
    return texture(rooms_folder() + name + ".png") if name != "" else null


static func texture(path: String) -> Texture2D:
    if path == "": return null
    if ResourceLoader.exists(path):
        var res: Resource = load(path)
        if res is Texture2D: return res
    if FileAccess.file_exists(path):
        var image := Image.load_from_file(path)
        if image != null and not image.is_empty(): return ImageTexture.create_from_image(image)
    return null


# A prop: art/props/<name>.png (native pixels, shown at PIXEL_SCALE).
static func prop(name: String) -> Texture2D:
    return texture(PROPS_README.get_base_dir() + "/" + name + ".png") if name != "" else null


# A close-up skin: art/ui/<name>.png (native pixels, shown at PIXEL_SCALE).
static func ui(name: String) -> Texture2D:
    return texture(UI_README.get_base_dir() + "/" + name + ".png") if name != "" else null


# A storage picture for one quarter turn: art/storage/<name>_r<0-3>.png. Parts are illustrated at full
# size (44 px per cell); PCs and tools are pixel art at 22 px per cell, shown at PIXEL_SCALE.
static func storage_item(name: String, rotation: int) -> Texture2D:
    return texture("%s/%s_r%d.png" % [STORAGE_README.get_base_dir(), name, posmod(rotation, 4)]) if name != "" else null


# A customer's portrait: art/customers/<person id>.png, else art/customers/<profession>.png, else null.
static func customer(person: Dictionary) -> Texture2D:
    for name: String in [str(person.get("id", "")), str(person.get("profession", "")), "customer"]:
        if name == "": continue
        var found: Texture2D = texture(customers_folder() + name + ".png")
        if found != null: return found
    return null
