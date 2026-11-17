# Read-only adapter. These are references/projections, never a second owned-item database.
extends RefCounted
const Data = preload("res://scripts/storage/storage_data.gd")

static func collect(gs: Node) -> Dictionary:
    var items: Dictionary = {}
    # The canonical component projection from GameState (RAM, CPU, GPU, cooler): the rack never
    # keeps its own per-kind dispatch, which silently dropped the CPU (BUGS.md B17).
    var projected: Dictionary = {}
    for built: Dictionary in gs.inventory_components():
        projected[str(built.get("id",""))] = built
    for record: Dictionary in gs.player_inventory:
        var raw_uid: String = str(record.get("uid",""))
        var kind: String = str(record.get("kind",""))
        if raw_uid == "" or record.get("owner","") != "player": continue
        var component: Dictionary = projected.get(raw_uid,{})
        if component.is_empty(): continue
        var layout: Variant = gs.inventory_layout.get(raw_uid,{})
        var fitted: bool = layout is Dictionary and layout.get("location","drawer") != "drawer"
        var uid: String = "part:"+raw_uid
        items[uid] = {"id":uid,"source_uid":raw_uid,"category":"part","kind":kind,"label":kind.to_upper() if kind in ["ram","gpu","cpu"] else kind.capitalize(),
            "model":str(component["display_name"]),"size":component["footprint"],"owner":"Shop property","condition":str(record.get("condition","working")),
            "reserved":fitted,"note":"Fitted on the hardware bench; this shelf space is reserved." if fitted else "Loose stock. Available to the hardware bench and replacement drawer."}
    for kind: String in Data.TOOL_SIZES:
        var uid: String = "tool:kit:"+kind
        items[uid] = {"id":uid,"source_uid":kind,"category":"tool","kind":kind,"label":"Paste syringe" if kind == "syringe" else kind.capitalize(),
            "model":"Included repair kit","size":Data.TOOL_SIZES[kind],"owner":"Shop property","condition":"working","reserved":false,
            "note":"Included repair tool. Its storage space stays reserved while in use."}
    var session: Node = gs.get_node_or_null("/root/NightSession")
    var jobs: Array = session.jobs(gs) if session != null else [gs.job]
    for job: Dictionary in jobs:
        var marker: Dictionary = job.get("hardware_trial",{}).get("night_session",{})
        var pc_id: String = str(marker.get("pc","legacy:"+str(job.get("id",""))+":"+str(job.get("customer_id",""))))
        if job.is_empty() or job.get("state","open") == "done" or pc_id == "": continue
        var uid: String = "pc:"+pc_id
        items[uid] = {"id":uid,"source_uid":str(job["id"]),"category":"pc","kind":"pc","label":"Customer PC",
            "model":("Compact PC" if job.get("layout","tower") == "compact" else "Tower PC")+" · "+str(job.get("customer","Customer")),
            "size":Vector2i(7,5) if job.get("layout","tower") == "compact" else Vector2i(8,6),"owner":"Customer property · "+str(job["id"]),
            "condition":"Awaiting service","reserved":false,
            "note":"Ticket %s. Whole customer PC, including fitted parts. Drag it into the workshop slot in the room to work on it."%str(job["id"])}
    return items
