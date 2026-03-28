// ============================================================
//  Cup Holder Expander
//  Three-section design: base cylinder → taper → top cylinder
//  Top cylinder includes a vertical notch for the cup handle.
// ============================================================

// --- Parameters ---------------------------------------------

wall_thickness   =  3;   // [mm] uniform wall thickness throughout

// Base (bottom cone — fits into existing cup holder)
base_bottom_od   = 67;   // [mm] outer diameter at the very bottom of the base
base_top_od      = 77;   // [mm] outer diameter at the top of the base cone
base_height      = 75;   // [mm] height of base cone

// Taper (conical transition section)
taper_height    = 20;    // [mm] height of the conical transition

// Top (larger cylinder — holds the new cup)
top_od          = 122;    // [mm] outer diameter of top cylinder
top_height      = 70;    // [mm] height of top cylinder

// Handle notch (rectangular cutout on top cylinder)
notch_width     = 22;    // [mm] width of the handle notch
notch_height    = 65;    // [mm] depth the notch extends downward from the top rim
notch_corner_r  =  4;    // [mm] radius of the rounded corners (top and bottom)

// --- Derived values -----------------------------------------

base_bottom_id = base_bottom_od - 2 * wall_thickness;
base_top_id    = base_top_od   - 2 * wall_thickness;
top_id         = top_od        - 2 * wall_thickness;

// Small epsilon for clean boolean unions/differences
eps = 0.01;

// ============================================================
//  Assembly
// ============================================================

union() {
    base_cylinder();
    translate([0, 0, base_height])
        taper_section();
    translate([0, 0, base_height + taper_height])
        top_cylinder();
}

// ============================================================
//  Modules
// ============================================================

// --- 1. Base cone -------------------------------------------
module base_cylinder() {
    difference() {
        // Outer cone: base_bottom_od at bottom → base_top_od at top
        cylinder(h = base_height,
                 d1 = base_bottom_od, d2 = base_top_od,
                 $fn = 128);
        // Hollow interior (open top, closed bottom)
        translate([0, 0, wall_thickness])
            cylinder(h = base_height - wall_thickness + eps,
                     d1 = base_bottom_id, d2 = base_top_id,
                     $fn = 128);
    }
}

// --- 2. Taper / conical transition --------------------------
module taper_section() {
    difference() {
        // Outer cone: base_top_od at bottom → top_od at top
        cylinder(h = taper_height,
                 d1 = base_top_od, d2 = top_od,
                 $fn = 128);
        // Inner cone (hollow), offset inward by wall_thickness
        translate([0, 0, -eps])
            cylinder(h = taper_height + 2 * eps,
                     d1 = base_top_id, d2 = top_id,
                     $fn = 128);
    }
}

// --- 3. Top cylinder with handle notch ----------------------
module top_cylinder() {
    difference() {
        // Solid outer cylinder
        cylinder(h = top_height, d = top_od, $fn = 128);

        // Hollow interior (open top, no floor — taper provides floor)
        translate([0, 0, -eps])
            cylinder(h = top_height + 2 * eps, d = top_id, $fn = 128);

        // Handle notch: rounded slot from the top downward
        // Centered on the +X side of the cylinder (adjust rotation to taste)
        notch_cutter();
    }
}

// --- 4. Rounded notch cutter --------------------------------
module notch_cutter() {
    r = notch_corner_r;
    // bottom of notch
    z = top_height - notch_height + r;
    hull() {
        for (y = [-notch_width/2 + r,  notch_width/2 - r])
            translate([0, y, z])
                rotate([0, 90, 0])
                    cylinder(h = top_od / 2 + eps, r = r, $fn = 64);
    }
    // middle of notch
    translate([0, -notch_width / 2, top_height - notch_height + r])
    cube([top_od / 2 + eps, notch_width, notch_height + eps - r]);
    // top left of notch
    translate([0, -notch_width / 2 - r, top_height - r])
    difference() {
        cube([top_od / 2 + eps, r, notch_height + eps - r]);
        rotate([0, 90, 0])
            cylinder(h = top_od / 2 + eps, r = r, $fn = 64);
        
    }
    // top right of notch
    translate([0, notch_width / 2 + r, top_height - r])
    mirror([0, 1, 0]) {
        difference() {
            cube([top_od / 2 + eps, r, notch_height + eps - r]);
            rotate([0, 90, 0])
                cylinder(h = top_od / 2 + eps, r = r, $fn = 64);
        }
    }
}
