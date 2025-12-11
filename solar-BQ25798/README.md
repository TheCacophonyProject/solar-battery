## Process for setting positions and duplicating layouts
- `python -m venv ./pi-venv`
- `source pi-venv/bin/activate`
- `pip install kicad-python`
- `python positioning.py`
- Running the python positioning script messes up the link of the component to the schematic so run "Update PCB from schematic" but check "re-link footprint to schematic bases on ref
- It also messes up the footprints a bit but this can be fixed by updating all footprints from library.
- Make the layout for one cell.
- Group the layout for one cell. This can sometimes be easier to do if you move everything to the side with shift+m.
- Replicate layout by 
    - Open up group of the cell
    - Select the anker component (the one that gets placed though the positioning script)
    - Go to Tools -> External plugins -> Replicate layout
    - Don't replicate drawings (it will replicate the edge boarder for some reason)
    - Select: Replicate group only (this makes sure you get all the tracks you want and nothing else)
    - Select: Remove existing tracks/...
    - Select: Remove Duplicates


### Building manufacturing files
- Install https://gitlab.com/waltzingkea/kicad-tools
- `make-kicad-prod-files --config ./wk-kicad-tools.yaml --type fab-files --version <set-version>`
