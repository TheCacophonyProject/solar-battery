# Solar BQ25798

This is a 3S5P 18650 MPPT solar charger that uses a BQ25798 for the MPPT charger, BQ76920 for the balancer, and an ATtiny1616 for the charge controller.

The [firmware](https://github.com/TheCacophonyProject/solar-battery-firmware) and the PCB is a WIP.

## TODO

- Reduce trace resistances for power paths.
- Check resistance of the protection for the 18650, if too high look for alternatives.
- Tidy up of traces (bit of a mess at the moment)
- Add something so the ATtiny can check what version of the board it is (will maybe not be able to have the latest firmware work on all versions of the PCB)
- Bed of nails test fixture.
- Calculate shunt resistor value for the BQ76920 so it high enough for triggering over current discharges and short circuits.
- New 3D print for new layout of the components.
