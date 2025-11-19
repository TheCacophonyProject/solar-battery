$fs=0.6;
$fa=4;


// ========== Boarder =============
// To make the boarder, we generate the boarder with the recommended maximum 
// measurements and then do an intersection from that with a rectangle.
// This makes it easy to resize/offset the boarder to fit in the case without 
// Needing to worry with being too big

// These are the maximum sizes that we want the boarder to be
width_max = 189;    // This is the width available for the back panel
depth_max = 89;     // This is the depth available for the back panel
corner_cutout = 15;             // For the corner cutouts this is the length that it is straight before it has its radius
corner_cutout_radius = 11.5;    // For the corner cutouts, this is the radius (not including the straight part)

// This is the size of the rectangle that will do an intersection with the maximum 
// boarder to get the final boarder.
// An offset is also used to make one end have more space for plugs.
depth = 85;
width = 85.5*2+5-1;
boarder_offset = 3;



// Distance from one battery cell to another.
bat_to_bat = 19.3;





h = 2;

module boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width) {
    intersection() {
        difference() {
            union() {
                cube([width_max, depth_max-2*corner_cutout, h], center=true);
                cube([width_max-2*corner_cutout, depth_max, h], center=true);
                cube([width_max-2*corner_cutout+2*corner_cutout_radius, depth_max-2*corner_cutout+2*corner_cutout_radius, h], center=true);
            }
            
            translate([(width_max/2+corner_cutout_radius-corner_cutout), (depth_max/2+corner_cutout_radius-corner_cutout), 0])
            cylinder(r=corner_cutout_radius, h=h+1, center=true);
            
            translate([-(width_max/2+corner_cutout_radius-corner_cutout), (depth_max/2+corner_cutout_radius-corner_cutout), 0])
            cylinder(r=corner_cutout_radius, h=h+1, center=true);
            
            translate([(width_max/2+corner_cutout_radius-corner_cutout), -(depth_max/2+corner_cutout_radius-corner_cutout), 0])
            cylinder(r=corner_cutout_radius, h=h+1, center=true);
            
            translate([-(width_max/2+corner_cutout_radius-corner_cutout), -(depth_max/2+corner_cutout_radius-corner_cutout), 0])
            cylinder(r=corner_cutout_radius, h=h+1, center=true);
        }
        translate([boarder_offset, 0, 0])
        cube([width, depth, h], center=true); 
    }
}

module rec_from_points(x1, y1, x2, y2, r=0) {
    if (r == 0) {
        polygon(points=[[x1, y1], [x1, y2], [x2, y2], [x2, y1]]);
    } else {
        minkowski() {
            polygon(points=[[x1+r, y1+r], [x1+r, y2-r], [x2-r, y2-r], [x2-r, y1+r]]);
            circle(r = r);
        }
    }
}

tab_h=17;
tab_y=1.2;
tab_x=15.3;
tab_feet_y=4;
tab_feet_x=4.4;
tab_p = 35;

module tab_main() {
    // Body
    hull() {
        // Wider at the bottom to make putting it on the PCB easier.
        translate([0, 0, -1])
        linear_extrude(height = 1) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y, x2 = tab_x/2, y2 = tab_y, r=0.4);
        linear_extrude(height = tab_h) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y/2, x2 = tab_x/2, y2 = tab_y/2, r=0.4);
    }

    difference() {
        hull() {
            translate([-(0)/2, tab_feet_y/2, -1])
            linear_extrude(height=2)
            rec_from_points(x1 = -bat_to_bat/2-0.5, y1 = -tab_feet_y/2-1, x2 = bat_to_bat/2+0.5, y2 = tab_feet_y/2);

            translate([-(0)/2, tab_feet_y/2-1.4, 5])
            cube([bat_to_bat+1, 0.1, 1], center=true);
        }

        translate([0, -tab_p+39.85, -2])
        cylinder(d=3.3+1.8, h=5); 

        translate([bat_to_bat/2, -tab_p+39.85, -2])
        cylinder(d=3.3+1.8, h=5);
        translate([-bat_to_bat/2, -tab_p+39.85, -2])
        cylinder(d=3.3+1.8, h=5);    
    }   
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

        translate([0, -13/2, -1])
        linear_extrude(height = tab_h)
        rec_from_points(-4, -6.5, 4, 7, r=1);


        translate([5.5, -2.7, -1])
        rotate([0, 1.9, 90])
        rotate_extrude(angle=90)
        translate([1.5, 0, 0])
        square([1, tab_h]);

        translate([-5.5, -2.7, -1])
        rotate([-1.9, 0, 0])
        rotate_extrude(angle=90)
        translate([1.5, 0, 0])
        square([1, tab_h]); 
        
        //cube([8, 13, tab_h/2], center=true);

    }
}

module electronics_cutout() {
    translate([0, 0, -1])
    linear_extrude(height = 2)
    rec_from_points(x1 = -bat_to_bat+5, y1 = -33, x2 = -5, y2 = -15, r=1);
    
    hull() {
        translate([0, 0, 1-0.1])
        linear_extrude(height = 0.1)
        rec_from_points(x1 = -bat_to_bat+5, y1 = -33, x2 = -5, y2 = -15);

        translate([-bat_to_bat/2, -24, 4])
        cube([0.01, 18, 0.01], center=true);

        //linear_extrude(height = 5)
        //rec_from_points(x1 = -bat_to_bat+9.5, y1 = -33, x2 = -9.5, y2 = -15);
    }
}

screw_hole_diameter = 2.6;
screw_head_diameter = 6.2;
screw_hole_y = 39.85;
screw_hole_dx = bat_to_bat/2;
module screw_cutout() {
    a = 5;
    translate([0, 0, -1])
    cylinder(d=3.5, h=h8);
    
    translate([0, 0, a-1])
    cylinder(d1=3.5, d2=screw_head_diameter, h=1);
    hull() {    
        translate([0, 0, a])
        cylinder(d=screw_head_diameter, h=h8);
        
    //    translate([0, 10, h8/2+a])
    //    cube([screw_head_diameter*2, 1, h8], center=true);
    }
}

//!screw_cutout();

module battery() {
    tab_n = -35;
    
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
    translate([0, 0, -1])
    linear_extrude(height=10)
    rec_from_points(x1=-3, y2=16.6, x2=3, y1=-8, r=0.5);

    translate([0, tab_n, 0])
    tab_negative();
    translate([0, tab_p, 0])
    tab_positive();
}

// Test cells
scale([1, -1, 1])
union() {
    count = 2;
    difference() {
        translate([bat_to_bat/2*count-bat_to_bat/2, 0, h8/2])
        cube([bat_to_bat*count, depth, h8], center=true);

        // Batteries
        for (i = [0:count-1]) {
            //battery();
            translate([i*bat_to_bat, 0, 0])
            //rotate([0, 0, (i+1)*180])
            battery();
        }

        // Cell protection cutout
        for (i = [0:count]) {
            translate([i*bat_to_bat, 0, 0])
            electronics_cutout();
            
            scale([1, -1, 1])
            translate([i*bat_to_bat, 0, 0])
            electronics_cutout();
        }

        mid_joints = [false, false, true, false, true];
        for (i = [0:count*2-2]) {
            translate([screw_hole_dx*i, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (mid_joints[i]) {
                translate([screw_hole_dx*i, screw_hole_y, 0])
                screw_cutout();
            }
        }

        mid_joints2 = [true, false, false, false, false];
        scale([1, -1, 1])
        for (i = [0:count*2-2]) {
            translate([screw_hole_dx*i, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (mid_joints2[i]) {
                translate([screw_hole_dx*i, screw_hole_y, 0])
                screw_cutout();
            }
        }
    }

    translate([bat_to_bat/2*count-bat_to_bat/2, 0, 0.2])
    difference() {
        cube([bat_to_bat*count, depth, 0.4], center=true);
        cube([bat_to_bat*count-1.6, depth-1.6, 0.6], center=true);
    }
}


battery_top_rotations = [0, 0, 1, 1, 1, 0, 0];
battery_bottom_rotations = [1, 1, 1, 0, 0, 1, 1, 1];
temp_sensors = [1, 0, 0, 1, 0, 0, 0];

h8 = 19/2+1;


// Flipping it around as the y axis is reversed in kicad to openscad
scale([1, -1, 1])
translate([0, 0, -h8])
union() {
    difference() {
        // Main body
        translate([0, 0, 0.01])
        linear_extrude(height = h8)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        translate([0, 0, -1])
        intersection() {
            translate([50 + 53.075 + bat_to_bat/2+1, 0, 0])
            cube([100, 200, 30], center=true);
            linear_extrude(height = h8)
            projection()
            boarder(width_max+4, depth_max+4, corner_cutout+4, corner_cutout_radius+2, depth-4, width-4);
        }

        // Battery cutout
        scale([1, -1, 1])
        translate([53.075, 0, 0])
        for (i = [0:6]) {
            translate([-i*bat_to_bat, 0, 0])
            
            rotate([0, 0, battery_top_rotations[i]*180])
            battery();

            if (temp_sensors[i] == 1) {
                translate([-i*bat_to_bat, 0, 0])
                rotate([0, 0, battery_top_rotations[i]*180])
                translate([0, -14.5, -1])
                cylinder(r=2, h = 20);
            }
        }

        // Cell protection cutout
        translate([53.075+bat_to_bat, 0, 0])
        for (i = [0:7]) {
            translate([-i*bat_to_bat, 0, 0])
            electronics_cutout();
            
            scale([1, -1, 1])
            translate([-i*bat_to_bat, 0, 0])
            electronics_cutout();
        }

        // Inductor cutout
        translate([width/2, -6.6, -16/2+h8-1])
        cube(16, center=true);

        // Fuse cutout
        translate([78.76, -34.32])
        cylinder(r=2, h=3);

        ////////////////////////////////////////////////
        // Bolt cutout
        mid_joints = [false, false, false, false, false];
        for (i = [0:13]) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 0 || i == 13) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }

        mid_joints2 = [true, false, false, false, false];
        scale([1, -1, 1])
        for (i = [0:13]) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 7) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }
    }

    // This is just a thin loop that goes around the edge
    // This helps with the printability, making the outer edge a full loop.
    difference() {
        a = 1;
        linear_extrude(height = 0.4)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        translate([0, 0, -0.2])
        linear_extrude(height = 0.8)
        projection()
        boarder(width_max-a, depth_max-a, corner_cutout, corner_cutout_radius, depth-a, width-a);
    }
}

// Top side, outside bit.
// Flipping it around as the y axis is reversed in kicad to openscad
!scale([1, -1, 1])
union() {
    difference() {
        // Main body
        linear_extrude(height = h8)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        // Battery cutout
        scale([1, -1, 1])
        translate([53.075, 0, -h8])
        for (i = [0:6]) {
            translate([-i*bat_to_bat, 0, 0])    
            rotate([0, 0, battery_top_rotations[i]*180])
            battery();

            translate([-i*bat_to_bat, 0, 0])
            cube([10, 40, 100], center=true);
        }

        ////////////////////////////////////////////////
        // Bolt cutout
        translate([0, 0, 0]) {
        for (i = [0:13]) {
            //translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            //cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }

        scale([1, -1, 1])
        for (i = [0:13]) {
            //translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            //cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }
        }

         // chamfer on plug side
        translate([width/2+boarder_offset, -depth/2, 0]) 
        rotate([0, -45, 0])
        cube([2*h8, depth, 2*h8]);

        // chamfer on plug side
        mirror([1, 0, 0])
        translate([width/2+boarder_offset, -depth/2, 0]) 
        rotate([0, -45, 0])
        cube([2*h8, depth, 2*h8]);

        // chamfer on long sides
        translate([-width/2, depth/2, h8-6])
        rotate([45, 0, 0])
        cube([width, 2*h8, 2*h8]);

        mirror([0, 1, 0])
        translate([-width/2, depth/2, h8-6])
        rotate([45, 0, 0])
        cube([width, 2*h8, 2*h8]);
    }

    // Mouse ears to help with printing stability
    translate([80, 37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([80, -37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([-80, 37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([-80, -37, h8-0.2])
    cylinder(d=6, h=0.2);
}

// Bottom side, inside bit
// Flipping it around as the y axis is reversed in kicad to openscad
scale([1, -1, 1])
translate([0, 0, -h8])
union() {
    difference() {
        bat_offset = -72.375;
        // Main body
        translate([0, 0, 0.01])
        linear_extrude(height = h8)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        // Battery cutout
        scale([1, -1, 1])
        translate([bat_offset, 0, 0])
        for (i = [0:7]) {
            translate([i*bat_to_bat, 0, 0])
            rotate([0, 0, battery_bottom_rotations[i]*180])
            battery();
        }

        ////////////////////////////////////////////////
        // Bolt cutout
        translate([0, 0, h8]) {
        for (i = [0:13]) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 0 || i == 13) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }

        scale([1, -1, 1])
        for (i = [0:13]) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 7) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }
        }

        // Output 1 cutout
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 30)
        rec_from_points(81, 14.8, 92.2, 27.4, r=0.4); 

        // Output 2 cutout
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 30)
        rec_from_points(81, -0.4, 92.2, 12.1, r=0.4); 

        // Input
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 30)
        rec_from_points(81.1, -28.65, 91.9, -19.85, r=0.4); 
    }

    // This is just a thin loop that goes around the edge
    // This helps with the printability, making the outer edge a full loop.
    difference() {
        a = 1;
        linear_extrude(height = 0.4)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        translate([0, 0, -0.2])
        linear_extrude(height = 0.8)
        projection()
        boarder(width_max-a, depth_max-a, corner_cutout, corner_cutout_radius, depth-a, width-a);
    }
}



// Bottom side, outside bit.
// Flipping it around as the y axis is reversed in kicad to openscad
scale([1, -1, 1])
union() {
    difference() {
        bat_offset = -72.375;
        // Main body
        linear_extrude(height = h8)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        // Battery cutout
        scale([1, -1, 1])
        translate([bat_offset, 0, -h8])
        for (i = [0:7]) {
            translate([i*bat_to_bat, 0, 0])
            rotate([0, 0, battery_bottom_rotations[i]*180])
            battery();

            translate([i*bat_to_bat, 0, 0])
            cube([10, 40, 100], center=true);
        }

        ////////////////////////////////////////////////
        // Bolt cutout
        for (i = [0:13]) {
            //translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            //cylinder(d=screw_hole_diameter, h=40, center=true);

            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }

        scale([1, -1, 1])
        for (i = [0:13]) {
            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_cutout();
            }
        }

        // Output 1 cutout
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 40)
        rec_from_points(81, 14.8, 92.2, 27.4, r=0.4); 

        // Output 2 cutout
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 40)
        rec_from_points(81, -0.4, 92.2, 12.1, r=0.4); 

        // Input
        translate([0, 0, -10])
        scale([1, -1, 1])
        linear_extrude(height = 40)
        rec_from_points(81.1, -28.65, 91.9, -19.85, r=0.4); 

        // chamfer on plug side
        translate([width/2+boarder_offset, -depth/2, 0]) 
        rotate([0, -45, 0])
        cube([2*h8, depth, 2*h8]);

        // chamfer on plug side
        mirror([1, 0, 0])
        translate([width/2+boarder_offset, -depth/2, 0]) 
        rotate([0, -45, 0])
        cube([2*h8, depth, 2*h8]);

        // chamfer on long sides
        translate([-width/2, depth/2, h8-6])
        rotate([45, 0, 0])
        cube([width, 2*h8, 2*h8]);

        mirror([0, 1, 0])
        translate([-width/2, depth/2, h8-6])
        rotate([45, 0, 0])
        cube([width, 2*h8, 2*h8]);
    }

    // Mouse ears to help with printing stability
    translate([80, 37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([80, -37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([-80, 37, h8-0.2])
    cylinder(d=6, h=0.2);
    translate([-80, -37, h8-0.2])
    cylinder(d=6, h=0.2);

    /*
    // This is just a thin loop that goes around the edge
    // This helps with the printability, making the outer edge a full loop.
    translate([0, 0, 2*h8-0.4]) 
    difference() {
        a = 1;
        linear_extrude(height = 0.4)
        projection()
        boarder(width_max, depth_max, corner_cutout, corner_cutout_radius, depth, width);

        translate([0, 0, -0.2])
        linear_extrude(height = 0.8)
        projection()
        boarder(width_max-a, depth_max-a, corner_cutout, corner_cutout_radius, depth-a, width-a);
    }
    */
}


