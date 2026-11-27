# RULES (0.58.4): the player's personal inventory. User, 27 November 2026: "the player can have a personal
# inventory (he can buy backpacks to upgrade)", and (answering) "Just carry, no gating": the backpack is one
# more storage grid that goes with the player into every room; carrying a part does not change where it can
# be used. Bigger backpacks are tool upgrades sold at the store (GameState.UPGRADE_PRICES, data/upgrades.gd).
extends RefCounted

const ID := "backpack"                       # the storage unit id (scripts/storage/storage_model.gd)
# Smallest first; the player always has pockets. Sizes are storage cells (44 px each on screen).
const LEVELS: Array = [
    {"id": "pockets", "name": "Pockets", "size": Vector2i(4, 2)},
    {"id": "backpack_small", "name": "Small backpack", "size": Vector2i(6, 3)},
    {"id": "backpack_large", "name": "Hiking backpack", "size": Vector2i(8, 4)},
]
const ACCEPTS: Array = ["tool", "part"]      # whole PCs do not fit in a backpack


# The best backpack the player owns (from GameState.upgrades).
static func level(upgrades: Dictionary) -> Dictionary:
    var best: Dictionary = LEVELS[0]
    for entry: Dictionary in LEVELS:
        if entry["id"] == "pockets" or bool(upgrades.get(entry["id"], false)): best = entry
    return best


static func size_for(upgrades: Dictionary) -> Vector2i:
    return level(upgrades)["size"]


static func spec(size: Vector2i) -> Dictionary:
    return {"name": "Backpack", "size": size, "shelves": 1, "accepts": ACCEPTS, "hint": "Goes with you into every room."}
