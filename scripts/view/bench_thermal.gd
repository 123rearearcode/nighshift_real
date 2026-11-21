# Thermal stage of the repair bench: paste material, syringe and cloth, the timed mount and the cooler install ritual (film, screwdriver screws, lever).
# Split out of bench_view.gd in 0.41.2 (Wave 3 session 3.0). Holds no state of its own: every
# member it touches lives on the bench (`bv`), and the bench keeps one-line wrappers with the old
# names, so callers and tests are unchanged.
extends RefCounted

const Ids = preload("res://scripts/data/ids.gd")
const PasteSim = preload("res://scripts/bench/paste_sim.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const PasteRenderer = preload("res://scripts/view/paste_renderer.gd")

var bv   # the bench_view.gd node; untyped on purpose (its members are reached dynamically)


func _init(bench: Node2D) -> void:
    bv = bench


func _on_mount_pressed() -> void:
    if bv.mount.active or not bv.mount_result.is_empty():
        return
    if bv.paste.total_deposited < 1.0:
        bv._set_status("Squeeze some paste onto the CPU first: hold the left mouse button over it.", 2)
        return
    if not bv._may_enter(HandState.MOUNTING):
        return
    bv._park_tool()   # pressing the cooler uses free hands; a syringe must not stay stuck to the cursor
    bv.mount.start()
    bv.screw_clicks.clear()
    bv.holding = false
    bv.wiping = false
    bv._set_status("Press now: hold Space (or the left mouse button over the socket). Release once CPU covered passes the line; too long and paste squeezes out. While you hold Space, right-click the screwdriver and tighten the four corner screws. Then click the lever.", 0)
    bv.time_up_told = false
    bv.wipe_told = false
    _sync_paste_controls()


# 0.44.1: the thermal guide. One list the player can always read: where they are and what to do now.
# Display only; the install rules stay in install_faults.gd and the grade in paste_sim.gd.
const GUIDE: Array = ["Film", "Paste", "Press + screws", "Lever", "Wipe extra", "Done"]
const OVERFLOW_CLEAN: float = 0.02   # squeezed-out share that counts as wiped clean


func _locked() -> bool:
    return not bv.mount.active and (not bv.mount_result.is_empty() or bool(GameState.job["paste_done"]))


func guide_step() -> int:
    if _locked():
        if not bv.mount_result.is_empty() and float(bv.live_stats.get("overflow", 0.0)) > OVERFLOW_CLEAN: return 4
        return 5
    if bv.mount.active:
        return 3 if bv.screw_clicks.size() >= InstallFaults.SCREW_COUNT * InstallFaults.TURNS_NEEDED else 2
    if not bool(GameState.job["cooler_film_peeled"]): return 0
    if bv.paste.total_deposited < 1.0: return 1
    return 2


func _done_text() -> String:
    var grade: String = str(GameState.job["paste_grade"]) if str(GameState.job["paste_grade"]) != "" else str(bv.mount_result.get("grade", ""))
    if bool(GameState.job["paste_done"]): return "Thermal service DONE (%s). Next: Diagnostic monitor > Hardware check." % grade
    if GameState.can_complete_repaste(): return "%s result: press Complete repaste." % grade
    return "%s is not good enough: Clear all paste and do it again." % grade


# The one instruction for right now.
func guide_text() -> String:
    match guide_step():
        0: return "NOW: peel the clear film off the cooler plate (button beside the plate)."
        1: return "NOW: right-click the syringe, hold left mouse on the CPU: a pea, in the green zone."
        2:
            if not bv.mount.active: return "NOW: click Mount cooler, then HOLD SPACE to press it down."
            if bv.tools.equipped and bv.tools.selected == Ids.SCREWDRIVER:
                return "NOW: keep holding Space; click the corner screws, opposite corners, two passes (%d of %d)." % [bv.screw_clicks.size(), InstallFaults.SCREW_COUNT * InstallFaults.TURNS_NEEDED]
            return "NOW: hold Space to press, and right-click the screwdriver to tighten the 4 corner screws."
        3: return "NOW: screws tight. Click the lever beside the socket to lock the cooler."
        4: return "NOW: right-click the cloth and wipe the orange paste around the CPU (not the CPU)."
    return _done_text()


# Verdict shown after the lever: grade and whether the repaste counts.
func verdict() -> Dictionary:
    if not _locked(): return {}
    var grade: String = str(GameState.job["paste_grade"]) if str(GameState.job["paste_grade"]) != "" else str(bv.mount_result.get("grade", ""))
    var good: bool = bool(GameState.job["paste_done"]) or GameState.can_complete_repaste()
    return {"text": ("LOCKED \u2713  %s" % grade) + (" · repaste complete" if bool(GameState.job["paste_done"]) else (" · good result" if good else " · not good enough, redo it")), "tone": 1 if good else 3}


# Material cannot change inside a deposited/locked layer. There is never a mixed-material field.
func _can_change_material() -> bool:
    return bv.paste.total_deposited <= 0.0 and not bv.mount.active and bv.mount_result.is_empty() and not bool(GameState.job["paste_done"])


func _refresh_material_menu(announce: bool = true) -> void:
    var menu: PopupMenu = bv.material_button.get_popup()
    for i in range(PasteMaterials.IDS.size()):
        menu.set_item_checked(i,bv.paste.material == PasteMaterials.IDS[i])
        menu.set_item_disabled(i,not _can_change_material())
    if announce and not _can_change_material(): bv._set_status("Wipe/reset the paste first before choosing another material.",2)


func _on_material_selected(index: int) -> void:
    if index<0 or index>=PasteMaterials.IDS.size(): return
    if not _can_change_material():
        bv._set_status("Wipe/reset the paste first before choosing another material.",2)
        return
    bv.paste.material = PasteMaterials.IDS[index]
    bv._sound("ui.click")
    _refresh_material_button()
    bv.paste_dirty = true
    var kind: Dictionary = PasteMaterials.material(bv.paste.material)
    if bool(kind["scam"]):
        bv._set_status("Toothpaste: free, stiffer, worse cooling. Billing this as a real repaste is a scam.",2)
    else:
        bv._set_status("%s ($%d%s).%s"%[kind["label"],kind["cost"],bv._material_charge_note()," Better cooling (trial: 4°C lower)." if bv.paste.material == "super" else ""],0)


func _material_charge_note() -> String:
    return ", charged when repaste is completed"


func _refresh_material_button() -> void:
    var kind: Dictionary = PasteMaterials.material(bv.paste.material)
    bv.material_button.text = "Paste: %s%s"%[kind["label"]," (scam / free)" if kind["scam"] else " ($%d)"%kind["cost"]]
    bv.material_button.tooltip_text = "Choose normal paste, super-paste (better cooling), or toothpaste (scam). Wipe/reset before changing a layer."
    _refresh_material_menu(false)


# Complete repaste: only a PERFECT or GOOD ENOUGH mount can be completed.
func _on_complete_pressed() -> void:
    if bv.mount.active or bv.mount_result.is_empty():
        return
    var result: Dictionary = GameState.complete_repaste(bv.paste.material)
    if not result["ok"]:
        bv._set_status(str(result["message"]) + " Wipe the paste off (cloth or Clear all paste) and try again.", 3)
        return
    bv._sound("cooler.complete",{"material":bv.paste.material,"grade":str(GameState.job["paste_grade"])})
    if bv.paste.material == "toothpaste":
        bv._set_status("Repaste \"complete\": toothpaste under the cooler. The customer will pay for thermal paste. It will pass today's check but run hotter and dry out.", 2)
    else:
        bv._set_status("Repaste complete: %s with %s ($%d). Run the final check in the shop." % [str(GameState.job["paste_grade"]),PasteMaterials.material(bv.paste.material)["label"],int(result["cost"])], 1)


func _on_clear_pressed() -> void:
    if bv.mount.active:
        return
    bv.paste.clear()
    bv.mount_result = {}
    bv.live_stats = {"coverage": 0.0, "overflow": 0.0}
    bv.paste_dirty = true
    GameState.clear_paste()
    bv._set_status("All paste cleared. Squeeze a new blob onto the CPU.", 0)
    _sync_paste_controls()


func _cloth_is_square() -> bool:
    return GameState.has_upgrade("square_cloth")


func _select_dispense() -> void:
    if not bv._equip_tool(Ids.SYRINGE,bv._pointer()):
        return
    bv.wiping = false
    bv.holding = false
    bv._set_status("Syringe selected. Hold on the CPU to apply paste; select cloth to wipe.", 0)
    bv.queue_redraw()


func _select_cloth() -> void:
    if not bv._equip_tool(Ids.CLOTH,bv._pointer()): return
    bv.wiping = true
    bv.holding = false
    bv._set_status("Cloth selected. Pick up the syringe from the bench to dispense again.",0)


func _cancel_unlocked_mount() -> void:
    if not bv.mount.active: return
    bv.mount.finish()
    bv.mount_result = {}
    GameState.clear_paste()
    bv._sound("cooler.cancel")


func _step_paste(delta: float, mouse: Vector2) -> void:
    if bv.mount.active:
        _step_mount(delta, mouse)
    elif bv.holding and bv.tools.equipped and not bv.tools.carrying and bv.wiping:
        var wcell: Vector2 = (mouse - bv.PASTE_ORIGIN) / float(bv.PASTE_CELL)
        var removed: float = bv.paste.wipe(wcell.x, wcell.y, bv.WIPE_RADIUS_CELLS, bv.WIPE_STRENGTH, _cloth_is_square())
        bv._audio_loop("cloth.wipe",bv._work_rect().has_point(mouse),{"speed":bv.tools.speed.length(),"removed":removed})
        if removed > 0.0:
            bv.paste_dirty = true
            # 0.44.1: after the lever, the squeezed-out figure follows the wiping, and the bench says when it is clean.
            if not bv.mount_result.is_empty():
                bv.live_stats = bv.paste.measure()
                if float(bv.live_stats["overflow"]) <= OVERFLOW_CLEAN and not bv.wipe_told:
                    bv.wipe_told = true
                    bv._set_status("Clean: the squeezed-out paste is gone. %s" % _done_text(), 1)
            # Tidying the paste that squeezed out BESIDE the CPU never costs the result; only wiping
            # the CPU itself does (0.20.0 fix: the user cleaned the overflow after pulling the lever
            # and lost the grade, so Complete repaste went dark).
            var graded_units: float = float(GameState.job.get("paste_graded_units", 0.0))
            if bv.paste.last_wipe_on_cpu > 0.0 and graded_units > 0.0 and bv.paste.total_deposited < graded_units * bv.KEEP_GRADE_ABOVE \
                    and (not bv.mount_result.is_empty() or str(GameState.job["paste_grade"]) != ""):
                bv.mount_result = {}
                bv.live_stats = {"coverage": 0.0, "overflow": 0.0}
                GameState.clear_paste()
                bv._set_status("Grade cleared because the paste on the CPU is being wiped off. Keep wiping, or squeeze fresh paste once the CPU is clean.", 0)
    elif bv.holding and bv.tools.equipped and bv.tools.selected == Ids.SYRINGE and not bv.tools.carrying and bv.mount_result.is_empty():
        var cell: Vector2 = (mouse - bv.PASTE_ORIGIN) / float(bv.PASTE_CELL)
        if cell.x >= 0.0 and cell.y >= 0.0 and cell.x < PasteSim.GRID and cell.y < PasteSim.GRID:
            if str(GameState.job["paste_grade"]) != "":
                GameState.clear_paste()
            bv.paste.deposit(cell.x, cell.y, bv.DEPOSIT_RATE * delta)
            bv._audio_loop("paste.squeeze",true,{"material":bv.paste.material,"rate":bv.DEPOSIT_RATE})
            bv.paste_dirty = true
    _sync_paste_controls()
    if bv.paste_dirty:
        _refresh_paste_image()
        bv.paste_dirty = false


func _sync_paste_controls() -> void:
    var done: bool = bool(GameState.job["paste_done"])
    var can_complete: bool = GameState.can_complete_repaste()
    var can_mount: bool = bv.stage == bv.STAGE_PASTE and bv.paste.total_deposited>=1.0 and not bv.mount.active and bv.mount_result.is_empty() and not done
    var key: int = bv.stage+int(bv.mount.active)*2+int(done)*4+int(can_complete)*8+int(can_mount)*16+int(bool(GameState.job["cooler_film_peeled"]))*32
    if key == bv._paste_ui_key: return
    bv._paste_ui_key = key
    bv.film_button.visible = bv.stage == bv.STAGE_PASTE
    bv.film_button.disabled = bool(GameState.job["cooler_film_peeled"]) or bool(GameState.job["paste_done"])
    bv.mount_button.visible = can_mount
    bv.mount_button.disabled = not can_mount
    bv.clear_button.disabled = bv.mount.active
    bv.material_button.disabled = bv.mount.active
    bv.complete_button.visible = bv.stage == bv.STAGE_PASTE
    bv.complete_button.disabled = bv.mount.active or done or not can_complete
    bv.complete_button.text = "Repaste complete" if done else "Complete repaste"
    bv.complete_button.tooltip_text = "Lock the cooler lever and obtain a good result before completing."


func _step_mount(delta: float, mouse: Vector2) -> void:
    # 0.44.1: with the screwdriver in hand the mouse turns screws; only Space presses then.
    var screwing: bool = bv.tools.equipped and bv.tools.selected == Ids.SCREWDRIVER
    var pressing: bool = Input.is_key_pressed(KEY_SPACE) or (not screwing and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and bv._work_rect().has_point(mouse))
    if bv.scripted_pressing is bool: pressing = bv.scripted_pressing   # automated playtest only
    var expired: bool = bv.mount.step(delta, pressing, bv.paste)
    bv._audio_loop("cooler.press",pressing and not expired,{"pressure":bv.mount.pressure})
    bv.live_stats = bv.paste.measure()
    bv.paste_dirty = true
    if expired and not bv.time_up_told:
        bv.time_up_told = true
        bv._set_status("The paste has set: pressing longer changes nothing now. Finish the four corner screws with the screwdriver if you have not, then click the lever to lock the cooler.", 2)


# Lift the cooler back off without grading (D57: nothing but the lever secures it). The paste keeps
# whatever shape the pressing gave it; mounting can simply be started again.
func _cancel_mount() -> void:
    if not bv.mount.active:
        return
    bv.mount.cancel()
    bv.screw_clicks.clear()
    if bv.tools.equipped and bv.tools.selected == Ids.SCREWDRIVER: bv._park_tool()
    bv.holding = false
    bv.time_up_told = false
    bv._set_status("You lifted the cooler off again without locking it: no result. The paste stays as it was pressed; mount again when ready, and pull the lever to secure.", 2)


# D131: which of InstallFaults.STEPS the player is on (0-based; STEPS.size() = all done).
func _install_step() -> int:
    var locked: bool = not bv.mount.active and (not bv.mount_result.is_empty() or bool(GameState.job["paste_done"]))
    if locked: return InstallFaults.STEPS.size()
    if bv.mount.active:
        if bv.mount.time_left > 0.0: return 2
        return 4 if bv.screw_clicks.size() >= InstallFaults.SCREW_COUNT * InstallFaults.TURNS_NEEDED else 3
    if bv.paste.total_deposited >= 1.0: return 2
    if bool(GameState.job["cooler_film_peeled"]): return 1
    return 0


func _socket_region() -> Rect2:
    return Rect2(bv.PASTE_ORIGIN, Vector2(PasteSim.GRID * bv.PASTE_CELL, PasteSim.GRID * bv.PASTE_CELL))


func _on_film_pressed() -> void:
    if bool(GameState.job["cooler_film_peeled"]):
        return
    GameState.peel_cooler_film()
    bv._paste_ui_key = -1
    _sync_paste_controls()
    bv._set_status("You peeled the clear plastic film off the cooler's base. Bare metal now.", 0)


# One quarter of the install ritual: a snug turn, then a tight one, on a corner screw. The bench never
# says whether the pattern was right; the customer finds out at home (D130).
func _screw_click(screw: int) -> void:
    if not (bv.tools.equipped and bv.tools.selected == Ids.SCREWDRIVER):
        bv._set_status("You need the screwdriver for the screws. Right-click it on the bench (you can keep holding Space while you do).", 2)
        return
    _turn_screw(screw)


func _turn_screw(screw: int) -> void:
    if not InstallFaults.can_turn(bv.screw_clicks, screw):
        return
    var first: bool = bv.screw_clicks.is_empty()
    bv.screw_clicks.append(screw)
    bv._sound("ui.click")
    var turns: int = InstallFaults.turns(bv.screw_clicks, screw)
    var text: String = "Screw %d %s (%d of %d turns done)." % [screw + 1, "tight" if turns >= InstallFaults.TURNS_NEEDED else "snug", bv.screw_clicks.size(), InstallFaults.SCREW_COUNT * InstallFaults.TURNS_NEEDED]
    if first:
        text += " Manual: tighten opposite corners in turn, in two passes."
    bv._set_status(text, 0)


func _finish_mount() -> void:
    if not bv.mount.active:
        return
    bv.mount.finish()
    bv.mount_result = bv.paste.evaluate()
    bv.live_stats = {"coverage": bv.mount_result["coverage"], "overflow": bv.mount_result["overflow"]}
    bv.access.set_removed(Ids.COOLER, false)
    GameState.job["removed_parts"] = bv.access.removed_ids()
    bv._sync_part_geometry()
    GameState.set_paste(bv.mount_result, bv.paste.total_deposited)
    # D130: the hidden mistakes of this mount are recorded now and surface only at the customer's pickup.
    GameState.set_install_faults(InstallFaults.evaluate(bool(GameState.job["cooler_film_peeled"]), bv.screw_clicks))
    bv.locked_screw_clicks = bv.screw_clicks.duplicate()   # 0.44.1: the screws stay visible on the locked cooler
    bv.screw_clicks.clear()
    bv.wipe_told = false
    if bv.tools.equipped and bv.tools.selected == Ids.SCREWDRIVER: bv._park_tool()
    bv.paste_dirty = true
    var cov: float = bv.mount_result["coverage"]
    var over: float = bv.mount_result["overflow"]
    var text: String = "Cooler LOCKED. %s: %s\nCoverage %d%%, squeezed out %d%%. You now see the paste through the cooler: red = bare CPU, orange = squeezed out.%s" % [bv.mount_result["grade"], bv.mount_result["message"], roundi(cov * 100.0), roundi(over * 100.0), " Wipe the orange away with the cloth." if over > OVERFLOW_CLEAN else ""]
    bv._set_status(text, bv.mount_result["tone"])


func _refresh_paste_image() -> void:
    var show_result: bool = not bv.mount_result.is_empty()
    PasteRenderer.refresh_image(bv.paste, bv.paste_image, bv.paste_texture, show_result, show_result or bv.mount.active)
