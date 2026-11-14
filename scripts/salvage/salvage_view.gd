# Isolated demo presentation/input. No campaign transactions or customer-state access.
extends Node2D
const Data = preload("res://scripts/salvage/salvage_data.gd")
const Session = preload("res://scripts/salvage/salvage_session.gd")
const Pile = preload("res://scripts/salvage/salvage_pile.gd")
const Ui = preload("res://scripts/view/ui_style.gd")
const CARGO_ORIGIN := Data.CARGO_ORIGIN
const CELL: int = Data.CELL
var session: RefCounted
var selected: String = ""
var hover: String = ""
var pointer := Vector2.ZERO
var map_controls: Array[Control] = []
var field_controls: Array[Control] = []
var car_buttons: Dictionary = {}
var site_buttons: Dictionary = {}
var return_button: Button
var open_button: Button
var pause_button: Button
var status: Label
var help: Label
var last_physics_usec: int = 0
var ui_updates: int = 0
var _controls_stamp: Array = []
var _last_impacts: int = 0

func _ready() -> void:
    session = Session.shared_demo()
    _label("NIGHTSHIFT / NIGHT SALVAGE",Vector2(32,18),Vector2(1000,40),27)
    _label("STANDALONE DEMO · no campaign saves or repair stock · progress lasts until app exit",Vector2(34,62),Vector2(1150,27),15)
    _button("Main menu",Rect2(1100,20,145,38),_back)
    var i: int = 0
    for id: String in Data.CARS:
        var car: Dictionary = Data.CARS[id]
        var b: Button = _button("%s · %d × %d trunk"%[car["name"],car["grid"].x,car["grid"].y],Rect2(42+i*318,145,300,54),_choose_car.bind(id))
        car_buttons[id] = b
        map_controls.append(b)
        i += 1
    i = 0
    for id: String in Data.SITES:
        var b: Button = _button("",Rect2(42,274+i*112,590,82),_depart.bind(id))
        site_buttons[id] = b
        map_controls.append(b)
        i += 1
    map_controls.append(_button("Next demo night",Rect2(42,546,185,42),_next_night))
    map_controls.append(_button("Unload to demo shelf",Rect2(243,546,210,42),_unload))
    map_controls.append(_button("Reset salvage demo",Rect2(469,546,195,42),_reset))
    return_button = _button("Drive home",Rect2(890,555,154,42),_return_home)
    field_controls.append(return_button)
    open_button = _button("Open / strip · E",Rect2(890,502,320,42),_open_selected)
    field_controls.append(open_button)
    pause_button = _button("Pause · P",Rect2(1054,555,156,42),_pause)
    field_controls.append(pause_button)
    status = _label("",Vector2(34,638),Vector2(1200,62),17)
    help = _label("",Vector2(890,444),Vector2(320,54),14)
    _refresh()

func _label(text: String, at: Vector2, size: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = size
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",font_size)
    add_child(label)
    return label

func _button(text: String, rect: Rect2, action: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.position = rect.position
    b.size = rect.size
    b.pressed.connect(action)
    b.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(b)
    return b

func _refresh() -> void:
    var on_site: bool = session.site != ""
    var selected_item: Dictionary = session.find(selected)
    var stamp: Array = [session.site,session.car,session.day,session.paused,selected,hover,session.held,
        session.effort.is_empty(),session.message,session.shelf.size(),selected_item.get("opened",false),
        int(session.remaining) if not on_site else 0]
    if stamp == _controls_stamp:
        queue_redraw()
        return
    _controls_stamp = stamp
    ui_updates += 1
    for control: Control in map_controls: control.visible = not on_site
    for control: Control in field_controls: control.visible = on_site
    for id: String in car_buttons: car_buttons[id].text = ("● " if session.car == id else "")+"%s · %d × %d trunk"%[Data.CARS[id]["name"],Data.CARS[id]["grid"].x,Data.CARS[id]["grid"].y]
    for id: String in site_buttons:
        var cycle: int = session.cycle_for(id)
        var days: int = int(Data.SITES[id]["refresh"])-posmod(session.day-1,int(Data.SITES[id]["refresh"]))
        site_buttons[id].text = "%s  →  %.1f min each way\n%s\nNew load in %d nights · %s"%[Data.SITES[id]["name"],session.travel(id),Data.SITES[id]["hint"],days,"visited this load" if session.cycles.get(id,-1) == cycle else "unsearched load"]
        site_buttons[id].disabled = session.remaining < session.travel(id)*2
    status.text = "PAUSED · P or Resume to continue. No effort or time is advancing." if session.paused else session.message
    pause_button.text = "Resume · P" if session.paused else "Pause · P"
    var item: Dictionary = session.find(selected)
    open_button.disabled = session.paused or not session.effort.is_empty() or session.held != "" or item.is_empty() or not item["kind"] in ["bag","box","pc"] or item["opened"] or item["zone"] == "cargo"
    help.visible = on_site
    var detail: String = "Drag to sort / pack"
    var hovered: Dictionary = session.find(hover)
    if not hovered.is_empty():
        detail = str(hovered["kind"]).to_upper()+" · "+("rated %d, untested"%hovered["power"] if hovered["kind"] in ["gpu","pc"] else "untested" if Data.SHAPES.has(hovered["kind"]) else "opened" if hovered["opened"] else "rubbish / container")
    if not hovered.is_empty() and hovered["kind"] == "pc":
        detail = "PC CASE · parts removed" if hovered["opened"] else "PC · unopened / untested"
    help.text = detail+"\nHold left: lift · E: open / strip\nHeld: Q/E / wheel rotate · Esc cancels"
    queue_redraw()

func _choose_car(id: String) -> void:
    if session.site != "": return
    session.car = id
    _refresh()

func _depart(id: String) -> void:
    session.depart(id)
    selected = ""
    _refresh()

func _next_night() -> void:
    session.next_night()
    _refresh()

func _unload() -> void:
    session.unload()
    _refresh()

func _reset() -> void:
    Session.demo = Session.new()
    session = Session.demo
    selected = ""
    _refresh()

func _return_home() -> void:
    session.return_home()
    selected = ""
    _refresh()

func _pause() -> void:
    session.paused = not session.paused
    _refresh()

func _back() -> void:
    session.cancel_hand()
    AudioFeedback.stop_owner(self)
    get_tree().change_scene_to_file("res://scenes/start.tscn")

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT and session != null:
        session.cancel_hand()
        session.paused = true
        _refresh()

func _open_selected() -> void:
    if session.start_effort(selected,"open"): _refresh()

func _input(event: InputEvent) -> void:
    if session == null or session.site == "": return
    if event is InputEventMouseMotion: pointer = event.position
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_P: _pause()
            KEY_ESCAPE:
                session.cancel_hand()
                _refresh()
            KEY_Q: _turn(-1)
            KEY_E:
                if session.held != "": _turn(1)
                elif hover != "":
                    selected = hover
                    _open_selected()
    if not event is InputEventMouseButton: return
    pointer = event.position
    if session.paused and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        session.cancel_hand()
        _refresh()
        return
    if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
        _turn(1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1)
        return
    if event.button_index != MOUSE_BUTTON_LEFT: return
    if event.pressed:
        var id: String = session.grids[session.car].at(_cell(pointer)) if _trunk_rect().has_point(pointer) else session.pile.hit(pointer)
        if id != "":
            selected = id
            session.start_effort(id,"grab")
    else:
        if session.held != "":
            var uid: String = session.held
            var packed: bool = session.drop_cargo(_cell(pointer)) if _trunk_rect().has_point(pointer) else session.drop_world(pointer)
            if packed: AudioFeedback.request(self,"handling.putdown",{"kind":session.find(uid).get("kind","part")})
        elif session.effort.get("action","") == "grab": session.cancel_effort()
    _refresh()

func _turn(by: int) -> void:
    if session.held == "" or session.paused: return
    session.turn(by)
    AudioFeedback.request(self,"handling.rotate",{"kind":session.find(session.held)["kind"]})

func _cell(point: Vector2) -> Vector2i:
    return Vector2i(((point-CARGO_ORIGIN)/CELL).floor())

func _trunk_rect() -> Rect2:
    return Rect2(CARGO_ORIGIN,Vector2(session.grids[session.car].size)*CELL)

func _physics_process(delta: float) -> void:
    var started: int = Time.get_ticks_usec()
    var previous: String = session.held
    session.step(delta,pointer)
    if previous == "" and session.held != "": AudioFeedback.request(self,"handling.pickup",{"kind":session.find(session.held)["kind"]})
    if session.site != "": hover = session.pile.hit(pointer)
    if session.site != "" and session.pile.impacts > _last_impacts:
        AudioFeedback.request(self,"handling.impact",{"kind":"salvage","count":session.pile.impacts-_last_impacts})
    _last_impacts = session.pile.impacts if session.site != "" else 0
    _refresh()
    last_physics_usec = Time.get_ticks_usec()-started

func _draw() -> void:
    if session == null: return
    draw_rect(Rect2(0,0,1280,720),Color("131d27"))
    draw_line(Vector2(32,99),Vector2(1246,99),Color("455b67"),2)
    Ui.label(self,Vector2(40,127),"NIGHT %d    %.1f min left%s"%[session.day,session.remaining,"    RETURN %.1f min reserved"%session.reserve if session.site != "" else "    DEMO SHELF %d items"%session.shelf.size()],19,Color("e8b76c"))
    if session.site == "":
        Ui.label(self,Vector2(42,239),"CHOOSE A LOCATION · information is a clue, never guaranteed working stock",16)
        Ui.label(self,Vector2(680,620),"Prototype timing / refresh values are tuning, not release balance.",13,Color("899da8"))
    else:
        _draw_work_area()
    _draw_cargo()
    if session.site != "" and session.held != "": _draw_item(session.find(session.held),true)
    if not session.effort.is_empty():
        var f: float = float(session.effort["elapsed"])/float(session.effort["duration"])
        draw_arc(pointer,23,-PI*0.5,-PI*0.5+TAU*f,28,Color("e8b76c"),4)
        Ui.label(self,pointer+Vector2(28,0),"%.1f min"%float(session.effort["cost"]),13)

func _draw_work_area() -> void:
    draw_rect(Pile.BIN.grow(8),Color("3e5b5d"))
    draw_rect(Pile.BIN,Color("202d32"))
    for x in range(70,630,80): draw_line(Vector2(x,178),Vector2(x,617),Color("2d4045"),3)
    draw_rect(Pile.SORT,Color("283843"))
    draw_rect(Pile.SORT,Color("5a747a"),false,2)
    Ui.label(self,Vector2(44,162),Data.SITES[session.site]["name"].to_upper()+" / drag to uncover",15)
    Ui.label(self,Vector2(656,162),"SORTING AREA",15)
    for uid: String in session.pile.order:
        var item: Dictionary = session.pile.objects[uid]
        if item["zone"] in ["pile","sort"] and uid != session.held: _draw_item(item,false)

func _draw_item(item: Dictionary, carried: bool) -> void:
    var size: Vector2 = item["size"]
    var kind: String = item["kind"]
    var center: Vector2 = item["center"]
    draw_set_transform(center+Vector2(4,7),float(item["rotation"])*PI/2+float(item["angle"]))
    draw_rect(Rect2(-size/2,size),Color(0,0,0,0.35))
    draw_set_transform(center,float(item["rotation"])*PI/2+float(item["angle"]))
    var color: Color = Data.COLOURS[kind]
    if item["opened"]: color = color.darkened(0.28)
    if kind == "bag":
        var half: Vector2 = size/2
        draw_colored_polygon(PackedVector2Array([Vector2(-half.x*0.8,-half.y*0.75),Vector2(-8,-half.y),Vector2(9,-half.y),Vector2(half.x*0.8,-half.y*0.6),half,Vector2(-half.x,half.y*0.7)]),color)
        draw_line(Vector2(-12,-half.y*0.6),Vector2(12,-half.y*0.6),Color("a5b0ac"),3)
    else:
        draw_rect(Rect2(-size/2,size),color)
        draw_rect(Rect2(-size/2,size),color.lightened(0.25),false,2)
        if kind == "box":
            draw_rect(Rect2(Vector2(-7,-size.y/2),Vector2(14,size.y)),Color("d0b88c"))
        elif kind in ["gpu","psu","pc"]:
            draw_circle(Vector2.ZERO,minf(size.y*0.32,22),Color("23313c"))
            for i in range(5): draw_line(Vector2.ZERO,Vector2.from_angle(i*TAU/5)*minf(size.y*0.25,18),color.lightened(0.3),3)
        elif kind == "ram":
            for i in range(3): draw_rect(Rect2(-size/2+Vector2(7+i*13,5),Vector2(9,12)),Color("223a34"))
    if carried or item["uid"] == hover or item["uid"] == selected: draw_rect(Rect2(-size/2-Vector2(3,3),size+Vector2(6,6)),Color("f4d59a"),false,2)
    draw_set_transform(Vector2.ZERO)

func _draw_cargo() -> void:
    var rect: Rect2 = _trunk_rect()
    Ui.label(self,CARGO_ORIGIN+Vector2(0,-22),"%s / TRUNK"%Data.CARS[session.car]["name"].to_upper(),17)
    draw_rect(rect,Color("1c2c38"))
    var grid: RefCounted = session.grids[session.car]
    for x in range(grid.size.x+1): draw_line(CARGO_ORIGIN+Vector2(x*CELL,0),CARGO_ORIGIN+Vector2(x*CELL,rect.size.y),Color("3e5361"))
    for y in range(grid.size.y+1): draw_line(CARGO_ORIGIN+Vector2(0,y*CELL),CARGO_ORIGIN+Vector2(rect.size.x,y*CELL),Color("3e5361"))
    for uid: String in grid.placements:
        if uid == session.held: continue
        var p: Dictionary = grid.placements[uid]
        var r := Rect2(CARGO_ORIGIN+Vector2(p["cell"])*CELL,Vector2(Data.footprint(p["kind"],p["rotation"]))*CELL)
        draw_rect(r.grow(-3),Data.COLOURS[p["kind"]])
        Ui.label(self,r.position+Vector2(5,18),str(p["kind"]).to_upper(),13,Color("13232a"))
    if session.held != "" and rect.has_point(pointer):
        var item: Dictionary = session.find(session.held)
        if Data.SHAPES.has(item["kind"]):
            var cell: Vector2i = _cell(pointer)
            var valid: bool = grid.can_place(session.held,item["kind"],cell,session.rotation)
            draw_rect(Rect2(CARGO_ORIGIN+Vector2(cell)*CELL,Vector2(Data.footprint(item["kind"],session.rotation))*CELL),Color(0.4,0.9,0.6,0.4) if valid else Color(1,0.35,0.3,0.4))
