/*
A small part which securely stores and conveniently dispenses 6-sided dice.

Default configuration holds 6 Chessex 12mm dice, but the design is parameterized to
easily allow for other amounts of dice, or to use different dice sizes or tolerances with
a little more effort.
*/

// Number of dice to generate for
num_dice = 6;

// Dimensions of the dice, with tolerance
die_width = 12.40;
die_height = 11.93;

// Thickness of all body walls
wall_thick = 1.5;

// Width of the walls that hold the dice in
retainer_width = 2.25;

// Size of the detent "bump" holding the dice in
detent_height = 3.75;
detent_middle = 1.25;
detent_depth = 1.1;
detent_width = 4;

// Size of the slots either side of the detent
cutout_width = 0.5;
cutout_height = 8;
cutout_radius = 40;
cutout_angle = 16; // Portion of circle to use for cutouts, in degrees

// Space above the top of the last die; used to align the detent
ramp_height = 2.85;

// Total height and radius to use for "lips" that constrict toward the opening
lip_radius = 50;
lip_height = 20;

// Tolerance value to avoid floating point errors in render
epsil = 0.001;


module body() {
    linear_extrude(wall_thick + num_dice * die_height + ramp_height) {
        difference() {
            square(die_width + 2*wall_thick);
            translate([wall_thick, wall_thick]) {
                square(die_width);
            }
            square(die_width + wall_thick - retainer_width);
        }
    }
}

module cap() {
    linear_extrude(wall_thick) {
        translate([wall_thick, wall_thick]) {
            difference() {
                square(die_width);
                circle(die_width - retainer_width, $fn=90);
            }
        }
    }
}

module detent() {
    rotate(-90, [0,0,1]) {
        rotate(90, [1,0,0]) {
            linear_extrude(detent_width) {
                polygon([
                    [0,0],
                    [detent_depth,detent_middle],
                    [0,detent_height]
                ]);
            }
        }
    }
}

module lips_cyl() {
    translate([0, -epsil, 0]) {
        rotate(-90, [1,0,0]) {
            linear_extrude(wall_thick + 2*epsil) {
                translate([-lip_radius + die_width + wall_thick - retainer_width, 0, 0]) {
                    circle(lip_radius, $fn=180);
                }
            }
        }
    }
}

module lips() {
    difference() {
        linear_extrude(lip_height) {
            difference() {
                square(wall_thick + die_width - retainer_width);
                translate([wall_thick, wall_thick]) {
                    square(die_width);
                }
            }
        }
        lips_cyl();
        mirror([1,-1,0]) {
            lips_cyl();
        }
    }
}

module cutouts() {
    translate([0,0,-cutout_height-ramp_height]) {
        cube([cutout_width, wall_thick + 2*epsil, cutout_height + ramp_height]);
        translate([cutout_width + detent_width, 0, 0]) {
            cube([cutout_width, wall_thick + 2*epsil, cutout_height + ramp_height]);
        }
    }
}

module round_cutouts() {
    rotate(-90, [1,0,0]) {
        linear_extrude(wall_thick + 2*epsil) {
            translate([-cutout_radius+cutout_width, 0]) {
                intersection() {
                    difference() {
                        circle(cutout_radius, $fn=90);
                        circle(cutout_radius-cutout_width, $fn=90);
                    }
                    polygon([
                        [0,0],
                        [999*cos(cutout_angle),999*sin(cutout_angle)],
                        [999,0]
                    ]);
                }
            }
            translate([cutout_radius+detent_width+cutout_width, 0]) {
                intersection() {
                    difference() {
                        circle(cutout_radius, $fn=90);
                        circle(cutout_radius-cutout_width, $fn=90);
                    }
                    polygon([
                        [0,0],
                        [-999*cos(cutout_angle),999*sin(cutout_angle)],
                        [-999,0]
                    ]);
                }
            }
        }
    }
}

module holder() {
    // Align and put together all the bits
    difference() {
        union() {
            body();
            cap();
            translate([
                (wall_thick*2 + die_width + detent_width)/2,
                wall_thick + die_width,
                wall_thick + num_dice*die_height + ramp_height - detent_height
            ]) {
                detent();
            }
            translate([0, 0, wall_thick + num_dice*die_height + ramp_height - lip_height]) {
                lips();
            }
        }
        translate([
            wall_thick + (die_width - detent_width)/2 - cutout_width,
            wall_thick + die_width - epsil,
            wall_thick + die_height*num_dice + ramp_height + epsil
        ]) {
          union() {
            //cutouts();
            round_cutouts();
          }
        }
    }
}

module on_axis_holder() {
    translate([-1.5*wall_thick - die_width, -1.5*wall_thick - die_width, 0]) {
        holder();
    }
}

module triholder() {
    on_axis_holder();
    rotate(120, [0,0,1]) {
        on_axis_holder();
    }
    rotate(-120, [0,0,1]) {
        on_axis_holder();
    } 
}

render(convexity=8) {
    holder();
}
