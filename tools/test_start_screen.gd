# Menu integration test. Dedicated save path; never writes the player's save.
extends "res://tools/test_support.gd"
const Store = preload("res://scripts/state/save_store.gd")

func _initialize() -> void:
    call_deferred("run_checks")


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var original_path: String = gs.save_path
    gs.save_path = "user://start_screen_test_only.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(gs.save_path + suffix)
    gs.new_game(false)
    check(not gs.has_saved_game(), "initialising a new session does not manufacture a save")
    check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/start.tscn", "normal launch enters start screen")
    change_scene_to_file("res://scenes/start.tscn")
    await process_frame
    await process_frame
    check(current_scene.load_button.disabled, "Load game is disabled without a readable save")
    var menu: Node = current_scene
    menu._on_achievements()
    check(menu.achievements_dialog.visible and current_scene == menu, "Achievements opens a clearly labelled placeholder without entering game")
    menu.achievements_dialog.hide()
    menu._on_new_game()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/shop.tscn" and gs.money == gs.START_MONEY, "New game opens the existing demo with fresh state")
    gs.money = 247
    gs.job["dust"]["cooler"] = 0.42
    gs.save_game()
    current_scene._on_main_menu_pressed()
    await process_frame
    await process_frame
    check(not current_scene.load_button.disabled and gs.money == 247, "return to menu preserves demo save and enables Load")
    current_scene._on_new_game()
    check(current_scene.replace_dialog.visible and gs.money == 247, "New game asks before replacing existing progress")
    current_scene.replace_dialog.hide()
    gs.money = 1
    current_scene._on_load_game()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/shop.tscn" and gs.money == 247 and is_equal_approx(gs.dust_fraction("cooler"),0.42), "Load restores saved money and work then opens demo")
    current_scene._on_main_menu_pressed()
    await process_frame
    await process_frame
    current_scene._start_new_game()
    await process_frame
    await process_frame
    check(gs.money == gs.START_MONEY and is_zero_approx(gs.dust_fraction("cooler")), "confirmed new game resets old demo progress")
    # Existing safe recovery remains available to Load game.
    var old_data: Dictionary = {"money":319}
    Store.write(gs.save_path, old_data)
    Store.write(gs.save_path, old_data)
    var broken: FileAccess = FileAccess.open(gs.save_path,FileAccess.WRITE)
    broken.store_string("damaged")
    broken.close()
    check(gs.has_saved_game() and gs.load_game() and gs.money == 319, "Load still recovers a readable backup after main-save corruption")
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(gs.save_path + suffix)
    gs.save_path = original_path
    current_scene.free()
    gs.new_game(false)
    finish("Start screen")
