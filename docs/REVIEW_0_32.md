# Cross-review of Claude PR #39 / integration 0.32.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. PR already merged when review began. Comment:
https://github.com/123rearearcode/nighshift_real/pull/39#issuecomment-6886430199

Reviewed integration-specific diff b40a879..3c1a2fd plus current storage/part-state/night UI code.
Inspected the user's eight-second recording. Godot 4.7.2 headless reproduced the ticket geometry.

## Findings, priority first

1. **P1 — B16, inherited storage crash still present.** Storage sidebar pressed calls _sync_ui,
   which synchronously frees its signal-emitting Button. The user's new video reproduces the
   locked-object error even without adding furniture. The prior local patch was explicitly not
   pushed; merging the old remote branches did not include it. Fixed by the direct room UI in
   local 0.33.0, with no selector/rebuild path.
2. **P2 — B19, night-workshop ticket overflows into the report.** Claude adds Parts.summary to a
   plain Label. Both parts broken produces ticket rect (32,166,630,345), bottom y=511, while the
   report starts at y=425: 86 pixels overlap. This repeats RC-2. Proposed fix: a bounded ticket
   ScrollContainer and a containment test. Not changed by the storage-room task; reported to Claude.
3. **P2 — B20, inherited furniture popup choices overlap.** Direct children of PopupPanel are
   manually positioned despite its Container layout. The recording shows only Tool board being
   usable. Headless baseline confirms all three choice rectangles are identical: (4,4,354,54).
   Fixed locally in 0.33.0 with Margin/VBox and native-click/geometry regressions.

B16 and B20 are inherited integration blockers, not changes introduced by Claude's new shared rule.
The passing 0.32.0 tests did not exercise real furniture-click dispatch or popup geometry.

## What the integration improves

The rack now consumes inventory_components(), so newly supported CPU stock is visible without a
second kind dispatcher (B17). PartStates is pure and shared by legacy/night diagnostic/ticket text,
so the broken-part repair path is consistent (B18). Main-menu containment is also tested.
These changes are preserved by the room work. No hot files were edited or PRs merged in this review.
