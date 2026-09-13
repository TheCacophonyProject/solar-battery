import json
import os
import shutil
import subprocess

import pcbnew

dir_path = ".generated-pcbs/solar-battery-panel"
input = "solar-BQ25798/solar-BQ25798.kicad_pcb"
output = f"{dir_path}/solar-battery-panel.kicad_pcb"
project = f"{dir_path}/solar-battery-panel.kicad_pro"
drc_report = f"{dir_path}/solar-battery-panel-drc.json"

# Footprints that the panelisation is expected to change (the board outline is
# redrawn through them), so their library mismatch is not a real error.
outline_footprints = {"cacophony-library:0603_NTC_CUTOUT"}
exclusion_comment = "Footprint is different as it is part of the outline"
null_uuid = "00000000-0000-0000-0000-000000000000"


def footprint_mismatch_exclusions(pcb_file, lib_ids):
    """DRC exclusions for the library mismatch of every footprint in lib_ids.

    KiCad identifies an excluded violation by the marker's position, which for
    this check is the centre of the footprint's bounding box rather than the
    footprint origin.
    """
    board = pcbnew.LoadBoard(pcb_file)
    exclusions = []
    for footprint in board.GetFootprints():
        if footprint.GetFPIDAsString() not in lib_ids:
            continue
        centre = footprint.GetCenter()  # already in nm
        uuid = footprint.m_Uuid.AsString()
        marker = f"lib_footprint_mismatch|{centre.x}|{centre.y}|{uuid}|{null_uuid}"
        exclusions.append([marker, exclusion_comment])
    return exclusions


def add_drc_exclusions(project_file, exclusions):
    with open(project_file) as f:
        settings = json.load(f)
    design_settings = settings["board"]["design_settings"]
    current = design_settings.get("drc_exclusions", [])
    # Older projects store bare marker strings rather than [marker, comment].
    seen = {e[0] if isinstance(e, list) else e for e in current}
    added = [e for e in exclusions if e[0] not in seen]
    design_settings["drc_exclusions"] = current + added
    with open(project_file, "w") as f:
        json.dump(settings, f, indent=2)
        _ = f.write("\n")
    return added

shutil.rmtree(dir_path, ignore_errors=True)
os.makedirs(dir_path, exist_ok=True)

command = [
    "kikit", "panelize",
    "--layout", "grid; rows: 3; cols: 1; hspace: 3mm; renameref: {orig}-{n}",
    "--tabs", "annotation",
    "--cuts", "vcuts",
    "--post", "millradius: 1mm",
    "--framing", "railslr; width: 8mm",
    "--fiducials", "type: 4fid; hoffset: 3.85mm; voffset:6mm",
    "--tooling", "type: 4hole; hoffset: 3mm; voffset: 3mm; size: 2mm",
    input,
    output
]

_ = subprocess.run(command, check=False)

# Set footprint library file
library_str = """(fp_lib_table
	(version 7)
	(lib (name "cacophony-library") (type "KiCad") (uri "${KIPRJMOD}/../../kicad-library/cacophony-library.pretty") (options "") (descr ""))
)
"""
with open(f"{dir_path}/fp-lib-table", "w") as f:
    _ = f.write(library_str)

# Exclude the library mismatches caused by panelising the outline footprints.
added = add_drc_exclusions(project, footprint_mismatch_exclusions(output, outline_footprints))
print(f"Added {len(added)} DRC exclusions")

print("Done")
