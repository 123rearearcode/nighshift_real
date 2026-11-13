# Silent audio event service. Owns lifecycle/deduplication, not game rules or assets.
# A future playback adapter consumes these signals + the cue registry. No sound is played here.
extends Node
const Cues = preload("res://scripts/data/audio_cues.gd")
signal cue_requested(id: String, context: Dictionary)
signal loop_started(key: String, id: String, context: Dictionary)
signal loop_updated(key: String, id: String, context: Dictionary)
signal loop_stopped(key: String, id: String)
const HISTORY_LIMIT: int = 128
var loops: Dictionary = {}
var history: Array = []
var last_request: Dictionary = {}
var clock_msec: Callable = Time.get_ticks_msec

func _key(owner: Object, id: String) -> String:
    return "%d:%s" % [owner.get_instance_id(),id]

func _record(event: String, id: String) -> void:
    history.append({"event":event,"id":id})
    if history.size() > HISTORY_LIMIT: history.pop_front()

func request(owner: Object, id: String, context: Dictionary = {}) -> bool:
    if not is_instance_valid(owner) or not Cues.CUES.has(id) or bool(Cues.CUES[id]["loop"]): return false
    var key: String = _key(owner,id)
    var now: int = int(clock_msec.call())
    if last_request.has(key) and now-int(last_request[key]) < int(Cues.CUES[id]["cooldown_ms"]): return false
    last_request[key] = now
    if last_request.size() > 512: last_request.erase(last_request.keys()[0])
    _record("cue",id)
    cue_requested.emit(id,context.duplicate(true))
    return true

func set_loop(owner: Object, id: String, enabled: bool, context: Dictionary = {}) -> bool:
    if not is_instance_valid(owner) or not Cues.CUES.has(id) or not bool(Cues.CUES[id]["loop"]): return false
    var key: String = _key(owner,id)
    if not enabled:
        _stop(key)
        return true
    if not loops.has(key):
        loops[key] = {"id":id,"owner":weakref(owner),"context":context.duplicate(true)}
        _record("start",id)
        loop_started.emit(key,id,context.duplicate(true))
    elif loops[key]["context"] != context:
        loops[key]["context"] = context.duplicate(true)
        loop_updated.emit(key,id,context.duplicate(true))
    return true

func _stop(key: String) -> void:
    if not loops.has(key): return
    var id: String = str(loops[key]["id"])
    loops.erase(key)
    _record("stop",id)
    loop_stopped.emit(key,id)

func stop_owner(owner: Object) -> void:
    if not is_instance_valid(owner): return
    var prefix: String = "%d:" % owner.get_instance_id()
    for key: String in loops.keys():
        if key.begins_with(prefix): _stop(key)
    for key: String in last_request.keys():
        if key.begins_with(prefix): last_request.erase(key)

func _process(_delta: float) -> void:
    for key: String in loops.keys():
        if loops[key]["owner"].get_ref() == null: _stop(key)
