# 0.58.9 (D180): the counter's wall finishes. User, 27 November 2026: "i kinda f with all of them. Later on in the
# game, you can change wallpaper, so you start w the second one but all should be included", and (answering) the
# finishes are bought at the store and, once bought, switched for free. The approved pictures byte for byte, the
# starting paint, buying and switching at the store, the counter drawing the chosen wall, saving and loading.
extends "res://tools/test_support.gd"
const Walls = preload("res://scripts/data/wall_finishes.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "wall_finishes_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)

    # ---- the approved pictures ----
    var folder: String = Walls.README.get_base_dir() + "/"
    var approved: Variant = JSON.parse_string(FileAccess.get_file_as_string(folder + "manifest.json"))
    var same: bool = approved is Dictionary and str(approved.get("approval_quote", "")) == "i kinda f with all of them"
    var with_files: int = 0
    for entry: Dictionary in Walls.LIST:
        if str(entry["file"]) == "": continue
        with_files += 1
        if FileAccess.get_sha256(folder + str(entry["file"])) != str(((approved as Dictionary).get("sha256", {}) as Dictionary).get(entry["file"], "")): same = false
    check(same and with_files == 4 and Walls.LIST.size() == 5, "all four approved walls are installed byte for byte, and the old teal tiles stay a choice")

    # ---- starting paint, buying, switching ----
    gs.new_game(false)
    check(gs.wall_finish == "oil_paint" and gs.has_wall("oil_paint") and not gs.has_wall("cream_tiles") and not gs.has_wall("wallpaper"), "a new shop starts with the two-tone oil paint (B)")
    gs.money = 100
    check(not gs.set_wall("cream_tiles") and gs.wall_finish == "oil_paint", "a finish you have not bought cannot be put up")
    check(gs.buy_wall("cream_tiles") and gs.wall_finish == "cream_tiles" and int(gs.money) == 100 - int(Walls.finish("cream_tiles")["price"]), "buying the cream tiles puts them up and costs their price")
    var cash: int = int(gs.money)
    check(gs.buy_wall("oil_paint") and gs.wall_finish == "oil_paint" and int(gs.money) == cash, "going back to the oil paint is free")
    check(gs.buy_wall("cream_tiles") and int(gs.money) == cash, "and back to the tiles you own, free too")
    gs.money = 10
    check(not gs.buy_wall("pine_wallpaper") and gs.wall_finish == "cream_tiles" and int(gs.money) == 10, "without the cash nothing changes")

    # ---- saved and loaded ----
    gs.save_game()
    gs.wall_finish = "oil_paint"
    check(gs.load_game() and gs.wall_finish == "cream_tiles" and gs.has_wall("cream_tiles"), "the wall and what you bought are saved")
    var file := FileAccess.open(gs.save_path, FileAccess.READ)
    var data: Dictionary = JSON.parse_string(file.get_as_text())
    file.close()
    data["wall_finish"] = "blue_plaster"   # never bought
    file = FileAccess.open(gs.save_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()
    check(gs.load_game() and gs.wall_finish == "oil_paint", "a saved wall that was never bought falls back to the oil paint")

    # ---- the store ----
    gs.money = 200
    night.start(gs, false)
    change_scene_to_file("res://scenes/night_shop.tscn")
    for f in range(3): await process_frame
    var shop: Node = current_scene
    check(shop.wall_buttons.size() == 5 and shop.wall_buttons["oil_paint"].disabled and shop.wall_buttons["oil_paint"].text.contains("on the wall") and shop.wall_buttons["blue_plaster"].text.contains("$40"), "the store lists every wall; the one up is marked")
    shop.wall_buttons["blue_plaster"].emit_signal("pressed")
    check(gs.wall_finish == "blue_plaster" and int(gs.money) == 160 and shop.wall_buttons["blue_plaster"].disabled and shop.wall_buttons["oil_paint"].text.contains("put up"), "buying the blue plaster at the store puts it up; the oil paint can go back up")
    var overlap: bool = false
    var rects: Array = []
    for child: Node in shop.get_children():
        if child is Button and child.visible: rects.append(child.get_global_rect())
    for i in range(rects.size()):
        for j in range(i + 1, rects.size()):
            if rects[i].intersects(rects[j]): overlap = true
    check(not overlap and shop.wall_buttons["teal_tiles"].get_global_rect().end.y < 640.0, "the store's buttons do not overlap and the walls fit above the message line")

    # ---- the counter draws it ----
    change_scene_to_file(Nav.COUNTER)
    for f in range(3): await process_frame
    var counter: Node = current_scene
    check(counter.counter_art.wall_finish == "blue_plaster" and counter.counter_art.wall_picture("blue_plaster") != null and counter.counter_art.wall_picture("teal_tiles") == null, "the counter room shows the wall you put up (the teal tiles are the shell's own wall)")
    var pic: Texture2D = counter.counter_art.wall_picture("oil_paint")
    check(pic != null and pic.get_size() == Vector2(1280, 505), "a wall picture covers the room down to the floor line, 1:1")
    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Wall finishes")
