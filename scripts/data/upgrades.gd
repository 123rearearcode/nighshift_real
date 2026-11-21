# DATA ONLY: the tool upgrades the Shop sells (D131). Prices stay in GameState.UPGRADE_PRICES (the
# rule that charges them); this file only names them. A new tool upgrade is added here AND there.
extends RefCounted

const LIST: Array = [
    {"id": "square_cloth", "label": "Square cloth", "blurb": "A square cloth wipes paste off cleanly and quickly."},
    {"id": "long_hose", "label": "Longer vacuum hose", "blurb": "More hose to reach the far corners of the case."},
]
