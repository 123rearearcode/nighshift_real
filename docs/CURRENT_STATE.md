# Nightshift — Current State and Technical Handoff

Version 1.7 · 13 November 2026

## Active baseline
**Update 0.15.0 (13 November 2026, Claude Opus 5.5, model id claude-opus-5-5):** the active trial is 0.15.0 in the user's GitHub repository `123rearearcode/nighshift_real`; main is the integrated baseline, older versions are kept as `archive/vX.Y.Z` branches. Every push runs the checker, the data-schema suite, the regression suite and a scripted bench playtest on Godot 4.7.2 headless (GitHub Actions); the user playtests by hand. Exact check counts per version are in CHANGELOG.md. See DESIGN.md section 18 for what the bench does now. The paragraphs below describe older trials and are kept for history.

Active Godot foundation trial 0.11.0, based on supplied 0.7.1 and reconciliation patch 0.7.2. Servicing, shared model geometry, persistence fixes, removable parts and risky pick/replacement choices implemented. No GitHub push or full production migration was performed.

Engine: Godot 4.7.2 is the user's real version, confirmed 2026-11-12 (a short-lived 4.6.3 claim in 0.11.1/0.11.2 was wrong). The review engine available to Codex was 4.6.3.stable.official.7d41c59c4, so the automated checks ran close to, but not on, the real engine; 4.7.2 verification and human playtesting are pending. **Update 0.12.3:** the automated checks (172 data schema, 344 regression, 0 failures) ran on Godot 4.7.2.stable.official via GitHub Actions on 0.12.2; human playtesting is still pending.

## Implemented in Godot
- Three code-built Node2D screens: placeholder Shop/job menu, repair bench, hardware bench.
- One overheating customer job; cash, one-time payout, square-cloth upgrade.
- Six-zone dust bundle simulation: brush weakens grip, vacuum removes bundles; cleaning progress saved per zone.
- Paste deposit, spread and wipe on a 51 x 51 simulation grid; timed cooler pressure activity; coverage/overflow grading.
- Final check uses dust/paste penalties and a cleanliness gate. All numbers are demo values.
- Two instances of one RAM model and a generic GPU footprint; tower/L-shaped and compact/stepped board preview profiles; four-way rotation, slot type/size/facing checks, hover details and placement feedback.
- Autosave/load of cash, upgrades, job, per-zone dust fractions and paste grade/coverage/overflow to user://nightshift_save.json.
- Contributor handoff, file map, contracts, versioned changelog and Python hygiene checker.

## Persistence limits / stabilisation issues
- Hardware grid and repair replacements now share owned stock/positions (0.11.0); full customer-PC inventory storage is still absent.
- Exact paste picture is not saved, only its result. Re-entering the bench starts with an empty paste simulation while keeping a saved grade. Starting a new deposit or effective wipe now invalidates the saved grade; regression checked.
- Dust restore now tracks partial bundle weight exactly; twenty successive restores at each tested fraction show no progress drift. Exact particle identities are not saved; per-zone fractions persist.
- Save loading checks some containers but not every field type; malformed-save recovery needs verification.
- No atomic-save or backup strategy is established.
- bench_view.gd still coordinates activities and input; PC drawing has moved into pc_renderer.gd. Further UI/mount-session splits remain open.

## Verification
Review of the original 0.7.1: Python checker passed (11 scripts, 20 res:// references, 23 mapped files); import and ten-frame scene starts passed without reported errors in Godot 4.6.3. Reconciliation 0.7.2 repeats checker/import/scene startup on the final package; final results are logged in CHANGELOG.md. These are startup/hygiene checks, not interactive validation.
Claude explicitly recorded no Godot execution. Its changelog reports the user tried 0.4.0; that is second-hand evidence for an older version, not verification of 0.7.1/0.7.2. Target-editor input, visuals, complete repair and persistence roundtrip remain pending.

## Not implemented
Daytime customer flow, Open/Close shop, estimates/pricing/hidden budgets, multiple persistent PCs, continuous night clock/manual pause/overtime, salvage locations, generated suppliers/deliveries, online listings, full relationships/reputation/customer discovery, general grid stash and full case assembly, full catalogue, complete assembly/sales, personal-PC benchmark/failure, B2B/server progression or Steam packaging.

## Source / collaboration
DEVELOPMENT.md sections 5–6 contain the active Godot file map/contracts. Read HANDOFF.md, this document and the relevant DESIGN.md section before edits. User exchanges versioned ZIPs with Claude; this chat coordinates/reviews. No AI repository access is established.
Repository: https://github.com/123rearearcode/Nightshift . User confirmed original docs uploaded; latest remote contents were not independently inspected. Copy accepted project changes manually only after review/testing. Keep one authoritative set of the five documents, not divergent root/project duplicates.

## Historical browser reference
Separate browser prototype v0.9 at https://nightshift-pc-repair-lab.andreicachristoph1.chatgpt.site/ . Last recorded published commit da3f60e09c52e6dec70ea6dc157f296139ba20f6. It had ten tickets, three board profiles, broader stock and technician views, but is a different codebase; do not assume these features migrated to Godot. Browser source is not in this ZIP and local historical checkout availability is not guaranteed.

## Immediate next step
Use STABILISATION.md to complete target-editor manual checks and choose a bounded persistence-fix task. Do not add catalogue content, a full hub or new mechanics as a side effect of this patch. Record checks actually run, update the changelog and include all five documents in the next handoff.


## Verified 0.8.0 additions
Shared pc_layout.gd defines model cells, board origin, case depth and case-mounted items. Both benches derive rectangles from this data; no arbitrary stretching of usable board cells. Hardware preview switches between two case/board sizes, with slots inside usable cells. General case assembly is not built. Fresh dirty bench contains 36 dust bundles; saved clean state is intentionally retained with an explicit message. Syringe selection exits cloth mode. Cleaning suction is faster; a scripted ideal sweep takes about 8.2 seconds (not a human timing claim).

Godot 4.6.3 regression suite: 71 checks passed, including dust initialisation/restore, shared geometry, slot/rotation/cutout/occupancy/depth checks, actual bench tool switching, paste invalidation, one-time payout, reload and upgrade spending/persistence. Test save is isolated from normal saves. GUI checks observed fresh dust, shared visual mounting, cloth-to-syringe switching, RAM drag/snap and both layout previews. Godot 4.7.2, full manual repair/payment playthrough and comprehensive corrupted-save recovery remain unverified. See CHANGELOG.md and tools/test_regressions.gd.


## Verified 0.9.0 additions / supersedes 0.8.0 tuning
One paste-stage/syringe button remains; redundant dedicated syringe button removed. Vacuum 4.0/radius 50/ramp 0.2. Dust 51 bundles + 34 independent single specks across six surface and two hidden zones. Scripted unobstructed vacuum sweep 20.45s, excluding disassembly/user movement; not a human completion-time claim.
ServiceAccess controller manages drag offsets, original slots, tray positions, removal/refit and blocker rectangles. Surface dust moves with a removed component. Hidden dust is not drawn or affected by brush/vacuum while its part is installed; tool paths are also checked against other blockers. Only GPU/cooler are removable in this trial. Job gains additive dust_schema=2 and removed_parts fields. Old fully cleaned saves preserve hidden regions as clean; saved removal state survives load. Payments require all parts refitted. No general PC inventory/assembly is claimed.
Input pickup/drop now uses each mouse event's position rather than polling the latest cursor, avoiding missed queued/quick drags. Simulation remains fixed-step; display redraw is frame-driven, tool velocity is smoothed with delta time, and blocker edges are cached/rebuilt only on access-state changes. These changes were reviewed and checked; no measured FPS gain is claimed.
96 Godot 4.6.3 regression checks passed: earlier payment/persistence tests plus hidden access for both tools, specks, tray geometry/removal/refit, invalid drops, moving surface dust, saved removed parts and event-position drag handling. GUI observed GPU removal, exposed dust and refit. Target 4.7.2 and full human repair/payment playthrough remain unverified. Broader dust/paste physics redesign is deferred for discussion.


## Verified 0.10.0 additions / current scope
Pick controller separates timing/random risk from view input. Key4, hover inspection, progress arc,0.8s extraction attempt and provisional12% per-attempt damage; no hover damage. GPU/cooler only. Damage is saved, outlined red, halts pick use on that part and blocks payment. Installed parts retain the normal vacuum/brush access blocker. Safe remove/clean/refit path remains available.
Replacement window requires removing damaged part to tray. Equivalent/budget purchase deducts cash once, fits the replacement and saves its tier; repeat/unknown/unaffordable purchases fail without charge. Cooler replacement clears paste. Budget cooler adds8C to final check; budget GPU is saved/reported as65% specification, without a real GPU benchmark. Functional inferior parts may complete the job, one-time payout preserved; lower specification appears in final-check notes. Full stock/catalogue, customer detection/disclosure and relationship/reputation effects are not implemented.
246 GDScript checks passed in Godot4.6.3 before final packaging; latest final count/results are in CHANGELOG.md. GUI inspection, successful extraction and corrected readable replacement window observed. Target4.7.2 and a complete human repair-to-payment playthrough remain unverified. Damage/purchase/payment paths are covered by deterministic automated checks. Core docs1.5 are bundled; no GitHub push.


## Free arrangement update — same 0.10.0 delivery
Hardware sandbox now supports two existing RAM instances plus a generic GPU footprint. Drawer12x8 accepts arbitrary free cells/quarter turns, prevents overlap/overflow, highlights socket matches and preserves items after unsupported drops. No INVALID motherboard warning for ordinary drawer drops. New GridInventory controller owns placement/state; PartMotion owns damped visual following, lift, sway and turning. Per-profile sandbox snapshots save via job.hardware_trial and restore across preview changes/re-entry. It is still separate from the repair PC/stock system. Prior statements about single view-local RAM are superseded here. Final regression count246 in Godot4.6.3, zero failures; includes500 randomized rearrangements with no overlaps/lost parts and motion convergence at30/60/144Hz. These are automated checks, not measured render FPS.


## Verified0.11.0 additions / current authority
Shared tabletop dynamics adds reflected edge impacts, spin, height/gravity/floor rebound, damping and rest. Hardware drawer flick-release throws, Shift-release places precisely, settling searches free cells and scene/profile exit settles safely. Repair ToolRig applies damped handling/toss/recovery to vacuum/brush/pick/cloth/syringe. Dynamic brush bristle tips affect loosening directly; contact is no longer a circle. Move-parts GPU/cooler flicks bounce over the repair worktable; picking at the actual body position recovers them. Dust surface nodes follow rigid pose changes. Service resting positions persist.
A single top-level player_inventory now feeds hardware grid and repair replacement rows. Unique owned records and shared inventory_layout prevent duplication; stock is bought into the grid, then consumed on fit without charging again. Installed hardware-board pieces are unavailable as drawer stock. Broken customer originals and consumed replacement ids remain on the repair ticket, outside saleable player stock. Six starting demonstration items are not a release catalogue; general storage/ownership for full customer PCs is still absent. Legacy hardware snapshots migrate once for the active profile; empty stock stays empty. Payout/cloth prices unchanged.
Fresh tickets show71 visible groups plus14 protected groups without Reset; partial dust survives reopening. Saved clean PCs remain clean. Added brighter dust, ticket/visible-group status and New dirty PC keeping cash/stock/upgrades. The stale bench cannot save over a newly created ticket. No fresh-ticket missing-dust bug was reproduced; no unsupported root-cause claim. New dirty PC is a practice-ticket reset, not daytime intake.
325 Godot4.6.3 regression checks passed before packaging; final checker/import/smoke/fresh-extract results are in CHANGELOG.md. GUI observed dust on first bench entry and a new ticket without Reset, physical brush/rack handling, purchase into shared drawer and corrected cooler shapes. Target4.7.2 and full human repair-payment path remain unverified. Physics is a custom bounded tabletop/bristle model, with no inter-object collision, sound, throw-induced damage or persistent flight state. Free tools reset on scene entry. This section supersedes earlier single/sandbox-only inventory and no-throw statements.
