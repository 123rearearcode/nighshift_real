extends "res://tools/test_support.gd"
const Nav = preload("res://scripts/night/night_navigation.gd")
const Art = preload("res://scripts/rooms/counter_art.gd")

func _initialize() -> void:
    call_deferred("measure")

func measure() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "counter_load_measure.json")
    gs.new_game(false)
    check(night.start(gs, false), "disposable night starts")
    var art_times: Array = []
    var texture_ids: Array = []
    for i in range(4):
        var start: int = Time.get_ticks_usec()
        var art = Art.new()
        art_times.append((Time.get_ticks_usec() - start) / 1000.0)
        texture_ids.append(art.textures["shell"].get_instance_id())
        check(art.available() and art.termopan_ready(), "all approved art is available")
        art = null
        await process_frame
    var scene_times: Array = []
    var scene_texture_ids: Array = []
    var static_memory: Array = []
    for i in range(5):
        var start: int = Time.get_ticks_usec()
        check(change_scene_to_file(Nav.COUNTER) == OK, "counter changes")
        await process_frame
        while current_scene == null: await process_frame
        scene_times.append((Time.get_ticks_usec() - start) / 1000.0)
        scene_texture_ids.append(current_scene.counter_art.textures["shell"].get_instance_id())
        static_memory.append(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0)
        for f in range(2): await process_frame
        check(change_scene_to_file(Nav.WORKSHOP) == OK, "workshop changes")
        for f in range(4): await process_frame
    print("COUNTER_LOADING " + JSON.stringify({"version": ProjectSettings.get_setting("application/config/version"), "art_construct_ms": art_times, "art_texture_ids": texture_ids, "counter_scene_ms": scene_times, "counter_texture_ids": scene_texture_ids, "counter_static_memory_mib": static_memory, "mode": "headless CPU scene setup, not GPU frame-present latency"}))
    restore_save(gs)
    for suffix: String in [".night.json", ".navigation.json", ".cables.json"]: _remove_save_files("user://counter_load_measure.json" + suffix)
    finish("Counter loading measurement")
