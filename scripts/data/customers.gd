# DATA ONLY: the customers behind the tickets (D92-D95; the agreed map is docs/CUSTOMER_MODEL_MAP.md).
# What never changes about a person lives here; what the shop EARNS (trust changes, history, scores)
# lives in the save under customer_state. All people are fictional; names are invented. The portrait
# field is deliberately empty for now: when portraits come, they must be derived from the character's
# actual look, so it will hold a reference to that, never a loose picture. Numbers are trial proposals.
#
# Professions in the first cut (D96): "regular", "gamer", "clueless". A clueless customer's needs hold
# a decoy: `stated` is what they SAY, `real` is what actually decides their pickup score.
extends RefCounted

const IDS: Array = ["t001_mara", "t002_relu"]


static func customer(id: String) -> Dictionary:
    if id == "t001_mara":
        return {
            "id": "t001_mara",
            "name": "Mara V.",
            "portrait": "",
            "scripted": true,
            "profession": "regular",
            "persona": "Polite, in a hurry, slightly suspicious of technology.",
            "about": "Front-desk clerk at the parody-brand hotel around the corner. First time in the shop; found it through an online review.",
            "complaint": "PC overheats and the fan is very loud.",
            "uses": "Office work, browsing and light games in the evening.",
            "habits": "Never opens the case herself. Would notice louder fans and hot air straight away. Reads and writes online reviews.",
            "patience": "Needs the PC back by tomorrow morning.",
            "trust_start": 50,
            "budget": 90,
            "payout": 60,
            "needs": {"boots": true, "quiet": true},
            # D148 (0.45.0): the PC she brings, as catalogue parts (hardware_catalog.gd).
            "pc": {"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"},
        }
    if id == "t002_relu":
        return {
            "id": "t002_relu",
            "name": "Relu D.",
            "portrait": "",
            "scripted": true,
            "profession": "gamer",
            "persona": "Chatty, knows benchmark numbers by heart, no patience for stutter.",
            "about": "Economics student; plays ranked matches every evening. A regular at the shop since his first build.",
            "complaint": "The frame rate suddenly tanked; now the PC powers on but the screen stays black. I can't play Counter Stroke at all.",   # 0.47.0: matches his boot symptom (Codex, PR #58)
            "uses": "Counter Stroke 2 every evening; wants it smooth.",
            "habits": "Opens the case himself, watches temperatures and clock speeds. Would spot a swapped part or old paste in a week.",
            "patience": "Can wait two days, not three.",
            "trust_start": 65,
            "budget": 140,
            "payout": 80,
            "needs": {"boots": true, "games": [{"game_id": "counter_stroke_2", "min_fps": 60}]},
            "pc": {"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_ssd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"},
        }
    return {}
