$fs=0.4;
$fa=4;

// $fa = 8;
// $fs = 0.8;

output = "bottom_side_inner";

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
width = 177;
boarder_offset = 4;

// Distance from one battery cell to another.
bat_to_bat = 19.3;

h = 2;

screw_head_diameter = 6.2;
screw_hole_y = 39.85;
screw_hole_dx = bat_to_bat/2;
screw_diameter_clearance = 3.5;
screw_diameter_pilot = 2.6;

plug_screw_x = 87.5;

solid_infill_diameter = 10;

bat_d = 18.8;
bat_h=1;
tab_n = -35;

battery_top_rotations = [0, 0, 1, 1, 1, 0, 0];
battery_bottom_rotations = [1, 1, 1, 0, 0, 1, 1, 1];
temp_sensors = [1, 0, 0, 1, 0, 0, 0];

h8 = 19/2+1;

tab_h=18;       // Height of the battery tab hole
tab_y=1.2;      // Thickness of the battery tab hole
tab_x=15.3;     // x position of the battery tab
tab_feet_y=4;
tab_feet_x=4.4;
tab_p = 35;

// Buzzer
buzzer_pos_x = 71.4;
buzzer_pos_y = -30.1;
buzzer_d = 10;

// DXF paths
programmer_dxf = "solar-BQ25798-programmer-border.dxf";
connectors_dxf = "solar-BQ25798-connectors-border.dxf";
components_dxf = "solar-BQ25798-B_components-border.dxf";


// Thermal switch
thermal_switch_pos_x = 71;
thermal_switch_pos_y = 23;
thermal_switch_pos_z = 6.45;
thermal_switch_size_x = 8.9;
thermal_switch_size_y = 28;
thermal_switch_size_z = 5.1;
thermal_switch_wall_t = 1.2;

// boarder is a function to make the boarder with given height using a dxf file.
module boarder(height) {
    linear_extrude(height = height)
    import("solar-battery-boarder-case.dxf"); 
}

module import_kicad_dxf(name, h) {
    // scale(25.4)
    linear_extrude(height = h)
    import(name); 
}

// Helper module to make a rectangle from 2 x and 2 y points with options rounded corners.
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

module rec_from_pos_size(pos_x, pos_y, len_x, len_y, r=0) {
    x1 = pos_x-len_x/2;
    x2 = pos_x+len_x/2;
    y1 = pos_y-len_y/2;
    y2 = pos_y+len_y/2;
    rec_from_points(x1 = x1, y1 = y1, x2 = x2, y2 = y2, r=r);
}

// Main part of the battery tab, used as part to make the positive and negative tab.
module tab_main() {
    // Body
    hull() {
        // Wider at the bottom to make putting it on the PCB easier.
        translate([0, 0, -1])
        linear_extrude(height = 1) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y, x2 = tab_x/2, y2 = tab_y, r=0.4);
        translate([0, -0.5, 0])
        linear_extrude(height = tab_h/2) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y/2, x2 = tab_x/2, y2 = tab_y/2, r=0.4);
    }
    translate([0, -0.5, tab_h/2])
    linear_extrude(height = tab_h/2) 
    rec_from_points(x1 = -tab_x/2, y1 = -tab_y/2, x2 = tab_x/2, y2 = tab_y/2, r=0.4);

    hull() {
        // Wider at the bottom to make putting it on the PCB easier.
        translate([0, -tab_y, h8])
        linear_extrude(height = 1) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y/2-2, x2 = tab_x/2, y2 = tab_y, r=0.4);
        
        translate([0, 0, tab_h-1])
        linear_extrude(height = 1) 
        rec_from_points(x1 = -tab_x/2, y1 = -tab_y/2-1, x2 = tab_x/2, y2 = tab_y/2, r=0.4);
    }

    difference() {
        hull() {
            extra_width=5;
            translate([-(0)/2, tab_feet_y/2, -1])
            linear_extrude(height=2)
            rec_from_points(x1 = -bat_to_bat/2-extra_width/2, y1 = -tab_feet_y/2-1, x2 = bat_to_bat/2+extra_width/2, y2 = tab_feet_y/2);

            translate([-(0)/2, tab_feet_y/2-1.4, 5])
            cube([bat_to_bat+extra_width, 0.01, 1], center=true);
        }

        translate([0, -tab_p+39.85, -2])
        cylinder(d=6, h=6); 

        translate([bat_to_bat/2, -tab_p+39.85, -2])
        cylinder(d=6, h=6);
        translate([-bat_to_bat/2, -tab_p+39.85, -2])
        cylinder(d=6, h=6);    
    }   
}
// !tab_main();

// tab_positive, cutout for the tab on the positive side 
module tab_positive() {
    tab_main();
    hull() {
        translate([0, -1, tab_h/2])
        cube([tab_x/3*2, 0.1, tab_h], center=true);
        translate([0, -2.3/2, tab_h/2])
        cube([tab_x/3, 2.3, tab_h], center=true);
    }
}
// !tab_positive();

// tab_negative, cutout for the tab on the negative side
module tab_negative() {
    rotate([0, 0, 180]) {
        tab_main();

        translate([0, -13/2, -1])
        linear_extrude(height = tab_h)
        rec_from_points(-4, -6.5, 4, 6, r=1);

        translate([5.5, -2.8, -1])
        rotate([0, 1.9, 90])
        rotate_extrude(angle=90)
        translate([1.5, 0, 0])
        square([1, tab_h]);

        translate([-5.5, -2.8, -1])
        rotate([-1.9, 0, 0])
        rotate_extrude(angle=90)
        translate([1.5, 0, 0])
        square([1, tab_h]); 
    }
}
// !tab_negative();

// cell_protection_cutout, cutout between the cells where the cell protection SMD components are
module cell_protection_cutout() {
    translate([0, 0, -1])
    linear_extrude(height = 2)
    rec_from_points(x1 = -bat_to_bat+5, y1 = -33, x2 = -5, y2 = 33, r=1);
    
    hull() {
        translate([0, 0, 1-0.1])
        linear_extrude(height = 0.1)
        rec_from_points(x1 = -bat_to_bat+5, y1 = -33, x2 = -5, y2 = 33);

        translate([-bat_to_bat/2, 0, 6])
        linear_extrude(height = 0.01)
        rec_from_points(x1 = 0.01, y1 = -33, x2 = -0.01, y2 = 33);
    }
}
// !cell_protection_cutout();

// screw_head_cutout, cutout for the screw head, has a few angle to make printing upside down doable without supports.
module screw_head_cutout() {
    a = 6;
    translate([0, 0, -1])
    cylinder(d=screw_diameter_clearance, h=h8);
    
    translate([0, 0, a-2])
    cylinder(d1=screw_diameter_clearance, d2=screw_head_diameter, h=2);


    hull() {    
        translate([0, 5, a-0.5])
        cylinder(d=1, h=a);

        translate([0, 0, a-1.5])
        cylinder(d=screw_diameter_clearance, h=a);

        translate([0, 0, a])
        cylinder(d=screw_head_diameter, h=h8);
        
        translate([0, 10, h8/2+a+5])
        cube([screw_head_diameter*2, 1, h8], center=true);
    }
}
// !rotate([0, 0, 90]) screw_head_cutout();

// screw_head_cutout_flat, cutout for the screw head. Not intended to be printed upside down.
module screw_head_cutout_flat() {
    a = 5;
    translate([0, 0, -1])
    cylinder(d=screw_diameter_clearance, h=h8+1);
    
    hull() {    
        translate([0, 0, a])
        cylinder(d=screw_head_diameter, h=h8);
        
        translate([0, 10, h8/2+a])
        cube([screw_head_diameter*2, 1, h8], center=true);
    }
}
// !screw_head_cutout_flat();

// battery, cutout for the battery. Includes the positive, negative tabs and the silkscreen cutout.
module battery() {
    render(convexity=2)
    union() {
    bat_c=0;
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
    rec_from_points(x1=-4, y2=20, x2=4, y1=-10, r=0.5);

    translate([0, tab_n, 0])
    tab_negative();
    translate([0, tab_p, 0])
    tab_positive();
    }

    // Top hole
    translate([0, 0, 10])
    linear_extrude(height = 20) 
    rec_from_points(x1 = -5, y1 = -20, x2 = 5, y2 = 20, r=1.5);
}
// !battery();

// test_cell. A smaller print to test the fitting of the battery cells.
module test_cells() {
    scale([1, -1, 1]) union() {
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
                cell_protection_cutout();
                
                scale([1, -1, 1])
                translate([i*bat_to_bat, 0, 0])
                cell_protection_cutout();
            }

            mid_joints = [false, false, true, false, true];
            for (i = [0:count*2-2]) {
                translate([screw_hole_dx*i, screw_hole_y, 0])
                cylinder(d=screw_diameter_pilot, h=40, center=true);

                if (mid_joints[i]) {
                    translate([screw_hole_dx*i, screw_hole_y, 0])
                    screw_head_cutout();
                }
            }

            mid_joints2 = [true, false, false, false, false];
            scale([1, -1, 1])
            for (i = [0:count*2-2]) {
                translate([screw_hole_dx*i, screw_hole_y, 0])
                cylinder(d=screw_diameter_pilot, h=40, center=true);

                if (mid_joints2[i]) {
                    translate([screw_hole_dx*i, screw_hole_y, 0])
                    screw_head_cutout();
                }
            }
        }

        translate([bat_to_bat/2*count-bat_to_bat/2, 0, 0.2])
        difference() {
            cube([bat_to_bat*count, depth, 0.4], center=true);
            cube([bat_to_bat*count-1.6, depth-1.6, 0.6], center=true);
        }
    }
}
// !test_cells();

// Top side, inside bit.
module top_side_inner() 
scale([1, -1, 1]) difference() {
    // Main body
    boarder(h8);

    // Cutout for main electronics.
    difference() {
        // Main cutout for electronics
        boarder2x=2.8;
        z = 1.5;
        translate([0, 0, -z])
        union() {
            b=3;
            linear_extrude(height = h8-b)
            offset(r=-boarder2x/2)
            projection()
            intersection() {
                boarder(1);
                translate([49 + 53.075 + bat_to_bat/2+1, 0, 0])
                cube([100+boarder2x, 200, 30], center=true);
            }

            x=75;
            a = 1;
            translate([x, 0, h8-b])
            linear_extrude(height = b-a, scale=[0.85, 0.95])
            translate([-x, 0, 0])
            offset(r=-boarder2x/2)
            projection()
            intersection() {
                boarder(1);
                translate([49 + 53.075 + bat_to_bat/2+1, 0, 0])
                cube([100+boarder2x, 200, 30], center=true);
            }

            translate([x, 0, h8-a])
            linear_extrude(height = a) 
            scale([0.85, 0.95])
            translate([-x, 0, 0])
            offset(r=-boarder2x/2)
            projection()
            intersection() {
                boarder(1);
                translate([49 + 53.075 + bat_to_bat/2+1, 0, 0])
                cube([100+boarder2x, 200, 30], center=true);
            }
        }

        // Roof support ridges
        c = 10;
        for (i =[-c/2:c/2]) {
            translate([0, i*7, 50+h8-z-0.6])
            cube([300, 0.8, 100], center=true);
        }

        
        hull() {
            translate([thermal_switch_pos_x, thermal_switch_pos_y, thermal_switch_pos_z])
            cube([thermal_switch_size_x+thermal_switch_wall_t*2
            , 20
            , thermal_switch_size_z+thermal_switch_wall_t*2], center=true);

            translate([thermal_switch_pos_x, thermal_switch_pos_y, thermal_switch_pos_z+4])
            cube([thermal_switch_size_x+thermal_switch_wall_t*2
            , 30
            , 0.01], center=true);
        }

        translate([thermal_switch_pos_x, thermal_switch_pos_y, 0])
        cube([thermal_switch_size_x+thermal_switch_wall_t*2, 20, 1], center=true);
        
        translate([thermal_switch_pos_x, thermal_switch_pos_y+10, 0])
        cube([thermal_switch_size_x+thermal_switch_wall_t*2, 0.6, 20], center=true);
        translate([thermal_switch_pos_x, thermal_switch_pos_y-10, 0])
        cube([thermal_switch_size_x+thermal_switch_wall_t*2, 0.6, 10], center=true);
        translate([thermal_switch_pos_x, thermal_switch_pos_y-3.3, 0])
        cube([thermal_switch_size_x+thermal_switch_wall_t*2, 0.6, 10], center=true);
        translate([thermal_switch_pos_x, thermal_switch_pos_y+3.3, 0])
        cube([thermal_switch_size_x+thermal_switch_wall_t*2, 0.6, 10], center=true);
        

        // Support wall, to be removed after print.
        union() {
            translate([75, -75/2, 0])
            cube([1, 45, h8-z-0.6]);
            translate([75+0.5, 0, 0])
            cube([1, 90, 0.6], center=true);
        }
    }

    // Battery cutout
    scale([1, -1, 1])
    translate([53.075, 0, 0])
    difference() {
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
        // This little bit will just make the print a bit more reliable 
        // though it needs to be removed after the print but is small so easy to do so.
        translate([bat_to_bat/2, 0, 0])
        cube([1.6, 100, 0.4], center=true);
    }

    
    // Cell protection cutout
    translate([53.075+bat_to_bat, 0, 0])
    difference() {
        for (i = [0:7]) {
            translate([-i*bat_to_bat, 0, 0])
            cell_protection_cutout();
        }

        translate([41, 0, 0])
        cube([100, 100, 100], center=true);
    }

    // Bolt cutout
    for (i = [0:13]) {
        // Bolt heads
        if (i == 0 || i == 13) {
            // Bolt head to screw into other part
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            screw_head_cutout_flat();

            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, -1])
            cylinder(h=h8, d=screw_diameter_pilot);
        }
        scale([1, -1, 1])
        if (i == 7) {
            // Bolt head to screw into other part
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            screw_head_cutout_flat();
            
            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, -1])
            cylinder(h=h8, d=screw_diameter_pilot);
        }

        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 1])
            cylinder(h=h8, d=screw_diameter_pilot);
            translate([screw_hole_dx*i-72.375, screw_hole_y, 1])
            cylinder(h=h8, d=screw_diameter_pilot);
        }
    }

    // Buzzer horn hole
    translate([0, 0, 0.3])
    linear_extrude(height = 3.2) 
    rec_from_points(x1 =77.8, y1 = -43, x2 = 65.5, y2 = -40); 

    // Inductor cutout //TODO, improve this
    linear_extrude(height = 8) 
    rec_from_pos_size(pos_x = 84.65, pos_y = -6.25, len_x = 12.7, len_y = 12.7);

    // Thermal switch cutout

    translate([thermal_switch_pos_x, thermal_switch_pos_y, thermal_switch_pos_z])
    cube([thermal_switch_size_x
    , thermal_switch_size_y+1
    , thermal_switch_size_z], center=true);

    
}
// rotate([0, 180, 0]) translate([0, 0, -10])
// top_side_inner();

module top_side_inner_solid_infill() {
    // Bolt cutout
    for (i = [0:13]) {
        // Bolt heads
        if (i == 0 || i == 13) {
            // Bolt head to screw into other part
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);

            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }
        scale([1, -1, 1])
        if (i == 7) {
            // Bolt head to screw into other part
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
            
            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }

        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 1])
            cylinder(h=60, d=solid_infill_diameter, center=true);
            translate([screw_hole_dx*i-72.375, screw_hole_y, 1])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }
    }
}
// !color(c="red", alpha=0.5) top_side_inner_solid_infill();

// Top side, outside bit.
module top_side_outer()
scale([1, -1, 1]) rotate([0, 180, 0]) difference() {
    // Main body
    union() {
        boarder(height = h8-2);
        
        intersection() {
            translate([0, 0, h8-2])
            linear_extrude(height = 2, scale=[1, 0.97])
            projection()
            boarder(height=1);

            cube([151, 200, 100], center=true);
        }

        difference() {
            translate([0, 0, h8-2])
            linear_extrude(height = 2, scale=[0.99, 0.97])
            projection()
            boarder(height=1);
            
            translate([0, 0, h8-2])
            cube([150.9, 200, 100], center=true);
        }
    }
    
    // Battery cutout
    translate([53.075, 0, -h8])
    for (i = [0:6]) {
        translate([-i*bat_to_bat, 0, 0])    
        rotate([0, 0, battery_top_rotations[i]*180])
        battery();
    }

    // Bolt cutout
    for (i = [0:13]) {
        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            screw_head_cutout();
            
            scale([1, -1, 1])
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            screw_head_cutout();
        }
    }
}
// top_side_outer();

module top_side_outer_solid_infill() {
    // Bolt cutout
    rotate([0, 180, 0])
    for (i = [0:13]) {
        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
            
            scale([1, -1, 1])
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }
    }
}
// color(c="red", alpha=0.5) top_side_outer_solid_infill();

// Bottom side, inside bit
module bottom_side_inner() 
mirror([0, 1, 0]) translate([0, 0, -h8]) union() {
    difference() {
        bat_offset = -72.375;
        // Main body
        boarder(height = h8);

        // Battery cutout
        mirror([0, 1, 0])
        difference() {
            translate([bat_offset, 0, 0])
            for (i = [0:7]) {
                translate([i*bat_to_bat, 0, 0])
                rotate([0, 0, battery_bottom_rotations[i]*180])
                battery();
            }

            translate([81, 0, 0])
            cube([20, 100, 11], center=true);
        }
        

        // Bolt cutout
        for (i = [0:13]) {
            if (i == 0 || i == 13) {
                // screw hole to join to other printed part on the other side of the PCB
                translate([screw_hole_dx*i-72.375, -screw_hole_y, -1])
                cylinder(h=h8, d=screw_diameter_pilot);

                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_head_cutout_flat();
            }
            scale([1, -1, 1])
            if (i == 7) {
                // screw hole to join to other printed part on the other side of the PCB
                translate([screw_hole_dx*i-72.375, -screw_hole_y, -1])
                cylinder(h=h8, d=screw_diameter_pilot);

                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_head_cutout_flat();
            }

            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, -screw_hole_y, 1])
                cylinder(h=h8, d=screw_diameter_pilot);
                translate([screw_hole_dx*i-72.375, screw_hole_y, 1])
                cylinder(h=h8, d=screw_diameter_pilot);
            }
        }

        // Connector cutout
        translate([0, 0, -1])
        import_kicad_dxf(connectors_dxf, h=30);

        // Programmer cutout
        translate([0, 0, -1])
        import_kicad_dxf(programmer_dxf, h=30);
        
        // Components cutout
        component_cutout_height = 2;
        translate([0, 0, -1])
        import_kicad_dxf(components_dxf, component_cutout_height+1);
        
        // screw hole for the plug
        translate([plug_screw_x, 0, 1])
        cylinder(d=screw_diameter_pilot, h=100);
        translate([plug_screw_x, 0, h8-0.5])
        cylinder(d1 = screw_diameter_pilot, d2=screw_diameter_pilot+4, h=2);
    }

    // This is just a thin loop that goes around the edge
    // This helps with the printability, making the outer edge a full loop.
    difference() {
        boarder(height=0.6);

        translate([0, 0, -1])
        linear_extrude(height = 3) 
        offset(r=-0.5)
        projection()
        boarder(height=1);
    }

    // This is a thin wall on the back side where the cutout for the battery and components go into the wall
    difference() {
        // Main part
        boarder(height=h8);

        // Inner cutout
        translate([0, 0, -1])
        linear_extrude(height = h8+2) 
        offset(r=-0.7)
        projection()
        boarder(height=1);

        // Cutout so it is just the back wall part
        translate([100-78, 0, 0])
        cube([200, 100, 100], center=true);
    }

    
}
// bottom_side_inner();

module bottom_side_inner_solid_infill() {
    for (i = [0:13]) {
        d = 8;
        h = 50;
        if (i == 0 || i == 13) {
            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);

            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }
        scale([1, -1, 1])
        if (i == 7) {
            // screw hole to join to other printed part on the other side of the PCB
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);

            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }

        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(h=60, d=solid_infill_diameter, center=true);
        }
    }

    translate([plug_screw_x, 0, 0])
    cylinder(h=60, d=solid_infill_diameter, center=true);
}
// bottom_side_inner_solid_infill();

// Bottom side, outside bit.
module bottom_side_outer()
scale([1, -1, 1]) rotate([0, 180, 0]) union() {
    difference() {
        bat_offset = -72.375;
        // Main body
        boarder(height = h8);

        // Battery cutout
        scale([1, -1, 1])
        translate([bat_offset, 0, -h8])
        for (i = [0:7]) {
            translate([i*bat_to_bat, 0, 0])
            rotate([0, 0, battery_bottom_rotations[i]*180])
            battery();
        }

        // Bolt cutout
        for (i = [0:13]) {
            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_head_cutout();
            }
        }

        scale([1, -1, 1])
        for (i = [0:13]) {
            if (i == 2 || i == 11) {
                translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
                screw_head_cutout();
            }
        }

        // Connectors cutout
        x_offset = 90;
        translate([x_offset, 0, 8]) 
        rotate([0, -45, 0])
        translate([-x_offset, 0, -20])
        import_kicad_dxf(connectors_dxf, h = 40);

        // Programmer cutout
        translate([0, 0, -1])
        import_kicad_dxf(programmer_dxf, 30);
        
        // Cutout for separate connector cover part
        translate([132.9, 0, 30])
        cube([100, 100, 100], center=true);
    }

    // This is a thin wall on the back side where the cutout for the battery and components go into the wall
    difference() {
        // Main part
        boarder(height=h8);

        // Inner cutout
        translate([0, 0, -1])
        linear_extrude(height = h8+2) 
        offset(r=-0.7)
        projection()
        boarder(height=1);

        // Cutout so it is just the back wall part
        translate([100-78, 0, 0])
        cube([200, 100, 100], center=true);
    }
}
// rotate([0, 180, 0])
// bottom_side_outer();

module bottom_side_outer_solid_infill() {
    // Bolt cutout
    scale([1, -1, 1])
    rotate([0, 180, 0])
    for (i = [0:13]) {
        if (i == 2 || i == 11) {
            translate([screw_hole_dx*i-72.375, screw_hole_y, 0])
            cylinder(d=10, h=100, center=true);

            translate([screw_hole_dx*i-72.375, -screw_hole_y, 0])
            cylinder(d=10, h=100, center=true);
        }
    }

}
// bottom_side_outer_solid_infill();

module plug_cover() scale([1, -1, 1]) rotate([0, 180, 0]) union() {
    difference() {
        union() {
            linear_extrude(height = h8)
            rec_from_points(83.2, 28.6, 92.5, -26);

            key_clearance = 0.2;    // Clearance from key hole to key
            radius = 0.6;
            key_length = 0.9; // percentage of key length 
            p = 0.4;    // percentage of length of pointy bit

            translate([0, 0, -h8*(key_length-p)])
            hull() {        
                // Main part
                linear_extrude(height = h8*(1+key_length-p)) 
                offset(r=radius)
                offset(r=-key_clearance-radius)
                import(programmer_dxf);

                // Pointy bit
                translate([0, 0, -h8*p])
                linear_extrude(height = h8*(1+key_length)) 
                offset(r=radius)
                offset(r=-key_clearance-1-radius)
                import(programmer_dxf);
            }
        }

        plug_height = 7;

        // Cut out area around plugs
        translate([-2, 0, 0])
        import_kicad_dxf(name = connectors_dxf, h = plug_height);
        translate([2, 0, 0])
        import_kicad_dxf(name = connectors_dxf, h = plug_height);

        // Cut our space for wires 
        translate([-7.5, 0, 0])
        import_kicad_dxf(name = connectors_dxf, h = h8+1);

        // Screw hole
        translate([plug_screw_x, 0, 0]) {
            translate([0, 0, 4])
            cylinder(d=screw_head_diameter, h=60);
            p = (screw_head_diameter - screw_diameter_clearance)/2;
            translate([0, 0, 4.01-p])
            cylinder(d1=screw_diameter_clearance, d2=screw_head_diameter, h=p);
            translate([0, 0, -1])
            cylinder(d=screw_diameter_clearance, h=60);
        }
    }
}
// !plug_cover();

module plug_cover_solid_infill() {
    translate([0, 0,-h8+5])
    scale([1, -1, 1]) rotate([0, 180, 0])
    linear_extrude(height = h8+1) 
    offset(r=3)
    import(connectors_dxf);

    // Screw hole
    translate([-plug_screw_x, 0, 0])
    translate([0, 0, 4])
    cylinder(d=screw_head_diameter+2, h=60, center=true);
}
// color(c="red", alpha=0.3) plug_cover_solid_infill();

module stack() {
    translate([0, 0, 30])
    rotate([0, 180, 0])
    top_side_outer();

    translate([0, 0, 10])
    top_side_inner();

    translate([0, 0, -10])
    rotate([180, 0, 0])
    bottom_side_inner();

    translate([0, 0, -30])
    rotate([0, 0, 180])
    bottom_side_outer();    
}
//stack();

if (output == "top_side_inner") {
    top_side_inner();
} 
if (output == "top_side_inner_solid_infill") {
    top_side_inner_solid_infill();
}
if (output == "top_side_outer") {
    top_side_outer();
}
if (output == "top_side_outer_solid_infill") {
    top_side_outer_solid_infill();
}
if (output == "bottom_side_inner") {
    bottom_side_inner();
}
if (output == "bottom_side_inner_solid_infill") {
    bottom_side_inner_solid_infill();
}
if (output == "bottom_side_outer") {
    bottom_side_outer();
}
if (output == "bottom_side_outer_solid_infill") {
    bottom_side_outer_solid_infill();
}
if (output == "plug_cover") {
    plug_cover();
}
if (output == "plug_cover_solid_infill") {
    plug_cover_solid_infill();
}

translate([88.77, -24.21, 0])
cube([5, 5, 10],center=true);

translate([89.035, 21.1, 0])
cube([5, 5, 10],center=true);

translate([95, 0, -h8])
cube([5, 60, 1],center=true);

mirror([0, 1, 0])
translate([0, 0, 0])
import_kicad_dxf(connectors_dxf, h=30);