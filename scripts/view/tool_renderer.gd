# Physical tool silhouettes, shadows and flexible brush drawing. No tool rules.
extends RefCounted
const Rig = preload("res://scripts/bench/tool_rig.gd")
static func draw_tools(canvas: CanvasItem, rig: RefCounted, visible: Array) -> void:
    var order: Array = visible.duplicate()
    if rig.selected in order:
        order.erase(rig.selected)
        order.append(rig.selected)
    if "vacuum" in order: draw_hose(canvas, rig)
    for id: String in order:
        var motion: RefCounted = rig.motions[id]
        var body: RefCounted = rig.bodies[id]
        var height: float = body.height if body.active else (motion.lift*5.0 if id == rig.selected and rig.equipped and not rig.active else 0.0)
        canvas.draw_set_transform(motion.center+Vector2(4,7),motion.angle)
        canvas.draw_line(Vector2(-18,24),Vector2(19,-32),Color(0,0,0,0.35),17)
        canvas.draw_set_transform(motion.center-Vector2(0,height),motion.angle)
        var tip: Vector2 = Rig.TIP
        if id == "vacuum":
            canvas.draw_line(tip,Vector2(21,-31),Color("899aa9"),15)
            canvas.draw_line(Vector2(10,-18),Vector2(21,-31),Color("3d657d"),20)
            canvas.draw_circle(tip,10,Color("cad4da"))
            canvas.draw_circle(tip,6,Color("142530"))
        elif id == "brush":
            canvas.draw_line(tip+Vector2(0,-16),Vector2(18,-34),Color("ba814c"),13)
            canvas.draw_line(tip+Vector2(-20,-13),tip+Vector2(20,-13),Color("8a9397"),9)
            var roots: PackedVector2Array = rig.brush.roots()
            var tips: PackedVector2Array = rig.brush.tips()
            for i in range(roots.size()):
                var root: Vector2 = tip+roots[i]
                var end: Vector2 = tip+tips[i]
                canvas.draw_polyline(PackedVector2Array([root,root.lerp(end,0.45)+rig.brush.bend*0.12,end]),Color("e8d39b") if i%2 == 0 else Color("ba9c68"),2)
        elif id == "pick":
            canvas.draw_line(Vector2(-2,4),Vector2(20,-30),Color("cb9b53"),10)
            canvas.draw_polyline(PackedVector2Array([Vector2(-2,4),tip,tip+Vector2(-6,1)]),Color("dce0df"),3)
        elif id == "cloth":
            var skew: float = rig.brush.bend.x*0.2
            canvas.draw_colored_polygon(PackedVector2Array([tip+Vector2(-24,-16),tip+Vector2(22,-13),tip+Vector2(25+skew,17),tip+Vector2(-22,14)]),Color("ddd6b6"))
            for i in range(4): canvas.draw_line(tip+Vector2(-18+i*11,-11),tip+Vector2(-16+i*11,12),Color("b4ac90"),1)
        else:
            canvas.draw_line(Vector2(-9,11),Vector2(13,-19),Color("b9deea"),13)
            canvas.draw_line(Vector2(13,-19),Vector2(24,-34),Color("96a4ae"),4)
            canvas.draw_line(Vector2(16,-38),Vector2(31,-28),Color("d5dde2"),4)
            canvas.draw_line(Vector2(-9,11),tip,Color("cbd3d8"),4)
        canvas.draw_set_transform(Vector2.ZERO)
        if id != rig.selected or not rig.equipped:
            canvas.draw_string(ThemeDB.fallback_font,motion.center+Vector2(-22,48),id,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("c6d7dd"))


# The vacuum hose: a see-through corrugated tube following the simulated chain of points (drawn
# through a smooth curve), with the dust it carries visible inside on its way to the bin.
const HOSE_WIDTH: float = 8.0
static func draw_hose(canvas: CanvasItem, rig: RefCounted) -> void:
    var raw: PackedVector2Array = rig.hose.pos
    if raw.size() < 2: return
    var points: PackedVector2Array = smooth_curve(raw, 4)
    var lifted: bool = rig.hose.pinned()
    canvas.draw_set_transform(Vector2(7,11) if lifted else Vector2(3,5),0.0)
    canvas.draw_polyline(points,Color(0,0,0,0.20 if lifted else 0.26),HOSE_WIDTH+1.0,true)
    canvas.draw_set_transform(Vector2.ZERO)
    canvas.draw_polyline(points,Color(0.72,0.84,0.92,0.30),HOSE_WIDTH,true)
    # Dust inside the tube.
    var flow: RefCounted = rig.flow
    for k in range(flow.count()):
        var at: Vector2 = rig.hose.point_along(flow.t[k])
        var ahead: Vector2 = rig.hose.point_along(minf(1.0,flow.t[k]+0.02))
        var along: Vector2 = (ahead-at).normalized()
        var specks: int = clampi(ceili(flow.amount[k]/2.0),1,4)
        for j in range(specks):
            var wobble: Vector2 = along.orthogonal()*sin(float(k*7+j*3))*1.6
            canvas.draw_circle(at-along*float(j)*2.6+wobble,1.2+minf(1.4,flow.amount[k]*0.12),Color("8d867b"))
    # Rims, ribs and a highlight make it read as a round, clear tube.
    var left := PackedVector2Array()
    var right := PackedVector2Array()
    var shine := PackedVector2Array()
    for i in range(points.size()):
        var a: Vector2 = points[maxi(0,i-1)]
        var b: Vector2 = points[mini(points.size()-1,i+1)]
        var side: Vector2 = (b-a).normalized().orthogonal()
        left.append(points[i]+side*HOSE_WIDTH*0.5)
        right.append(points[i]-side*HOSE_WIDTH*0.5)
        shine.append(points[i]+side*HOSE_WIDTH*0.2)
        if i % 3 == 0:
            canvas.draw_line(points[i]-side*HOSE_WIDTH*0.45,points[i]+side*HOSE_WIDTH*0.45,Color(0.85,0.93,1.0,0.16),1.0)
    canvas.draw_polyline(left,Color(0.80,0.90,0.97,0.55),1.0,true)
    canvas.draw_polyline(right,Color(0.30,0.40,0.48,0.55),1.0,true)
    canvas.draw_polyline(shine,Color(1,1,1,0.30),1.0,true)


# A smooth curve through `points` (Catmull-Rom), with `steps` drawn segments per link. Drawing only.
static func smooth_curve(points: PackedVector2Array, steps: int) -> PackedVector2Array:
    var out := PackedVector2Array()
    var n: int = points.size()
    for i in range(n - 1):
        var p0: Vector2 = points[maxi(0, i - 1)]
        var p1: Vector2 = points[i]
        var p2: Vector2 = points[i + 1]
        var p3: Vector2 = points[mini(n - 1, i + 2)]
        for k in range(steps):
            var t: float = float(k) / float(steps)
            var t2: float = t * t
            var t3: float = t2 * t
            out.append(0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
    out.append(points[n - 1])
    return out
