# D157: the approved standard infection, not the rejected disappearing-row boss experiment.
# Local cleanup simulation only. The monitor owns clock/save transactions and the canonical infection.
extends RefCounted
const Malware = preload("res://scripts/rules/malware.gd")
const COST_MINUTES: int = 10 # Trial tuning: charged once when an attempt starts, including failed attempts.
const AD_SECONDS: float = 12.0
const ALIAS_SECONDS: float = 8.0
const RETURN_SECONDS: float = 5.0
const WORDS: Array[String] = ["BANANA", "POTATO", "CHEESE"]
const ALIASES: Array[String] = ["CoolCoin.exe", "SystemHeater.exe", "DefinitelyIdle.exe"]
const OFFERS: Array[String] = ["YOU WON A FREE MOUSE. Shipping: $499.", "HOT SINGLE CORES IN YOUR AREA.", "DOWNLOAD MORE RAM. Now with extra RAM."]
var strain: String = ""
var processes: Array[Dictionary] = []
var elapsed: float = 0.0
var overload: float = 12.0
var paused: bool = false
var startup: bool = true
var respawn_left: float = 0.0
var returns: int = 0
var advert: bool = false
var next_ad: float = AD_SECONDS
var offer: int = 0
var scanned: bool = false
var pending: Dictionary = {}
var hacks: int = 0
var outcome: String = "running"
var status: String = "Fixed rows. No hiding. End the source and its watchdog, then reboot to verify."
var history: Array[String] = []

func _init(infection: String = "") -> void:
    strain = Malware.sanitize(infection)
    if strain == "":
        outcome = "invalid"
        status = "No scanned infection to clean."
        return
    var miner: bool = strain == Malware.MINER
    processes = [
        _row("desktop", "desktop.exe", ":|", 2, "Macrosoft", "System/Desktop", "Critical desktop service. Holds this whole mess together."),
        _row("source", "CoolCoin.exe" if miner else "FreeCursors.exe", ":3" if miner else ":D", 88 if miner else 12, "Local Heating Solutions" if miner else "Trust Me Bro LLC", "Temp/FreeMoney" if miner else "Downloads/FreeStuff", "Recent CPU: 88%, 92%, 89%. Protected: needs a mainframe override." if miner else "Produces an advert every 12 seconds. End this parent to stop the offers.", true, miner),
        _row("invoice", "Invoice_FINAL2.exe", ":)", 3, "BudgetBooks Ltd.", "Programs/Accounting", "A genuine customer program with an unfortunate filename."),
        _row("watchdog", "Zombie.exe", ":P", 8, "Back Again Software", "Startup/Zombie", "This infection's watchdog. Returns after five seconds unless its auto-start is disabled.", true),
        _row("printer", "PrintSpooler.exe", "-_-", 0, "Macrosoft", "System/Printing", "Legitimate. Waiting for the printer to develop enthusiasm."),
        _row("rgb", "RGB_FanClub.exe", ":)", 1, "Colourful Peripherals", "Programs/RGB", "Legitimate lighting utility. It thinks it is essential. It is not.")
    ]
    advert = not miner

func _row(id: String, label: String, face: String, cpu: int, publisher: String, path: String, detail: String, bad: bool = false, locked: bool = false) -> Dictionary:
    return {"id":id, "label":label, "face":face, "cpu":cpu, "publisher":publisher, "path":path, "detail":detail, "bad":bad, "locked":locked, "ended":false}

func process(id: String) -> Dictionary:
    for item: Dictionary in processes:
        if item["id"] == id: return item
    return {}

func label(id: String) -> String:
    if id == "source" and strain == Malware.MINER:
        return ALIASES[int(elapsed / ALIAS_SECONDS) % ALIASES.size()]
    return str(process(id).get("label", ""))

func active(id: String) -> bool:
    var item: Dictionary = process(id)
    return not item.is_empty() and not bool(item["ended"])

func remaining() -> int:
    return processes.filter(func(p: Dictionary) -> bool: return p["bad"] and not p["ended"]).size()

func interactive() -> bool:
    return outcome == "running" and not paused and pending.is_empty()

func end_task(id: String) -> void:
    if not interactive() or not active(id): return
    if id == "desktop":
        outcome = "crashed"
        status = "Your technician ran into a problem. Desktop crashed; reboot needed. No hardware damage."
        history.append("The desktop process was ended; the PC crashed.")
    elif bool(process(id)["locked"]):
        pending = {"id":id, "word":WORDS[hacks % WORDS.size()]}
        hacks += 1
        status = "ACCESS DENIED. Hack the mainframe. The desktop pauses while you type."
    else:
        _end(id)

func _end(id: String) -> void:
    process(id)["ended"] = true
    history.append("Ended " + label(id) + ".")
    if bool(process(id)["bad"]): overload = maxf(0.0, overload - 12.0)
    if id == "source":
        advert = false
        status = "MAINFRAME HACKED. Local heating economy devastated." if strain == Malware.MINER else "FreeCursors: 'But you were our millionth visitor!' The adverts stop."
    elif id == "watchdog":
        respawn_left = RETURN_SECONDS if startup else 0.0
        status = "Zombie stopped. Auto-start is preparing an encore." if startup else "Zombie stopped. No more encores."
    else:
        status = "An innocent program closed. Suspicious name, innocent little guy."

func submit_word(raw: String) -> bool:
    if outcome != "running" or paused or pending.is_empty(): return false
    if raw.strip_edges().to_upper() != str(pending["word"]):
        status = "ACCESS DENIED. Type %s and try SEND again." % pending["word"]
        return false
    var id: String = str(pending["id"])
    pending.clear()
    _end(id)
    return true

func cancel_word() -> void:
    if pending.is_empty(): return
    pending.clear()
    status = "Override cancelled. The process is still running."

func disable_startup() -> void:
    if not interactive() or not startup: return
    startup = false
    respawn_left = 0.0
    history.append("Disabled the visible Zombie auto-start entry.")
    status = "Auto-start disabled. End its running process too."

func scan() -> void:
    if not interactive(): return
    scanned = true
    status = "Budget scan flags the source and its watchdog. Ordinary customer programs can stay."

func close_advert() -> void:
    if not interactive(): return
    advert = false
    status = "Advert closed. Its parent can still make another."

func verify() -> void:
    if not interactive(): return
    if remaining() > 0:
        status = "Verification: suspicious activity remains. Finish the cleanup first."
    elif startup:
        process("watchdog")["ended"] = false
        respawn_left = 0.0
        returns += 1
        status = "Reboot launched Zombie again. Disable its auto-start."
        history.append("Zombie returned after the verification reboot.")
    else:
        outcome = "won"
        advert = false
        status = "Clean reboot. Source and watchdog stopped; no auto-start return. Actual professional service."
        history.append("Reboot verification: no matching processes returned.")

func abort() -> void:
    if outcome != "running": return
    outcome = "aborted"
    pending.clear()
    status = "Cleanup stopped without verified removal. The infection remains on this PC."

func step(delta: float) -> void:
    if not interactive() or delta <= 0.0: return
    elapsed += delta
    if respawn_left > 0.0:
        respawn_left = maxf(0.0, respawn_left - delta)
        if respawn_left == 0.0 and startup:
            process("watchdog")["ended"] = false
            returns += 1
            status = "Zombie returned to the same row, wearing a tiny moustache."
    if elapsed >= next_ad:
        next_ad = elapsed + AD_SECONDS
        if strain == Malware.ADWARE and active("source") and not advert:
            offer += 1
            advert = true
    overload = clampf(overload + delta * (remaining() * 0.15 + (0.05 if advert else 0.0)), 0.0, 100.0)
    if overload >= 100.0:
        outcome = "overloaded"
        status = "The desktop needs a break. Cleanup failed; infection remains."

func report() -> String:
    return "Task Manajer: %s\n%s" % [status, "\n".join(history)]
