# Movable customer parts on the repair bench (cooler, GPU): geometry, unscrewing and dragging, motion, saved positions, and the Replacement stock panel.
# Split out of bench_view.gd in 0.41.2 (Wave 3 session 3.0). Holds no state of its own: every
# member it touches lives on the bench (`bv`), and the bench keeps one-line wrappers with the old
# names, so callers and tests are unchanged.
extends RefCounted

const Ids = preload("res://scripts/data/ids.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const TableBody = preload("res://scripts/bench/table_body.gd")
const PartMotion = preload("res://scripts/view/part_motion.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const ServiceAccess = preload("res://scripts/bench/service_access.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")

var bv   # the bench_view.gd node; untyped on purpose (its members are reached dynamically)


func _init(bench: Node2D) -> void:
    bv = bench


func _zone_rect(i: int) -> Rect2:
    var z: Dictionary = bv.zones[i]
    var r: Rect2 = z["rect"]
    r.position += bv.PC_ORIGIN
    return r


func _part_rects() -> Dictionary:
    var out: Dictionary = {}
    for id: String in ServiceAccess.MOVABLE:
        var center: Vector2 = bv.part_motions[id].center
        if bv.part_bodies.has(id): center.y -= bv.part_bodies[id].height
        var size: Vector2 = (bv.access.homes[id] as Rect2).size
        out[id] = Rect2(center-size*0.5,size)
    return out


func _part_poses() -> Dictionary:
    var out: Dictionary = {}
    var rects: Dictionary = _part_rects()
    for id: String in ServiceAccess.MOVABLE:
        out[id] = {"center":rects[id].get_center(),"angle":bv.part_motions[id].angle,"shadow":bv.part_motions[id].center+Vector2(3,5)}
    return out


func _sync_part_geometry() -> void:
    if bv.part_motions.is_empty(): return
    var poses: Dictionary = _part_poses()
    for id: String in ServiceAccess.MOVABLE:
        var index: int = DustZones.index_of(id)
        var old: Dictionary = bv.previous_poses.get(id,{"center":bv.access.homes[id].get_center(),"angle":0.0})
        bv.dust.transform_zone(index,old["center"],poses[id]["center"],poses[id]["angle"]-old["angle"])
    bv.previous_poses = poses
    var key: String = str(bv.access.removed_ids())
    if key != bv.blocker_key:
        bv.dust.set_blockers(bv.access.blockers())
        bv.blocker_key = key


func _finish_part_drag(point: Vector2) -> void:
    var id: String = bv.access.dragging
    var flick: bool = id != "" and bv.event_velocity.length() > 450 and Time.get_ticks_msec()-bv.pointer_tick < 140 and ToolRig.TABLE.has_point(point) and not bv.access.homes[id].grow(12).has_point(point)
    var result: Dictionary = bv.access.finish(ServiceAccess.TRAY.get_center() if flick else point)
    if id != "":
        bv._sound("handling.install" if result.get("changed",false) and not id in bv.access.removed_ids() else "handling.putdown",{"kind":id,"item":"component"})
        if flick:
            var body := TableBody.new()
            body.launch(bv.part_motions[id].center,bv.event_velocity*0.8,bv.access.homes[id].size*0.5,bv.part_motions[id].angle)
            bv.part_bodies[id] = body
        else: bv.part_bodies.erase(id)
    _sync_part_geometry()
    if result.get("changed", false):
        GameState.job["removed_parts"] = bv.access.removed_ids()
        if result["id"] == Ids.COOLER and Ids.COOLER in bv.access.removed_ids():
            GameState.clear_paste()
            bv.paste.clear()
            bv.mount_result = {}
            bv.paste_dirty = true
        bv._save_dust()
    if result.get("message", "") != "": bv._set_status(result["message"], 0)


func _pick_target(point: Vector2) -> String:
    for id: String in ServiceAccess.MOVABLE:
        if not id in bv.access.removed_ids() and bv.access.current_rect(id).has_point(point): return id
    return ""


func _init_part_motion() -> void:
    var saved: Dictionary = GameState.job.get("service_table_positions",{})
    for id: String in ServiceAccess.MOVABLE:
        var motion := PartMotion.new()
        motion.snap(bv.access.current_rect(id).get_center(),0)
        if id in bv.access.removed_ids() and saved.get(id) is Dictionary:
            var xy: Variant = saved[id].get("center",[])
            if xy is Array and xy.size() == 2 and typeof(xy[0]) in [TYPE_INT,TYPE_FLOAT] and typeof(xy[1]) in [TYPE_INT,TYPE_FLOAT]:
                var body := TableBody.new()
                body.center = Vector2(float(xy[0]),float(xy[1])).clamp(ToolRig.TABLE.position+bv.access.homes[id].size*0.5,ToolRig.TABLE.end-bv.access.homes[id].size*0.5)
                body.half_size = bv.access.homes[id].size*0.5
                body.angle = float(saved[id].get("angle",0.0))
                bv.part_bodies[id] = body
                motion.center = body.center
                motion.angle = body.angle
        bv.part_motions[id] = motion


func _step_part_motion(delta: float) -> void:
    for id: String in ServiceAccess.MOVABLE:
        var motion: RefCounted = bv.part_motions[id]
        if bv.access.dragging == id:
            bv.part_bodies.erase(id)
            motion.step(delta,bv.access.current_rect(id).get_center(),0,true)
        elif bv.part_bodies.has(id) and id in bv.access.removed_ids():
            var body: RefCounted = bv.part_bodies[id]
            body.step(delta,ToolRig.TABLE)
            motion.center = body.center
            motion.angle = body.angle
        else:
            bv.part_bodies.erase(id)
            motion.step(delta,bv.access.current_rect(id).get_center(),0,false)


func _save_service_positions() -> void:
    var saved: Dictionary = {}
    for id: String in bv.part_bodies:
        if id in bv.access.removed_ids():
            var center: Vector2 = bv.part_bodies[id].center
            saved[id] = {"center":[center.x,center.y],"angle":bv.part_bodies[id].angle}
    GameState.job["service_table_positions"] = saved


# The movable part under `point`, or "".
func _part_under(point: Vector2) -> String:
    var rects: Dictionary = _part_rects()
    for id: String in ServiceAccess.MOVABLE:
        var hit_rect: Rect2 = rects[id]
        if bv.part_bodies.has(id):
            var edge: Vector2 = bv.part_bodies[id].extent()
            hit_rect = Rect2(rects[id].get_center()-edge,edge*2)
        if hit_rect.has_point(point): return id
    return ""


func _begin_part_drag(point: Vector2) -> bool:
    var id: String = _part_under(point)
    return id != "" and _start_part_drag(id, point)


func _start_part_drag(id: String, point: Vector2) -> bool:
    if not bv._may_enter(HandState.DRAGGING_PART):
        return false
    var rects: Dictionary = _part_rects()
    bv.access.begin(bv.access.current_rect(id).get_center())
    bv.access.drag_rect = rects[id]
    bv.access.drag_offset = (point-(rects[id] as Rect2).position).clamp(Vector2.ZERO,(rects[id] as Rect2).size)
    bv.part_bodies.erase(id)
    bv._sound("handling.pickup",{"kind":id,"item":"component"})
    return true


func _build_replacements() -> void:
    bv.replacement_panel = Panel.new()
    bv.replacement_panel.position = Vector2(680, 250)
    bv.replacement_panel.size = Vector2(570, 385)
    bv.replacement_panel.z_index = 20
    var background := StyleBoxFlat.new()
    background.bg_color = Color("202b38")
    background.border_color = Color("8eafc3")
    background.set_border_width_all(2)
    bv.replacement_panel.add_theme_stylebox_override("panel", background)
    bv.add_child(bv.replacement_panel)
    bv.replacement_summary = Label.new()
    bv.replacement_summary.position = Vector2(16, 12)
    bv.replacement_summary.size = Vector2(538, 140)
    bv.replacement_summary.add_theme_font_size_override("font_size", 14)
    bv.replacement_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    bv.replacement_panel.add_child(bv.replacement_summary)
    for id: String in ServiceParts.IDS:
        for tier: String in ["similar", "budget"]:
            var choice: Dictionary = ServiceParts.option(id, tier)
            var i: int = bv.replacement_buttons.size()
            var button := Button.new()
            button.position = Vector2(16, 156 + i * 41)
            button.size = Vector2(350, 36)
            button.add_theme_font_size_override("font_size", 14)
            var disabled_style := StyleBoxFlat.new()
            disabled_style.bg_color = Color("29333f")
            button.add_theme_stylebox_override("disabled", disabled_style)
            button.text = "%s / $%d / %d%% of original%s" % [choice["label"], choice["cost"], choice["performance"], " / +8 C" if id == Ids.COOLER and tier == "budget" else ""]
            button.pressed.connect(_replace_part.bind(id, tier))
            bv.replacement_panel.add_child(button)
            var buy := Button.new()
            buy.position = Vector2(374,156+i*41)
            buy.size = Vector2(178,36)
            buy.text = "Buy +1 / $%d" % choice["cost"]
            buy.pressed.connect(_buy_stock.bind(id,tier))
            bv.replacement_panel.add_child(buy)
            bv.replacement_buttons.append({"button":button,"buy":buy,"id":id,"tier":tier})
    var close := Button.new()
    close.position = Vector2(16, 332)
    close.size = Vector2(250, 36)
    close.text = "Close / return to bench"
    close.pressed.connect(func() -> void: bv.replacement_panel.hide())
    bv.replacement_panel.add_child(close)
    var inventory_button := Button.new()
    inventory_button.position = Vector2(282,332)
    inventory_button.size = Vector2(270,36)
    inventory_button.text = "Open player inventory"
    inventory_button.pressed.connect(func() -> void:
        bv._save_dust()
        bv.get_tree().change_scene_to_file("res://scenes/main.tscn"))
    bv.replacement_panel.add_child(inventory_button)
    bv.replacement_panel.hide()


func _open_replacements() -> void:
    if not bv._may_enter(HandState.PANEL_OPEN):
        return
    bv.holding = false
    bv.access.dragging = ""
    _sync_part_geometry()
    bv.pick.reset()
    bv.replacement_panel.show()
    _refresh_replacements()


func _refresh_replacements() -> void:
    # D150 (0.46.2): fitting is a test until the customer collects: the part stays yours, the customer's
    # original stays theirs. The panel never says which part is faulty.
    bv.replacement_summary.text = "PLAYER INVENTORY / cash $%d\nTake the customer's part out first, then fit one of yours. It stays your stock until the customer collects; take it out again and it goes back to the drawer.\nBudget = 65%% specification. Cooler downgrade: +8 C." % [GameState.money]
    for item: Dictionary in bv.replacement_buttons:
        var id: String = item["id"]
        var choice: Dictionary = ServiceParts.option(id,item["tier"])
        var count: int = GameState.stock_count(id,item["tier"])
        item["button"].text = "Fit %s / owned %d" % [choice["label"],count]
        item["button"].disabled = count == 0 or not id in GameState.job["removed_parts"] or GameState.job["state"] == "done"
        item["buy"].disabled = GameState.money < int(choice["cost"])


func _replace_part(id: String, tier: String) -> void:
    if not GameState.replace_service_part(id, tier): return
    bv.access.set_removed(id, false)
    _sync_part_geometry()
    if id == Ids.COOLER:
        bv.paste.clear()
        bv.mount_result = {}
        bv.paste_dirty = true
    _refresh_replacements()
    bv._set_status("Replacement fitted. %s" % ("Budget part: 65% of the original specification." if tier == "budget" else "Original specification restored."), 2 if tier == "budget" else 1)


func _buy_stock(id: String, tier: String) -> void:
    if not GameState.buy_service_stock(id,tier):
        bv._set_status("Purchase needs enough cash and empty inventory cells.",2)
    _refresh_replacements()


func _new_ticket() -> void:
    bv._save_dust()
    GameState.start_repair_ticket()
    bv.get_tree().reload_current_scene()
