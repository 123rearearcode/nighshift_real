# Handoff - read this first

**Project:** Nightshift, a 2D pixel-art PC repair and shop-management game for Steam. This folder is a
small Godot 4.7.2 foundation trial, not the game. **Version at handoff: 0.27.0.**
**Owner:** the user, the creative director, a complete beginner. GitHub is connected; scoped branches/PRs are current workflow, with ZIPs available for playtests.

**Signed:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026, 0.27.0 native dumpster physics (also 0.26.0 salvage demo). Earlier contributors: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026, 0.22.1. Earlier contributors: Claude (Sonnet 5.5, model id claude-sonnet-5-5), working in a chat session, 2026-11-12, up to 0.14.1; Claude (Opus 5.5, model id claude-opus-5-5), same session, 2026-11-13, 0.14.2 to 0.15.1. Codex: read docs/HANDOFF_FOR_CODEX.md.
**Claude did not run Godot.** Subsequent review ran the automated checks in Godot 4.6.3, not the user's real version 4.7.2 (confirmed by the user on 2026-11-12). **Update 0.14.0:** GitHub Actions ran the automated checks on Godot 4.7.2.stable.official (headless): 172 data schema and 344 regression checks, 0 failures, on 0.12.2. Still pending: human interactive validation (looks, feel, mouse and keyboard play) on 4.7.2.

## Current update 0.27.0 — real 2D dumpster physics trial

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
Same entry F5 → Salvage demo, now side-view with native rigid-body gravity/collisions/support/collapse.
Pull with bounded forces; lift over the visible rim before packing. E opens containers/strips PCs;
boxes become hollow frames and bags flatten, revealing the same physical contents. World release drops
in place; cargo rollback restores committed grid. Actual grip travel costs time once. Pause/focus/menu
handling preserves isolated session custody; app exit/Reset still loses this demo's progress.
Read new body/world contracts and D103. Ten suites include native engine-frame tests, plus an optional
20/50/100-body fall/settle/pulling profiler. Placeholder graphics and rigid bags, no final feel acceptance.
All five core docs revision 1.15. No hot file/customer/software/shared-save change. Existing PR #33 is
updated rather than opening a second salvage PR. Claude cross-reviews; do not self-merge. Keep 0.26.0
archive/ZIP as the previous prototype. This is an experiment; final minigame format depends on playtest.

## Current update 0.26.0 — playable salvage sandbox

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
F5 → Salvage demo. Two test cars/sites, physical layered searching/opening/stripping, sorting, trunk
packing, effort/travel budget and few-day cycles. Only in-memory state through menu/revisits; app exit
or Reset clears it. Return/unload are sandbox transactions, not campaign stock or saves. Read
SALVAGE_DESIGN_PROPOSAL.md, D98–D102 and DEVELOPMENT's contracts. Claude's merged 0.25.0 customer/FPS/
boot rules are preserved. No hot file, customer/software code, WORK_PLAN.md or shared state was changed.
User approved the design and requested code; this first isolated slice is implemented under D91. Shared
clock/save/stock/PC adapters remain Claude's work before campaign integration. All timings/loot/cars are
tuning. Simple shapes, layered nudges and outline bags are not final graphics/3D cloth. User must assess
feel and layout; target-engine headless results are in CHANGELOG. Nine suites now include salvage.
This PR supersedes unmerged design PR #31 (renumbered to avoid Claude's customer D92–D97); preserve both
contributors' records if shared docs/version numbering advances again. Cross-review; do not self-merge.

## Current update 0.25.0 — the customer model, first wave

Signed: Claude (Fable 5, model id claude-fable-5), working in a chat session, 14 November 2026.
The user approved docs/CUSTOMER_MODEL_MAP.md point by point before any code (D92–D97). Customers
now have professions, personas, trust, budgets and NEEDS; the boot test replaces the required-power
threshold (any output passes as long as the PC starts); the shop can buy video games (Counter
Stroke 2) and an fps simulation says how the PC runs them; the first passing final check scores
the PICKUP 0–100 against the customer's real needs, writes trust and history into the save
(`customer_state`, the shop's property, survives new_game), and says when an unhappy customer
comes back. Split: Claude owns this customer/software part; Codex builds the dumpster-salvage
minigame in parallel (docs/CODEX_PROMPT_SALVAGE.md); Claude cross-reviews Codex when both are
done. The software-checks monitor screen (boot test, anti-virus, Vapor store, overclocker) is the
next wave — the rules behind it are built, the screen is not.

## Current update 0.22.1 — bounded performance pass

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.
The user explicitly authorised the measured performance recommendations. This isolated PR makes narrow
bench_view integration edits; it does not change tool_rig, game_state or hand rules. Claude retains
Phase 2 ownership and must cross-review before merging/continuing step 7. Read docs/PERFORMANCE.md
and the newest changelog. Settled clamped hoses now sleep and wake on changed constraints; paste
measurements/uploads and bin/paste controls skip unchanged work. Static case/tray commands live on
a separate CanvasItem. Paste height-field writes must invalidate its revision. No save format or
asynchronous-save change. Eight required suites (new cache/wake contracts); quick profiling is optional.
No interactive visual/feel acceptance is claimed.

## Current update 0.20.1 — test cleanup only

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.
The user explicitly authorised test cleanup during Claude's engineering work. No scripts/ files change;
Claude retains the three hot files. Read docs/TESTING.md. Seven required suites remain; copied rack/fresh
checks and historical balance assertions are reduced, full diagnostics are selective and a smoke mode
is available. The existing lever bypass and rejected-selection highlight are honest, non-blocking
pending-contract failures, not gameplay fixes or passing coverage. Claude fixes/promotes those cases.
Do not merge this PR until Claude cross-review/user acceptance. Next action and exact checks: CHANGELOG.

## Current update 0.19.1 — work plan and split of responsibilities

Signed: Claude (Opus 5.5, model id claude-opus-5-5), chat session, 13 November 2026.

The user approved `docs/WORK_PLAN.md`: 17 code-health steps in 5 phases, and a split: **Codex** does design and gameplay features, **Claude** does engineering and code health. Hot files (`scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd`, `scripts/state/game_state.gd`) have one owner at a time; during Phases 2 and 4 Claude owns them. Cross-review each other's pull requests. Prompt for Codex: `docs/CODEX_PROMPT_WORK_PLAN.md`. Docs only; no game change.

## Update 0.19.0 — bin feedback, hose recovery and silent audio

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

Read AUDIO_DESIGN.md for the new silent contract. AudioFeedback only emits events, never sound; sim/rules/state do not depend on it. View owners stop loops on stage exit/tree exit, cooldowns/history are bounded and freed owners are pruned. New test_audio_and_vacuum.gd runs in CI. No save migration.

Video: bin fills around 35 seconds, intentionally stopping extraction; switching tools used to overwrite its only warning. Persistent status and Empty bin action fix that confusion. Tool/service rows are regrouped. Hose 2-opt untangling plus rare pinned-fold arc reseeding fix replayed crossings. Pinned reach now reserves segment count, not straight-line distance. Exact recovery feel needs human testing; no claim of graphics QA.

Cooler request is interaction design, not art. Pressure/release and lever feedback goals accepted; exact new puzzle still proposed. Back cancels unfinished mounting rather than bypassing the physical lever. Preserve existing grading/completion gates.

## Current update 0.18.0 — trapped threads, clamp, reach and mount put-down

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026. User reports 0.17.1 pickup/removal working.

Trapped dust now exposes partial chains with a count; precise suction slowly extracts real hidden mass. Three representative chains per housing keep the view readable; specks use shorter tails after chains are removed. Disassembly remains easier; risky pick is unchanged. Normal tools cannot clean through the housing center.

Clamp supports left/right drag and stationary left-click unclip. Replacement-stock button no longer overlaps it. Entire footprint stays outside PC/bin; occupied hose reach still applies. Standard hose is shortened to 560 px, upgrade 760 px (provisional), with rotated-nozzle corner reach verified on both case profiles. Existing upgrade ownership is retained.

Recording diagnosis: right-button handling was blocked by mount.active, so tools could not be put down until the lever ended mounting; paste also inherited the cleaning mode's parts restriction. Mounting now parks tools and permits right-drag put-down throughout the lever-wait phase. This neither locks the cooler nor bypasses good-result completion. New regression/CI suite: test_bench_feedback.gd.

Cooler visual ideas are discussion proposals only (DESIGN_PROPOSALS section 6). Keep D52/D57 and existing pressure rules until an explicit redesign is selected. See latest changelog for target-engine results; no human graphical acceptance of 0.18.0 claimed.

## Current update 0.17.1 — recording-led input bug fix

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

The user's recording narrowed the stall to putting down and picking up tools. Reproduced on active 0.17.0: the resting-tool pickup branch returned with holding=false, so the entire held-left movement did no work until release/reclick. This explains why a freshly auto-equipped vacuum could work while later pickup appeared broken. The pickup branch now preserves the held press, including paste tools picked up from the rack.

Second confirmed fault: in Move parts mode the resting-tool hit test ran before component dragging. A parked vacuum/brush over the GPU/cooler intercepted the click, selected a tool and prevented removal. Parts-mode press/release now takes priority. Both components are tested through removal, actual under-dust vacuuming and refit.

New regression: 7 of 11 failures before the fix; expanded post-fix checks and target-engine results in CHANGELOG. This is a reproduced input cause, superseding earlier root-cause uncertainty for this recorded path. Historical 0.17.0 notes remain correct about what was known then. No dust-physics/tuning/save-format change. User visual acceptance of this patch is still needed.

## Current update 0.17.0 — dust restoration/travel and movable clamp

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

Read DEVELOPMENT's 0.17.0 contract and newest changelog before editing. Initial, reopened, New dirty PC and legacy reset use shared initialization. Physical dust saves preserve looseness, locations and traps; old fraction-only saves migrate without erasing progress. Light brush contact now loosens visibly. Top-surface access is explicit, and vacuum can collect already-moving dust immediately. A switched-off vacuum cannot delete loose dirt on a timer.

Fast brushing scatters dust across the case; installed GPU/cooler catch it underneath, filter catches it with stronger grip. Area mass/progress transfers; case total never counts movement as removal. Case interior is a ninth zero-spawn area; initial particle count is unchanged. Dirty areas can become dirty again. Service-tray surface dirt stays on extracted components. Fan-driven redistribution remains queued, not implemented by this task.

Right-drag the clamp around the desk; whole footprint is kept outside PC/bin and within desk, with occupied-hose reach respected. Left-click with empty hands unclips; Shift-right-drag hose pickup is unchanged. Fixture position is session-local.

Root-cause boundary: the original first-entry stall was not reproduced on a controlled fresh 0.16.0 ticket (fresh and New dirty PC gave equal suction). Tests now exercise first entry, saved reopen, legacy saved progress, New dirty PC and reset through actual bench input, including brush response. Fixes address lost physical state, light-contact feedback and access/suction behaviour; do not claim a user-save-specific root cause was established without that save. See checks in CHANGELOG; human acceptance remains needed.

## Current update 0.16.0 — start screen and hose

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026. The user identified the model as GPT 6.1 Sol; use this signature going forward. Earlier truthful unavailable-id notes remain historical. The user authorises merging all open PRs and reports testing the other AI's work. Only #10 was open at inventory; it is now merged. Older PRs were already merged.

F5 opens `start.tscn`: New game starts the existing shop demo; Load resumes saved state (disabled if no readable save); Achievements explicitly says unavailable. Existing saves are replaced only after confirmation. Startup without a save initialises memory without writing a new save. Shop's Main menu saves first. No save-format change.

Hose collisions use full square cooler/GPU housings (including link/corner checks); tools and hand-carried parts pass above the hose. Right-drag of a held tool takes priority. Shift + right-drag explicitly grabs the hose; right-drag also works with empty hands. Drop it in the visible desk clamp; empty-hand click or re-grab releases. Clamp arrangement is session-local and does not change upgrades/bin/paste/economy rules. Geometry/placement and hover are trial UI tuning.

Checks: target Godot 4.7.2 headless schema, regression and start-screen suites; see newest changelog for results. No interactive graphical acceptance is claimed: no display server was available for the attempted native launch. User playtest remains the next step.

## Documentation update 0.15.2 — read before historical notes

Signed: Codex (GPT-6, model id not exposed by this session) in ChatGPT Work, 13 November 2026. Exact deployment id is not exposed; this does not satisfy D51's exact-id requirement and must not be disguised with an invented id.

Gameplay is unchanged from 0.15.1. Accepted: A/B/D/E/F/G/H; excluded: C. Read DESIGN sections 19–20, DECISIONS D58–D60, MINIGAME_RULES and SCAM_DESIGN_PROPOSAL. Promises must be visible; actual work, agreement, claim and functional result must remain distinct. Detailed UI/balance/remedies are proposals. Do not claim those rules are coded.

Next: human-test 0.15.1, then scope persistent agreements, cleaning/claim separation and one archived toothpaste comeback. Preserve vacuum-only removal, physical lever, customer ownership and persona-based discovery. No evidence system. Python checker run for docs hygiene; no new Godot run. Branch `design/scam-direction`, PR only, do not merge. Historical notes below are superseded where inconsistent.

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
4. Fill in **Author** and **Based on** (previous version). **An AI must sign with its model:** name, model
   name and exact model id, and where it ran, e.g. `Claude (Opus 5.5, model id claude-opus-5-5) in a chat
   session`. Sign the same way when you update this file's **Signed** line and in your commit messages.
   If the model changed during your work, name every model that made edits. A person writes `(human)`.
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
