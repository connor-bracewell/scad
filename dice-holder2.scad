/*
A small part which securely stores and conveniently dispenses 6-sided dice.

Default configuration holds 6 Chessex 12mm dice, but the design is parameterized to
easily allow for other amounts of dice, or to use different dice sizes or tolerances with
a little more effort.
*/

/*[Dice Propertes]*/
// Number of dice
num_dice = 4;
// Width of each die, with tolerance
die_width = 12.35;
// Height of each die, with tolerance
die_height = 11.81;

//build volume (use %)
*cube([180,180,180]);

/*[Model Properties]*/
// Thickness of body walls
wall_thick = 1.3;

module end_customizer() {}

xaxis=[1,0,0];
yaxis=[0,1,0];
zaxis=[0,0,1];

// Width of the walls that hold the dice in
retainer_width = 2.25;

// Size of the detent "bump" holding the dice in
detent_height = 3.75;
detent_middle = 1.25;
detent_depth = 0.93;
detent_width = 3;

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
    translate([wall_thick/2,wall_thick/2]) {
      difference() {
        square(die_width+2*wall_thick/2);
        circle(die_width - retainer_width+wall_thick/2, $fn=90);
      }
    }
  }
}

module detent() {
  intersection() {
    // This gets rotated into -x,-y...
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
    linear_extrude(detent_height) {
      polygon([
        [0,0],
        [-detent_width,0],
        [-(detent_width-detent_depth*1.25),-detent_depth],
        [0,-detent_depth]
      ]);
    }
  }
}

module pos_detent() {
  translate([wall_thick+die_width-6.43,wall_thick,lip_height-detent_height]) {
    rotate(180, [0,0,1]) detent();
  }
}


module lips_cyl() {
    translate([0, -epsil, 0]) {
        rotate(-90, [1,0,0]) {
            linear_extrude(wall_thick + detent_depth + 2*epsil) {
                translate([-lip_radius + die_width + wall_thick - retainer_width, 0, 0]) {
                    circle(lip_radius, $fn=180);
                }
            }
        }
    }
}

module lips() {
    difference() {
      union() {
        linear_extrude(lip_height) {
            difference() {
                square(wall_thick + die_width - retainer_width);
                translate([wall_thick, wall_thick]) {
                    square(die_width);
                }
            }
        }
        pos_detent();
        mirror([1,-1,0]) pos_detent();
      }
      lips_cyl();
      mirror([1,-1,0]) lips_cyl();
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

module decoration() {
  deco_depth = wall_thick/2;
  translate([die_width+2*wall_thick,0,0]) {
    translate([-deco_depth+epsil,die_width+2*wall_thick,0]) {
      rotate(180,zaxis) rotate(-90,yaxis) {
        linear_extrude(deco_depth) {
          intersection() {
            square([wall_thick+num_dice*die_height+ramp_height,die_width+2*wall_thick],false);
            translate([10,4.4]) text("magic",9,"Comic Sans MS");
          }
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
                // detent();
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
            //round_cutouts();
          }
        }
        *decoration();
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
  translate([wall_thick,0,0]) mirror(xaxis) holder();
}