# Outside the shop (0.53.0, D161): the street at night. The shop's door leads back in to the counter; your
# van drives to the salvage dump. More places can open here later (the parts supplier is a "later:" spot).
extends "res://scripts/rooms/room_view.gd"


func _draw_placeholder() -> void:
    draw_rect(Rect2(0, 0, 1280, 470), Color("0d1320"))       # night sky over the street
    draw_rect(Rect2(880, 90, 400, 380), Color("2a2f36"))     # the shop's front
    draw_rect(Rect2(0, 520, 1280, 200), Color("1a1d22"))     # the road
