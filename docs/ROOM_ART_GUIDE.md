# Room art guide — replacing the placeholders (0.53.0, D161)

The game has no menus between places anymore: every place is **one picture with clickable spots on it**.
Right now each place is drawn with placeholder boxes. This guide is how you swap in your own art and line
the clickable spots up with it. You never need to touch code for this.

## The places

| Place | Scene file (open in Godot) | Picture file | What is on it |
| --- | --- | --- | --- |
| The counter (main screen) | `scenes/rooms/counter.tscn` | `art/rooms/counter.png` | front door, customer window, shutter, back door, till, ticket clipboard, phone, storage under the window, bin, wall board |
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

Without a portrait the game draws a grey silhouette. Paint portraits to fit the window
(about 340 × 300 px at full size), with a transparent background.

## 5. Ideas already marked as spots

These exist as spots so your art can include them now, and the features can come later: the **bin** under
the counter, the **parts supplier** down the street. Possible scam features also start at the counter
(what you tell customers, the till, the bin), so it is worth giving those objects room in the picture.
