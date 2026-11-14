# Storage footprints are shelf units, separate from motherboard connector geometry. Trial tuning.
extends RefCounted
const CELL: int = 24
const MAX_UNITS: int = 8
const MODELS: Dictionary = {
    "rack":{"name":"Steel rack","size":Vector2i(12,6),"shelves":2,"accepts":["pc","tool","part"],"hint":"Deep shelves for whole PCs, tools and parts."},
    "drawers":{"name":"Parts cabinet","size":Vector2i(12,2),"shelves":3,"accepts":["part"],"hint":"Shallow drawers for loose components."},
    "pegboard":{"name":"Tool board","size":Vector2i(12,6),"shelves":1,"accepts":["tool"],"hint":"Dedicated tool storage frees the main rack."}
}
const TOOL_SIZES: Dictionary = {"vacuum":Vector2i(4,2),"brush":Vector2i(3,1),"pick":Vector2i(2,1),"cloth":Vector2i(2,2),"syringe":Vector2i(1,2)}
const COLOURS: Dictionary = {"pc":Color("82a9bb"),"ram":Color("7cc694"),"gpu":Color("b89ada"),"cooler":Color("80b9ce"),"vacuum":Color("7caee1"),"brush":Color("d7ae66"),"pick":Color("da8b82"),"cloth":Color("a1c4ba"),"syringe":Color("bc9fce")}

static func footprint(item: Dictionary, rotation: int) -> Vector2i:
    var size: Vector2i = item["size"]
    return Vector2i(size.y,size.x) if posmod(rotation,2) else size
