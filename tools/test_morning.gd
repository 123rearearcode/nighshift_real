# Wave 3 session 3.2 (D136): ending the night, collection by called customers, hidden faults now or
# later, waiting PCs, new tickets, the report screen and the 06:00 limit.
extends "res://tools/test_support.gd"
const MorningText = preload("res://scripts/night/morning_text.gd")
const Morning = preload("res://scripts/rules/morning.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const ShopRating = preload("res://scripts/rules/shop_rating.gd")

func _initialize() -> void: call_deferred("run_checks")

func of_kind(report: Dictionary, kind: String) -> Array:
    return (report.get("cards", []) as Array).filter(func(card: Dictionary) -> bool: return card["kind"] == kind)

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "morning_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)

    # Pure rule.
    var split: Dictionary = Morning.split([InstallFaults.FILM, InstallFaults.GPU_LOOSE, "malware_adware", Overclock.UNSTABLE])
    check(split["now"] == [InstallFaults.FILM, "malware_adware"] and split["later"] == [InstallFaults.GPU_LOOSE, Overclock.UNSTABLE], "film and pop-ups show at pickup; GPU screws and overclock come back later")
    check(Morning.pay(40, true) == 40 and Morning.pay(40, false) == 0 and Morning.reaction(90, true).begins_with("Happy") and Morning.reaction(90, false).begins_with("Furious"), "pay and reaction")
    var ticked: Dictionary = Morning.tick([{"faults": ["gpu_loose"], "nights_left": 2}, {"faults": ["oc_unstable"], "nights_left": 1}])
    check(ticked["due"].size() == 1 and ticked["pending"].size() == 1 and ticked["pending"][0]["nights_left"] == 1, "comebacks count down one morning at a time")
    check(Morning.sanitize_pending([{"faults": ["film_left"], "nights_left": 2}, "junk", {"faults": ["gpu_loose"], "nights_left": "x"}]).is_empty() and Morning.sanitize_pending([{"faults": ["gpu_loose"], "nights_left": 3}])[0]["nights_left"] == 3, "saved comebacks keep only delayed faults and sane counts")
    check(Morning.comeback_trust(["gpu_loose"]) < 0, "a comeback always costs trust")

    # Night one: both customers called. Mara's PC starts (film left on, GPU screws loose); Relu's GPU is broken.
    gs.tickets_taken = 0
    gs.customer_state = {}
    gs.new_game(false)
    check(night.start(gs), "night starts")
    var first: String = night.active_id
    var other: String = night.tickets[1]["id"]
    var first_customer: String = str(gs.job["customer_id"])
    var payout: int = int(gs.job["payout"])
    gs.job["install_faults"] = [InstallFaults.FILM]
    gs.job["gpu_screws"] = 0
    night.checkpoint(gs)
    night.ticket_action(gs, first, Ticket.TOGGLE_CALL)
    night.ticket_action(gs, other, Ticket.TOGGLE_CALL)
    var cash: int = gs.money
    gs.night_minutes = 200
    var report: Dictionary = night.end_night(gs)
    check(report.get("ok", false) and report["night"] == 1 and of_kind(report, "collected").size() == 2, "both called customers collect")
    var mara: Dictionary = of_kind(report, "collected").filter(func(c: Dictionary) -> bool: return c["ticket"] == first)[0]
    var relu: Dictionary = of_kind(report, "collected").filter(func(c: Dictionary) -> bool: return c["ticket"] == other)[0]
    var film_text: String = InstallFaults.complaint(InstallFaults.FILM)
    var gpu_text: String = InstallFaults.complaint(InstallFaults.GPU_LOOSE)
    check(mara["paid"] == payout and mara["boots"] and (mara["misses"] as Array).has(film_text) and not (mara["misses"] as Array).has(gpu_text), "a working PC is paid for; the film is noticed now, the GPU screws are not")
    check(relu["paid"] == 0 and not relu["boots"] and str(relu["reaction"]).begins_with("Furious") and relu["trust_change"] < 0, "a PC that does not start is not paid for and costs trust")
    check(gs.money == cash + payout and report["earned"] == payout, "the shop is paid once")
    check(gs.comebacks.size() == 1 and gs.comebacks[0]["faults"] == [InstallFaults.GPU_LOOSE] and gs.comebacks[0]["customer_id"] == first_customer, "the loose GPU screws are queued to come back")
    check(of_kind(report, "new").size() == ShopRating.arrivals(float(report["rating"]), int(report["reputation"]), 0) and of_kind(report, "new").size() >= 1 and gs.night_number == 2 and gs.night_minutes == 0, "new customers arrive (0.48.0: as many as the rating and reputation bring) and the clock resets")
    var open: Array = night.jobs(gs).filter(func(j: Dictionary) -> bool: return j["state"] != "done")
    check(open.size() == of_kind(report, "new").size() and night.tickets.size() == open.size() and gs.job["state"] == "open" and gs.job["id"] != first and gs.job["id"] != other, "collected PCs leave; the active PC is a new one")
    check(not open.any(func(j: Dictionary) -> bool: return bool(Ticket.flags(j)["called"])), "new tickets start uncalled")
    gs.save_game()
    check(gs.load_game() and gs.comebacks.size() == 1 and gs.night_number == 2, "the comeback and the night number survive save and load")
    night.bound_path = ""
    check(night.ensure(gs), "the new night's manifest is valid")

    # Night two: nobody called. Both wait; the comeback is not due yet.
    var trust: int = int(gs.customer_view(first_customer)["trust"])
    report = night.end_night(gs)
    check(report["ok"] and of_kind(report, "waiting").size() == open.size() and of_kind(report, "waiting")[0]["nights"] == 1 and of_kind(report, "comeback").is_empty() and of_kind(report, "new").size() == ShopRating.arrivals(float(report["rating"]), int(report["reputation"]), open.size()), "uncalled PCs wait; no comeback yet; new customers only as the rating brings and space allows")
    check(int(gs.customer_view(first_customer)["trust"]) == trust and gs.comebacks[0]["nights_left"] == 1, "nothing changes for the waiting customers")

    # Night three: the loose GPU screws bring the first customer back.
    report = night.end_night(gs)
    var back: Array = of_kind(report, "comeback")
    check(back.size() == 1 and back[0]["customer_id"] == first_customer and (back[0]["misses"] as Array).has(gpu_text) and back[0]["trust_change"] < 0, "the hidden fault comes back two mornings later and costs trust")
    check(gs.comebacks.is_empty() and of_kind(report, "waiting")[0]["nights"] == 2 and gs.night_number == 4, "the comeback is used up; waiting nights add up")

    # 0.53.0 (D161): the morning's customers walk in at the counter, one at a time.
    var walked_in: Array = (report["cards"] as Array).filter(func(c: Dictionary) -> bool: return str(c["kind"]) in ["collected", "comeback", "new"])
    night.visits_pending = true
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    await process_frame
    await process_frame
    var counter: Node = current_scene
    check(counter.visiting() and counter.arrived == walked_in.size() and counter.slip.visible and counter.slip_title.text.contains("%d customer" % walked_in.size()), "the shutter goes up and the board counts who came in")
    check(counter.slip_text.text == MorningText.card_text(walked_in[0]) and counter.hotspot("BackDoor").disabled, "the first customer speaks across the counter; the shop waits until they are served")
    for i in range(walked_in.size()): counter.next_button.pressed.emit()
    await process_frame
    check(not counter.visiting() and not night.visits_pending and not counter.slip.visible and not counter.hotspot("BackDoor").disabled, "after the last customer the counter opens for the night")
    check(counter.message.text.contains("came in this morning"), "the counter sums up the morning")

    # 06:00: only closing the shutter is left.
    gs.night_minutes = 480
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    await process_frame
    await process_frame
    var acts: Node = current_scene
    check(acts.hotspot("BackDoor").disabled and acts.hotspot("FrontDoor").disabled and acts.hotspot("Catalogue").disabled and not acts.hotspot("Shutter").disabled and acts.hotspot("Shutter").badge.contains("06:00"), "at 06:00 only closing the shutter remains")
    acts._ask_end_night()
    check(acts.end_dialog.dialog_text.contains("Nobody was called"), "the shutter's question says who collects")
    acts.end_dialog.hide()
    gs.set_pc_powered(true)
    change_scene_to_file("res://scenes/software.tscn")
    await process_frame
    await process_frame
    var monitor: Node = current_scene
    monitor.run_seconds = 0.0
    var minutes: int = gs.night_minutes
    monitor._game()
    check(monitor.output.text.contains("06:00") and gs.night_minutes == minutes, "the monitor refuses timed tests after 06:00")
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    await process_frame
    await process_frame
    current_scene._end_night()
    await process_frame
    await process_frame
    var visitors: bool = not (night.last_report["cards"] as Array).filter(func(c: Dictionary) -> bool: return str(c["kind"]) in ["collected", "comeback", "new"]).is_empty()
    check(current_scene.scene_file_path == "res://scenes/rooms/counter.tscn" and gs.night_minutes == 0 and gs.night_number == 5 and current_scene.visiting() == visitors, "closing the shutter brings the morning's customers to the counter")
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Morning report")
