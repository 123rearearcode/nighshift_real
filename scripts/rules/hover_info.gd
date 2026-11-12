# TEXT CONTENT for hover cards, built from data. No drawing here.
# Each function returns {"title": String, "lines": Array of String}.
extends RefCounted

const PlacementRules = preload("res://scripts/rules/placement_rules.gd")


static func for_component(component: Dictionary, rot: int) -> Dictionary:
    var fp: Vector2i = PlacementRules.rotated_footprint(component["footprint"], rot)
    var lines: Array = []
    var details: Array = component["details"]
    for pair: Array in details:
        lines.append("%s: %s" % [pair[0], pair[1]])
    lines.append("Connector: %s" % component["connector_type"])
    lines.append("Size: %d x %d cells" % [fp.x, fp.y])
    lines.append("Facing: %s" % PlacementRules.direction_name(rot))
    return {"title": "%s - %s" % [component["category"], component["display_name"]], "lines": lines}


static func for_connector(connector: Dictionary, occupant_name: String) -> Dictionary:
    var fp: Vector2i = connector["footprint"]
    var status: String = "Free" if occupant_name == "" else "Occupied by " + occupant_name
    return {
        "title": str(connector["label"]),
        "lines": [
            "Accepts: %s" % connector["type"],
            "Part must be: %d x %d cells" % [fp.x, fp.y],
            "Part must face: %s" % PlacementRules.facing_text(connector),
            "Status: " + status,
        ],
    }


static func for_board(board: Dictionary) -> Dictionary:
    var size: Vector2i = board["size"]
    var usable: int = 0
    var rows: Array = board["rows"]
    for row: String in rows:
        usable += row.count("#")
    var connectors: Array = board["connectors"]
    return {
        "title": "Motherboard - %s" % board["display_name"],
        "lines": [
            "Grid: %d x %d cells" % [size.x, size.y],
            "Usable cells: %d" % usable,
            "Connectors: %d" % connectors.size(),
        ],
    }


static func for_cutout() -> Dictionary:
    return {"title": "Board cutout", "lines": ["No board here.", "Nothing can be mounted."]}
