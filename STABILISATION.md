# Stabilisation — existing-feature reliability milestone

Trial 0.7.2 · 12 November 2026. This patch establishes a reconciled baseline, not a declaration that the trial is stable. No gameplay or save-format change is made.

## Pass conditions
| Check | Current evidence / next action |
| --- | --- |
| All docs and version references agree | Reconciled; checker run on final fresh extraction |
| Project imports, each scene starts | Headless Godot 4.6.3 startup checks; not target-editor/input verification |
| RAM accepts matching type, footprint and facing; rejects cutouts/occupied slots | Code exists; manual target-editor test pending |
| Scene changes do not lose progress unexpectedly | Hardware state intentionally resets; dust/paste limitations documented; interactive check pending |
| Dust before/after reload is unchanged | Whole-bundle restore may round upwards; reproduce with partial progress and repeated reload before fixing |
| Redoing paste cannot keep a stale passing grade | Test partial paste, leave/re-enter, start redo, check before mounting; saved grade versus empty simulation is a known risk |
| Payout happens once and survives restart | Guard exists in GameState; actual save/reload test pending |
| Damaged save fails gracefully | Test missing, invalid JSON and wrong-type fields using a backup/test save; field validation incomplete |
| Current minigames are usable | Human playtest in target Godot; no AI smoke test substitutes for this |

Keep backup save files and baseline ZIP. Each bug-fix delivery gets a patch version and checks reproducing the bug before/after. New persistent hardware state changes the data contract and should be a separate minor feature task.

## Simple manual test session
1. Import the project in Godot 4.7.2 (the user's real version; report the actual version if different). Start New game; note starting cash.
2. Open hardware bench; try valid RAM placements/facings and invalid drops; return to shop. Record the current reset-on-reentry limitation rather than claiming it is saved.
3. Partly clean a zone; leave/re-enter and restart the app several times. Compare percentages and remaining dust.
4. Complete cleaning; apply/mount paste; return and reload. Confirm grade persists, while exact paste picture is intentionally absent.
5. Start redoing paste after reload, leave before mounting, then run the final check. Report whether old grade still counts.
6. Complete the job and note payout; check again and restart. Confirm no duplicate payout. Buy the cloth and verify money/ownership survive restart.
7. Record exact errors, observed outcomes and engine version. Report each check separately; do not mark everything passed from a single successful startup.

## Proposed bench-file split — explanation and boundaries
Current bench_view.gd is a combined cleaning screen, paste screen, mounting-session controller and drawing routine. Size alone is not the bug; unrelated responsibilities make changes harder to isolate.

Proposed responsibilities:
- bench_view.gd: small coordinator, stage switching, navigation and calls to shared job state.
- cleaning_view.gd: dust drawing/input and cleaning UI; calls DustSim, does not reimplement physics.
- paste_view.gd: paste drawing/input and its controls; calls PasteSim.
- mount_session.gd: pressure/time/result session, accepting input values rather than reading mouse keys or drawing. Uses PasteSim; placement in the sim/controller layer must be recorded in DEVELOPMENT.md.
Keep existing dust_sim.gd, paste_sim.gd and GameState roles. Names are proposals; do not create empty abstractions just to match this list.

Do not split everything at once. First capture current behaviour and persistence tests. Extract cleaning presentation in one patch, retest; extract paste presentation in another, retest; then move mount-session control if still useful. Preserve controls, tuning, saved data and results. Fix save bugs separately so behaviour-preservation can be assessed.

## Handoff requirements
Include the full project plus five core docs. New contributor states base version, exact files changed, runtime engine/version, checks and failures. Update the technical map/contracts and CURRENT_STATE.md. Do not claim GitHub was updated without an actual push. No catalogue, new hub or balancing changes during this milestone unless explicitly assigned.


## 0.8.0 update
Completed in code/regressions: fresh dust initialisation, exact dust restore without reload inflation, syringe/cloth state changes, saved-grade invalidation on redo, one-time payout across checks/reload and upgrade persistence. Shared case/motherboard geometry and height checks added; PC drawing extracted. GUI verified fresh dust, paste tool switch, valid RAM drag/snap and both demo profiles in 4.6.3.
Still pending: target 4.7.2 validation, human completion/pace feedback, malformed-save recovery/atomic writes, persistent hardware installation and full case assembly. Further split proposal remains relevant; PC renderer is the first extraction. Do not call all stabilisation complete.


## 0.9.0 checks and remaining limits
96 automated regression checks cover blocked hidden dust (brush/vacuum), blocker paths, independent specks, translating part-surface dust, tray bounds for two model profiles, valid/invalid drag/refit, actual queued mouse positions, saved removed-state and payment denial while a part is missing. Existing payout-once/reload/upgrade checks remain. GUI GPU removal/exposure/refit observed. Full test/packaging results in changelog.
Smoothness changes: cached blocker corners; rebuild blockers only when removal state changes; frame-driven redraw separated from fixed-step simulation; time-based velocity smoothing; event-position pickup/drop in both benches. Still pending: target4.7.2, user judgement of pace, save atomicity, broader schema validation and the future physics model. Current loose-bundle timeout/removal remains simplified; do not call this a physical collision simulation.


## 0.10.0 scoped follow-up
Test the pick versus safe removal trade-off. Key4 hover is safe; holding can damage cooler/GPU. Remove damaged part to tray, choose equivalent/budget replacement, verify money and saved specification. Replacing cooler requires fresh paste; budget cooler adds heat. Check damaged machines cannot receive payment and completed functional downgraded jobs pay only once. Customer discovery/reputation/disclosure remain future scope. Target-editor4.7.2/full human completion still pending; automated checks use4.6.3.

Free storage follow-up: test pickup/drop in empty drawer cells, quarter turns at bounds, collisions with other parts, slot installation/removal, Esc/outside rollback, profile changes and save/load. Confirm no part loss or duplicate occupancy. Motion is visual and must never influence saved coordinates. Physical throwing, collision simulation, pickup sounds and shared shop/customer inventory remain future work.


##0.11.0 verification follow-up
Test use/right-drag toss/recover for all five tools, physical brush contact, part flick/refit and drawer flick versus Shift-place. Test purchase adds a visible owned part, installation consumes same UID once, installed hardware stock is unavailable, empty/full inventory cannot duplicate or silently lose cash. Fresh ticket dust must appear immediately; partial and fully cleaned progress must reopen faithfully. New dirty PC keeps economy and does not receive old scene's save. Confirm no clipping during large-item rotation.325 automated checks in4.6.3 cover these; full human target4.7.2 repair/payment remains pending. User's original fresh-entry dust report was not reproduced. No body-pair collision, throw damage or full catalogue was implemented.
