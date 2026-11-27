# STATE LAYER helper (0.57.11, B59). Morning backups of one save and their restore.
# User, 27 November 2026: "automatically save every morning, and keep backups up to 3 days before", and
# when the ticket book is damaged, "try to restore it".
# A backup is a copy of the save's own files as they were when the morning began: the main save, the
# ticket manifest (".night.json") and the room memory (".navigation.json"). It lives next to the save in
# backups/<save name>/morning_<night>/. Only the newest KEEP mornings are kept. Restoring never deletes
# anything: the files being replaced are moved to backups/<save name>/damaged_<time>/ first.
# Knows nothing about what is in the files; NightSession decides whether a restored set is usable.
extends RefCounted

const KEEP: int = 3
const SUFFIXES: Array = ["", ".night.json", ".navigation.json"]
const PREFIX := "morning_"


static func folder(save_path: String) -> String:
    return save_path.get_base_dir().path_join("backups").path_join(save_path.get_file().get_basename())


# Copies this morning's files. `night` is the night about to begin. Returns false if the main save could
# not be copied (the previous backups are kept either way).
static func take(save_path: String, night: int) -> bool:
    if not FileAccess.file_exists(save_path): return false
    var dir: String = folder(save_path).path_join(PREFIX + "%04d" % night)
    if DirAccess.dir_exists_absolute(dir): _clear(dir)
    if DirAccess.make_dir_recursive_absolute(dir) != OK: return false
    for suffix: String in SUFFIXES:
        var from: String = save_path + suffix
        if not FileAccess.file_exists(from): continue
        if DirAccess.copy_absolute(from, dir.path_join(save_path.get_file() + suffix)) != OK:
            if suffix == "":
                push_warning("Could not back up the save for the morning of night %d." % night)
                return false
    _prune(save_path)
    return true


# The kept mornings, newest first ("morning_0004", ...).
static func mornings(save_path: String) -> Array:
    var found: Array = []
    var dir: String = folder(save_path)
    if not DirAccess.dir_exists_absolute(dir): return found
    for name: String in DirAccess.get_directories_at(dir):
        if name.begins_with(PREFIX) and FileAccess.file_exists(dir.path_join(name).path_join(save_path.get_file())):
            found.append(name)
    found.sort()
    found.reverse()
    return found


static func night_of(morning: String) -> int:
    return int(morning.trim_prefix(PREFIX))


# Puts one morning's files back in place of the current ones. The current files (and their .bak/.tmp)
# are moved aside first, never deleted. Returns the folder they were moved to, or "" (changing nothing)
# if the backup has no main save or the current files could not be moved.
static func restore(save_path: String, morning: String) -> String:
    var source: String = folder(save_path).path_join(morning)
    if not FileAccess.file_exists(source.path_join(save_path.get_file())): return ""
    var aside: String = set_aside(save_path)
    if aside == "": return ""
    copy_in(save_path, source)
    return aside


# Moves the save's current files (and their .bak/.tmp) into a new backups/<save>/damaged_<time>/ folder.
static func set_aside(save_path: String) -> String:
    var aside: String = folder(save_path).path_join("damaged_%d_%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()])
    if DirAccess.make_dir_recursive_absolute(aside) != OK: return ""
    for suffix: String in SUFFIXES:
        for extra: String in ["", ".bak", ".tmp"]:
            var current: String = save_path + suffix + extra
            if FileAccess.file_exists(current) and DirAccess.rename_absolute(current, aside.path_join(current.get_file())) != OK:
                return ""
    return aside


# Copies every one of this save's files found in `from` (a morning or a set-aside folder) into place.
static func copy_in(save_path: String, from: String) -> bool:
    var ok: bool = true
    for file: String in DirAccess.get_files_at(from):
        if file.begins_with(save_path.get_file()):
            ok = DirAccess.copy_absolute(from.path_join(file), save_path.get_base_dir().path_join(file)) == OK and ok
    return ok


static func _prune(save_path: String) -> void:
    var kept: Array = mornings(save_path)
    for i in range(KEEP, kept.size()):
        _clear(folder(save_path).path_join(str(kept[i])))


static func _clear(dir: String) -> void:
    for file: String in DirAccess.get_files_at(dir):
        DirAccess.remove_absolute(dir.path_join(file))
    DirAccess.remove_absolute(dir)
