// This file is used to generate a DXF that will be the tack for the resistance
// The resistance we can calculate from:
// - Track width (chosen from KiCAD import option), 
// - Total length (will echo estimated total length) 
// - copper thickness (normally 17.5um on internal copper layers)

h = 40; //
l = 142;
x1 = 8;
t1 = 0.7;

c = 0.0172;

$fs=0.2;

estimate_total_length = l/t1*(h-t1*2);

echo(Length=estimate_total_length);

rho = 1.68e-8; // Ω·m
length_m = estimate_total_length/1000;
height_m = 0.0175/1000;
width_m = t1/1000/2;
resistance = 1.68e-8*length_m/(width_m * height_m);
echo(Resistance=resistance);

module slice2() {
    a = h/2-t1*1.5;
    translate([0, a/2])
    cube([t1, a, 1], center=true);

    translate([-t1*1, h/2-t1*1.5])
    intersection() {
        difference() {
            cylinder(d=t1*3, h=1, center=true);
            cylinder(d=t1, h=2, center=true);
        }
        translate([0, 0, -1])
        cube([t1*4, t1*4, 2]);
    }

}


function pos_bump(x) = (-10 < x && x < 3) ? -12 : 0;
function neg_bump(x) = (48 < x && x < 62) ? -12 : 0;


// projection()
union() {
    for (i = [0:l/t1/2]) {
        x = -l/2-x1+i*t1*2;
        translate([x, pos_bump(x), 0])
        if (i%2==0) {
            translate([0, 0, 0])
            slice2();    
            translate([-t1*2, 0, 0])
            mirror([1, 0, 0])
            slice2();
        }
    }

    mirror([0, 1, 0])
    for (i = [0:l/t1/2]) {
        x = -l/2-x1+i*t1*2+t1*2;
        translate([x, neg_bump(x), 0])
        if (i%2==0) {
            translate([0, 0, 0])
            slice2();    
            translate([-t1*2, 0, 0])
            mirror([1, 0, 0])
            slice2();
        }
    }

    translate([-l/2-x1-t1*2, 0, 0])
    hull() {
        cylinder(d=t1, h=1, center=true);
        
        translate([0, -h/2+t1/2, 0])
        cylinder(d=t1, h=1, center=true);
    }


    i = l/t1/2;
    a = i - i%1;
    x = -l/2-x1+a*t1*2;
    translate([x, 0, 0])
    hull() {
        cube([t1, 1, 1], center=true);
        
        translate([0, h/2-t1-5, 0])
        cube([t1, 1, 1], center=true);
    }
}
