# The workshop, behind the counter (0.53.0, D161). Every station stands here: the repair bench (cleaning
# and thermal service), the hardware board (parts in and out), the diagnostic monitor, and the testing
# bay in the corner. The stock room door leads to the PC shelves, where you choose which PC goes on the
# bench. Clicking a station walks up to it with the PC that is on the bench.
#
# Scam hook kept open: the testing bay's "mark" and the shelves are where untested parts can be relabelled
# before they go into a customer's PC (D158); nothing here changes that.
extends "res://scripts/rooms/room_view.gd"

const TicketMenu = preload("res://scripts/night/ticket_menu.gd")


func _bench_pc() -> String:
    return str(GameState.job.get("hardware_trial", {}).get("night_session", {}).get("pc", ""))


func _refresh_room() -> void:
    var on_bench: String = TicketMenu.identity_text(GameState.job) if _bench_pc() != "" else "empty: bring a PC from the stock room"
    for name: String in ["RepairBench", "HardwareBoard", "Monitor"]:
        var spot: Hotspot = hotspot(name)
        if spot != null: spot.set_badge(on_bench if name == "RepairBench" else "")
    var bay: Hotspot = hotspot("TestingBay")
    if bay != null: bay.set_badge("%d part%s" % [GameState.bay_parts().size(), "" if GameState.bay_parts().size() == 1 else "s"])


func _draw_placeholder() -> void:
    draw_rect(Rect2(180, 470, 1100, 30), Color("4a4038"))   # the long workbench
