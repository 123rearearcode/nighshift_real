# Correctness of idle caches/wake conditions; no machine-dependent timing assertions.
extends "res://tools/test_support.gd"
const Hose = preload("res://scripts/bench/hose_sim.gd")
const Paste = preload("res://scripts/bench/paste_sim.gd")
const Renderer = preload("res://scripts/view/paste_renderer.gd")

func _initialize() -> void: call_deferred("run")

func settle(hose: RefCounted, obstacles: Array = [], pin_index: int = -1, target: Vector2 = Vector2(160,100)) -> void:
    for frame in range(80): hose.step(1.0/60.0,Vector2(40,40),Vector2(400,80),obstacles,pin_index,target)

func run() -> void:
    var hose := Hose.new()
    hose.reset(Vector2(40,40),Vector2(400,80))
    settle(hose,[],8)
    check(hose.sleeping,"clamped hose sleeps with fixed constraints")
    var solves: int = hose.solver_steps
    var points: PackedVector2Array = hose.pos.duplicate()
    settle(hose,[],8)
    check(hose.solver_steps == solves and hose.pos == points,"sleeping hose skips solver without creeping")
    hose.step(1.0/60.0,Vector2(40,40),Vector2(402,80),[],8,Vector2(160,100))
    check(not hose.sleeping,"nozzle movement wakes clamped hose")
    settle(hose,[],8)
    for i in range(1,12): hose.step(1.0/60.0,Vector2(40,40),Vector2(400+i*0.05,80),[],8,Vector2(160,100))
    check(hose.solver_steps > solves+1,"sub-threshold nozzle movement accumulates and wakes")
    settle(hose,[],8)
    hose.step(1.0/60.0,Vector2(40,40),Vector2(400,80),[],8,Vector2(161,100))
    check(not hose.sleeping,"clamp movement wakes hose")
    settle(hose,[],8)
    hose.pin = -1
    hose.step(1.0/60.0,Vector2(40,40),Vector2(400,80),[])
    check(not hose.sleeping,"unclipping wakes hose")
    settle(hose)
    hose.set_length(760)
    hose.step(1.0/60.0,Vector2(40,40),Vector2(400,80),[])
    check(not hose.sleeping,"hose length upgrade wakes solver")
    settle(hose)
    hose.step(1.0/60.0,Vector2(41,40),Vector2(400,80),[])
    check(not hose.sleeping,"anchor change wakes solver")
    var obstacles: Array = [{"center":Vector2(700,500),"half":Vector2(20,20),"angle":0.0},{"center":Vector2(800,500),"half":Vector2(20,20),"angle":0.0}]
    settle(hose,obstacles)
    obstacles[0]["center"].x += 1
    obstacles[1]["center"].x -= 1
    hose.step(1.0/60.0,Vector2(40,40),Vector2(400,80),obstacles)
    check(not hose.sleeping,"individual obstacle changes wake even when sums match")
    settle(hose)
    hose.reset(Vector2(40,40),Vector2(400,80))
    check(not hose.sleeping,"reset invalidates sleeping state")
    test_paste()
    var gs: Node = root.get_node("GameState")
    use_test_save(gs,"performance_test_only.json")
    gs.new_game(false)
    var bench: Node = load("res://scenes/bench.tscn").instantiate()
    root.add_child(bench)
    bench.set_process(false)
    bench.set_physics_process(false)
    bench.tools.park()
    bench.scripted_pointer = Vector2(300,300)
    bench._refresh_vacuum_status()
    var updates: int = bench.vacuum_ui_updates
    for frame in range(10): bench._refresh_vacuum_status()
    check(bench.vacuum_ui_updates == updates,"unchanged bin does not rewrite controls")
    bench.bin.fill = bench.bin.CAPACITY
    bench._refresh_vacuum_status()
    check("FULL" in bench.vacuum_status.text and not bench.empty_bin_button.disabled,"full bin updates warning and empty action")
    bench.bin.fill = 0
    bench._refresh_vacuum_status()
    check(bench.empty_bin_button.disabled and not "FULL" in bench.vacuum_status.text,"empty bin clears warning")
    await process_frame
    await process_frame
    var draws: int = bench.backdrop.draw_count
    for frame in range(4):
        bench.queue_redraw()
        await process_frame
    check(bench.backdrop.draw_count == draws,"animated parent redraw does not rebuild static case")
    bench._select_stage(1)
    bench._step_paste(1.0/60.0,Vector2.ZERO)
    check(not bench.backdrop.clean and bench.complete_button.visible,"paste stage updates backdrop and controls")
    bench._select_stage(0)
    bench._select_stage(1)
    bench._step_paste(1.0/60.0,Vector2.ZERO)
    check(bench.complete_button.visible,"returning to paste invalidates UI cache")
    bench.free()
    restore_save(gs)
    finish("Performance contracts")

func test_paste() -> void:
    var paste := Paste.new()
    var first: Dictionary = paste.measure()
    var scans: int = paste.measure_scans
    first["coverage"] = 12
    check(paste.measure()["coverage"] == 0 and paste.measure_scans == scans,"cached measurement is isolated from caller writes")
    paste.deposit(25,25,100)
    var covered: Dictionary = paste.measure()
    check(paste.measure_scans == scans+1 and covered["coverage"] > 0,"deposit invalidates measurement")
    var revision: int = paste.revision
    paste.step(0.001)
    check(paste.revision > revision,"flow invalidates measurement")
    revision = paste.revision
    paste.wipe(25,25,20,1)
    check(paste.revision > revision,"wipe invalidates measurement")
    var image := Image.create_empty(Paste.GRID,Paste.GRID,false,Image.FORMAT_RGBA8)
    var texture := ImageTexture.create_from_image(image)
    Renderer.refresh_image(paste,image,texture,false,false)
    Renderer.refresh_image(paste,image,texture,false,false)
    check(texture.get_meta("paste_uploads") == 1,"unchanged paste skips texture upload")
    paste.material = "toothpaste"
    Renderer.refresh_image(paste,image,texture,false,false)
    check(texture.get_meta("paste_uploads") == 2,"material switch invalidates texture")
    Renderer.refresh_image(paste,image,texture,true,true)
    var fresh := Image.create_empty(Paste.GRID,Paste.GRID,false,Image.FORMAT_RGBA8)
    var fresh_texture := ImageTexture.create_from_image(fresh)
    Renderer.refresh_image(paste,fresh,fresh_texture,true,true)
    check(image.get_data() == fresh.get_data(),"cached renderer matches uncached output after overlay change")
    paste.clear()
    Renderer.refresh_image(paste,image,texture,true,true)
    check(paste.measure()["coverage"] == 0 and texture.get_meta("paste_uploads") == 4,"clear invalidates measure and texture")
