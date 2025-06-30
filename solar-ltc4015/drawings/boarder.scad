

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

projection()
boarder(l1, l2, l3, r1);
/*
difference() {
    
    translate([-2.5, 0, 0])
    boarder(l1, l2, l3, r1);
    
    translate([-2.5, 0, 0])
    boarder(l1-10, l2-10, l3, r1);

}
*/
