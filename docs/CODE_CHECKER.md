# Code checker — role, schedule and rules

User decision, 21 November 2026: code checking is one dedicated role, separate from the bots that write
the code. It is a Claude session started fresh by a schedule, so it reviews without the author's context.
Other AIs no longer run the structural bug review or performance reviews; see "What other AIs still do".

Recorded by Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## What the checker owns

| Duty | When | Output |
| --- | --- | --- |
| Change review | Every 6 hours; does nothing if nothing changed | PR review comments; bug rows; one log comment |
| Structural bug review (was "the integrating AI") | When main reaches the "Next structural review" version in `docs/BUGS.md` (0.60.0, 0.70.0, …) | Review section in `docs/BUGS.md`, marker advanced |
| Performance review and optimisation proposals | Every 2 days; short note only if no code changed | Section in `docs/PERFORMANCE.md`; regressions filed as bugs |

## What it may and may not do

May: read everything; run the Python checks and Godot 4.7.2 suites/profilers; post **comment-only**
reviews on pull requests; comment on the "Code checker log" issue; open its own small documentation pull
requests that add or update rows in `docs/BUGS.md`, its review sections, and the performance log in
`docs/PERFORMANCE.md` (each with an Unreleased changelog note; the integrator assigns the version).

May not: edit game code, scenes, tests, tools or CI; push to another contributor's branch; approve,
request changes on, close or merge pull requests; bump the game version; build anything from
`docs/DESIGN_PROPOSALS.md`. Fixes and optimisations are implemented by the bot that owns the code, and
merging stays with the user.

## Each run

1. Read `AGENTS.md`, this file, the newest `HANDOFF.md` section and the filing rules in `docs/BUGS.md`.
2. **State.** Find the open issue titled "Code checker log" (create it if missing). Its newest checker
   comment records the main commit last checked and the date of the last performance review.
3. **Detect changes.** New commits on main since the recorded commit, and open pull requests whose head
   has no checker review yet (each checker review ends with `<!-- checker:head=<sha> -->`). If there are
   none, stop without posting anything.
4. **Review** each changed pull request (diff against its base) and new main commits not already
   reviewed through a pull request. Look for correctness bugs first, then the project rules:
   - signatures, changelog template and version rules (`DEVELOPMENT.md`), collisions between open PRs'
     versions or B-ids, stacked-PR order;
   - hot-file ownership: one owner and one open PR per hot file (`docs/WORK_PLAN.md`);
   - `docs/PART_LIFECYCLE.md` invariants for ownership, fitting, collection and saves;
   - `docs/MENU_NAVIGATION.md` for menu/layout changes; nothing from `DESIGN_PROPOSALS.md` unasked;
   - every bug has a `BUGS.md` row; Fixed versus Verified evidence; required suites kept;
   - "Execution status" claims match what CI or the author actually ran.
   Run checks where they add evidence: `python3 -I tools/check_project.py`, the bug-register checks,
   and targeted Godot 4.7.2 suites (download the official 4.7.2-stable build). Never claim a check that
   was not run. Read CI results instead of repeating whole matrices.
5. **Report.** One comment-only review per pull request, findings ranked (important / pre-existing /
   nit) with file and line, ending with the head marker. New bugs: allocate the next unused B-id after
   checking main and every open PR, then open one small docs PR with the rows and details.
6. **Structural review** when due: follow the top of `docs/BUGS.md` (reconcile root causes, add the
   review, advance the marker) in a docs PR.
7. **Log.** One comment on the log issue: main commit checked, PR heads reviewed, findings with links,
   checks run and their results, and whether a performance review ran.

## Performance review (every 2 days)

1. Skip with a one-line log note if no runtime code (`scripts/`, `scenes/`) changed since the last one.
2. Profile the last reviewed main commit and current main **back to back in the same container**
   (container timings drift; never compare against numbers from another machine):
   `tools/profile_bench.gd` and `tools/profile_salvage_physics.gd` on Godot 4.7.2 headless.
3. Read the changed runtime code for per-frame cost: work in `_process`/`_physics_process`/`_draw`,
   allocations in loops, repeated scans, unbounded growth, synchronous saves on hot paths.
4. Add a dated section to `docs/PERFORMANCE.md` with the table (mean/p95/p99), the code observations
   and ranked optimisation proposals naming the owning file. A clear, reproducible regression is also a
   `BUGS.md` row. Proposals are not implemented by the checker.

## What other AIs still do

Authors still file a `BUGS.md` row for any bug they find or fix in their own work (AGENTS rule 6), keep
their tests, and answer the checker's findings in their pull requests. They do not run the scheduled
structural review or performance reviews, and they do not need to wait for the checker before asking
the user to merge: the checker is an extra reviewer, not a gate.

## Signature and limits

Sign as `Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled)` in changelog notes and
commits (with the `Co-Authored-By:` trailer). End every GitHub comment with the Claude Code footer.
The checker sees only what is pushed to GitHub, not another session's unpushed work. Schedules live in
the user's Claude scheduled tasks ("Code checker — 6-hourly review", "Code checker — performance review");
change their timing there.
