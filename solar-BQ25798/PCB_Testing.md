# PCB Testing

This lays out the different things we want to be able to test (and how to) for each PCB.

## Manual testing

Before we have a testing PCB rig setup with a automated testing procedure we need to test the PCBs manually.

## Pack level testing




- Pack over voltage protection: Put in 4.1V cells and make sure it is not charging the pack to more than 12.3V total.
- Cell under voltage protection: Put in 3.3V cells and make sure under voltage protection kicks in if a high load (enough to drop the cell voltage to below 3V) will trigger the under voltage protection.
- Pack Over Current Protection: Will all 15 cells in make sure it can draw 2.5A, should cut off at around 3A
- Pack short Circuit Protection: Short the output with the 15 cells to make sure the short circuit protection triggers.
- Sanity check on temperature sensor (check that the temperature is around the correct value) Maybe this can be done in software, checking that all internal temperature sensors read about the same on the initial startup?

- Over temperature protection: One at a time, apply heat to the temperature sensor to make sure the 