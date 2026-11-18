# 0.48.1 (user, 18 November 2026): the motherboard is a PC part and comes out only once every other part is
# out; the GPU bracket screws sit on the card's rear bracket; the vacuum's bin and hose keep their contents
# across screens and reloads; paste survives leaving (or closing the game) mid-press.
extends "res://tools/test_support.gd"
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const Layout = preload("res://scripts/data/layout.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const VacuumState = preload("res://scripts/bench/vacuum_state.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const PasteSnapshot = preload("res://scripts/night/paste_snapshot.gd")
const Generator = preload("res://scripts/rules/ticket_generator.gd")
const Ids = preload("res://scripts/data/ids.gd")

func _initialize() -> void:
    call_deferred("run_checks")


func _fitted_customer_part(view: Node) -> int:
    var best: int = -1
    for i in range(view.inventory.items.size()):
        var item: Dictionary = view.inventory.items[i]
        var key: String = str(item["part"]["id"])
        if not CustomerPC.is_customer(key) or str(item["location"]) == "drawer": continue
        if CustomerPC.part_of(key) == Ids.COOLER: return i   # the cooler comes off before the CPU
        if best < 0 or CustomerPC.part_of(key) != "cpu": best = i
    return best


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "board_bench_state_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)

    # ---- motherboards as parts ----
    check(Catalog.boards_for("tower").size() >= 2 and Catalog.boards_for("compact").size() >= 2 and Catalog.is_board(str(Catalog.DEFAULT_BOARD["tower"])), "boards exist for both case sizes")
    check(PcBuild.sanitize({"board": "board_atx_z390"})["board"] == "board_atx_z390" and PcBuild.sanitize({"board": "gpu_gtx1660"})["board"] == "" and PcBuild.sanitize({})["board"] == "", "only real board models are kept; none recorded means the case's own board")
    check(PcBuild.board_model({"layout": "compact", "parts": {"board": "board_atx_z390"}}) == Catalog.DEFAULT_BOARD["compact"] and PcBuild.board_model({"layout": "tower", "parts": {"board": "board_atx_z390"}}) == "board_atx_z390", "a board of the wrong size for the case reads as the case's default")
    gs.tickets_taken = 0
    gs.new_game(false)
    check(night.start(gs), "a night starts")
    check(str(PcBuild.part_lines(gs.job)[0]).begins_with("Motherboard: ") and Findings_has(gs.job, "Motherboard: "), "the motherboard is listed with the PC's parts and in Findings")
    check(gs.board_blocker().contains("CPU") and gs.board_blocker().contains("graphics card") and not gs.take_out_board(), "with parts fitted, the motherboard cannot come out and the player is told what is still in")

    # ---- the whole journey on the real hardware bench ----
    var view: Node = load("res://scenes/night_hardware.tscn").instantiate()
    root.add_child(view)
    await process_frame
    check(view.board_button.text.contains("Take out") and view.board_button.tooltip_text.contains("Still fitted"), "the bench offers the motherboard and says why it cannot come out yet")
    view._board_pressed()
    check(not PcBuild.board_out(gs.job) and str(view.status_label.text).contains("Take out every part first"), "pressing it early only explains")
    var guard: int = 0
    while _fitted_customer_part(view) >= 0 and guard < 20:
        var i: int = _fitted_customer_part(view)
        view.inventory.begin(i)
        view.inventory.store(view.inventory.first_space(i))
        view._save_inventory()
        guard += 1
    check(gs.board_blocker() == "", "every part dragged to the drawer: the motherboard may come out")
    var board_name: String = str(Catalog.board(PcBuild.board_model(gs.job))["name"])
    view._board_pressed()
    check(PcBuild.board_out(gs.job) and view.board_button.text.contains("Fit the motherboard back") and str(view.status_label.text).contains(board_name), "the motherboard comes out and the bench says so")
    check(Findings_last(gs.job).contains("Taken out: Motherboard"), "taking it out is work history in Findings")
    check(str(PcBuild.missing(gs.job)[0]).begins_with("MOTHERBOARD") and str(Checks.boot(gs.job)["message"]).contains("MOTHERBOARD"), "a PC without its motherboard cannot start, and the boot check names it")
    var stock_i: int = -1
    for i in range(view.inventory.items.size()):
        if not CustomerPC.is_customer(str(view.inventory.items[i]["part"]["id"])) and str(view.inventory.items[i]["location"]) == "drawer": stock_i = i
    view.inventory.begin(stock_i)
    var target: Vector2 = view._connector_rect(view.board["connectors"][0]).get_center()
    var preview: Dictionary = view._candidate(target)
    check(not bool(preview.get("ok", true)) and str(preview.get("message", "")).contains("motherboard is out"), "nothing can be dropped into the case while the motherboard is out")
    view.inventory.cancel()
    check(not gs.set_service_part_fitted(Ids.GPU, true) and not gs.fit_catalog_stock("stock_ram_demo", "ram_1"), "state refuses fitting without the motherboard too")
    gs.save_game()
    check(gs.load_game() and PcBuild.board_out(gs.job), "the motherboard stays out through save and load")
    view._board_pressed()
    check(not PcBuild.board_out(gs.job) and Findings_last(gs.job).contains("Fitted: Motherboard") and gs.set_service_part_fitted(Ids.GPU, true), "fitted back, parts can go in again")
    view.queue_free()
    await process_frame

    # ---- the board travels with the PC ----
    gs.job["parts"]["board"] = "board_atx_z390"
    var applied: Dictionary = CustomerPC.apply(gs.job, {})
    check(applied["parts"]["board"] == "board_atx_z390", "writing the bench back keeps the motherboard model")
    gs.settle_custody()
    check(str(gs.job["parts"]["board"]) == "board_atx_z390", "settling at collection keeps it in the PC record")
    var old: Dictionary = gs.job.duplicate(true)
    old.erase("board_out")
    old["parts"].erase("board")
    check(not PcBuild.board_out(old) and PcBuild.board_model(old) == Catalog.DEFAULT_BOARD["compact" if str(old.get("layout", "tower")) == "compact" else "tower"], "an old save without a board has its case's default board, fitted")
    for slot in range(8):
        var r: RandomNumberGenerator = Generator.rng_for(31, 4, slot)
        var drawn: Dictionary = Generator.draw_case(gs.make_ticket_job(""), Generator.new_person(r, "p%04d" % slot), {}, gs.diagnosis_capabilities(), 4, r)
        var layout: String = "compact" if str(drawn["job"]["layout"]) == "compact" else "tower"
        check(str(drawn["job"]["parts"]["board"]) in Catalog.boards_for(layout), "a generated PC has a motherboard that fits its case (%s)" % layout)

    # ---- GPU bracket screws on the bracket, not on the second slot ----
    for layout_id: String in ["tower", "compact"]:
        var profile: Dictionary = PCLayout.profile(layout_id)
        var geometry: Dictionary = PCLayout.display(profile, Layout.WORKSHOP_PC)
        var cell: float = geometry["cell"]
        var slot: Rect2 = PCLayout.connector_rect(profile, geometry, "pcie")
        var board_rect: Rect2 = PCLayout.board_rect(profile, geometry)
        var radius: float = InstallFaults.gpu_screw_radius(cell)
        var clear: bool = true
        for center: Vector2 in InstallFaults.gpu_screw_centers(slot, cell):
            if center.x + radius > board_rect.position.x + 0.5 or not (geometry["case_rect"] as Rect2).has_point(center): clear = false
            if not InstallFaults.gpu_bracket_rect(slot, cell).has_point(center): clear = false
            for c: Dictionary in profile["board"]["connectors"]:
                if PCLayout.connector_rect(profile, geometry, str(c["id"])).grow(-1.0).has_point(center): clear = false
        check(clear, "%s case: both screws sit on the GPU's rear bracket, outside the board and off every slot" % layout_id)
    var s_slot: Rect2 = PCLayout.connector_rect(PCLayout.profile(), PCLayout.display(PCLayout.profile(), Layout.WORKSHOP_PC), "pcie")
    var s_cell: float = PCLayout.display(PCLayout.profile(), Layout.WORKSHOP_PC)["cell"]
    var centers: Array = InstallFaults.gpu_screw_centers(s_slot, s_cell)
    check(InstallFaults.gpu_screw_at(s_slot, s_cell, centers[0]) == 0 and InstallFaults.gpu_screw_at(s_slot, s_cell, centers[1]) == 1 and InstallFaults.gpu_screw_at(s_slot, s_cell, s_slot.get_center() + Vector2(0, s_cell)) == -1, "clicking a screw finds it; the second PCIe slot is not a screw any more")

    # ---- the vacuum keeps its contents ----
    var junk: Dictionary = VacuumState.sanitize({"bin": 99999, "hose": [[2.0, 5], [0.5, -3], "x", [0.2, NAN], [0.1, 4]]})
    check(is_equal_approx(float(junk["bin"]), DustBin.CAPACITY) and junk["hose"] == [[1.0, 5.0], [0.1, 4.0]], "saved vacuum contents are rebuilt within the bin's capacity, bad clumps dropped")
    gs.new_game(false)
    gs.vacuum_state = {"bin": 60.0, "hose": [[0.4, 12.0]]}
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    await process_frame
    check(is_equal_approx(bench.bin.fill, 60.0) and is_equal_approx(bench.tools.flow.carried(), 12.0), "opening the bench finds the bin and hose as they were left")
    bench.bin.fill = 80.0
    bench._save_dust()
    check(gs.load_game() and is_equal_approx(float(gs.vacuum_state["bin"]), 80.0) and (gs.vacuum_state["hose"] as Array).size() == 1, "leaving saves them, and they survive a reload")
    bench._empty_bin()
    check(gs.load_game() and is_equal_approx(float(gs.vacuum_state["bin"]), 0.0), "emptying the bin is saved too")
    bench.queue_free()
    await process_frame

    # ---- paste survives closing the game mid-press ----
    gs.tickets_taken = 0
    gs.new_game(false)
    check(night.start(gs), "a fresh night for the paste check")
    var repair: Node = load("res://scenes/night_bench.tscn").instantiate()
    root.add_child(repair)
    repair.set_physics_process(false)
    await process_frame
    repair._select_stage(1)
    repair.paste.deposit(25.5, 25.5, 80)
    repair._on_mount_pressed()
    repair.scripted_pressing = true
    for k in range(4): repair.thermal._step_mount(0.5, Vector2.ZERO)
    repair.scripted_pressing = null
    var pressed: Dictionary = PasteSnapshot.capture(repair.paste)
    check(repair.mount.active, "the cooler is being pressed")
    repair._notification(NOTIFICATION_WM_CLOSE_REQUEST)
    check(not repair.mount.active and str(gs.job["paste_grade"]) == "" and gs.job["hardware_trial"].get("night_paste", {}).get("height_bytes", "") == pressed["height_bytes"], "closing the game mid-press cancels the press (no result) but saves the paste exactly as pressed")
    repair.queue_free()
    await process_frame
    check(gs.load_game(), "the save reloads")
    var again: Node = load("res://scenes/night_bench.tscn").instantiate()
    root.add_child(again)
    again.set_physics_process(false)
    await process_frame
    check(PasteSnapshot.capture(again.paste)["height_bytes"] == pressed["height_bytes"] and not again.mount.active, "reopened, the bench shows the pressed paste and waits for a new press")
    again.queue_free()
    await process_frame

    _remove_save_files(manifest)
    restore_save(gs)
    finish("Board and bench state")


func Findings_has(job: Dictionary, text: String) -> bool:
    return "\n".join(preload("res://scripts/rules/findings.gd").configuration(job)).contains(text)


func Findings_last(job: Dictionary) -> String:
    var notes: Array = job.get("findings", [])
    return "" if notes.is_empty() else str(notes.back()["text"])
