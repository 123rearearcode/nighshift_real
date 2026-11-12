# Run: godot --headless --path . --script res://tools/test_data_schemas.gd
# Checks that every data dictionary has exactly the expected keys with the expected types,
# and that the data agrees with itself (connectors on board cells, parts inside the case,
# unique ids). Catches typos such as "comp_id" instead of "id" before they become silent bugs.
# When you add a new kind of data or a new key, add it to the schema tables below.
extends SceneTree
const ComponentData = preload("res://scripts/data/component_data.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")

# key -> Variant.Type. REQUIRED keys must exist; OPTIONAL keys may exist; any other key is a problem.
const COMPONENT_REQUIRED: Dictionary = {"id": TYPE_STRING, "category": TYPE_STRING, "display_name": TYPE_STRING,
    "short_label": TYPE_STRING, "connector_type": TYPE_STRING, "footprint": TYPE_VECTOR2I, "height": TYPE_INT, "details": TYPE_ARRAY}
const BOARD_REQUIRED: Dictionary = {"id": TYPE_STRING, "display_name": TYPE_STRING, "size": TYPE_VECTOR2I,
    "rows": TYPE_ARRAY, "connectors": TYPE_ARRAY}
const CONNECTOR_REQUIRED: Dictionary = {"id": TYPE_STRING, "label": TYPE_STRING, "short_label": TYPE_STRING,
    "type": TYPE_STRING, "origin": TYPE_VECTOR2I, "footprint": TYPE_VECTOR2I}
const CONNECTOR_OPTIONAL: Dictionary = {"allowed_rotations": TYPE_ARRAY}
const PROFILE_REQUIRED: Dictionary = {"id": TYPE_STRING, "name": TYPE_STRING, "size": TYPE_VECTOR2I, "depth": TYPE_INT,
    "board_origin": TYPE_VECTOR2I, "board": TYPE_DICTIONARY, "fan": TYPE_RECT2, "psu": TYPE_RECT2, "filter": TYPE_RECT2}
const ZONE_REQUIRED: Dictionary = {"id": TYPE_STRING, "label": TYPE_STRING, "rect": TYPE_RECT2,
    "bundles": TYPE_INT, "specks": TYPE_INT, "temp_penalty": TYPE_FLOAT}
const ZONE_OPTIONAL: Dictionary = {"covered_by": TYPE_STRING, "grip_scale": TYPE_FLOAT}
const OPTION_REQUIRED: Dictionary = {"label": TYPE_STRING, "cost": TYPE_INT, "performance": TYPE_INT, "heat_penalty": TYPE_FLOAT}

var failed: int = 0
var checks: int = 0


func _initialize() -> void:
    call_deferred("run_checks")


func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: " + label)


# Returns a list of human-readable problems; an empty list means the dictionary matches the schema.
static func validate(data: Dictionary, required: Dictionary, optional: Dictionary, label: String) -> Array:
    var problems: Array = []
    for key: String in required:
        if not data.has(key):
            problems.append("%s: missing key '%s'" % [label, key])
        elif typeof(data[key]) != int(required[key]):
            problems.append("%s: key '%s' has the wrong type (%s)" % [label, key, type_string(typeof(data[key]))])
    for key: Variant in data:
        if not required.has(key) and not optional.has(key):
            problems.append("%s: unexpected key '%s' (typo?)" % [label, str(key)])
        elif optional.has(key) and typeof(data[key]) != int(optional[key]):
            problems.append("%s: key '%s' has the wrong type (%s)" % [label, str(key), type_string(typeof(data[key]))])
    return problems


func check_schema(data: Dictionary, required: Dictionary, optional: Dictionary, label: String) -> void:
    var problems: Array = validate(data, required, optional, label)
    for problem: String in problems:
        check(false, problem)
    check(problems.is_empty(), label + " matches its schema")


func run_checks() -> void:
    # The validator itself must be able to fail, or the checks below mean nothing.
    var typo: Dictionary = ComponentData.ram_stick()
    typo["comp_id"] = typo["id"]
    typo.erase("id")
    check(validate(typo, COMPONENT_REQUIRED, {}, "typo case").size() == 2, "validator reports a missing key and an unexpected key")
    var wrong_type: Dictionary = ComponentData.ram_stick()
    wrong_type["height"] = "1"
    check(validate(wrong_type, COMPONENT_REQUIRED, {}, "type case").size() == 1, "validator reports a wrong value type")

    test_components()
    test_boards_and_cases()
    test_zones()
    print("Data schema checks: %d, failures: %d" % [checks, failed])
    quit(1 if failed else 0)


func test_components() -> void:
    var seen: Dictionary = {}
    var parts: Array = [ComponentData.ram_stick()]
    parts.append_array(ComponentData.drawer_stock())
    for id: String in ServiceParts.IDS:
        for tier: String in ["similar", "budget"]:
            var option: Dictionary = ServiceParts.option(id, tier)
            check_schema(option, OPTION_REQUIRED, {}, "service option %s/%s" % [id, tier])
            parts.append(ServiceParts.component("uid_%s_%s" % [id, tier], id, tier))
    check(ServiceParts.option("nonsense", "similar").is_empty(), "unknown service part gives an empty option")
    for part: Dictionary in parts:
        var label: String = "component " + str(part.get("id", "?"))
        check_schema(part, COMPONENT_REQUIRED, {}, label)
        var footprint: Vector2i = part["footprint"]
        check(footprint.x > 0 and footprint.y > 0, label + " has a positive footprint")
        check(int(part["height"]) > 0, label + " has a positive height")
        for row: Variant in part["details"]:
            check(row is Array and row.size() == 2 and row[0] is String and row[1] is String, label + " details are [name, value] text pairs")
        check(not seen.has(part["id"]), label + " id is unique")
        seen[part["id"]] = true


func test_boards_and_cases() -> void:
    var profile_ids: Array = ["tower", "compact"]
    for profile_id: String in profile_ids:
        var pc: Dictionary = PCLayout.profile(profile_id)
        var label: String = "case profile " + profile_id
        check_schema(pc, PROFILE_REQUIRED, {}, label)
        var board: Dictionary = pc["board"]
        check_schema(board, BOARD_REQUIRED, {}, label + " board")
        var case_size: Vector2i = pc["size"]
        var board_size: Vector2i = board["size"]
        var board_origin: Vector2i = pc["board_origin"]
        check(board_origin.x >= 0 and board_origin.y >= 0 and board_origin.x + board_size.x <= case_size.x and board_origin.y + board_size.y <= case_size.y,
            label + ": the board fits inside the case")
        for key: String in ["fan", "psu", "filter"]:
            var rect: Rect2 = pc[key]
            check(rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= case_size.x and rect.end.y <= case_size.y,
                label + ": " + key + " is inside the case")
        var rows: Array = board["rows"]
        check(rows.size() == board_size.y, label + ": board has one row per cell of height")
        for row: Variant in rows:
            check(row is String and (row as String).length() == board_size.x, label + ": every board row is as wide as the board")
        var connector_ids: Dictionary = {}
        for connector: Dictionary in board["connectors"]:
            var clabel: String = "%s connector %s" % [label, str(connector.get("id", "?"))]
            check_schema(connector, CONNECTOR_REQUIRED, CONNECTOR_OPTIONAL, clabel)
            check(not connector_ids.has(connector["id"]), clabel + " id is unique")
            connector_ids[connector["id"]] = true
            var origin: Vector2i = connector["origin"]
            var size: Vector2i = connector["footprint"]
            check(size.x > 0 and size.y > 0, clabel + " has a positive footprint")
            var all_on_board: bool = true
            for y in range(origin.y, origin.y + size.y):
                for x in range(origin.x, origin.x + size.x):
                    if x < 0 or y < 0 or x >= board_size.x or y >= board_size.y:
                        all_on_board = false
                    elif (rows[y] as String)[x] != "#":
                        all_on_board = false
            check(all_on_board, clabel + " sits entirely on usable board cells")
            if connector.has("allowed_rotations"):
                for turn: Variant in connector["allowed_rotations"]:
                    check(turn is int and int(turn) >= 0 and int(turn) <= 3, clabel + " rotations are 0 to 3")


func test_zones() -> void:
    var zones: Array = DustZones.zones()
    var ids: Dictionary = {}
    for zone: Dictionary in zones:
        ids[zone["id"]] = true
    check(ids.size() == zones.size(), "dust zone ids are unique")
    for zone: Dictionary in zones:
        var label: String = "dust zone " + str(zone.get("id", "?"))
        check_schema(zone, ZONE_REQUIRED, ZONE_OPTIONAL, label)
        check(int(zone["bundles"]) >= 0 and int(zone["specks"]) >= 0, label + " has non-negative dust counts")
        var rect: Rect2 = zone["rect"]
        check(rect.size.x > 0.0 and rect.size.y > 0.0, label + " has a visible area")
        if zone.has("covered_by"):
            check(ids.has(zone["covered_by"]), label + " is covered by a zone that exists")
    check(DustZones.index_of("cooler") >= 0 and DustZones.index_of("nonsense") == -1, "index_of finds zones by id")
