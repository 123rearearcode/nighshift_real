# RULES ONLY: the bench's hand-state machine (docs/HAND_STATES.md, work plan Phase 2 step 6).
# The player's hands are always in exactly one state; this script says which state the current flags
# amount to (`derive`) and which state changes are allowed (`allowed`). The bench view asks `allowed`
# before any act that would take something into the hands, so the forbidden combinations (equipping a
# tool mid-mount, grabbing a part while carrying the hose, ...) are impossible rather than unplanned.
# Pure functions: no scene access, no input, no drawing.
extends RefCounted

const FREE: String = "FREE"
const USING_TOOL: String = "USING_TOOL"
const THROWING: String = "THROWING"
const CARRYING_HOSE: String = "CARRYING_HOSE"
const DRAGGING_PART: String = "DRAGGING_PART"
const DRAGGING_CLAMP: String = "DRAGGING_CLAMP"
const MOUNTING: String = "MOUNTING"
const PANEL_OPEN: String = "PANEL_OPEN"

# What may be ENTERED from each state. Letting go (any state -> FREE) is always allowed and not
# listed. A state missing from a list can only be reached through FREE first.
const MOVES: Dictionary = {
    FREE: [USING_TOOL, DRAGGING_PART, CARRYING_HOSE, DRAGGING_CLAMP, PANEL_OPEN, MOUNTING],
    USING_TOOL: [USING_TOOL, THROWING, CARRYING_HOSE, DRAGGING_CLAMP, PANEL_OPEN, MOUNTING],
    THROWING: [],
    CARRYING_HOSE: [],
    DRAGGING_PART: [],
    DRAGGING_CLAMP: [],
    MOUNTING: [],
    PANEL_OPEN: [],
}


# The state the given flags amount to, in priority order (docs/HAND_STATES.md).
static func derive(f: Dictionary) -> String:
    if bool(f.get("panel_open", false)): return PANEL_OPEN
    if bool(f.get("mounting", false)): return MOUNTING
    if bool(f.get("clamp_dragging", false)): return DRAGGING_CLAMP
    if bool(f.get("hose_grabbed", false)): return CARRYING_HOSE
    if bool(f.get("part_dragging", false)): return DRAGGING_PART
    if bool(f.get("throwing", false)): return THROWING
    if bool(f.get("equipped", false)): return USING_TOOL
    return FREE


# May the hands go from `from` to `to`? Letting go is always allowed.
static func allowed(from: String, to: String) -> bool:
    if to == FREE:
        return true
    return to in (MOVES.get(from, []) as Array)
