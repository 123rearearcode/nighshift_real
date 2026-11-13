# Work plan — code health and responsibilities (from 0.19.1)

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5); approved by the user the same day
("go ahead"). Combines Claude's code health review and Codex's improvement list. Each step is one version,
one pull request, all checks green before merging. A step that should not change behaviour must leave
the scripted playtest tables (`tools/playtest_bench.gd`) identical.

## Who does what (user decision, 2026-11-13)
**Codex — game design and gameplay features:** design documents and decisions (scams, customers, the
dust minigame purpose, the PC/owned-part model design), new gameplay features and their tests, feel
tuning from the user's playtests.
**Claude — engineering and code health:** steps 1–15 and 17 below; the build half of step 16 on top of
Codex's design; investigating unclear bugs with the scripted playtest.

## Rules so the two agents do not collide
1. **One owner per hot file at a time.** Hot files: `scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd`,
   `scripts/state/game_state.gd`. During Phases 2 and 4 Claude owns them; Codex works in other files or
   waits. Outside those phases, the agent assigned the task owns them for that version.
2. **One open pull request per hot file.** The next one starts from the updated `main`.
3. **Cross-review.** Each agent reads the other's pull request before it is merged and leaves a short
   comment. The user decides anything that changes game behaviour.
4. **Handoff line per version.** Each changelog entry's "Next action" names who goes next and which hot
   files are free.
5. **Design before code.** New mechanics start as a Codex proposal; the user approves; the file owner builds.
6. **Unchanged:** sign with your model (D51), bump the version, follow the changelog template, keep
   `archive/vX.Y.Z` branches, never claim untested work was tested.

## Phase 1 — Quick wins (no gameplay change) — Claude
1. **Shared test helper and simpler workflow.** `tools/test_support.gd` (check, summary line, temporary
   save path, bench loader); the 7 suites use it; the workflow runs them in one loop. Done when the same
   checks pass and each suite's summary line is still in the log.
2. **Frame-time measurement.** The playtest records physics-tick and redraw times for an idle bench,
   heavy brushing, vacuuming with a moving hose, and flowing paste (average and worst); never fails the
   build. Done when the table is in the log; the user compares once on their PC.
3. **Layout and ID constants.** `scripts/data/layout.gd` (table, PC area, socket, lever, bin, panel) and
   `scripts/data/ids.gd` (tools, stages, parts). No value changes. Done when no coordinate or id is
   duplicated across files and playtest tables are identical.
4. **Code-style checker in CI.** gdtoolkit `gdlint`, report-only first, blocking once the backlog is fixed.

## Phase 2 — Predictable interactions — Claude (hot files locked)
5. **Name every hand state (no behaviour change).** States: FREE, USING_TOOL, THROWING, CARRYING_HOSE,
   DRAGGING_PART, DRAGGING_CLAMP, MOUNTING, PANEL_OPEN, and the allowed moves. A read-only derived state is
   printed in the playtest. Safety net for step 6.
6. **Hand state machine.** `scripts/bench/hand_state.gd` (pure rules); the bench input asks it what a
   press/release means instead of checking ~10 flags. Done when click/pickup/throw tests and playtest tables
   are unchanged and the user confirms the feel by hand.
7. **Transition and failure tests.** Focus lost while holding, leaving mid-mount, tool switch while carrying
   the hose, dropping a part outside the tray, two buttons at once; add the missing focus and window-close
   handling.

## Phase 3 — Saves — Claude
8. **Close the save gaps.** On-screen message when a save fails; save on window close and when leaving
   mid-action; one small migration function per format change (`save_format` 2 when first needed); tests
   for damaged, missing, failed and every recent old save shape.

## Phase 4 — Break up the bench — Claude (hot files locked)
Before step 9: a small public bench test API (click at, press lever, pick tool) and tests moved onto it.
9. Input routing on top of the hand state.
10. One controller script per tool (vacuum, brush, pick, syringe, cloth).
11. Interface building.
12. Replacement panel.
Done when `bench_view.gd` is under about 500 lines and only coordinates.
13. **Break up long functions** (hose step, dust setup, save loading); the hose gets the Python check again.

## Phase 5 — Ready to grow
14. Reusable layout controls, structure only (no visual polish; still deferred) — Claude.
15. Typed job record (`JobState` with explicit save conversion) — Claude.
16. Shared PC and owned-part model, when multiple PCs come — design: Codex; build: Claude.
17. Exported-build checks before release preparation — Claude.

## Features during this plan
Codex may continue features during Phase 1 and Phase 3 (outside hot files when Claude holds them). During
Phases 2 and 4, features must not touch `bench_view.gd`, `tool_rig.gd` or `game_state.gd`; after step 10,
features land in the per-tool scripts.

## Status
| Step | State | Version |
| --- | --- | --- |
| Plan | approved | 0.19.1 |
| 1 Shared test helper, workflow loop | done | 0.19.2 |
| 2–17 | not started | — |
