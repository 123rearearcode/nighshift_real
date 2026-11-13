# PROPOSAL — Shared PCs, individual parts and saved ownership

Revision 1 · 13 November 2026 · reviewed against main 0.19.3

Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

**For user design review; not approved and not implemented.** This is the design half of WORK_PLAN.md
step 16, prepared while Claude owns Phase 1 step 3. It does not change the work plan, save format,
catalogue or game code. Claude owns engineering, migration implementation and tests.

Read PC_OWNED_PART_MODEL_PROPOSAL.md for the player-facing grid, handling and work-order proposal.
This document is the canonical proposal for record relationships, saving and legacy migration; the
companion must refer here rather than define a second competing save contract. Existing confirmed
choices in DECISIONS.md and MINIGAME_RULES.md take precedence. All field names here are illustrative.

## 1. The shared model in plain words

A catalogue entry describes a model. A part record describes one physical copy. A PC record identifies
one machine and refers to the copies inside it. A work order refers to that PC and remembers what the
customer agreed to. Inventory, repair, building and sales all look at these same records.

Moving between screens must never manufacture a second GPU, change its owner or regenerate a cleaner PC.
One part can change where it is, how it works and who owns it, while keeping the same unique identity.
Two identical RAM sticks share a model reference but have different individual identifiers.

## 2. Proposed records and relationships

| Record | What it needs to remember | What it must not duplicate |
| --- | --- | --- |
| Catalogue definition | Stable model identifier and definition revision; category, labels/details, connector and body geometry, fit/performance/heat data | Individual damage, ownership or location |
| Owner reference | Shop/player or a stable customer identifier | A customer's display name as the only identity |
| Individual part | Unique identifier, model reference, owner, one location, actual working condition, new/used status, faults and discovered information | Another independently editable copy in each screen |
| PC | Unique identifier, principal owner, case-item reference, outer location and an assembly revision | Copies of all contained part records |
| Container | Stable identifier, kind, permitted items, dimensions/mask and parent reference where applicable | Ownership inferred from who can physically reach it |
| Work order | Unique identifier, customer and PC references, reported symptom, agreement/revisions, due date, price/authorisation, current work/claim/delivery state | A separate mutable installed-hardware list |
| Thermal interface | CPU/cooler identifiers, actual material, physical paste result, securing/completion and validity | A timeless good-paste flag usable with any later CPU |
| Delivered record | PC identity, agreed terms, delivered part identities/specification snapshot, claim, time and payment state | Live references alone which rewrite history when hardware changes later |

Use the job's customer/PC references to choose the active work, not a second global 'current hardware'
copy. A new work order can reference an existing returning PC; it does not need to create a new machine.
An empty case can be the start of a player-owned PC before any sale or customer job exists.

Catalogue definitions can remain ordinary project data. Save model references plus a definition revision;
retain compatibility definitions or deliberate migrations when shipped definitions change. Do not silently
resize an owned item or change its specification because a catalogue file was edited. The full catalogue,
its format and new model names remain the user's separate design task; parody brands only.

## 3. One authoritative location

Recommended location choices are: a loose storage placement, a case/board mount, a removed-parts tray,
a temporarily reserved carry, or an explicitly delivered/disposed state. A location names its container
or mount plus logical cells/rotation where needed. A part cannot be both loose stock and installed.

Recommendation: the part's location is authoritative. Slot contents are derived from it; a saved cache,
if needed, is checked or rebuilt rather than becoming a second source of truth. Claude may choose another
representation provided it enforces the same one-place rule. No cyclic containment is allowed.

The PC itself is the one large object in outer storage (D26). Its case item identifies the physical shell
but does not occupy a second outer footprint. Installed parts consume interior space only; removed parts
consume their own loose footprint. A motherboard is an individual part with child mounts, not a permanent
rectangle attached to a screen. Changing it changes available slots through its model definition.

Keep logical placement independent of zoom, animation, free-flight pose and screen coordinates. Connector
fit, body clearance, permitted mounting overlaps and height/depth follow the companion proposal. Those
rules are not implemented by writing this document.

### Ownership is independent of location

Customer property remains customer property on the player's desk (D19). A customer PC's principal owner
helps identify the job, but must not blindly overwrite every contained part's owner. Shop parts fitted for
testing can remain shop-owned and reserved; they cannot also be offered as loose stock. This is bench
substitution/testing, not the excluded customer loaner-PC feature.

**Proposed commitment point:** an explicitly committed replacement transfers a shop part to the customer;
merely test-fitting or dragging it into a socket does not. Record that distinction clearly, then settle any
agreed price under the later transaction design. This recommendation refines the companion's ownership
row; exact UI/payment timing still needs user approval.

A sale/delivery checks ownership of all included copies. Do not allow unresolved customer-owned items
inside a shop listing, or shop test stock to transfer accidentally during collection. Old parts stay with
the customer until returned, purchased or disposal is authorised. Authorised disposal is a distinct state,
not a free addition to saleable shop stock. A separate theft mechanic is not introduced here.

## 4. The same PC across the four activities

| Activity | Reads | Changes |
| --- | --- | --- |
| Repairs | Work order, same PC/parts, reported/discovered information | Actual dirt, material, faults, fitted copies, work results and proposed claims |
| Inventory | Same PC/part locations, dimensions and ownership | Placement/rotation and reservations; not ownership by moving things |
| Building | Owned copies, case/board mounts and fit rules | Assembly relationships; can exist without a customer work order |
| Sales/collection | Actual assembly plus declared specification/claim and agreement | Explicit transfer, archive and money applied once |

An honest approved budget replacement and a concealed downgrade can use the same physical item. The
agreement/claim makes the difference, not a different hardware record. Customer knowledge is separate
from the actual stored faults. A private scam flag cannot automatically expose the player to the customer.
Discovery remains the approved persona-based chance for now; no evidence-system design is added.

After a material or relevant part changes, mark its functional check stale. Its previous measurement can
remain in history but must not certify the changed assembly. Delivered snapshots stay fixed so a later
comeback refers to the actual earlier deal rather than today's edited machine.

## 5. What the save needs to store

| Saved area | Minimum contents |
| --- | --- |
| Header | Save-format version, producing game version and migration source/completion information |
| Economy/progression | Money, upgrades and existing counters; later approved campaign fields without inventing them now |
| Identity allocation | A way to avoid reusing live/archived PC, part, customer, job and committed-transaction identifiers |
| Parts and PCs | Individual records, model references, owners, locations, mount references, conditions/faults, actual assembly |
| Containers | Outer PC footprint, loose placements, logical rotation and any reserved source placement |
| Jobs | Active/unfinished and delivered records, customer/PC links, promises/revisions, claims and one-time payment/transfer state |
| Physical work | Real dust per owning surface, paste/interface state and valid measurements; keep observations separate from hidden truth |
| Selection | Active work-order/PC reference if present; a safe default if its screen is unavailable |

Keep one canonical actual-material value per thermal interface; the screen's syringe selection is not
proof of what was previously applied. Work history may record an earlier material after it is wiped off,
without overriding the current interface.

**Proposed persistence boundary:** real dirt and applied paste should survive a normal leave/reopen. Save
paste distribution and remaining residue when that system is approved, plus whether its mount is locked
and completed. Current trial saves a grade but not the exact paste picture; this proposal does not claim
otherwise. An interrupted unlocked press may cancel safely without granting a result; the residue need
not disappear. Exact in-progress pressing persistence is an open choice below.

Dirt stays on its physical surface: GPU dust follows the GPU; dirt under it belongs to the board/case.
The current snapshot is tied to zone order and displayed geometry. Preserve it through a legacy adapter
until a deliberate surface/local-coordinate migration exists; do not reinterpret its pixel coordinates
as another model's cells. Unknown geometry must not silently become clean.

Tool flights, bristle oscillation, cosmetic dust and sound-loop instances do not need campaign persistence.
For a save during item transfer, recommended first policy is to resolve to the reserved valid source
placement, with the same identity, ownership and stock. No invalid free-floating permanent location.
Bin/hose fill are currently session-local; whether they persist is an open gameplay decision, not a silent
consequence of this model. No campaign dust/time rule changes are approved here.

## 6. Safe transfer and load outcomes

A logical install, replacement or sale changes related records together. Validate destination, capacity,
compatibility and ownership before making the result visible as committed. A failed move must leave the
same usable copies and money; a repeat sale/collection cannot pay or transfer twice.

These are game-state requirements, not a mandate for a database or event-sourcing framework. Claude can
choose compact records and transaction guards. Historical delivery and major work events are useful;
recording every brush contact is unnecessary.

For loading, build and validate a candidate before replacing the live world. Check unique identifiers,
valid references, allowed ownership/location combinations, single slot occupancy, no containment cycles,
finite numerical values, conserved stock and legitimate delivery/payment state. A dictionary which parses
as JSON can still be invalid. A rejected primary should allow a valid backup candidate to be considered.

If a model is unknown, do not silently delete valuable stock or substitute an expensive default. Retain a
compatibility definition where supported; otherwise keep a recoverable blocked record with an explanation
or reject the candidate and try recovery. Unsupported future saves must not be overwritten automatically.
The precise fallback/UI implementation belongs to Claude's save work and needs its own tests.

## 7. Migration from today's single job — proposed, not code

Baseline examined: main 0.19.3, GameState's current format 1 and existing loader. Future format numbering
must be chosen against the actual main when implemented; do not reserve 'format 2' if Phase 3 uses it first.
Preserve an original backup and validate the whole migration before making it the saved active world.

| Existing data | Proposed destination and preservation rule |
| --- | --- |
| money, upgrades, inventory_sequence, ticket_sequence | Carry forward values and safe unique allocation; no reset or repeat starter reward |
| job.id, customer, complaint, state, payout | One linked work order and customer/PC reference; do not create a new payable job for an already-done ticket |
| job.layout | Existing case/board profile via frozen compatibility definitions, not a newly generated build |
| player_inventory records | One part per existing UID, preserving kind/tier/owner/condition; do not duplicate installed sandbox stock |
| inventory_layout; legacy hardware_trial | Keep the recognised active sandbox placement for those same UIDs; older snapshots are alternative views, not extra PCs/stock |
| service_replacements and service_replacement_ids | Recreate the actual fitted service copy with its saved UID when available; remove any duplicate loose listing; conflicts require validation/recovery, not arbitrary preference |
| removed_parts and service_table_positions | Those customer copies are detached at their saved resting placement or a valid recovery tray; still customer property |
| removed_component_records | Preserve old customer copies, condition and identity separately from fitted replacements |
| broken_parts | Apply saved faults to the actual active copy; never heal a broken original during conversion |
| dust and dust_state | Preserve fractions/physical snapshot through the existing geometry adapter; do not spawn a fresh dirty PC or award extra cleaning |
| paste fields, paste_done, scams, temp | Preserve recorded result/material/claim flags and validity limits, including completed work; do not charge paste again or replay discovery |

### Gaps needing explicit handling

1. **Customer hardware is partly implicit today.** Some installed components are drawn from the profile,
   rather than existing as owned stock records. Materialise only those existing fixtures needed for the
   old repair in a legacy PC definition. Give them stable migration identifiers; do not award the player
   a free sellable catalogue or invent unknown CPU specifications/new-used status. Unknown stays unknown.
2. **The hardware bench is a sandbox.** A stock UID installed in its preview must not also become a component
   of the customer's repair PC. Recommendation: preserve it in a separate marked legacy sandbox container,
   referencing the same stock copy and retaining its reservation. It is not a new saleable full PC. Later,
   offer an explicit move-back-to-stock action; do not auto-return it during this migration. Never import
   both historical profile snapshots as simultaneously real assemblies.
3. **Promises were not recorded.** Show old scope/condition/authorisation/deadline fields as 'Not recorded'.
   Do not infer a quote from the player's actual installed part or automatically classify a legacy job as
   a new scam. The reported complaint is not a complete agreement.
4. **Exact paste is absent from old saves.** Keep a completed grade/material as a grandfathered result for
   the unchanged legacy assembly. Show that exact physical residue is unavailable; do not fabricate a
   perfectly spread picture. Relevant disassembly/redo invalidates it under the normal agreed rules.
5. **Old completed jobs are not archived sales.** Preserve the completed/payout guard and current money.
   Do not pay again, create a new customer visit or invent a historical collection date. Where delivery
   was never recorded, keep it explicitly unknown. Archive only facts actually present.

Repeated loading must not repeat conversion rewards, clone parts or allocate new identities for the same
legacy fixtures. Deterministic migration identities or an explicit persisted mapping can achieve this;
Claude chooses the mechanism. Migration failure keeps the recoverable source and should be explained.

## 8. Build order and acceptance handoff

Do not add this model during the constants refactor. First obtain design approval; then give Claude the
record boundaries before typed JobState (step 15), with implementation at step 16 when scheduled. Keep the
first fixture small and reuse the trial content; no suppliers, catalogue generation or new campaign loop.

Start by connecting one existing repair PC and stock to shared identity/location records. Then prove two
persistent PCs can be switched without mixing hardware, ownership or promises. Only then add empty-case
building and real delivery/sale integration under their separately approved rules.

Required later checks include: install/remove/reload the same copy; distinct identical copies; full-space
rollback; mixed ownership before handoff; removed original versus replacement identity; broken-board
persistence; saved dirt/material and stale checks; once-only sale/payment; malformed-reference recovery;
legacy migration repeated twice; no starter-stock duplication; and the sandbox/repair distinction above.
These are acceptance requirements for future implementation, not tests run by this proposal.

## 9. Open questions for the user

1. **Replacement ownership:** should ordinary test-fitting leave a part shop-owned, with ownership changing
   only when the player explicitly commits it as the customer's replacement? Recommended: yes. Payment
   timing remains a separate design choice.
2. **Legacy sandbox stock:** keep installed sandbox copies reserved in a labelled compatibility container
   until the player retrieves them? Recommended: yes, preserving today's reservation without inventing a PC.
3. **Paste persistence:** should leaving mid-press cancel the press but preserve the real deposited paste,
   while completed mounts retain their exact picture in future saves? Recommended: yes. Resuming the exact
   pressure/timer would be a larger follow-up.
4. **Bin/hose maintenance:** should fill persist across screen changes/reloads, or remain session-local as
   today? Recommended eventually persist fill, so reopening is not a free emptying action; not a change now.
5. **First shared-model milestone:** keep implementation to existing repair/stock first, then two persistent
   PCs before building/sales? Recommended: yes. Catalogue creation remains separate.

The companion contains the additional unresolved fit/condition/board-removal choices. None is approved by
this draft. Claude continues Phase 1 step 3; bench_view.gd, tool_rig.gd and game_state.gd are reserved to
Claude and no game-code changes by Codex are permitted until that step's PR is merged. Cross-review only;
no PR is to be merged by Codex under this request.
