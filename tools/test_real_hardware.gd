# Wave 3 session 3.3 (D148): the hardware catalogue, the six stats, PSU and cooler as support stats,
# several GPUs, named parts everywhere, and the demo PCs performing exactly as before the rescale.
extends "res://tools/test_support.gd"
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const Customers = preload("res://scripts/data/customers.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const Games = preload("res://scripts/data/games.gd")

func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs, "real_hardware_test.json")

    # Catalogue.
    var stat_key: Dictionary = {"cpu": "processing", "gpu": "graphics", "ram": "gb", "storage": "gb", "psu": "watts", "cooler": "capacity"}
    for type: String in Catalog.TYPES:
        var ids: Array = Catalog.of_type(type)
        check(ids.size() >= 4 and ids.size() <= 6, "%s has four to six models (%d)" % [type, ids.size()])
        for id: String in ids:
            var p: Dictionary = Catalog.part(id)
            check(int(p.get("price", 0)) > 0 and int(p.get(stat_key[type], 0)) > 0 and str(p["name"]).length() > 4 and Catalog.stat_text(id) != "", "%s is a complete %s" % [id, type])
            check(not str(p["brand"]) in ["Intel", "AMD", "NVIDIA", "Nvidia", "Corsair", "Samsung", "Seagate", "Seasonic", "Noctua", "Kingston"], "%s uses a parody brand" % id)
    var best: float = 0.0
    for id: String in Catalog.of_type("gpu"): best = maxf(best, float(Catalog.part(id)["graphics"]))
    check(best == 98.0, "the best single GPU scores 98: 100 is a soft ceiling")
    check(Catalog.part("nonsense").is_empty() and not Catalog.is_type("gpu_gtx1660", "cpu"), "unknown ids are refused")

    # Stats and support.
    var demo: Dictionary = PcBuild.stats(Customers.customer("t001_mara")["pc"])
    check(demo["processing"] == 25.0 and demo["graphics"] == 20.0 and demo["ram_gb"] == 8 and demo["storage_gb"] == 500, "the demo PC's performance stats")
    check(demo["draw_w"] == 235 and demo["psu_w"] == 450 and demo["powered"] and demo["excess_heat_w"] == 0, "the demo PC's PSU and cooler cope")
    check(PcBuild.combined_graphics([98, 98]) == 147.0 and PcBuild.combined_graphics([20]) == 20.0 and PcBuild.combined_graphics([20, 50]) == 60.0, "several GPUs add up, each further card half as much: past 100 takes two top cards")
    var dual: Dictionary = PcBuild.stats({"cpu": "cpu_rysen9_9590x", "gpus": ["gpu_rtx5900", "gpu_rtx5900"], "ram": ["ram_32gb", "ram_32gb"], "storage": ["sto_nvme_2tb"], "psu": "psu_prime1600", "cooler": "cool_nh_d15"})
    check(dual["graphics"] > 100.0 and dual["gpu_count"] == 2 and dual["powered"] and dual["ram_gb"] == 64, "a dual top-GPU build passes 100 and needs the biggest PSU")
    var starved: Dictionary = PcBuild.stats({"cpu": "cpu_i5_6060", "gpus": ["gpu_rtx5900"], "ram": ["ram_8gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"})
    check(not starved["powered"] and starved["draw_w"] > starved["psu_w"], "a big GPU on a small PSU draws too much")
    check(PcBuild.sanitize({"cpu": "x", "gpus": ["y"], "psu": 5}) == PcBuild.FALLBACK and PcBuild.sanitize(null) == PcBuild.FALLBACK, "junk parts fall back to the demo PC")

    # Service replacements are catalogue models; costs and the 65% budget share are unchanged.
    check(ServiceParts.option("gpu", "budget")["performance"] == 65 and ServiceParts.option("gpu", "similar")["cost"] == 40 and str(ServiceParts.option("gpu", "budget")["label"]).contains("GeForks"), "stock tiers are named catalogue models with the old prices")

    # The game: demo PCs perform exactly as before (100 fps when cool), PSU and cooler matter.
    gs.new_game(false)
    gs.set_pc_powered(true)
    gs.owned_games = ["counter_stroke_2"]
    check(int(Checks.game_test(gs.job, gs.owned_games, "counter_stroke_2", 42.0)["fps"]) == 100, "the demo PC still makes 100 fps in Counter Stroke 2")
    check(gs.current_gpu_power() == 20 and gs.job["pc_specs"] == {"cpu_power": 25, "ram_gb": 8}, "graphics and specs come from the parts")
    gs.job["service_replacements"] = {"gpu": "budget"}
    check(gs.current_gpu_power() == 13, "a budget replacement GPU is the cheaper model")
    gs.job["service_replacements"] = {}
    gs.job["broken_parts"] = ["gpu"]
    check(gs.current_gpu_power() == 0, "a broken only GPU gives no graphics")
    gs.job["broken_parts"] = []
    gs.job["parts"]["gpus"] = ["gpu_gtx1660", "gpu_rtx3800"]
    check(gs.current_gpu_power() == 60, "a second card adds to the first")
    gs.job["parts"]["gpus"] = ["gpu_rtx5900"]
    var refused: Dictionary = Checks.boot(gs.job)
    check(not refused["ok"] and str(refused["message"]).contains("power supply"), "too small a PSU stops the boot and says why")
    gs.job["parts"]["psu"] = "psu_focus750"
    check(Checks.boot(gs.job)["ok"], "a bigger PSU lets it start")
    gs.job["parts"] = PcBuild.sanitize(Customers.customer("t001_mara")["pc"])
    var cool: float = float(gs.assess()["temp"])
    gs.job["parts"]["cpu"] = "cpu_i7_12070"
    var hot: Dictionary = gs.assess()
    check(float(hot["temp"]) > cool + 50.0 and str(hot["notes"]).contains("cannot remove"), "a hot CPU on a small cooler runs much hotter, and the check says so")
    gs.job["parts"]["cooler"] = "cool_nh_d15"
    check(is_equal_approx(float(gs.assess()["temp"]), cool), "a big enough cooler brings it back")

    # Saves: parts survive; old saves get the customer's PC.
    gs.save_game()
    check(gs.load_game() and gs.job["parts"]["cooler"] == "cool_nh_d15" and gs.job["pc_specs"]["cpu_power"] == 62, "parts and derived specs survive save and load")
    var data: Dictionary = load("res://scripts/state/save_store.gd").read(gs.save_path)
    data["job"].erase("parts")
    load("res://scripts/state/save_store.gd").write(gs.save_path, data)
    check(gs.load_game() and gs.job["parts"] == PcBuild.sanitize(Customers.customer(str(gs.job["customer_id"]))["pc"]), "an old save gets the customer's own PC")

    # Names everywhere.
    var titles: Dictionary = {}
    for id: String in Games.IDS: titles[id] = str(Games.game(id)["title"])
    var ticket: String = Ticket.text(gs.job, Customers.customer(str(gs.job["customer_id"])), titles)
    check(ticket.contains("Nvidya GeForks GTX 1660") and ticket.contains("Specs: Processing 25") and ticket.contains("Corsare CV450"), "the ticket lists every part by name and the six stats")
    check(WorkReport.text(gs.job, {}, 75.0).contains("PC SPECS") and WorkReport.text(gs.job, {}, 75.0).contains("Intol Core i5-6060"), "the Work tab shows the specs")
    var parts: Array = CustomerPC.components(gs.job)
    check(str(parts[0]["details"][0][1]).contains("Core i5-6060") and CustomerPC.ram_sticks(gs.job) == 1, "the hardware bench shows real model names and one stick per RAM part")
    restore_save(gs)
    finish("Real hardware")
