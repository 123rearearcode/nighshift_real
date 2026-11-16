# RULES ONLY (pure): a customer's ticket as one record (D135, Wave 3 session 3.1), and its pickup state
# (D134). A ticket is opened whenever a customer makes a request. Today every ticket is a repair; the
# build request is designed (D140) but not built. The record is DERIVED from the job each time, so it can
# never disagree with the PC; only the pickup flags are stored, in job["ticket"].
#   ready  = the player's own "ready for pickup" sticker. A note: it changes no rule.
#   called = the customer was called and collects NEXT MORNING (the morning itself is session 3.2).
extends RefCounted

const PartStates = preload("res://scripts/rules/part_states.gd")

const REPAIR := "repair"
const BUILD := "build"
const REQUESTS: Array = [REPAIR, BUILD]

const OPEN := "open"
const READY := "ready"
const CALLED := "called"
const DONE := "done"

# Menu actions, shared by the room and the workbench header.
const TOGGLE_READY := "toggle_ready"
const TOGGLE_CALL := "toggle_call"


static func sanitize(raw: Variant) -> Dictionary:
    var out: Dictionary = {"request": REPAIR, "ready": false, "called": false}
    if raw is Dictionary:
        var request: String = str(raw.get("request", REPAIR))
        if request in REQUESTS: out["request"] = request
        var ready: Variant = raw.get("ready", false)
        var called: Variant = raw.get("called", false)
        if ready is bool: out["ready"] = ready
        if called is bool: out["called"] = called
    return out


static func flags(job: Dictionary) -> Dictionary:
    return sanitize(job.get("ticket", {}))


# One status word: done > called > ready > open.
static func status(job: Dictionary) -> String:
    if str(job.get("state", "open")) == "done": return DONE
    var f: Dictionary = flags(job)
    if bool(f["called"]): return CALLED
    if bool(f["ready"]): return READY
    return OPEN


static func status_text(job: Dictionary) -> String:
    match status(job):
        DONE: return "Collected"
        CALLED: return "Customer called · collects next morning"
        READY: return "Marked ready for pickup"
    return "Open · in the shop"


# Short tag for drawing on the PC and in the header ("" when there is nothing to show).
static func badge(job: Dictionary) -> String:
    match status(job):
        CALLED: return "CALLED"
        READY: return "READY"
    return ""


# The ticket's objects (D135). `customer` is the customer data record (customers.gd).
static func record(job: Dictionary, customer: Dictionary) -> Dictionary:
    var needs: Dictionary = customer.get("needs", {})
    if needs.has("stated"): needs = needs["stated"]
    return {
        "id": str(job.get("id", "")),
        "request": flags(job)["request"],
        "customer": {"name": str(job.get("customer", customer.get("name", "Customer"))), "profession": str(customer.get("profession", "")), "uses": str(customer.get("uses", ""))},
        "machine": {"layout": str(job.get("layout", "tower")), "parts": PartStates.summary(job)},
        "symptoms": str(job.get("complaint", "")),
        "requirements": needs,
        "terms": {"payout": int(job.get("payout", 0)), "collection": str(customer.get("patience", ""))},
        "status": status(job),
    }


static func requirement_text(needs: Dictionary, games: Dictionary) -> String:
    var out: Array = []
    if bool(needs.get("boots", false)): out.append("a working PC")
    if bool(needs.get("quiet", false)): out.append("quiet")
    for target: Dictionary in needs.get("games", []):
        out.append("%s at %d FPS or more" % [str(games.get(str(target.get("game_id", "")), str(target.get("game_id", "")))), int(target.get("min_fps", 0))])
    return ", ".join(out) if not out.is_empty() else "a working PC"


# Plain text of the whole ticket, for the ticket window.
static func text(job: Dictionary, customer: Dictionary, games: Dictionary) -> String:
    var r: Dictionary = record(job, customer)
    var lines: Array = [
        "TICKET %s · %s" % [r["id"], "PC repair" if r["request"] == REPAIR else "PC build"],
        "Status: %s" % status_text(job),
        "",
        "Customer: %s%s" % [r["customer"]["name"], (" (" + str(r["customer"]["profession"]) + ")") if str(r["customer"]["profession"]) != "" else ""],
        "Uses it for: %s" % r["customer"]["uses"] if str(r["customer"]["uses"]) != "" else "",
        "What they say: %s" % r["symptoms"],
        "Wants: %s" % requirement_text(r["requirements"], games),
        "Pay on collection: $%d" % int(r["terms"]["payout"]),
        "Collection: %s" % r["terms"]["collection"] if str(r["terms"]["collection"]) != "" else "",
        "",
        "Machine: %s PC · %s" % [str(r["machine"]["layout"]).capitalize(), r["machine"]["parts"]],
    ]
    var kept: Array = []
    for i in range(lines.size()):
        # optional lines are "" when absent; keep the two deliberate blank separators (index 2 and 9)
        if str(lines[i]) != "" or i in [2, 9]: kept.append(lines[i])
    return "\n".join(kept)


# The right-click menu: [[action, label], ...]. Empty for a collected ticket.
static func menu(job: Dictionary) -> Array:
    if status(job) == DONE: return []
    var f: Dictionary = flags(job)
    return [
        [TOGGLE_READY, "Remove the ready sticker" if bool(f["ready"]) else "Mark ready for pickup (sticker)"],
        [TOGGLE_CALL, "Cancel the call" if bool(f["called"]) else "Call the customer to pick it up"],
    ]


# Applies one menu action to a COPY of the flags. Returns {ok, flags, message}.
static func apply(job: Dictionary, action: String) -> Dictionary:
    var f: Dictionary = flags(job)
    if status(job) == DONE: return {"ok": false, "flags": f, "message": "This ticket is already collected."}
    var who: String = str(job.get("customer", "The customer"))
    if action == TOGGLE_READY:
        f["ready"] = not bool(f["ready"])
        return {"ok": true, "flags": f, "message": ("Ready sticker on %s's PC. It is your own note: nobody has been called." % who) if f["ready"] else "Ready sticker removed."}
    if action == TOGGLE_CALL:
        f["called"] = not bool(f["called"])
        return {"ok": true, "flags": f, "message": ("You called %s. They collect the PC next morning, exactly as you leave it tonight. You can cancel the call until then." % who) if f["called"] else "Call cancelled: %s will not come in the morning." % who}
    return {"ok": false, "flags": f, "message": "Unknown ticket action."}
