// CM5 IO Board case – top lid with USB-A plug cut-out above the M.2 slot
// -----------------------------------------------------------------------
// Base design: "Case for Raspberry Pi CM5 & CM5IO" by Cyryllo
//   https://www.printables.com/model/1098386  (CC BY 4.0)
// Modification: rectangular pass-through for a USB-A cable plug that is
// inserted into a top-facing USB-A socket on a passive M.2 2280
// "mining riser" adapter fitted in the CM5IO M.2 M-key slot (J4).
//
// Board coordinates used below come from the official CM5IO rev 2 KiCad
// files (RP-008099): origin = PCB lower-left corner seen from the top,
// +X along the 160 mm edge (port edge is Y = 0), +Y towards the CM5.
//
// Usage:
//   part = "lid"      -> modified lid (export STL for printing)
//   part = "bottom"   -> unmodified bottom (passes through upstream STL)
//   part = "preview"  -> assembly preview with ghost PCB / M.2 card / plug
// -----------------------------------------------------------------------

part = "lid";              // [lid, bottom, preview]

/* ===== MEASURE THESE ON YOUR ADAPTER =================================
   Reference point = centre of the M.2 2230 stand-off hole on the IO board
   (the screw hole closest to the M.2 socket, ~30 mm from the socket).
   usb_along  : distance from that hole centre to the centre of the USB-A
                socket opening, measured ALONG the card (towards the 2280
                end / towards the CM5 edge of the board). Negative = towards
                the M.2 socket.
   usb_across : offset ACROSS the card, + = towards the right-hand board
                edge (the edge the M.2 card is next to), 0 = card centreline.
   ==================================================================== */
usb_along  = 35.0;   // mm  <-- PLACEHOLDER, replace with your measurement
usb_across = 0.0;    // mm  <-- PLACEHOLDER, replace with your measurement

// Orientation of the socket's long (≈13 mm wide) side:
//   true  = long side runs ACROSS the 22 mm card (most common for a
//           vertical socket on a 22 mm wide board)
//   false = long side runs ALONG the card
usb_long_side_across = true;

/* Size of the hole = what has to pass THROUGH the lid. The plug is pushed
   into the socket ~18-20 mm below the lid, so the lid sees the plastic
   over-mould of the cable plug (not the 12 x 4.5 mm metal shell).
   Measure the over-mould (widest part that sits at lid height). */
plug_w = 16.0;       // mm, over-mould long side   <-- measure
plug_t = 8.5;        // mm, over-mould short side  <-- measure
clearance = 0.8;     // mm per side (FDM tolerance + position error)
corner_r  = 1.0;     // mm, corner radius of the cut-out

/* Fill the honeycomb vents around the hole so the opening gets a clean,
   solid frame. Set to 0 to disable. */
frame = 3.0;         // mm, solid band around the cut-out

/* Text engraving around the cut-out to clearly indicate PCIe bus signals */
engrave_text  = "PCIe";
engrave_depth = 0.6; // mm into top surface
text_size     = 3.5; // mm font size

/* ===== Geometry constants (do not change unless the base model changes) */
// Upstream STLs are placed so that the PCB lower-left corner sits here:
board_origin_stl = [-271, -160, 0];   // PCB bottom face at Z = 0
pcb_t       = 1.6;
lid_plate_z = [39, 41];               // lid top plate (2 mm) in STL Z
// CM5IO M.2 J4 (from KiCad, board coords)
m2_x        = 147.5;                  // card centreline
m2_hole_2230 = [147.5, 35.75];
m2_holes     = [[147.5,35.75],[147.5,47.75],[147.5,65.75],[147.5,85.75]];
m2_card_edge_y = 5.75;                // card gold-finger edge (2230 hole - 30)

usb_center_board = [m2_hole_2230[0] + usb_across, m2_hole_2230[1] + usb_along];
hole_dx = (usb_long_side_across ? plug_w : plug_t) + 2*clearance;
hole_dy = (usb_long_side_across ? plug_t : plug_w) + 2*clearance;

$fn = 48;

module rrect(dx, dy, h, r) {
    r2 = min(r, dx/2 - 0.01, dy/2 - 0.01);
    linear_extrude(h) offset(r = r2) square([dx - 2*r2, dy - 2*r2], center = true);
}

module in_board_frame() { translate(board_origin_stl) children(); }

module lid_modified() {
    difference() {
        union() {
            import("upstream/top_cm5io.stl", convexity = 10);
            if (frame > 0)
                in_board_frame()
                    translate([usb_center_board[0], usb_center_board[1], lid_plate_z[0]])
                        rrect(hole_dx + 2*frame, hole_dy + 2*frame,
                              lid_plate_z[1] - lid_plate_z[0], corner_r + frame);
        }
        // Rectangular cut-out for plug
        in_board_frame()
            translate([usb_center_board[0], usb_center_board[1], lid_plate_z[0] - 1])
                rrect(hole_dx, hole_dy, lid_plate_z[1] - lid_plate_z[0] + 2, corner_r);

        // Engraved text on the top surface
        if (len(engrave_text) > 0 && engrave_depth > 0) {
            in_board_frame()
                translate([usb_center_board[0], usb_center_board[1] - (hole_dy/2 + frame/2 + 0.5), lid_plate_z[1] - engrave_depth])
                    linear_extrude(engrave_depth + 0.1)
                        text(engrave_text, size = text_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
        }
    }
}

module ghost_parts() {
    in_board_frame() {
        // IO board
        color("green", 0.5) cube([160, 90, pcb_t]);
        // M.2 2280 card (approx. 3 mm above PCB top)
        color("royalblue", 0.6)
            translate([m2_x - 11, m2_card_edge_y, pcb_t + 2.5]) cube([22, 80, 0.8]);
        // stand-off holes (markers)
        for (h = m2_holes) color("red") translate([h[0], h[1], pcb_t]) cylinder(d = 2, h = 3);
        // USB plug over-mould column from socket up through the lid
        color("orange", 0.7)
            translate([usb_center_board[0], usb_center_board[1], pcb_t + 4])
                rrect(usb_long_side_across ? plug_w : plug_t,
                      usb_long_side_across ? plug_t : plug_w, 50, 1);
    }
}

if (part == "lid") {
    lid_modified();
} else if (part == "bottom") {
    import("upstream/bottom_cm5io.stl", convexity = 10);
} else {
    color("lightgray", 0.35) import("upstream/bottom_cm5io.stl", convexity = 10);
    color("gold", 0.5) lid_modified();
    ghost_parts();
}

echo(str("USB cut-out centre (board coords) = ", usb_center_board,
         ", hole size = ", hole_dx, " x ", hole_dy, " mm"));
