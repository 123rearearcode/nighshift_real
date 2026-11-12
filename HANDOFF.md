# Handoff - read this first

**Project:** Nightshift, a 2D pixel-art PC repair and shop-management game for Steam. This folder is a
small Godot 4.7.2 foundation trial, not the game. **Version at handoff: 0.14.0.**
**Owner:** the user, the creative director, a complete beginner. Files are exchanged as ZIPs.

**Signed:** Claude (Sonnet 5.5, model id claude-sonnet-5-5), working in a chat session, 2026-11-12.
**Claude did not run Godot.** Subsequent review ran the automated checks in Godot 4.6.3, not the user's real version 4.7.2 (confirmed by the user on 2026-11-12). **Update 0.14.0:** GitHub Actions ran the automated checks on Godot 4.7.2.stable.official (headless): 172 data schema and 344 regression checks, 0 failures, on 0.12.2. Still pending: human interactive validation (looks, feel, mouse and keyboard play) on 4.7.2.

## 1. Historical foundation features (see current update below)
- Shop screen with one repair ticket, cash and save/load (`user://nightshift_save.json`).
- Repair bench: vacuum dust bundles out of six parts of a PC; squeeze thermal paste, wipe with a cloth,
  mount the cooler in a timed pressure minigame.
- Hardware bench: drag RAM onto a shaped (L-shaped) motherboard grid, with rotation and hover cards.
- Square cloth upgrade, final check (temperature from dust and paste), 95% rule per part.
- Checker: `python3 -I tools/check_project.py` (hygiene only; it does not run Godot).

Where things are: `DEVELOPMENT.md` section 5 (file map) and section 6 (data contracts).

## 2. What is NOT built (and must not be built unless the user asks)
Everything in `docs/DESIGN_PROPOSALS.md`: night hub and time limit, ticket board, Go out locations, real
Shop, grid inventory, general case assembly, parts catalogue, mount-minigame redesign. Independent specks and two service-removable parts are now implemented in 0.9.0.
The user said they will work on the parts catalogue themselves first. Do not start it.

## 3. Rules for every bot
1. **Read before writing:** `HANDOFF.md`, `DEVELOPMENT.md`, newest `CHANGELOG.md` entry, then the scripts.
2. **Keep the layers:** data, rules, sim, state, view (`DEVELOPMENT.md` section 4). Lower layers never draw
   or read input. Do not put physics or rules in a view.
3. **Honesty:** never describe code as tested unless it ran in Godot 4.7.2. If you could not run Godot,
   say so in the changelog entry. List only checks you actually performed, with results.
4. **Mark proposals:** anything the user has not approved, including every number, is a proposal.
5. **No real brand names or logos** in game data. Brands are parodies.
6. **Do not rewrite old changelog entries.** Add a dated "Correction" note inside them instead.
7. **One number per delivery.** Never ship a different build under a version already delivered.
8. **Small, readable changes.** The owner is a beginner; keep structure simple and explain in plain words.
9. **Do not touch the user's design decisions** (D01 to D33 in the handoff documents). Ask when unsure.
10. **Beginner-friendly files:** deliver a ZIP named `nightshift_godot_trial_vX.Y.Z.zip` whose folder is
    `nightshift_godot_trial`, with `project.godot` inside and F5 running the main scene.

## 4. How to update the changelog (every bot, every change)
1. Decide the version bump (`DEVELOPMENT.md` section 1): MINOR for a new player-visible feature, screen or
   data contract; PATCH for fixes, tuning, docs, tooling. MAJOR stays 0 until the user says otherwise.
2. Set `config/version` in `project.godot` to the new number.
3. Copy the entry template from the top of `CHANGELOG.md` and paste it as the **first** entry below
   "Unreleased", with the heading `## X.Y.Z - YYYY-MM-DD - short title`. Keep every required heading:
   Execution status, Added/Changed/Fixed/Removed, Files changed, Checks performed, Decisions proposed
   (not approved), Known issues and open items, Next action.
4. Fill in **Author** (your name, which tool or model, where it ran) and **Based on** (previous version).
5. In **Files changed** list every file added (A), modified (M), deleted (D) or renamed (R), docs included.
6. In **Execution status** say plainly whether Godot was run, by whom, on which version.
7. In **Checks performed** write only what you actually ran. Put the text `CHECKS_PLACEHOLDER` there while
   working; the checker fails until you replace it with real results.
8. Update the first line of `README.md` to `(vX.Y.Z)`, plus any instructions that changed.
9. Update `DEVELOPMENT.md` sections 5 and 6 if files or contracts changed, in the same version.
10. Run `python3 -I tools/check_project.py` from the project folder and fix every FAIL.
11. Build the ZIP with the new number, check a fresh extract with the checker, and report to the user
    what was run and what was not.

If you work in parallel on a branch, put notes under "Unreleased" instead and let the integrating
contributor assign the number (`DEVELOPMENT.md` section 1).

## 5. Historical next-task list (superseded by STABILISATION.md)
1. Parts catalogue: the user is working on this; wait for their data and format.
2. Night hub with a time limit, ticket board with carry-over tickets, real Shop screen
   (`docs/DESIGN_PROPOSALS.md` section 1).
3. Mount-minigame redesign with matching squares, and loose dust specks (section 4 of that file).
4. Grid stash, then case grid with the height number (section 2 of that file).
5. Rename `scenes/main.tscn` to `hardware_bench.tscn` (a small, separate PATCH).

## 6. First thing to do on a machine with Godot 4.7.2
Open the project, press F5, click through the shop, both benches and the final check, and report any red
error text with file and line. Target-editor interactive behaviour remains unverified until that is done. In particular untested:
the 0.7.0 dust/vacuum rewrite and the timed mount minigame, which were only checked as Python models.


## 0.7.2 integrator update — Codex, 12 November 2026
The user's current task supersedes the historical next-task order above: reconcile notes, update/include the five core documents, then stabilise existing features before adding systems. Gameplay is unchanged. All five core files now live in docs/ at document version 1.2. Read them; do not rely on a separate stale pack.
Authority: latest explicit user instruction, then docs/DECISIONS.md and docs/DESIGN.md for scope; CURRENT_STATE.md for implemented facts; DEVELOPMENT.md for code contracts. Local DESIGN_PROPOSALS.md retains proposals and newer agreements but cannot reopen settled daytime/clock rules. If a genuine conflict remains, report it before implementing that decision.
Current sequence: documentation baseline; target-editor playtest; bounded save/progress fixes; proposed behaviour-preserving split of bench_view.gd; then shared PC state. Full inventory/hub/catalogue expansion is not part of this patch. Include all five core documents in every future project ZIP and refresh them whenever accepted scope or state changes.


## 0.8.0 current handoff — Codex, 12 November 2026
Authorised user fixes implemented: shared case/board cell layout, tower/compact previews, on-board cooler/RAM/GPU cleaning geometry, faster 36-bundle cleaning, explicit syringe selection/reset on paste-stage activation, exact dust reload accounting and stale-grade invalidation. PC drawing extracted from bench_view.gd to pc_renderer.gd. Original target remains 4.7.2; actual checks run with 4.6.3. tools/test_regressions.gd passes 71 checks; GUI fresh dust, tool switching, RAM snap and profile previews observed. Payment tested by isolated state/save regression, not full human repair completion.
The user-reported absent dust was not reproduced on a fresh PC; a saved cleaned PC legitimately has no dust. Preserve saved progress, show the clean-resume message, and use New game for a genuinely new ticket. Do not automatically re-dirty a completed customer's machine to mask this distinction.
All five core documents updated to v1.3 and bundled. Read their CURRENT_STATE and STABILISATION sections; prior open-task lists are historical. Keep reviewing code; next gaps include general persistent PC state, actual case assembly, save validation/atomicity and remaining view/controller extraction. Do not start catalogue generation; user owns catalogue design. Every future ZIP includes the five docs and check logs.


## 0.9.0 current handoff — Codex, 12 November 2026
User requested restrained base suction, independent specks, component-blocked access with physical removal, no duplicate syringe control and smoothness review. Broader physics redesign explicitly deferred. GPU/cooler move to tray and back; underneath dust is protected while installed, surface dust follows the part. Final check requires refitting. Removing cooler invalidates paste; mounting it refits. Removal state saves; old fully cleaned saves migrate without adding hidden dirt. Only these two parts are service-removable, not a full inventory implementation.
Current tuning: 51 bundles/34 specks, pull4/range50/ramp0.2. 96 regressions passed in Godot4.6.3 plus GUI GPU removal/exposure/refit observed. Target4.7.2 not run, full human payment session not run. No FPS/performance gain claim; cached blocker geometry and event-position drag fix address identified work/input issues. tools/test_regressions.gd contains reproducible tests.
All five core docs are version1.4 and bundled. Read their newest sections rather than stale historical summaries above. Next user tests pace/challenge, then discusses future physics representation. Do not add vacuum upgrades, a catalogue or a general hub without a task. Log every file change and preserve prior delivered ZIPs.


## 0.10.0 current handoff — Codex, 12 November2026
Current explicit user task added risky pick and similar/inferior substitution. Key4 inspects cooler/GPU trapped dust and attempts extraction with per-stroke risk. Damage saved and final-check gated. Replacements panel permits equivalent/budget purchase only after damaged part removal; purchasing auto-fits and saves tier. Budget cooler affects thermal result; GPU specification metadata awaits future benchmark. No full stock, catalogue, detection/reputation or disclosure mechanics. All five core docs are1.5. New scripts dust_pick.gd and service_parts.gd keep rules/data out of view; simulation has controlled extraction API. Read newest CHANGELOG entry for actual checks. Broader physics redesign remains deferred; user playtests risk/reward now. Keep original safe access path and established once-only payout. Do not interpret an inferior part passing functional check as an instruction to auto-refund or erase the downgrade.

The same unreleased0.10.0 delivery also implements the user's follow-up request for forgiving hardware inventory handling. GridInventory handles three sample pieces, footprints, free storage, slot installation and serialisation. PartMotion handles presentation-only damped following/lift/sway/rotation. job.hardware_trial stores separate snapshots for tower/compact; this sandbox is not connected to repair-PC stock. Unsupported drops restore previous placement with a nonmodal hint; ordinary drawer drops never invoke socket rules. Latest regression count246; read final changelog. Do not claim real collision/throw physics or reuse reference assets.


## Current0.11.0 handoff — Codex,12 November2026
Latest authorised scope: shared tabletop throw/bounce and tactile repair-tool handling, dynamic brush, visible fresh-ticket dust, player inventory connected to replacement fitting. See docs1.6 newest sections; historical sandbox-only/no-throw notes are superseded. Added TableBody,BrushShape,ToolRig and ToolRenderer, linked GridInventory to GameState player stock. Buy stock and Fit owned stock are separate transactions; no second charge. Cooler/GPU removal, protected dust and pick risks remain. Resting service poses save; flight/tool positions do not. Hardware throws safely settle before scene exit. New dirty PC keeps economy but replaces practice work, with ticket-id save guard. Fresh dust failure not reproduced; no auto-re-dirty on opening.325 regressions in Godot4.6.3; actual final checks logged. Target4.7.2/full human payment still pending. No supplier/catalogue/reputation or3D/body-body collision expansion was made. Keep five docs, logs and source versions in future ZIPs.
