# Physical tool silhouettes, shadows and flexible brush drawing. No tool rules.
extends RefCounted
const Rig = preload("res://scripts/bench/tool_rig.gd")
static func draw_tools(canvas: CanvasItem, rig: RefCounted, visible: Array) -> void:
    var order: Array = visible.duplicate()
    if rig.selected in order:
        order.erase(rig.selected)
        order.append(rig.selected)
    for id: String in order:
        if id == rig.selected and rig.equipped and not Rig.TABLE.has_point(rig.point): continue
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
