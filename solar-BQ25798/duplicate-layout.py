# https://docs.kicad.org/kicad-python-main/board.html


"""
from kipy import KiCad
from kipy.geometry import Vector2, Angle 

board = KiCad().get_board() 
footprints = board.get_footprints() 

for footprint in footprints: 
    footprint.position += Vector2.from_xy_mm(5, 2)     
    footprint.orientation += Angle.from_degrees(90) 
    
board.update_items(footprints)

exit(0)
"""


from kipy import KiCad
from kipy.geometry import Vector2, Angle


try:
    kicad = KiCad()
    print(f"Connected to KiCad {kicad.get_version()}")
except BaseException as e:
    print(f"Not connected to KiCad: {e}")
    exit(1)

board = kicad.get_board()

commit = board.begin_commit()


# Get anchor footprint
footprints = board.get_footprints()

# Get anchor footprint
for footprint in footprints:
    if footprint.reference_field.text.value == "Q303":
        anchor = footprint

sheet_low = 2
sheet_high = 16

for i in range(sheet_low, sheet_high+1):
    print(i)

print("===")
print(anchor)
print(anchor.sheet_path)
print(anchor.sheet_path.path)
print(anchor.sheet_path.path_human_readable)
print("===")
# footprints to mirror
