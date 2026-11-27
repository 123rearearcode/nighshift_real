# Review of Claude's PRs #87 and #88 — 27 November 2026

Reviewer: Codex (GPT-6; model id not exposed by this session), ChatGPT Work.
This is a bounded review requested before the 0.58.0 antivirus work, not the scheduled structural or
performance review. Neither PR was merged or modified by this review.

## #87 — magnifying-glass clues, head 79ab79b

No blocking finding in the reviewed patch. The panel and lens now use the same revealed picture stack;
source and destination texture coordinates are bounded at the panel edge. On #88's stacked tree
(a8667b7, which includes this exact patch), Godot 4.7.2 Testing bay passed 62 checks. This is automated
coverage of the supplied cases, not human acceptance of the lens's appearance or every edge position.

## #88 — save recovery, head a8667b7

**High / B63 — a new game can lose its own morning backup and restore the previous playthrough.**

`scripts/state/save_backups.gd:16–31,36–45,87–90` puts all runs of a save slot in one folder, orders them
by night number and prunes to three. `scripts/night/night_session.gd:286–306` tries those backups without
matching the run being recovered. New game resets the night number but leaves that folder populated.

Reproduced in actual Godot 4.7.2, using only a uniquely named disposable save:

1. Start a shop, save $777 at nights 20, 21 and 22, taking morning backups.
2. Start a new shop in the same slot: a different run ID, night 1, $100.
3. Its morning-1 backup is immediately pruned. The retained list is morning_0022/0021/0020.
4. Remove the new run's ticket manifest and its fallback copies; load into protected mode.
5. Restore morning: it succeeds with $777, night 22 and the **old run ID**.

Observed output:

```
new_run_differs=true cash=100 retained=["morning_0022", "morning_0021", "morning_0020"]
protected=true restored=true cash=777 night=22 restored_old_run=true
```

Expected: retain the new run's first morning, and recover only a compatible snapshot of that run.
Recommendation: namespace or filter snapshots by the canonical run ID, apply retention within a run,
and add a cross-new-game recovery test. Keeping the previous run archived is fine; silently selecting
it for this run's recovery is not. Also make staging/moving/copying failures preserve or roll back the
original set; those failure branches were inspected, not reproduced here, and are not a second verified
finding.

The supplied Save safety 15 and Night workshop 57 checks also passed with zero failures/script errors.
Their backup fixture clears the folder before New game, so it does not cover B63. Passing those checks
does not clear this new reproduction. Recommend correcting B63 before merging #88.

The opt-in `tools/reproduce_b63.gd` prints observations on a checkout containing #88; on main without
the backup module it explains the prerequisite and exits. It is not a CI test requiring the defect to
remain. No actual user save was changed. No damaged-save graphical playtest was performed.

## 0.58.0 baseline

The feature starts from merged main dfbf5aa (project version 0.57.9), not these unmerged PRs. It does not
edit the lens, backup, manifest, counter-recovery or save-store code. B59/B61 retain main's recorded
statuses; B62 remains allocated by #88. Reconcile the documentation/status rows when those PRs land.
