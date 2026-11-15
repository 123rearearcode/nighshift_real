# Wave 2 — first diagnostic desktop, 0.35.0

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

## What remains

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
