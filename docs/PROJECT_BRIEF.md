# Nightshift — Project Brief

Version 1.9 · 13 November 2026

## Read this first
This pack guides human-directed collaboration between AIs. The user is creative director. Current task: merge the open PRs, add a simple New/Load/Achievements start screen, and fix hose routing/tool interference with an optional desk clamp. Trial 0.16.0 implements this bounded feature. Seven scam concepts A/B/D/E/F/G/H remain approved, C excluded; work-order/claims/consequences are still future work described in MINIGAME_RULES.md.

GitHub is connected; repository `123rearearcode/nighshift_real`. The user explicitly authorises merging the current task's PRs and reports testing the other AI's changes. Only #10 was open at inventory and is merged; older PRs were already merged. Use scoped branches, logged checks and preserved archive baselines. This supersedes the previous task's no-merge scope. ZIPs remain available for playtests.

Read this brief for every task, then only the relevant DESIGN.md sections and task files. Read CURRENT_STATE.md before touching code. DECISIONS.md distinguishes approved rules from proposals. ROADMAP.md orders the work. Later explicit user decisions supersede this snapshot; update the documents when that happens.

## Game
Working title: Nightshift — PC Repair. A single-player, pixel-art PC repair and shop-management game intended for a commercial Steam release. Godot/GDScript is now the active trial implementation. The real engine version is Godot 4.7.2 (confirmed by the user); the 0.15.1 changelog reports CI on 4.7.2, while human acceptance of that build remains pending. Price, release date, setting and the full production architecture remain open. Parody brands are the recorded hardware naming direction.

The player runs a shop by day and works on machines or salvages at night. Physical space is central: parts occupy inventory cells; each motherboard has its own grid shape and connector layout; cases determine available interior space. Finding value in used hardware, fitting useful builds together, and deciding whom to trust connect the activities.

## Core experience
- Day: manually open the shop; handle untimed, individual visitors; inspect repair intakes; negotiate prices and collection dates; buy used stock; sell goods; return machines; manually close.
- Night: a continuously running clock pressures repairs, cleaning, building and other work. A manual pause stops time. Outside salvage minigames consume time according to choices.
- Progression: obtain parts, manage space and cash, repair/build, sell, improve the shop, build relationships and unlock more demanding opportunities.
- Release: dozens of models per major part category across low to high end; build complete PCs from empty cases; personal technician PC; lore, dynamic relationships, reputation, suppliers, online sales and eventually B2B/bulk opportunities.

## Design priorities
1. Clarity and approachable interactions despite hardware variety.
2. Meaningful spatial and commercial choices.
3. Hands-on cleaning, pasting and component handling.
4. Customers whose history and needs matter.
5. Progression that substantially changes play; exact late game remains open.

Inspiration includes Probably Stolen's spatial inventory approach. Produce original systems, setting, art and writing; do not copy its assets or presentation.

## Scope discipline
No new major systems during the current opening-campaign definition. Bulk lots currently mean a price reduction, not a sealed-lot inspection simulation. Loaner PCs are excluded for now. Cable visuals were removed for clarity; reconsider later. Advanced diagnostic software with hardware requirements and buying actual in-game games for customer testing belong to a later update. Server builds are a long-term ambition, with release versus update placement unresolved.

## Working with other AIs
One lead integrates work. Other contributors receive bounded tasks. A role is not a requirement to hire or run another model. Do not assume another chat shares memory, source access, or accounts.

Suggested assignments: economy tables, customer writing, one mechanic specification, bounded implementation, or independent bug review. Avoid concurrent edits to the same files. Use separate branches/copies for code; retain a known working baseline and review changes before merging. Do not send the complete chat when a brief and relevant section suffice.

### Practical workflow — current manual exchange
- This chat: design and coordination. User: creative director and playtester.
- Current implementation contributor: Claude in chat, returning ZIP files. This chat handles design reconciliation and review. No AI repository connection is established.
- Additional AIs: bounded features, data/content or reviews. Start with one lead plus one specialist/reviewer rather than many concurrent contributors.
- Godot runs locally on the user's computer to open, play and inspect the integrated game. AIs edit project files; they need not all operate the editor.
- A chat-only AI returns files/patches. A tool-enabled AI can edit its authorised checkout. Neither automatically shares local folders, repository access or conversation memory.
- At least one development environment must run the pinned Godot version for integration checks. Contributors unable to run it must disclose that verification limit.
- Agree on shared component, PC, inventory, job, customer and supplier definitions before parallel implementation.
- Assign separate branches and file ownership. Keep main as the integrated baseline; review pull requests and actual checks before merging. Do not let several agents modify the same checkout concurrently.
- Current exchange: user downloads a versioned ZIP, extracts it separately, tests it in Godot, and returns the ZIP plus feedback for review. After acceptance, user commits the accepted files through GitHub Desktop.
- Use only relevant context and files, and concise handoffs to control token use.

### Repository status
Repository: https://github.com/123rearearcode/Nightshift . User confirmed the original five documents were uploaded. Repository contents/visibility were not independently inspected; AI write access is not established. Godot project upload remains unverified. Proposed repository layout: root docs/ and game/; actual ZIP layout is a standalone project with its five authoritative documents in docs/. Do not keep independently edited duplicate copies of those documents in one repository.
If a local Godot project exists, preserve it before moving/copying it into game/. Ignore the generated .godot/ cache and exclude credentials/build outputs. A contributor with no repository access can receive a source archive instead.

### Task brief template
- Task ID / objective:
- Baseline commit or document version:
- Read these files / sections:
- Confirmed constraints:
- Files you may edit:
- Expected output and length limit:
- Acceptance checks:
- Out of scope:
- Open questions you may resolve / must escalate:

### Handoff template
- Outcome:
- Files changed:
- Decisions proposed (not silently approved):
- Checks actually performed and results:
- Known failures / assumptions:
- Exact next action:

Use compact diffs and concise explanations. Do not claim checks you did not run. Never overwrite unrelated work, silently expand scope, or invent credentials. New numerical balance values are proposals unless the user approved them.


## Current servicing scope — trial 0.10.0
The user explicitly added a risky dust pick and the choice between careful work and speed/profit. Hovering inspects dust beneath installed GPU/cooler; holding attempts extraction without disassembly. Damage persists and requires replacement. The trial offers only equivalent and budget service replacements for those two parts, not a catalogue. Budget GPU specification is recorded; a budget cooler also changes the temperature estimate. Customer discovery, disclosure, trust/reputation consequences and general replacement inventory remain future work. The intended game permits knowingly inferior substitutions; do not turn all mistakes into automatic refunds or silently restore original quality.


## Free arrangement update — same 0.10.0 delivery
The hardware sandbox now separates storage from installation: three generic sample pieces (two existing RAM instances and a GPU shape), footprint-based drawer packing/rotation, socket compatibility on installation, and saved per-profile arrangements. Controlled spring following, lift, shadow and rotation provide tactile feedback. This is a bounded inventory interaction prototype, not shop stock, customer-PC integration or the release catalogue.


## Current trial0.11.0 — handling across both benches
The user authorised tabletop throws/bounces, tactile repair tools, a flexible physical brush and replacement stock linked to player inventory. Implemented a shared bounded tabletop model (edge rebounds, spin, vertical hop/floor bounce and friction), repair-tool rig for vacuum/brush/pick/cloth/syringe, and real bristle contact points. Hardware flicks settle into free drawer cells; repair GPU/cooler can be thrown and recovered. A single owned stock list now feeds hardware storage and repair replacements. Buying adds a unique item; fitting consumes it with no second charge. This is a minimal shared stock foundation, not the final catalogue, supplier market or complete PC inventory. Fresh dirty tickets initialise visible dust; existing cleaned saves stay clean with explicit status and a New dirty PC action preserving cash/stock. The user's reported missing dust was not reproduced on a fresh ticket; do not claim an established root cause.
