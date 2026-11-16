# Mouse and keyboard input of the repair bench, routed through the hand state (docs/HAND_STATES.md).
# Split out of bench_view.gd in 0.42.0 (Wave 3 session 3.0). Holds no state of its own: every
# member it touches lives on the bench (`bv`), and the bench keeps one-line wrappers with the old
# names, so callers and tests are unchanged.
extends RefCounted

const Ids = preload("res://scripts/data/ids.gd")
const Layout = preload("res://scripts/data/layout.gd")
const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const DustSim = preload("res://scripts/bench/dust_sim.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")

var bv   # the bench_view.gd node; untyped on purpose (its members are reached dynamically)


func _init(bench: Node2D) -> void:
    bv = bench


func _input(event: InputEvent) -> void:
    if is_instance_valid(bv.replacement_panel) and bv.replacement_panel.visible: return
    if event is InputEventMouseMotion and bv.turning_with_mouse:
        bv.turn_travel += (event as InputEventMouseMotion).relative.x
        var steps: int = int(bv.turn_travel / bv.TURN_DRAG_PIXELS)
        if steps != 0:
            bv.turn_travel -= float(steps) * bv.TURN_DRAG_PIXELS
            bv.tools.rotate_steps(steps)
    if event is InputEventMouseMotion:
        var now: int = Time.get_ticks_msec()
        if bv.pointer_tick > 0:
            bv.event_velocity = bv.event_velocity.lerp(((event.position-bv.pointer_event)/maxf(0.008,float(now-bv.pointer_tick)/1000.0)).limit_length(2200),0.6)
        bv.pointer_tick = now
        bv.pointer_event = event.position
    if event is InputEventMouseButton:
        var mb: InputEventMouseButton = event
        if bv.stage == bv.STAGE_CLEAN and mb.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
            if not mb.pressed and bv.clamp_button == mb.button_index:
                bv.tools.move_clamp(mb.position)
                var clicked: bool = bv.clamp_press.distance_to(mb.position) < 5.0
                bv.tools.end_clamp_drag()
                if clicked and bv.clamp_button == MOUSE_BUTTON_LEFT:
                    bv.tools.unclamp_hose()
                    bv._sound("clamp.release")
                bv.clamp_button = 0
                bv.holding = false
                return
            if mb.pressed and bv.tools.hose_grab < 0 and bv._may_enter(HandState.DRAGGING_CLAMP) and bv.tools.begin_clamp_drag(mb.position):
                bv.clamp_button = mb.button_index
                bv.clamp_press = mb.position
                bv.holding = false
                return
        # Middle mouse turns the held tool: spin the wheel, or hold the middle button and drag sideways.
        if mb.button_index == MOUSE_BUTTON_MIDDLE:
            bv.turning_with_mouse = mb.pressed
            bv.turn_travel = 0.0
            return
        if mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
            bv.tools.rotate_held(-1 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
            return
        # The clamp never steals a held-tool click. Empty hands can unclip it.
        if mb.button_index == MOUSE_BUTTON_RIGHT and not mb.pressed and bv.tools.hose_grab >= 0:
            bv.tools.release_hose(mb.position)
            if bv.tools.hose_clamp > 0:
                bv._sound("clamp.lock")
                bv._set_status("Hose parked in the clamp. Pick up a tool to keep working; click the clamp with empty hands to release.", 1)
            elif bv.tools.clamp_hit(mb.position):
                bv._set_status("That section cannot reach the clamp. Grab farther along the hose and try again.", 2)
            bv.holding = false
            return
        # D131: mid-mount the hands are busy with the cooler. Once the paste has set, the SCREWDRIVER (and only it)
        # can be picked up for the corner screws; right-click again puts it down. Every other tool stays refused.
        if mb.button_index == MOUSE_BUTTON_RIGHT and bv.stage == bv.STAGE_PASTE and bv.mount.active:
            if mb.pressed:
                if bv.tools.equipped:
                    var was_screwdriver: bool = bv.tools.selected == Ids.SCREWDRIVER
                    bv._park_tool()
                    if was_screwdriver: bv._set_status("Screwdriver put down. Right-click it on the bench to pick it up again.", 0)
                elif not bv.tools.equipped and bv.mount.time_left <= 0.0 and bv.tools.hit(mb.position, Ids.PASTE_TOOLS) == Ids.SCREWDRIVER:
                    bv.tools.select(Ids.SCREWDRIVER, mb.position)
                    bv._sound("handling.pickup", {"kind": Ids.SCREWDRIVER})
                    bv._set_status("Screwdriver in hand. Click the four corner screws: opposite corners in turn, two passes. Then click the lever.", 0)
            bv.holding = false
            return
        if mb.button_index == MOUSE_BUTTON_RIGHT and (bv.stage == bv.STAGE_PASTE or bv.active_tool != 2 or mb.shift_pressed):
            if mb.pressed:
                var candidate: String = "" if bv.tools.equipped else bv.tools.hit(mb.position,Ids.CLEAN_TOOLS if bv.stage == bv.STAGE_CLEAN else Ids.PASTE_TOOLS)
                var was_equipped: bool = bv.tools.equipped
                if (candidate == "" or mb.shift_pressed) and bv.stage == bv.STAGE_CLEAN and (not bv.tools.equipped or mb.shift_pressed) and bv._may_enter(HandState.CARRYING_HOSE) and bv.tools.grab_hose(mb.position):
                    if was_equipped: bv._sound("handling.putdown",{"kind":bv.tools.selected})
                    bv._sound("hose.grab")
                    bv.holding = false
                    return
                if bv.stage == bv.STAGE_CLEAN and candidate in Ids.CLEAN_TOOLS:
                    bv._select_tool(Ids.TOOL_SLOT[candidate])
                elif bv.stage == bv.STAGE_PASTE and candidate in Ids.PASTE_TOOLS:
                    if bv._equip_tool(candidate,mb.position):
                        bv.wiping = candidate == Ids.CLOTH
                if bv.tools.equipped and bv._may_enter(HandState.THROWING):
                    bv.tools.begin_throw(mb.position)
                elif bv.tools.equipped:
                    # Letting go is always allowed: where a throw is forbidden (mid-mount), the same
                    # right-click sets the tool down gently instead of winding up (_park_tool plays the sound).
                    bv._park_tool()
            else:
                var was_carrying: bool = bv.tools.carrying
                bv.tools.release_throw(bv.event_velocity if Time.get_ticks_msec()-bv.pointer_tick < 140 else Vector2.ZERO)
                if was_carrying: bv._sound("handling.putdown",{"kind":bv.tools.selected,"speed":bv.event_velocity.length()})
                bv.holding = false
            return
        if mb.button_index == MOUSE_BUTTON_LEFT:
            if bv.stage == bv.STAGE_CLEAN and Layout.BENCH_RETRACT.has_point(mb.position):
                bv.holding = false # native bin button owns this click, not the tool/bin-empty hit tests
                return
            # D130: the four corner screws (only while a cooler is pressed on). The click is theirs, not the press.
            if mb.pressed and bv.stage == bv.STAGE_PASTE and bv.mount.active:
                var screw: int = InstallFaults.screw_at(bv._socket_region(), mb.position)
                if screw >= 0:
                    bv.holding = false
                    bv._screw_click(screw)
                    return
            # The cooler is secured by physically clicking its retention lever (there is no button for it).
            if mb.pressed and bv.stage == bv.STAGE_PASTE and bv.mount.active and bv.SECURE_LEVER.has_point(mb.position):
                bv.holding = false
                bv._sound("cooler.lever")
                bv._finish_mount()
                return
            # Loose items: empty hands pick one up; releasing drops it (on the trash can it is binned).
            if bv.stage == bv.STAGE_CLEAN and not mb.pressed and bv.items.carried >= 0:
                var dropped: Dictionary = bv.items.drop(mb.position, ToolRig.TABLE)
                if bool(dropped.get("trashed", false)):
                    bv._sound("item.trash",{"kind":dropped.get("kind","")})
                    bv._set_status("Threw the %s away." % str(dropped.get("kind","item")), 0)
                else:
                    bv._sound("handling.putdown",{"kind":dropped.get("kind",""),"item":"loose"})
                bv.holding = false
                return
            if mb.pressed and bv.stage == bv.STAGE_CLEAN and bv._may_enter(HandState.CARRYING_ITEM) and bv.items.pick(mb.position):
                bv._sound("handling.pickup",{"kind":bv.items.kinds[bv.items.carried],"item":"loose"})
                bv.holding = false
                return
            # The PC's power button, top-right of the case.
            if mb.pressed and bv.stage == bv.STAGE_CLEAN and Layout.BENCH_POWER.has_point(mb.position) \
                    and bv.hand_state() in [HandState.FREE, HandState.USING_TOOL]:
                GameState.set_pc_powered(not bool(GameState.job["pc_powered"]))
                bv._sound("ui.click")
                bv._set_status("PC powered ON: the fans spin up again." if bool(GameState.job["pc_powered"])
                    else "PC powered OFF: fans wind down. Boot, temperature and game tests need power; use the workshop monitor.", 0)
                bv.holding = false
                return
            # In explicit parts mode, tools lying on a component must not steal its click.
            if bv.stage == bv.STAGE_CLEAN and bv.active_tool == 2:
                if mb.pressed:
                    var under: String = bv._part_under(mb.position)
                    if under != "" and not under in bv.access.removed_ids() and bv._may_enter(HandState.DRAGGING_PART):
                        # Unscrewing a fitted part takes time (D89): hold on it; the drag starts when it frees.
                        bv.lift_id = under
                        bv.lift_progress = 0.0
                    elif under != "":
                        bv._begin_part_drag(mb.position)   # a part lying in the tray lifts instantly
                else:
                    if bv.lift_id != "":
                        bv.lift_id = ""
                        bv._set_status("Let go before it was unscrewed: the part stays fitted.", 0)
                    bv._finish_part_drag(mb.position)
                bv.holding = false
                return
            if mb.pressed:
                # With a tool in hand a left click always uses it (it never swaps to a tool lying next to it).
                var resting: String = "" if bv.tools.equipped else bv.tools.hit(mb.position,Ids.CLEAN_TOOLS if bv.stage == bv.STAGE_CLEAN else Ids.PASTE_TOOLS)
                if resting != "" and ToolRig.TABLE.has_point(mb.position) and resting in (Ids.CLEAN_TOOLS if bv.stage == bv.STAGE_CLEAN else Ids.PASTE_TOOLS):
                    if bv.stage == bv.STAGE_CLEAN and resting in Ids.CLEAN_TOOLS:
                        bv._select_tool(Ids.TOOL_SLOT[resting])
                    elif bv.stage == bv.STAGE_PASTE and resting in Ids.PASTE_TOOLS:
                        if bv._equip_tool(resting,mb.position):
                            bv.wiping = resting == Ids.CLOTH
                    # The pickup press is also the beginning of this tool stroke. Waiting for
                    # a second click made every freshly picked-up tool look broken.
                    bv.holding = not bv.mount.active
                    return
            if mb.pressed and bv.stage == bv.STAGE_CLEAN and DustBin.RECT.has_point(mb.position):
                bv._empty_bin()
                bv.holding = false
                return
            if mb.pressed:
                bv.holding = bv._work_rect().has_point(mb.position) and not bv.mount.active
                if bv.holding and bv.stage == bv.STAGE_PASTE and not bv.wiping and not bv.mount_result.is_empty():
                    bv._set_status("The cooler is already mounted. Wipe the paste off with the cloth, or press Clear all paste, before squeezing more.", 2)
            else:
                bv.holding = false
    elif event is InputEventKey:
        var key: InputEventKey = event
        if key.pressed and key.keycode == KEY_Q:
            bv.tools.rotate_held(-1)   # holding the key repeats, so the tool keeps turning
        elif key.pressed and key.keycode == KEY_E:
            bv.tools.rotate_held(1)
        if key.pressed and not key.echo:
            if bv.stage == bv.STAGE_CLEAN:
                if key.keycode == KEY_1:
                    bv._select_tool(DustSim.TOOL_BRUSH)   # a refused switch leaves the highlight alone: _select_tool updates it only when it happens
                elif key.keycode == KEY_2:
                    bv._select_tool(DustSim.TOOL_VACUUM)
                elif key.keycode == KEY_3:
                    bv._select_tool(2)
                elif key.keycode == KEY_4:
                    bv._select_tool(3)
            elif key.keycode == KEY_3:
                bv._select_dispense()
