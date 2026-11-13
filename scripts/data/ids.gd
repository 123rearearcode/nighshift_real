# DATA ONLY: names the code uses to identify tools, bench stages and serviceable parts, in one place
# (docs/WORK_PLAN.md Phase 1 step 3). Use these instead of typing "vacuum" or 0 by hand: a typo in a
# constant name is caught when the script loads, a typo in a string only when that line runs.
# The values are unchanged from before, so saves and tests are not affected.
extends RefCounted

# Tools
const VACUUM: String = "vacuum"
const BRUSH: String = "brush"
const PICK: String = "pick"
const CLOTH: String = "cloth"
const SYRINGE: String = "syringe"
const ALL_TOOLS: Array = [VACUUM, BRUSH, PICK, CLOTH, SYRINGE]
const CLEAN_TOOLS: Array = [VACUUM, BRUSH, PICK]      # tools on the bench in the cleaning stage
const PASTE_TOOLS: Array = [CLOTH, SYRINGE]           # tools on the bench in the paste stage
# The cleaning stage's tool slots (bench_view.active_tool, same numbers as DustSim.TOOL_*): 0 vacuum,
# 1 brush, 2 parts mode (no tool in hand; the vacuum stays the selected tool), 3 pick.
const SLOT_TOOL: Array = [VACUUM, BRUSH, VACUUM, PICK]
const TOOL_SLOT: Dictionary = {VACUUM: 0, BRUSH: 1, PICK: 3}
const SLOT_PARTS: int = 2

# Bench stages
const STAGE_CLEAN: int = 0
const STAGE_PASTE: int = 1

# Serviceable parts (also the ids of their dust zones)
const COOLER: String = "cooler"
const GPU: String = "gpu"
const SERVICE_PARTS: Array = [COOLER, GPU]
