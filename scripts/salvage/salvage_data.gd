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
const SHAPES: Dictionary = {"gpu":Vector2i(3,1),"ram":Vector2i(2,1),"psu":Vector2i(2,2),"drive":Vector2i(2,1),"pc":Vector2i(4,4),
    "cpu":Vector2i(1,1),"motherboard":Vector2i(3,3),"cooler":Vector2i(2,2),"fan":Vector2i(2,2),"ssd":Vector2i(2,1),
    "hdd":Vector2i(2,1),"wifi":Vector2i(2,1),"soundcard":Vector2i(2,1),"networkcard":Vector2i(2,1)}
const POWER: Dictionary = {"gpu":65,"ram":0,"psu":0,"drive":0,"pc":65,"cpu":65}
const COLOURS: Dictionary = {"gpu":Color("b184d6"),"ram":Color("77c69a"),"psu":Color("e8b76c"),"drive":Color("6cb8cf"),"pc":Color("6f92a3"),
    "cpu":Color("c7b497"),"motherboard":Color("49977b"),"cooler":Color("9eacbb"),"fan":Color("71a3b0"),"ssd":Color("83b6cf"),
    "hdd":Color("a7b3bd"),"wifi":Color("b19bda"),"soundcard":Color("c28eae"),"networkcard":Color("91b884"),
    "bag":Color("586572"),"box":Color("aa8056"),"junk":Color("7e8988"),"concrete":Color("8e8a7c"),"appliance":Color("b5b9ae")}
const LABELS: Dictionary = {"cpu":"CPU","gpu":"GPU","ram":"RAM","psu":"PSU","ssd":"SSD","hdd":"HDD","pc":"PC",
    "wifi":"Wi-Fi adapter","soundcard":"Sound card","networkcard":"Network card","concrete":"Concrete block","appliance":"Heavy appliance"}
const WEIGHTS: Dictionary = {
    "mixed":{"gpu":2,"ram":8,"psu":5,"drive":7,"pc":2,"cpu":3,"motherboard":3,"cooler":6,"fan":9,"ssd":3,"hdd":8,"wifi":5,"soundcard":4,"networkcard":5},
    "office":{"gpu":3,"ram":12,"psu":7,"drive":6,"pc":6,"cpu":6,"motherboard":7,"cooler":5,"fan":6,"ssd":10,"hdd":10,"wifi":5,"soundcard":2,"networkcard":10}}
const MASSES: Dictionary = {"cpu":0.3,"motherboard":0.9,"psu":2.2,"hdd":1.1,"cooler":1.3,"concrete":12.0,"appliance":10.0}
const MAX_OBJECTS: int = 64

static func label(kind: String) -> String:
    return str(LABELS.get(kind,kind.capitalize()))
static func short_label(kind: String) -> String:
    return str({"motherboard":"BOARD","soundcard":"SOUND","networkcard":"NIC","wifi":"WI-FI"}.get(kind,label(kind).to_upper()))
static func is_heavy(kind: String) -> bool:
    return kind in ["concrete","appliance"]
static func loot(rng: RandomNumberGenerator,site: String) -> String:
    var table: Dictionary = WEIGHTS[site]
    var total: int = 0
    for weight: int in table.values(): total += weight
    var roll: int = rng.randi_range(1,total)
    for kind: String in table:
        roll -= int(table[kind])
        if roll<=0: return kind
    return "ram"

static func footprint(kind: String, rotation: int) -> Vector2i:
    var size: Vector2i = SHAPES.get(kind,Vector2i.ONE)
    return Vector2i(size.y,size.x) if posmod(rotation,2) == 1 else size
