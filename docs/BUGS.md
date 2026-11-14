# Nightshift — Bug register

Every bug goes here when it is found (user playtest, CI, cross-review), not only when it is
fixed. One row per bug in the table; bigger bugs get a section below with the root cause. The
goal is to see STRUCTURAL problems: when several bugs share a root cause, that cause is the
real bug. Rules for keeping this file are in `AGENTS.md` (rule 6) and `DEVELOPMENT.md`.

**Structural review: every 10 versions** (0.30.0, 0.40.0, …) the integrating AI re-reads this
whole file, writes a short "Patterns" entry at the top of the Reviews section below, and
proposes structural work to the user. Next review due: **0.30.0**.

## How to file a bug

Add a table row at once (ID, found version, status `open`). Fill `Fixed` when a release fixes
it. If the root cause is not local — if the same cause could bite again elsewhere — add a
section under "Root causes" and say what the structural answer would be, even if only the local
fix ships now.

| ID | Found | Fixed | Reported by | Symptom | Root cause (short) |
| --- | --- | --- | --- | --- | --- |
| B1 | 0.19.x | 0.19.7 | Codex review | Idle paste bench kept an active mounting session | stage state not cleared on switch |
| B2 | 0.21.0 | 0.22.0 | user video | Hose end detached from the vacuum; vacuum stayed behind | two owners of one position (hose sim vs tool rig), no bridge |
| B3 | 0.21.0 | 0.22.1 | user video | Crowded tools "disappear" (teleport across the obstruction) | collision resolver pushed to the far side; no table clamp |
| B4 | 0.22.x | 0.23.0 | user playtest | Final check demanded full cleaning the design no longer wanted | rule lived in code, not in the agreed design (D87 settled it) |
| B5 | 0.25.0 | 0.28.0 | Codex cross-review + user screenshot | Customer dossier text overflowed its card and the footer | plain Labels grow to content; fixed rects do not bound them (see RC-2) |
| B6 | 0.25.0 | 0.28.0 | Codex cross-review | Trust never moved for scores 61–79 | integer division swallowed small deltas |
| B7 | 0.25.0 | 0.28.0 | Codex cross-review | Hand-edited/damaged save crashed the shop (invalid cast) | loaded data trusted without per-field validation (see RC-3) |
| B8 | 0.28.0 | 0.28.0 | CI (new test) | History normaliser crashed on visit records missing keys | `get()` default passed the type test, then direct `[]` access hit the missing key |
| B9 | 0.26/0.27 | 0.28.0 | user playtest | Held salvage find bulldozed other finds out of the dumpster | zone decided by bare x-position; no ownership gate at the rim (D108) |
| B10 | 0.28.0 | 0.29.0 | user playtest | **Loop-blocker:** GPU replaced "at the hardware bench" but the final check still failed | two disconnected PCs: the sandbox never writes job state (see RC-1) |
| B11 | 0.28.0 | 0.29.0 | user playtest | Coolers unmountable at the hardware bench ("needs a mount"); no CPU exists | sandbox board had no COOLER_MOUNT slot and stock had no CPU (see RC-1) |
| B12 | 0.28.0 | 0.29.0 | user playtest | Broken GPU came as a surprise at the final check | damage feedback was a 3 s status line; ticket/check never showed part states (see RC-2) |
| B13 | 0.28.0 | 0.29.0 | user playtest | Main-menu status text crossed the card border | buttons were added (salvage, settings) without growing the card (see RC-2) |
| B14 | 0.27.0 | 0.29.0 | Codex review of the D108 plan | Releasing a find overlapping the rim barrier could fling it | collider re-enabled inside a body; fixed with a grace exemption until clear |
| B15 | 0.27.0 | 0.29.0 | Codex cross-review | Cargo re-entry at a fixed point could spawn inside a staged find | fixed spawn coordinates; fixed with a free-space probe |

## Root causes (structural)

### RC-1: more than one representation of "the customer's PC" (B10, B11)
The job (`game_state.gd`) is the real customer PC. The repair bench reads/writes it. The
hardware bench is a SANDBOX over `player_inventory` + a demo board — fitting a GPU there never
touched the job, and nothing told the player. Worse, the sandbox's own loop was incoherent
(coolers had no slot, no CPU existed), so it looked broken rather than separate.
0.29.0 answer: one source of truth surfaced everywhere — `GameState.part_state()` is the only
way part states are read; ticket, final check and benches all show it with the exact repair
path; the sandbox says plainly what it is and got a coherent CPU → mount → cooler loop.
Still open structurally: actually CONNECTING the customer's PC to the hardware bench (D79 note)
so there is only ONE parts model. That is the next structural step, not patched here.

### RC-2: fixed-rect UI with growing content, and state without a surface (B5, B12, B13)
Labels and cards were sized by hand and content grew past them; important state (a broken part)
lived in the model with no persistent surface. Pattern answer: every long text sits in a bounded
scrolling container with a containment regression check; every player-relevant state must have a
place on screen that shows it binary and names the next action.

### RC-3: loaded and external data trusted as-shaped (B7, B8)
Save data (and any future imported data) must be rebuilt field by field with defaults and
clamps, never cast in the UI. B8 showed even the VALIDATOR can make the same mistake — tests
must feed damaged data on purpose.

## Reviews (newest first)

*(none yet — first structural review due at 0.30.0)*
