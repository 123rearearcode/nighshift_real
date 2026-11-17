# Hardware catalogue (0.45.0, D148)

The parts in `scripts/data/hardware_catalog.gd`, for the creative director to check. **All numbers are
trial proposals**: change them in that one file. Written by Claude (Opus 5.5, model id claude-opus-5-5),
17 November 2026.

## Rules agreed with the user (17 November 2026)
- Part types: CPU, GPU, RAM sticks, storage, PSU, cooler. Motherboard and case stay fixed for now.
- Four or five models per type, budget to high end. Names are close parodies of real hardware.
- PSU and cooler are support stats: every part draws power; too small a PSU and the PC does not start.
  The CPU makes heat; too small a cooler and it runs hot (and hot GPUs throttle, so FPS drops).
- Scale: processing and graphics scores. 100 is a mid-to-late-game soft ceiling that takes a long time to
  pass; the 5090 parody scores 98. A PC can have several GPUs (needed to pass 100).

## How the stats combine (pc_build.gd)
- Processing = the CPU's score. Graphics = best GPU + half the second + a quarter of the third, ...
  (two 98 cards = 147). RAM and storage add up.
- Power drawn = 50 W (board, fans, drives) + CPU watts + every GPU's watts. It must not exceed the PSU.
- CPU heat = its watts. Every watt the cooler cannot remove adds 0.5 °C.
- Game demands moved to this scale (Counter Stroke 2 needs graphics 11 and processing 15 for 60 fps), so
  the two demo PCs run exactly as before.

## Parts

| Type | Model | Stat | Watts | Price |
| --- | --- | --- | --- | --- |
| CPU | Intol Pentium G4650 | processing 12 | 54 | $20 |
| CPU | Intol Core i5-6060 (demo PCs) | processing 25 | 65 | $45 |
| CPU | AMB Rysen 5 3060 | processing 40 | 88 | $85 |
| CPU | Intol Core i7-12070 | processing 62 | 180 | $220 |
| CPU | AMB Rysen 9 9590X | processing 98 | 230 | $560 |
| GPU | Nvidya GeForks GTX 1550 Ti (budget stock) | graphics 13 | 75 | $18 |
| GPU | Nvidya GeForks GTX 1660 (demo PCs, equivalent stock) | graphics 20 | 120 | $40 |
| GPU | AMB Radion RX 6060 | graphics 32 | 132 | $130 |
| GPU | Nvidya GeForks RTX 3800 | graphics 50 | 320 | $320 |
| GPU | Nvidya GeForks RTX 5900 | graphics 98 | 575 | $1600 |
| RAM | Kingstone ValueRAM 4 GB DDR4 | 4 GB | – | $6 |
| RAM | Corsare Vengance LPX 8 GB DDR4 (demo PCs) | 8 GB | – | $14 |
| RAM | G.Skil Ripjaws V 16 GB DDR4 | 16 GB | – | $26 |
| RAM | Corsare Dominator 32 GB DDR5 | 32 GB | – | $70 |
| Storage | Seagait Barracooda 500 GB HDD (Mara) | 500 GB | – | $12 |
| Storage | Samsong 870 EVA 500 GB SSD (Relu) | 500 GB | – | $35 |
| Storage | Samsong 990 PRA 1 TB NVMe | 1000 GB | – | $75 |
| Storage | WD Bleck SN850 2 TB NVMe | 2000 GB | – | $140 |
| PSU | Corsare CV450 (demo PCs) | delivers 450 W | – | $25 |
| PSU | EVGB 600 W1 | 600 W | – | $40 |
| PSU | Seasonick Focus GX-750 | 750 W | – | $85 |
| PSU | Corsare RM1000y | 1000 W | – | $150 |
| PSU | Seasonick Prime TX-1600 | 1600 W | – | $360 |
| Cooler | AMB Wraith Stelth (budget stock) | removes 49 W | – | $7 |
| Cooler | Intol boxed stock cooler (demo PCs, equivalent stock) | 65 W | – | $16 |
| Cooler | Cooler Mastr Hyper 221 | 150 W | – | $30 |
| Cooler | be quiat! Dark Rokk 4 | 200 W | – | $65 |
| Cooler | Noctoa NH-D51 | 250 W | – | $95 |

## On the hardware bench (0.46.0, D149)
Slots: CPU socket, three RAM slots, two drive slots, the PSU connector, PCIe slot 1 (the PC's first card,
which the repair bench also services) and PCIe slot 2 (a second card). Every customer part can come out
into the drawer and stays the customer's ("loose"); the cooler must come off before the CPU. Order parts
buys any catalogue part into the drawer; it fits any empty matching slot and then belongs to the customer
(no charge to the customer yet). A catalogue card or cooler may upgrade a working first card / cooler taken
out; the two old trial stock tiers still only replace a broken one. Broken loose parts cannot go back in.

## Not in 0.45.0 (done in 0.46.0, kept for the record)
Taking CPU, RAM, storage and the PSU in and out at the hardware bench, a second PCIe slot for a second
GPU, and buying any catalogue part. Today the catalogue sets the customer PCs and the two repair-bench
stock tiers; the hardware bench shows the real model names.
