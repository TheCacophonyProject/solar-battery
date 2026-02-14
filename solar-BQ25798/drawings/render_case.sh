#!/usr/bin/env bash
set -euo pipefail

SCAD_FILE="case.scad"
OUT_DIR="./case_renders"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$OUT_DIR"

parts=(
  top_side_inner
  top_side_inner_solid_infill
  top_side_outer
  top_side_outer_solid_infill
  bottom_side_inner
  bottom_side_inner_solid_infill
  bottom_side_outer
  bottom_side_outer_solid_infill
  plug_cover
  plug_cover_solid_infill
)

throttle() {
  while (( $(jobs -pr | wc -l) >= JOBS )); do
    sleep 0.1
  done
}

for part in "${parts[@]}"; do
  throttle
  (
    echo "Rendering $part..."
    openscad "$SCAD_FILE" -D "output=\"$part\"" -o "$OUT_DIR/$part.stl"
    echo "Finished  $part"
  ) &
done

wait
echo "Done."
