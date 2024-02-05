use <lib/polyline.scad>

badge_width = 54.5;
badge_height = 86;
badge_thick = 1.7;
badge_radius = 3;

lip_deep = 1; //amount lip overlaps badge.
lip_thick = 1; //how thick the lip material is. Should be > lip_deep.
border_depth = 4.5; //overall border in front of badge.

index_radius = 2.25;

arm_angle = 86.75;  // Angle to spread the arms so they clear one another. Set by guess-and-check.

leg_width = badge_width/2 - badge_radius + border_depth;

module border(segs) {
  extline(segs) {
    translate([-lip_deep,0]) {
      polygon([
        [0, 0],
        [lip_deep, lip_thick],
        [lip_deep, lip_thick+badge_thick],
        [0, 2*lip_thick+badge_thick],
        [border_depth, 2*lip_thick+badge_thick],
        [border_depth, 0]
      ]);
    }
  }
}

module holder() {
  br = badge_radius;
  bw = badge_width - 2*br;
  bh = badge_height- 2*br;
  lw = leg_width;
  aa = arm_angle;
  segs = [[lw],[90,br],[bh],[aa,br],[bw],[aa,br],[bh],[90,br],[lw]];
  points = extline_precompute(segs);
  difference() {
    union() { 
      // The main border.
      border(segs);
      // The half-circle at the top.
      translate((points[4][0]+points[5][0])/2) {
        linear_extrude(badge_thick + 2*lip_thick) {
          rotate(points[4][1]+180, [0,0,1]) {
            translate([0, border_depth - lip_deep, 0]) {
              intersection() {
                circle(border_depth, $fn=90);
                translate([-50, 0]) {
                  square(100);
                }
              }
            }
          }
        }
      }
      // The half-circle at the bottom-right.
      translate(points[0][0]) {
        linear_extrude(badge_thick + 2*lip_thick) {
          rotate(points[0][1]+180, [0,0,1]) {
            translate([-border_depth, border_depth - lip_deep, 0]) {
              intersection() {
                circle(border_depth, $fn=90);
                translate([-50, 0]) {
                  square(100);
                }
              }
            }
          }
        }
      }
      // The half-circle at the bottom-left.
      translate(points[len(points)-1][0]) {
        linear_extrude(badge_thick + 2*lip_thick) {
          rotate(points[len(points)-1][1]+180, [0,0,1]) {
            translate([border_depth, border_depth - lip_deep, 0]) {
              intersection() {
                circle(border_depth, $fn=90);
                translate([-50, 0]) {
                  square(100);
                }
              }
            }
          }
        }
      }
    }
    // The hole at the top.
    #translate((points[4][0]+points[5][0])/2 + [0,0,-0.1]) {
      rotate(points[4][1] + 180, [0,0,1]) {
        translate([0, border_depth-lip_deep, 0]) {
          linear_extrude(badge_thick + 2*lip_thick + 0.2) {
            circle(1.5, $fn=90);
          }
        }
      }
    }
    // The hole at the bottom-right.
    #translate(points[0][0] + [0,0,-0.1]) {
      rotate(points[0][1] + 180, [0,0,1]) {
        translate([-border_depth, border_depth-lip_deep, 0]) {
          linear_extrude(badge_thick + 2*lip_thick + 0.2) {
            circle(1.5, $fn=90);
          }
        }
      }
    }
    // The hole at the bottom-left.
    #translate(points[len(points)-1][0] + [0,0,-0.1]) {
      rotate(points[len(points)-1][1] + 180, [0,0,1]) {
        translate([border_depth, border_depth-lip_deep, 0]) {
          linear_extrude(badge_thick + 2*lip_thick + 0.2) {
            circle(index_radius + 0.25, $fn=90);
          }
        }
      }
    }
    // The relief at the bottom-right, with the index.
    #difference() {
      translate(points[0][0]) {
        linear_extrude((badge_thick + 2*lip_thick)/2+0.3) {
          rotate(points[0][1]+180, [0,0,1]) {
            translate([-border_depth, border_depth - lip_deep, 0]) {
              square((border_depth+0.25)*2, true);
            }
          }
        }
      }
      translate(points[0][0]) {
        linear_extrude((badge_thick + 2*lip_thick)/2+0.2) {
          rotate(points[0][1]+180, [0,0,1]) {
            translate([-border_depth, border_depth - lip_deep, 0]) {
              circle(index_radius, $fn=90);
            }
          }
        }
      }
    }
    // The relief at the bottom-left.
    #translate(points[len(points)-1][0]) {
      rotate(points[len(points)-1][1]+180, [0,0,1]) {
        translate([border_depth, border_depth - lip_deep, badge_thick/2 + lip_thick - 0.1]) {
          linear_extrude(badge_thick/2 + lip_thick*1.75) {
            square((border_depth+0.25)*2, true);
          }
        }
      }
    }
  }
}

render(convexity=4) {
  holder();
}

