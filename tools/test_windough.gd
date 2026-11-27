# 0.59.0 (D182): Windough 98 on NightBoot USB, the customer PC's screen on the diagnostic monitor. The user, 28
# November 2026: "the PC desktop boot screen. It has to look somewhat like a goofy windows. We will have it booted
# in our own boot tool"; on the drafts: "make sure the info of the bios doesnt give anything away"; then "approved".
# The approved files byte for byte; the boot (BIOS, NightBoot countdown, splash, desktop; clicks and Enter skip); a
# PC that does not start (NO SIGNAL, observation noted); the desktop (select, double click, windows whose buttons
# run the monitor's own apps, Close); the Begin menu (Programs, readme, Shut Down); the tray clock.
extends "res://tools/test_support.gd"
const Windough = preload("res://scripts/night/windough.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func click(view: Node, native: Vector2, double: bool = false) -> void:
    var at: Vector2 = view.windough.global_position + native * 2.0 + Vector2(1, 1)
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.double_click = double and down
        event.position = at
        event.global_position = at
        root.push_input(event, true)
        await process_frame


func move(view: Node, native: Vector2) -> void:
    var event := InputEventMouseMotion.new()
    event.position = view.windough.global_position + native * 2.0 + Vector2(1, 1)
    event.global_position = event.position
    root.push_input(event, true)
    await process_frame


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "windough_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)

    # ---- the approved files ----
    var approved: Variant = JSON.parse_string(FileAccess.get_file_as_string(Windough.art("manifest.json")))
    var same: bool = approved is Dictionary and str(approved.get("approval_quote", "")) == "approved, create PR"
    var hashes: Dictionary = (approved as Dictionary).get("sha256", {}) if approved is Dictionary else {}
    for file: String in hashes:
        if FileAccess.get_sha256(Windough.art(file)) != str(hashes[file]): same = false
    check(same and hashes.size() >= 23, "every Windough 98 / NightBoot file is the approved one, byte for byte")

    # ---- a PC that starts ----
    gs.new_game(false)
    night.start(gs, false)
    gs.job["broken_parts"] = []
    gs.job["removed_parts"] = []
    gs.set_pc_powered(false)
    var view: Node = load("res://scenes/software.tscn").instantiate()
    view.run_seconds = 0.0
    root.add_child(view)
    current_scene = view
    await process_frame
    var win: Control = view.windough
    check(win != null and win.available() and win.state == "off" and not view.boot_button.visible and not view.output.visible, "the monitor is dark while the PC is off; the old flat panel is gone")
    view._power()
    await process_frame
    check(gs.job["pc_powered"] and win.state == "bios" and view.output.text.contains("NightBoot"), "switching on shows the BIOS first")
    var findings: int = (gs.job.get("findings", []) as Array).size()
    win._process(Windough.BIOS_SECONDS + 0.01)
    check(win.state == "nightboot" and win.countdown() == Windough.COUNTDOWN, "then the NightBoot USB menu, counting down from 3")
    win._process(1.1)
    check(win.state == "nightboot" and win.countdown() == Windough.COUNTDOWN - 1, "a second later it says 2")
    var enter := InputEventKey.new()
    enter.keycode = KEY_ENTER
    enter.pressed = true
    root.push_input(enter, true)
    await process_frame
    check(win.state == "splash", "Enter starts Windough 98 at once")
    await click(view, Vector2(200, 100))
    check(win.state == "desktop" and (gs.job.get("findings", []) as Array).size() == findings, "a click skips the splash to the desktop; booting writes nothing in Findings")

    # ---- the desktop ----
    check(view.boot_button.disabled == false, "on the desktop the apps can run")
    var hw: Rect2i = win.icon_rect(1)
    await click(view, Vector2(hw.get_center()))
    check(win.selected == 1 and win.open_app == "", "one click selects the Hardware check icon")
    await click(view, Vector2(hw.get_center()), true)
    check(win.open_app == "hardware" and win.app_text("hardware").contains("Press Run"), "a double click opens it in a window")
    var minutes: int = gs.night_minutes
    var run: Rect2 = win.button_rect("Run")
    check(run.has_area(), "the window has a Run button")
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = run.get_center()
        event.global_position = event.position
        root.push_input(event, true)
        await process_frame
    check(win.result_app == "hardware" and win.app_text("hardware") == view.output.text and view.output.text != "" and win.status_text("hardware").contains("Findings"), "Run runs the monitor's own Hardware check and the window shows its report")
    check(gs.night_minutes >= minutes, "the check keeps its own night-minute rule")
    var close: Rect2i = win.layout("hardware")["close"]
    await click(view, Vector2(close.get_center()))
    check(win.open_app == "", "the window's X closes it")
    win.open("boot")
    check(win.app_text("boot").contains("Press Run") and not win.app_text("boot").contains("in place"), "another app does not show the last app's report")
    win.close_window()
    var spot: Vector2i = Windough.icon_spot(7)
    check(Windough.ICONS[7][0] == "readme" and Windough.ICONS.size() == 9, "readme.txt and the Bin of Regret are on the desktop too")
    win.open("readme")
    check(win.app_text("readme").contains("- V.") and win.layout("readme")["status"] == Rect2i(), "readme.txt is the last technician's note")
    win.close_window()
    check(win.status_text("hardware") != "" and str(Clock.label(gs.night_minutes)).length() == 5, "the tray clock is the night clock")

    # ---- the Begin menu ----
    await click(view, Vector2(10, Windough.H - 8))
    check(win.menu_open, "Begin opens the menu")
    var items: Array = win.menu_items()
    var programs: Rect2i = items[0][1]
    await move(view, Vector2(programs.get_center()))
    check(win.hover_menu == "Programs", "pointing at Programs highlights it")
    await move(view, Vector2(win.program_rect(5).get_center()))
    check(win.hover_program == "stress", "and opens the shop's apps beside it")
    await click(view, Vector2(win.program_rect(5).get_center()))
    check(win.open_app == "stress" and not win.menu_open, "choosing the Stress lab opens it")
    win.close_window()
    await click(view, Vector2(10, Windough.H - 8))
    var shut: Rect2i = items[items.size() - 1][1]
    await move(view, Vector2(shut.get_center()))
    await click(view, Vector2(shut.get_center()))
    check(not gs.job["pc_powered"] and win.state == "off" and view.output.text.contains("readings cleared"), "Shut Down... turns the PC off")
    view.queue_free()
    await process_frame

    # ---- a PC that does not start ----
    gs.job["removed_parts"] = ["ram"]
    var dead: Node = load("res://scenes/software.tscn").instantiate()
    dead.run_seconds = 0.0
    root.add_child(dead)
    current_scene = dead
    await process_frame
    dead._power()
    await process_frame
    var notes: Array = gs.job.get("findings", [])
    check(dead.windough.state == "no_signal" and dead.output.text.contains("nothing reaches the screen") and str(notes.back()["text"]).begins_with("Boot check: Boot FAILED"), "a PC that does not start shows NO SIGNAL; what you see is written down as a Boot check")
    await click(dead, Vector2(200, 100))
    check(dead.windough.state == "no_signal" and dead.windough.open_app == "", "nothing on that screen can be clicked into")
    dead.queue_free()
    await process_frame
    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Windough")
