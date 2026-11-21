# Room → workshop, 0.36.0

**Current menu rules: MENU_NAVIGATION.md (0.42.0, user approved).** Slot → workbench directly,
common Repair/Hardware/Monitor tabs, named Room back, Activities/Pause, Arrange room mode and
Continue. Older menu, sandbox and service-hub instructions below are historical; current hardware
is connected (D131). This supersedes paths only, preserving current game/app mechanics.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 16 November 2026.

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. Implements user requests D125–D126.

## Use it

New Game / Load → Activities → Workshop room. Find a whole customer PC on a rack (or in the
waiting-for-space area), hold the left mouse button and drag it to the right-hand WORKSHOP SLOT.
Release: the workshop opens with that PC's repair ticket. Change PCs by returning to Room / choose
another PC and dragging a different one in. Open workshop reopens the currently worked PC.

The slot is the active canonical PC. Its shelf spot becomes a marked ON BENCH reservation; when
you choose another PC, the previous one returns to that reserved allocation. Storage capacity is
never granted twice. The first active repair ticket remains the default bench PC, as before;
there is no separate persistent slot inventory. Rearranging furniture retains its reservation.

A part/tool cannot go in this slot. Build tickets without client hardware do not create a PC.
Unknown, stale or protected choices fail safely; dropping elsewhere still restores the last
committed layout. PC identity resolves against current canonical sources, not the hovered label.
Switch/checkpoint succeeds before deferred workshop entry. No pickup, money or trust side effect.
The hardware bench is still the shop-stock sandbox; the repair bench/diagnostic monitor use the
selected customer's actual ticket. A full shared installed-PC hardware model remains later work.

Activities is at the same top-right rectangle on the room, service hub, repair bench, hardware
bench, diagnostic monitor and salvage. Each exit keeps its existing cleanup/save behavior. The
hub itself needs no self-link. Return-to-workshop actions remain separate. Duplicate title/activity
Storage shortcuts and the service hub's PC dropdown are removed. Furniture utility buttons remain;
there are no numbered per-rack selectors.

## Recording and installation

The supplied 8.13s recording shows v0.32.0 on the title at 1s and its numbered rack sidebar at 6s.
That source frees a furniture Button while it emits its own signal. The replacement room, already
merged as PR #40/v0.33.0, removes that list and lifecycle path entirely. The current build retains
it and replays native sort/save/add/multiple-header clicks to check persistent control identities.
This explains this recording; it does not rule out an unseen different current-build failure.

Extract the new source ZIP into a fresh folder. Import that folder's project.godot in Godot
Project Manager. Check v0.36.0 on title/room before testing. Keep existing saves; do not delete
progress or overwrite old projects as an installation step. Same Godot app/user-data identity is
preserved; old storage schema-1 allocations still migrate through the existing schema-2 reader.

## Scope and verification

No hot files, global item ownership, save schema or WORK_PLAN.md changes in this version. PR #41
is extended, not duplicated or merged. Claude cross-reviews next. B19 is fixed with a bounded
service-hub ticket scroll while that hub was changed. Native-input room and exit regression tests
are added to CI; exact results are in CHANGELOG. No manual graphical or universal crash claim.
