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
# 0.58.4 (user, 27 November 2026): "add a new customer that comes with a virus installed so I can playtest
# (Hudici Dan by name, he does not appear yet but his PC is in storage)". Not in the IDS rotation: he never
# comes to the counter; a new game puts his PC, with the crypto miner, in storage (NightSession.add_waiting_pc).
const HUDICI_DAN := "t003_hudici"


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
            # 0.58.9 (D181): what she says at the counter, around the complaint (placeholder lines; the story is the user's).
            "greeting": "Good morning. I read about your shop online, so I hope the reviews were honest.",
            "patience_line": "I need it back by tomorrow morning, please. I start early.",
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
            "greeting": "Hey, it's me again! My PC is in real trouble this time.",   # 0.58.9 (D181), placeholder line
            "patience_line": "I can wait two days. Not three, though.",
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
    if id == HUDICI_DAN:
        return {
            "id": HUDICI_DAN,
            "name": "Hudici Dan",
            "portrait": "",
            "scripted": true,
            "profession": "regular",
            "persona": "Easy-going, a little embarrassed about the state of his PC.",
            "about": "Left his PC at the shop before opening day; drops by later to collect it.",
            "complaint": "The PC is slow and the fans roar all the time, even when nothing is open.",
            "uses": "Browsing, music and the odd game at the weekend.",
            "habits": "Installs whatever promises free stuff. Would notice the fans and the speed straight away.",
            "patience": "In no hurry.",
            "trust_start": 55,
            "budget": 100,
            "payout": 65,
            "needs": {"boots": true, "quiet": true},
            "pc": {"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"},
        }
    return {}
