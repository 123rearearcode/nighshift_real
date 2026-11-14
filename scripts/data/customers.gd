# DATA ONLY: the customers behind the tickets. What the shop knows (and the player can read in the
# shop's Customer tab): who they are, what they brought the PC in for, what they use it for (that is
# where the job's required graphics power comes from), and their habits — which will matter for the
# scam direction (D17/D18: discovery is persona-based). All people here are fictional; names are
# invented, never real people or brands. Numbers are trial proposals.
extends RefCounted

const IDS: Array = ["t001_mara"]


static func customer(id: String) -> Dictionary:
    if id == "t001_mara":
        return {
            "id": "t001_mara",
            "name": "Mara V.",
            "about": "Front-desk clerk at the parody-brand hotel around the corner. First time in the shop; found it through an online review.",
            "complaint": "PC overheats and the fan is very loud.",
            "uses": "Office work, browsing and light games in the evening - this PC needs a graphics output of at least 60.",
            "required_power": 60,
            "habits": "Never opens the case herself. Would notice louder fans and hot air straight away. Reads and writes online reviews.",
            "patience": "Needs the PC back by tomorrow morning.",
            "payout": 60,
        }
    return {}
