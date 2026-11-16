# RULES ONLY (pure): the morning after a night (D136, Wave 3 session 3.2). Which hidden mistakes a
# customer notices at pickup and which only come back later (user, 16 November 2026: film left on,
# pop-ups and loud fans show at pickup; loose GPU screws and an unstable overclock come back after a
# few days), what they pay, and how the report words it. All numbers are trial proposals.
extends RefCounted

const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")

# Felt only after a few days at home. Everything else is felt at pickup.
const DELAYED: Array = [InstallFaults.GPU_LOOSE, Overclock.UNSTABLE, Overclock.CRASHING]
const COMEBACK_NIGHTS: int = 2          # a delayed fault brings the customer back after this many mornings
const COMEBACK_TRUST_PER_10: int = 1    # trust lost per 10 annoyance points of the faults that came back
const NO_BOOT_TRUST: int = -10          # handed back a PC that does not even start


static func split(faults: Array) -> Dictionary:
    var now: Array = []
    var later: Array = []
    for f: Variant in faults:
        if str(f) in DELAYED: later.append(str(f))
        else: now.append(str(f))
    return {"now": now, "later": later}


static func annoyance(faults: Array) -> float:
    return InstallFaults.annoyance(faults) + Malware.annoyance(faults) + Overclock.annoyance(faults)


static func complaints(faults: Array) -> Array:
    var out: Array = []
    for f: Variant in faults:
        var text: String = InstallFaults.complaint(str(f)) + Malware.complaint(str(f)) + Overclock.complaint(str(f))
        if text != "": out.append(text)
    return out


# Trust lost when delayed faults bring the customer back (always at least 1).
static func comeback_trust(faults: Array) -> int:
    return -maxi(1, roundi(annoyance(faults) / 10.0) * COMEBACK_TRUST_PER_10)


# A customer only pays for a PC that starts (proposal). Returns the cash handed over.
static func pay(payout: int, boots: bool) -> int:
    return maxi(0, payout) if boots else 0


static func reaction(score: int, boots: bool) -> String:
    if not boots: return "Furious: the PC does not even start. They refuse to pay."
    if score >= PickupScore.HAPPY_FROM: return "Happy with the repair."
    if score >= 40: return "Disappointed."
    return "Angry."


# Ticks every pending comeback by one morning. Returns {due: [...], pending: [...]}.
static func tick(pending: Array) -> Dictionary:
    var due: Array = []
    var keep: Array = []
    for raw: Variant in pending:
        if not raw is Dictionary: continue
        var entry: Dictionary = (raw as Dictionary).duplicate(true)
        entry["nights_left"] = int(entry.get("nights_left", COMEBACK_NIGHTS)) - 1
        if int(entry["nights_left"]) <= 0: due.append(entry)
        else: keep.append(entry)
    return {"due": due, "pending": keep}


# Rebuilds saved pending comebacks from known shapes only.
static func sanitize_pending(raw: Variant) -> Array:
    var out: Array = []
    if not raw is Array: return out
    for item: Variant in raw:
        if not item is Dictionary: continue
        var faults: Array = []
        var raw_faults: Variant = (item as Dictionary).get("faults", [])
        if raw_faults is Array:
            for f: Variant in raw_faults:
                if str(f) in DELAYED: faults.append(str(f))
        var nights: Variant = (item as Dictionary).get("nights_left", COMEBACK_NIGHTS)
        if faults.is_empty() or not typeof(nights) in [TYPE_INT, TYPE_FLOAT]: continue
        out.append({"customer_id": str(item.get("customer_id", "")), "customer": str(item.get("customer", "")),
            "ticket": str(item.get("ticket", "")), "faults": faults, "nights_left": clampi(int(nights), 1, 30)})
    return out
