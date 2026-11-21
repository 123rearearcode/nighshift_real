# Task Manajer — approved standard infection, implemented in 0.49.0

19 November 2026 · D157 · Codex (GPT-6; exact deployment model id not exposed by this session),
ChatGPT Work. This section supersedes revision 1's unapproved fast-round rules below. Original D156
chose the Task Manager direction; after interactive reviews, the user approved the calmer demo and
requested game integration. The disappearing/reordering experiment was too hard; a boss is an idea only.

## Current player loop

Boot the actual customer PC -> Anti-virus scan -> Remove threat -> Task Manajer inside the monitor.
Inspect processes, end the malicious source and its Zombie watchdog, disable the visible auto-start
entry, then Reboot & verify. Only verified victory cures the infection. No payment, ready sticker,
collection, trust or reputation transaction belongs to this activity.

Six rows stay in the same positions even when ended. No processes disappear, spawn, reorder or hide.
Ordinary customer apps look silly but have readable publisher/location clues; ending one is a
recoverable mistake. Ending the critical desktop crashes the attempt and switches the PC off; no
hardware or file damage is invented. Failure leaves infection for another attempt/customer pickup.

The existing save has one `job.infection`, adware or miner. Each round uses that actual strain plus
its persistence watchdog. Do not invent a miner on an adware-only PC or claim multiple saved infections.

| Behaviour | Standard implementation |
| --- | --- |
| Adware | One advert in a fixed bounded slot, never over controls. Twelve-second recurrence is trial tuning. |
| Miner | Same row changes alias every eight seconds (trial tuning); publisher, location and identity stay consistent. Protected termination asks for a funny word. |
| Zombie watchdog | Returns to its same row after five seconds (trial tuning) unless auto-start is disabled. Reboot catches forgotten persistence. |
| Budget scan | In-round tags for source/watchdog; deliberate monitor scan still precedes cleanup. No shop purchase prerequisite. |

## Current typing and transaction contract

Typed letters immediately become UPPERCASE, preserving the caret. Native SEND `Button.pressed` and
LineEdit `text_submitted` call one handler. Wrong words show an error and permit retry; success ends
the protected task once. Cancel leaves it running. No typing countdown: elapsed simulation, aliases,
adverts, respawns and overload pause during the prompt. Controls are built once, never recreated by
updates. Shared Pause and focus-loss pause remain usable without trapping the typing prompt.

Trial cost: ten canonical night minutes per attempt, spent/saved once on entry. Check powered boot,
actual infection, writable PC and fit before 06:00 first. Incomplete attempts retain paid time;
scan/notes remain uncharged as before. The round's animation time is not a separate night clock.

Rounds are session-local. Stop cleanup, power-off or application exit leaves infection intact;
a fresh attempt resets local progress and visibly costs time again. Navigation refuses while the
panel is open. Cure and Findings use existing GameState/NightSession saves; no new save key or schema.
Findings records visible actions/outcome on the real night clock. Completion binds the scanned ticket
and strain; a stale panel cannot cure another PC. "Looks fine" exits cleanup only: actual pickup still
uses the ordinary ticket workflow and existing infection consequences, with no invented fraud penalty.

## Current boundaries and resume

Deferred: boss speed/disappearance, new virus families, simultaneous saved infections, scanner tiers,
subscriptions, tools/store economy and deeper persistence. The eight old questions below are historical
proposals, not blockers or approval for this other work. Required suite: `tools/test_antivirus.gd`
(Antivirus), covering native SEND/Enter/uppercase, fixed controls, typing pause, cancellation, reboot,
clock/06:00, save and stale-ticket isolation. The in-chat acceptance is not a graphical Godot playtest.

This is a detour after 3.5. Claude resumes **3.6 Testing bay, talk first**, after cross-review and
user-controlled integration. Next slots: bay 0.50.0 with structural review, builds 0.51.0, elegance
0.52.0. Manual remains deferred. HANDOFF and WORK_PLAN have the live branch/merge/resume instructions.

## Historical revision 1 — proposals superseded by D157 where they conflict

Revision 1 · 18 November 2026 · Claude (Opus 5.5, model id claude-opus-5-5) · **for review, not built**

The user chose the direction on 18 November 2026 (D156): option D, a Task Manager panic, "cus it fits the
goofy style of the game". The user's goals (D155 item 5): anti-virus should feel electrifying, the most
dynamic thing in the game; several anti-virus scans; "Remove threat" opens a real mini-game where the
virus is the enemy; several kinds of viruses; anti-virus tools you buy act as power-ups.

Everything below is a first set of **ideas for review** by Codex (ChatGPT) and the user. Nothing here is
approved beyond the chosen direction. Names are parodies; numbers are placeholders.

## 1. The fantasy in one paragraph

You open the customer's Task Manajer (sic) and it is a zoo. Processes stream in and out of a list,
each with a tiny pixel face. Most are the PC's honest workers (`svchost.exe`, `explorer.exe`). A few are
little goblins in disguise (`svchots.exe`, `exploder.exe`, `FREE_RAM_D0WNL0AD.exe`) multiplying, hiding
and locking things. You have about 40 seconds to End Task the goblins, without killing a real system
process, because that blue-screens the PC ("Your PC ran into a problem and needs a hug"). Squeaky death
sounds, sparks on every kill, the list shaking when a miner hogs the CPU, combo pop-ups ("kill -9 x3!").

## 2. Where it sits in the existing loop

1. **Scan first (the scouting step).** Running an anti-virus scan on the monitor (night minutes, as today)
   produces a report of what it detected. Better products detect more kinds and tag suspects in the
   mini-game. The scan never removes anything by itself any more.
2. **Remove threat starts the round.** The monitor's "Remove threat" opens the Task Manajer window.
3. **Result.** Every malware process ended → the infection is removed (the existing `clean_infection`).
   Partial → what survived stays on the PC (the customer may feel it at pickup, as today's delayed
   discovery). Blue screen → the round ends early with a crash; see the open questions (section 9).
4. **Findings (D150).** The round is noted as work/measurement: what was ended, at what night time, any
   crash. Only what the player saw; nothing the round did not show.

The two existing strains (adware 'FreeCursors', hidden miner 'CoolCoin') become the first two enemy types,
so generated tickets (0.48.0) feed the mini-game without a new data model.

## 3. The screen

- A Task Manajer window fills the monitor's output area: columns **Name · Face · CPU · Memory · Publisher**.
- Rows scroll slowly; new processes appear, finished ones leave. 10–14 rows visible.
- **Left click a row = End task.** Right click = a details card (file location, publisher, start time).
  Mouse only, like the rest of the game; Del as an optional hotkey.
- An **infection meter** at the top: malware that keeps running fills it (replication, locks, pop-ups);
  when it is full the round is lost. A timer bar beside it.
- A small **power-up tray** at the bottom with the tools the shop owns (section 6).
- Tabs that matter for some viruses: **Processes** (default) and **Startup** (for respawners).

## 4. Tells: how a player tells a goblin from a worker (fairness)

Puzzles must be solvable from what is on screen (D150 5.7), with difficulty from how evident the tell is.

| Tell | Example | Evidence level |
| --- | --- | --- |
| Misspelled name | `svchots.exe`, `exploder.exe`, `chr0me.exe` | evident |
| Shouty / greedy name | `FREE_RAM_D0WNL0AD.exe`, `HotSinglesNearCPU.exe` | evident |
| Wrong publisher | "Macrosoft Corporashun", "Unknown", "trust me bro" | one look (details card) |
| Behaviour | CPU stuck at 99 %, copies of itself appearing, padlocks spreading | watch for a moment |
| Face | goblins grin, sweat or whistle innocently when hovered | goofy hint, never the only tell |
| Scan tag | a "SUSPECT" label from a good enough scan | given by the scan you ran |

A weaker scan does not hide a virus from the list; it only fails to tag it. Real system processes always
have correct names and publishers, so a careful player can always win without tags (harder, not unfair).
A cheap scanner may give a **false positive** tag on a real process: the details card shows the truth.

## 5. Enemy types (first ideas)

| Virus | Behaviour in the round | How to beat it | Ties to |
| --- | --- | --- | --- |
| **Adware "PopUpPete"** (existing adware) | Spawns pop-up windows over the list ("YOU WON A FREE MOUSE!"); their X buttons dodge a little | Close pop-ups, then End Task the parent | existing `adware` strain |
| **Miner "CoinMuncher"** (existing miner) | Hogs CPU: while it runs, the whole list stutters and lags; drops to 0 % and whistles when the cursor hovers it | Sort by CPU, or catch it before it hides | existing `miner` strain |
| **Worm "Wormy.exe"** | Copies itself every few seconds; copies are indented under the parent | End the parent: all copies die; ending copies only buys time | new |
| **Trojan "TotallyLegit"** | Uses a real system name (`svchost.exe`); only the publisher or file location is wrong | Read the details card; the real one stays | new |
| **Rootkit "Mole"** | Invisible; pops into a random row for half a second, then hides again | Whack-a-mole timing, or a power-up that reveals hidden processes | new |
| **Ransomware "Lockjaw"** | Puts padlocks on rows (they cannot be ended) and spreads them on a countdown | Kill it before the locks spread; a power-up can break a lock | new |
| **Respawner "Zombie.exe"** | Comes back 3 s after being ended | Also remove its entry in the Startup tab | new |

Early nights would show only adware and miners; later nights mix in the others (D153 difficulty by night).

## 6. Anti-virus products and power-ups

**Scanners** (owned software, bought once in the Vapor store; parody names):

| Product | Detects and tags | Scan time | Quirk |
| --- | --- | --- | --- |
| Norten Free | adware only | slow | nags you to upgrade during the round (a harmless pop-up of its own) |
| Avest Basic | adware, miners, worms | medium | none |
| McAfeel Total | most kinds | medium | occasional false positive tag |
| Kasperspooky Pro | everything, including rootkits | fast | expensive |

**Power-ups** (consumable charges, bought in packs, one tap in the tray). First ideas:

| Power-up | Effect |
| --- | --- |
| **Freeze Ray** | Pauses the list and every virus for 3 s |
| **Highlighter** | Outlines every malware row for 2 s, tagged or not |
| **Rubber Duck** | Click a process: the duck says "that one's fine" or quacks suspiciously |
| **Firewall** | Stops replication and lock spreading for 5 s |
| **Sudo Hammer** | Ends one locked or respawning process for good |
| **Auto-Kill Bot** | Ends one random *tagged* malware process by itself |

## 7. Juice: what makes it "electrifying"

- Sparks and a small screen shake on every End Task; bigger for chains.
- Combo counter on quick correct kills ("kill -9 ×3!").
- The infection meter crackles as it fills; music speeds up in the last 10 seconds.
- Squeaky, slightly pathetic death sounds per goblin type; system processes look worried when hovered.
- The blue screen is a gag screen, then a reboot animation.

## 8. Building it in steps (if approved)

1. **Pure simulation first** (`scripts/rules/` or `scripts/sim/`): a seeded round with processes,
   spawns, replication, the meter and the win/lose result; no drawing. Deterministic for tests, like the
   generator (0.48.0).
2. **Vertical slice:** the Task Manajer window with adware, miner, real system processes and the blue
   screen; one scanner; no power-ups. Logged in Findings; removes the infection on a win.
3. **More viruses and scanners** (worm, trojan, ransomware, respawner/Startup tab, rootkit).
4. **Power-ups and the store**, then the juice pass (sound, shake, combos).

## 9. Open questions for the user and Codex

1. **Losing:** when the meter fills, what happens: the infection simply stays (try again, costs time),
   it gets worse (an extra virus next time), or the customer's PC is harmed?
2. **Blue screen:** how bad is ending a real system process: a lost round plus time, or does the PC
   also need a repair-type fix?
3. **Night time:** how many night minutes does one round cost (the scan already costs some)?
4. **Power-ups:** consumable charges as proposed, owned upgrades, or both?
5. **Scans:** should the products differ in price only, or also be subscriptions with a monthly cost?
6. **Launch set:** which 3–4 virus types for the first playable version?
7. **Difficulty:** round length, spawn speed and decoys rising with the night (D153), or with a separate
   "virus strength"?
8. **Fairness rule:** confirm that a weak scan only fails to tag (never hides) a virus from the list.

## Review request

Codex (ChatGPT Work): please review for consistency with D150 (observation-only evidence, solvable puzzles,
difficulty by evidence), D153 (generated tickets and difficulty by night) and the existing malware rules
(D132, `scripts/rules/malware.gd`), and add or challenge ideas. Answers to section 9 belong to the user.
