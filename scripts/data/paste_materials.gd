# DATA ONLY: what can go between the CPU and the cooler. Real thermal paste costs a little and
# cools properly. Toothpaste is free, looks the part, spreads thicker and cools badly: using it is a
# scam (the customer pays for a repaste they did not get). Numbers are trial proposals.
extends RefCounted

const IDS: Array = ["thermal", "toothpaste"]

static func material(id: String) -> Dictionary:
    if id == "toothpaste":
        return {"id": "toothpaste", "label": "Toothpaste", "cost": 0, "heat_penalty": 14.0,
            "yield_scale": 1.5, "mobility_scale": 0.75, "scam": true}
    if id == "thermal":
        return {"id": "thermal", "label": "Thermal paste", "cost": 3, "heat_penalty": 0.0,
            "yield_scale": 1.0, "mobility_scale": 1.0, "scam": false}
    return {}
