# For any AI agent or tool working in this project

Read, in this order: `HANDOFF.md`, `docs/roadmap.json` (the current plan; rule 12), `DEVELOPMENT.md`, the newest
entry of `CHANGELOG.md`, then the scripts you will touch. Do not start from this file alone.

Project rules:
1. Log every change in `CHANGELOG.md` with a new version number (steps in `HANDOFF.md`, section 4).
2. Never say code works unless it was actually run in Godot 4.7.2 (the user's real version). Say exactly what you did run.
3. Do not build anything listed in `docs/DESIGN_PROPOSALS.md` unless the user has asked for it.
4. Sign every edit with your model: name, model name and exact model id (changelog Author line,
   HANDOFF signature, commit messages). Example: `Claude (Opus 5.5, model id claude-opus-5-5)`.
5. Follow the work split in `docs/WORK_PLAN.md`: Codex does design and gameplay features, Claude does
   engineering and code health. Hot files (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) have one owner
   at a time; check the plan's Status table and the newest changelog "Next action" before editing them.
6. Every bug — user-reported, CI-caught or review-found — gets a row in `docs/BUGS.md` when it is
   found, with its root cause filled in when fixed. The structural review every 10 versions and the
   performance reviews belong to the scheduled **Code checker** only (`docs/CODE_CHECKER.md`, user
   decision 21 November 2026); other AIs do not run them and answer its findings in their PRs.
   Follow its one-index/detail format and Fixed versus Verified evidence rules. Run
   `python3 -I tools/check_bug_register.py` and `python3 -B tools/test_bug_register.py`.
   Read `docs/PART_LIFECYCLE.md` before changing ownership, fitting, collection or save migration;
   retain the required cross-PC lifecycle tests. Never claim slot-derived identity or orphan custody
   is solved merely because the existing test suite passes. Coordinate hot-file ownership first.

Every handoff ZIP must include docs/PROJECT_BRIEF.md, docs/DESIGN.md, docs/ROADMAP.md, docs/DECISIONS.md and docs/CURRENT_STATE.md. Read STABILISATION.md for the current milestone. Latest explicit user decisions and the reconciled core docs take precedence over stale OPEN labels in local proposal notes.

8. For every place, door, menu, layout or navigation change, read `docs/MENU_NAVIGATION.md` (0.53.0:
   room navigation, D161). The game moves through rooms and objects, not menus: do not reintroduce a
   hub, tab rows or a service-menu detour. Rooms are art + hotspots (`docs/ROOM_ART_GUIDE.md`). Reuse
   shared navigation and run its native-input tests.

9. Before any art creation/integration, read `docs/ART_PRODUCTION_PROGRESS.md` FIRST for the active list,
   then ART_DIRECTION and ART_ASSET_LOG and inspect art/references. FIRST_DAY_ART_CHECKLIST is temporary;
   follow the permanent tracker's migration/retirement procedure when it completes and remind the user.
10. Art contributors update ACTIVE creation checkboxes and ART_ASSET_LOG with actual per-file creator,
    model/tool/date and edit history. Keep Created, Human approved, Integrated and Visually accepted separate.
11. NO ART may be pushed into the playable game before HUMAN approval of that exact revision/use is
    recorded with evidence/hashes. AI review, a Created checkbox, CI or reference/concept acceptance is
    not human runtime approval. Keep unapproved drafts/reference files non-loaded; changed art needs
    renewed human approval. Never replace a runtime asset or bind scenes/code to unapproved artwork.

12. Read `docs/roadmap.json` before choosing work (0.58.6, user request 27 November 2026). It is the
    machine-readable roadmap: phases, tasks with status (done / next / planned / idea), and the decision desk
    with the user's answers. When your PR finishes or changes a task, update that task in the same PR (keep its
    id; a new task gets a new id in its phase) and set `about.main` to your version; `tools/check_project.py`
    fails if `about.main` differs from `project.godot`. The user edits the live page named in `about.live`;
    if the file and the page disagree, the page wins and Claude syncs the file, except that the latest
    explicit user decisions take precedence over either stale snapshot. D182–D184 cancel the per-part
    minigames and give the replacement monitor desktop step to Claude; the old 0.59.0 per-part reservation
    is released. Cancelled tasks retain their ids in a phase's `cancelledItems` history, outside active
    items and completion totals. Do not start another agent's task or reserved version (0.60.0 checker)
    without the user.
