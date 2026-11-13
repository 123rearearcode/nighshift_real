# Proposal: one shared PC and owned-part model

Revision 2 · 13 November 2026 · reviewed against main 0.19.3

Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

**Status: design proposal for user approval. No mechanics, save format or game code changed.**
Completed for user review while Claude owns Phase 1 step 3. Claude retains engineering ownership under WORK_PLAN.md.
The save/record/migration companion is [PC_MODEL_PROPOSAL.md](PC_MODEL_PROPOSAL.md), the canonical proposal for those boundaries. This document focuses on player-facing behaviour, grid fit and acceptance examples. Claude chooses implementation
classes, file boundaries, validation and migrations. Do not treat this proposal as permission to build.

## 1. What this should make possible

The RAM on the table should be the same RAM after installation, removal, storage and sale. A customer
machine should remain the same machine when opened on another screen or resumed tomorrow. The player
should freely experiment with arrangement while money, condition, ownership and promises remain reliable.

This supports the agreed nested grids, complete PC assembly, repairable motherboards, replaceable CPUs,
physical stock, customer PCs in inventory and honest or dishonest substitutions. It does not start the
catalogue, supplier market, cooling simulation, campaign or new repair minigames.

### Existing decisions retained

| Decision | Requirement preserved |
| --- | --- |
| D02–D05 | Generic visible names, model details on inspection, many models later; cases, shaped boards and compatible slots; physical handling |
| D19 / D26 / D34 | Removed parts remain customer property; whole PCs occupy one outer footprint; stash/case/board grids nest |
| D35–D36 | Height/depth and data-driven catalogue; exact production units and catalogue format remain open |
| D43 / D46 / D48 | Forgiving free storage, rotation, bounded handling and gentle collisions |
| D52–D53 / D57 | Actual material and good repaste result, explicit completion, physical securing lever |
| D58–D60 | Accepted scams A/B/D/E/F/G/H, C rejected; visible promises; agreement, work, claim and function stay separate |

The trial already has shared player stock, two layout profiles, service replacements, dirt snapshots and
paste results. It does not yet have a complete shared PC object, general assembly or multiple persistent
customer machines. The field groupings and transfer rules below are proposals, not current contracts.

## 2. Five things to keep distinct

| Thing | Plain meaning | Recommended information |
| --- | --- | --- |
| Catalogue model | What a type of part is | Model identifier, category, generic label, parody brand/model details, fit data, performance and heat |
| Individual part | One physical copy | Unique identifier, model reference, owner, location, actual working condition, actual new/used status, faults and discovered information |
| PC | One assembled or partly assembled machine | Unique identity, case item, installed item references, outer storage location and customer/player association |
| Work order | What was promised for that PC | Customer and PC references, reported symptoms, agreement/revisions, price/authorisation, due date, work and handoff state |
| Container | Where physical objects can be | Stash, customer tray, case interior or another permitted storage area; grid/shape and capacity |

**Recommendation:** condition belongs to each physical copy. Two copies of one GPU model can be clean
and working, dirty and working, or broken. The catalogue must not change when one copy breaks.

New/used is also separate from working/broken: used hardware can work perfectly. This distinction is
needed for the already accepted used-as-new scam. Exact condition grades, durability numbers and failure
probabilities are not selected here. Hidden faults stay hidden until the applicable inspection reveals them.

Prototype labels and future identifiers are not final catalogue names. No real brands or model list is added.

## 3. One identity, one physical place

Each part has one identity throughout its life. Fitting it moves that item; it does not create an installed
copy while leaving another in the drawer. Removing it moves the same item back out, including its faults,
condition and ownership. Selling a machine transfers the items actually inside it, not catalogue templates.

A PC occupies the agreed single large footprint in outer storage. Its installed parts occupy its interior,
not additional stash cells. Removing a GPU makes that GPU consume separate storage space. Removing every
part must not delete the machine identity or its work order: its case and remaining job still exist.

The case and motherboard are physical items too. The motherboard can be broken, tested, repaired or
replaced. Owning an assembly is not a second physical copy of its case. Motherboard layouts belong to
models, not to whichever screen currently draws the PC.

A work order references the actual PC. Switching the active ticket only changes what the player is viewing;
it must not overwrite, regenerate or exchange the machines. Changing a preview profile remains a sandbox
action until actual case/board replacement is implemented; it must not become a free hardware upgrade.

## 4. Ownership must follow the item

| Action | Physical result | Ownership result |
| --- | --- | --- |
| Remove a customer's RAM | Same RAM moves to a tray/storage | Still the customer's |
| Commit player stock as an agreed replacement | That copy leaves available stock and enters the PC | Proposed transfer at explicit replacement commitment; test-fitting alone keeps shop ownership. Payment timing still needs agreement |
| Remove a failed replacement later | Same copy returns to a tray | Its current ownership remains; removal does not refund or grant ownership |
| Customer sells a PC | Actual PC and included parts change hands | Transfers by the agreed purchase, not by moving it behind the counter |
| Return an original part | Same item is handed back with the job | Customer ownership is preserved |
| Customer authorises purchase/disposal of an old part | Explicit recorded agreement applies | Transfers or disposal follow that agreement; no automatic salvage reward |

**Recommendation:** mark customer property clearly in inventory and on hover. Physical accessibility is
not permission to sell it. Keep it out of ordinary player-stock sales until ownership has legitimately
changed. The accepted scam set allows substitution and dishonest claims; it does not by itself approve a
new customer-property theft mechanic. Such a mechanic would need its own proposal.

A hidden dishonest replacement must still move the actual installed item and preserve the original as
customer property. Ownership transfer and misrepresentation are separate issues. Trade-in eligibility and
all economic costs remain open; this model should accommodate them without deciding them now.

## 5. Grid fit: connection and physical space are different checks

Keep the agreed three levels: outer stash, case interior and model-specific motherboard layout. Use one
logical cell scale within a PC; zoom and window size only change drawing. A large part must not shrink to
fit a smaller case or a smaller socket. Rotation changes its occupied cells, not its specification.

Recommended separation:

| Fit information | What it answers |
| --- | --- |
| Storage footprint | How much loose drawer/stash space does this copy need? |
| Connector and facing | Can it attach to that particular slot/socket? |
| Installed body footprint | Once attached there, what space does its body occupy? |
| Height and case depth | Is there enough vertical clearance? |
| Slot reservations | Does a wide card prevent use of neighbouring expansion positions? |

The current trial ties connector and item rectangles closely together. For the full game, a GPU's plug
can be short while its cooler/body is long. A CPU cooler sits above the CPU rather than needing an empty
rectangle beside it. This is why connection points and body clearance should not be the same rule.

**Proposed first production rule:** connector cells must be valid on that model's board; the anchored body
must fit the case's permitted space. It may extend beyond the green board silhouette where the case allows.
Overlapping bodies are rejected unless that specific mount relationship permits it, such as cooler-over-CPU.
Start with explicit mount relationships and simple height limits, not general arbitrary stacking or 3D physics.
Case fan/PSU/drive mounts can reserve space without being motherboard sockets. A multi-slot GPU reserves
its neighbouring expansion space so an adapter cannot invisibly occupy the same volume.

Board masks, connectors and clearance reservations are authored data. Different boards can expose
different RAM and expansion configurations. Future Wi-Fi, Bluetooth and sound cards use compatible mounts;
this document does not add those models or require cable simulation. Cable visuals remain deferred.

**Motherboard changes need a recoverable path.** Recommended first rule: detach its dependent components
into real available storage before removing the board; if space is insufficient, show the reason and keep
the current assembly intact. Do not secretly move them onto the new board. Carrying a populated board as a
nested subassembly could come later; it is not required for the first slice.

## 6. Friendly handling, strict accounting

Trying a part in a drawer should not run motherboard rules. While hovering a socket, give a specific reason
such as wrong memory generation, wrong facing, occupied slot or insufficient case clearance. Explain the
first useful problem instead of showing an error modal.

**Proposed transfer rule:** validate destination and required space before committing removal/installation.
An invalid final drop restores the previous valid placement and explains why; it neither destroys the part
nor charges money. This preserves the forgiving trial direction while making full inventory safe.

A hand is a temporary carry state, not a place that permanently owns stock. Free movement, sway and throws
are presentation until the item settles into a valid place. If a thrown item cannot settle at the nearest
cells, find another valid cell; if none exists, restore its reserved original placement. Never store it at
an invisible off-grid coordinate. Exact settling preference is proposed tuning.

Going back, changing tickets or saving mid-drag must leave every part with a valid recoverable placement.
Recommendation: reserve the source until a transfer commits. Claude's hand-state and save work should own
how this is implemented; this is not an additional input-state implementation by Codex.

## 7. Dirt, paste and damage belong to the actual assembly

Dirt on a GPU follows that GPU when removed or installed elsewhere. Dirt on the motherboard beneath it
stays on the board. Case/filter dirt stays with its physical surface. Swapping a part must not count the
original's dirt as vacuumed or clean unrelated surfaces. Cosmetic motes never count as real dust.

Recommended model boundary: real dirt is associated with a physical surface; a job's cleaning display is a
view of the current PC. A board or case change may need a geometry remap or explicit recovery policy. Never
silently discard dirt because an old snapshot's screen rectangle no longer matches. The exact representation
is Claude's engineering decision; do not rewrite DustSim as part of this proposal.

A repaste result describes the interface between a particular CPU and cooler, including actual material,
coverage and secured/completed state. Removing/replacing either breaks that interface and invalidates its
current functional result. It does not erase the historical fact that paste was previously applied or paid
for. Costs for another application remain a later economy decision. Old-paste reuse is accepted concept G,
but retaining usable residue through removal needs its own approved physical-state rule.

Likewise, damage is attached to the actual copy. Replacing a broken GPU does not repair the removed one.
A check result must become stale after a relevant hardware/material change. It cannot certify the new build
just because an earlier arrangement passed. A low-cost version can simply mark it 'Needs recheck'.

## 8. The work order remembers promises without rewriting reality

Keep these four records separate, following D59–D60 and MINIGAME_RULES.md:

- **Agreement:** accepted work, specified part/material/condition, agreed price and spending permission,
  collection day, revisions and removed-part handling. Unknown means not agreed, not secretly inferred.
- **Actual PC/work:** real fitted items, real dirt, material, damage and physical results.
- **Completion claim:** what the player says was done, including omissions or false statements.
- **Functional check:** what the current machine can do; not a measure of honesty.

The work order should show 'Promised' and 'Actual' separately in the bench, inventory/parts inspection,
diagnosis and handoff. Customer true budget remains hidden. Knowledge comes from intake/testing; an item
record containing the real fault does not give the player or customer automatic access to it.

Agreement revisions need customer approval under the proposed revision flow; swapping hardware must not
rewrite the quoted specification. Archive the agreed scope, delivered contents and claim at handoff so a
later complaint can refer to what was sold. These records support consistent state; they are not an NPC
evidence-collection system. Initial discovery still follows approved persona-based chance (D18).

Example: a budget GPU is physically installed while the quote promises a higher specification. An honest
approved revision can make this legitimate; claiming the original spec leaves an accepted substitution scam.
Neither claim changes the actual GPU. Toothpaste remains toothpaste even with a good physical grade.
The disputed cleaning claim uses real remaining dirt; rejected filter scam C stays excluded.

## 9. Delivery and sale should not leak ownership or identity

A customer collection returns the customer's actual PC and any original parts designated for return. The
job is archived rather than regenerated. Transferring a whole PC must transfer every contained item exactly
once, while separately stored old parts follow their own agreement. Money and delivery cannot repeat on a
second click or after reloading. A machine cannot be both collected and available as player sale stock.

Keep the PC identity after a comeback. Open a new linked service record for it rather than overwriting the
original delivered agreement. Trust, closeness and reputation consequences remain the existing design's
separate systems; no new formulas, timers or refund rules are selected here.

## 10. Smallest useful implementation, after approval

| Slice | Player-visible result | Prerequisite / owner |
| --- | --- | --- |
| Design approval | Agree on identity, ownership, fit and recovery rules | User reviews this proposal; Codex revises |
| Existing ticket connected to real items | The same stock/installed copy is seen by each bench; no new mechanics | Claude after the relevant engineering gates; use existing demo content |
| Two persistent PCs | Switching jobs preserves each machine, agreement and removed parts | Shared PC state and tested saves; no need for generated customer flow yet |
| Empty-case build | Assemble one supported build from owned stock and run existing checks where applicable | Approved case/board fitting rules and required-parts list |
| Sales and comebacks | Transfer/archive the actual assembly and delivered claim | Approved transaction and consequence design |

For record relationships, save contents, exact legacy gaps and migration policy, see PC_MODEL_PROPOSAL.md.

Step 15's typed job should reference a PC identity and leave room for agreement, claim and archived delivery,
without assuming that a job itself owns the only hardware in the world. Engineering class/file/API choices
remain Claude's. Work plan step 16 remains the shared model implementation; this proposal does not reorder
the approved plan or authorise it early. Do not generate the user's extensive catalogue to exercise the model.

### Acceptance examples for Claude's later tests (not implemented tests)

1. Two identical RAM copies keep distinct identities through install/remove/reload; no duplicate occupancy.
2. A customer GPU removed to storage is still customer property and not available for normal sale.
3. A PC consumes one outer footprint; its removed GPU consumes another; installed parts do not double-count.
4. An invalid fit or full drawer leaves money, identity, ownership and valid placements unchanged.
5. A long GPU fits its plug but fails case clearance; zooming cannot change that result.
6. A wider GPU blocks an adjacent card; a compatible cooler can occupy its authorised CPU mount overlap.
7. A broken motherboard stays broken when moved; a different board does not inherit free installed parts.
8. Switching between two tickets and reopening preserves their distinct dirt, hardware, ownership and promises.
9. Removing a CPU/cooler invalidates its current thermal result; the historical service record remains.
10. Budget substitution leaves actual model unchanged by the claim; disclosed revisions and lies remain distinct.
11. Delivery/sale changes ownership and money once, including after save/reload; old parts follow their agreement.
12. Legacy-save migration preserves money, upgrades, stock, active PC and accepted completed results; failure
    recovery and exact migration mapping are designed/tested by Claude, not invented in this document.

## 11. Decisions to make, most important first

1. **Individual condition and identity:** approve one physical-copy identity, with new/used and working/broken
   separate, while catalogue entries describe only models? Recommendation: yes.
2. **Connector versus body space:** approve an anchored body which may extend beyond the board if the case
   permits, with explicit mount exceptions for cooler/CPU and reserved adjacent expansion space? Recommendation: yes.
3. **Customer property:** retain ownership labels and prevent ordinary sale of customer-owned loose parts unless
   explicitly transferred? Recommendation: yes; propose any theft mechanic separately.
4. **Transfer recovery:** reserve the original placement and restore it on invalid/full-space drops or interrupted
   transfer? Recommendation: yes, keeping physical throws and free experimentation.
5. **Board removal:** require dependent parts to be detached first for the initial version, or support carrying a
   populated board immediately? Recommendation: detach first; revisit subassemblies after the first shared-PC slice.

These answers approve design boundaries only. Exact payment/ownership commitment timing, required components
for a sellable build, repair procedures for boards and future sockets/catalogue values need later proposals.

## Handoff

This proposal is complete for user review, not approved for implementation. Claude continues Phase 1
step 3. bench_view.gd, tool_rig.gd and game_state.gd are reserved to Claude; Codex makes no game-code
changes until that PR is merged. The companion PC_MODEL_PROPOSAL.md covers records/saves/migration.
Re-read the live plan and newest changelog before implementation. Claude cross-reviews this docs-only PR;
the user decides the design. No merge is authorised for Codex. An integrating contributor assigns the
next available patch version at integration under the parallel-work rule; no game version is reserved here.
