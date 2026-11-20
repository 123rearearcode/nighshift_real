# 0.50.0 / session 3.6 (D158): the testing bay. Real condition versus what the shop knows; salvage finds
# and customers' replaced parts arrive untested; physical inspection and quick/long rig tests on the night
# clock; the player's own mark; scrap. Untested test parts fitted in a customer's PC behave as they really
# are (dead, weak, hot, crashing), so a bad spare can mislead a diagnosis, and a crashing part brings the
# customer back. The hidden condition never reaches any text the player sees.
extends "res://tools/test_support.gd"
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const SalvageStock = preload("res://scripts/rules/salvage_stock.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const StressLab = preload("res://scripts/rules/stress_lab.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Morning = preload("res://scripts/rules/morning.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Ids = preload("res://scripts/data/ids.gd")
const SECRET: Array = ["degraded", "artifacts", "broken", "condition", "defect"]   # "errors"/"weak" are ordinary words in results

func _initialize() -> void:
    call_deferred("run_checks")


func _part(gs: Node, uid: String, kind: String, model: String, condition: String) -> Dictionary:
    var record: Dictionary = {"uid": uid, "kind": kind, "tier": "model", "model": model, "owner": "player", "condition": condition,
        "known": PartCondition.fresh(PartCondition.UNTESTED, "Test part")}
    if condition == PcBuild.DEGRADED: record["defect"] = str(PcBuild.DEFECTS[kind])
    gs.player_inventory.append(record)
    return record


# A real mouse click through the viewport (as Codex's anti-virus suite does), not a direct callback.
func press(button: Button) -> void:
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = button.get_global_rect().get_center()
        event.global_position = event.position
        root.push_input(event, true)
        await process_frame
    await process_frame


func _leaks(text: String) -> Array:
    return SECRET.filter(func(w: String) -> bool: return text.to_lower().contains(w))


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "testing_bay_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.new_game(false)
    check(night.start(gs), "a night starts")

    # ---- knowledge versus truth (pure) ----
    check(PartCondition.sanitize_known(null, "broken")["label"] == "dead" and PartCondition.sanitize_known(null, "working")["label"] == "new", "old records: a broken one was damaged by you (known dead), the rest were bought new")
    var hidden: Dictionary = {"uid": "x1", "kind": "gpu", "condition": "broken", "known": PartCondition.fresh(PartCondition.UNTESTED, "")}
    check(PartCondition.usable(hidden) and not PartCondition.known_good(hidden), "an untested part is usable but proves nothing, whatever it really is")
    check(PartCondition.spot_text(hidden, "Fans") == PartCondition.spot_text(hidden, "Fans"), "looking at a spot twice shows the same thing")
    var quick_gpu: String = PartCondition.test_result({"kind": "gpu", "condition": "degraded"}, false)
    var long_gpu: String = PartCondition.test_result({"kind": "gpu", "condition": "degraded"}, true)
    check(quick_gpu.contains("steady") and long_gpu.contains("coloured blocks"), "a quick render test misses flickering artifacts; the long one finds them")
    check(PartCondition.test_result({"kind": "ram", "condition": "degraded"}, false).contains("0 errors") and PartCondition.test_result({"kind": "ram", "condition": "degraded"}, true).contains("7 errors"), "memory errors only show in the long run")
    check(PartCondition.test_result({"kind": "psu", "condition": "degraded"}, false).contains("70%") and PartCondition.test_result({"kind": "cpu", "condition": "degraded"}, false).contains("83"), "steady faults (weak output, heat) show in the quick test")
    check(PartCondition.test_result({"kind": "storage", "condition": "broken"}, false).contains("not detected"), "a dead part fails even the quick test")
    var shown: int = 0
    for i in range(60):
        var r: Dictionary = {"uid": "tell_%d" % i, "kind": "gpu", "condition": "broken"}
        if PartCondition.spot_text(r, "Power connector") != PartCondition.NEUTRAL: shown += 1
    check(shown > 25 and shown < 60, "a dead part shows its tell on inspection often but not always (%d of 60)" % shown)
    var all_text: String = ""
    for kind: String in PartCondition.SPOTS:
        for cond: String in ["working", "degraded", "broken"]:
            all_text += PartCondition.test_result({"kind": kind, "condition": cond}, true) + PartCondition.test_result({"kind": kind, "condition": cond}, false)
            for spot: String in PartCondition.spots(kind): all_text += PartCondition.spot_text({"uid": "s", "kind": kind, "condition": cond}, spot)
    check(_leaks(all_text).is_empty(), "inspections and tests describe what is seen or measured, never the verdict: " + ", ".join(_leaks(all_text)))

    # ---- salvage finds become untested stock ----
    var a: Dictionary = SalvageStock.stock_for({"uid": "1:o7", "kind": "gpu", "condition": "broken"}, 42, "salvage_1")
    check(a["condition"] == "broken" and a["known"]["label"] == "untested" and SalvageStock.stock_for({"uid": "1:o7", "kind": "gpu", "condition": "broken"}, 42, "salvage_1") == a, "a find the pile says is dead stays dead, unknown to you, the same every time")
    check(SalvageStock.stock_for({"uid": "2", "kind": "soundcard"}, 42, "x").is_empty() and SalvageStock.stock_for({"uid": "3", "kind": "hdd"}, 42, "x")["kind"] == "storage", "drives become storage stock; things the shop cannot stock are scrap")
    var degraded_seen: bool = false
    for i in range(40):
        var f: Dictionary = SalvageStock.stock_for({"uid": "w%d" % i, "kind": "ram", "condition": "working"}, 7, "u")
        if f["condition"] == "degraded": degraded_seen = f.get("defect", "") == "errors" or degraded_seen
    check(degraded_seen, "some finds that work are worn out (degraded)")
    var cash: int = gs.money
    var count: int = gs.player_inventory.size()
    var got: Dictionary = gs.receive_salvage([{"uid": "n1:a", "kind": "gpu", "condition": "broken"}, {"uid": "n1:b", "kind": "ram", "condition": "working"}, {"uid": "n1:c", "kind": "fan"}])
    check((got["added"] as Array).size() == 2 and gs.player_inventory.size() == count + 2 and gs.money == cash + PartCondition.JUNK_SCRAP, "unloading adds stockable finds to stock and scraps the rest")
    var dead_gpu: String = str(got["added"][0]["uid"])
    check(gs.stock_available(dead_gpu) and dead_gpu in gs.bay_parts(), "a dead untested GPU is still in the drawer and on the bay: its truth does not make it vanish")
    var caps: Dictionary = gs.diagnosis_capabilities()
    check((caps["stock"] as Dictionary).get("gpu", 0) == 2, "only known-good spares count for solvability (the two starter GPUs, not the untested find)")

    # ---- the bay: inspection, tests, the night clock, the player's call, scrap ----
    gs.night_minutes = 100
    var spot: String = str(PartCondition.spots("gpu")[0])
    var looked: Dictionary = gs.inspect_part(dead_gpu, spot)
    check(looked["ok"] and gs.night_minutes == 101 and str(PartCondition.known(gs.stock_record(dead_gpu))["notes"][0]).contains(spot.to_lower()), "looking at a spot costs a minute and goes into the part's notes")
    gs.inspect_part(dead_gpu, spot)
    check(gs.night_minutes == 101, "looking at the same spot again is free")
    check(gs.test_part(dead_gpu, false)["message"].contains("no signal") and gs.night_minutes == 106, "the quick test takes five night minutes and shows a dead card")
    gs.night_minutes = Clock.SHIFT_MINUTES - 10
    check(not gs.test_part(dead_gpu, true)["ok"] and gs.night_minutes == Clock.SHIFT_MINUTES - 10, "a long test that would pass 06:00 is refused")
    gs.night_minutes = 120
    check(gs.label_part(dead_gpu, "working") and PartCondition.known(gs.stock_record(dead_gpu))["label"] == "working" and "quick" in PartCondition.known(gs.stock_record(dead_gpu))["tests"],
        "the mark is the player's own call, even against the evidence; the tests done stay on record (scam hook)")
    check(gs.label_part(dead_gpu, "dead") and not gs.stock_available(dead_gpu), "marking a part dead takes it out of use")
    var before_cash: int = gs.money
    check(gs.scrap_part(dead_gpu) == PartCondition.scrap_value("gpu") and gs.money == before_cash + PartCondition.scrap_value("gpu") and gs.stock_record(dead_gpu).is_empty(), "scrap sells it for a little cash and it is gone")
    gs.save_game()
    var ram_uid: String = str(got["added"][1]["uid"])
    var ram_condition: String = str(gs.stock_record(ram_uid)["condition"])
    check(gs.load_game() and gs.stock_record(ram_uid)["condition"] == ram_condition and gs.stock_record(ram_uid)["known"]["label"] == "untested", "condition and knowledge survive save and load")

    # ---- untested test parts behave as they really are in a customer's PC ----
    _part(gs, "bay_gpu_art", "gpu", "gpu_gtx1660", "degraded")
    check(gs.set_service_part_fitted(Ids.GPU, false) and gs.fit_inventory_part(Ids.GPU, "bay_gpu_art"), "a worn GPU from stock is fitted as a test part")
    gs.set_pc_powered(true)
    var load: float = float(Diagnostics.evaluate(gs.job, [])["temp"])
    var lab: Dictionary = StressLab.run(gs.job, load, 60)
    check(lab["crashed"] and int(lab["minutes"]) == 12, "the Stress lab crashes after 12 minutes: the spare is the problem now")
    gs.owned_games = ["counter_stroke_2"]
    var game: Dictionary = Checks.game_test(gs.job, gs.owned_games, "counter_stroke_2", load)
    check(str(game["message"]).contains("flickering coloured blocks") and _leaks(str(game["message"])).is_empty(), "the game test shows flickering blocks, without naming a cause")
    check(PartCondition.UNSTABLE_FAULT in gs.pickup_faults(load) and PartCondition.UNSTABLE_FAULT in Morning.DELAYED, "left in the PC, the crashing part would bring the customer back later")
    check(gs.set_service_part_fitted(Ids.GPU, false) and gs.stock_record("bay_gpu_art")["condition"] == "degraded" and PartCondition.known(gs.stock_record("bay_gpu_art"))["label"] == "untested", "taking it out returns it unchanged: fitting does not test or change a part")
    _part(gs, "bay_gpu_dead", "gpu", "gpu_gtx1660", "broken")
    check(gs.fit_inventory_part(Ids.GPU, "bay_gpu_dead") and str(Checks.boot(gs.job)["message"]).contains("no image"), "a dead spare GPU gives the same black screen as a faulty original: a misleading swap")
    var original_broken: bool = Ids.GPU in (gs.job["loose_parts"] as Array).filter(func(e: Dictionary) -> bool: return str(e["original_of"]) == Ids.GPU).map(func(e: Dictionary) -> String: return Ids.GPU if bool(e["broken"]) else "")
    check(gs.set_service_part_fitted(Ids.GPU, false) and (Ids.GPU in gs.job["broken_parts"]) == original_broken and gs.stock_record("bay_gpu_dead")["condition"] == "broken", "returning it restores the original's own state; the dead spare stays dead and untested")
    check(gs.set_service_part_fitted(Ids.GPU, true), "the customer's card goes back in")
    # A dead power supply from stock in the PSU bay.
    _part(gs, "bay_psu_dead", "psu", "psu_600w", "broken")
    gs.job["parts"]["psu"] = ""
    check(gs.fit_catalog_stock("bay_psu_dead", "psu_bay") and str(Checks.boot(gs.job)["message"]).contains("Nothing happens"), "a dead spare PSU: pressing the button does nothing at all")
    check(gs.unfit_catalog_stock("bay_psu_dead"), "it comes out again")
    _part(gs, "bay_psu_weak", "psu", "psu_cv450", "degraded")
    check(gs.fit_catalog_stock("bay_psu_weak", "psu_bay") and int(PcBuild.effective(gs.job)["psu_w"]) == int(450 * PcBuild.WEAK_PSU_SHARE), "a worn PSU gives about 70% of its label")
    gs.save_game()
    gs.job["shop_condition"] = {}
    check(gs.load_game() and str(PcBuild.shop_condition(gs.job, "psu_bay")["defect"]) == "weak", "after a reload the fitted part's real condition is rebuilt from its stock record")
    check(gs.unfit_catalog_stock("bay_psu_weak"), "the worn PSU comes out")

    # ---- customers' replaced parts stay with the shop, untested ----
    gs.tickets_taken = 0
    gs.new_game(false)
    check(night.start(gs), "a fresh night")
    check(night.switch_pc(gs, str(night.tickets[1]["id"])) and Ids.GPU in gs.job["broken_parts"], "Relu's PC with its faulty card")
    check(gs.set_service_part_fitted(Ids.GPU, false) and gs.fit_inventory_part(Ids.GPU, "trial_gpu"), "his card is swapped for a starter GPU")
    var kept: Array = gs.settle_custody()
    var old_card: Array = gs.player_inventory.filter(func(r: Dictionary) -> bool: return str(PartCondition.known(r)["source"]).contains("PC"))
    check(kept.size() == 1 and old_card.size() == 1 and old_card[0]["condition"] == "broken" and PartCondition.known(old_card[0])["label"] == "untested", "his faulty card stays with the shop as UNTESTED stock (its fault still hidden)")
    check(_leaks(PartCondition.describe(old_card[0], 5)).is_empty(), "its description says where it came from, not what is wrong with it")

    # ---- the screen ----
    _part(gs, "bay_ram", "ram", "ram_8gb", "degraded")
    gs.night_minutes = 30
    gs.save_game()
    var bay: Node = load("res://scenes/night_bay.tscn").instantiate()
    root.add_child(bay)
    await process_frame
    check(bay.list_buttons.has("bay_ram") and bay.list_buttons.size() == gs.bay_parts().size(), "the bay lists every stock part in the drawer")
    bay._select("bay_ram")
    var first: Button = bay.spot_buttons[0]
    await press(first)
    check(gs.night_minutes == 31 and first.text.begins_with("✓"), "clicking a spot on the part inspects it (one night minute) and ticks it off")
    await press(bay.quick_button)
    check(gs.night_minutes == 36 and str(bay.message.text).to_lower().contains("memory test"), "the quick test runs from its button")
    check(_leaks(bay.card_text.text).is_empty() and bay.card_text.text.contains("Untested"), "the part card shows what you know, never the real condition")
    bay.label_buttons["degraded"].emit_signal("pressed")
    check(PartCondition.known(gs.stock_record("bay_ram"))["label"] == "degraded" and bay.card_text.text.contains("Marked degraded"), "marking it is shown as your call")
    bay.scrap_button.emit_signal("pressed")
    await process_frame
    check(gs.stock_record("bay_ram").is_empty() and not bay.list_buttons.has("bay_ram"), "scrapping removes it from the list")
    bay.queue_free()
    await process_frame
    # Native navigation: Activities -> Testing bay -> back, through real clicks.
    change_scene_to_file("res://scenes/activities.tscn")
    for f in range(3): await process_frame
    var bay_entry: Array = current_scene.activity_buttons.filter(func(b: Button) -> bool: return b.text.begins_with("TESTING BAY"))
    check(bay_entry.size() == 1 and not bay_entry[0].disabled, "Activities offers the testing bay")
    if bay_entry.size() == 1:
        await press(bay_entry[0])
        for f in range(3): await process_frame
        check(current_scene.scene_file_path == "res://scenes/night_bay.tscn", "clicking it opens the testing bay")
        var back: Button = current_scene.get_node_or_null("BackButton")
        check(back != null and back.text == "← Activities" and current_scene.get_node_or_null("ActivitiesButton") != null, "the bay has the standard back and Activities buttons")
        if back != null:
            await press(back)
            for f in range(3): await process_frame
            check(current_scene.scene_file_path == "res://scenes/activities.tscn", "← Activities returns to the hub")

    _remove_save_files(manifest)
    restore_save(gs)
    finish("Testing bay")
