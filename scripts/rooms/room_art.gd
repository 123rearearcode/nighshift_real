# Finds the picture for a room or a customer (0.53.0, D161). Pure lookup, no game rules.
# A picture dropped into the project in the Godot editor is imported and loaded normally. A picture that
# was not imported yet (copied in while the editor was closed) is still read straight from the file, so
# the artist's new art always shows. No picture = null, and the caller draws its placeholder.
extends RefCounted

# Each art folder is named by its README (which says what goes there), so the folders always exist.
const ROOMS_README := "res://art/rooms/README.md"
const CUSTOMERS_README := "res://art/customers/README.md"


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


# A customer's portrait: art/customers/<person id>.png, else art/customers/<profession>.png, else null.
static func customer(person: Dictionary) -> Texture2D:
    for name: String in [str(person.get("id", "")), str(person.get("profession", "")), "customer"]:
        if name == "": continue
        var found: Texture2D = texture(customers_folder() + name + ".png")
        if found != null: return found
    return null
