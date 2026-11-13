# Silent sound contracts, full-bin recovery UI, hose replay and stage/scene lifecycle.
extends SceneTree
const Feedback = preload("res://scripts/audio/audio_feedback.gd")
const Cues = preload("res://scripts/data/audio_cues.gd")
const Rig = preload("res://scripts/bench/tool_rig.gd")
const Bin = preload("res://scripts/bench/dust_bin.gd")
var audio: Node
var checks: int = 0
var failed: int = 0
func _initialize() -> void: call_deferred("run_checks")
func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed += 1
        push_error("FAIL: "+label)
func has_loop(owner: Object, id: String) -> bool:
    return audio.loops.has("%d:%s"%[owner.get_instance_id(),id])
func run_checks() -> void:
    audio = root.get_node("AudioFeedback")
    test_contract()
    test_hose()
    var gs: Node = root.get_node("GameState")
    var original: String = gs.save_path
    gs.save_path="user://audio_vacuum_test_only.json"
    gs.new_game()
    var bench: Node=load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_physics_process(false)
    var point: Vector2=bench.dust.b_center[0]
    bench.scripted_pointer=point
    bench._select_tool(0)
    bench.tools.flow.add(Bin.CAPACITY)
    bench.dust.vac_ramp=1.0
    bench._after_dust_step(1.0,point)
    var before: float=bench.dust.remaining_fraction()
    bench.holding=true
    for frame in range(60):bench._physics_process(1.0/60.0)
    check(bench.dust.remaining_fraction()==before,"full bin intentionally blocks further dust extraction")
    check(bench.vacuum_status.text.contains("BIN FULL") and not bench.empty_bin_button.disabled,"full vacuum has persistent recovery banner and enabled action")
    check(not has_loop(bench,"vacuum.motor"),"full bin stops vacuum audio loop instead of sounding operational")
    bench._select_tool(1)
    bench._select_tool(0)
    check(bench.vacuum_status.text.contains("BIN FULL"),"switching tools cannot overwrite full-bin state")
    var full_cues: int = 0
    for event: Dictionary in audio.history:
        if event["id"] == "bin.full" and event["event"] == "cue": full_cues += 1
    check(full_cues==1,"bin filling requests one warning rather than a cue every frame")
    bench.empty_bin_button.pressed.emit()
    check(bench.bin.fill==0.0 and bench.vacuum_status.text.contains("Vacuum ready"),"Empty bin button clears blockage without new ticket/reset")
    bench.holding=true
    for frame in range(180):bench._physics_process(1.0/60.0)
    check(bench.dust.remaining_fraction()<before,"vacuum resumes extracting dirt after emptying")
    check(has_loop(bench,"vacuum.motor"),"operating vacuum exposes a single motor loop")
    bench.holding=false
    bench._physics_process(1.0/60.0)
    check(not has_loop(bench,"vacuum.motor"),"releasing use stops its loop")
    # Visible UI buttons do not overlap each other after grouping tools/maintenance.
    var buttons: Array=[]
    for child: Node in bench.get_children():
        if child is Button and child.visible:buttons.append(child)
    var overlap: bool=false
    for i in range(buttons.size()):
        for j in range(i+1,buttons.size()):
            if buttons[i].get_global_rect().intersects(buttons[j].get_global_rect()):overlap=true
    check(not overlap,"cleaning controls are separate non-overlapping groups")
    bench._select_stage(1)
    check(not has_loop(bench,"pc.fan"),"stage change releases the previous scene's machine loops")
    check(bench.material_button.position.y<bench.mount_button.position.y and bench.complete_button.position.y==bench.mount_button.position.y,"paste controls follow material/tool then mount/complete order")
    var cpu: Vector2=bench.PASTE_ORIGIN+Vector2(25,25)*bench.PASTE_CELL
    bench.scripted_pointer=cpu
    bench._select_dispense()
    bench.holding=true
    for frame in range(30):bench._physics_process(1.0/60.0)
    check(has_loop(bench,"paste.squeeze"),"actual syringe dispensing emits a material-aware loop")
    bench.holding=false
    bench._physics_process(1.0/60.0)
    check(not has_loop(bench,"paste.squeeze"),"syringe release ends dispensing loop")
    bench.wipe_button.set_pressed_no_signal(true)
    bench._on_wipe_toggled()
    bench.holding=true
    bench._physics_process(1.0/60.0)
    check(has_loop(bench,"cloth.wipe"),"wiping has its own audio hook")
    bench.mount.start()
    bench._cancel_unlocked_mount()
    check(not bench.mount.active and bench.mount_result.is_empty() and gs.job["paste_grade"]=="","leaving an unfinished mount cannot bypass physical lever or grant a grade")
    var prefix: String="%d:"%bench.get_instance_id()
    bench.free()
    var orphan: bool=false
    for key: String in audio.loops:
        if key.begins_with(prefix):orphan=true
    check(not orphan,"leaving bench releases every owned loop")
    check(audio.get_child_count()==0,"silent foundation instantiates no sound players or placeholder beeps")
    for suffix in ["", ".bak", ".tmp"]:DirAccess.remove_absolute(gs.save_path+suffix)
    gs.save_path=original
    gs.new_game(false)
    print("Audio and vacuum checks: %d, failures: %d"%[checks,failed])
    quit(1 if failed else 0)

func test_contract() -> void:
    for bus: String in Cues.BUSES:
        check(AudioServer.get_bus_index(bus)>=0,"mixer bus exists: "+bus)
    var service:=Feedback.new()
    root.add_child(service)
    var owner:=Node.new()
    root.add_child(owner)
    var time: Array=[0]
    service.clock_msec=func() -> int:return int(time[0])
    check(service.request(owner,"handling.pickup",{"kind":"ram"}),"known one-shot cue is accepted")
    check(not service.request(owner,"handling.pickup"),"one-shot cooldown prevents duplicate chatter")
    time[0]=100
    check(service.request(owner,"handling.pickup"),"cooldown permits later action")
    check(not service.request(owner,"unknown") and not service.request(owner,"vacuum.motor"),"invalid cue/misused loop is rejected")
    for frame in range(120):service.set_loop(owner,"vacuum.motor",true,{"ramp":1.0})
    check(service.loops.size()==1,"one continuous action creates one voice lifecycle, not one per frame")
    service.set_loop(owner,"vacuum.motor",true,{"ramp":0.5})
    check(service.loops.size()==1,"parameter updates do not start duplicate loops")
    service.stop_owner(owner)
    check(service.loops.is_empty(),"owner cleanup stops loops")
    service.set_loop(owner,"brush.contact",true)
    owner.free()
    service._process(0)
    check(service.loops.is_empty(),"forgotten cleanup recovers when owner is freed")
    for i in range(200):
        time[0]+=100
        service.request(service,"ui.click")
    check(service.history.size()<=service.HISTORY_LIMIT,"debug event history stays bounded")
    service.free()

func test_hose() -> void:
    var rig:=Rig.new()
    rig.select("vacuum",Vector2(300,300))
    rig.hose_obstacles=[{"center":Vector2(300,345),"half":Vector2(100,13),"angle":0.0,"corner_radius":0.0},{"center":Vector2(237,217),"half":Vector2(37,37),"angle":0.0,"corner_radius":0.0}]
    var path:Array=[Vector2(250,340),Vector2(160,200),Vector2(260,200),Vector2(550,430),Vector2(600,520),Vector2(550,220),Vector2(590,450),Vector2(450,300)]
    var worst: int=0
    for frame in range(960):
        var mouse:Vector2=path[(frame/60)%path.size()]+Vector2(sin(frame*0.14)*40,cos(frame*0.17)*30)
        if frame%120==0:rig.rotate_steps(6)
        rig.step(1.0/60.0,mouse,false)
        worst=maxi(worst,rig.hose.self_crossings())
    check(worst==0,"rapid path/rotation replay has no self-crossing hose loops (baseline worst 10)")
    var anchor: Vector2=rig.hose.anchor
    var pin: int=8
    rig.hose_grab=pin
    var target: Vector2=anchor+Vector2(-100,10)
    for frame in range(60):rig.step(1.0/60.0,target,false)
    check(rig.hose.pos[pin].distance_to(target)<1.0,"untangling preserves the player's pinned section")
    var pinned_worst: int = 0
    rig.release_hose()
    rig.hose_clamp = pin
    for frame in range(480):
        rig.step(1.0/60.0,path[(frame/60)%path.size()],false)
        pinned_worst=maxi(pinned_worst,rig.hose.self_crossings())
    check(pinned_worst==0,"clamped hose also recovers without self-crossing loops")
