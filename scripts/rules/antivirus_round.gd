# D157 / D163: simple clues, fixed targets and the actual customer's infection.
# Local cleanup simulation only. The monitor owns clock/save transactions and the canonical infection.
extends RefCounted
const Malware = preload("res://scripts/rules/malware.gd")
const COST_MINUTES: int = 10 # Trial tuning: charged once when an attempt starts, including failed attempts.
const AD_SECONDS: float = 12.0
const ALIAS_SECONDS: float = 8.0
const RETURN_SECONDS: float = 5.0
const WORDS: Array[String] = ["BANANA", "POTATO", "CHEESE"]
const ALIASES: Array[String] = ["CoolCoin.exe", "SystemHeater.exe", "DefinitelyIdle.exe"]
const ADWARE_NAMES: Array[String] = ["FreeCursors.exe", "HappyOffers.exe", "BonusSmiles.exe"]
const INVOICE_NAMES: Array[String] = ["Invoice_FINAL2.exe", "Receipts_FinalFINAL.exe", "BudgetBuddy.exe"]
const RGB_NAMES: Array[String] = ["RGB_FanClub.exe", "RainbowKeyboard.exe", "DiscoMouse.exe"]
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
var case_variant: int = 0

func _init(infection: String = "", case_key: String = "") -> void:
    strain = Malware.sanitize(infection)
    if strain == "":
        outcome = "invalid"
        status = "No scanned infection to clean."
        return
    var miner: bool = strain == Malware.MINER
    processes = [
        _row("desktop", "desktop.exe", ":|", 2, "Macrosoft", "System/Desktop", "Keeps the desktop running. Leave this one alone: stopping it crashes the PC."),
        _row("source", "CoolCoin.exe" if miner else "FreeCursors.exe", ":3" if miner else ":D", 88 if miner else 12, "Local Heating Solutions" if miner else "Trust Me Bro LLC", "Temp/FreeMoney" if miner else "Downloads/FreeStuff", "Makes coins for somebody else, using nearly all the PC's power. Stopping it needs a silly password." if miner else "Opens unwanted adverts, even when no browser is open. Came with a free download.", true, miner),
        _row("invoice", "Invoice_FINAL2.exe", ":)", 3, "BudgetBooks Ltd.", "Programs/Accounting", "The customer's invoices. A silly name, but it only opens their receipts."),
        _row("watchdog", "Zombie.exe", ":P", 8, "Back Again Software", "Startup/Zombie", "Brings unwanted software back. Turn off Start with PC, then stop this app.", true),
        _row("printer", "PrintSpooler.exe", "-_-", 0, "Macrosoft", "System/Printing", "Waits for the customer's printer. Uses almost no power. Mostly waits."),
        _row("rgb", "RGB_FanClub.exe", ":)", 1, "Colourful Peripherals", "Programs/RGB", "Changes the keyboard lights. The customer installed it. Doesn't open adverts or make coins.")
    ]
    if case_key != "": _vary_case(case_key)
    advert = not miner
    status = "Click an app to read what it does. Scan clues help you find the trouble."


# A PC keeps the same layout and names on retry. Different PCs get small, reproducible variations.
# No process ever moves during a round; no extra infection or hidden difficulty is generated.
func _vary_case(case_key: String) -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = case_key.hash()
    case_variant = rng.randi_range(0, ADWARE_NAMES.size() - 1)
    if strain == Malware.ADWARE: process("source")["label"] = ADWARE_NAMES[case_variant]
    process("invoice")["label"] = INVOICE_NAMES[rng.randi_range(0, INVOICE_NAMES.size() - 1)]
    process("rgb")["label"] = RGB_NAMES[rng.randi_range(0, RGB_NAMES.size() - 1)]
    for i in range(processes.size() - 1, 0, -1):
        var at: int = rng.randi_range(0, i)
        var held: Dictionary = processes[i]
        processes[i] = processes[at]
        processes[at] = held

func _row(id: String, label: String, face: String, cpu: int, publisher: String, path: String, detail: String, bad: bool = false, locked: bool = false) -> Dictionary:
    return {"id":id, "label":label, "face":face, "cpu":cpu, "publisher":publisher, "path":path, "detail":detail, "bad":bad, "locked":locked, "ended":false}

func process(id: String) -> Dictionary:
    for item: Dictionary in processes:
        if item["id"] == id: return item
    return {}

func label(id: String) -> String:
    if id == "source" and strain == Malware.MINER and not bool(process(id).get("ended",false)):
        return ALIASES[(int(elapsed / ALIAS_SECONDS) + case_variant) % ALIASES.size()]
    return str(process(id).get("label", ""))


func scan_clues() -> String:
    if strain == Malware.MINER:
        return "Find the app making coins with the PC's power. Then find the helper that brings unwanted software back."
    return "Find the app opening unwanted adverts. Then find the helper that brings unwanted software back."


func next_step() -> String:
    if remaining() == 0:
        return "Both stopped. Turn off Start with PC for the helper, then reboot." if startup else "Both stopped. Reboot to check they stay gone."
    if not active("source"): return "Main trouble stopped. Check the app that brings unwanted software back."
    return "Unwanted activity raises the pressure. Pause any time to read at your own pace."

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
    var stopped_name: String = label(id)
    process(id)["label"] = stopped_name
    process(id)["ended"] = true
    history.append("Ended " + label(id) + ".")
    if bool(process(id)["bad"]): overload = maxf(0.0, overload - 12.0)
    if id == "source":
        advert = false
        status = "MAINFRAME HACKED. Local heating economy devastated." if strain == Malware.MINER else "%s: 'But you were our millionth visitor!' The adverts stop." % label("source")
    elif id == "watchdog":
        respawn_left = RETURN_SECONDS if startup else 0.0
        status = "Helper stopped. Start with PC is still on, so it will come back." if startup else "Helper stopped. No more encores."
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
    status = "Start with PC is off. Stop the helper too, so it cannot keep running."

func scan() -> void:
    if not interactive(): return
    scanned = true
    status = scan_clues()

func close_advert() -> void:
    if not interactive(): return
    advert = false
    status = "Advert closed. Its parent can still make another."

func verify() -> void:
    if not interactive(): return
    if remaining() > 0:
        status = "An unwanted app is still running. Read the scan clues and check what each app does."
    elif startup:
        process("watchdog")["ended"] = false
        respawn_left = 0.0
        returns += 1
        status = "Zombie came back after reboot. Turn off Start with PC, then stop it again."
        history.append("Zombie returned after the verification reboot.")
    else:
        outcome = "won"
        advert = false
        status = "Clean reboot. Both unwanted apps stayed stopped. Start with PC is off. Actual professional service."
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
