# Night workshop — 0.30.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
14 November 2026, Europe/Bucharest. User-approved follow-up; keep both PRs unmerged.

## Play this version

1. F5 → **New game** → **Activities**. Choose Workshop, Salvage dump or Storage rack.
   A disabled card leaves space for later activities; no shop has been built here.
2. Workshop's dropdown selects the PC. A new game has the two existing customers' repair tickets:
   one original tower and one additional compact PC. Both occupy real rack space.
3. Enter Repair bench for cleaning/paste. Return with **Switch PC / workshop** whenever you want.
   Each PC keeps dust, removed parts, broken/replacement components, scams and its physical paste.
4. Lock the cooler lever after a good paste mount: it commits automatically and charges the same
   thermal-paste cost as before. Toothpaste still costs nothing and records the existing scam.
   There is no extra Complete repaste button on this night route. Bad mounts need rework; if
   consumables cannot be paid for, the bench reports that and the repaste remains unconfirmed.
5. **Run final check** gives boot, heat, missing/damaged-part and owned-game-test information.
   Pass or fail, it never pays you, marks the ticket done, records pickup or advances customers.
   Keep working or switch PCs. Daytime customer pickup remains future work.
6. The existing square-cloth and longer-hose upgrades remain purchasable in Workshop.
   Prices and effects are unchanged. No payout is granted by the diagnostic button.
7. Hardware bench is still the shop's stock/board sandbox. It is grouped here for access, but
   it is not yet a complete customer-PC assembly system. Use repair-bench replacements for the
   current customer's damaged cooler/GPU. Salvage returns to Activities; its cargo/time remain
   isolated from campaign stock/time as before.

Existing saves migrate their actual current ticket only. **Start New game to get two demo PCs**;
loading an existing one-ticket save does not invent another client or overwrite its repair work.
Storage has three shelves per rack now; existing furniture gains the shelf without losing placements.
Storage cells are drawn smaller to fit all three shelves, and saved coordinates remain in grid cells.

## Tickets and physical PCs

A ticket and a PC are different things. The temporary marker at
`job.hardware_trial.night_session` contains `run`, `ticket`, `pc` and `kind`.
A repair ticket normally has a physical PC ID. A future build-order ticket can have `pc: ""`;
it does not create a customer PC tile, use PC shelf space or become a selectable repair machine.
No build-order intake or building mechanic is claimed by this release.

The current extra ticket uses the other existing customer, their actual complaint and quote.
No new customer persona/lore was invented. The gamer PC begins with a damaged GPU to give that
complaint a repair action. Collection information shows the customer's existing request, not a
made-up promised date. Promised-date negotiation is not built yet.

## How the bridge works (for Claude)

Hot files remain untouched. `NightSession` is a separate autoload after GameState. The selected
PC is still `GameState.job`, so all existing bench and replacement operations use real current
stock/money and existing saves. The manifest owns inactive job snapshots; it contains no copied
shop inventory, money, upgrades, customer trust or game library. Source projection is read-only:
reading the rack never initializes the queue, changes a ticket or manufactures work.

`<GameState.save_path>.night.json`, version 1, stores `{version, run, tickets}`. Each ticket is a
complete existing job dictionary with the namespaced marker. Run/PC IDs use a random nonce so a
new game's T001 cannot inherit another run's customer PC allocation. The active marker is nested
in hardware_trial because the old loader already preserves that dictionary. SAVE_FORMAT stays 1;
the sidecar and paste snapshot have their own versions. Unknown root-level job fields would be
stripped by the legacy loader, so do not add them as a shortcut.

Before switching, checkpoint the active main save and all ticket snapshots and verify main-save
readback. If either fails, keep the previous PC selected and show the failure. Then write the target
job to the main save. Its marker chooses the active PC on reload; no second manifest-pointer write
is needed. If the app stops during a switch, the previous or target main job is authoritative, and
inactive snapshots were already saved before it changed. Normal bench saves keep the active PC
current even if the manifest's cached active snapshot is older.

On reload, require matching run, unique ticket/PC identities and valid job shapes. A missing,
mismatched, future-version or damaged manifest recovers the main active job but disables switching
and preserves the original sidecar. Starting a confirmed New game intentionally replaces the queue.
This is crash recovery for the old single-job architecture, not a general multi-file transaction
system; migrating it into Claude's final canonical PC/ticket store remains necessary.

`PasteSnapshot` keeps the 51×51 float32 height field as base64 bytes, plus dispensed units and
material. This preserves the exact field through JSON without decimal rounding changing it.
It excludes transient hand/tool/mount pressure: leaving mid-mount cancels the unsecured mount.
Shape/finite-value validation happens before applying any snapshot. It is captured on bench saves
and exit, not every frame. The active PC's snapshot lives in hardware_trial.night_paste and therefore
travels with the rest of that PC's work.

`night_diagnostics.gd` is a pure evaluator using legacy temperature constants, dust zones, paste/
replacement data and fps rules. It does not call the old `run_final_check`, because that still pays
and records pickup. Old scene/tests retain the old behavior for now. When Claude extracts the
canonical diagnostic/pickup split, move the shared formula into that single rule module to avoid
thermal logic drifting. Do not expose the legacy shop's payout check in the new night navigation.

## Boundaries and next work

- This branch is stacked on `feature/storage-rack`; PR #35 stays unmerged. No automatic merges.
- No edits to bench_view.gd, tool_rig.gd, game_state.gd, shop_view.gd or WORK_PLAN.md. Small additive
  view wrappers change navigation/automatic paste commit; they do not replace hand/physics logic.
- Review save recovery and the temporary marker namespace with Claude before integration.
- Later: canonical PC/owned parts and queue, actual build orders, daytime pickups, capacity hooks,
  global night clock and shop selection. None is silently implemented by adding the Activities screen.
- Existing rack furniture is still free and capped at eight; purchase/intake/drawer limits are unchanged.
- No graphical playtest or target-hardware performance result is claimed. User should test routing,
  switching during unfinished work, paste feel and three-shelf readability.

## Checks

`tools/test_night_workshop.gd`: linked PCs, stock consumption across switches, per-PC repairs,
main/manifest JSON recovery and failed saves, build orders without a PC, non-completing diagnosis,
physical paste persistence, actual scene navigation and lever-driven commit. Existing tests update
only changed contracts (third shelf and activity routes); old bench simulations remain unchanged.
