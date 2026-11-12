# DATA ONLY: what things are. No drawing, no input, no rules in this file.
# Sizes are in grid cells. Prototype values, not approved production data.
extends RefCounted


static func ram_stick() -> Dictionary:
    return {
        "id": "ram_demo_8gb",
        "category": "RAM",
        "display_name": "Demo RAM 8GB",
        "short_label": "RAM",
        "connector_type": "DDR4_DIMM",
        "footprint": Vector2i(1, 4),
        "height": 1,
        # Shown on the hover card. Placeholder values, not real products.
        "details": [
            ["Capacity", "8 GB"],
            ["Standard", "DDR4"],
            ["Speed", "2400 MT/s"],
        ],
    }


# '#' = usable board cell, '.' = cutout (no board there).
# Connectors are rectangles of cells; "type" decides what can plug in.
# "allowed_rotations" (optional) lists the facings a part may have there:
# 0 = Up, 1 = Right, 2 = Down, 3 = Left. Leave it out to accept any facing.
static func demo_board() -> Dictionary:
    return {
        "id": "board_demo_l",
        "display_name": "Demo L-shaped board",
        "size": Vector2i(10, 10),
        "rows": [
            "######....",
            "######....",
            "######....",
            "######....",
            "##########",
            "##########",
            "##########",
            "##########",
            "##########",
            "##########",
        ],
        "connectors": [
            {"id": "ram_1", "label": "RAM slot 1", "short_label": "R1", "type": "DDR4_DIMM",
                "origin": Vector2i(5, 0), "footprint": Vector2i(1, 4), "allowed_rotations": [0]},
            {"id": "ram_2", "label": "RAM slot 2", "short_label": "R2", "type": "DDR4_DIMM",
                "origin": Vector2i(4, 0), "footprint": Vector2i(1, 4), "allowed_rotations": [0, 2]},
            {"id": "ram_3", "label": "RAM slot 3", "short_label": "R3", "type": "DDR4_DIMM",
                "origin": Vector2i(0, 8), "footprint": Vector2i(4, 1), "allowed_rotations": [1]},
            {"id": "cpu", "label": "CPU socket", "short_label": "CPU", "type": "CPU_SOCKET",
                "origin": Vector2i(0, 1), "footprint": Vector2i(3, 3)},
            {"id": "pcie", "label": "PCIe x16 slot", "short_label": "PCIe x16", "type": "PCIE_X16",
                "origin": Vector2i(0, 6), "footprint": Vector2i(8, 1)},
        ],
    }


# Three sandbox pieces, not new catalogue models. Two instances of the existing RAM.
static func drawer_stock() -> Array:
    var first: Dictionary = ram_stick()
    first["id"] = "trial_ram_a"
    var second: Dictionary = ram_stick()
    second["id"] = "trial_ram_b"
    return [first, second, {"id":"trial_gpu", "category":"GPU", "display_name":"Demo GPU", "short_label":"GPU",
        "connector_type":"PCIE_X16", "footprint":Vector2i(8,1), "height":2,
        "details":[["Model","Generic trial piece"],["Connector","PCIe x16"],["Size","8 x 1 cells"]]}]
