# VIEW + INPUT: free storage arrangement and deliberate motherboard installation.
extends Node2D
const TableBody = preload("res://scripts/bench/table_body.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const PlacementRules = preload("res://scripts/rules/placement_rules.gd")
const Inventory = preload("res://scripts/bench/grid_inventory.gd")
const PartMotion = preload("res://scripts/view/part_motion.gd")
const HoverInfo = preload("res://scripts/rules/hover_info.gd")
const HoverCard = preload("res://scripts/view/hover_card.gd")
const DRAWER_CELL: float = 30.0
const DRAWER_GRID_ORIGIN := Vector2(826, 148)
const DRAWER_GRID_SIZE := Vector2i(12,8)
const DRAWER_RECT := Rect2(800,100,440,330)
const STATUS_RECT := Rect2(800,450,440,110)
const COLOR_BG := Color("1c1f26")
const COLOR_CASE := Color("383d4a")
const COLOR_BOARD := Color("195c38")
const COLOR_CUTOUT := Color("14171c")
const COLOR_GRID := Color(0,0,0,0.3)
const COLOR_TEXT := Color("f2f2f2")
const COLOR_OK := Color("72d9ad")
const COLOR_BAD := Color("e8bd79") # gentle amber, no red error for experimenting
const FACING_VECTORS := [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
var CELL: float = 30.0
var BOARD_ORIGIN := Vector2.ZERO
var profile_id: String = "tower"
var pc: Dictionary = {}
var geometry: Dictionary = {}
var board: Dictionary = {}
var font: Font
var inventory := Inventory.new()
var motions: Array = []
var thrown: Dictionary = {}
var throw_rotations: Dictionary = {}
var throw_velocity := Vector2.ZERO
var previous_pointer := Vector2.ZERO
var last_pointer_tick: int = 0
var pointer := Vector2.ZERO
var grab_fraction := Vector2(0.5,0.5)
var status_label: Label
var hover_card: HoverCard
var preview: Dictionary = {}
var feedback: Rect2 = Rect2()
var feedback_life: float = 0.0
var hover_index: int = -1

func _ready() -> void:
    font = ThemeDB.fallback_font
    profile_id = str(GameState.job.get("layout", "tower"))
    _build_ui()
    _configure_layout()

func _exit_tree() -> void:
    _settle_all_throws()
    if not inventory.items.is_empty(): _save_inventory()

func _build_ui() -> void:
    var title := Label.new()
    title.position = Vector2(40,16)
    title.size = Vector2(1200,70)
    title.add_theme_font_size_override("font_size",20)
    title.text = "NIGHTSHIFT / hardware sandbox\nDrag to arrange. Flick-release to throw; Shift-drop places precisely. R / right-click turns. Esc puts back."
    add_child(title)
    status_label = Label.new()
    status_label.position = STATUS_RECT.position + Vector2(12,12)
    status_label.size = STATUS_RECT.size - Vector2(24,24)
    status_label.add_theme_font_size_override("font_size",17)
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(status_label)
    _button("Reset sandbox", Vector2(800,580), Vector2(200,44), _reset_state)
    _button("Back to shop", Vector2(1020,580), Vector2(220,44), func() -> void: get_tree().change_scene_to_file("res://scenes/shop.tscn"))
    _button("Tower + L board", Vector2(60,110), Vector2(240,36), _change_profile.bind("tower"))
    _button("Compact + stepped board", Vector2(310,110), Vector2(300,36), _change_profile.bind("compact"))
    hover_card = HoverCard.new()
    add_child(hover_card)

func _button(text: String, pos: Vector2, size: Vector2, callback: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.position = pos
    button.size = size
    button.focus_mode = Control.FOCUS_NONE
    button.pressed.connect(callback)
    add_child(button)

func _configure_layout() -> void:
    pc = PCLayout.profile(profile_id)
    board = pc["board"]
    geometry = PCLayout.display(pc, Rect2(60,165,640,420))
    CELL = geometry["cell"]
    BOARD_ORIGIN = PCLayout.board_rect(pc,geometry).position
    inventory.setup(board, int(pc["depth"]), GameState.inventory_layout, GameState.inventory_components())
    _reset_motion()
    _set_status("Arrange parts anywhere that fits in the drawer. Slots matter only when installing.")

func _change_profile(id: String) -> void:
    _settle_all_throws()
    inventory.cancel()
    _save_inventory()
    profile_id = id
    _configure_layout()

func _reset_state() -> void:
    inventory.setup(board, int(pc["depth"]), {}, GameState.inventory_components())
    _reset_motion()
    _save_inventory()
    _set_status("Stock rearranged. Owned parts only; consumed parts stay consumed.")

func _reset_motion() -> void:
    thrown.clear()
    throw_rotations.clear()
    motions.clear()
    preview = {}
    feedback_life = 0.0
    hover_card.hide_card()
    for i in range(inventory.items.size()):
        var motion := PartMotion.new()
        motion.snap(_item_rect(i).get_center(), inventory.items[i]["rotation"])
        motions.append(motion)
    queue_redraw()

func _save_inventory() -> void:
    GameState.set_inventory_layout(inventory.snapshot())

func _set_status(text: String, hint: bool = false) -> void:
    status_label.text = text
    status_label.add_theme_color_override("font_color", COLOR_BAD if hint else COLOR_TEXT)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var now: int = Time.get_ticks_msec()
        if last_pointer_tick > 0:
            var elapsed: float = maxf(0.008,float(now-last_pointer_tick)/1000.0)
            throw_velocity = throw_velocity.lerp(((event.position-pointer)/elapsed).limit_length(2000),0.6)
        last_pointer_tick = now
        pointer = event.position
        if inventory.held < 0: _update_hover()
    elif event is InputEventMouseButton:
        pointer = event.position
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed: _try_pick_up(pointer)
            elif inventory.held >= 0: _drop(pointer, not event.shift_pressed)
        elif event.pressed and inventory.held >= 0:
            if event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN]: _rotate_part(1)
            elif event.button_index == MOUSE_BUTTON_WHEEL_UP: _rotate_part(-1)
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_R: _rotate_part(-1 if event.shift_pressed else 1)
        elif event.keycode == KEY_ESCAPE:
            inventory.cancel()
            _set_status("Put back. Nothing changed.")
    if inventory.held >= 0: preview = _candidate(pointer)

func _try_pick_up(mouse: Vector2) -> void:
    if inventory.held >= 0: return
    for i in range(inventory.items.size()-1,-1,-1):
        var rect: Rect2 = Rect2(thrown[i].center-thrown[i].extent(),thrown[i].extent()*2) if thrown.has(i) else _item_rect(i)
        if not rect.has_point(mouse): continue
        var airborne_rotation: int = throw_rotations.get(i,inventory.items[i]["rotation"])
        thrown.erase(i)
        throw_rotations.erase(i)
        grab_fraction = (mouse - rect.position) / rect.size
        inventory.begin(i)
        inventory.items[i]["rotation"] = airborne_rotation
        pointer = mouse
        throw_velocity = Vector2.ZERO
        last_pointer_tick = Time.get_ticks_msec()
        hover_card.hide_card()
        _set_status("Move freely. R / right-click rotates; Esc puts it back.")
        return

func _rotate_part(step: int) -> void:
    var idle: bool = inventory.held < 0
    var rotation_center := Vector2.ZERO
    if idle:
        var found: int = -1
        for i in range(inventory.items.size()):
            if _item_rect(i).has_point(pointer) and inventory.items[i]["location"] == "drawer": found = i
        if found < 0: return
        rotation_center = _item_rect(found).get_center()
        inventory.begin(found)
        grab_fraction = Vector2(0.5,0.5)
    inventory.rotate(step)
    grab_fraction = Vector2(0.5,0.5)
    if idle:
        var i: int = inventory.held
        var center: Vector2 = rotation_center
        var size: Vector2i = inventory.footprint(i)
        var cell: Vector2i = _drawer_cell(center - Vector2(size) * DRAWER_CELL * 0.5)
        cell = cell.clamp(Vector2i.ZERO, Vector2i(maxi(0,DRAWER_GRID_SIZE.x-size.x),maxi(0,DRAWER_GRID_SIZE.y-size.y)))
        if inventory.store(cell):
            _save_inventory()
            _set_status("Rotated in the drawer.")
        else:
            inventory.cancel()
            _set_status("A little more room is needed to turn here. Pick it up and try another space.", true)
    preview = _candidate(pointer) if inventory.held >= 0 else {}

func _drop(mouse: Vector2, allow_throw: bool = false) -> void:
    var candidate: Dictionary = _candidate(mouse)
    var speed: Vector2 = throw_velocity if Time.get_ticks_msec()-last_pointer_tick < 120 else Vector2.ZERO
    if allow_throw and speed.length() > 450 and candidate.get("kind", "") != "board":
        var i: int = inventory.held
        var body := TableBody.new()
        body.launch(motions[i].center,speed*0.8,Vector2(inventory.footprint(i))*DRAWER_CELL*0.5,0)
        throw_rotations[i] = inventory.items[i]["rotation"]
        # Physical angle starts at zero because half_size already uses the rotated footprint.
        inventory.cancel()
        thrown[i] = body
        _set_status("Thrown! It bounces off drawer edges, then finds a free grid space. Shift-drop places precisely.")
        preview = {}
        return
    if candidate.get("kind", "") == "drawer" and candidate["ok"]:
        inventory.store(candidate["cell"])
        _set_status("Stored. Pick it up or rotate it whenever you like.")
    elif candidate.get("kind", "") == "board" and candidate["ok"]:
        var result: Dictionary = inventory.install(candidate["cell"])
        _set_status("Clicked into %s. Pick it up again to rearrange." % result["label"])
    else:
        inventory.cancel()
        _set_status(str(candidate.get("message", "Set parts down in the drawer or on a matching slot.")) + " Put back safely.", true)
    feedback = candidate.get("rect", Rect2()) if candidate.get("ok", false) else Rect2()
    feedback_life = 0.35
    preview = {}
    _save_inventory()

func _drawer_cell(top_left: Vector2) -> Vector2i:
    var relative: Vector2 = (top_left - DRAWER_GRID_ORIGIN) / DRAWER_CELL
    return Vector2i(roundi(relative.x),roundi(relative.y))

func _candidate(mouse: Vector2) -> Dictionary:
    if inventory.held < 0: return {}
    var i: int = inventory.held
    var fp: Vector2i = inventory.footprint(i)
    var grid_rect := Rect2(DRAWER_GRID_ORIGIN, Vector2(DRAWER_GRID_SIZE) * DRAWER_CELL)
    if grid_rect.grow(12).has_point(mouse):
        var cell: Vector2i = _drawer_cell(mouse - grab_fraction * Vector2(fp) * DRAWER_CELL)
        cell = cell.clamp(Vector2i.ZERO, Vector2i(maxi(0,DRAWER_GRID_SIZE.x-fp.x),maxi(0,DRAWER_GRID_SIZE.y-fp.y)))
        var ok: bool = inventory.can_store(i,cell)
        return {"kind":"drawer", "cell":cell, "ok":ok, "rect":Rect2(DRAWER_GRID_ORIGIN + Vector2(cell)*DRAWER_CELL, Vector2(fp)*DRAWER_CELL), "message":"Leave enough empty cells for this part."}
    var cell: Vector2i = _pos_to_cell(mouse)
    if PlacementRules.in_grid_bounds(board,cell):
        var result: Dictionary = PlacementRules.check_placement(board,inventory.items[i]["part"],inventory.items[i]["rotation"],cell,inventory.occupied(),int(pc["depth"]))
        var connector: Dictionary = PlacementRules.connector_at(board,cell)
        var rect: Rect2 = _connector_rect(connector) if not connector.is_empty() else Rect2(_cell_to_pos(cell),Vector2(fp)*CELL)
        return {"kind":"board", "cell":cell, "ok":result["ok"], "rect":rect, "message":result["message"]}
    return {"ok":false, "message":"Try an empty drawer space or a matching socket."}

func _process(delta: float) -> void:
    feedback_life = maxf(0.0,feedback_life-delta)
    if inventory.held >= 0: preview = _candidate(pointer)
    for i in thrown.keys():
        var body: RefCounted = thrown[i]
        body.step(delta,Rect2(DRAWER_GRID_ORIGIN,Vector2(DRAWER_GRID_SIZE)*DRAWER_CELL))
        motions[i].center = body.center-Vector2(0,body.height)
        motions[i].angle = float(throw_rotations[i])*PI/2.0+body.angle
        motions[i].lift = body.height/60.0
        if not body.active: _settle_throw(i)
    for i in range(motions.size()):
        if thrown.has(i): continue
        var rect: Rect2 = _item_rect(i)
        motions[i].step(delta,rect.get_center(),inventory.items[i]["rotation"],inventory.held == i)
    queue_redraw()

func _update_hover() -> void:
    hover_index = -1
    for i in range(inventory.items.size()):
        if _item_rect(i).has_point(pointer):
            hover_index = i
            var info: Dictionary = HoverInfo.for_component(inventory.items[i]["part"],inventory.items[i]["rotation"])
            hover_card.show_card(info["title"],info["lines"],pointer)
            return
    var cell: Vector2i = _pos_to_cell(pointer)
    if PlacementRules.is_cell_on_board(board,cell):
        var connector: Dictionary = PlacementRules.connector_at(board,cell)
        var info: Dictionary = HoverInfo.for_board(board) if connector.is_empty() else HoverInfo.for_connector(connector,"Occupied" if inventory.occupied().has(connector["id"]) else "")
        hover_card.show_card(info["title"],info["lines"],pointer)
    else: hover_card.hide_card()

func _item_rect(i: int) -> Rect2:
    var item: Dictionary = inventory.items[i]
    var fp: Vector2i = inventory.footprint(i)
    if i == inventory.held:
        var scale_cell: float = CELL if Rect2(60,165,640,420).has_point(pointer) else DRAWER_CELL
        var size: Vector2 = Vector2(fp)*scale_cell
        return Rect2(pointer-grab_fraction*size,size)
    if item["location"] == "drawer":
        return Rect2(DRAWER_GRID_ORIGIN+Vector2(item["cell"])*DRAWER_CELL,Vector2(fp)*DRAWER_CELL)
    for connector: Dictionary in board["connectors"]:
        if connector["id"] == item["location"]: return _connector_rect(connector)
    return Rect2()

func _cell_to_pos(cell: Vector2i) -> Vector2:
    return BOARD_ORIGIN+Vector2(cell)*CELL
func _pos_to_cell(point: Vector2) -> Vector2i:
    var relative: Vector2 = (point-BOARD_ORIGIN)/CELL
    return Vector2i(floori(relative.x),floori(relative.y))
func _connector_rect(connector: Dictionary) -> Rect2:
    return Rect2(_cell_to_pos(connector["origin"]),Vector2(connector["footprint"])*CELL)
func _type_color(type: String) -> Color:
    match type:
        "DDR4_DIMM": return Color("efbe52")
        "CPU_SOCKET": return Color("e86b70")
        "PCIE_X16": return Color("b99cf0")
        "COOLER_MOUNT": return Color("62b9bd")
    return Color.GRAY
func _text(pos: Vector2, text: String, size: int = 16, color: Color = COLOR_TEXT) -> void:
    draw_string(font,pos,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),COLOR_BG)
    _draw_case()
    _draw_board()
    draw_rect(DRAWER_RECT,Color("41352c"))
    draw_rect(DRAWER_RECT,Color("947451"),false,2)
    _text(Vector2(818,130),"PLAYER INVENTORY / 12 x 8",20)
    for y in range(DRAWER_GRID_SIZE.y):
        for x in range(DRAWER_GRID_SIZE.x):
            draw_rect(Rect2(DRAWER_GRID_ORIGIN+Vector2(x,y)*DRAWER_CELL,Vector2.ONE*DRAWER_CELL),COLOR_GRID,false)
    _text(Vector2(817,413),"Free arrangement / R turns / Esc puts back",14)
    draw_rect(STATUS_RECT,Color("26302f"))
    draw_rect(STATUS_RECT,Color("66857b"),false,1)
    if inventory.held >= 0 and preview.get("rect", Rect2()).has_area():
        var rect: Rect2 = preview["rect"]
        var color: Color = COLOR_OK if preview["ok"] else COLOR_BAD
        draw_rect(rect,Color(color,0.18))
        draw_rect(rect,color,false,2)
    elif feedback_life > 0.0 and feedback.has_area(): draw_rect(feedback,COLOR_OK,false,2)
    # Highlight compatible vacant sockets before the user commits a drop.
    if inventory.held >= 0:
        var item: Dictionary = inventory.items[inventory.held]
        for connector: Dictionary in board["connectors"]:
            if PlacementRules.check_placement(board,item["part"],item["rotation"],connector["origin"],inventory.occupied(),int(pc["depth"]))["ok"]:
                draw_rect(_connector_rect(connector).grow(2),Color(COLOR_OK,0.8),false,2)
    for i in range(inventory.items.size()):
        if i != inventory.held: _draw_part(i)
    if inventory.held >= 0: _draw_part(inventory.held)

func _draw_part(i: int) -> void:
    var item: Dictionary = inventory.items[i]
    var motion: RefCounted = motions[i]
    var size: Vector2 = Vector2(item["part"]["footprint"])*(_item_rect(i).size.x/float(inventory.footprint(i).x))
    var scale: Vector2 = Vector2.ONE*(1.0+motion.lift*0.045)
    var rect := Rect2(-size*0.5,size)
    draw_set_transform(motion.center+Vector2(3,4+motion.lift*7),motion.angle,scale)
    draw_rect(rect,Color(0,0,0,0.30))
    draw_set_transform(motion.center-Vector2(0,motion.lift*3),motion.angle,scale)
    draw_rect(rect,_type_color(item["part"]["connector_type"]))
    draw_rect(rect,Color.WHITE if inventory.held == i else Color("272725"),false,2)
    if item["part"]["category"] == "RAM":
        for j in range(3): draw_rect(Rect2(rect.position+Vector2(5,10+j*28),Vector2(maxf(8,size.x-10),18)),Color("464947"))
        _text(rect.position+Vector2(3,size.y-5),"RAM",10,Color.BLACK)
        draw_line(rect.position+Vector2(2,3),rect.position+Vector2(2,size.y-3),Color("ffe2a0"),2)
    elif item["part"]["category"] == "GPU":
        for j in range(2):
            var center := Vector2(-size.x*0.25 if j == 0 else size.x*0.25,0)
            draw_circle(center,size.y*0.35,Color("383d4a"))
            draw_arc(center,size.y*0.35,0,TAU,20,Color("ddd5ed"),1)
        _text(Vector2(-14,4),"GPU",11,Color.BLACK)
    else:
        var radius: float = minf(size.x,size.y)*0.34
        draw_circle(Vector2.ZERO,radius,Color("294e55"))
        for blade in range(5):
            var direction: Vector2 = Vector2.from_angle(blade*TAU/5.0)
            draw_line(Vector2.ZERO,direction*radius,Color("c2e8e0"),4)
        _text(Vector2(-23,size.y*0.5-4),"Cooler",10,Color.BLACK)
    draw_set_transform(Vector2.ZERO)

func _draw_case() -> void:
    var bounds: Rect2 = geometry["case_rect"]
    draw_rect(bounds, COLOR_CASE)
    draw_rect(bounds, Color(0.6, 0.62, 0.7), false, 3.0)
    var size: Vector2i = pc["size"]
    for y in range(size.y):
        for x in range(size.x):
            draw_rect(PCLayout.cell_rect(Rect2(x, y, 1, 1), geometry), COLOR_GRID, false)
    _text(Vector2(65, 620), "%s / %d x %d cells / depth %d" % [pc["name"], size.x, size.y, pc["depth"]], 16)
    for key: String in ["fan", "psu", "filter"]:
        var r: Rect2 = PCLayout.cell_rect(pc[key], geometry)
        draw_rect(r.grow(-2), Color("706342"))
        _text(r.position + Vector2(2, 14), key.to_upper(), 11)


func _draw_board() -> void:
    var size: Vector2i = board["size"]
    _text(BOARD_ORIGIN + Vector2(0, -12), str(board["display_name"]), 14)
    for y in range(size.y):
        for x in range(size.x):
            var cell := Vector2i(x, y)
            var rect := Rect2(_cell_to_pos(cell), Vector2(CELL, CELL))
            if PlacementRules.is_cell_on_board(board, cell):
                draw_rect(rect, COLOR_BOARD)
            else:
                draw_rect(rect, COLOR_CUTOUT)
    var connectors: Array = board["connectors"]
    for connector: Dictionary in connectors:
        var crect: Rect2 = _connector_rect(connector)
        var col: Color = _type_color(connector["type"])
        draw_rect(crect, Color(col.r, col.g, col.b, 0.35))
    for y in range(size.y):
        for x in range(size.x):
            var cell2 := Vector2i(x, y)
            if PlacementRules.is_cell_on_board(board, cell2):
                draw_rect(Rect2(_cell_to_pos(cell2), Vector2(CELL, CELL)), COLOR_GRID, false, 1.0)
    for connector: Dictionary in connectors:
        var crect2: Rect2 = _connector_rect(connector)
        draw_rect(crect2, _type_color(connector["type"]), false, 2.0)
        _text(crect2.position + Vector2(3, 16), str(connector["short_label"]), 13)
    _text(BOARD_ORIGIN + Vector2(0, size.y * CELL + 22),
        "Board %d x %d cells (dark = cutout)" % [size.x, size.y], 14)




func _settle_throw(i: int) -> void:
    var body: RefCounted = thrown[i]
    inventory.begin(i)
    inventory.items[i]["rotation"] = throw_rotations[i]
    var fp: Vector2i = inventory.footprint(i)
    var desired: Vector2i = _drawer_cell(body.center-Vector2(fp)*DRAWER_CELL*0.5)
    var best := Vector2i(-100,-100)
    var distance: float = INF
    for y in range(DRAWER_GRID_SIZE.y):
        for x in range(DRAWER_GRID_SIZE.x):
            var cell := Vector2i(x,y)
            if inventory.can_store(i,cell) and Vector2(cell-desired).length_squared() < distance:
                best = cell
                distance = Vector2(cell-desired).length_squared()
    if not inventory.store(best): inventory.cancel()
    thrown.erase(i)
    throw_rotations.erase(i)
    _save_inventory()

func _settle_all_throws() -> void:
    for i in thrown.keys(): _settle_throw(i)
