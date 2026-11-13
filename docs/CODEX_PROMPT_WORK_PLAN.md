# Prompt for Codex — work split and code health plan (copy everything below the line)

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5) for the user.

---

Hi Codex. The user (creative director of Nightshift) has approved a work plan and a split of
responsibilities between you and Claude. Please read `docs/WORK_PLAN.md` on `main` (version 0.19.1 or
later) before doing anything else, then the newest `CHANGELOG.md` entry.

**Your role from now on: game design and gameplay features.** That means design documents and decisions
(scams, customers, the dust minigame purpose, and later the design of the shared PC and owned-part model),
new gameplay features and their tests, and feel tuning from the user's playtests. Claude takes
engineering and code health: tests and CI, frame-time measurement, layout and ID constants, a hand-state
machine for bench input, save gaps, and splitting `bench_view.gd`.

**The collision rules (please follow them exactly):**
1. Hot files are `scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd` and `scripts/state/game_state.gd`.
   During Phases 2 and 4 of the plan, Claude owns them: do not edit them, and do not open pull requests that
   touch them. Check the plan's Status table and the newest changelog "Next action" to see which phase is
   active and which hot files are free.
2. One open pull request per hot file. Start new work from the updated `main`.
3. Cross-review: before the user merges a Claude pull request, read it and leave a short comment (what you
   checked, any concern). Claude does the same for yours.
4. End every changelog entry's "Next action" with who goes next and which hot files are free.
5. New mechanics start as a design proposal for the user; build only after the user approves.
6. Unchanged project rules: sign with name, model name and exact model id (D51); a version bump per
   delivery; the changelog template; `python3 -I tools/check_project.py` passing; `archive/vX.Y.Z`
   branches; never claim testing that did not happen.

**What I would like from you now:**
1. Reply with your agreement or concerns about the plan and the split (especially anything that blocks
   gameplay work you have planned). If you disagree with a step's order, say why.
2. Tell me which of your planned features touch the hot files, so we can schedule them before Phase 2
   starts or after Phase 4.
3. If you have repository access, add a short comment to the plan's pull request (or the latest one) saying
   you have read it. Do not change `docs/WORK_PLAN.md` yourself; propose changes in your reply and I will
   decide.

Claude is starting Phase 1 (shared test helper, frame-time measurement, constants, gdlint). Those touch the
test tools, the workflow and new data files; Phase 1 step 3 will touch the hot files briefly (replacing
literals only), and Claude will say so in the changelog before and after.
