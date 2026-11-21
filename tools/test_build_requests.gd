# 0.51.0 / session 3.7 (D159): build requests. Cases as swappable parts; the rescaled uses table, wants and
# budgets; a request is offered only when the cheapest catalogue build meets it and the shop can pay for
# it; a build starts as an empty basic case with the cheapest motherboard; assembly costs night time; the
# customer pays half up front and half on collection; the pickup judges needs (hard) and wants (soft); the
# scam hooks are recorded. Builds start on nights 4-5 and never change a repair PC's numbers.
extends "res://tools/test_support.gd"
const BuildRequest = preload("res://scripts/rules/build_request.gd")
const Generator = preload("res://scripts/rules/ticket_generator.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Memory = preload("res://scripts/night/navigation_state.gd")
const Nav = preload("res://scripts/night/night_navigation.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Legacy = preload("res://scripts/state/game_state.gd")

func _initialize() -> void:
    call_deferred("run_checks")


func _buy(gs: Node, id: String) -> String:
    gs.money += int(Catalog.part(id)["price"])
    if not gs.buy_catalog_part(id): return ""
    var uid: String = ""
    for record: Dictionary in gs.player_inventory:
        if str(record.get("model", "")) == id and str(record.get("fitted_in", "")) == "": uid = str(record["uid"])
    return uid


# A build request made the way the morning makes one, then made the active PC through the night manifest.
func _active_build(gs: Node, night: Node, seed: int, use_night: int) -> Dictionary:
    var r: RandomNumberGenerator = Generator.rng_for(seed, use_night, 0)
    var who: Dictionary = Generator.new_person(r, gs.next_person_id())
    var order: Dictionary = Generator.draw_build(gs.make_ticket_job(""), who, 5000, use_night, r)
    if order.is_empty(): return {}
    gs.remember_person(order["person"])
    var job: Dictionary = order["job"]
    night._tag(job, str(job["id"]), night.run_id + ":pc:" + str(job["id"]))
    night.tickets.append(job.duplicate(true))
    night._write(gs)
    if not night.switch_pc(gs, str(job["id"])): return {}
    return order


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "build_requests_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.new_game(false)
    check(night.start(gs), "a night starts")
    gs.player_inventory = []   # an empty drawer: this suite buys every part it fits
    gs.inventory_layout = {}

    # ---- cases (user: "cases are also something swappable") ----
    for form: String in ["tower", "compact"]:
        var id: String = str(Catalog.DEFAULT_CASE[form])
        check(Catalog.is_case(id) and str(Catalog.CASES[id]["form"]) == form and int(Catalog.CASES[id]["heat"]) == 0 and not bool(Catalog.CASES[id]["quiet"]), "the default %s case has no effect, so repair PCs behave as before" % form)
        check(PcBuild.case_model({"layout": form, "parts": {}}) == id and PcBuild.case_heat({"layout": form, "parts": {}}) == 0.0, "a PC with no case recorded is in the default %s case" % form)
    check(PcBuild.case_model({"layout": "compact", "parts": {"case": "case_tower_mesh"}}) == "case_compact_basic", "a case of the wrong size reads as the default")
    check(PcBuild.case_heat({"layout": "tower", "parts": {"case": "case_tower_mesh"}}) < 0.0, "a mesh case cools the CPU")
    check(PcBuild.sanitize({"case": "case_tower_silent"})["case"] == "case_tower_silent" and PcBuild.sanitize({"case": "gpu_gtx1660"})["case"] == "" and PcBuild.FALLBACK["case"] == "", "only real case models are kept")
    check(gs.job["parts"].has("case") and str(PcBuild.part_lines(gs.job)[PcBuild.part_lines(gs.job).size() - 1]).begins_with("Case: "), "every PC lists its case")

    # ---- the uses table and needs ----
    var office: Dictionary = BuildRequest.needs_for("light_office", 60)
    check(int(office["processing"]) == 10 and int(office["graphics"]) == 0 and int(office["ram_gb"]) == 8 and int(office["storage_gb"]) == 250 and office["game"].is_empty(), "light office work matches the approved table")
    var game90: Dictionary = BuildRequest.needs_for("gaming", 90)
    check(int(game90["processing"]) == 23 and int(game90["graphics"]) == 17 and int(game90["game"]["min_fps"]) == 90 and int(game90["storage_gb"]) == 85, "gaming needs come from the game and the frame rate")
    var stream: Dictionary = BuildRequest.needs_for("streaming", 60)
    check(int(stream["processing"]) == 15 + 15 and int(stream["ram_gb"]) == 8 + 16 and int(stream["storage_gb"]) == 85 + 500, "streaming adds to the game's needs")
    check(BuildRequest.uses_for(4).size() == 4 and BuildRequest.uses_for(6).size() == BuildRequest.USES.size(), "nights 4-5 bring the simpler uses; every use from night 6")
    check(not BuildRequest.wanted(RandomNumberGenerator.new(), 3, 0) and BuildRequest.wanted(RandomNumberGenerator.new(), 5, 0), "no build requests before night 4; night 5's first arrival is always one")

    # ---- every request can end well: the cheapest build meets it ----
    for use: String in BuildRequest.USES:
        for form: String in (["tower"] if bool(BuildRequest.USES[use].get("tower", false)) else ["tower", "compact"]):
            var needs: Dictionary = BuildRequest.needs_for(use, 144 if use in BuildRequest.GAME_USES else 60)
            var best: Dictionary = BuildRequest.cheapest(needs, form)
            check(not best.is_empty(), "%s in a %s case can be built from the catalogue" % [use, form])
            if best.is_empty(): continue
            var stats: Dictionary = PcBuild.stats(best["parts"])
            var spec: Dictionary = {"needs": needs, "wants": []}
            check((BuildRequest.review(spec, stats, best["parts"], str(best["parts"]["case"]), 46.0)["needs"] as Array).is_empty() and bool(stats["powered"]) and int(stats["excess_heat_w"]) == 0,
                "the cheapest %s build (%s) meets every need, starts and is cooled" % [use, form])
            check(int(best["cost"]) == BuildRequest.value_of(best["parts"]), "its cost is its parts at new prices, case and board included (%s)" % use)
            for want: String in BuildRequest.WANTS:
                var w: Dictionary = {"id": want} if want != BuildRequest.BRAND else {"id": want, "part": "cpu", "brand": "AMB"}
                var rich: Dictionary = BuildRequest.cheapest(needs, form, [w])
                if rich.is_empty(): continue
                var r2: Dictionary = BuildRequest.review({"needs": needs, "wants": [w]}, PcBuild.stats(rich["parts"]), rich["parts"], str(rich["parts"]["case"]), 46.0)
                check((r2["needs"] as Array).is_empty() and (r2["wants"] as Array).is_empty() and int(rich["cost"]) >= int(best["cost"]), "the cheapest %s build with the '%s' want meets it too, and costs at least as much (%s)" % [use, want, form])
    var weak: Dictionary = {"cpu": "cpu_pentium_g4650", "gpus": ["gpu_gtx1550ti"], "ram": ["ram_4gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box", "board": "", "case": ""}
    var missed: Dictionary = BuildRequest.review({"needs": BuildRequest.needs_for("video", 60), "wants": []}, PcBuild.stats(weak), weak, "case_tower_basic", 46.0)
    check((missed["needs"] as Array).size() == 4, "a weak PC for video editing misses processing, graphics, memory and storage")
    var loud: Dictionary = PcBuild.stats({"cpu": "cpu_pentium_g4650", "gpus": ["gpu_gtx1550ti"], "ram": ["ram_8gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"})
    check(BuildRequest.loud_sources(loud, 46.0).size() == 1 and not BuildRequest.quiet(loud, 46.0, "case_tower_basic") and BuildRequest.quiet(loud, 46.0, "case_tower_silent"), "a cooler near its limit is loud; a sound-dampened case hides one loud fan")
    check(BuildRequest.sanitize(null).is_empty() and BuildRequest.sanitize({"use": "teleporter"}).is_empty(), "junk build records are dropped")
    var round_trip: Dictionary = BuildRequest.sanitize({"use": "gaming", "needs": game90, "wants": [{"id": "brand", "part": "gpu", "brand": "Nvidya"}, {"id": "jetpack"}], "budget": 400, "deposit": 900})
    check(round_trip["needs"] == game90 and (round_trip["wants"] as Array).size() == 1 and int(round_trip["deposit"]) == 400, "a build record keeps known wants only and never a deposit above the budget")

    # ---- the generator ----
    var r: RandomNumberGenerator = Generator.rng_for(777, 5, 0)
    var a: Dictionary = Generator.draw_build(gs.make_ticket_job(""), Generator.new_person(r, "p9001"), 5000, 5, r)
    r = Generator.rng_for(777, 5, 0)
    var b: Dictionary = Generator.draw_build(gs.make_ticket_job(""), Generator.new_person(r, "p9001"), 5000, 5, r)
    check(not a.is_empty() and a["build"] == b["build"] and a["job"]["parts"] == b["job"]["parts"], "the same seed brings the same build request")
    if not a.is_empty():
        var spec: Dictionary = a["build"]
        check(int(spec["budget"]) >= int(a["cost"]) and int(spec["deposit"]) == roundi(float(spec["budget"]) * 0.5), "the budget covers the cheapest build; half is paid up front")
        check(PcBuild.is_build(a["job"]) and Ticket.flags(a["job"])["request"] == Ticket.BUILD, "it is a build ticket")
    var poor: int = 0
    for i in range(10):
        var rr: RandomNumberGenerator = Generator.rng_for(31 + i, 4, 1)
        var order: Dictionary = Generator.draw_build(gs.make_ticket_job(""), Generator.new_person(rr, "p95%02d" % i), 0, 4, rr)
        if not order.is_empty() and int(order["cost"]) > int(order["build"]["deposit"]): poor += 1
    check(poor == 0, "a request is only offered when the shop can pay for its cheapest build")

    # ---- an empty build at the bench ----
    gs.night_minutes = 0
    var order_a: Dictionary = _active_build(gs, night, 4242, 4)
    check(not order_a.is_empty() and PcBuild.is_build(gs.job), "a build request is the active PC")
    var job: Dictionary = gs.job
    var form: String = str(job["layout"])
    check(Ids.GPU in job["removed_parts"] and Ids.COOLER in job["removed_parts"] and str(job["parts"]["cpu"]) == "" and (job["parts"]["ram"] as Array).is_empty() and str(job["parts"]["psu"]) == "", "it starts empty")
    check(PcBuild.case_model(job) == str(Catalog.DEFAULT_CASE[form]) and PcBuild.board_model(job) == Catalog.cheapest_board(form) and not PcBuild.board_out(job), "in the basic case with the cheapest motherboard fitted")
    check(CustomerPC.first_parts(job).is_empty() and CustomerPC.components(job).is_empty() and (job["loose_parts"] as Array).is_empty(), "there is no customer part anywhere: no phantom GPU or cooler")
    check(job["dust"].values().all(func(v: Variant) -> bool: return float(v) >= 1.0), "a new build is clean")
    var lines: String = "\n".join(PcBuild.part_lines(job))
    check(lines.contains("GPU: none fitted yet") and lines.contains("Cooler: none fitted yet") and not lines.contains(str(Catalog.part(BuildRequest.PLACEHOLDER_GPU)["model"])), "the parts list shows empty slots, never a placeholder model")
    var ticket: String = Ticket.text(job, gs.customer_view(str(job["customer_id"])), {})
    check(ticket.contains("PC build") and ticket.contains("Budget $") and ticket.contains("Needs (hard minimums)") and ticket.contains("Would like:"), "the ticket shows the needs, wants and budget")
    gs.set_pc_powered(true)
    check(not bool(Checks.boot(gs.job)["ok"]) and str(Checks.boot(gs.job)["message"]).contains("NOT FITTED YET"), "an empty build does not start and says what is missing")
    Memory.enter(gs, Nav.REPAIR)
    check(Memory.workbench_path(gs) == Nav.HARDWARE and Memory.resume_path(gs) == Nav.HARDWARE, "a build opens at the hardware bench, never the repair bench, even from an old preference")

    # ---- assembly costs night time; the cooler needs the CPU ----
    var spec_a: Dictionary = order_a["build"]
    var plan: Dictionary = BuildRequest.cheapest(spec_a["needs"], form)   # the plain plan: it fits the basic case
    var parts: Dictionary = plan["parts"]
    var cooler: String = _buy(gs, str(parts["cooler"]))
    check(cooler != "" and not gs.fit_inventory_part(Ids.COOLER, cooler), "the cooler cannot go on before the CPU")
    var minutes: int = gs.night_minutes
    var cpu: String = _buy(gs, str(parts["cpu"]))
    check(gs.fit_catalog_stock(cpu, CustomerPC.CPU_SLOT) and gs.night_minutes == minutes + BuildRequest.minutes("cpu"), "fitting the CPU costs its assembly minutes")
    minutes = gs.night_minutes
    check(gs.fit_inventory_part(Ids.COOLER, cooler) and gs.night_minutes == minutes + BuildRequest.minutes("cooler") and bool(gs.job["paste_done"]) and str(gs.job["paste_grade"]) == BuildRequest.PASTE_GRADE, "the cooler goes on with its pre-applied paste, for its minutes")
    check((gs.job["loose_parts"] as Array).is_empty(), "no customer original was set aside")
    var i: int = 0
    for id: Variant in parts["ram"]:
        check(gs.fit_catalog_stock(_buy(gs, str(id)), CustomerPC.RAM_SLOTS[i]), "memory stick %d fitted" % (i + 1))
        i += 1
    i = 0
    for id: Variant in parts["storage"]:
        check(gs.fit_catalog_stock(_buy(gs, str(id)), CustomerPC.STORAGE_SLOTS[i]), "drive %d fitted" % (i + 1))
        i += 1
    check(gs.fit_catalog_stock(_buy(gs, str(parts["psu"])), CustomerPC.PSU_SLOT), "the power supply is fitted")
    var gpu: String = _buy(gs, str(parts["gpus"][0]))
    check(gs.fit_inventory_part(Ids.GPU, gpu) and int(gs.job["gpu_screws"]) == 0, "the graphics card goes in, its screws still loose")
    if (parts["gpus"] as Array).size() > 1: check(gs.fit_catalog_stock(_buy(gs, str(parts["gpus"][1])), CustomerPC.GPU2_SLOT), "the second card goes in")
    while gs.turn_gpu_screw(): pass
    check(Checks.boot(gs.job)["ok"], "the finished build starts")
    var shop_check: Dictionary = gs.assess()
    check(float(shop_check["temp"]) < Legacy.PASS_TEMP and not str(shop_check["notes"]).contains("Downgrade"), "it passes the shop's own check without repair-only notes")
    check(BuildRequest.value(gs.job) == int(plan["cost"]), "its value at new prices is what the plan cost")

    # ---- 06:00 stops assembly ----
    var saved_minutes: int = gs.night_minutes
    gs.night_minutes = Clock.SHIFT_MINUTES - 1
    var spare: String = _buy(gs, "ram_4gb")
    var free_ram: String = ""
    for slot: String in CustomerPC.RAM_SLOTS:
        if not gs.job["shop_fitted"].has(slot): free_ram = slot
    if free_ram != "":
        check(not gs.fit_catalog_stock(spare, free_ram) and gs.assembly_blocker("ram").contains("06:00"), "past the end of the night nothing more can be fitted, and the bench says why")
    gs.night_minutes = saved_minutes

    # ---- save and load keep the build ----
    gs.save_game()
    check(gs.load_game() and PcBuild.is_build(gs.job) and BuildRequest.record(gs.job) == BuildRequest.sanitize(spec_a) and PcBuild.case_model(gs.job) == str(Catalog.DEFAULT_CASE[form]), "the build record, request and case survive save and load")
    night.bound_path = ""
    check(night.ensure(gs) and not night.read_only, "the night manifest stays valid with a build in it")

    # ---- collection: the second half, needs and wants, the scam hooks ----
    var cash: int = gs.money
    var customer: String = str(gs.job["customer_id"])
    var card: Dictionary = gs.collect_active()
    check(int(card["paid"]) == int(spec_a["budget"]) - int(spec_a["deposit"]) and gs.money == cash + int(card["paid"]), "on collection they pay the rest of the budget, never more")
    check(int(card["score"]) >= 100 - 10 * (spec_a["wants"] as Array).size() and int(card["score"]) >= 70 and str(card["reaction"]).contains("build"), "a build that meets its needs leaves the customer happy (a skipped want costs a little)")
    var history: Array = gs.customer_view(customer)["history"]
    check(not history.is_empty() and int(history[history.size() - 1]["build"]["budget"]) == int(spec_a["budget"]) and int(history[history.size() - 1]["build"]["value"]) == int(plan["cost"]), "scam hook: the budget and the value at new prices are kept with the visit")
    var delivered: Dictionary = card["job"]["build"]["delivered"]
    check(int(delivered["new"]) == int(delivered["parts"]) and int(delivered["untested"]) == 0, "scam hook: what was handed over is counted by what the shop knew (all new here)")
    check(PcBuild.sanitize(gs.person(customer)["pc"])["cpu"] == str(parts["cpu"]), "the customer now owns that PC")
    check(gs.player_inventory.all(func(rec: Dictionary) -> bool: return str(rec.get("fitted_in", "")) != str(card["ticket"])), "every part in it left the shop's stock")

    # ---- a build that misses a need ----
    gs.night_minutes = 0
    var order_b: Dictionary = {}
    for s in range(20):
        order_b = _active_build(gs, night, 9000 + s, 4)
        if not order_b.is_empty() and int(BuildRequest.record(gs.job)["needs"]["processing"]) > 12: break
    if not order_b.is_empty():
        gs.fit_catalog_stock(_buy(gs, "cpu_pentium_g4650"), CustomerPC.CPU_SLOT)
        gs.fit_inventory_part(Ids.COOLER, _buy(gs, "cool_stock_box"))
        gs.fit_catalog_stock(_buy(gs, "ram_32gb"), CustomerPC.RAM_SLOTS[0])
        gs.fit_catalog_stock(_buy(gs, "sto_nvme_2tb"), CustomerPC.STORAGE_SLOTS[0])
        gs.fit_catalog_stock(_buy(gs, "psu_600w"), CustomerPC.PSU_SLOT)
        gs.fit_inventory_part(Ids.GPU, _buy(gs, "gpu_rx6060"))
        while gs.turn_gpu_screw(): pass
        var weak_card: Dictionary = gs.collect_active()
        if int(BuildRequest.record(weak_card["job"])["needs"]["processing"]) > 12:
            check((weak_card["misses"] as Array).any(func(m: Variant) -> bool: return str(m).contains("processing")) and int(weak_card["score"]) <= 60, "a build too slow for its use is a missed need and the customer is unhappy")

    # ---- case and motherboard swaps (only while the case is empty) ----
    gs.night_minutes = 0
    var order_c: Dictionary = _active_build(gs, night, 5151, 5)
    check(not order_c.is_empty(), "another build")
    if not order_c.is_empty():
        gs.money += 500
        var other_form: String = "compact" if str(gs.job["layout"]) == "tower" else "tower"
        var target: String = "case_compact_quiet" if other_form == "compact" else "case_tower_mesh"
        check(not bool(gs.choose_build_case(target)["ok"]), "the case cannot be swapped with the motherboard in it")
        check(gs.take_out_board(), "an empty build's motherboard comes out")
        var money_before: int = gs.money
        var old_case: String = PcBuild.case_model(gs.job)
        var old_board: String = PcBuild.board_model(gs.job)
        minutes = gs.night_minutes
        var swapped: Dictionary = gs.choose_build_case(target)
        check(bool(swapped["ok"]) and str(gs.job["layout"]) == other_form and PcBuild.case_model(gs.job) == target, "the case is swapped, and the layout follows it")
        var new_board: String = PcBuild.board_model(gs.job)
        check(str(Catalog.BOARDS[new_board]["form"]) == other_form and gs.night_minutes == minutes + BuildRequest.minutes("case"), "a case of the other size takes a motherboard of its size; swapping costs night time")
        check(gs.money == money_before - (int(Catalog.CASES[target]["price"]) - int(Catalog.CASES[old_case]["price"])) - (int(Catalog.BOARDS[new_board]["price"]) - int(Catalog.BOARDS[old_board]["price"])), "the old case and board are refunded, the new ones paid")
        var wrong: String = Catalog.boards_for("tower" if other_form == "compact" else "compact")[0]
        check(not bool(gs.choose_build_board(wrong)["ok"]), "a motherboard of the wrong size is refused")
        var better: String = ""
        for id: String in Catalog.boards_for(other_form):
            if id != new_board: better = id
        money_before = gs.money
        check(bool(gs.choose_build_board(better)["ok"]) and gs.money == money_before - (int(Catalog.BOARDS[better]["price"]) - int(Catalog.BOARDS[new_board]["price"])), "a better motherboard can be chosen while it is out")
        minutes = gs.night_minutes
        check(gs.fit_board_back() and gs.night_minutes == minutes + BuildRequest.minutes("board"), "fitting a build's motherboard costs night time")
        check(not bool(gs.choose_build_case(str(Catalog.DEFAULT_CASE[other_form]))["ok"]), "with the motherboard back in, the case stays")

        # The real hardware bench, with this build on it.
        var view: Node = load("res://scenes/night_hardware.tscn").instantiate()
        root.add_child(view)
        await process_frame
        check(view.case_button.visible and view.get_node_or_null("RepairTab") == null, "the bench offers Case and motherboard (0.53.0: stations, no tabs)")
        check(view.inventory.items.all(func(item: Dictionary) -> bool: return not CustomerPC.is_customer(str(item["part"]["id"]))), "the bench shows no customer part in a build")
        view._toggle_case_panel()
        check(view.case_panel.visible, "the case panel opens")
        view._toggle_case_panel()
        var bench_cpu: String = _buy(gs, "cpu_i5_6060")
        view._configure_layout()
        minutes = gs.night_minutes
        view._fit_stock(bench_cpu, CustomerPC.CPU_SLOT)
        check(str(gs.job["shop_fitted"].get(CustomerPC.CPU_SLOT, {}).get("uid", "")) == bench_cpu and gs.night_minutes == minutes + BuildRequest.minutes("cpu"), "fitting from the bench costs the assembly minutes")
        view.queue_free()
        await process_frame

    # ---- the morning brings build requests from night 5 ----
    var kept: Array = night.tickets.duplicate(true)
    night.tickets = night.tickets.filter(func(e: Dictionary) -> bool: return str(e["id"]) == str(gs.job["id"]))
    gs.money = 5000
    var cash_before: int = gs.money
    var morning: Dictionary = night._arrivals(gs, 5)
    var builds: Array = (morning["cards"] as Array).filter(func(c: Dictionary) -> bool: return bool(c.get("build", false)))
    check(not builds.is_empty() and bool((morning["cards"] as Array)[0].get("build", false)), "night 5's first new customer brings a build request")
    if not builds.is_empty():
        var arrived: Dictionary = builds[0]["job"]
        var spec_m: Dictionary = BuildRequest.record(arrived)
        check(int(builds[0]["paid"]) == int(spec_m["deposit"]) - BuildRequest.starter_cost(str(arrived["layout"])) and str(builds[0]["reaction"]).contains("up front"), "they pay half up front; the basic case and board come out of it")
        var net: int = 0
        for c: Dictionary in builds: net += int(c["paid"])
        check(gs.money == cash_before + net, "the deposits reach the shop's cash")
    night.tickets = night.tickets.filter(func(e: Dictionary) -> bool: return str(e["id"]) == str(gs.job["id"]))
    var early: Dictionary = night._arrivals(gs, 3)
    check((early["cards"] as Array).all(func(c: Dictionary) -> bool: return not bool(c.get("build", false))), "night 3 brings no build requests")
    night.tickets = kept

    _remove_save_files(manifest)
    _remove_save_files(gs.save_path + ".navigation.json")
    restore_save(gs)
    finish("Build requests")
