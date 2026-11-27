# STATE LAYER helper (0.58.2, B59; B63). Morning backups of one save and their restore.
# User, 27 November 2026: "automatically save every morning, and keep backups up to 3 days before", and
# when the ticket book is damaged, "try to restore it".
# A backup is a copy of the save's own files as they were when the morning began: the main save, the
# ticket manifest (".night.json") and the room memory (".navigation.json"). Backups are kept PER
# PLAYTHROUGH (the night session's run id): backups/<save name>/run_<run>/morning_<night>/. Only the newest
# KEEP mornings of a playthrough are kept, and only the newest ARCHIVED_RUNS earlier playthroughs (B63: a
# new game must never lose its own first morning to an older game's later nights, and a restore only ever
# looks at the playthrough being recovered).
# Restoring never deletes anything: the files being replaced are moved to backups/<save name>/damaged_<time>/
# first, and any failure while moving or copying puts the original files back.
# Knows nothing about what is in the files; NightSession decides whether a restored set is usable.
extends RefCounted

const KEEP: int = 3
const ARCHIVED_RUNS: int = 1
const SUFFIXES: Array = ["", ".night.json", ".navigation.json"]
const PREFIX := "morning_"
const RUN_PREFIX := "run_"
const STAMP := "last_backup.txt"


static func folder(save_path: String) -> String:
    return save_path.get_base_dir().path_join("backups").path_join(save_path.get_file().get_basename())


static func run_folder(save_path: String, run: String) -> String:
    var safe: String = run.validate_filename() if run != "" else "unbound"
    return folder(save_path).path_join(RUN_PREFIX + safe)


# Copies this morning's files for playthrough `run`. `night` is the night about to begin. Returns false if
# the main save could not be copied (the earlier backups are kept either way).
static func take(save_path: String, run: String, night: int) -> bool:
    if not FileAccess.file_exists(save_path): return false
    var dir: String = run_folder(save_path, run).path_join(PREFIX + "%04d" % night)
    if DirAccess.dir_exists_absolute(dir): remove_tree(dir)
    if DirAccess.make_dir_recursive_absolute(dir) != OK: return false
    for suffix: String in SUFFIXES:
        var from: String = save_path + suffix
        if not FileAccess.file_exists(from): continue
        if DirAccess.copy_absolute(from, dir.path_join(save_path.get_file() + suffix)) != OK and suffix == "":
            push_warning("Could not back up the save for the morning of night %d." % night)
            remove_tree(dir)
            return false
    var stamp := FileAccess.open(run_folder(save_path, run).path_join(STAMP), FileAccess.WRITE)
    if stamp != null:
        stamp.store_string(str(Time.get_unix_time_from_system()))   # sub-second: orders playthroughs reliably
        stamp.close()
    _prune(save_path, run)
    return true


# The kept mornings of playthrough `run`, newest first ("morning_0004", ...).
static func mornings(save_path: String, run: String) -> Array:
    var found: Array = []
    var dir: String = run_folder(save_path, run)
    if not DirAccess.dir_exists_absolute(dir): return found
    for name: String in DirAccess.get_directories_at(dir):
        if name.begins_with(PREFIX) and FileAccess.file_exists(dir.path_join(name).path_join(save_path.get_file())):
            found.append(name)
    found.sort()
    found.reverse()
    return found


static func night_of(morning: String) -> int:
    return int(morning.trim_prefix(PREFIX))


# The playthroughs with backups ("run_<id>" folder names), most recently backed up first.
static func runs(save_path: String) -> Array:
    var base: String = folder(save_path)
    if not DirAccess.dir_exists_absolute(base): return []
    var found: Array = Array(DirAccess.get_directories_at(base)).filter(func(name: String) -> bool: return name.begins_with(RUN_PREFIX))
    found.sort_custom(func(a: String, b: String) -> bool: return _last_backup_time(base.path_join(a)) > _last_backup_time(base.path_join(b)))
    return found


# Puts one morning of playthrough `run` back in place of the current files. The current files (and their
# .bak/.tmp) are moved aside first, never deleted. Returns the folder they were moved to, or "" with the
# current files unchanged (put back if anything failed half way).
static func restore(save_path: String, run: String, morning: String) -> String:
    var source: String = run_folder(save_path, run).path_join(morning)
    if not FileAccess.file_exists(source.path_join(save_path.get_file())): return ""
    var aside: String = set_aside(save_path)
    if aside == "": return ""
    if not copy_in(save_path, source):
        put_back(save_path, aside)
        return ""
    return aside


# Moves the save's current files (and their .bak/.tmp) into a new backups/<save>/damaged_<time>/ folder.
# If one cannot be moved, the ones already moved go back and "" is returned.
static func set_aside(save_path: String) -> String:
    var aside: String = folder(save_path).path_join("damaged_%d_%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()])
    if DirAccess.make_dir_recursive_absolute(aside) != OK: return ""
    var moved: Array = []
    for suffix: String in SUFFIXES:
        for extra: String in ["", ".bak", ".tmp"]:
            var current: String = save_path + suffix + extra
            if not FileAccess.file_exists(current): continue
            if DirAccess.rename_absolute(current, aside.path_join(current.get_file())) != OK:
                for path: String in moved: DirAccess.rename_absolute(aside.path_join(path.get_file()), path)
                remove_tree(aside)
                return ""
            moved.append(current)
    return aside


# Copies every one of this save's files found in `from` (a morning or a set-aside folder) into place.
static func copy_in(save_path: String, from: String) -> bool:
    var ok: bool = true
    for file: String in DirAccess.get_files_at(from):
        if file.begins_with(save_path.get_file()):
            ok = DirAccess.copy_absolute(from.path_join(file), save_path.get_base_dir().path_join(file)) == OK and ok
    return ok


# Replaces whatever is in place with the files kept in `aside` (they stay in `aside` as well).
static func put_back(save_path: String, aside: String) -> bool:
    for suffix: String in SUFFIXES:
        for extra: String in ["", ".bak", ".tmp"]:
            if FileAccess.file_exists(save_path + suffix + extra): DirAccess.remove_absolute(save_path + suffix + extra)
    return copy_in(save_path, aside)


static func remove_tree(dir: String) -> void:
    if not DirAccess.dir_exists_absolute(dir): return
    for sub: String in DirAccess.get_directories_at(dir): remove_tree(dir.path_join(sub))
    for file: String in DirAccess.get_files_at(dir): DirAccess.remove_absolute(dir.path_join(file))
    DirAccess.remove_absolute(dir)


static func _prune(save_path: String, run: String) -> void:
    var kept: Array = mornings(save_path, run)
    for i in range(KEEP, kept.size()):
        remove_tree(run_folder(save_path, run).path_join(str(kept[i])))
    var current: String = run_folder(save_path, run).get_file()
    var others: Array = runs(save_path).filter(func(name: String) -> bool: return name != current)
    for i in range(ARCHIVED_RUNS, others.size()):
        remove_tree(folder(save_path).path_join(str(others[i])))


static func _last_backup_time(run_dir: String) -> float:
    var path: String = run_dir.path_join(STAMP)
    return float(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else 0.0
