# Optional native PhysicsServer2D stress profile; no pass/fail timing thresholds.
# Run: godot --headless --path . --script res://tools/profile_salvage_physics.gd
extends SceneTree
const Session = preload("res://scripts/salvage/salvage_session.gd")
const World = preload("res://scripts/salvage/salvage_physics.gd")

func _initialize() -> void: call_deferred("run")

func report(label: String, samples: Array) -> void:
    samples.sort()
    var total: float = 0
    for value: float in samples: total += value
    print("SALVAGE PHYSICS %s mean_ms=%.3f p50_ms=%.3f p95_ms=%.3f p99_ms=%.3f max_ms=%.3f"%[label,total/samples.size(),samples[ceili(samples.size()*0.5)-1],samples[ceili(samples.size()*0.95)-1],samples[ceili(samples.size()*0.99)-1],samples[-1]])

func run() -> void:
    Engine.max_fps = 60
    for count: int in [20,50,100]:
        var s := Session.new()
        s.depart("mixed")
        s.pile.objects.clear()
        s.pile.order.clear()
        var rng := RandomNumberGenerator.new()
        rng.seed = 785
        for i in range(count):
            s.pile.add("box",Vector2(80+(i%10)*52,580-(i/10)*38),Vector2(34,30),"stress%d"%i,rng)
        var w := World.new()
        root.add_child(w)
        w.sync(s,Vector2.ZERO)
        var samples: Array = []
        var max_pairs: int = 0
        var max_active: int = 0
        for frame in range(240):
            await physics_frame
            var started: int = Time.get_ticks_usec()
            w.capture()
            w.sync(s,Vector2.ZERO)
            await process_frame
            samples.append(float(Time.get_ticks_usec()-started)/1000.0)
            max_pairs = maxi(max_pairs,int(Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)))
            max_active = maxi(max_active,int(Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)))
        report("%d bodies / fall-and-settle"%count,samples)
        var sleeping: int = 0
        for uid: String in w.bodies:
            if w.bodies[uid].sleeping: sleeping += 1
        print("SALVAGE PHYSICS count=%d sleeping=%d peak_active=%d peak_pairs=%d"%[count,sleeping,max_active,max_pairs])
        samples.clear()
        for frame in range(60):
            await physics_frame
            var started: int = Time.get_ticks_usec()
            w.capture()
            w.sync(s,Vector2.ZERO)
            await process_frame
            samples.append(float(Time.get_ticks_usec()-started)/1000.0)
        report("%d bodies / late-settle"%count,samples)
        samples.clear()
        var uid: String = "stress%d"%mini(count-1,14)
        s.start_effort(uid,"grab")
        w.remember_grab(uid,w.bodies[uid].position)
        for frame in range(120):
            await physics_frame
            var started: int = Time.get_ticks_usec()
            var target := Vector2(320+sin(frame*0.06)*190,300)
            w.capture()
            s.step(1.0/60.0,target)
            w.sync(s,target)
            await process_frame
            samples.append(float(Time.get_ticks_usec()-started)/1000.0)
        report("%d bodies / pulling"%count,samples)
        w.free()
        await physics_frame
    print("Salvage physics profile finished; physics-phase wall time (physics_frame to process_frame, includes sync/dispatch), headless; no GPU or FPS claim.")
    quit()
