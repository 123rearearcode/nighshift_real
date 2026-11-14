# Prototype tuning, not a release catalogue. No state or input.
extends RefCounted
const NIGHT_MINUTES: float = 180.0
const CARGO_ORIGIN := Vector2(890,214)
const CELL: int = 32
const CARS: Dictionary = {
    "hatch":{"name":"Hatchback","speed":1.4,"grid":Vector2i(8,5)},
    "van":{"name":"Cargo van","speed":0.85,"grid":Vector2i(10,7)}
}
const SITES: Dictionary = {
    "mixed":{"name":"Mixed waste","hint":"Mostly household rubbish. Older parts sometimes surface.","travel":8.0,"refresh":3,"hardware_chance":0.24},
    "office":{"name":"Office disposal","hint":"More office hardware, often incomplete. Further from the shop.","travel":14.0,"refresh":4,"hardware_chance":0.58}
}
const SHAPES: Dictionary = {"gpu":Vector2i(3,1),"ram":Vector2i(2,1),"psu":Vector2i(2,2),"drive":Vector2i(2,1),"pc":Vector2i(4,4)}
const POWER: Dictionary = {"gpu":65,"ram":0,"psu":0,"drive":0,"pc":65}
const COLOURS: Dictionary = {"gpu":Color("b184d6"),"ram":Color("77c69a"),"psu":Color("e8b76c"),"drive":Color("6cb8cf"),"pc":Color("6f92a3"),"bag":Color("586572"),"box":Color("aa8056"),"junk":Color("7e8988")}

static func footprint(kind: String, rotation: int) -> Vector2i:
    var size: Vector2i = SHAPES.get(kind,Vector2i.ONE)
    return Vector2i(size.y,size.x) if posmod(rotation,2) == 1 else size
