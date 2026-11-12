# STATE LAYER helper: reads and writes the save file as JSON. Knows nothing about what is in it;
# GameState decides what to save and how to validate what it loads.
# Safe writing (0.11.2): the new save is written to "<path>.tmp" and read back first; only if it
# parses is the old save moved to "<path>.bak" and the new one moved into place. So a crash or a full
# disk while saving cannot destroy the previous save. Reading falls back to .bak, then .tmp, if the
# main file is missing or damaged. The .bak is just the previous save, not a long-term backup.
extends RefCounted


static func _parse(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        return null
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null
    var json := JSON.new()   # JSON.new().parse() fails quietly; JSON.parse_string() prints an engine error
    if json.parse(file.get_as_text()) != OK:
        return null
    return json.data


# Write `data` as JSON to `path`. Returns false (with a warning) if it could not be saved safely;
# in that case the previous save is left untouched.
static func write(path: String, data: Dictionary) -> bool:
    var tmp: String = path + ".tmp"
    var bak: String = path + ".bak"
    var file: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
    if file == null:
        push_warning("Could not save game: error %d" % FileAccess.get_open_error())
        return false
    file.store_string(JSON.stringify(data, "  "))
    file.close()
    if typeof(_parse(tmp)) != TYPE_DICTIONARY:
        push_warning("Could not save game: the new save did not read back correctly; the previous save was kept.")
        DirAccess.remove_absolute(tmp)
        return false
    if FileAccess.file_exists(path):
        if FileAccess.file_exists(bak):
            DirAccess.remove_absolute(bak)
        var moved: Error = DirAccess.rename_absolute(path, bak)
        if moved != OK:
            push_warning("Could not save game: could not keep the previous save (error %d)." % moved)
            DirAccess.remove_absolute(tmp)
            return false
    var placed: Error = DirAccess.rename_absolute(tmp, path)
    if placed != OK:
        push_warning("Could not save game: could not move the new save into place (error %d). The previous save is at %s." % [placed, bak])
        return false
    return true


# Read the save at `path`. Returns the parsed Dictionary from the first of path, path.bak, path.tmp
# that parses to one, or null if none does. Warns when it had to use a fallback or found damage.
static func read(path: String) -> Variant:
    var candidates: Array = [path, path + ".bak", path + ".tmp"]
    var saw_file: bool = false
    for i in range(candidates.size()):
        var candidate: String = candidates[i]
        if not FileAccess.file_exists(candidate):
            continue
        saw_file = true
        var parsed: Variant = _parse(candidate)
        if typeof(parsed) == TYPE_DICTIONARY:
            if i > 0:
                push_warning("Save file was missing or damaged; recovered from %s." % candidate)
            return parsed
    if saw_file:
        push_warning("Save file(s) exist but none could be read; starting without them.")
    return null
