# Props

Loose objects drawn on top of a room, separate from the room picture (0.57.3). Pixel art, painted at half
size and always shown at exactly 2x with sharp pixels. Every file here was approved by the user before it
entered the game; credits, approval evidence and file hashes are in docs/ART_ASSET_LOG.md.

- `clipboard_resting.png` (ART-06): the ticket clipboard lying on the counter (the TicketClipboard spot's
  Prop). `clipboard_upright.png`: the same clipboard picked up, shown while the mouse is over it.
- `pc_tower_closed.png` (ART-09): a customer's closed tower PC, standing on the counter while its owner is
  at the window. One generic case for every customer; the ticket says whose PC it is.

To give any hotspot a prop, set its Prop (and optional Prop Hover) to a file name here, without ".png".
See docs/ROOM_ART_GUIDE.md. Replacing a picture with a new one needs the user's approval first.
