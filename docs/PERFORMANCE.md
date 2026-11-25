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

### 2026-11-25: main 960b847 (0.56.1) → 1897eda (0.57.2)

Signed: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), performance reviewer.

Baseline: `960b847`, the "new" commit of the 2026-11-23 review. Runtime changed since then: 6 files under
`scripts/` (PR #75, 0.57.0 first-day customer intake: `morning_text.gd`, `navigation_state.gd`,
`night_session.gd`, `counter_room.gd`, `game_state.gd`, `start_view.gd`; +107/−11 lines). No scene changed.
0.57.1 and 0.57.2 were documentation only.

**Method.**
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

The old and new ranges overlap in every row. The save median is about 0.5 ms higher on new, but the only
change on the save path is one extra key (`opening_customers`, an empty array after intake) in
`GameState.save_game()` and one more key compared in `NightSession._main_saved()`. That is not a plausible
cause of 0.5 ms, and old runs 5, 6 and 8 reached 3.2–3.6 ms too. I treat it as container noise and will
recheck it in the next review. No bug is filed.

**Result: no reproducible regression in the profiled scenarios.** The 0.57.0 change does not touch the
bench, the tool rig or salvage physics, which is all these profilers measure. The counter room and the
opening intake are not covered by any profiler, so the notes below come from reading the code.

**Code observations (changed runtime code)**
1. **No new per-frame work.** None of the 0.57.0 changes are in `_process`, `_physics_process` or `_draw`.
   `counter_room.gd` `_refresh_room()` now checks `GameState.opening_customers.is_empty()` once per
   hotspot. That is an O(1) check, and `_refresh_room()` runs on events, not every frame.
2. **Each "Accept PC" click does several synchronous file operations.**
   `night_session.gd` `accept_opening_customer()` calls `ensure()` (reads the marker), then
   `opening_cards()`, then `checkpoint()`. `checkpoint()` calls `ensure()` again, then `save_game()`
   (writes the main save), `_main_saved()` (re-reads the save and JSON round-trips 11 keys) and `_write()`
   (writes the ticket manifest). That is two writes and at least one full re-read per click. On the failure
   path there is one more `save_game()`. This runs on a button press, not on a hot path, so it is acceptable
   today. It uses the same checkpoint cost as switching PCs.
3. **The opening card rebuild is quadratic in tickets.** `opening_cards()` calls `ticket_job()` for each
   pending ID. For non-active IDs, `ticket_job()` calls `jobs(gs)`, which deep-copies every ticket
   (`tickets.duplicate(true)`). So a rebuild does O(pending × tickets) deep copies of full job
   dictionaries, and it runs once on room entry and again inside every accept. With today's 2 demo PCs this
   is negligible. `load_game()` caps `opening_customers` at 64, so the growth is bounded.
4. **Already there before 0.57.0, still unchanged.** In `counter_room.gd`, each `_refresh_room()` calls
   `_open_tickets()` three times (badge plus twice in `_board_text()`) and `_called()` once, and each call
   deep-copies all tickets through `NightSession.jobs()`. 0.57.0 did not add calls. B57 and the
   2026-11-23 proposals 1–5 are still open: `ticket_generator.gd` and `build_request.gd` did not change.

**Optimisation proposals (ranked; not implemented by the checker)**
1. Still the top item: the 2026-11-23 proposals 1–2 for B57 (`scripts/rules/ticket_generator.gd` early
   affordability check, and `scripts/rules/build_request.gd` memoisation). B57 is the only measured stall
   in the game.
2. `scripts/night/night_session.gd` (gameplay owner for 0.57.0): add a non-copying lookup, for example a
   private `_find_ticket(id)` that returns a reference for read-only use. Use it in `opening_cards()`, and
   have `accept_opening_customer()` validate only the front ID instead of rebuilding every card before
   `checkpoint()`. This removes the O(pending × tickets) deep copies and one redundant `ensure()`.
3. `scripts/rooms/counter_room.gd`: compute `_open_tickets()` once per `_refresh_room()` and pass it to
   `_board_text()` and `_called()`. This takes 4 deep copies of the ticket list per refresh down to 1. Low
   priority, because refreshes are event-driven.
4. `tools/` (Claude, engineering): the 2026-11-23 proposal 5 (a morning-step profiler case) is still open.
   Add the save scenario's median to the bench output, so later reviews can settle drifts like this run's
   save row without extra runs.

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
