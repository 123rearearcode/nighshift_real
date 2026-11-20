# Cleaning stage of the repair bench: dust steps, the pick, the vacuum bin, tool and part collisions, fan speeds and dust saving.
# Split out of bench_view.gd in 0.41.2 (Wave 3 session 3.0). Holds no state of its own: every
# member it touches lives on the bench (`bv`), and the bench keeps one-line wrappers with the old
# names, so callers and tests are unchanged.
extends RefCounted

const VacuumState = preload("res://scripts/bench/vacuum_state.gd")
const Ids = preload("res://scripts/data/ids.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const TableBody = preload("res://scripts/bench/table_body.gd")
const DustSnapshot = preload("res://scripts/bench/dust_snapshot.gd")
const DustSim = preload("res://scripts/bench/dust_sim.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const ServiceAccess = preload("res://scripts/bench/service_access.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const PieceCollision = preload("res://scripts/bench/piece_collision.gd")

var bv   # the bench_view.gd node; untyped on purpose (its members are reached dynamically)


func _init(bench: Node2D) -> void:
    bv = bench


# Fresh, reopened and New dirty PC use the same geometry + restoration sequence.
func _initialize_dust() -> void:
    bv.dust.setup(bv.zones, bv.PC_ORIGIN, bv.DUST_SEED)
    bv.access.setup(bv.zones, bv.PC_ORIGIN, GameState.job.get("removed_parts", []))
    bv.part_motions.clear()
    bv.part_bodies.clear()
    bv._init_part_motion()
    bv.previous_poses.clear()
    bv.blocker_key = ""
    bv._sync_part_geometry()
    var restored: bool = DustSnapshot.restore(bv.dust, GameState.job.get("dust_state", {}))
    if not restored:
        for i in range(bv.zones.size()): bv.dust.apply_progress(i,GameState.dust_fraction(str(bv.zones[i]["id"])))
    bv.zone_done.clear()
    for i in range(bv.zones.size()): bv.zone_done.append(bv.dust.removed_fraction(i) >= DustZones.CLEAN_AT)
    bv.tools.clamp_pc = bv.dust.case_bounds


func _dust_fractions() -> Dictionary:
    var out: Dictionary = {}
    for i in range(bv.zones.size()):
        var z: Dictionary = bv.zones[i]
        out[str(z["id"])] = bv.dust.removed_fraction(i)
    return out


func _save_dust() -> void:
    # 0.48.1: the vacuum is the shop's tool; its bin and hose contents are saved with every dust save.
    GameState.set_vacuum(bv.bin.fill, VacuumState.capture(bv.tools.flow))
    if bv.zones.is_empty() or bv.loaded_job_id != str(GameState.job["id"]):
        GameState.save_game()
        return
    bv._save_service_positions()
    GameState.set_dust(_dust_fractions(),DustSnapshot.capture(bv.dust))
    bv.dust_dirty = false
    bv.save_timer = 0.0


func _done_count() -> int:
    var n: int = 0
    for d in bv.zone_done:
        if bool(d):
            n += 1
    return n


func _clean_hint() -> String:
    if bv.active_tool == 3:
        return "Pick: hover cooler/GPU to inspect trapped dust; hold to extract (0.8s, 12% damage risk per attempt). Safe alternative: remove the part. Broken? Move it to tray, then choose Replacements."
    if bv.active_tool == 2:
        return "Move parts: drag cooler or GPU onto the tray. Clean their surfaces there, then clean the exposed board. Drag each back to its mount before final check."
    if bv.active_tool == DustSim.TOOL_VACUUM:
        return "Vacuum: hold over dirt. Tails hanging from under parts can be pulled very slowly with precise suction; remove the part for easier access. Short hose: rotate/re-route to reach the far-left corner."
    return "Brush: sweep the bristles over dust to loosen it (it turns lighter). Fast strokes scatter it through the case; watch for trapped dust and clogged filter. The brush removes nothing by itself; vacuum the loosened bundle afterwards, which is faster."


func _on_reset_dust() -> void:
    bv.holding = false
    var fresh: Dictionary = {}
    for z: Dictionary in bv.zones: fresh[str(z["id"])] = 1.0 if z["id"] == "case_interior" else 0.0
    bv._save_service_positions()
    GameState.set_dust(fresh)
    _initialize_dust()
    bv.tools.flow.clear()
    bv.cooler_rpm = bv.FAN_RPM_DUSTY if GameState.job["pc_powered"] else 0.0
    bv.case_rpm = bv.FAN_RPM_DUSTY if GameState.job["pc_powered"] else 0.0
    bv._save_dust()
    bv._set_status(_clean_hint(), 0)


func _step_clean(delta: float, mouse: Vector2) -> void:
    # Unscrewing (D89): holding on a fitted part frees it after PART_LIFT_SECONDS; slipping off cancels.
    if bv.lift_id != "":
        if bv.active_tool != 2 or bv.lift_id in bv.access.removed_ids():
            bv.lift_id = ""
        else:
            var rects: Dictionary = bv._part_rects()
            if not (rects[bv.lift_id] as Rect2).grow(24.0).has_point(mouse):
                bv.lift_id = ""
                bv._set_status("Unscrewing cancelled: keep the cursor on the part.", 2)
            else:
                bv.lift_progress += delta
                if bv.lift_progress >= bv.PART_LIFT_SECONDS:
                    var freed: String = bv.lift_id
                    bv.lift_id = ""
                    bv._start_part_drag(freed, mouse)
    bv.access.move(mouse)
    bv._step_part_motion(delta)
    bv._sync_part_geometry()
    var modal_open: bool = is_instance_valid(bv.replacement_panel) and bv.replacement_panel.visible
    bv.dust.brush_contacts = PackedVector2Array()
    if bv.active_tool == 1:
        var angle: float = bv.tools.motions[Ids.BRUSH].angle
        for point: Vector2 in bv.tools.brush.tips(): bv.dust.brush_contacts.append(mouse+point.rotated(angle))
    var working: bool = bv.holding and not modal_open and bv.tools.equipped and not bv.tools.carrying and not bv.tools.clamp_dragging
    var vacuum_ok: bool = not (bv.active_tool == DustSim.TOOL_VACUUM and bv.bin.is_full())   # a full bin stops the suction
    bv.dust.step(delta, bv.active_tool, mouse, bv.tools.speed, working and vacuum_ok)
    bv._audio_loop("vacuum.motor",working and vacuum_ok and bv.active_tool == 0,{"ramp":bv.dust.vac_ramp,"bin_fill":bv.bin.fraction()})
    bv._audio_loop("brush.contact",working and bv.active_tool == 1 and bv.dust.last_brush_contacts > 0,{"speed":bv.tools.speed.length(),"contacts":bv.dust.last_brush_contacts})
    _after_dust_step(delta, mouse)
    var target: String = bv._pick_target(mouse)
    var eligible: bool = bv.active_tool == 3 and working and target != "" and not target in GameState.job.get("damaged_parts", []) and GameState.job["state"] != "done" and bv.dust.trapped_count(target) > 0
    bv._audio_loop("pick.scrape",eligible,{"part":target})
    var stroke: Dictionary = bv.pick.step(delta, target, eligible)
    if not stroke.is_empty():
        if stroke["damaged"]:
            GameState.damage_service_part(target)
            bv._sound("part.damage",{"kind":target})
            bv.holding = false
            bv._set_status("SNAP! %s damaged. Move it to the tray, then open Replacements. Equivalent parts cost more; budget parts lower the specification." % target.to_upper(), 3)
        else:
            bv.dust.pick_extract(target)
            bv._sound("pick.extract",{"kind":target})
            bv._set_status("Extracted a clump from under %s. %d remain. Another attempt risks damage again." % [target, bv.dust.trapped_count(target)], 2)
        bv._save_dust()
    if bv.holding or bv.dust.motion_changed:
        bv.dust_dirty = true
    for i in range(bv.zones.size()):
        var now_clean: bool = bv.dust.removed_fraction(i) >= DustZones.CLEAN_AT
        if bool(bv.zone_done[i]) != now_clean:
            bv.zone_done[i] = now_clean
            bv.dust_dirty = true
            if now_clean and not bv.dust.motion_changed: _announce_zone(i)
    if bv.dust_dirty:
        bv.save_timer += delta
        if bv.save_timer >= bv.AUTOSAVE_SECONDS:
            bv._save_dust()
    # Fan speeds follow how clean their own part is; angle advances by exactly RPM * 360 / 60 per second.
    var target_cooler: float = lerpf(bv.FAN_RPM_DUSTY, bv.FAN_RPM_CLEAN, bv.dust.removed_fraction(bv.cooler_zone))
    var target_case: float = lerpf(bv.FAN_RPM_DUSTY, bv.FAN_RPM_CLEAN, bv.dust.removed_fraction(bv.case_fan_zone))
    if Ids.COOLER in GameState.job["broken_parts"]: target_cooler = 0.0
    if not bool(GameState.job["pc_powered"]):
        target_cooler = 0.0
        target_case = 0.0
    bv.cooler_rpm = lerpf(bv.cooler_rpm, target_cooler, 1.0 - exp(-3.0 * delta))
    bv.case_rpm = lerpf(bv.case_rpm, target_case, 1.0 - exp(-3.0 * delta))
    bv.cooler_angle += bv.cooler_rpm * TAU / 60.0 * delta   # RPM to radians per second
    bv.case_angle += bv.case_rpm * TAU / 60.0 * delta


# Tools and loose parts lying on the bench collide as rotated boxes. Held things push others away and are
# never pushed. The solid pieces also become obstacles the vacuum hose has to lie around.
func _step_pieces() -> void:
    var visible_tools: Array = Ids.CLEAN_TOOLS if bv.stage == bv.STAGE_CLEAN else Ids.PASTE_TOOLS
    var pieces: Array = bv.tools.collision_pieces(visible_tools)
    if bv.stage == bv.STAGE_CLEAN and not (is_instance_valid(bv.replacement_panel) and bv.replacement_panel.visible):
        pieces.append_array(_part_pieces())
    PieceCollision.resolve(pieces)
    bv.tools.apply_collisions(pieces)
    _apply_part_collisions(pieces)
    var fitted: Array = []
    if bv.stage == bv.STAGE_CLEAN:
        for id: String in ServiceAccess.MOVABLE:
            if id in bv.access.removed_ids() or bv.access.dragging == id: continue
            var home: Rect2 = bv.access.homes[id]
            fitted.append({"id": id, "center": home.get_center(), "angle": 0.0, "half": home.size * 0.5})
    bv.tools.set_hose_obstacles(pieces, fitted)


func _part_pieces() -> Array:
    var out: Array = []
    for id: String in ServiceAccess.MOVABLE:
        var dragging: bool = bv.access.dragging == id
        if not dragging and not id in bv.access.removed_ids(): continue
        var motion: RefCounted = bv.part_motions[id]
        var body: RefCounted = bv.part_bodies.get(id)
        out.append({"id": id, "kind": "part", "center": motion.center, "angle": motion.angle,
            "half": bv.access.homes[id].size * 0.5,
            "velocity": motion.velocity if dragging else (Vector2.ZERO if body == null else body.velocity),
            "spin": 0.0 if (dragging or body == null) else body.angular_velocity,
            "inv_mass": 0.0 if dragging else 1.0 / float(bv.PART_MASS[id]),
            "solid": dragging or body == null or not body.active or body.height < ToolRig.SOLID_HEIGHT,
            "touched": false})
    return out


func _apply_part_collisions(pieces: Array) -> void:
    for piece: Dictionary in pieces:
        if piece["kind"] != "part" or not bool(piece["touched"]): continue
        var id: String = piece["id"]
        if bv.access.dragging == id: continue
        var body: RefCounted = bv.part_bodies.get(id)
        if body == null:
            body = TableBody.new()
            bv.part_bodies[id] = body
        var was_active: bool = body.active
        body.half_size = bv.access.homes[id].size * 0.5
        body.center = (piece["center"] as Vector2).clamp(ToolRig.TABLE.position + body.half_size, ToolRig.TABLE.end - body.half_size)
        body.angle = piece["angle"]
        body.velocity = piece["velocity"]
        body.angular_velocity = piece["spin"]
        if not was_active:
            body.height = 0.0
            body.vertical_velocity = 0.0
            body.active = true
        bv.part_motions[id].center = body.center
        bv.part_motions[id].angle = body.angle


# Things that follow from one dust step: the bin fills, kicked dust sends up motes, motes float.
func _after_dust_step(delta: float, nozzle: Vector2) -> void:
    var swallowed: float = bv.dust.take_swallowed()
    bv.tools.flow.add(swallowed)   # swallowed dust rides the hose; it fills the bin when it arrives
    var suction_now: float = bv.dust.vac_ramp if bv.active_tool == DustSim.TOOL_VACUUM else 0.0
    var arrived: float = bv.tools.flow.step(delta, suction_now, DustBin.CAPACITY - bv.bin.fill)
    if arrived > 0.0:
        bv.bin.add(arrived)
        if bv.bin.is_full() and not bv.bin_notified:
            bv.bin_notified = true
            bv._sound("bin.full")
            bv._set_status("The dust bin is full! Click the bin (bottom right of the bench) to empty it, then keep vacuuming.", 2)
    bv._audio_loop("vacuum.dust",bv.active_tool == 0 and bv.holding and bv.tools.equipped and not bv.bin.is_full() and (swallowed > 0.0 or bv.tools.flow.count() > 0),{"units":swallowed,"carried":bv.tools.flow.carried()})
    _refresh_vacuum_status()
    for point: Vector2 in bv.dust.kicked:
        bv.motes.spawn(point, bv.tools.speed.limit_length(200.0) * 0.15, 3, 45.0)
    var suction: float = bv.dust.vac_ramp if bv.active_tool == DustSim.TOOL_VACUUM else 0.0
    bv.motes.step(delta, bv.dust, nozzle, suction)


# A blocked vacuum is a persistent state, independent of transient tool hints.
func _refresh_vacuum_status() -> void:
    if not is_instance_valid(bv.vacuum_status): return
    var full: bool = bv.bin.is_full()
    var key := Vector3i(roundi(bv.bin.fraction()*100.0),int(full),int(bv.bin.fill<=0.0))
    if key == bv._vacuum_ui_key: return
    bv._vacuum_ui_key = key
    bv.vacuum_ui_updates += 1
    bv.vacuum_status.text = "BIN FULL — suction paused. Empty bin to continue." if full else "Vacuum ready  /  bin %d%%" % roundi(bv.bin.fraction()*100.0)
    bv.vacuum_status.add_theme_color_override("font_color",bv.TONE_COLORS[2] if full else bv.TONE_COLORS[0])
    bv.empty_bin_button.text = "Empty bin (%d%%)" % roundi(bv.bin.fraction()*100.0)
    bv.empty_bin_button.disabled = bv.bin.fill <= 0.0
    bv.empty_bin_button.add_theme_color_override("font_color",bv.TONE_COLORS[2] if full else bv.TONE_COLORS[0])


func _empty_bin() -> void:
    var had: float = bv.bin.empty()
    if had > 0.0: bv._sound("bin.empty",{"units":had})
    GameState.set_vacuum(bv.bin.fill, VacuumState.capture(bv.tools.flow))
    GameState.save_game()
    bv.bin_notified = false
    _refresh_vacuum_status()
    if had <= 0.0:
        bv._set_status("The dust bin is already empty.", 0)
    else:
        bv._set_status("Emptied the dust bin (%d units of dust). The vacuum is ready again." % roundi(had), 1)


func _announce_zone(i: int) -> void:
    var z: Dictionary = bv.zones[i]
    if _done_count() == bv.zones.size():
        bv._set_status("%s is clean. That was the last part: the whole PC is clean! Move on to step 2: apply thermal paste." % z["label"], 1)
    else:
        bv._set_status("%s is clean (%d of %d parts). Keep going: the other parts still count." % [z["label"], _done_count(), bv.zones.size()], 1)


func _retract_hose() -> void:
    if bv.stage != bv.STAGE_CLEAN or not bv.hand_state() in [HandState.FREE,HandState.USING_TOOL]: return
    bv.tools.start_spool_retract()
    bv._sound("hose.rewind")
    bv._set_status("Bin retract button: hose reels in and stays short until you pull it back out.",0)
    bv.holding = false
