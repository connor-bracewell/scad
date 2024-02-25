
*translate([0,0,-2]) mirror([0,1,0]) rotate(90,[1,0,0]) rotate(180,[0,1,0]) import("Camry_Cupholder_MK_2_v1.stl");

d=0.02;
dd=2*d;

wide=160;
deep=45;
thick=4;
curve=3;

pinw=4;

module body1() {
  module cutout() cylinder(thick+dd,37,37,$fn=180);
  difference() {
    cube([160,45, thick]);
    translate([41,45,-d]) {
      cutout();
    }
    translate([160-41,45,-d]) {
      cutout();
    }
  }
}

module body2() {
  linear_extrude(thick) {
    difference() {
      square([160,45],false);
      translate([41,45]) {
        circle(37,$fn=180);
      }
      translate([160-41,45]) {
        circle(37,$fn=180);
      }
    }
  }
}

module body3() {
  module ring() {
    difference() {
      circle(41,$fn=180);
      circle(37,$fn=180);
    }
  }
  function chord_dist(c,r) = sqrt(r^2-(c/2)^2);
  module bigring() {
    bigrad = 550;
    translate([wide/2,-chord_dist(wide-8,bigrad-4)]) {
      difference() {
        circle(bigrad,$fn=180);
        circle(bigrad-4,$fn=180);
      }
    }
  }
  module chamfer(r) {
    difference() {
      translate([-d,-d]) square(r+d,false);
      translate([r,r]) circle(r,$fn=180);
    }
  }
  module chamfer_at(xy,a,r=1.5) {
    translate(xy) rotate(a) chamfer(r);
  }
  linear_extrude(thick) {
    intersection() {
      // main shape
      square([wide,deep],false);
      difference() {
        union() {
          square([4,deep],false);
          translate([wide-4,0]) square([4,deep],false);
          translate([41,45]) {
            ring();
          }
          translate([160-41,45]) {
            ring();
          }
          bigring();
        }
        chamfer_at([0,deep],-90);
        chamfer_at([4+.034,deep],-180);
        chamfer_at([78-.034,deep],-90);
        chamfer_at([82+.034,deep],-180);
        chamfer_at([156-0.34,deep],-90);
        chamfer_at([160,deep],-180);
      }
    }
  }
}

module pinholes() {
  translate([wide/2,1,thick-curve]) {
    rotate(45,[1,0,0]) {
      rotate(90,[0,1,0]) {
        // cube([1.5,1.5,wide+dd],true);
        cylinder(wide+dd,.4,$fn=180);
      }
    }
  }
}

function cirpos(a) = [cos(a),sin(a)] / cos(22.5);

module pin() {
  translate([-d,0,0]) {
    rotate(90,[0,1,0]) {
      *linear_extrude(pinw+d) {
        rotate(22.5) polygon([cirpos(0),cirpos(45),cirpos(90),cirpos(135),cirpos(180),cirpos(225),cirpos(270), cirpos(315)]);
      }
      cylinder(pinw+d,1,$fn=180);
    }
  }
}

// main
union() {
  difference() {
    body3();
    // chamfer
    difference() {
      translate([-d,-d,thick-curve]) {
        cube([160+dd,curve+d,3+d]);
      }
      translate([-d,curve,thick-curve]) {
        rotate(90,[0,1,0]) {
          cylinder(160+dd,curve,curve,$fn=180);
        }
      }
    }
  }
  translate([0,1,1]) {
    mirror([1,0,0]) pin();
    translate([wide,0,0]) pin();
  }
}