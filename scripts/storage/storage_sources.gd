# Read-only adapter. These are references/projections, never a second owned-item database.
extends RefCounted
const Data = preload("res://scripts/storage/storage_data.gd")
const Parts = preload("res://scripts/data/service_parts.gd")
const Ram = preload("res://scripts/data/component_data.gd")

static func collect(gs: Node) -> Dictionary:
    var items: Dictionary = {}
    for record: Dictionary in gs.player_inventory:
        var raw_uid: String = str(record.get("uid",""))
        var kind: String = str(record.get("kind",""))
        if raw_uid == "" or record.get("owner","") != "player": continue
        var component: Dictionary = Ram.ram_stick() if kind == "ram" else Parts.component(raw_uid,kind,str(record.get("tier","similar")))
        if component.is_empty(): continue
        var layout: Variant = gs.inventory_layout.get(raw_uid,{})
        var fitted: bool = layout is Dictionary and layout.get("location","drawer") != "drawer"
        var uid: String = "part:"+raw_uid
        items[uid] = {"id":uid,"source_uid":raw_uid,"category":"part","kind":kind,"label":kind.to_upper() if kind == "ram" or kind == "gpu" else kind.capitalize(),
            "model":str(component["display_name"]),"size":component["footprint"],"owner":"Shop property","condition":str(record.get("condition","working")),
            "reserved":fitted,"note":"Fitted on the hardware bench; this shelf space is reserved." if fitted else "Loose stock. Available to the hardware bench and replacement drawer."}
    for kind: String in Data.TOOL_SIZES:
        var uid: String = "tool:kit:"+kind
        items[uid] = {"id":uid,"source_uid":kind,"category":"tool","kind":kind,"label":"Paste syringe" if kind == "syringe" else kind.capitalize(),
            "model":"Included repair kit","size":Data.TOOL_SIZES[kind],"owner":"Shop property","condition":"working","reserved":false,
            "note":"Included repair tool. Its storage space stays reserved while in use."}
    var job: Dictionary = gs.job
    if not job.is_empty() and job.get("state","open") != "done":
        var uid: String = "pc:ticket:"+str(job["id"])+":"+str(job.get("customer_id",""))
        items[uid] = {"id":uid,"source_uid":str(job["id"]),"category":"pc","kind":"pc","label":"Customer PC",
            "model":("Compact PC" if job.get("layout","tower") == "compact" else "Tower PC")+" · "+str(job.get("customer","Customer")),
            "size":Vector2i(7,5) if job.get("layout","tower") == "compact" else Vector2i(8,6),"owner":"Customer property · "+str(job["id"]),
            "condition":"Needs repair" if not job.get("broken_parts",[]).is_empty() else "Awaiting service","reserved":false,
            "note":"Whole PC, including its fitted parts. This remains the customer's property; moving it does not claim or dismantle it."}
    return items
