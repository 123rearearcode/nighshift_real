# Dust regions derived from the SAME cell geometry used by the hardware bench.
extends RefCounted
const Ids = preload("res://scripts/data/ids.gd")
const Layout = preload("res://scripts/data/layout.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const AREA_SIZE: Vector2 = Layout.BENCH_PC_SIZE
const CLEAN_AT: float = 0.95

static func zones(profile_id: String = "tower") -> Array:
    var pc: Dictionary = PCLayout.profile(profile_id)
    var fit: Dictionary = PCLayout.display(pc, Rect2(Vector2.ZERO, AREA_SIZE))
    if profile_id == "laptop": return _laptop(pc, fit)
    return [
        {"id": "case_fan", "label": "Case fan", "rect": PCLayout.cell_rect(pc["fan"], fit), "bundles": 6, "specks": 4, "temp_penalty": 8.0},
        {"id": Ids.COOLER, "label": "CPU cooler", "rect": PCLayout.connector_rect(pc, fit, "cpu"), "bundles": 9, "specks": 6, "temp_penalty": 20.0},
        {"id": "motherboard", "label": "RAM", "rect": PCLayout.connector_rect(pc, fit, "ram_2").merge(PCLayout.connector_rect(pc, fit, "ram_1")), "bundles": 6, "specks": 4, "temp_penalty": 6.0},
        {"id": Ids.GPU, "label": "Graphics card", "rect": PCLayout.connector_rect(pc, fit, "pcie"), "bundles": 8, "specks": 5, "temp_penalty": 12.0},
        {"id": "psu", "label": "Power supply", "rect": PCLayout.cell_rect(pc["psu"], fit), "bundles": 6, "specks": 4, "temp_penalty": 6.0},
        {"id": "front_filter", "label": "Filter", "rect": PCLayout.cell_rect(pc["filter"], fit), "bundles": 8, "specks": 5, "temp_penalty": 8.0, "grip_scale": 1.5},
        {"id": "under_cooler", "label": "Under cooler", "rect": PCLayout.connector_rect(pc, fit, "cpu").grow(-8), "bundles": 4, "specks": 3, "covered_by": "cooler", "temp_penalty": 0.0},
        {"id": "under_gpu", "label": "Under GPU", "rect": PCLayout.connector_rect(pc, fit, "pcie").grow(-4), "bundles": 4, "specks": 3, "covered_by": "gpu", "temp_penalty": 0.0},
        {"id": "case_interior", "label": "Case interior", "rect": fit["case_rect"], "bundles": 0, "specks": 0, "temp_penalty": 0.0}]

# 0.59.1 (D185): a laptop is quicker to clean and its cooling is tighter. Four dusty spots instead of six
# (one blower fan, the heatsink, its exhaust fins, the RAM) with fewer clumps each, and nothing to take out but
# the heatsink. Each spot costs more heat when left dirty, because a thin laptop has no spare airflow: the
# heatsink 26 C (a tower's cooler 20), the fins 16 (a tower's filter 8), the fan 12 (8). The same zone ids
# as the desktops, so dust saves, the dust physics and the reports work unchanged. Trial numbers.
static func _laptop(pc: Dictionary, fit: Dictionary) -> Array:
    return [
        {"id": "case_fan", "label": "Blower fan", "rect": PCLayout.cell_rect(pc["fan"], fit), "bundles": 4, "specks": 3, "temp_penalty": 12.0},
        {"id": Ids.COOLER, "label": "Heatsink", "rect": PCLayout.connector_rect(pc, fit, "cpu"), "bundles": 6, "specks": 4, "temp_penalty": 26.0},
        {"id": "motherboard", "label": "RAM", "rect": PCLayout.connector_rect(pc, fit, "ram_1").merge(PCLayout.connector_rect(pc, fit, "ram_2")), "bundles": 2, "specks": 2, "temp_penalty": 3.0},
        {"id": "front_filter", "label": "Exhaust fins", "rect": PCLayout.cell_rect(pc["filter"], fit), "bundles": 5, "specks": 3, "temp_penalty": 16.0, "grip_scale": 1.5},
        {"id": "under_cooler", "label": "Under heatsink", "rect": PCLayout.connector_rect(pc, fit, "cpu").grow(-8), "bundles": 3, "specks": 2, "covered_by": "cooler", "temp_penalty": 0.0},
        {"id": "case_interior", "label": "Inside the laptop", "rect": fit["case_rect"], "bundles": 0, "specks": 0, "temp_penalty": 0.0}]

static func index_of(zone_id: String, profile_id: String = "tower") -> int:
    var list: Array = zones(profile_id)
    for i in range(list.size()):
        if list[i]["id"] == zone_id:
            return i
    return -1

static func total_penalty(profile_id: String = "tower") -> float:
    var total: float = 0.0
    for z: Dictionary in zones(profile_id):
        total += float(z["temp_penalty"])
    return total
