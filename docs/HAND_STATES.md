# The bench's hand states (work plan Phase 2, steps 5 and 6)

Written 2026-11-13 by Claude (Fable 5, model id claude-fable-5); step 5 named the states, step 6
(0.19.7) made them real. `scripts/bench/hand_state.gd` holds the rules (`derive`, `allowed`, `MOVES`),
and the bench asks `_may_enter(<state>)` before every act that takes something into the hands; a
refused act simply does not happen (the click falls through to nothing, silently). The current state
is `bench_view.hand_state()`, visible in the scripted playtest's `PLAYTEST STATE` table.

## The states

On the repair bench, the player's hands are always in exactly one of these states:

| State | Meaning | Today's flags (how `hand_state()` derives it) |
| --- | --- | --- |
| `PANEL_OPEN` | The replacement-stock panel is open; the bench is paused behind it | `replacement_panel.visible` |
| `MOUNTING` | The cooler is on the paste and the press minigame runs | `mount.active` |
| `DRAGGING_CLAMP` | Carrying the hose clamp (a desk fixture) | `tools.clamp_dragging` |
| `CARRYING_HOSE` | Carrying a point of the hose with the right button | `tools.hose_grab >= 0` |
| `DRAGGING_PART` | Carrying the cooler or GPU | `access.dragging != ""` |
| `CARRYING_ITEM` | Carrying a loose item (a coin, a screw) | `items.carried >= 0` |
| `THROWING` | Right-button wind-up of the held tool | `tools.carrying` |
| `USING_TOOL` | A tool is in the hand (applying it only while the left button is down in the work area) | `tools.equipped` |
| `FREE` | Empty hands | none of the above |

The order above is the priority: the first line whose flags match is the state. "Applying" (the left
button held in the work area, `holding`) is a property inside `USING_TOOL`, not a state of its own.

## Allowed moves (the rules in `hand_state.gd`)

- `FREE` → `USING_TOOL` (click or press 1/2/4 to take a tool), `DRAGGING_PART` (left-press a part in
  parts mode), `CARRYING_HOSE` (right-press on the hose), `DRAGGING_CLAMP` (left-press on the clamp),
  `PANEL_OPEN` (button), `MOUNTING` (the Mount button parks the tool first, so the press can come from
  empty hands), `CARRYING_ITEM` (left-press a loose item).
  Instant clicks that enter no state: emptying the dust bin, pulling the cooler lever, and the hose
  spool (allowed from `FREE` and `USING_TOOL`; the click rewinds the hose and the hands stay as they were).
- `USING_TOOL` → `THROWING` (right-press), `FREE` (park / parts mode), `USING_TOOL` (switch tool: one
  tool is put down and another taken in the same act), `CARRYING_HOSE` / `DRAGGING_CLAMP` (the held tool
  is parked first — today's behaviour), `MOUNTING` (syringe stage, Mount button), `PANEL_OPEN` (button).
- `THROWING` → `FREE` (release: the tool flies; the hand is empty).
- `CARRYING_HOSE` → `FREE` (release the right button).
- `DRAGGING_PART` → `FREE` (release: the part settles in the tray or its socket).
- `CARRYING_ITEM` → `FREE` (release: the item drops where it is, or into the trash can, which destroys
  it). Entered from `FREE` only: a hand holding a tool uses the tool; it does not pick small items up.
- `DRAGGING_CLAMP` → `FREE` (release: the clamp parks on a valid spot).
- `MOUNTING` → `FREE` (the lever is clicked; the result panel shows). Nothing else may interrupt a
  mount; a stage switch mid-mount behaves like pulling the lever (the cooler is secured as it lies),
  and leaving the bench must behave like releasing everything first. Letting go still works: a
  right-click that would normally wind up a throw parks the tool gently instead (putting a tool down
  mid-mount is allowed; flinging it is not).
- `PANEL_OPEN` → `FREE` (the panel closes; any drag or throw was already cancelled when it opened).

Everything not listed is forbidden and refused by the machine since 0.19.7. One superseded behaviour:
a keyboard tool switch while gripping the hose used to auto-release the hose and equip; it is now
refused, because the gripping hand is still physically on the button (`tool_rig.select` keeps its
auto-release only as a safety net for direct calls). Two known holes remain for step 7's tests:
- losing window focus in any state must behave like releasing every button (back to `FREE` or
  `USING_TOOL` with nothing applied);
- leaving the bench must end every state cleanly (mount finished or abandoned deliberately, drags
  released), never leaving a flag stuck for the next visit.
