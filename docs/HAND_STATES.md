# The bench's hand states (work plan Phase 2 step 5)

Written 2026-11-13 by Claude (Fable 5, model id claude-fable-5). Step 5 only NAMES the states and shows
them; behaviour is unchanged. Step 6 will make these rules real in `scripts/bench/hand_state.gd` and
route the bench's input through them. Until then this document is the specification, and the derived
state is visible in `bench_view.hand_state()` and the scripted playtest's `PLAYTEST STATE` table.

## The states

On the repair bench, the player's hands are always in exactly one of these states:

| State | Meaning | Today's flags (how `hand_state()` derives it) |
| --- | --- | --- |
| `PANEL_OPEN` | The replacement-stock panel is open; the bench is paused behind it | `replacement_panel.visible` |
| `MOUNTING` | The cooler is on the paste and the press minigame runs | `mount.active` |
| `DRAGGING_CLAMP` | Carrying the hose clamp (a desk fixture) | `tools.clamp_dragging` |
| `CARRYING_HOSE` | Carrying a point of the hose with the right button | `tools.hose_grab >= 0` |
| `DRAGGING_PART` | Carrying the cooler or GPU | `access.dragging != ""` |
| `THROWING` | Right-button wind-up of the held tool | `tools.carrying` |
| `USING_TOOL` | A tool is in the hand (applying it only while the left button is down in the work area) | `tools.equipped` |
| `FREE` | Empty hands | none of the above |

The order above is the priority: the first line whose flags match is the state. "Applying" (the left
button held in the work area, `holding`) is a property inside `USING_TOOL`, not a state of its own.

## Allowed moves (the specification for step 6)

- `FREE` → `USING_TOOL` (click or press 1/2/4 to take a tool), `DRAGGING_PART` (left-press a part in
  parts mode), `CARRYING_HOSE` (right-press on the hose), `DRAGGING_CLAMP` (left-press on the clamp),
  `PANEL_OPEN` (button).
- `USING_TOOL` → `THROWING` (right-press), `FREE` (park / parts mode), `USING_TOOL` (switch tool: one
  tool is put down and another taken in the same act), `CARRYING_HOSE` / `DRAGGING_CLAMP` (the held tool
  is parked first — today's behaviour), `MOUNTING` (syringe stage, Mount button), `PANEL_OPEN` (button).
- `THROWING` → `FREE` (release: the tool flies; the hand is empty).
- `CARRYING_HOSE` → `FREE` (release the right button).
- `DRAGGING_PART` → `FREE` (release: the part settles in the tray or its socket).
- `DRAGGING_CLAMP` → `FREE` (release: the clamp parks on a valid spot).
- `MOUNTING` → `FREE` (the lever is clicked; the result panel shows). Nothing else may interrupt a
  mount except leaving the bench (which must behave like releasing everything first).
- `PANEL_OPEN` → `FREE` (the panel closes; any drag or throw was already cancelled when it opened).

Everything not listed is forbidden; step 6 makes the forbidden moves impossible rather than merely
unplanned. Two known holes the table closes (they become tests in step 7):
- losing window focus in any state must behave like releasing every button (back to `FREE` or
  `USING_TOOL` with nothing applied);
- leaving the bench must end every state cleanly (mount finished or abandoned deliberately, drags
  released), never leaving a flag stuck for the next visit.
