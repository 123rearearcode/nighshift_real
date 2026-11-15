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
    test_varied_generation()
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
    check(not s.pile.objects.has("test-gpu") and s.visit_counts["mixed"] == 2,"every arrival gets a fresh pile rather than retaining left-behind finds")
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
    check(s.cargo["van"].has("pc-child") and not s.pile.objects.has("pc-child"),"fresh arrival across nights preserves packed child without returning it to the pile")
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
    a.generate("mixed",0,12345)
    b.generate("mixed",0,12345)
    check(a.objects == b.objects,"explicit seed can reproduce a visit for debugging")
    b.generate("mixed",1,98765)
    check(a.objects != b.objects,"different visit/seed changes identities and contents")


func test_varied_generation() -> void:
    var kinds: Dictionary = {}
    var sizes: Dictionary = {}
    var counts: Dictionary = {}
    var valid: bool = true
    var overlaps: bool = false
    var heavy_seen: bool = false
    var totals := {"mixed":0,"office":0}
    for site: String in Data.SITES:
        for seed_value in range(64):
            var pile := Pile.new()
            pile.generate(site,1,seed_value)
            valid = valid and pile.objects.size()<=Data.MAX_OBJECTS
            counts[pile.objects.size()] = true
            var roots: Array[Rect2] = []
            for item: Dictionary in pile.objects.values():
                kinds[item["kind"]] = true
                if Data.SHAPES.has(item["kind"]): totals[site] += 1
                valid = valid and item["known_condition"] == "untested" and item["owner"] == "unclaimed"
                if item["zone"] == "hidden":
                    valid = valid and pile.objects.has(item["parent"]) and item["uid"] in pile.objects[item["parent"]]["children"]
                    continue
                if item["kind"] in ["box","bag"]: sizes[str(item["size"])] = true
                heavy_seen = heavy_seen or Data.is_heavy(item["kind"])
                var size: Vector2 = item["size"]
                var angle: float = item["angle"]
                var bounds := Vector2(absf(cos(angle))*size.x+absf(sin(angle))*size.y,absf(sin(angle))*size.x+absf(cos(angle))*size.y)
                var rect := Rect2(Vector2(item["center"])-bounds*0.5,bounds)
                valid = valid and Rect2(52,173.99,560,438.02).encloses(rect)
                for other: Rect2 in roots: overlaps = overlaps or rect.intersects(other)
                roots.append(rect)
    check(valid,"128 seeded piles stay bounded, capped, unclaimed/untested with valid hidden identities")
    check(not overlaps,"random rotated spawn hulls never initially overlap")
    check(kinds.size() >= Data.SHAPES.size()+4 and kinds.has("concrete") and kinds.has("appliance"),"generation reaches every collectible plus both heavy obstacle kinds")
    check(sizes.size()>20 and counts.size()>4,"container dimensions and pile counts vary across visits")
    check(heavy_seen and totals.office>totals.mixed,"heavy obstacles exist and office waste still yields more hardware")
    var packable: bool = true
    for kind: String in Data.SHAPES:
        var grid := Grid.new()
        packable = packable and grid.place(kind,kind,Vector2i.ZERO,0) and grid.place(kind,kind,Vector2i.ZERO,1)
    check(packable,"all fourteen component/PC types support trunk packing and rotation")
    var s := Session.new()
    s.depart("mixed")
    var first_ids: Array = s.pile.objects.keys()
    var first: RefCounted = s.pile
    s.return_home()
    s.depart("mixed")
    var disjoint: bool = true
    for id: String in first_ids: disjoint = disjoint and not s.pile.objects.has(id)
    check(disjoint and s.pile != first and s.visit_sequence == 2,"same-night revisit has fresh visit-scoped identities")
    var same_visit: RefCounted = s.pile
    check(not s.depart("mixed") and s.pile == same_visit,"attempting to depart twice cannot reroll the active visit")
    var child_counts: int = 0
    for item: Dictionary in s.pile.objects.values():
        if not item["children"].is_empty():
            var old: Array = item["children"].duplicate()
            var count: int = s.pile.objects.size()
            s.pile.open(item["uid"])
            child_counts += old.size()
            valid = valid and s.pile.objects.size() == count
            for id: String in old: valid = valid and s.pile.objects[id]["parent"] == "" and s.pile.objects[id]["zone"] != "hidden"
    check(valid and child_counts>0,"opening varied containers reveals pre-generated items without reroll or extra records")
