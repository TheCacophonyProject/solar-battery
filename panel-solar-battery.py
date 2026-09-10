import os
import shutil
import subprocess

dir_path = ".generated-pcbs/solar-battery-panel"
input = "solar-BQ25798/solar-BQ25798.kicad_pcb"
output = f"{dir_path}/solar-battery-panel.kicad_pcb"

# shutil.rmtree(dir_path, ignore_errors=True)
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

# Run the command
_ = subprocess.run(command, check=False)

print("Done")
