# Storage contracts: source ownership, packing, safe moves, persistence, scene input.
extends "res://tools/test_support.gd"
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const SafeStore = preload("res://scripts/state/save_store.gd")

func _initialize() -> void:
    call_deferred("run_checks")

func sample(id: String,category: String,size: Vector2i) -> Dictionary:
    return {"id":id,"category":category,"size":size}

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    use_test_save(gs,"storage_game_test.json")
    gs.new_game(false)
    var inventory: Array = gs.player_inventory.duplicate(true)
    var job: Dictionary = gs.job.duplicate(true)
    var cash: int = gs.money
    var sources: Dictionary = Sources.collect(gs)
    check(sources.size() == inventory.size()+6,"starter projects every owned part, five tools and one customer PC")
    check(gs.money == cash and gs.player_inventory == inventory and gs.job == job,"source projection never mutates game state")
    check(Sources.collect(gs) == sources,"source IDs are stable across repeated reads")
    var first_uid: String = inventory[0]["uid"]
    gs.inventory_layout[first_uid] = {"location":"motherboard","cell":[0,0]}
    check(Sources.collect(gs)["part:"+first_uid]["reserved"],"installed shop part keeps marked storage reservation")
    gs.inventory_layout.erase(first_uid)
    gs.player_inventory[0]["condition"] = "broken"
    check(not Sources.collect(gs)["part:"+first_uid]["reserved"],"broken loose stock is not mislabelled as installed")
    gs.player_inventory = inventory.duplicate(true)
    gs.job["state"] = "done"
    check(Sources.collect(gs).size() == sources.size()-1,"collected customer PC no longer occupies storage")
    gs.job = job.duplicate(true)
    gs.player_inventory.remove_at(0)
    check(not Sources.collect(gs).has("part:"+first_uid),"consumed stock does not survive as phantom inventory")
    gs.player_inventory = inventory.duplicate(true)
    var m := Model.new()
    m.setup(sources)
    check(m.units.size() == 1 and m.overflow().is_empty(),"starter rack fits actual current stock and customer PC")
    var before: Dictionary = m.snapshot()
    check(m.begin("part:"+first_uid),"existing part can be picked up")
    m.rotate(1)
    check(m.snapshot() == before,"held/rotated item keeps committed save allocation")
    check(not m.drop("missing",0,Vector2i.ZERO),"invalid drop is rejected without destroying placement")
    m.cancel()
    check(m.snapshot() == before and m.held == "","cancel restores exact last committed layout")
    var fixtures := {"pc":sample("pc","pc",Vector2i(8,6)),"a":sample("a","part",Vector2i(8,1)),"b":sample("b","part",Vector2i(4,2)),"tool":sample("tool","tool",Vector2i(4,2))}
    m.setup(fixtures)
    var rack: String = m.units[0]["id"]
    var cabinet: String = m.add_unit("drawers")
    var board: String = m.add_unit("pegboard")
    m.placements.clear()
    check(m.place("pc",rack,0,Vector2i.ZERO,0),"whole PC occupies an eight-by-six shelf footprint")
    check(not m.place("a",rack,0,Vector2i(2,2),0),"shelf collision checks whole footprint")
    check(m.place("a",rack,1,Vector2i.ZERO,0),"separate shelf permits same coordinates")
    check(not m.can_place("b",rack,1,Vector2i(10,5),0),"out-of-bounds footprint cannot fit")
    check(not m.can_place("a",rack,2,Vector2i.ZERO,0),"nonexistent shelf is rejected")
    check(not m.can_place("pc",cabinet,0,Vector2i.ZERO,0),"parts cabinet rejects whole PCs")
    check(not m.can_place("b",board,0,Vector2i.ZERO,0),"tool board rejects components")
    check(m.place("tool",board,0,Vector2i.ZERO,1),"tool board accepts a rotated tool")
    check(m.place("b",cabinet,0,Vector2i.ZERO,0),"shallow drawer accepts fitting components")
    check(not m.can_place("b",cabinet,1,Vector2i.ZERO,1),"rotation can make a part too deep for a drawer")
    check(not m.remove_unit(rack),"occupied furniture cannot disappear")
    var empty: String = m.add_unit("rack")
    check(m.remove_unit(empty),"empty expansion furniture can be removed")
    before = m.snapshot()
    var recovered := Model.new()
    recovered.setup(fixtures,JSON.parse_string(JSON.stringify(before)))
    check(recovered.snapshot() == before,"JSON roundtrip preserves furniture, shelves, cells and rotation")
    var many: Dictionary = {}
    for i in range(6): many[str(i)] = sample(str(i),"pc",Vector2i(8,6))
    m.setup(many)
    check(m.overflow().size() == 4 and m.items.size() == 6,"overflow keeps all owned items visible without granting capacity")
    m.add_unit("rack")
    m.fill_unplaced()
    check(m.overflow().size() == 2,"added furniture genuinely increases available space")
    m.arrange()
    check(m.items.size() == 6 and m.overflow().size() == 2,"arranging never restocks or destroys items")
    while m.units.size()<8: m.add_unit("rack")
    check(m.add_unit("rack") == "" and m.units.size() == 8,"prototype furniture cap is enforced")
    check(m.add_unit("unknown") == "","unknown furniture is rejected")
    m.setup({})
    check(not m.remove_unit(m.units[0]["id"]),"last furniture unit is retained")
    var damaged: Dictionary = {"units":[{"id":"one","model":"rack"},{"id":"one","model":"rack"},{"id":"x","model":"bogus"}],"placements":{"a":{"unit":"one","shelf":0,"cell":[0.5,0],"rotation":0},"b":{"unit":"one","shelf":0,"cell":[0,0],"rotation":true},"ghost":{"unit":"one","shelf":0,"cell":[0,0],"rotation":0}}}
    m.setup(fixtures,damaged)
    check(m.units.size() == 1 and m.units[0]["id"] == "one","damaged save drops duplicate/unknown furniture")
    check(not m.placements.has("ghost") and m.items.size() == 4,"save cannot manufacture owned items")
    for uid: String in m.placements:
        var p: Dictionary = m.placements[uid]
        check(m.can_place(uid,p.unit,p.shelf,p.cell,p.rotation),"invalid saved moves are safely repacked: "+uid)
    var store := Store.new()
    store.path = "user://storage_layout_test.json"
    _remove_save_files(store.path)
    check(store.write(m),"layout saves through safe writer")
    before = m.snapshot()
    check(store.read() == JSON.parse_string(JSON.stringify(before)),"layout persisted without ownership copies")
    m.add_unit("pegboard")
    check(store.write(m),"second layout write succeeds")
    var file := FileAccess.open(store.path,FileAccess.WRITE)
    file.store_string("damaged")
    file.close()
    check(store.read() == JSON.parse_string(JSON.stringify(before)),"damaged primary recovers previous layout backup")
    _remove_save_files(store.path)
    SafeStore.write(store.path,{"version":999,"sentinel":"keep"})
    store.read()
    check(store.read_only and not store.write(m),"future layout version is protected against overwrite")
    check(SafeStore.read(store.path)["sentinel"] == "keep","future save contents remain untouched")
    _remove_save_files(store.path)
    store.read_only = false
    store.path = "user://does_not_exist/storage.json"
    check(not store.write(m) and store.status.contains("not saved"),"write failure is reported honestly")
    # Real view, disposable layout path, real mouse/key handlers.
    var view: Node = load("res://scripts/storage/storage_view.gd").new()
    view.store.path = "user://storage_view_test.json"
    _remove_save_files(view.store.path)
    root.add_child(view)
    await process_frame
    var uid: String = "part:"+first_uid
    var origin: Rect2 = view.item_rect(uid)
    before = view.model.snapshot()
    click(view,MOUSE_BUTTON_LEFT,true,origin.get_center())
    check(view.model.held == uid,"scene input picks up real owned stock")
    var key := InputEventKey.new()
    key.keycode = KEY_R
    key.pressed = true
    view._input(key)
    click(view,MOUSE_BUTTON_LEFT,false,Vector2(5,5))
    check(view.model.held == "" and view.model.snapshot() == before,"scene invalid release is quiet, safe and cancels rotation")
    click(view,MOUSE_BUTTON_LEFT,true,origin.get_center())
    view._cancel()
    check(view.model.held == "" and view.model.snapshot() == before,"focus-loss cancellation preserves committed placement")
    view._add_unit("rack")
    check(view.model.units.size() == 2,"view expansion adds real furniture")
    click(view,MOUSE_BUTTON_LEFT,true,origin.get_center())
    var destination: Vector2 = view.shelf_rect(1,0).position+origin.size/2
    click(view,MOUSE_BUTTON_LEFT,false,destination)
    check(view.model.placements[uid]["unit"] == view.model.units[1]["id"],"scene drag transfers between furniture units")
    check(view.store.read()["placements"][uid]["unit"] == view.model.units[1]["id"],"successful scene drop autosaves")
    view._add_unit("pegboard")
    view.page = 0
    origin = view.item_rect(uid)
    click(view,MOUSE_BUTTON_LEFT,true,origin.get_center())
    key.keycode = KEY_TAB
    view._input(key)
    check(view.page == 1 and view.model.held == uid,"held item survives furniture page navigation")
    view._cancel()
    check(gs.player_inventory == inventory and gs.job == job and gs.money == cash,"rack interactions never clone, spend or change repair ownership")
    view._refresh()
    check(view.model.items.size() == sources.size(),"refresh reconciles against canonical game records")
    view.waiting_page = 99
    view._sync_ui()
    check(view.waiting_page == 0,"refreshing fewer waiting items keeps the visible overflow page in range")
    _remove_save_files(view.store.path)
    view.queue_free()
    await process_frame
    change_scene_to_file("res://scenes/start.tscn")
    await process_frame
    await process_frame
    current_scene._on_storage()
    await process_frame
    await process_frame
    check(current_scene.scene_file_path == "res://scenes/storage.tscn","start menu opens storage scene")
    restore_save(gs)
    finish("Storage")
