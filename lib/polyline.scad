/*
Create a 2d curved polygon strip.

The strip starts centered at [0,0], pointing to the positive x-axis.

w: Width of the polygon strip.
segs: Array of strip segment descriptors, either:
  [l]: A straight segment of length l.
  [a, r]: A curved segment ending in relative angle a, with radius r.
          Angles must be in the range (-360, 360), and are right-hand directed.
*/
module polyline(w, segs) {
  curveSegs = 100;
  polyline_rec(w, segs, 0, 0, 0, 0, [[0,w]],[[0,-w]]);
  module polyline_rec(w, segs, i, x, y, a, prefix, suffix) {
    if (i == len(segs)) {
      //accumulation done, render output
      points = concat(prefix, suffix);
      polygon(points);
    } else {
      seg = segs[i];
      if (len(seg) == 1) {
        polyline_straight_rec(w, segs, i, x, y, a, prefix, suffix);
      } else {
        polyline_curve_rec(w, segs, i, x, y, a, prefix, suffix, curveSegs);
      }
    }
  }
  module polyline_straight_rec(w, segs, i, x, y, a, prefix, suffix) {
    seg = segs[i];
    xn = x + seg[0]*cos(a);
    yn = y + seg[0]*sin(a);
    xoff = w*cos(a+90);
    yoff = w*sin(a+90);
    prefixn = concat(prefix, [[xn+xoff,yn+yoff]]);
    suffixn = concat([[xn-xoff,yn-yoff]], suffix);
    polyline_rec(w, segs, i+1, xn, yn, a, prefixn, suffixn);
  }
  module polyline_curve_rec(w, segs, i, x, y, a, prefix, suffix, curveRemaining) {
      seg = segs[i];
      angle = seg[0]/(curveSegs+1);
      len = 2*seg[1]*abs(sin(seg[0]/(2*curveSegs)));
      an = a + angle;
      xn = x + len * cos(an);
      yn = y + len * sin(an);
      if (curveRemaining == 1) {
          tangent = an+angle; // use angle of next segment, not average
          xoff = w*cos(tangent+90);
          yoff = w*sin(tangent+90);
          prefixn = concat(prefix, [[xn+xoff,yn+yoff]]);
          suffixn = concat([[xn-xoff,yn-yoff]], suffix); 
          polyline_rec(w, segs, i+1, xn, yn, an+angle, prefixn, suffixn);
      } else {
          tangent = an + angle/2;
          xoff = w*cos(tangent+90);
          yoff = w*sin(tangent+90);
          prefixn = concat(prefix, [[xn+xoff,yn+yoff]]);
          suffixn = concat([[xn-xoff,yn-yoff]], suffix); 
          polyline_curve_rec(w, segs, i, xn, yn, an, prefixn, suffixn, curveRemaining-1);
      }
  }
}

module extline(segs) {
  if ($children == 1) {
    extline_rec(segs, 0, [0,0,0], 0) {
      children();
    }
  } else {
    echo("extline requires exactly 1 child");
  }
  module extline_rec(segs, i, pos, a) {
    if (i < len(segs)) {
      if (len(segs[i]) == 1) {
        extline_straight_rec(segs, i, pos, a) {
          children(0);
        }
      } else {
        extline_curve_rec(segs, i, pos, a) {
          children(0);
        }
      }
    }
  }
  module extline_straight_rec(segs, i, pos, a) {
    d = segs[i][0];
    translate(pos) {
      rotate(a, [0,0,1]) {
        rotate(-90, [0,0,1]) {
          rotate(90, [1,0,0]) {
            translate([0,0,-d]) {
              linear_extrude(d) {
                children(0);
              }
            }
          }
        }
      }
    }
    offset = [d*cos(a),d*sin(a),0];
    extline_rec(segs, i+1, pos+offset, a) {
      children(0);
    }
  }
  module extline_curve_rec(segs, i, pos, a) {
    ang = segs[i][0];
    rad = segs[i][1];
    translate(pos) {
      rotate(a-90, [0,0,1]) {
        translate([-rad,0,0]) {
          rotate_extrude(angle=ang, $fn=30) {
            translate([rad,0]) {
              children(0);
            }
          }
        }
      }
    }
    // Magical math. Re-derive if you're curious.
    D = 2*rad*sin(ang/2);
    inlineX = [cos(a), sin(a), 0];
    inlineY = [-sin(a), cos(a), 0];
    offset = D*cos(ang/2)*inlineX + D*sin(ang/2)*inlineY;
    extline_rec(segs, i+1, pos+offset, a+ang) {
      children(0);
    }
  }
}

// Precomputes the [point, angle] pairs used by extline.
// Useful if you need to know where points on your extrusion are located.
function extline_precompute(segs) = extline_pc_rec(segs, 0, [0,0,0], 0, []);

// Accumulates `result` and dispatches the next recursive call.
function extline_pc_rec(segs, i, pos, a, result) =
  let(new_result = concat(result, [[pos,a]]))
  i == len(segs) ? new_result : (len(segs[i]) == 1 ? extline_straight_pc_rec(segs, i, pos, a, new_result) : extline_curve_pc_rec(segs, i, pos, a, new_result));

function extline_straight_pc_rec(segs, i, pos, a, result) = 
  let(d = segs[i][0])
  let(offset = [d*cos(a), d*sin(a), 0])
  extline_pc_rec(segs, i+1, pos+offset, a, result);

function extline_curve_pc_rec(segs, i, pos, a, result) = 
  let(ang = segs[i][0])
  let(rad = segs[i][1])
  // Magical math. Re-derive if you're curious.
  let(D = 2*rad*sin(ang/2))
  let(inlineX = [cos(a), sin(a), 0])
  let(inlineY = [-sin(a), cos(a), 0])
  let(offset = D*cos(ang/2)*inlineX + D*sin(ang/2)*inlineY)
  extline_pc_rec(segs, i+1, pos+offset, a+ang, result);

