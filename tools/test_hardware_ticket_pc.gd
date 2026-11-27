extends "res://tools/test_support.gd"
# D131: the hardware bench is a projection of the ticket's own PC; GPU bracket screws need a screwdriver.
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const Faults = preload("res://scripts/rules/install_faults.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Upgrades = preload("res://scripts/data/upgrades.gd")

func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs, "hardware_ticket_pc_test.json")
    gs.new_game(false)
    root.get_node("NightSession").ensure(gs)

    # Pure projection of the job.
    var job: Dictionary = gs.job
    var parts: Array = CustomerPC.components(job)
    var ids: Array = parts.map(func(p: Dictionary) -> String: return str(p["id"]))
    check(ids[0] == CustomerPC.uid(job, "cpu") and CustomerPC.uid(job, Ids.GPU) in ids and CustomerPC.uid(job, Ids.COOLER) in ids, "ticket PC lists its own CPU, GPU and cooler")
    check(not CustomerPC.is_fixed(CustomerPC.uid(job, "cpu")) and not CustomerPC.is_fixed(CustomerPC.uid(job, Ids.GPU)), "0.46.0: nothing is locked; CPU and GPU can both come out")
    var fitted: Dictionary = CustomerPC.placements(job, {})
    check(str(fitted[CustomerPC.uid(job, Ids.GPU)]["location"]) == "pcie", "fitted GPU sits on the PCIe slot")

    # Repair bench state is mirrored: removing the GPU unscrews it and it appears in the drawer.
    check(int(job["gpu_screws"]) == 2 and gs.pickup_faults().is_empty(), "a fresh PC has tight GPU screws and no hidden fault")
    check(gs.set_service_part_fitted(Ids.GPU, false) and int(gs.job["gpu_screws"]) == 0, "taking the GPU out unscrews it")
    check(not CustomerPC.placements(gs.job, {}).has(CustomerPC.uid(gs.job, Ids.GPU)), "removed GPU is not on the board")
    check(not gs.turn_gpu_screw(), "a removed GPU has no screws to turn")
    check(gs.set_service_part_fitted(Ids.GPU, true) and int(gs.job["gpu_screws"]) == 0, "refitted GPU is loose")
    check(Faults.GPU_LOOSE in gs.pickup_faults(), "a loose GPU becomes a hidden pickup fault")
    check(gs.turn_gpu_screw() and gs.turn_gpu_screw() and not gs.turn_gpu_screw(), "two screws, no more")
    check(gs.pickup_faults().is_empty(), "tight screws clear the fault")

    # Screw geometry.
    var slot := Rect2(100, 100, 200, 40)
    check(Faults.gpu_screw_at(slot, 20, Faults.gpu_screw_centers(slot, 20)[0]) == 0 and Faults.gpu_screw_at(slot, 20, Vector2(900, 900)) == -1, "GPU screw hit test works")

    # The live hardware bench scene.
    gs.set_service_part_fitted(Ids.GPU, false)
    var view: Node = load("res://scenes/night_hardware.tscn").instantiate()
    root.add_child(view)
    await process_frame
    var cpu_uid: String = CustomerPC.uid(gs.job, "cpu")
    var found_cpu: bool = false
    var gpu_in_drawer: bool = false
    for item: Dictionary in view.inventory.items:
        if str(item["part"]["id"]) == cpu_uid: found_cpu = str(item["location"]) == "cpu"
        if str(item["part"]["id"]) == CustomerPC.uid(gs.job, Ids.GPU): gpu_in_drawer = str(item["location"]) == "drawer"
    check(found_cpu, "hardware bench shows the ticket's CPU fitted")
    check(gpu_in_drawer, "a GPU removed at the repair bench is in the hardware drawer")
    view.queue_free()
    await process_frame

    # Shop data.
    check(Upgrades.LIST.size() == 4 and Upgrades.LIST.all(func(u: Dictionary) -> bool: return gs.UPGRADE_PRICES.has(u["id"])), "every shop upgrade has a price")
    restore_save(gs)
    finish("Hardware ticket PC")
