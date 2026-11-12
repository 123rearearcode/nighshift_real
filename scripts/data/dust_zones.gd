# Dust regions derived from the SAME cell geometry used by the hardware bench.
extends RefCounted
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const AREA_SIZE := Vector2(620, 400)
const CLEAN_AT: float = 0.95

static func zones(profile_id: String = "tower") -> Array:
    var pc: Dictionary = PCLayout.profile(profile_id)
    var fit: Dictionary = PCLayout.display(pc, Rect2(Vector2.ZERO, AREA_SIZE))
    return [
        {"id": "case_fan", "label": "Case fan", "rect": PCLayout.cell_rect(pc["fan"], fit), "bundles": 6, "specks": 4, "temp_penalty": 8.0},
        {"id": "cooler", "label": "CPU cooler", "rect": PCLayout.connector_rect(pc, fit, "cpu"), "bundles": 9, "specks": 6, "temp_penalty": 20.0},
        {"id": "motherboard", "label": "RAM", "rect": PCLayout.connector_rect(pc, fit, "ram_2").merge(PCLayout.connector_rect(pc, fit, "ram_1")), "bundles": 6, "specks": 4, "temp_penalty": 6.0},
        {"id": "gpu", "label": "Graphics card", "rect": PCLayout.connector_rect(pc, fit, "pcie"), "bundles": 8, "specks": 5, "temp_penalty": 12.0},
        {"id": "psu", "label": "Power supply", "rect": PCLayout.cell_rect(pc["psu"], fit), "bundles": 6, "specks": 4, "temp_penalty": 6.0},
        {"id": "front_filter", "label": "Filter", "rect": PCLayout.cell_rect(pc["filter"], fit), "bundles": 8, "specks": 5, "temp_penalty": 8.0},
        {"id": "under_cooler", "label": "Under cooler", "rect": PCLayout.connector_rect(pc, fit, "cpu").grow(-8), "bundles": 4, "specks": 3, "covered_by": "cooler", "temp_penalty": 0.0},
        {"id": "under_gpu", "label": "Under GPU", "rect": PCLayout.connector_rect(pc, fit, "pcie").grow(-4), "bundles": 4, "specks": 3, "covered_by": "gpu", "temp_penalty": 0.0}]

static func index_of(zone_id: String) -> int:
    var list: Array = zones()
    for i in range(list.size()):
        if list[i]["id"] == zone_id:
            return i
    return -1

static func total_penalty() -> float:
    var total: float = 0.0
    for z: Dictionary in zones():
        total += float(z["temp_penalty"])
    return total
