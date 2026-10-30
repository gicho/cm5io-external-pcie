# CM5 IO Board case – lid with USB-A cut-out above the M.2 slot

## Files
| File | Purpose |
|---|---|
| `cm5io_usb_lid.scad` | Parametric OpenSCAD script for modified lid with USB cutout & "PCIe" engraving. |
| `upstream/top_cm5io.stl`, `upstream/bottom_cm5io.stl` | Unmodified base case, "Case for Raspberry Pi CM5 & CM5IO" by **Cyryllo**, https://www.printables.com/model/1098386, licence **CC BY 4.0**. |
| `out/top_cm5io_pcie.stl` | Ready-to-print modified lid STL. |
| `reference/` | CM5IO datasheet and rev 2 KiCad files (RP-008099). |

## Coordinates (from the CM5IO rev 2 KiCad PCB)
Origin: the PCB's lower-left corner, viewed from the top. The port edge is at Y = 0 and X runs along the 160 mm side.

| Feature | X | Y |
|---|---|---|
| M.2 J4 card centreline | 147.5 | – |
| M.2 stand-off hole **2230** (reference) | 147.5 | 35.75 |
| M.2 stand-off hole 2242 | 147.5 | 47.75 |
| M.2 stand-off hole 2260 | 147.5 | 65.75 |
| M.2 stand-off hole 2280 | 147.5 | 85.75 |
| Board mounting holes | (3.5,3.5) (11,8) (61.5,3.5) (132.5,8) (3.5,52.5) (61.5,52.5) (11,77) (132.5,77) | |

The hole spacing (12 / 18 / 20 mm) is the standard M.2 pattern, measured from a card edge 30 mm before the 2230 hole.

## What to measure
1. **`usb_along`**: the distance along the card from the centre of the 2230 hole to the centre of the USB-A socket opening. Positive is towards the 2280 end.
2. **`usb_across`**: the offset across the card from the card centreline. Positive is towards the nearest board edge (the right-hand edge in the datasheet drawing). The 2230 hole is on the centreline, so this is usually 0 ± a few mm.
3. **`usb_long_side_across`**: does the 13 mm long side of the socket run across the 22 mm card (`true`) or along it (`false`)?
4. **`plug_w` / `plug_t`**: the plastic over-mould of the cable plug at lid height. The lid plate is about 37 mm above the IO-board PCB.

Quick check: the 2230 and 2260 holes on the IO board are exactly 30 mm apart. Use them to confirm your ruler reading.

## Build
```bash
# Render the modified top lid STL for 3D printing
openscad -o out/top_cm5io_pcie.stl -D 'part="lid"' cm5io_usb_lid.scad

# Render an assembly preview image
openscad -o out/preview.png --preview -D 'part="preview"' --viewall --autocenter cm5io_usb_lid.scad
```
Print the bottom from `upstream/bottom_cm5io.stl` unchanged.
