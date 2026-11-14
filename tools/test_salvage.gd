# Pure salvage time/grid/custody rules. Native movement/input tests live in test_salvage_physics.gd.
extends "res://tools/test_support.gd"
const Session = preload("res://scripts/salvage/salvage_session.gd")
const Data = preload("res://scripts/salvage/salvage_data.gd")
const Pile = preload("res://scripts/salvage/salvage_pile.gd")
const Grid = preload("res://scripts/salvage/cargo_grid.gd")

func _initialize() -> void: call_deferred("run")

func finish_effort(s: RefCounted, at: Vector2) -> void:
    for frame in range(90):
        s.step(1.0/60.0,at)
        if s.effort.is_empty(): break

func fixture(s: RefCounted, kind: String, uid: String, point: Vector2 = Vector2(120,250)) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = 90
    s.pile.add(kind,point,Vector2(Data.SHAPES.get(kind,Vector2i(3,3)))*26,uid,rng)
    return s.pile.objects[uid]

func run() -> void:
    test_grid()
    var s := Session.new()
    check(s.depart("mixed"),"round trip starts when affordable")
    var outbound: float = s.travel("mixed")
    check(is_equal_approx(s.remaining,Data.NIGHT_MINUTES-outbound) and s.reserve == outbound,"outbound charged once and return reserved")
    check(not s.depart("office"),"cannot double-depart or charge travel twice")
    var initial: float = s.remaining
    for frame in range(60): s.step(1.0/60.0,Vector2.ZERO)
    check(s.remaining == initial,"ordinary elapsed time does not double-charge the outing")
    var item: Dictionary = fixture(s,"gpu","test-gpu")
    check(s.start_effort("test-gpu","grab"),"start lifting visible hardware")
    s.step(0.1,item["center"])
    check(s.remaining < initial and s.held == "","partial effort costs time before completion")
    var after_partial: float = s.remaining
    s.paused = true
    s.step(0.1,item["center"])
    check(s.remaining == after_partial,"pause freezes effort and charges")
    s.paused = false
    s.cancel_effort()
    check(s.remaining == after_partial,"cancelling does not refund spent effort")
    check(s.start_effort("test-gpu","grab"),"cancelled item can be retried")
    finish_effort(s,item["center"])
    check(s.held == "test-gpu","lift finishes into hand")
    s.turn(1)
    check(s.drop_cargo(Vector2i(1,1)),"hardware packs into rotated trunk grid")
    check(not s.pile.objects.has("test-gpu") and s.cargo[s.car].has("test-gpu"),"packed item has one custody, removed from pile")
    check(s.cargo[s.car]["test-gpu"]["known_condition"] == "untested","packing never diagnoses a component for free")
    check(s.grids[s.car].placements["test-gpu"]["rotation"] == 1,"packing retains chosen rotation")
    var start_placement: Dictionary = s.grids[s.car].placements["test-gpu"].duplicate()
    s.start_effort("test-gpu","grab")
    finish_effort(s,item["center"])
    s.turn(1)
    check(not s.drop_cargo(Vector2i(8,7)),"invalid trunk drop is rejected")
    check(s.held == "" and s.grids[s.car].placements["test-gpu"] == start_placement and item["rotation"] == 1,"invalid drop restores committed cargo orientation and footprint")
    s.start_effort("test-gpu","grab")
    finish_effort(s,item["center"])
    check(s.drop_world(Vector2(710,300)) and not s.cargo[s.car].has("test-gpu"),"unpacking transfers the same UID to sorting area")
    check(Pile.SORT.encloses(Rect2(Vector2(item["center"])-s.pile.extent(item),s.pile.extent(item)*2)),"whole object fits sorting-area boundary")
    var box: Dictionary = fixture(s,"box","sealed-box",Vector2(220,280))
    fixture(s,"ram","box-ram")
    s.pile.objects["box-ram"]["zone"] = "hidden"
    box["children"] = ["box-ram"]
    check(not s.start_effort("box-ram","grab"),"covered container contents cannot be grabbed")
    s.start_effort("sealed-box","open")
    finish_effort(s,box["center"])
    check(box["opened"] and s.pile.objects["box-ram"]["zone"] == "pile","opening reveals pre-existing child")
    check(not s.start_effort("sealed-box","open"),"opening again cannot reroll or duplicate contents")
    s.remaining = s.reserve+0.1
    check(not s.start_effort("test-gpu","grab"),"search cannot consume return allowance")
    var before_return: float = s.remaining
    check(s.return_home() and is_equal_approx(s.remaining,before_return-outbound),"return drive charged exactly once")
    var returned: float = s.remaining
    check(not s.return_home() and s.remaining == returned,"return replay cannot re-charge")
    s.next_night()
    s.depart("mixed")
    check(s.pile.objects.has("test-gpu") and box["opened"],"same-cycle revisit retains cleared/revealed state")
    s.return_home()
    test_refresh_and_identity()
    Session.demo = null
    finish("Salvage")

func test_grid() -> void:
    var grid := Grid.new()
    grid.size = Vector2i(4,3)
    check(grid.place("a","gpu",Vector2i.ZERO,0),"grid stores real item footprint")
    check(not grid.place("b","ram",Vector2i(2,0),0),"grid rejects overlap")
    check(not grid.place("b","gpu",Vector2i(3,0),0),"grid rejects out-of-bounds shape")
    check(grid.place("a","gpu",Vector2i(3,0),1),"grid rotates same identity and excludes its committed footprint")
    check(grid.placements.size() == 1 and grid.at(Vector2i(3,2)) == "a","rotation does not duplicate IDs")

func test_refresh_and_identity() -> void:
    var s := Session.new()
    s.car = "van"
    s.depart("mixed")
    var pc: Dictionary = fixture(s,"pc","claimed-pc")
    var rng := RandomNumberGenerator.new()
    s.pile.add("gpu",Vector2(100,250),Vector2(78,26),"pc-child",rng,"claimed-pc")
    s.start_effort("claimed-pc","grab")
    finish_effort(s,pc["center"])
    check(s.drop_cargo(Vector2i.ZERO),"whole PC fits roomy car")
    var old_pile: RefCounted = s.pile
    check(not old_pile.objects.has("pc-child") and pc["packed_children"].has("pc-child"),"whole PC carries actual nested components out of site")
    s.return_home()
    s.depart("office")
    s.start_effort("claimed-pc","grab")
    finish_effort(s,pc["center"])
    s.drop_world(Vector2(710,300))
    check(not old_pile.objects.has("claimed-pc") and s.pile.objects.has("pc-child"),"cross-site unpacking cannot resurrect a second PC at the old site")
    s.start_effort("claimed-pc","open")
    finish_effort(s,pc["center"])
    check(pc["children"].is_empty() and pc["condition"] == "incomplete" and pc["power"] == 0 and s.pile.objects["pc-child"]["zone"] == "sort","stripping removes real child from whole PC")
    s.start_effort("pc-child","grab")
    finish_effort(s,s.pile.objects["pc-child"]["center"])
    s.drop_cargo(Vector2i.ZERO)
    s.return_home()
    for day in range(4): s.next_night()
    s.depart("office")
    check(s.cycles["office"] == 1 and s.cargo["van"].has("pc-child"),"new dump cycle refreshes site and preserves car cargo")
    s.return_home()
    s.car = "hatch"
    s.depart("office")
    check(not s.start_effort("pc-child","grab"),"another car cannot access this car's cargo by guessing its UID")
    s.return_home()
    s.car = "van"
    check(s.unload() == 1 and s.unload() == 0 and s.shelf.has("pc-child"),"unloading to demo shelf is idempotent")
    s.car = "hatch"
    var fast: float = s.travel("office")
    s.car = "van"
    check(fast < s.travel("office") and s.grids["hatch"].size.x < s.grids["van"].size.x,"fast/small versus slow/roomy vehicle trade-off")
    var a := Pile.new()
    var b := Pile.new()
    a.generate("mixed",0)
    b.generate("mixed",0)
    check(a.objects == b.objects,"site cycle generation is deterministic")
    b.generate("mixed",1)
    check(a.objects != b.objects,"refresh cycle changes object identities and contents")
