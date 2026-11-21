# Component lifecycle — accepted direction and staged implementation

Recorded by Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026. The user accepted the bug-audit recommendations. This is an incremental plan;
it does not claim that a complete canonical component registry has already been implemented.

## Invariants

1. A physical part has one stable individual uid, one owner and one location; a model name is not an id.
2. Fitting/removing/testing does not itself change health or permanently transfer ownership.
3. Damage follows the component, not its slot or a same-model neighbour.
4. Collection transfers the intended parts once and preserves the delivered build.
5. Save/load, PC switching and repeat settlement preserve those facts without duplication or loss.
6. A measurement is current only for its relevant configuration. History remains readable.
7. Actual condition and player knowledge are separate. UI/manual/Findings read only allowed evidence.

## Current stage — 0.47.1

The main 0.47.0 model already has stable shop stock uids and temporary custody. New required tests
exercise two customer PCs with identical original GPU models but different faults, two identical shop
GPUs with different uids, separate test RAM, damage/return, active/inactive save recovery, collection,
repeat settlement, historical measurements and final reload. The test asserts stock claims against
actual state; it is not a second source of inventory truth. See `tools/test_part_lifecycle.gd`.

This protects existing supported journeys. It does not turn customer slot-derived ids into physical
ids or make orphan custody recovery safe. L1/L2 in BUGS.md remain Investigating. New scenarios which
fail must get their own reproduction and bug entry, not weakened assertions or silent data cleanup.

## Stage reached in 0.50.0 (Claude, testing bay)

Shop stock records now carry the fields this plan asked for, for SHOP parts: uid, model, owner,
location (drawer / `fitted_in` + slot), actual condition (`condition`, `defect`) and known condition /
evidence (`known`: label, notes, tests, source). Availability and every visible text read `known` only.
A fitted shop test part behaves by its actual condition through a derived job copy (`shop_condition`),
rebuilt from the stock record on load and PC switch. Customer parts are still slot-derived (L1), and a
delivered shop part loses its condition at collection (L3). Do not read this stage as L1/L2 resolved.

## Stage reached in 0.51.0 (Claude, build requests)

A build (D159) is a PC made only of shop parts: no customer original exists, so nothing is set aside in
the drawer and nothing is kept at collection. Every part goes through the existing custody paths
(`shop_fitted`, first-slot `shop_custody`) and `settle_custody` hands them to the customer at collection,
like a test part left in a repair PC. The empty first GPU slot and cooler mount use the existing
`removed_parts` record with placeholder ids that no view, stat or settlement reads (`CustomerPC.first_parts`).
L3 applies to builds too: a delivered degraded or dead part loses its condition at collection. Not a
step towards L1/L2.

## Next stage — before expanding physical customer-part manipulation

Agree a small part-record contract with fields for uid, model, owner, location/slot, actual condition
and known condition/evidence. The exact field names/layout are implementation proposals. Migrate one
part path at a time behind existing adapters; keep one authority and derive old views/stat inputs from
it. Do not maintain two writable registries or infer identity by matching a model name after a move.

Migration acceptance must cover:
- Two identical customer RAM sticks with different condition/knowledge, reordered and refitted.
- Cross-PC movement only where ownership permits; customer property never becomes free shop stock.
- Loose and fitted originals retaining individual identity through upgrade, undo and collection.
- Old saves missing ids: assign each physical instance once, persist it and never reseed on reload.
- Malformed/duplicate ids and orphan custody: preserve data, explain recovery limits and reject unsafe
  transfer. An unknown ticket reference is not permission to unlock or delete a part.
- Failed writes/rollback, temporary test part removed after damage, and a second settlement call.

## AI coordination and integration

Claude's PR #59 currently owns shared GameState/night-session code. This PR intentionally adds tests,
policy and documentation without racing that runtime work. Do not start a concurrent GameState
rewrite from this plan. Coordinate ownership and integrate/rebase against the actual latest main first.

When combining PRs, preserve ALL suite entries (Diagnosis, Part lifecycle and any Generated tickets
suite), the Python register checks and all existing bug ids. Allocate a fresh version and bug ids from
main plus open PRs; do not overwrite 0.48.0 or renumber historical bugs. Fix handoff merge status as part
of integration. Do not claim L1/L2 resolved until their acceptance scenarios run on the real model.

Before generated tickets rely on a stronger solvability guarantee, distinguish an existing working
shop uid from an untested/unknown part and verify physical capability. The generator must not expose
hidden truth or silently mutate customer hardware to manufacture solvability.

## Optional/external data rule (RC-3)

Read an optional value once, validate that local value, then use it. Do not type-check a get() fallback
and then index the possibly absent key. Keep fixtures with missing keys, wrong nested container types,
bad numbers and future-version data. A generalized validation framework is not required by this plan.

## Stage reached in 0.54.0 — delivered physical records (Codex)

The user authorized the audit follow-up. `job.part_instances` owns the identity, actual condition,
defect and known evidence of parts permanently handed over from shop stock. Each record keeps its
original shop uid, catalogue model/kind and customer owner. `parts` remains the legacy model/placement
projection; these records supply physical identity and condition, not a second writable stock store.
A temporary shop part still uses the existing authoritative stock record and rebuilt shop_condition.
At collection, records transfer before stock is consumed; old shared-stock custody is then cleared.

A migrated part removed at the hardware bench carries its record inside its loose entry; refitting
and identical RAM/drive reordering transfer that same record. When it is later replaced and retained
by the shop, the same uid and actual fault return to stock (D158's untested label still applies).
Snapshots on delayed comeback entries/cards are immutable delivery receipts, not independently editable
PCs or newly spawned repair tickets. Existing report-only comeback routing and social effects stay.

Old saves without records keep their prior legacy behaviour. We do not guess already-lost historical
condition or invent uids for all originals. L1 remains open for those originals, stable bench aliases,
full migration/rollback and malformed/orphan recovery. L2 is not solved or silently unlocked. The new
suite is `tools/test_delivered_parts.gd`; preserve it with all existing lifecycle tests.

Current bounded file ownership: Codex owns this follow-up on top of #66's exact head, not a competing
main-based GameState rewrite. Claude cross-reviews it after his #64 -> #65 -> #66 chain, then resumes
his current room/art/playtest follow-up. These live instructions supersede the historical #59 claim
above. Next scheduled structural review remains 0.60.0.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
21 November 2026, Europe/Bucharest.
