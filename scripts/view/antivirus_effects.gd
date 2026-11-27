# Presentation only (0.58.0). Decorations never change a process's clues, identity, control geometry,
# simulation or outcome. The round's elapsed time freezes while paused or typing.
extends RefCounted

const GARBLED: Array[String] = ["svÑhost.exe", "Chr0me_Ã©.exe", "Systεm_Â¿.exe", "CoolCοin.exe"]
const LOAD: Array[int] = [88, 94, 89, 97, 91, 86]


static func sample(round_model: RefCounted, id: String, reduced: bool) -> Dictionary:
    var item: Dictionary = round_model.process(id)
    var ended: bool = bool(item.get("ended", false))
    var result: Dictionary = {"text":round_model.label(id), "cpu":0 if ended else int(item.get("cpu", 0)),
        "colour":Color.WHITE, "italic":false, "offset":Vector2.ZERO}
    if ended or round_model.outcome != "running": return result
    var tick: int = int(round_model.elapsed / (1.0 if reduced else 0.65))
    if id == "source" and round_model.strain == "miner":
        result["text"] = GARBLED[(tick + round_model.case_variant) % GARBLED.size()]
        result["cpu"] = LOAD[tick % LOAD.size()]
        result["colour"] = Color("f5c979")
        result["italic"] = true
        if not reduced:
            result["offset"] = Vector2(sin(round_model.elapsed * 14.0), 0)
    elif id == "source":
        result["colour"] = Color("f5c979") if reduced else Color.from_hsv(fmod(round_model.elapsed * 0.12, 1.0), 0.42, 1.0)
        result["italic"] = true
        result["cpu"] = [12, 19, 9, 16][tick % 4]
    elif id == "watchdog" and round_model.returns > 0:
        result["text"] = round_model.label(id) + " · back again!"
        result["colour"] = Color("f5c979")
    return result
