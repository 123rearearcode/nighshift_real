# DATA ONLY: the hardware catalogue (Wave 3 session 3.3, D148). Every part is a close parody of real
# hardware (user: "close parodies"). Six stats in all: processing (CPU), graphics (GPU), RAM (GB),
# storage (GB), PSU (watts it can deliver) and cooler (watts of heat it can remove).
# Scale (user, 17 November 2026): 100 is a mid-to-late-game soft ceiling that takes a long time to pass;
# the best single GPU (a 5090 parody) is 98. Several GPUs in one PC add up (pc_build.gd).
# The two demo customers' parts are calibrated so their PCs perform exactly as before 0.45.0.
# Prices are used-market shop prices. All numbers are trial proposals.
extends RefCounted

const CPU := "cpu"
const GPU := "gpu"
const RAM := "ram"
const STORAGE := "storage"
const PSU := "psu"
const COOLER := "cooler"
const TYPES: Array = [CPU, GPU, RAM, STORAGE, PSU, COOLER]
const TYPE_LABELS: Dictionary = {CPU: "Processor", GPU: "Graphics card", RAM: "Memory", STORAGE: "Storage", PSU: "Power supply", COOLER: "CPU cooler"}

# id: {type, brand, model, price, and the stats of its type}
#   cpu: processing, watts (power drawn = heat made)   gpu: graphics, watts
#   ram: gb                                            storage: gb, kind
#   psu: watts (deliverable)                           cooler: capacity (watts of heat removed)
const PARTS: Dictionary = {
    # Processors
    "cpu_pentium_g4650": {"type": CPU, "brand": "Intol", "model": "Pentium G4650", "price": 20, "processing": 12, "watts": 54},
    "cpu_i5_6060": {"type": CPU, "brand": "Intol", "model": "Core i5-6060", "price": 45, "processing": 25, "watts": 65},
    "cpu_rysen5_3060": {"type": CPU, "brand": "AMB", "model": "Rysen 5 3060", "price": 85, "processing": 40, "watts": 88},
    "cpu_i7_12070": {"type": CPU, "brand": "Intol", "model": "Core i7-12070", "price": 220, "processing": 62, "watts": 180},
    "cpu_rysen9_9590x": {"type": CPU, "brand": "AMB", "model": "Rysen 9 9590X", "price": 560, "processing": 98, "watts": 230},
    # Graphics cards
    "gpu_gtx1550ti": {"type": GPU, "brand": "Nvidya", "model": "GeForks GTX 1550 Ti", "price": 18, "graphics": 13, "watts": 75},
    "gpu_gtx1660": {"type": GPU, "brand": "Nvidya", "model": "GeForks GTX 1660", "price": 40, "graphics": 20, "watts": 120},
    "gpu_rx6060": {"type": GPU, "brand": "AMB", "model": "Radion RX 6060", "price": 130, "graphics": 32, "watts": 132},
    "gpu_rtx3800": {"type": GPU, "brand": "Nvidya", "model": "GeForks RTX 3800", "price": 320, "graphics": 50, "watts": 320},
    "gpu_rtx5900": {"type": GPU, "brand": "Nvidya", "model": "GeForks RTX 5900", "price": 1600, "graphics": 98, "watts": 575},
    # Memory sticks
    "ram_4gb": {"type": RAM, "brand": "Kingstone", "model": "ValueRAM 4 GB DDR4", "price": 6, "gb": 4},
    "ram_8gb": {"type": RAM, "brand": "Corsare", "model": "Vengance LPX 8 GB DDR4", "price": 14, "gb": 8},
    "ram_16gb": {"type": RAM, "brand": "G.Skil", "model": "Ripjaws V 16 GB DDR4", "price": 26, "gb": 16},
    "ram_32gb": {"type": RAM, "brand": "Corsare", "model": "Dominator 32 GB DDR5", "price": 70, "gb": 32},
    # Storage
    "sto_hdd_500": {"type": STORAGE, "brand": "Seagait", "model": "Barracooda 500 GB HDD", "price": 12, "gb": 500, "kind": "HDD"},
    "sto_ssd_500": {"type": STORAGE, "brand": "Samsong", "model": "870 EVA 500 GB SSD", "price": 35, "gb": 500, "kind": "SSD"},
    "sto_nvme_1tb": {"type": STORAGE, "brand": "Samsong", "model": "990 PRA 1 TB NVMe", "price": 75, "gb": 1000, "kind": "NVMe"},
    "sto_nvme_2tb": {"type": STORAGE, "brand": "WD", "model": "Bleck SN850 2 TB NVMe", "price": 140, "gb": 2000, "kind": "NVMe"},
    # Power supplies
    "psu_cv450": {"type": PSU, "brand": "Corsare", "model": "CV450", "price": 25, "watts": 450},
    "psu_600w": {"type": PSU, "brand": "EVGB", "model": "600 W1", "price": 40, "watts": 600},
    "psu_focus750": {"type": PSU, "brand": "Seasonick", "model": "Focus GX-750", "price": 85, "watts": 750},
    "psu_rm1000y": {"type": PSU, "brand": "Corsare", "model": "RM1000y", "price": 150, "watts": 1000},
    "psu_prime1600": {"type": PSU, "brand": "Seasonick", "model": "Prime TX-1600", "price": 360, "watts": 1600},
    # CPU coolers
    "cool_wraith_stelth": {"type": COOLER, "brand": "AMB", "model": "Wraith Stelth", "price": 7, "capacity": 49},
    "cool_stock_box": {"type": COOLER, "brand": "Intol", "model": "boxed stock cooler", "price": 16, "capacity": 65},
    "cool_hyper212": {"type": COOLER, "brand": "Cooler Mastr", "model": "Hyper 221", "price": 30, "capacity": 150},
    "cool_dark_rock4": {"type": COOLER, "brand": "be quiat!", "model": "Dark Rokk 4", "price": 65, "capacity": 200},
    "cool_nh_d15": {"type": COOLER, "brand": "Noctoa", "model": "NH-D51", "price": 95, "capacity": 250},
}


# 0.48.1 (user, 18 November 2026): the motherboard is one of the PC's parts. Kept apart from PARTS on
# purpose: boards are not drag-and-drop bench pieces or order-panel stock yet (no board faults or
# replacement boards are designed). "form" says which case it fits: tower (ATX) or compact (mATX);
# every board of a form has the same slots (pc_layout.gd). Parody names, trial prices.
const BOARD := "board"
const BOARDS: Dictionary = {
    "board_atx_b350": {"brand": "AzRock", "model": "B350 Steel Legend", "form": "tower", "price": 45},
    "board_atx_z390": {"brand": "MSY", "model": "Z390 Torpedo Pro", "form": "tower", "price": 120},
    "board_matx_h310": {"brand": "Gigabait", "model": "H310M Snug", "form": "compact", "price": 35},
    "board_matx_b450": {"brand": "Asos", "model": "Prime B450M-Q", "form": "compact", "price": 60},
}
const DEFAULT_BOARD: Dictionary = {"tower": "board_atx_b350", "compact": "board_matx_h310"}


static func board(id: String) -> Dictionary:
    var b: Variant = BOARDS.get(id, null)
    if not b is Dictionary: return {}
    var out: Dictionary = (b as Dictionary).duplicate()
    out["id"] = id
    out["type"] = BOARD
    out["name"] = "%s %s" % [out["brand"], out["model"]]
    return out


static func is_board(id: String) -> bool:
    return BOARDS.has(id)


static func boards_for(form: String) -> Array:
    var out: Array = []
    for id: String in BOARDS:
        if BOARDS[id]["form"] == form: out.append(id)
    return out


static func part(id: String) -> Dictionary:
    var p: Variant = PARTS.get(id, null)
    if not p is Dictionary: return {}
    var out: Dictionary = (p as Dictionary).duplicate()
    out["id"] = id
    out["name"] = "%s %s" % [out["brand"], out["model"]]
    return out


static func of_type(type: String) -> Array:
    var out: Array = []
    for id: String in PARTS:
        if PARTS[id]["type"] == type: out.append(id)
    return out


static func is_type(id: String, type: String) -> bool:
    return PARTS.has(id) and PARTS[id]["type"] == type


# One line of the part's own stat, for tickets and the hardware bench.
static func stat_text(id: String) -> String:
    var p: Dictionary = part(id)
    match str(p.get("type", "")):
        CPU: return "processing %d · %d W" % [int(p["processing"]), int(p["watts"])]
        GPU: return "graphics %d · %d W" % [int(p["graphics"]), int(p["watts"])]
        RAM: return "%d GB" % int(p["gb"])
        STORAGE: return "%d GB %s" % [int(p["gb"]), str(p["kind"])]
        PSU: return "%d W" % int(p["watts"])
        COOLER: return "removes %d W of heat" % int(p["capacity"])
    return ""


# 0.46.0 (D149): how each type sits on the board (connector type, footprint in cells, height).
const BENCH: Dictionary = {
    CPU: {"connector": "CPU_SOCKET", "footprint": Vector2i(3, 3), "height": 1, "short": "CPU", "category": "CPU"},
    GPU: {"connector": "PCIE_X16", "footprint": Vector2i(8, 1), "height": 2, "short": "GPU", "category": "GPU"},
    RAM: {"connector": "DDR4_DIMM", "footprint": Vector2i(1, 4), "height": 1, "short": "RAM", "category": "RAM"},
    STORAGE: {"connector": "STORAGE_SLOT", "footprint": Vector2i(2, 1), "height": 1, "short": "SSD", "category": "STORAGE"},
    PSU: {"connector": "PSU_BAY", "footprint": Vector2i(3, 2), "height": 2, "short": "PSU", "category": "PSU"},
    COOLER: {"connector": "COOLER_MOUNT", "footprint": Vector2i(2, 2), "height": 2, "short": "COOL", "category": "COOLER"},
}


# A hardware-bench component for one catalogue part (the bench's drag-and-drop shape).
static func component(uid: String, id: String) -> Dictionary:
    var p: Dictionary = part(id)
    if p.is_empty(): return {}
    var shape: Dictionary = BENCH[str(p["type"])]
    return {"id": uid, "category": shape["category"], "display_name": str(p["name"]), "short_label": shape["short"],
        "connector_type": shape["connector"], "footprint": shape["footprint"], "height": int(shape["height"]),
        "details": [["Model", str(p["name"])], ["Spec", stat_text(id)], ["Price", "$%d" % int(p["price"])]]}

