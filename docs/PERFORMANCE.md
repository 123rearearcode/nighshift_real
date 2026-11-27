# Bench performance — 0.22.1

Since 21 November 2026 performance reviews are the scheduled Code checker's (every 2 days, see
`docs/CODE_CHECKER.md`); it appends dated sections under "Scheduled performance reviews" at the end.

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

## Scheduled performance reviews

The Code checker adds the newest review directly below this line.

### 2026-11-27: main 1897eda (0.57.2) → df5c03f (0.57.8)

Signed: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), performance reviewer.

Baseline: `1897eda`, the "new" commit of the 2026-11-25 scheduled review (the 0.57.7 section above is
an integration note, not a scheduled run). Runtime changed since then: 15 scripts and `counter.tscn`
(+954/−125 lines; runtime parts of PRs #79, #80 and #83): approved art drawn by `item_art.gd`, `pc_renderer.gd`,
`tool_renderer.gd`, `cleaning_renderer.gd`, `paste_renderer.gd`, `workshop_view.gd`, the testing-bay
inspection pictures and clue overlays, counter art/props, and the storage drawer embedded in the counter.
No hot file (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) changed. Both profiler scripts are identical
at the two commits.

**Method.**
- Build: official Godot 4.7.2.stable.official.ed1daf0bf, Linux x86_64, `--headless`, one 4-vCPU cloud
  container. Each commit in its own git worktree, imported once, then run back to back with no other Godot
  process running.
- `tools/profile_bench.gd` 8 times per commit (runs 1–4 old then new, runs 5–8 new then old);
  `tools/profile_salvage_physics.gd` twice per commit (old/new, then new/old).
- **A/A control (new this review):** a second worktree of the *same* old commit, `profile_bench` 4 times
  alternating with the first, to see how much two worktrees of identical code differ.
- Tables: milliseconds, "run 1 / run 2", the scripts' nearest-rank percentiles. Bench draw and save rows
  have 30 samples, so p99 is the sample maximum. The headless renderer records draw commands but does no
  GPU work, so `draw_cpu` is CPU command-generation time only.

| Scenario | Mean old | Mean new | p95 old | p95 new | p99 old | p99 new |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| clean_idle_free/physics | 0.342 / 0.343 | 0.601 / 0.341 | 0.381 / 0.392 | 1.157 / 0.383 | 0.415 / 0.564 | 1.888 / 0.410 |
| clean_idle_free/draw_cpu | 1.040 / 1.395 | 1.144 / 1.135 | 1.157 / 2.020 | 1.306 / 1.329 | 1.180 / 2.836 | 1.375 / 1.342 |
| save/full_dirty_pc | 2.718 / 2.977 | 3.120 / 3.125 | 2.954 / 3.687 | 4.079 / 3.910 | 3.664 / 3.850 | 4.190 / 7.398 |
| clean_idle_clamped/physics | 0.347 / 0.502 | 0.350 / 0.368 | 0.391 / 0.593 | 0.388 / 0.436 | 0.413 / 0.627 | 0.464 / 0.658 |
| clean_idle_clamped/draw_cpu | 1.115 / 1.108 | 1.180 / 1.225 | 1.202 / 1.306 | 1.322 / 1.631 | 1.781 / 1.358 | 1.396 / 1.784 |
| brush/physics | 0.469 / 0.520 | 0.552 / 0.500 | 0.521 / 0.761 | 0.811 / 0.589 | 0.614 / 0.883 | 0.879 / 0.739 |
| brush/draw_cpu | 1.086 / 1.042 | 1.228 / 1.151 | 1.173 / 1.155 | 1.575 / 1.292 | 1.179 / 1.161 | 1.724 / 1.299 |
| vacuum_moving/physics | 3.613 / 4.355 | 3.665 / 3.768 | 4.049 / 5.942 | 4.073 / 4.650 | 4.359 / 6.115 | 4.527 / 5.553 |
| vacuum_moving/draw_cpu | 1.115 / 1.064 | 1.210 / 1.297 | 1.385 / 1.154 | 1.535 / 1.390 | 1.525 / 1.221 | 1.689 / 1.396 |
| paste_idle_clamped/physics | 0.092 / 0.086 | 0.090 / 0.091 | 0.128 / 0.111 | 0.124 / 0.112 | 0.270 / 0.138 | 0.145 / 0.172 |
| paste_idle_clamped/draw_cpu | 0.296 / 0.250 | 0.352 / 0.316 | 0.400 / 0.364 | 0.474 / 0.382 | 0.774 / 0.381 | 0.536 / 0.409 |
| paste_flow/physics | 5.830 / 5.631 | 6.526 / 5.806 | 7.331 / 7.459 | 10.624 / 7.965 | 7.396 / 10.168 | 13.401 / 9.078 |
| paste_flow/draw_cpu | 0.323 / 0.325 | 0.404 / 0.361 | 0.406 / 0.385 | 0.487 / 0.448 | 0.441 / 0.399 | 0.581 / 0.458 |
| Salvage 20 bodies / fall-and-settle | 0.671 / 0.702 | 0.728 / 0.778 | 0.959 / 0.895 | 1.022 / 1.162 | 1.213 / 1.027 | 1.299 / 2.622 |
| Salvage 20 bodies / late-settle | 0.807 / 0.766 | 0.688 / 0.764 | 1.240 / 0.916 | 0.905 / 0.944 | 1.923 / 1.754 | 1.362 / 2.802 |
| Salvage 20 bodies / pulling | 0.789 / 0.726 | 0.765 / 0.723 | 1.251 / 0.939 | 1.194 / 0.886 | 1.423 / 1.121 | 1.389 / 1.696 |
| Salvage 50 bodies / fall-and-settle | 1.281 / 1.285 | 1.302 / 1.318 | 1.840 / 1.853 | 1.759 / 1.969 | 2.299 / 2.370 | 2.320 / 2.616 |
| Salvage 50 bodies / late-settle | 1.148 / 1.247 | 1.463 / 1.166 | 1.555 / 1.332 | 2.433 / 1.398 | 1.725 / 4.892 | 2.601 / 1.493 |
| Salvage 50 bodies / pulling | 1.132 / 1.199 | 1.231 / 1.204 | 1.310 / 1.460 | 1.513 / 1.394 | 1.470 / 1.849 | 1.558 / 2.358 |
| Salvage 100 bodies / fall-and-settle | 2.137 / 2.087 | 1.952 / 2.176 | 2.933 / 2.565 | 2.458 / 2.760 | 4.043 / 3.574 | 2.678 / 3.135 |
| Salvage 100 bodies / late-settle | 2.123 / 2.088 | 2.103 / 2.040 | 2.911 / 2.753 | 3.153 / 2.278 | 4.580 / 3.055 | 3.923 / 2.507 |
| Salvage 100 bodies / pulling | 2.099 / 2.101 | 1.990 / 2.218 | 2.574 / 2.575 | 2.176 / 2.831 | 2.676 / 3.226 | 2.233 / 3.201 |

Means over all 8 bench runs, paired by run number (ms). "New higher in" counts the 8 pairs.

| Row (mean, ms) | Old min – max (median) | New min – max (median) | Paired new−old (median) | New higher in |
| --- | ---: | ---: | ---: | ---: |
| clean_idle_free/physics | 0.335 – 0.348 (0.342) | 0.334 – 0.601 (0.352) | +0.010 | 6/8 |
| clean_idle_free/draw_cpu | 1.040 – 1.395 (1.071) | 1.105 – 1.501 (1.221) | +0.131 | 7/8 |
| save/full_dirty_pc | 2.718 – 3.275 (2.843) | 2.938 – 3.923 (3.122) | +0.275 | 7/8 |
| clean_idle_clamped/physics | 0.342 – 0.541 (0.350) | 0.330 – 0.400 (0.354) | +0.001 | 4/8 |
| clean_idle_clamped/draw_cpu | 1.070 – 1.233 (1.111) | 1.157 – 1.340 (1.177) | +0.094 | 7/8 |
| brush/physics | 0.469 – 0.523 (0.501) | 0.493 – 0.854 (0.531) | +0.055 | 6/8 |
| brush/draw_cpu | 1.042 – 1.306 (1.094) | 1.138 – 1.267 (1.186) | +0.099 | 7/8 |
| vacuum_moving/physics | 3.378 – 4.355 (3.728) | 3.540 – 4.302 (3.809) | -0.042 | 3/8 |
| vacuum_moving/draw_cpu | 1.062 – 1.403 (1.119) | 1.087 – 1.427 (1.194) | +0.067 | 5/8 |
| paste_idle_clamped/physics | 0.085 – 0.100 (0.088) | 0.086 – 0.147 (0.091) | +0.004 | 5/8 |
| paste_idle_clamped/draw_cpu | 0.234 – 0.317 (0.251) | 0.273 – 0.366 (0.320) | +0.057 | 8/8 |
| paste_flow/physics | 5.457 – 6.010 (5.742) | 5.613 – 6.526 (5.840) | +0.176 | 6/8 |
| paste_flow/draw_cpu | 0.304 – 0.348 (0.331) | 0.351 – 0.540 (0.367) | +0.034 | 8/8 |

A/A control, same commit `1897eda` in two worktrees, 4 alternating runs, means (ms):

| Row | Worktree A | Worktree B |
| --- | ---: | ---: |
| save/full_dirty_pc | 3.525, 3.068, 2.850, 4.477 | 2.810, 2.854, 2.865, 3.026 |
| clean_idle_free/draw_cpu | 1.073, 1.133, 1.109, 1.221 | 1.079, 1.124, 1.249, 1.157 |
| paste_idle_clamped/draw_cpu | 0.274, 0.235, 0.259, 0.243 | 0.253, 0.292, 0.271, 0.259 |

**Result.**
- **Bench draw CPU is slightly higher on 0.57.8, consistently.** Every `draw_cpu` row is higher on new in
  5–8 of 8 pairs; the paired median rises by 0.03–0.13 ms (about 6–27%). The largest relative change is
  `paste_idle_clamped/draw_cpu` (0.251 → 0.320 ms, 8/8); the largest absolute one is
  `clean_idle_free/draw_cpu` (1.071 → 1.221 ms, 7/8). The A/A gap on these rows is about 0.01–0.04 ms, smaller
  than the old→new gap. This matches what 0.57.8 added to the bench redraw (textured rectangles for the
  case, board, parts, fan rotor/frame, tool sprites, clamp, dust bin, paste stage and one dust film per
  dusty zone) and is an expected cost of drawing the art, not a defect. It stays far under a 16.7 ms frame
  (≤ 1.5 ms in every run). **No bug filed.** No GPU/display frame time is claimed.
- **Bench physics: no change.** Rows overlap; paired medians are within ±0.2 ms and split both ways.
  `paste_flow/physics` p95/p99 had one high new run (10.6/13.4 ms in run 1) that did not repeat.
- **Save: noise.** `save/full_dirty_pc` was higher on new in 7/8 pairs (median +0.28 ms), but nothing on
  the save path changed, and the A/A control on identical code spread 2.85–4.48 ms. The same commit
  `1897eda` measured a 3.27 ms median as "new" on 2026-11-25 and 2.84 ms as "old" today. This closes the
  2026-11-25 watch item: the save-row shifts are within container/worktree noise.
- **Salvage physics: no change** (rows overlap at 20/50/100 bodies; that code did not change).

**Code observations (runtime changed since 1897eda).**
1. `scripts/view/item_art.gd`: every lookup builds strings on each redraw. `tool()` concatenates the path,
   then `pixel()` formats a second key with `get_instance_id()`; `board()`/`bench()`/`clue()` format
   paths per call. One bench redraw makes roughly 10–20 such lookups (tool sprite, clamp, bin, fan rotor and
   frame twice, CPU/cooler/GPU/RAM/PSU zones, dust film + `tiled()` key). Each is small; together they are
   a plausible part of the measured draw increase. Textures themselves are cached (misses are cached too).
2. `scripts/view/cleaning_renderer.gd` `draw_dust_films`: one textured rect with a transform per dusty
   zone per redraw; it skips hidden, weightless and ≥98%-clean zones. Bounded by the zone count.
3. `scripts/night/testing_bay_view.gd`: `_process` calls `queue_redraw()` every frame while the lens
   dwells on a spot. Each redraw now runs `clue_texture(i)` per spot, which calls `_record()` (that is
   `GameState.stock_record()`, a `duplicate(true)` deep copy) and `looked(i)` (another deep copy plus
   `PartCondition.known()`/`sanitize_known()`). `_draw_spots` and `_draw_lens` repeat `looked()` and
   `spot_under_lens()`. With 5 GPU spots that is about 15 deep copies and 10 sanitisations per frame while
   the lens is held. Not measured (no profiler covers the testing bay); likely well under 1 ms for one
   record, but it is repeated work.
4. `scripts/rooms/counter_room.gd` `_build_storage_drawer`: the under-counter view is instantiated on
   every counter-room entry, even if the drawer is never opened. One-off room-entry cost, not per frame;
   not measured (the profilers do not cover room entry).
5. `scripts/rooms/under_counter_view.gd`: `_save()` writes synchronously on each drop/bring/send. These are
   click events, not per frame; acceptable. `_draw` reuses its per-view texture cache (`_art`), and redraws
   on mouse motion only while an item is held.
6. `scripts/view/tool_renderer.gd` cloth: two small `PackedVector2Array`s per redraw; negligible.
   `scripts/rooms/room_art.gd` `texture()` itself does not cache, but every caller added in this range
   caches its result (counter art at init, hotspot `_prop_cache`, `ItemArt._load`, under-counter `_art`).

**Ranked optimisation proposals (not implemented by the checker).**
1. *(Unchanged, still first)* B57, morning build-request stall: `scripts/rules/ticket_generator.gd` /
   `build_request.gd`. Still Open; it is the only measured user-visible stall.
2. `scripts/night/testing_bay_view.gd` (owner: whoever holds the testing bay; Codex added 0.57.8): read
   the record and its `known()` once per `_draw`/`_process` and pass them to `clue_texture`, `looked`,
   `_draw_spots` and `spot_under_lens`, instead of a fresh deep copy per call. Keep reading through
   `GameState.stock_record()` (no change to the hot file `game_state.gd` is needed). Measure first with a
   scratch probe; do it only if it shows up.
3. `scripts/view/item_art.gd`: cache by *name* (for example `_tool_cache[name]`), so a repeated
   `tool("hose_clamp")` or `bench("fan/fan_rotor")` is one dictionary lookup with no string building. Low
   priority: the whole measured draw increase is ≤ 0.15 ms.
4. Profiler coverage (Claude, `tools/`): add a testing-bay lens-held redraw case and a counter-room entry
   case, so proposal 2 and observation 4 can be measured rather than estimated. Earlier
   morning/checkpoint/asset-load coverage proposals still stand.
5. Method (checker): keep the A/A control in future reviews; it showed that the save row's run-to-run
   spread is larger than the shifts seen in the last two reviews.

### 2026-11-25 integration: 0.57.7 review of current main 0.57.6 / 842d0c2

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
User-requested critical consolidation of checker PRs #77/#78, not a new scheduled performance audit.

[REVIEW_CONSOLIDATION.md](REVIEW_CONSOLIDATION.md) records the current source comparison,
B59 reproduction matrix and disposition of every #78 observation/proposal. In particular:

- The original benchmark compares 0.56.1 → 0.57.2. Later Batch A/B runtime art and counter paths
  are outside its coverage; Batch C 0.57.6 remains ignored draft art. No current GPU/FPS claim.
- Ordinary pre-dawn counter refresh copies the ticket list **twice**, not four times. The board's
  two-copy text action is separate. A refresh cache is a low-priority 2 → 1 candidate, not measured.
- Save p50 output already exists in profile_bench.gd; do not implement the duplicate median proposal.
  The historical median of run means is a different statistic, and its shift remains inconclusive.
- Acceptance cost needs complete-path measurement. Warm ensure checks an in-memory marker;
  both safe-write transactions read back their temporary files in addition to _main_saved's read.
  Button-driven work is not automatically free of perceptible latency.
- Preserve validation of **all** pending IDs. The proposed front-only check can accept a customer
  when a later pending job is absent; the disposable probe demonstrates the existing refusal.
  A private lookup needs a safety-preserving design, not weaker validation or removal of save guards.
- B57's affordability/cheapest-build work and better morning/checkpoint/asset-load profiling remain
  proposals. Generator/profiler source is unchanged; the old timings were not rerun on current main.

### 2026-11-25: main 960b847 (0.56.1) → 1897eda (0.57.2)

Signed: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), performance reviewer.

Baseline: `960b847`, the "new" commit of the 2026-11-23 review. Runtime changed since then: 6 files under
`scripts/` (PR #75, 0.57.0 first-day customer intake: `morning_text.gd`, `navigation_state.gd`,
`night_session.gd`, `counter_room.gd`, `game_state.gd`, `start_view.gd`; +107/−11 lines). No scene changed.
0.57.1 and 0.57.2 were documentation only.

**Historical evidence imported from PR #78.** Claude's method and timing tables below are retained
unchanged. Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
critically revised the conclusions/proposals for 0.57.7; original narrative remains in
[#78](https://github.com/123rearearcode/nighshift_real/pull/78). See the current assessment above.

**Method (recorded by Claude; not rerun by the integrator).**
- Build: official Godot 4.7.2.stable.official.ed1daf0bf, Linux x86_64, run with `--headless` in one
  4-vCPU cloud container.
- Both commits were checked out in git worktrees, imported once each, then run back to back with no other
  Godot process running.
- `tools/profile_bench.gd` ran 8 times per commit: runs 1–4 alternated old then new, and runs 5–8 alternated
  new then old to rule out order effects. `tools/profile_salvage_physics.gd` ran twice per commit. Both
  profiler scripts are identical at the two commits.
- The table gives milliseconds as "run 1 / run 2", using the scripts' own nearest-rank percentiles. The
  bench draw and save rows have 30 samples, so their p99 is the sample maximum.

| Scenario | Mean old | Mean new | p95 old | p95 new | p99 old | p99 new |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| clean_idle_free/physics | 0.293 / 0.342 | 0.335 / 0.276 | 0.329 / 0.381 | 0.361 / 0.298 | 0.377 / 0.491 | 0.412 / 0.368 |
| clean_idle_free/draw_cpu | 0.963 / 1.192 | 0.896 / 1.042 | 1.103 / 1.266 | 1.042 / 1.175 | 1.131 / 7.439 | 1.072 / 1.342 |
| save/full_dirty_pc | 2.833 / 2.587 | 2.413 / 3.356 | 3.008 / 2.865 | 3.063 / 4.338 | 4.057 / 3.247 | 3.307 / 4.958 |
| clean_idle_clamped/physics | 0.346 / 0.284 | 0.276 / 0.338 | 0.398 / 0.317 | 0.301 / 0.385 | 0.423 / 0.345 | 0.318 / 0.584 |
| clean_idle_clamped/draw_cpu | 0.985 / 1.053 | 1.057 / 1.251 | 1.114 / 1.260 | 1.195 / 1.755 | 1.207 / 1.433 | 1.321 / 2.097 |
| brush/physics | 0.507 / 0.447 | 0.499 / 0.532 | 0.629 / 0.513 | 0.659 / 0.809 | 0.799 / 0.747 | 0.743 / 0.951 |
| brush/draw_cpu | 0.997 / 1.068 | 1.264 / 1.041 | 1.127 / 1.296 | 1.710 / 1.129 | 1.172 / 1.530 | 1.744 / 1.430 |
| vacuum_moving/physics | 3.420 / 3.897 | 3.559 / 3.467 | 3.764 / 6.188 | 5.427 / 3.919 | 4.021 / 6.561 | 6.092 / 5.642 |
| vacuum_moving/draw_cpu | 1.030 / 0.997 | 0.960 / 1.032 | 1.214 / 1.129 | 1.067 / 1.250 | 1.347 / 1.178 | 1.152 / 1.377 |
| paste_idle_clamped/physics | 0.085 / 0.090 | 0.075 / 0.086 | 0.110 / 0.121 | 0.098 / 0.105 | 0.132 / 0.194 | 0.102 / 0.207 |
| paste_idle_clamped/draw_cpu | 0.232 / 0.243 | 0.247 / 0.242 | 0.293 / 0.354 | 0.315 / 0.309 | 0.300 / 0.368 | 0.348 / 0.408 |
| paste_flow/physics | 5.488 / 5.376 | 5.320 / 5.751 | 7.327 / 7.179 | 7.037 / 7.450 | 8.012 / 7.497 | 7.515 / 10.641 |
| paste_flow/draw_cpu | 0.321 / 0.309 | 0.299 / 0.311 | 0.380 / 0.384 | 0.371 / 0.397 | 0.619 / 0.396 | 0.389 / 0.428 |
| Salvage 20 bodies / fall-and-settle | 0.688 / 0.711 | 0.659 / 0.633 | 0.962 / 1.000 | 0.940 / 0.838 | 1.451 / 1.515 | 1.183 / 1.167 |
| Salvage 20 bodies / late-settle | 0.745 / 0.636 | 0.713 / 0.632 | 1.313 / 0.753 | 0.935 / 0.823 | 2.879 / 0.931 | 1.443 / 1.093 |
| Salvage 20 bodies / pulling | 0.684 / 0.720 | 0.663 / 0.727 | 0.841 / 0.958 | 0.831 / 0.878 | 0.887 / 1.218 | 0.879 / 1.437 |
| Salvage 50 bodies / fall-and-settle | 1.213 / 1.441 | 1.161 / 1.238 | 1.470 / 2.012 | 1.676 / 1.669 | 2.325 / 2.526 | 2.138 / 2.545 |
| Salvage 50 bodies / late-settle | 1.351 / 1.265 | 1.252 / 1.271 | 1.432 / 1.861 | 1.748 / 1.510 | 13.514 / 2.314 | 3.028 / 4.066 |
| Salvage 50 bodies / pulling | 1.152 / 1.176 | 1.306 / 1.184 | 1.406 / 1.387 | 1.883 / 1.387 | 1.507 / 1.415 | 1.974 / 2.278 |
| Salvage 100 bodies / fall-and-settle | 2.147 / 2.064 | 2.029 / 1.942 | 3.002 / 2.808 | 2.656 / 2.340 | 3.716 / 4.250 | 3.703 / 2.853 |
| Salvage 100 bodies / late-settle | 2.306 / 2.634 | 1.988 / 2.039 | 2.997 / 3.722 | 2.659 / 2.374 | 3.188 / 4.746 | 3.095 / 2.663 |
| Salvage 100 bodies / pulling | 1.990 / 1.967 | 2.171 / 1.960 | 2.446 / 2.333 | 2.979 / 2.276 | 2.733 / 2.744 | 3.209 / 2.808 |

The save row looked higher on new in runs 2–4, so runs 5–8 rechecked it. Means over all 8 bench runs (ms):

| Row (mean, ms) | Old: min – max (median) | New: min – max (median) |
| --- | ---: | ---: |
| save/full_dirty_pc | 2.548 – 3.586 (2.79) | 2.413 – 3.890 (3.27) |
| paste_flow/physics | 4.920 – 6.298 (5.50) | 5.168 – 7.286 (5.74) |

**Integration assessment — 0.57.7, Codex.** The 2.79 → 3.27 ms median of run means differs by
about 0.48 ms (~17%). Overlapping ranges do not establish that this is noise or rule out a shift;
the report does not retain all eight paired run results or an uncertainty analysis. No reliable causal
attribution or current-build regression conclusion follows. Keep these measurements as historical
960b847 → 1897eda evidence, not a performance clearance for 0.57.6's installed art.

The profilers cover bench CPU physics/draw-command generation, bench dust autosave (snapshot and
GameState save) and salvage physics. They do not measure end-to-end acceptance/checkpoint, counter/room entry, texture
loading, GPU/display frame time, the testing lens or under-counter rendering. Proposed follow-ups and
the corrected two-copy refresh count, existing p50 output and full-queue validation requirement are in
[the consolidation](REVIEW_CONSOLIDATION.md#78-retain-historical-data-revise-conclusions-and-proposals).
B57 remains Open; no optimization or recovery policy is implemented by this report.

### 2026-11-23: main c04a278 (0.50.0) → 960b847 (0.56.1)

Signed: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), performance reviewer.

Baseline: no earlier scheduled review existed, so the baseline is the main commit from 2 days before
(`c04a278`, main at 21 Nov 00:41 UTC). Runtime changed since then: 51 files under `scripts/` and
`scenes/` (PRs #64–#70: build requests, reviews, rooms, under-counter storage, the testing-bay lens and
the PC-owned part model).

**Method.**
- Build: official Godot 4.7.2.stable.official.ed1daf0bf, Linux x86_64, run with `--headless` in one
  4-vCPU cloud container.
- Both commits were checked out in git worktrees, imported once each, then run back to back with no other
  Godot process running.
- `tools/profile_bench.gd` ran 4 times per commit (alternating old/new). `tools/profile_salvage_physics.gd`
  ran twice per commit. Both profiler scripts are identical at the two commits.
- The table gives milliseconds as "run 1 / run 2", using the scripts' own nearest-rank percentiles. The
  bench draw and save rows have 30 samples, so their p99 is the sample maximum.

| Scenario | Mean old | Mean new | p95 old | p95 new | p99 old | p99 new |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| clean_idle_free/physics | 0.404 / 0.377 | 0.368 / 0.372 | 0.531 / 0.412 | 0.398 / 0.413 | 1.211 / 0.608 | 0.424 / 0.468 |
| clean_idle_free/draw_cpu | 1.054 / 1.013 | 1.018 / 0.966 | 1.666 / 1.386 | 1.457 / 1.050 | 1.686 / 1.446 | 2.189 / 1.142 |
| save/full_dirty_pc | 3.073 / 2.825 | 3.035 / 2.963 | 3.783 / 2.963 | 3.853 / 4.939 | 4.041 / 3.818 | 3.863 / 5.440 |
| clean_idle_clamped/physics | 0.380 / 0.411 | 0.387 / 0.395 | 0.420 / 0.595 | 0.443 / 0.477 | 0.454 / 1.177 | 0.558 / 0.662 |
| clean_idle_clamped/draw_cpu | 1.020 / 0.932 | 1.112 / 1.500 | 1.207 / 1.070 | 1.556 / 1.618 | 1.253 / 1.169 | 1.605 / 1.705 |
| brush/physics | 0.562 / 0.516 | 0.538 / 0.556 | 0.878 / 0.543 | 0.608 / 0.804 | 0.963 / 0.573 | 0.706 / 1.075 |
| brush/draw_cpu | 1.446 / 1.022 | 0.939 / 0.936 | 1.617 / 1.398 | 1.038 / 1.037 | 1.621 / 1.508 | 1.092 / 1.213 |
| vacuum_moving/physics | 4.478 / 4.091 | 3.851 / 3.853 | 7.027 / 6.584 | 4.537 / 4.408 | 7.326 / 11.458 | 7.356 / 6.236 |
| vacuum_moving/draw_cpu | 1.102 / 1.044 | 1.131 / 0.982 | 1.663 / 1.510 | 1.490 / 1.266 | 1.677 / 1.520 | 1.521 / 1.296 |
| paste_idle_clamped/physics | 0.104 / 0.094 | 0.109 / 0.095 | 0.147 / 0.114 | 0.147 / 0.119 | 0.186 / 0.122 | 0.594 / 0.126 |
| paste_idle_clamped/draw_cpu | 0.434 / 0.161 | 0.230 / 0.158 | 0.342 / 0.313 | 0.293 / 0.213 | 6.625 / 0.371 | 1.358 / 0.248 |
| paste_flow/physics | 6.035 / 6.631 | 6.260 / 6.444 | 7.730 / 11.660 | 8.185 / 10.097 | 8.315 / 12.070 | 11.991 / 12.869 |
| paste_flow/draw_cpu | 0.267 / 0.249 | 0.237 / 0.350 | 0.581 / 0.364 | 0.305 / 0.440 | 0.737 / 0.431 | 0.316 / 0.552 |
| Salvage 20 bodies / fall-and-settle | 0.610 / 0.520 | 0.584 / 0.440 | 0.780 / 0.725 | 0.782 / 0.598 | 1.353 / 0.951 | 1.389 / 1.635 |
| Salvage 20 bodies / late-settle | 0.614 / 0.549 | 0.494 / 0.410 | 0.756 / 0.736 | 0.601 / 0.598 | 1.157 / 1.077 | 0.795 / 0.652 |
| Salvage 20 bodies / pulling | 0.592 / 0.595 | 0.590 / 0.469 | 0.764 / 0.749 | 0.785 / 0.610 | 0.848 / 1.106 | 0.887 / 0.756 |
| Salvage 50 bodies / fall-and-settle | 1.027 / 0.891 | 0.986 / 0.923 | 1.467 / 1.196 | 1.330 / 1.279 | 1.843 / 1.378 | 1.572 / 1.573 |
| Salvage 50 bodies / late-settle | 1.278 / 0.810 | 0.931 / 0.949 | 1.561 / 1.068 | 1.293 / 1.251 | 1.809 / 1.232 | 1.444 / 1.302 |
| Salvage 50 bodies / pulling | 1.024 / 0.900 | 1.138 / 0.966 | 1.392 / 1.179 | 1.544 / 1.254 | 1.571 / 1.209 | 1.695 / 1.556 |
| Salvage 100 bodies / fall-and-settle | 2.073 / 1.818 | 2.180 / 1.725 | 2.822 / 2.385 | 2.783 / 2.319 | 3.500 / 2.698 | 3.022 / 2.385 |
| Salvage 100 bodies / late-settle | 2.109 / 1.821 | 2.491 / 1.792 | 2.703 / 2.233 | 2.752 / 2.293 | 3.474 / 2.325 | 3.184 / 2.484 |
| Salvage 100 bodies / pulling | 2.062 / 1.701 | 2.058 / 1.775 | 2.672 / 2.221 | 2.739 / 2.315 | 2.802 / 2.264 | 3.035 / 2.426 |

Two rows looked higher on new in runs 1–2, so bench runs 3 and 4 (old / new) rechecked them:

| Row (mean, ms) | Old run 3 / run 4 | New run 3 / run 4 |
| --- | ---: | ---: |
| save/full_dirty_pc | 3.172 / 2.809 | 2.964 / 3.324 |
| clean_idle_clamped/draw_cpu | 1.362 / 0.904 | 1.345 / 0.964 |

Across all four runs, the old and new ranges overlap.

**Result: no reproducible regression in the profiled scenarios.** Every row is within run-to-run noise in
this container. The changes since 0.50.0 do not touch the bench, the tool rig or salvage physics, which is
all these profilers measure. The new rooms, the lens and the storage views are not covered by any profiler.

**Extra measurement: build-request search (scratch script, not committed).** `BuildRequest.cheapest`
(added in 0.51.0) runs on the night→morning step, which no profiler covers. I timed it at `960b847` with a
throwaway SceneTree script, two runs each:

| Measurement | Mean (ms) | p50 (ms) | p95 (ms) | Max (ms) |
| --- | ---: | ---: | ---: | ---: |
| `BuildRequest.cheapest`, 108 need/form/want combinations | 15.4 / 14.2 | 9.4 / 9.1 | 47.7 / 40.1 | 59.9 / 58.6 |
| `TicketGenerator.draw_build`, 24 slots, money 500 | 18.3 / 18.8 | 15.3 / 13.9 | 39.6 / 42.5 | 47.2 / 45.1 |
| `TicketGenerator.draw_build`, 24 slots, **money 0** | **165 / 166** | 175 / 183 | 282 / 262 | 306 / 317 |

The 24 slots are nights 4, 6, 8 and 12 × 6 slots, seed 12345. At money 0, 17 of the 24 slots found no
affordable request, so they ran all 12 attempts.

**Code observations (changed runtime code)**
1. **Brute-force search, nothing cached.** `scripts/rules/build_request.gd` `cheapest()` tries every CPU ×
   every GPU set (tower: all pairs) × cases × quiet options. Each combination calls `_cheapest()` twice (a
   Callable per catalogue part) and `PcBuild.stats()`. `_cheapest_sum()` rebuilds every RAM/storage
   combination on each call. The result depends only on (needs, form, wants) and a fixed catalogue, yet
   nothing is cached.
2. **Late affordability check (filed as B57).** `scripts/rules/ticket_generator.gd` `draw_build()` calls
   `cheapest()` twice per attempt (base and with wants), for up to `DRAWS` = 12 attempts. It checks
   `base.cost > money + deposit` only after the second call. When the shop is short of money, every
   attempt does both searches and then fails. `night_session.gd` `_arrivals()` runs this synchronously for
   each build-request slot (up to 3 arrivals), so a poor shop can stall the morning step for roughly
   0.5–1 s. This estimate comes from the per-slot timings above; the full morning step was not timed.
   *Follow-up, 0.58.7 (Claude):* B57 fixed by remembering `cheapest()` answers and pruning combinations
   that cannot beat the best. The earlier affordability check was not used: the deposit depends on the
   full (with-wants) cost, so checking first would change which requests appear.
3. **Lens re-reads the record every frame.** `scripts/night/testing_bay_view.gd`: while the lens is held,
   `_process` and `_draw` call `_record()` several times per frame (`spot_under_lens`, `looked`,
   `_draw_spots`, `_draw_lens`). Each call is `GameState.stock_record()`, which deep-copies the record, and
   `looked()` also rebuilds `PartCondition.known()`. The dictionaries are small, so the cost is minor, but
   it runs every frame while the lens dwells. Every mouse-motion event also calls `Input.set_mouse_mode`,
   even when the mode has not changed.
4. **Repeated placement filter.** `scripts/rooms/under_counter_view.gd`: `here()` filters every placement
   through a lambda, and the view calls it several times per redraw and per `_refresh` (twice in one format
   string). During a drag, every mouse-motion event queues a redraw. This is cheap at today's item counts
   and grows linearly with them. Saves (`store.write`) run on drop, bring and send, never per frame, which
   is acceptable.
5. **Bounded state, no issue.** In `scripts/state/game_state.gd`, `reviews` is capped at 40 and
   `fake_orders` at 10, so neither grows without bound. `scripts/rooms/room_view.gd` runs `find_children`
   only on setup. Hotspots redraw only on hover or state change.

**Optimisation proposals (ranked; not implemented by the checker)**
1. `scripts/rules/ticket_generator.gd` (gameplay owner): in `draw_build`, check affordability right after
   computing `base`, before computing `full`. The deposit depends on the budget, so either bound it with
   the largest margin or derive the budget from `base` first. This keeps results identical and should
   roughly halve the cost of each failing attempt.
2. `scripts/rules/build_request.gd`: memoise `cheapest()` on (needs, form, sorted want ids) for the session.
   Also memoise `_cheapest_sum()` on (type, need, most) and `_gpu_sets(form)`. The catalogue is constant,
   so repeat attempts and later mornings reuse the results. Add a test that memoised and fresh results
   match.
3. `scripts/rules/build_request.gd`: prune the search. Sort CPUs by price and stop once the CPU alone costs
   more than the best total. Pick the cooler and PSU once per (CPU watts, load) instead of once per case.
4. `scripts/night/testing_bay_view.gd` (0.56.0 owner): read the record once per frame, or cache it until
   `_after`/`_refresh`. Call `set_mouse_mode` only when the wanted mode changes. Turn `set_process` off
   while the lens is down.
5. `tools/` (Claude, engineering): add a morning-step case to a profiler that times `_arrivals` at low and
   normal cash, so later reviews measure it directly instead of with a scratch script.
