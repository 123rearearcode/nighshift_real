# DATA ONLY: the tool upgrades the Shop sells (D131). Prices stay in GameState.UPGRADE_PRICES (the
# rule that charges them); this file only names them. A new tool upgrade is added here AND there.
extends RefCounted

const LIST: Array = [
    {"id": "square_cloth", "label": "Square cloth", "blurb": "A square cloth wipes paste off cleanly and quickly."},
    {"id": "long_hose", "label": "Longer vacuum hose", "blurb": "More hose to reach the far corners of the case."},
    # 0.58.4: backpacks (scripts/rules/backpack.gd): your personal inventory grows; you always have pockets.
    {"id": "backpack_small", "label": "Small backpack", "blurb": "Carry more: a 6 x 3 backpack instead of your 4 x 2 pockets."},
    {"id": "backpack_large", "label": "Hiking backpack", "blurb": "Carry the most: an 8 x 4 backpack."},
]
