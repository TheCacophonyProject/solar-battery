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
footprints = board.get_footprints()

# key (field name), position value x, y tuple in mm
new_positions = {}

print("Calculating new positions...")
# 3S5P 18650 cells
series = 3
parallel = 5

cell_length = 70
cell_gap = 9.65

q_x_offset = (4.1)/2
q_y_offset = 10
q2_y_offset = 4.2

cells = series*parallel
for i in range(cells):
    cell_id = i+101
    q3_id = i*100+103
    q1_id = i*100+201
    x = -72.375+i*cell_gap

    # The cells alternate from being on the top or bottom layer
    if i%2 == 0:
        layer = "bottom"
        # Get the center line of the bottom cells, as this is what the components will be centered around (as they are all on the top)
        components_x = x 
    else:
        layer = "top"

    # Each set of cells in parallel are facing the same direction, once it reaches the start of the next set of 
    # cells in parallel they are then facing the other direction.
    if (i//parallel)%2 == 0:
        # Cell here have the positive terminal at Y- position.
        if layer == "top":
            new_positions[f"BAT_P{cell_id}"] = (x, -cell_length/2, layer, 180)
            new_positions[f"BAT_N{cell_id}"] = (x, cell_length/2, layer, 0)
            #new_positions[f"Q{q3_id}"] = (components_x+q_x_offset, cell_length/2-q_y_offset, "top", 180)
            new_positions[f"Q{q1_id}"] = (components_x+q_x_offset, -(cell_length/2-q2_y_offset), "top", 90)
        else:
            new_positions[f"BAT_P{cell_id}"] = (x, -cell_length/2, layer, 0)
            new_positions[f"BAT_N{cell_id}"] = (x, cell_length/2, layer, 180)
            #new_positions[f"Q{q3_id}"] = (components_x-q_x_offset, cell_length/2-q_y_offset, "top", 180)
            new_positions[f"Q{q1_id}"] = (components_x-q_x_offset, -(cell_length/2-q2_y_offset), "top", 90)
    # S2
    else:
        # Cell here have the positive terminal at Y+ position.
        if layer == "top":
            new_positions[f"BAT_P{cell_id}"] = (x, cell_length/2, layer, 0)
            new_positions[f"BAT_N{cell_id}"] = (x, -cell_length/2, layer, 180)
            #new_positions[f"Q{q3_id}"] = (components_x+q_x_offset, -(cell_length/2-q_y_offset), "top", 0)
            new_positions[f"Q{q1_id}"] = (components_x+q_x_offset, (cell_length/2-q2_y_offset), "top", 270)
        else:
            new_positions[f"BAT_P{cell_id}"] = (x, cell_length/2, layer, 180)
            new_positions[f"BAT_N{cell_id}"] = (x, -cell_length/2, layer, 0)
            #new_positions[f"Q{q3_id}"] = (components_x-q_x_offset, -(cell_length/2-q_y_offset), "top", 0)
            new_positions[f"Q{q1_id}"] = (components_x-q_x_offset, (cell_length/2-q2_y_offset), "top", 270)

#print(new_positions)

print("Creating updated footprints...")
updated_footprints = []
for footprint in footprints:
    ref = footprint.reference_field.text.value
    if ref in new_positions:
        # Set position
        footprint.position = Vector2.from_xy_mm(new_positions[ref][0], new_positions[ref][1])
        
        # Set layer
        if new_positions[ref][2] == "top":
            footprint.layer = 3
        else:
            footprint.layer = 34
        
        # Set rotation
        footprint.orientation = Angle.from_degrees(new_positions[ref][3])

        # Add to list of footprints that need updating.
        updated_footprints.append(footprint)

print("Updating board...")
new_footprints = board.update_items(updated_footprints)

board.push_commit(commit)






print("Done")
