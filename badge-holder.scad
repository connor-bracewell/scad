use <lib/polyline.scad>

/*
// Placeholder for the badge itself.
translate([-27,0]) {
  square([54,86]);
}
*/

badge_width = 54.5;
badge_height = 86;
badge_thick = 1.7;
badge_radius = 3;

bottom_gap = 10;
lip_deep = 1; //amount lip overlaps badge.
lip_thick = 1; //how thick the lip material is. Should be > lip_deep.
border_depth = 5; //overall border in front of badge.

leg_width = (badge_width - bottom_gap) / 2;

module border() {
  br = badge_radius;
  bw = badge_width - 2*br;
  bh = badge_height- 2*br;
  lw = leg_width;
  translate([0.54,0,0]) {
    rotate(-1,[0,0,1]) {
      extline([[lw],[90,br],[bh],[91,br],[bw],[91,br],[bh],[90,br],[lw]]) {
        translate([-lip_deep,0]) {
          polygon([
            [0, 0],
            [lip_deep, lip_thick],
            [lip_deep, lip_thick+badge_thick],
            [0, 2*lip_thick+badge_thick],
            [border_depth, 2.75*lip_thick+badge_thick],
            [border_depth, 0]
          ]);
        }
      }
    }
  }
}

module holder() {
  difference() {
    union() {
      border();
      translate([0, badge_height+3, 0]) {
        linear_extrude(badge_thick + 2.75*lip_thick) {
          intersection() {
            circle(4.5, $fn=90);
            translate([0,5.097]) {
              square(9, true);
            }
          }
        }
      }
    }
    #translate([0, badge_height+3, -0.1]) {
      linear_extrude(badge_thick + 2.75*lip_thick + 0.2) {
        circle(1.25, $fn=90);
      }
    }
  }
}

render(convexity=4) {
  holder();
}

