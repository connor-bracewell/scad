// Little legs to put something atop, with a moat
// that can be filled with water to keep ants off.

// Build plate reference
%square(180);

$fn=64;

base_thickness=2;
leg_base=35;
leg_top=25;
moat_width=15;
arm_length=100;


translate([leg_base+moat_width+base_thickness, leg_base+moat_width+base_thickness]) {
  difference() {
    union() {
      cylinder(base_thickness+moat_width, leg_base+moat_width+base_thickness, leg_base+moat_width+base_thickness);
      translate([leg_base, -moat_width/2-base_thickness]) {
        linear_extrude(base_thickness+moat_width) {
          square([arm_length+moat_width, moat_width+base_thickness*2]);
        }
      }
    }
    ring_moat();
    translate([leg_base, 0]) {
      arm_moat();
    }
  }
  translate([0, 0, base_thickness+moat_width]) {
    cylinder(100, leg_base, leg_top);
  }
}

module ring_moat() {
  translate([0, 0, base_thickness+moat_width]) {
    scale([1, 1, 2]) {
      rotate_extrude() {
        translate([leg_base, 0]) {
          intersection() {
            translate([moat_width/2, 0]) {
              circle(moat_width/2);
            }
            translate([0, -moat_width]) {
              square(moat_width, false);
            }
          }
        }
      }
    }
  }
}

module arm_moat() {
  translate([moat_width/2, 0, base_thickness+moat_width]) {
    scale([1, 1, 2]) {
      rotate(90, [0, 1, 0]) {
        linear_extrude(arm_length+moat_width/2-base_thickness) {
          intersection() {
            circle(moat_width/2);
            translate([moat_width/2, 0]) {
              square(moat_width, true);
            }
          }
        }
      }
    }
  }
}
