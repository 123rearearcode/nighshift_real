# Art production progress — permanent queue and agent entry point

23 November 2026. Author: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
This is the permanent place agents read to find **what art to create next**. Read ART_DIRECTION for the look and ART_ASSET_LOG for credits, revisions and human approvals. Do not infer active tasks from old handoffs or completed checklists.

## Current routing

| Field | Current value |
| --- | --- |
| Lifecycle phase | FIRST_DAY_ACTIVE |
| Active creation list | [FIRST_DAY_ART_CHECKLIST.md](FIRST_DAY_ART_CHECKLIST.md) |
| Creation status | 5 / 18 created (ART-06 to ART-10, Batch B, Claude, 0.57.3); the others unchecked |
| Human approval for in-game art | ART-06 to ART-10 rev 2 approved by the user 25 Nov 2026 (hashes in ART_ASSET_LOG) and integrated in 0.57.3; nothing else. Reference/look acceptance is not installation approval |
| Next creation dependency | ART-01 composition/anchors with ART-05 storage-capacity layout: Batch A, assigned by the user to ChatGPT (23 Nov 2026). Batch B props currently use interim placements in the placeholder counter; align them to ART-01 anchors when it lands |
| Next asset work after layout | Follow the first-day list's minimum counter subset and P0/P1 dependencies; no new tabletop props |
| Ongoing authority | ART_DIRECTION + this routing/queue + ART_ASSET_LOG |
| Retirement state | First-day list still useful; do NOT delete now |

These counts are an initial snapshot, not another per-asset ledger. Update this summary when the active
list changes; individual Created checks currently live ONLY in the first-day checklist. Per-file credits,
approvals and delivery evidence live ONLY in ART_ASSET_LOG. Resolve disagreement from actual files and
human evidence; do not tick tasks to make the summary match.

## Rules before choosing or delivering work

1. Read this document first. Check its lifecycle phase and active creation list before using an older prompt.
2. Claim a bounded ID/owner in ART_ASSET_LOG; read dependency/layout/anchor decisions. No overlapping art edits.
3. Create drafts only for the assigned approved scope; preserve names, source and editor credits.
4. Update the ACTIVE creation checkboxes and log per-file creator/model/tool/date, revision/hash, source,
   dimensions/alpha/anchors/states. A file existing is not integration or human approval.
5. Obtain explicit human approval of the exact artwork revision before it enters the playable game.
6. Before binding art into scenes, verify the recorded human approval still covers those bytes and use.
   Record the integration commit separately; headless tests and AI review do not confer approval.
7. After each delivery check whether the first-day creation list has completed and follow the transition
   below. Remind the user when it becomes obsolete; do not leave future agents on a dead task list.

## Human-approval rule — mandatory (user, 23 November 2026)

**No art may be pushed into the playable game without human approval first.**

- Draft creation/sharing may use non-loaded `art/drafts/` or `art/references/`. They must stay disconnected
  from gameplay. This is not an exception allowing unapproved assets to be bound on a feature branch.
- Until approval, do not copy artwork into auto-loaded paths such as `art/rooms/counter.png`, assign it
  to runtime scene textures, preload it from code, replace a live sprite, or include it as new game-facing
  content. This includes room art, characters, icons, UI skins, textures and animation frames.
- A human must approve an identified preview/revision for in-game use. Record approver, date, evidence
  (chat/PR reference or exact user quote plus context) and exact file hashes/revision in ART_ASSET_LOG.
  If a human reviews a batch, enumerate the covered files/revisions. Do not invent approval evidence.
- "Keep this look for now", generating a concept, checking Created, code CI passing, an AI approving,
  or a general instruction to merge documentation is NOT blanket approval of later game art.
- Changed pixels/frames/meaningful visual edits invalidate approval for the changed files until the human
  approves the revised version. Untouched files retain their own approvals; copying byte-identical approved
  files may retain approval if the approved use still matches. Verify hashes and scope.
- Keep Created, Human approved, Integrated and Visually accepted separate. Approval permits integration;
  it does not prove game alignment/occlusion/handling works. Report those checks truthfully afterwards.

This is a documented agent policy, not a new automated CI approval gate. No unapproved art is installed
by this governance patch. Existing reference PNGs stay reference-only and are not retroactively promoted.

## First-day transition — required once creation is complete

Trigger: every required ART-01–18 deliverable is Created with real file/credit metadata, or the user has
explicitly recorded a scope adjustment for any omitted task. Existing generated references alone do not
satisfy this. Human approval is never waived by a creation checkbox or by a scope-adjustment shortcut.

The coordinating/integrating agent (Codex unless reassigned) must:

- [ ] Verify created files, checkboxes and the credits ledger agree; identify all remaining approval,
  integration, testing and acceptance work. Do not hide unfinished work in a completed creation list.
- [ ] Populate the continuing queue BELOW with those outstanding items and the next user-authorized art
  batch. Preserve ART IDs, creator/edit history, file hashes, constraints and dependency links. If the
  next creative batch is undecided, list the specific decision needed rather than inventing new scope.
- [ ] Change phase to CONTINUING_QUEUE and Active creation list to this document. Update LIVE pointers
  in AGENTS, newest HANDOFF, ART_DIRECTION, ROOM_ART_GUIDE, WORK_PLAN, core-doc current notes and README
  to send agents here; ART_ASSET_LOG remains the credits/approval record.
- [ ] Tell the user the first-day creation checklist is complete and that this queue now drives future
  work. Include remaining approval/integration work and say the old file is now transitional/obsolete.
- [ ] Reduce the old first-day file to a brief redirect/historical pointer while other branches migrate;
  keep its completed state recoverable via a named git commit. Do not maintain two live task lists.
- [ ] Once retirement conditions below hold, delete the obsolete live file and repair all live links and
  DEVELOPMENT's file map in the same docs PR. The user has requested this eventual cleanup; no new art
  approval is implied by document deletion. Report the retirement and remind the user at that point.

The transition must occur even if some Created art is still awaiting human approval: carry that work
into the continuing queue, with in-game integration BLOCKED until approved. Don't keep a completed
creation checklist as the permanent scheduler just because approval is pending.

## Continuing queue — becomes active after first-day creation

Currently **not active**; no additional art scope has been commissioned by this document.

| Queue ID | Work / source ART IDs | Dependencies | Creation state | Human approval / integration state | Owner | Next action |
| --- | --- | --- | --- | --- | --- | --- |
| NEXT-REVIEW | Carry forward any created first-day files awaiting human review | Created files + credit/revision records | Await actual handoff | Not approved; do not integrate | Unassigned | Populate exact paths/hashes at phase transition |
| NEXT-INTEGRATE | Integrate only specifically human-approved first-day revisions | Recorded human approval + agreed runtime owner | No new art implied | Blocked until approvals | Unassigned | Preserve grid/occlusion/navigation and existing tests |
| NEXT-ACCEPT | Verify the playable counter/repair slice and record remaining issues | Approved assets integrated | No new art implied | Not yet visually accepted | Human playtester + implementer | Confirm readability, layers, storage and first-day flow |
| NEXT-SCOPE | Define the next art milestone after the first-day slice | Current milestone disposition | Not created | No art approval | User / Codex | Ask for bounded scope when this becomes next, not build arbitrary rooms |

When active, add stable tasks with actual per-task creation checkboxes immediately below this table;
use IDs such as ART-19 onward, retain source IDs for revisions and distinguish art creation from reviews
or integration. Keep only one active creation list; do not duplicate the retired ART-01–18 checkboxes.

## Retirement conditions and reminder

Delete FIRST_DAY_ART_CHECKLIST.md from the LIVE tree only when:
1. Creation is complete or explicitly rescoped, phase CONTINUING_QUEUE is active and all remaining work
   and constraints have been transferred here/ART_DIRECTION/ART_ASSET_LOG.
2. Live agent entry points and current prompts point here; any open branch relying on the old list is
   updated, merged, or its needed instructions are copied to the permanent docs.
3. Credits, approvals and completion history have durable file paths and a named git commit reference;
   no required metadata is lost. Immutable release-history mentions may remain as provenance, but live
   relative links must be migrated or use a pinned historical commit when appropriate.
4. The new routing is present in the current handoff and there is no remaining unique active instruction
   in the old file. Validate links/file map and report deletion in the changelog/PR.

If any condition fails, keep only the needed transition pointer and record what blocks removal here.
Do not delete the current file just because this long-term tracker now exists. Today it is incomplete.

A daily ChatGPT condition-watch was created at the user's request to check completion/obsolescence,
prepare deduplicated docs-only transition/retirement PRs when the conditions hold, and remind them.
It complements, not replaces, the coordinating agent's delivery-time checks. It must never merge,
approve art or install it. Stop the one-purpose reminder after retirement and
notification are complete; if the schedule is unavailable, keep these repository rules operative.
