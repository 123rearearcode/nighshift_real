# Test policy — 0.22.1

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work · 13 November 2026.
User authorised the test audit recommendations. Gameplay is unchanged; Claude still owns the Phase 2 hot files.

## What runs when

| Change | Required checks | Diagnostic work |
| --- | --- | --- |
| Markdown only, optionally a project version-only bump | Project checker and CI scope tests | No Godot download, style pass or playtest |
| Runtime code, tests, workflow or other non-doc files | Project checker, CI scope tests and all eight Godot suites | Short representative smoke playtest |
| Bench physics/controllers, game data, bench_view, part_motion or playtest driver | Same required checks | Complete original matrix and frame-time measurements |
| Manual workflow run | Same required checks | Smoke by default; select full_diagnostics for full matrix |
| Unknown/missing comparison history | Same required checks | Full diagnostics, conservatively |

A newer push/PR run for the same branch cancels an older in-progress run; different branches remain independent.
The classifier examines actual Git diffs. Only config/version changes are exempt in project.godot;
other settings, code deletions and code renamed to Markdown still require runtime checks. Workflow
changes run the suites too. The scope tests create real temporary Git histories to check these boundaries.

Keep all eight suites while Claude refactors the bench. Do not judge coverage by the headline count:
schema loops and frame loops can count the same scenario repeatedly. A fixed bug's regression test
remains useful; older-save migration tests remain until compatibility is explicitly dropped.

## What was cleaned up

- Removed the historical 8.2–65 second vacuum balance gate. Optional --tuning prints the same simulated
  clear-time observation, without treating teleporting between dirt groups as a human completion time.
- Dust-spawn and pick-inspection counts follow configured zone data; slow-brush conservation compares
  against its initial count. Fresh visibility no longer requires a hard-coded minimum of 70 groups.
- Replaced the obsolete 'Apply paste / syringe' label search with one actual cloth/syringe toggle
  and no redundant direct-dispense button. It inspects action wiring, so text changes cannot fool it.
- Removed duplicate fresh-bench/rack-pickup checks from the broad suite. test_dust_flow and
  test_bench_interactions retain the real input scenarios; partial-work reload and stale-scene ticket
  protection stay in the broad suite.
- The pick's 47 pre-completion frames are all still simulated and observed, but report one combined
  assertion instead of 47 almost identical success counts. Stroke completion has its own assertion.
- Removed the test endorsing tab navigation as a substitute for the securing lever. That behaviour
  conflicts with D57; the correct expectation moved to the pending-contract report, then into required tests in 0.21.0.

## Historical pending-contract lane

Update: 0.21.0 fixed and promoted these cases into required regressions. The pending script is now an
empty stub; the older CI lane/summary wording remains for Claude to retire. The paragraph below records
what the 0.20.1 cleanup did, rather than asserting these defects are still open.


tools/test_pending_contracts.gd checks the intended lever rule on same-tab and cross-tab navigation,
and the selected-tool highlight after a refused switch while gripping the hose. At baseline 0.20.0
these are expected to fail: the known gameplay defects have not been fixed by this test-only patch.
The CI step is explicitly named and non-blocking, writes a warning to the job summary, keeps its log
and does not suppress its nonzero exit. These failures must be disclosed alongside required-suite results.

Claude must fix the bench within its reserved scope. Then move the cases into the required interaction
suite and remove the temporary non-blocking lane. Do not change expected outcomes just to obtain green
results. Fixture setup checks in that file distinguish inability to reproduce from the intended failures.

## Local commands

Use the user's target engine, Godot 4.7.2. Run python3 -I tools/check_project.py for project hygiene and
python3 tools/test_ci_scope.py for the nine CI-selection integration tests. The eight GDScript suites
remain listed explicitly in .github/workflows/tests.yml; each ends with its own summary and exit status.
CI now retains nonzero process exits, continues to later suites and handles missing summaries safely.

- Short diagnostics: godot --headless --path . --script res://tools/playtest_bench.gd -- --smoke
- Complete legacy matrix plus frame times: godot --headless --path . --script res://tools/playtest_bench.gd
- Optional pace observation: append -- --smoke --tuning, or -- --tuning for the full matrix too.
- Known-defect report: godot --headless --path . --script res://tools/test_pending_contracts.gd

Smoke uses two brush angles per part, one vacuum angle, four overlap-click cases and one representative
paste combination, retaining reach and hand-state tables. Full mode preserves the previous matrix; timing
rows naturally vary. Diagnostic tables are observations, not proof of human feel or GPU performance.

## Review and release

Run the full required set once for test/workflow changes such as this patch. After it passes, rerun only
when a relevant edit, failure or unresolved concern warrants it. Documentation-only edits need no fresh
full game run. For behaviour-preserving engineering changes, retain the approved work plan's comparison
of full deterministic tables; intentional gameplay/tuning changes need an approved new baseline instead.
No runtime save, inventory, physics, sound or ownership rules change in this cleanup.


## Performance checks (0.22.1)

Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 13 November 2026.
The eighth required suite, tools/test_performance.gd, checks sleeping/waking constraints, paste cache
invalidation and isolated return values, unchanged texture uploads, bin status and static redraw independence.
It deliberately has no millisecond thresholds: shared runners are noisy.
Run `godot --headless --path . --script res://tools/profile_bench.gd` for the short optional CPU profile,
or enable quick_profile on a manual workflow. It prints mean, p50/p95/p99/max for physics, CPU drawing
and full dirty-PC saves. It does not measure GPU rendering, display latency or player FPS. Saves use a
disposable path and retain safe readback/backup rotation. Run comparison builds sequentially on the same
host, without other Godot tests competing. Full deterministic playtest comparison is still required for
behaviour-preserving changes; the quick profiler does not replace that matrix.
