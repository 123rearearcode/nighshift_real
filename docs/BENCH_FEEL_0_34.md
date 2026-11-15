# Spool, brush and heavy salvage — 0.34.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User-requested feel fixes, D119–D121.

Room PR #40 (0.33.0) was published/merged after successful CI with the user's explicit approval.
This separate branch preserves the room; its new changes await cross-review, not an automatic merge.

## Playtest

Repair bench starts with Brush equipped and highlighted. **1 = Brush, 2 = Vacuum, 3 = Parts, 4 = Pick**.
Both the legacy bench and the night repair route inherit this. Physics ids remain vacuum 0 / brush 1.
Accepted tool changes explicitly synchronize all highlights; refused changes leave selection alone.

Click the spool. It takes hose onto the reel while pulling the vacuum back. It leaves roughly 140
world pixels deployed, not the full 560/760 capacity in a new coil. Leave it alone and it stays short.
Pick up and pull the vacuum or a hose section: the reel feeds out what is needed, limited by capacity.
A clipped moving clamp can also pull length out. Passive/throw motion alone never feeds hose out. Starting the reel releases a carried hose/clamp pin;
taking the vacuum/rope stops retraction. An upgrade adds capacity without dumping already coiled hose.
Existing hose constraints and a continuous solver still govern routing/reach. Tuning is provisional.

Concrete and heavy appliances can now be nudged, slowly repositioned or tipped, rather than effectively
anchored. They still have several times the mass of ordinary parts; grip force remains below their
weight, with strong damping and lower friction. They cannot be packed as loot. Feel values are not
release balance; user should compare them with normal parts during a dump visit.

## Limits and coordination

Deployed hose length is session-local to a bench instance, like the existing tool positions. It is
not saved across scene exit/app restart. No new save schema, ownership model or real audio assets.
No hand-state-machine change, no GameState edit, no collision resolver rewrite. User directly
requested the narrow hot-file edits; no competing bench PR was open at task start. Claude reviews
ToolRig/BenchView next. Hot files are released for that review/next engineering turn after delivery.
B19 (workshop ticket text overflow) remains a separate open issue; this does not silently fix it.

Tests cover idle short hose, payout by vacuum and rope, capacity/upgrade/repeated spool, brush default
and actual key labels/bindings/highlights, refused switches and heavy-vs-normal native movement.
Existing regressions and full diagnostic playtest are required because bench hot files changed.
No target-hardware performance or graphical/manual playtest claim.
