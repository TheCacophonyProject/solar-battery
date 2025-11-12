

//l1 = 181.6-4;
//l2 = 85.6;
//l3 = 8;
//r1 = 5;


/*
l1 = 189;
l2 = 89;
l3 = (189-165.4)/2;
r1 = (82-65.4)/2;
*/

l1 = 189;
l2 = 89;
l3 = 15;
r1 = 11.5;

bat_to_bat = 19.3;

l4 = 85;
l5 = 85.5*2+5-1;

$fs=0.5;
$fa=2;


h = 2;


module corner(l, r) {
    difference() {
        
        
        cube([l, l, h]);
        
        translate([r, r, 0])
        cylinder(r=r, h=2*h+1, center=true);
    }
}

//!corner(10, 20);

module boarder(l1, l2, l3, r1) {
    intersection() {
        difference() {
            union() {
                cube([l1, l2-2*l3, h], center=true);
                cube([l1-2*l3, l2, h], center=true);
                cube([l1-2*l3+2*r1, l2-2*l3+2*r1, h], center=true);
            }
            
            translate([(l1/2+r1-l3), (l2/2+r1-l3), 0])
            cylinder(r=r1, h=h+1, center=true);
            
            translate([-(l1/2+r1-l3), (l2/2+r1-l3), 0])
            cylinder(r=r1, h=h+1, center=true);
            
            translate([(l1/2+r1-l3), -(l2/2+r1-l3), 0])
            cylinder(r=r1, h=h+1, center=true);
            
            translate([-(l1/2+r1-l3), -(l2/2+r1-l3), 0])
            cylinder(r=r1, h=h+1, center=true);
            
        }
        translate([2+1, 0, 0])
        cube([l5, l4, h], center=true);
        
    }
}

/*
difference() {
    
    translate([-2.5, 0, 0])
    boarder(l1, l2, l3, r1);
    
    translate([-2.5, 0, 0])
    boarder(l1-10, l2-10, l3, r1);

}
*/

module rec_from_points(x1, y1, x2, y2) {
    polygon(points=[[x1, y1], [x1, y2], [x2, y2], [x2, y1]]);
}



tab_h=17;
tab_y=0.8;
tab_x=14.3;
tab_feet_y=3;
tab_feet_x=4.4;
tab_p = 36;

module tab_main() {
    // Body
    hull() {
        // Wider at the bottom to make putting it on the PCB easier.
        translate([0, 0, tab_h/2])
        cube([tab_x, tab_y, tab_h], center=true);
        cube([tab_x, tab_y, 1], center=true);
    }
    // Feet
    translate([(tab_x-tab_feet_x)/2, tab_feet_y/2, 0.5])
    cube([tab_feet_x, tab_feet_y, 1], center=true);
    translate([-(tab_x-tab_feet_x)/2, tab_feet_y/2, 0.5])
    cube([tab_feet_x, tab_feet_y, 1], center=true);
}

module tab_positive() {
    tab_main();
    hull() {
        translate([0, 0, tab_h/2])
        cube([tab_x/3*2, tab_y, tab_h], center=true);
        translate([0, -2.3/2, tab_h/2])
        cube([tab_x/3, 2.3, tab_h], center=true);
    }
}

module tab_negative() {
    rotate([0, 0, 180]) {
        tab_main();
        // Positive tab
    
    
        hull() {
            translate([0, 0, tab_h/2])
            cube([tab_x/3*2, tab_y, tab_h], center=true);
            translate([0, -2.3/2, tab_h/2])
            cube([tab_x/3, 2.3, tab_h], center=true);
        }
        translate([0, -8/2, tab_h/2])
        cube([tab_x/3, 8, tab_h], center=true);
        translate([0, -13/2, tab_h/4-1])
        cube([8, 13, tab_h/2], center=true);

    }
}

//!tab_negative();

module battery() {
    tab_n = -36;
    
    bat_d = 18.5;
    bat_c=1;
    bat_h=1;
    tab_h=17;
    tab_t=2;
    tab_x=14.2;
    tab_feet_y=2.8;
    tab_feet_x=4;

    // Main 18650 cell cell
    translate([0, tab_n+bat_c, bat_d/2+bat_h])
    rotate([-90, 0, 0])
    minkowski() {
        sphere(r=bat_c);
        cylinder(d=bat_d-bat_c*2,h=tab_p-tab_n-bat_c*2);
    }
    

    // Battery silkscreen cutout
    linear_extrude(height=10)
    rec_from_points(3, 16.6, -3, -8);

    translate([0, tab_n, 0])
    tab_negative();
    translate([0, tab_p, 0])
    tab_positive();

    // Negative side electronics
    translate([-7.5,  -24, 0])
    cube([5, 14, 3], center=true);
    translate([7.5, -24, 0])
    cube([5, 14, 3], center=true);

    // Positive side electronics
    //translate([0, 0, -0.01])
    //linear_extrude(height=1.5)
    //rec_from_points(-8.875, 34.8, -5.4, 27.2);
    //translate([0, 0, -0.01])
    //linear_extrude(height=1.5)
    //rec_from_points(5.475, 34.3, 9.6, 27.2);
    translate([7.275, 30.6, 0])
    cube([3.6,7.4,3], center=true);
    translate([-7.925, 30.6, 0])
    cube([3.6,7.4,3], center=true);
}

/*
battery();

scale([1, -1, 1])
difference() {
    translate([bat_to_bat/2, 0, h8/2])
    cube([bat_to_bat*2, l4, h8], center=true);
    battery();
    translate([bat_to_bat, 0, 0])
    battery();
}
*/

h8 = 19/2+1;
// Flipping it around as the y axis is reversed in kicad to openscad
scale([1, -1, 1])
translate([0, 0, -h8])
difference() {
    // Main body
    //translate([0, 0, h8])
    translate([0, 0, 0.01])
    linear_extrude(height = h8)
    projection()
    boarder(l1, l2, l3, r1);

    // Battery cutout
    scale([1, -1, 1])
    translate([-72.375, 0, 0])
    for (i = [0:7]) {
        translate([i*bat_to_bat, 0, 0])
        battery();
    }

    translate([-72.375, 0, 0])
    for (i = [0:7*2+1]) {
        translate([i*bat_to_bat/2, -39.85, 0])
        cylinder(d=3.2, h=100);
        translate([i*bat_to_bat/2, 39.85, 0])
        cylinder(d=3.2, h=100);
    }

    
    // Main electronics cutout
    linear_extrude(height = 2) 
    polygon(points=[[89,27],[89,-28],[82,-29],[72, -29], [72, 6.4], [70, 9.4], [70, 14.2], [73.2, 17.4], [74.2, 24.6], [75.8, 27]]);
        
    
    // (72,27) (89,27) (89, -28) (82, -29) (72, -29) (72, 27)
    translate([0, 0, 1.9])
    hull() {
        linear_extrude(height = 2.9) 
        polygon(points=[[89,27],[89,-28],[82,-29],[72, -29],[73.2, 17.4], [74.2, 24.6], [75.8, 27]]);
        // Inductor, much higher than the other bits
        linear_extrude(height=8)
        polygon(points=[[73,-12], [73, 1], [84.5, 1], [84.5, -12]]);
    }

    // Nut cutouts

    // Plug solder joints cutouts
    hull() {
        linear_extrude(height=2.5)
        rec_from_points(-82.8, -26, -78.3, 16.5);
        linear_extrude(height=2.5)
        rec_from_points(-82.8, -26, -78.3, 16.5);
    }

    // That battery sense current limit resistor
    linear_extrude(height=1.5)
    rec_from_points(-83.3, 17.2, -81.4, 21);

    // The temp resistor
    linear_extrude(height=10)
    rec_from_points(3.6, 9.4, 6, 13.2);

    // The tabs from the other side
    linear_extrude(height=3.5)
    rec_from_points(-75, -36.7, 75, -35.3);
    linear_extrude(height=3.5)
    rec_from_points(-75, 36.7, 75, 35.3);
    
}


