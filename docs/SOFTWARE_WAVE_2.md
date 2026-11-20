# Wave 2 — first diagnostic desktop, 0.35.0

## Current anti-virus update — 0.49.0 (D157)

Anti-virus scan -> Remove threat now opens the approved standard Task Manajer inside this monitor;
removal is no longer one click. Fixed rows, one occasional advert, slow miner alias, uppercase native
SEND/Enter and unlimited typing pause. Stop the actual source/watchdog, disable auto-start, reboot to
verify; only then cure the canonical infection. Attempts spend ten night minutes once (trial tuning);
failed/stopped attempts retain infection. No payment or ready-for-pickup action is introduced.
See ANTIVIRUS_MINIGAME_DESIGN.md for the live contract and HANDOFF.md for Claude's 3.6 testing-bay resume.
Older Wave 2 version notes below are historical. Signed: Codex (GPT-6; model id not exposed), ChatGPT Work.

**Current menu rules: MENU_NAVIGATION.md (0.42.0, user approved).** Slot → workbench directly,
common Repair/Hardware/Monitor tabs, named Room back, Activities/Pause, Arrange room mode and
Continue. Older menu, sandbox and service-hub instructions below are historical; current hardware
is connected (D131). This supersedes paths only, preserving current game/app mechanics.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 16 November 2026.

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User requested: fix cloth, PCs off by default, start Wave 2.
This is the first slice of CUSTOMER_MODEL_MAP section 7, not the complete software system.

## Play it

New Game → Workshop → choose a customer PC → Diagnostic monitor.
The case is beside the desktop; Switch PC ON is outside the screen so it is usable while off.
Boot check names missing/broken parts and their repair path. After boot works, final/thermal
check gives a report with existing heat rules, never a payment, pickup or completion.
Vapor buys Counter Stroke 2 for the shop for the existing $12, once; Run uses the existing
CPU/RAM/GPU/thermal FPS simulation. Both customer PCs use the same owned licences, with their
own power switches and repair state. A failed boot gives no live temperature or FPS reading.
The customer's complaint, uses and collection request remain alongside the monitor in a scroll.

Off PCs are available for cleaning and repasting. Entering/leaving screens never automatically
turns them on. Fresh tickets begin off; old saves without a switch migrate off; explicit on/off
saves remain unchanged. The repair bench starts with stationary fans when off. Legacy shop final
check also requires power, but retains its historical one-time payment semantics; this monitor
and the night diagnosis never call that transaction.

Cloth picking now follows its actual skewed, rotated fabric inset one world pixel. Working wipe
reach is 35 rather than 36 world pixels (4.375 instead of 4.5 paste cells); square cloth behavior
and wipe strength are unchanged. Cloth art is not redesigned.

## 0.40.0 - anti-virus and overclocker (D132)
The two "later" buttons are now apps. Anti-virus: Scan / Remove threat (`malware.gd`); the second demo PC
arrives with adware, hinted in the complaint. Overclocker: multiplier and voltage steps, Quick stress and
Long stress ($2) (`overclock.gd`). Heat from the overclock is visible in every check; instability is not.
Both feed hidden pickup faults. All numbers are trial proposals awaiting the user's playtest.
Still not built: customer-specific infection generation beyond the demo ticket; overclocking the GPU.

## 0.41.0 - hardware check, timed tests, Work + match tab (D133)
Hardware check replaces Final / thermal check. Game tests take 30 night minutes and the long stress test 20
(`night_clock.gd`); the clock is shown but nothing ends the night yet. `work_report.gd` builds the main side
tab from the job and from stored measurements (`job["tests"]`), which are marked outdated when the PC changes.

## What remains (historical, 0.35.0)

Anti-virus and overclocker are visible, clearly marked upcoming. Clicking them explains that no
scan/tuning has run. Their exact infection, cure, stability/heat and risk rules need a separate
slice; this does not create a pretend successful test. No real OS, real game launch, benchmark
or Steam integration is implied. All outputs use the existing trial simulation.

No campaign clock, diagnostic wait timer, supplier change, PC ownership migration or persistent
monitor report is added. Licences/cash use existing GameState saves and NightSession checkpoints.
An off diagnostic may still internally estimate heat for pure rule callers; UI never labels that
as a measured temperature. The legacy final check remains an estimate-based historical screen.

## Coordination

User assigned Wave 2 to Codex now; older Claude/customer split is historical for this slice.
Only one PR touches the hot files: extend existing bench-feel PR #41; do not open a competing PR.
Keep archive/v0.34.0 intact and create archive/v0.35.0 for this delivery. Do not merge automatically.
Claude cross-reviews GameState boot integration, monitor transaction boundaries and feel changes.
Hot files released after delivery, subject to Claude's next work-plan ownership. WORK_PLAN.md is
unchanged. Anti-virus/overclocking remain future work, not approved numeric mechanics.

## Verification

Required suites include software tests for off/default/migration, native GUI power click, boot
failure, game ownership, budget-performance effect, no diagnostic payout/trust/job mutation,
per-PC power after switching/reload, future app no-op and one-pixel cloth fringe.
Target-engine results are in CHANGELOG.md; no graphical/manual playtest claim.
