# Room art guide — replacing the placeholders (0.53.0, D161)

## Counter Batch A layers — 0.57.5

The approved counter now uses `scripts/rooms/counter_art.gd` and the unchanged PNGs under
`art/rooms/counter_batch_a/`. Read manifest.json/ART_ASSET_LOG for the exact source approval before
changing art. layout.json records the current anchors: customer waist 488 (center 680), PC base
(1030,550), clipboard center (830,543). Source crops in CounterArt are render-time regions, not new
raster exports. The foreground counter's alpha provides customer occlusion; props remain separate.

Morning/dusk are selected from existing visit state. Door hover switches endpoints, and the existing
shutter confirmation previews closed/cancelled states without time or save changes. `ui_label` on a
Hotspot is an always-visible compact UI backing for existing cash/phone/shift functions that have no
painted physical prop. All original actions remain; F3 still reveals the world hotspot bounds.

The ordinary flat Background texture override still takes precedence if explicitly provided; missing
source art retains the old playable placeholders. The below one-image instructions remain valid for
outside/workshop and that explicit override. Under-counter art is decorative around the unchanged
44 px / 20×10 grid, so it does not require resizing Batch B item pictures or partitioning capacity.

## Mandatory before installing room art — 0.57.2

Start with ART_PRODUCTION_PROGRESS.md for current task routing and retirement state, then ART_DIRECTION
and ART_ASSET_LOG. The historical drop-in instructions below may ONLY be used after human approval of
the exact artwork revision/use is recorded. Merely copying into an auto-loaded room path installs art;
unapproved drafts must stay non-loaded. After first-day completion, agents use the permanent queue.


## Art direction update — 0.56.2

Before creating any art, read [ART_DIRECTION.md](ART_DIRECTION.md) and
[FIRST_DAY_ART_CHECKLIST.md](FIRST_DAY_ART_CHECKLIST.md), and inspect `art/references/`.
They define the current art target: layered pixel scenes, precise close-up hardware, only a clipboard
as initial tabletop dressing, dynamic people/items and sufficient space for one 20 x 10 storage grid.
The one-picture procedure below describes the SHIPPED loader/fallback, not completed layered support.
Its old counter prop list is a list of functional hotspots, not a mandate to paint till/phone/clutter.
Do not drop the reference PNGs into live auto-loaded room paths; they still need alignment/layer work.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

The game has no menus between places anymore: every place is **one picture with clickable spots on it**.
Right now each place is drawn with placeholder boxes. This guide is how you swap in your own art and line
the clickable spots up with it. You never need to touch code for this.

## The places

| Place | Scene file (open in Godot) | Picture file | What is on it |
| --- | --- | --- | --- |
| The counter (main screen) | `scenes/rooms/counter.tscn` | `art/rooms/counter.png` | front door, customer window, shutter, back door, till, ticket clipboard (its own prop picture: leave the spot clear), phone, storage under the window, bin, wall board |
| The workshop | `scenes/rooms/workshop.tscn` | `art/rooms/workshop.png` | door to the counter, stock room door, repair bench, hardware board, monitor, testing bay |
| Outside | `scenes/rooms/outside.tscn` | `art/rooms/outside.png` | the shop door, your van (salvage dump), the store (tools and upgrades), the parts supplier (later, a different place) |

The close-up screens (repair bench, hardware board, monitor, stock room, testing bay, salvage dump, tool
shop, under the counter) are separate and keep their current look for now.

## 1. Paint the picture

- Size: **1280 × 720** (the game's screen). For chunky pixel art, paint at **320 × 180** or **640 × 360**
  and the game scales it up sharply (pixels stay crisp: nearest-neighbour filtering is already set).
- Leave the **top-left corner** (about 220 × 60 px) and the **top-right corner** (about 120 × 60 px)
  calm: the place's name and the Pause button sit there. Leave the **bottom strip** (about 60 px) calm too:
  the game writes messages there.
- Save it as PNG with the exact name from the table, into `art/rooms/`.

That is enough: the next time you press **F5**, the game finds the picture and the placeholder boxes
disappear. (In the Godot editor you can also drag the PNG onto the room's **Background** node, Texture
field. Either way works.)

## 2. Line up the clickable spots

1. In Godot, open the room's scene file (double-click it in the FileSystem panel).
2. In the Scene panel, open **Hotspots**. Each child is one clickable spot (FrontDoor, Till, Phone, ...).
   In the editor each one shows as a labelled box over your art.
3. Click one, then drag it and its edges in the 2D view until the box covers the object you painted.
4. In the Inspector, **Art Hint** tells you what belongs under that spot.
5. Save the scene (Ctrl+S). Press **F5** and hover your art: the spot lights up with its name.

Tip: in the game, press **F3** to see the outline of every spot at once.

## 3. Things you can change on a spot (Inspector)

| Field | What it does |
| --- | --- |
| **Label** | The name shown when the mouse is over it |
| **Action** | What clicking does (see below). Leave it unless you are adding a new spot |
| **Art Hint** | A note for you: what to paint there |
| **Closed At Dawn** | At 06:00 the night is over; ticked spots (doors to work) close |
| **Placeholder Color** | Only used while there is no art |
| **Prop** (0.57.3) | A loose object drawn on the spot, a file name from `art/props/` without ".png" (pixel art, shown at 2x, centred). The ticket clipboard uses `clipboard_resting`. Don't paint that object into the room picture |
| **Prop Hover** (0.57.3) | Optional: the picture shown while the mouse is over the spot (the clipboard picked up: `clipboard_upright`) |

Actions: `go:<place>` walks somewhere (`counter`, `workshop`, `outside`, `stock`, `repair`, `hardware`,
`monitor`, `bay`, `salvage`, `shop` (the store), `under_counter`), `open:<thing>` opens something in that room (the counter knows
`phone`, `tickets`, `till`, `board`, `customer`), `end_night` is the shutter, and `later:<idea>` makes a
spot that says "coming later" (good for objects you paint before their feature exists).

**Adding a spot:** select an existing one, Ctrl+D to duplicate, move it, and change Label, Action and Art
Hint. **Removing a spot:** delete the node (the game simply has one place fewer to click).

## 4. Customers

Customers appear in the counter's window when the shutter goes up in the morning. Portraits are optional:

- `art/customers/<profession>.png` (`regular`, `gamer`, `clueless`) for everyone of that kind,
- `art/customers/<person id>.png` for one particular person (story characters, e.g. `t001_mara.png`),
- `art/customers/customer.png` for everyone else.

Without a portrait the game draws a grey silhouette.

Two kinds of portrait work (0.57.3):

- **Pixel-art sprites** (no taller than 200 px, like Mara's and Relu's, 120 × 172): shown at exactly 2x with
  sharp pixels, centred on the window, the bottom edge of the picture (their waist) on the counter-top
  line. Paint from the top of the head down to the waist; the counter hides the rest.
- **Larger painted portraits**: fitted into the window (about 340 × 300 px), as before.

Mara (`t001_mara.png`) and Relu (`t002_relu.png`) are approved art (ART-08). While a customer is at the
window their PC stands on the counter (`art/props/pc_tower_closed.png`, ART-09).

## 4b. Storage under the counter and the ticket close-up (0.57.3)

- The under-counter storage draws every item with its picture from `art/storage/<name>_r<turn>.png`
  (see that folder's README). Cells are 44 px. Parts are illustrated (comic-book, semi-realistic) at 1:1;
  PCs and tools are pixel art at 2x. A picture that does not exactly fit its footprint is ignored and the
  plain box is drawn instead.
- The ticket clipboard close-up uses `art/ui/ticket_clipboard.png` (300 × 350, shown 600 × 700). The game
  writes the tickets on its blank paper.
- These are approved files; a new or changed picture needs the user's approval before it goes in.

## 5. Ideas already marked as spots

These exist as spots so your art can include them now, and the features can come later: the **bin** under
the counter, the **parts supplier** down the street. Possible scam features also start at the counter
(what you tell customers, the till, the bin), so it is worth giving those objects room in the picture.
