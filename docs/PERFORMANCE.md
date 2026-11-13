# Bench performance — 0.22.1

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.
User-authorised performance pass based on main 0.22.0, commit
9d9be8ec868ae1f02bfdf1c5e38b292309df257e. Await Claude cross-review and human playtest.

## What changed

- A settled hose can sleep while clamped. Changing the endpoint, pin target/index, anchor, length or
  any obstacle wakes it. Tiny endpoint movements accumulate while asleep. Iterations, collision,
  untangling, spool behaviour and the drawn vacuum attachment remain intact.
- Stuck dust skips tool-distance/access work when neither brush nor vacuum is operating. Pull decay,
  loose/thrown dust, hose flow, fans and saving still run. The existing zero-transform guard already
  avoided moving stationary component dust; another duplicate guard was deliberately not added.
- Paste measures cache by revision. Clear, deposit, wipe and flow invalidate it. Returned dictionaries
  are independent copies. Texture stamps also include material, result/overflow overlays and object
  identity. Changed paste still simulates and redraws normally.
- Bin/paste controls change only when their displayed state changes. Exact empty/full states are part
  of the key even when the displayed percentage is unchanged. Stage entry invalidates paste controls.
- Background, case, board grid and tray draw on a separate CanvasItem. Their retained drawing commands
  survive the animated parent's redraw. Fans, moving parts, dirt, tools and feedback remain dynamic.

## Measured comparison

Same container, Godot 4.7.2.stable.official.ed1daf0bf, headless. Baseline and changed build ran
sequentially with no competing Godot suite. Same profiler script and gestures; fixed 60 Hz ticks,
60 warmup ticks then 240 samples per scenario. Drawing has 30 samples after two warmup frames;
safe full-PC saving has 30 samples. Percentiles use nearest rank. Values below are milliseconds.
The save p99 is the maximum in this short sample; rerun on the player's hardware before setting budgets.

| Physics scenario | Mean before | Mean after | p95 before | p95 after | p99 before | p99 after |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Idle cleaning, free hose | 0.434 | 0.276 | 0.602 | 0.388 | 0.707 | 0.469 |
| Idle cleaning, clamped hose | 3.264 | 0.300 | 3.694 | 0.419 | 4.079 | 0.631 |
| Brushing | 0.825 | 0.696 | 3.963 | 3.660 | 4.301 | 3.977 |
| Moving vacuum | 4.161 | 3.480 | 5.855 | 3.769 | 6.950 | 4.792 |
| Idle paste, clamped hose | 0.521 | 0.048 | 0.736 | 0.063 | 1.603 | 0.113 |
| Paste spreading | 6.365 | 6.255 | 8.445 | 8.612 | 10.773 | 9.988 |

Idle clamped-cleaning mean work fell about 91%. This does not mean 91% higher game FPS.
Paste spreading remains broadly unchanged; the small differences include runner noise and the
simulation's changing state over the sample. The caches principally save unchanged work.

| Other CPU work | Mean before | Mean after | p95 before | p95 after |
| --- | ---: | ---: | ---: | ---: |
| Idle clean draw commands, free hose | 1.267 | 0.926 | 1.773 | 1.089 |
| Idle clean draw commands, clamped hose | 1.412 | 0.935 | 1.535 | 1.090 |
| Complete dirty-PC save | 2.239 | 2.332 | 2.649 | 2.908 |

Save p99: 4.106 ms before, 4.007 ms after. No save optimisation is claimed. This small sample does
not justify asynchronous saving; snapshot capture, JSON, readback and backup rotation remain safe and
synchronous. Larger future inventories may change that result. Autosave scheduling is unchanged.
Static initial drawing is now outside the dynamic parent's draw timer; it runs on configuration changes.
The totals above are CPU drawing-command generation, not total render/GPU cost or display latency.

## Reproduce and keep it safe

Run `godot --headless --path . --script res://tools/profile_bench.gd`, or select quick_profile on a
manual workflow. It takes about seven seconds here and prints mean, p50/p95/p99/max. The script uses
a disposable save and deletes it before restoring the original save path. It does not time importing.

`tools/test_performance.gd` checks sleep/wake and cache correctness without speed thresholds.
Existing suites still protect suction/brush first entry, removal/refit, hose replays, stock/payment,
mount lever and save recovery. Full scripted gameplay tables must match the baseline for this patch;
see CHANGELOG for the actual comparison result. No interactive visual acceptance is claimed.

Future direct writes/restores to PasteSim.h must call mark_changed(). A caller that externally replaces
a texture's pixels must remove its paste_stamp metadata or use a new texture. Configure the backdrop
again if adding a runtime case/profile/layout change. Do not treat animation positions as saved identity.

## Handoff

This branch makes narrow integration edits to bench_view.gd under the user's explicit performance
instruction; it does not edit tool_rig.gd, game_state.gd, the hand-state machine or WORK_PLAN.md.
Claude retains Phase 2 ownership. Cross-review this PR before step 7 so the view split preserves the
new cache invalidation and static-layer contracts. No gameplay design or balance decision was added.
