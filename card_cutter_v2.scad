// measured + toleranced 
  card_w = 63.4;
  card_t = 0.3;
  //card_h = 87.9;

// design params
  // height of the label
  label_h = 4;
  // gap between cards and label
  space_h = 1.4;
  // general wall size
  wall = 3;
  // wall size at the open cut end
  cut_wall = 8;
  // gap from score line to braces (rough)
  brace_gap = 2;
  // piece thickness
  th = 2;


// computed: how far down to cut 
cut_h = label_h+space_h+card_w;

// technical
d=0.1;

linear_extrude(th) difference() {
  square([card_w+2*wall,wall+cut_h]);
  translate([wall,wall]) square([card_w,cut_h+d]);
}

linear_extrude(th-card_t) {
  translate([wall-d,wall-d]) square([card_w+2*d,label_h+d]);
  translate([wall-d,wall+cut_h-cut_wall])
    square([card_w+2*d,cut_wall]);
}

module brace() {
  open_w = card_w+wall;
  open_h = cut_h-label_h-cut_wall-2*brace_gap;
  inner_h = card_w-label_h-wall;
  translate([wall/2,wall+label_h+brace_gap])
    rotate(atan(open_h/open_w)) translate([-d,-wall/2])
    square([sqrt(open_w^2+open_h^2)+2*d,wall]);
}

linear_extrude(th-card_t) {
  brace();
  translate([card_w+2*wall,0]) mirror([1,0]) brace();
}