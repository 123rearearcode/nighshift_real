# Review consolidation — 0.57.7, 25 November 2026

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Original discovery and historical measurements: Claude (Opus 5.5, model id claude-opus-5-5),
scheduled Code checker / performance reviewer. His attribution and measurements are retained.

The user requested a critical review and one replacement PR for
[#77](https://github.com/123rearearcode/nighshift_real/pull/77) and
[#78](https://github.com/123rearearcode/nighshift_real/pull/78), leaving the merge to the user.
Both reports were based on main **0.57.2 / 1897eda**. This consolidation is based on main
**0.57.6 / 842d0c2**, after merged Batch B #79, Batch A #80 and Batch C drafts #81.
No gameplay fix or optimization is implemented. The only executable addition is an opt-in,
disposable-save diagnostic; it is not registered as a CI regression test.

## What changed since the reports

`1897eda..842d0c2` changes six loaded runtime files: counter.tscn, counter_art.gd,
counter_room.gd, hotspot.gd, room_art.gd and under_counter_view.gd. The intake/session/save logic,
build generator and profiler scripts reviewed below are unchanged. Batch C remains in ignored
draft paths; ART-16 pixel revision 2 still awaits human approval. This review changes no art or approval.

Reproduce the source comparison from this repository:

```sh
git diff --stat 1897eda 842d0c2 -- scripts scenes
git diff --exit-code 1897eda 842d0c2 -- scripts/night/night_session.gd scripts/state/game_state.gd scripts/state/save_store.gd scripts/rules/ticket_generator.gd scripts/rules/build_request.gd tools/profile_bench.gd tools/profile_salvage_physics.gd
git show 960b847:scripts/rooms/room_view.gd
```

The final command shows that checkpoint-gated room navigation already existed before 0.57.0.
This is bounded revalidation of these PRs, not the next scheduled structural/performance review;
the structural marker remains 0.60.0.

## #77: retain B59, correct its trigger and impact

**B59 remains Open, severity High** under the register's blocked-loop definition. Reproducing a bug
does not make it Fixed or Verified. The original Medium rating understated the blocked core loop;
irrecoverable ownership loss has not been demonstrated, so Critical is not justified.

Official Godot **4.7.2.stable.official.ed1daf0bf**, Linux x86_64, headless, was run against 842d0c2
with the versioned diagnostic below. Each fixture creates a new uniquely named disposable save,
sets up the existing two real jobs, changes only its own manifest/queue, cold-loads the main save,
and enters the actual current counter scene. No real player save is modified.

```sh
godot --headless --path . --script res://tools/reproduce_b59.gd
```

Observed results (before the diagnostic's explicit accept attempt):

| Fixture | ensure / protected | Pending / cards | Visiting | Accept |
| --- | --- | --- | --- | --- |
| Valid manifest | true / false | 2 / 2 | true | true |
| Missing primary, valid matching .bak | true / false | 2 / 2 | true | true |
| Unparseable primary, valid matching .bak | true / false | 2 / 2 | true | true |
| Unparseable primary, valid matching .tmp | true / false | 2 / 2 | true | true |
| No usable primary, .bak or .tmp | false / true | 2 / 0 | false | false |
| Readable wrong-run primary, valid matching .bak | false / true | 2 / 0 | false | false |
| No manifest, only inactive job pending | false / true | 1 / 0 | false | false |
| No manifest, only recovered active job pending | false / true | 1 / 1 | true | false |
| No manifest, queue cleared (control for suggested skip) | false / true | 0 / 0 | false | n/a |
| Valid manifest containing active job only, both IDs pending | true / false | 2 / 0 | false | false |

All pending cases disable the workshop door and refuse workshop navigation, switching and end-night.
In the four healthy controls this is the intended intake gate, and acceptance succeeds. In the damaged
cases acceptance fails and the queue stays unchanged. The no-pending protected control enables the
door, but navigation still fails at `RoomView._navigate()` → `NightSession.checkpoint()`; switching
and end-night also fail. All ten fixtures preserved money, inventory and the active job (zero
setup/ownership failures). The diagnostic prints observations rather than asserting that a blocked
route is desirable; exit 0 establishes setup/ownership checks, not a B59 fix.

Specific corrections to #77:

- `SaveStore.read()` tries primary, .bak and .tmp, returning the first parsable dictionary. A missing
  or unparseable primary alone is not enough to trigger B59 when a matching fallback is usable.
- Application-level validity is checked later. A parsable wrong-run primary prevents trying a valid
  .bak; this was reproduced, not merely inferred from the code.
- Zero cards is not universal. A queue containing only the recovered active ID still displays a slip,
  but protected mode refuses acceptance. Missing an inactive pending job produces the empty window.
- “Stuck for good” and “only New game” are too strong. Restoring the valid manifest in the fixture
  left warm `ensure()` false (cached protection); a cold reload/session reset then returned true and
  restored both cards. External restoration must be followed by a session restart/cold load.
- “Skip intake” is not a complete remedy. The unchanged shared room checkpoint also refuses protected
  navigation. The pre-0.57.0 claim that the recovered active PC was always reachable is unsupported:
  checkpoint-gated room navigation already existed at 960b847. A recovery design must consider both
  intake and protected navigation, while preserving every unrecovered ticket and the original files.

The final fixture tests the safety constraint relevant to #78: `ensure()` can succeed with an otherwise
valid manifest containing only the active job, while a later pending ID is missing. Current full-queue
card validation refuses acceptance. Validating only the first ID would remove that protection.
Do not manufacture lost jobs, silently consume missing pending IDs, or erase a queue as a performance fix.

## #78: retain historical data, revise conclusions and proposals

The dated 2026-11-25 section in [PERFORMANCE.md](PERFORMANCE.md) contains Claude's original timing
tables/method and clearly attributed integration corrections. No fresh comparative benchmark is
claimed here; absolute timings from another container would not revalidate his comparison.

| Claim or proposal in #78 | Current disposition and reason |
| --- | --- |
| No new per-frame work in 0.57.0 | Retain for that historical diff. Later counter art adds drawing/asset-loading paths, outside that claim and both profilers. No current FPS/GPU or art-loading conclusion follows. |
| Save mean drift is container noise | Inconclusive. The median of eight run means rose 2.79 → 3.27 ms (~17%). Overlapping ranges do not rule out a shift. Only two complete tabulated runs and aggregate ranges/medians survive in the report, without all eight paired results or uncertainty. Neither a regression nor its absence/noise attribution is established. |
| Accept PC file work is acceptable because event-driven | Synchronous cost exists but has not been timed end to end. Warm ensure reads an in-memory marker, not a file. Each successful checkpoint has two safe-write transactions and at least three JSON file reads, including both temporary-file readbacks and _main_saved, plus backup rotation. The bench save scenario measures GameState.save_game, not this complete path. |
| Opening rebuild is O(pending × tickets) | Retain, with payload/copy costs. The queue's 64-entry cap limits pending IDs only; it does not bound total manifest size or per-job payload. Current demo intake has two jobs. |
| Four ticket-list copies per counter refresh | Correct to two in an ordinary pre-dawn refresh: clipboard badge and _called for the shutter. _board_text is invoked by the board action, not refresh, and separately calls _open_tickets twice. At dawn the shutter's called branch is skipped. |
| B57 affordability / cheapest-build memoization | Retain as the leading measured performance follow-up in the reviewed scenarios. Generator source is unchanged; 165–317 ms values remain historical 960b847 measurements, not new current-build timings. “Only measured stall in the game” overstates coverage. B57 stays Open. |
| Private lookup, validate only front ID, remove ensure | Reject as written. A private lookup may avoid repeated deep copies, but must validate all pending IDs and preserve snapshot isolation, cold-bind protection, ownership and checkpoint verification. The missing-later-ID fixture demonstrates why front-only validation is unsafe. No guard is proven redundant by this review. |
| Cache one open list per refresh, four copies to one | Low-priority candidate, corrected to two copies to one pre-dawn. The board action is a separate two-copy case. Preserve independent returned snapshots; no measured current benefit is claimed. |
| Add save median output | Drop: profile_bench.report already prints p50_us, including save/full_dirty_pc, at both the old baseline and current main. Per-run sample p50 differs from the median of run means above. |
| Add morning-step profiling | Retain as a coverage proposal. Also measure complete acceptance/checkpoint latency and counter entry/asset loading cold versus warm, with representative ticket/stock sizes. Retain paired results before deciding a budget or an optimization. |

These are reviewed dispositions, not approval to implement gameplay/recovery changes. Preserve safe
save readback/backup behavior and the missing-ticket guard. Anti-virus 0.58.0, part tests 0.59.0 and
the checker's next structural review 0.60.0 remain reserved. Validation actually run for this delivery
is recorded in the newest CHANGELOG entry. Source PRs remain historical provenance; the new PR is
the combined integration for human review and remains unmerged.
