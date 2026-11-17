# Wave 3 session 3.3b (D149): every part type comes out at the hardware bench, a second PCIe slot,
# buying any catalogue part, fitting it into an empty slot, upgrading and swapping the first card.
extends "res://tools/test_support.gd"
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const Ids = preload("res://scripts/data/ids.gd")

func _initialize() -> void: call_deferred("run_checks")

func stock_uid(gs: Node, model: String) -> String:
    for record: Dictionary in gs.player_inventory:
        if str(record.get("model", "")) == model: return str(record["uid"])
    return ""

func item_index(view: Node, key: String) -> int:
    for i in range(view.inventory.items.size()):
        if str(view.inventory.items[i]["part"]["id"]) == key: return i
    return -1

func connector(view: Node, id: String) -> Dictionary:
    for c: Dictionary in view.board["connectors"]:
        if c["id"] == id: return c
    return {}

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "hardware_parts_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.new_game(false)
    check(night.start(gs), "night starts")
    var job: Dictionary = gs.job

    # Pure projection.
    check(CustomerPC.part_of(CustomerPC.uid(job, "ram_a")) == "ram" and CustomerPC.part_of(CustomerPC.uid(job, "storage_b")) == "storage" and CustomerPC.part_of(CustomerPC.uid(job, "loose_3")) == "loose" and CustomerPC.part_of(CustomerPC.uid(job, "gpu_2")) == "gpu_2" and CustomerPC.part_of(CustomerPC.uid(job, "psu")) == "psu", "customer uids name their part kind")
    var placed: Dictionary = CustomerPC.placements(job, {})
    check(CustomerPC.components(job).size() == 6 and placed[CustomerPC.uid(job, "psu")]["location"] == "psu_bay" and placed[CustomerPC.uid(job, "storage_a")]["location"] == "m2_1", "the demo PC has CPU, RAM, drive, PSU, GPU and cooler, each on its slot")
    var snap: Dictionary = placed.duplicate(true)
    snap[CustomerPC.uid(job, "cpu")] = {"location": "drawer", "cell": [0, 0], "rotation": 0}
    var applied: Dictionary = CustomerPC.apply(job, snap)
    check(applied["parts"]["cpu"] == "" and applied["loose_parts"] == [{"id": "cpu_i5_6060", "broken": false}], "a CPU moved to the drawer leaves the socket empty and becomes a loose customer part")
    var empty: Dictionary = job.duplicate(true)
    empty["parts"] = applied["parts"]
    check(PcBuild.missing(empty).size() == 1 and str(PcBuild.missing(empty)[0]).begins_with("CPU"), "an empty socket is reported missing")

    # Missing parts stop the boot and fail the hardware check.
    empty["pc_powered"] = true
    check(not Checks.boot(empty)["ok"] and str(Checks.boot(empty)["message"]).contains("CPU: MISSING"), "no CPU, no boot")
    check(not WorkReport.hardware_check(empty)["ok"], "no CPU fails the hardware check")

    # Buying and fitting catalogue parts.
    gs.money = 5000
    check(gs.buy_catalog_part("ram_16gb") and gs.money == 5000 - 26 and stock_uid(gs, "ram_16gb") != "", "any catalogue part can be bought into the drawer")
    check(not gs.buy_catalog_part("nonsense"), "unknown parts cannot be bought")
    check(gs.fit_catalog_stock(stock_uid(gs, "ram_16gb"), "ram_2") and gs.job["parts"]["ram"] == ["ram_8gb", "ram_16gb"] and gs.job["pc_specs"]["ram_gb"] == 24 and stock_uid(gs, "ram_16gb") == "", "a bought stick fits an empty RAM slot and becomes the customer's")
    gs.buy_catalog_part("cpu_rysen5_3060")
    check(not gs.fit_catalog_stock(stock_uid(gs, "cpu_rysen5_3060"), "cpu"), "a CPU cannot go into an occupied socket")
    gs.buy_catalog_part("gpu_rx6060")
    check(gs.fit_catalog_stock(stock_uid(gs, "gpu_rx6060"), "pcie_2") and gs.current_gpu_power() == 42, "a second card in PCIe slot 2 adds to the first (32 + 20 / 2)")
    gs.job["parts"]["gpus"] = ["gpu_gtx1660", "gpu_rtx5900"]
    gs.set_pc_powered(true)
    check(not Checks.boot(gs.job)["ok"] and str(WorkReport.hardware_check(gs.job)["message"]).contains("TOO SMALL"), "a big second card on the small PSU: no boot, and the hardware check says the PSU is too small")
    gs.job["parts"]["gpus"] = ["gpu_gtx1660", "gpu_rx6060"]

    # Upgrading the first card: the customer's working card stays theirs, in the drawer.
    gs.set_service_part_fitted(Ids.GPU, false)
    gs.buy_catalog_part("gpu_rtx3800")
    check(gs.fit_inventory_part(Ids.GPU, stock_uid(gs, "gpu_rtx3800")) and gs.job["service_replacements"][Ids.GPU] == "model:gpu_rtx3800", "a catalogue card upgrades a working first card taken out")
    check(CustomerPC.loose(gs.job) == [{"id": "gpu_gtx1660", "broken": false}] and gs.current_gpu_power() == 66, "the customer's old card is a loose part; the new one counts (50 + 32 / 2)")
    # Swapping it back: the old card on PCIe slot 1, the new one out.
    gs.set_service_part_fitted(Ids.GPU, false)
    var back: Dictionary = CustomerPC.placements(gs.job, {})
    back[CustomerPC.uid(gs.job, Ids.GPU)] = {"location": "drawer", "cell": [0, 0], "rotation": 0}
    back[CustomerPC.uid(gs.job, "loose_0")] = {"location": "pcie", "cell": [0, 0], "rotation": 0}
    check(gs.apply_bench(back) and gs.job["parts"]["gpus"][0] == "gpu_gtx1660" and not gs.job["service_replacements"].has(Ids.GPU) and not Ids.GPU in gs.job["removed_parts"], "the customer's own card can go back into slot 1")
    check(CustomerPC.loose(gs.job) == [{"id": "gpu_rtx3800", "broken": false}] and gs.job["gpu_screws"] == 0, "the bought card is now loose, and the refitted one needs its screws")

    # Saves keep all of it.
    gs.buy_catalog_part("sto_nvme_1tb")
    gs.save_game()
    check(gs.load_game() and CustomerPC.loose(gs.job).size() == 1 and stock_uid(gs, "sto_nvme_1tb") != "" and gs.job["parts"]["ram"].size() == 2, "loose parts, bought stock and fitted parts survive save and load")
    gs.job["service_replacements"] = {Ids.GPU: "model:gpu_rtx3800"}
    gs.save_game()
    check(gs.load_game() and gs.job["service_replacements"].get(Ids.GPU, "") == "model:gpu_rtx3800", "a catalogue replacement survives a reload")
    gs.job["service_replacements"] = {}
    night.checkpoint(gs)

    # The bench itself.
    var view: Node = load("res://scenes/night_hardware.tscn").instantiate()
    root.add_child(view)
    await process_frame
    var cpu_key: String = CustomerPC.uid(gs.job, "cpu")
    var cpu_i: int = item_index(view, cpu_key)
    check(cpu_i >= 0 and view.inventory.items[cpu_i]["location"] == "cpu" and item_index(view, CustomerPC.uid(gs.job, "psu")) >= 0 and item_index(view, CustomerPC.uid(gs.job, "gpu_2")) >= 0, "the bench shows the CPU, PSU and second card on their slots")
    view._try_pick_up(view._item_rect(cpu_i).get_center())
    check(view.inventory.held == -1 and str(view.status_label.text).contains("cooler"), "the CPU cannot come out while the cooler sits on it")
    gs.set_service_part_fitted(Ids.COOLER, false)
    view._configure_layout()
    cpu_i = item_index(view, cpu_key)
    view.inventory.begin(cpu_i)
    check(view.inventory.store(view.inventory.first_space(cpu_i)), "the CPU goes into the drawer")
    view._save_inventory()
    check(gs.job["parts"]["cpu"] == "" and CustomerPC.loose(gs.job).any(func(e: Dictionary) -> bool: return e["id"] == "cpu_i5_6060"), "taking the CPU out empties the socket and keeps it as the customer's")
    var loose_cpu: int = -1
    for i in range(view.inventory.items.size()):
        if CustomerPC.catalog_id(gs.job, str(view.inventory.items[i]["part"]["id"])) == "cpu_i5_6060": loose_cpu = i
    view.inventory.begin(loose_cpu)
    var put: Dictionary = view.inventory.install(connector(view, "cpu")["origin"])
    view._save_inventory()
    check(put["ok"] and gs.job["parts"]["cpu"] == "cpu_i5_6060" and not CustomerPC.loose(gs.job).any(func(e: Dictionary) -> bool: return e["id"] == "cpu_i5_6060"), "the CPU goes back into the socket")
    check(view.order_panel != null and not view.order_panel.visible, "Order parts starts closed")
    view._toggle_order()
    var cash: int = gs.money
    view._buy("psu_focus750")
    check(view.order_panel.visible and gs.money == cash - 85 and stock_uid(gs, "psu_focus750") != "" and item_index(view, stock_uid(gs, "psu_focus750")) >= 0, "buying from the panel puts the part in the drawer")
    view._reset_state()
    check(gs.job["parts"]["cpu"] == "cpu_i5_6060" and gs.job["parts"]["psu"] == "psu_cv450", "Rearrange drawer never pulls parts out of the PC")
    view.queue_free()
    await process_frame
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Hardware parts")
