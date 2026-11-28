# 0.59.1 (D185): laptops. The user, 28 November 2026: "add laptops. they take up less space than a desktop and
# you can choose to store them on top of eachother or on top of desktops. you cannot change the case or the
# motherboard for a laptop. its faster to service and space and airflow constraints are more important ...
# mara comes in with a laptop". Answers: only RAM and storage change; faster = less hands-on work; stacks up to 3
# high, top one off first. The laptop's shape and spots, its locked parts, its heat, Mara's laptop at the counter
# and on both benches, generated laptops, and storage piles.
extends "res://tools/test_support.gd"
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const LayoutRules = preload("res://scripts/rules/layout_rules.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const Laptop = preload("res://scripts/rules/laptop.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Generator = preload("res://scripts/rules/ticket_generator.gd")
const Customers = preload("res://scripts/data/customers.gd")


func _initialize() -> void:
    call_deferred("run_checks")


func sample(id: String, size: Vector2i, stackable: bool) -> Dictionary:
    return {"id": id, "source_uid": id, "category": "pc", "kind": "pc", "label": id, "model": id, "size": size,
        "owner": "Customer", "condition": "", "reserved": false, "stackable": stackable, "finish": "graphite", "note": ""}


func spots(profile: String) -> Dictionary:
    var out: Dictionary = {}
    for z: Dictionary in DustZones.zones(profile): out[str(z["id"])] = z
    return out


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "laptops_test.json")
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json", gs.save_path + ".storage.json"]: _remove_save_files(path)

    # ---- the laptop's shape, case, board and dusty spots ----
    var pc: Dictionary = PCLayout.profile("laptop")
    check(pc["id"] == "laptop" and pc["size"] == Vector2i(16, 10) and LayoutRules.validate(pc).is_empty(), "a laptop is a valid 16 x 10 layout, its board inside it")
    var slots: Array = (pc["board"]["connectors"] as Array).map(func(c: Dictionary) -> String: return str(c["id"]))
    check(slots.has("ram_1") and slots.has("ram_2") and slots.has("m2_1") and not slots.has("pcie") and not slots.has("psu_bay") and not slots.has("ram_3") and not slots.has("m2_2"), "its board has two memory slots and one drive slot, nothing else to fit")
    check(Catalog.boards_for("laptop") == ["board_laptop_hm65"] and Catalog.DEFAULT_CASE["laptop"] == "case_laptop" and not Catalog.swappable("laptop") and Catalog.swappable("tower"), "a laptop has its own board and case, never sold or swapped")
    var lap: Dictionary = spots("laptop")
    var tower: Dictionary = spots("tower")
    var dusty: int = 0
    var clumps: Array = [0, 0]
    for id: String in lap:
        if float(lap[id]["temp_penalty"]) > 0.0: dusty += 1
        clumps[0] += int(lap[id]["bundles"])
    for id: String in tower: clumps[1] += int(tower[id]["bundles"])
    check(dusty == 4 and not lap.has(Ids.GPU) and not lap.has("psu") and clumps[0] < clumps[1], "faster to service: four dusty spots, fewer clumps, no graphics card or PSU to clean")
    check(float(lap[Ids.COOLER]["temp_penalty"]) > float(tower[Ids.COOLER]["temp_penalty"]) and float(lap["front_filter"]["temp_penalty"]) > float(tower["front_filter"]["temp_penalty"]) and float(lap["case_fan"]["temp_penalty"]) > float(tower["case_fan"]["temp_penalty"]), "airflow matters more: each dirty spot costs more heat than on a tower")
    check(DustZones.index_of(Ids.COOLER, "laptop") == 1 and DustZones.index_of(Ids.GPU, "laptop") == -1, "zone lookups use the laptop's own list")

    # ---- Mara brings her laptop ----
    check(gs.desktop_first_ticket, "under the headless suites the first ticket is the old desktop (fixture)")
    gs.desktop_first_ticket = false
    gs.new_game(false)
    var job: Dictionary = gs.job
    var parts: Dictionary = PcBuild.sanitize(job["parts"])
    check(job["customer_id"] == "t001_mara" and PcBuild.is_laptop(job) and Laptop.finish_of(job) == "silver" and str(job["complaint"]).contains("laptop"), "Mara comes in with her silver laptop")
    check((parts["ram"] as Array).size() <= Laptop.RAM_MAX and parts["storage"] == ["sto_ssd_500"] and PcBuild.case_model(job) == "case_laptop" and PcBuild.board_model(job) == "board_laptop_hm65", "her laptop has one drive (an SSD), its own case and board")
    check(PcBuild.case_heat(job) == 6.0, "a laptop's thin case adds 6 C before any dust")

    # ---- only memory and the drive change ----
    var ids: Array = CustomerPC.components(job).map(func(p: Dictionary) -> String: return CustomerPC.part_of(str(p["id"])))
    check(ids == ["ram", "storage"] and CustomerPC.first_parts(job).is_empty(), "on the hardware bench only her memory and drive are pieces")
    var kept: Dictionary = CustomerPC.apply(job, CustomerPC.placements(job, {}))["parts"]
    check(kept["cpu"] == parts["cpu"] and kept["psu"] == parts["psu"] and kept["gpus"] == parts["gpus"] and kept["cooler"] == parts["cooler"], "the soldered processor, graphics, power and heatsink stay in the laptop")
    check(gs.board_blocker() == Laptop.BOARD_LOCKED and not gs.take_out_board(), "the motherboard never comes out")
    var desk: Dictionary = {"id": "T9", "layout": "tower", "parts": PcBuild.sanitize({"ram": ["ram_8gb", "ram_8gb", "ram_8gb"]})}
    var third: Dictionary = CustomerPC.placements(desk, {})[CustomerPC.uid(desk, "ram_c")]
    check(third["location"] == "ram_3" and int(third["rotation"]) == 1 and int(CustomerPC.placements(job, {})[CustomerPC.uid(job, "ram_a")]["rotation"]) == 1, "B84: a stick on a lying slot (a desktop's slot 3, a laptop's slots) is restored turned to fit")
    check(not gs.set_service_part_fitted(Ids.GPU, false) and not gs.set_overclock(1, 0), "no graphics card to take out, no overclocking")
    check(Laptop.why_not(job, "sto_hdd_500") == Laptop.NO_HDD and Laptop.fits(job, "sto_nvme_1tb") and Laptop.fits(job, "ram_16gb") and Laptop.why_not(job, "gpu_gtx1660") == Laptop.SOLDERED, "a 3.5-inch drive does not fit; an NVMe drive and memory do; graphics are soldered")
    gs.job["ticket"]["request"] = "build"
    check(not bool(gs.choose_build_case("case_laptop")["ok"]), "the laptop chassis is never offered as a case")
    gs.job["ticket"]["request"] = "repair"

    # ---- its heat ----
    var dirty: Dictionary = gs.assess()
    var dirty_notes: String = "\n".join(dirty["notes"])
    check(dirty_notes.contains("Heatsink still has dust (+26 C)") and dirty_notes.contains("Exhaust fins still has dust (+16 C)") and dirty_notes.contains("case's airflow: +6 C"), "the shop's check names the laptop's own spots and its heat")
    var clean: Dictionary = {}
    for z: Dictionary in DustZones.zones("laptop"): clean[str(z["id"])] = 1.0
    gs.set_dust(clean)
    gs.job["paste_grade"] = "PERFECT"
    gs.job["paste_done"] = true
    gs.job["pc_powered"] = true   # the final check boots it
    var result: Dictionary = gs.run_final_check()
    check(bool(gs.job["cleaned"]) and bool(result["boots"]) and bool(result["passed"]), "cleaned and repasted, her laptop passes the final check")
    check(float(result["temp"]) < float(dirty["temp"]) - 40.0, "cleaning takes more than 40 C off a dusty laptop")
    gs.tickets_taken = 0   # finishing her ticket rotated the next customer to Relu (D104); she comes back first

    # ---- the repair bench and the hardware bench ----
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    await process_frame
    await process_frame
    check(bench.zones.size() == 6 and bench.access.movable == [Ids.COOLER] and bench.cooler_zone == 1, "on the repair bench only the heatsink lifts out")
    bench.queue_free()
    await process_frame
    night.ensure(gs)
    var hardware: Node = load("res://scenes/night_hardware.tscn").instantiate()
    root.add_child(hardware)
    await process_frame
    var pieces: Array = []
    for item: Dictionary in hardware.inventory.items:
        if CustomerPC.is_customer(str(item["part"]["id"])): pieces.append(CustomerPC.part_of(str(item["part"]["id"])) + "@" + str(item["location"]))
    pieces.sort()
    check(pieces == ["ram@ram_1", "storage@m2_1"], "the hardware bench shows her memory and drive in the laptop's slots")
    check(hardware.board_button.disabled and hardware.board_button.text.contains("built in"), "the motherboard button says it is built in")
    hardware.queue_free()
    await process_frame

    # ---- generated customers bring laptops too ----
    var made: int = 0
    var safe: bool = true
    check(not PcBuild.is_laptop(gs.make_ticket_job("")), "a generated customer's blank ticket starts as a desktop, not Mara's laptop")
    for slot in range(60):
        var r: RandomNumberGenerator = Generator.rng_for(1234, 3, slot)
        var person: Dictionary = Generator.new_person(r, "g_test_%d" % slot)
        var caps: Dictionary = gs.diagnosis_capabilities()
        caps["money"] = 500
        var drawn: Dictionary = Generator.draw_case(gs.make_ticket_job(""), person, {}, caps, 3, r)
        if PcBuild.is_laptop(drawn["job"]):
            made += 1
            if not (drawn["events"] as Array).all(func(e: Variant) -> bool: return str(e) in Generator.LAPTOP_EVENTS): safe = false
            if (PcBuild.sanitize(drawn["job"]["parts"])["storage"] as Array).size() > 1: safe = false
    check(made > 0 and made < 60 and safe, "some generated customers bring laptops, only with problems a laptop can have (%d of 60)" % made)

    # ---- storage: smaller, and laptops pile up to three high ----
    var m := Model.new()
    m.setup({"tower": sample("tower", Vector2i(8, 6), false), "a": sample("a", Laptop.SIZE, true), "b": sample("b", Laptop.SIZE, true),
        "c": sample("c", Laptop.SIZE, true), "box": sample("box", Vector2i(7, 5), false)})
    var rack: String = m.units[0]["id"]
    m.placements.clear()
    check(m.place("tower", rack, 0, Vector2i.ZERO, 0), "a tower on the shelf")
    check(not m.can_place("box", rack, 0, Vector2i(1, 1), 0), "a desktop never goes on a desktop")
    check(not m.can_place("a", rack, 0, Vector2i(4, 0), 0), "a laptop hanging off the tower's edge is refused")
    check(m.place("a", rack, 0, Vector2i(1, 1), 0) and m.level("a") == 1 and m.placements["a"].get("on", "") == "tower", "a laptop lies on the tower")
    check(m.place("b", rack, 0, Vector2i(1, 1), 0) and m.level("b") == 2, "a laptop lies on that laptop")
    check(not m.can_place("c", rack, 0, Vector2i(1, 1), 0) and not m.can_place("c", rack, 0, Vector2i(2, 2), 0), "three high is the most")
    check(m.blocked("tower") != "" and not m.begin("tower") and not m.begin("a") and m.begin("b"), "the top laptop comes off first")
    m.cancel()
    check(m.place("c", rack, 1, Vector2i.ZERO, 0) and m.level("c") == 0, "on free shelf space a laptop lies flat")
    var saved: Dictionary = m.snapshot()
    var again := Model.new()
    again.setup({"tower": sample("tower", Vector2i(8, 6), false), "a": sample("a", Laptop.SIZE, true), "b": sample("b", Laptop.SIZE, true),
        "c": sample("c", Laptop.SIZE, true), "box": sample("box", Vector2i(7, 5), false)}, saved)
    check(again.level("b") == 2 and again.level("a") == 1 and again.placements["b"].get("on", "") == "a", "piles survive saving and loading")
    var fresh := Model.new()
    fresh.setup({"tower": sample("tower", Vector2i(8, 6), false), "a": sample("a", Laptop.SIZE, true)})
    check(fresh.level("a") == 0 and fresh.overflow().is_empty(), "with free space a laptop is stored flat, not piled")
    gs.new_game(false)
    gs.save_game()
    gs.job["laptop_finish"] = "graphite"
    check(gs.load_game() and Laptop.finish_of(gs.job) == "silver" and PcBuild.is_laptop(gs.job), "her laptop and its colour survive saving and loading")
    night.ensure(gs)
    var shelved: Dictionary = Sources.collect(gs).values().filter(func(i: Dictionary) -> bool: return str(i["category"]) == "pc" and str(i["source_uid"]) == str(gs.job["id"]))[0]
    check(shelved["size"] == Laptop.SIZE and bool(shelved["stackable"]) and shelved["finish"] == "silver" and str(shelved["model"]).begins_with("Laptop"), "Mara's laptop is a small, stackable storage item")

    # ---- at the counter ----
    gs.new_game(false)
    check(night.start(gs, true), "the first-day intake starts")
    change_scene_to_file("res://scenes/rooms/counter.tscn")
    for f in range(3): await process_frame
    var counter: Node = current_scene
    counter.dialogue.skip_all()
    await process_frame
    check(counter.next_button.text.contains("Accept laptop"), "her slip says Accept laptop")
    check(not counter.customer_pc.visible or counter.customer_pc.texture != load("res://art/props/pc_tower_closed.png"), "no tower appears on the counter for a laptop customer")

    change_scene_to_file("res://scenes/start.tscn")
    for f in range(2): await process_frame
    for path: String in [gs.save_path + ".night.json", gs.save_path + ".navigation.json", gs.save_path + ".cables.json", gs.save_path + ".storage.json"]: _remove_save_files(path)
    restore_save(gs)
    finish("Laptops")
