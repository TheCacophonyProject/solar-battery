#!/bin/bash

# Exit on error
set -e

layers=("B.components-border" "connectors-border" "programmer-border")

for layer in "${layers[@]}"; do
    kicad-cli pcb export dxf --mode-multi --output-units mm --layers "$layer" ../solar-BQ25798.kicad_pcb
done

echo "All done"