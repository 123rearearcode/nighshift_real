# Storage footprints are shelf units, separate from motherboard connector geometry. Trial tuning.
extends RefCounted
const CELL: int = 18
const ROOM_SIZE := Vector2i(4,2)
const BAY_SIZE := Vector2(280,440)
const BAY_STRIDE := Vector2(300,460)
const MAX_UNITS: int = 8
const MODELS: Dictionary = {
    "rack":{"name":"Steel rack","size":Vector2i(12,6),"shelves":3,"accepts":["pc","tool","part"],"hint":"Deep shelves for whole PCs, tools and parts."},
    "drawers":{"name":"Parts cabinet","size":Vector2i(12,2),"shelves":3,"accepts":["part"],"hint":"Shallow drawers for loose components."},
    "pegboard":{"name":"Tool board","size":Vector2i(12,6),"shelves":1,"accepts":["tool"],"hint":"Dedicated tool storage frees the main rack."}
}
# 0.55.0 (D162; user: "all of these ... create a 10x20 grid for now"): storage under the counter window. A
# fixed unit that is not stock-room furniture: it is never auto-filled, auto-packed, moved or removed, and
# the stock room does not draw it. 20 cells wide and 10 high (wide, under the window). Trial size.
const COUNTER_ID := "counter"
const COUNTER: Dictionary = {"name":"Under-counter storage","size":Vector2i(20,10),"shelves":1,"accepts":["pc","tool","part"],"hint":"Under the counter window: keep anything close at hand."}

# 0.59.2 (D186; user: "PC just disappears into inv. It must be moved", "Under the counter", "there should also
# be a way to carry 1 pc/thing in your arms"). A PC handed over at the counter waits ON the counter top until you
# put it under the counter or pick it up; your arms carry exactly one thing of any size, from room to room. Both
# are fixed units like the under-counter storage: never in the room, never auto-filled by Arrange.
const TOP_ID := "counter_top"
const TOP: Dictionary = {"name":"On the counter","size":Vector2i(20,6),"shelves":1,"accepts":["pc"],"hint":"Handed over at the counter: put it under the counter or pick it up."}
const ARMS_ID := "arms"
const ARMS: Dictionary = {"name":"In your arms","size":Vector2i(8,8),"shelves":1,"accepts":["pc","tool","part"],"max_items":1,"hint":"One thing at a time, any size. It goes with you into every room."}

static func spec(model: String) -> Dictionary:
    if model == TOP_ID: return TOP
    if model == ARMS_ID: return ARMS
    return COUNTER if model == COUNTER_ID else MODELS.get(model,{})

const TOOL_SIZES: Dictionary = {"vacuum":Vector2i(4,2),"brush":Vector2i(3,1),"pick":Vector2i(2,1),"cloth":Vector2i(2,2),"syringe":Vector2i(1,2)}
const COLOURS: Dictionary = {"pc":Color("82a9bb"),"ram":Color("7cc694"),"gpu":Color("b89ada"),"cpu":Color("d9b27c"),"cooler":Color("80b9ce"),"vacuum":Color("7caee1"),"brush":Color("d7ae66"),"pick":Color("da8b82"),"cloth":Color("a1c4ba"),"syringe":Color("bc9fce")}

static func footprint(item: Dictionary, rotation: int) -> Vector2i:
    var size: Vector2i = item["size"]
    return Vector2i(size.y,size.x) if posmod(rotation,2) else size
