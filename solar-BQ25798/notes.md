## Notes from BQ25798 datasheet
### 1 Features
- Buck boost
- 1-4 cell batteries
- Input and charging current sensing
- Samples open circuit voltage MPPT
- Up to 24V, 30V absolute
- uA for battery only operation
- 500nA in charger shutdown mode
- Thermal regulation and thermal shutdown
- Input/battery OVP and OCP
- Charging safety timer
- Says only li-ion/li-polyer but the target charge voltage can be changed to suite a LiFePO4 4S setup 

### 7 Pin configuration and functions
- STAT: LED attached to help debugging while in development but is no needed in end product
- VBUS: recommended capacitor setup caused noise at low power charging. Check if adding more capacitance is not recommended.
- ~{QON}: Check if we need to use this for ship mode.
- ILIM_HIZ: Just pull up as the maximum current will be programmed through I2C
- SDRV: ship mosfet drive pin

### 8 Specifications
- Absolute max voltage of 30V
- Recommended max voltage of 24V
- 8.5 describes quiescent currents. Should use this to see what mode we should try to be in during night to reduce unneeded power losses.

### 9 Detailed Description
9.3.2 PROG Pin: Using 750MHz as that can work better at lower charge currents, and 3s cell count, even when using 4s LiFePO4 as the charge voltage range is 10-13.99V for 3s
- On boot should read the CELL bits to check that it is in the 3s and 750MHz

9.3.3 Device power up from battery without input source: This should only happen once when putting together the battery

9.3.4 Device Power Up from input Source: Need to check that in the process of putting the battery pack together it will boot up in combination with the cell balancer chip

9.3.4.1: Power Up REGN LDO: Don't use it for external circuits and not for ~{INT}

9.3.4.2 Poor Source qualification:
- Needs to stay in the voltage range while pulling up to 10mA
- PG_STAT is set high with a good source, ~{INT} is pulsed to notify host.
- If the voltage drops below the minimum voltage when pulling 10mA it will go into high impedance mode (EN_HIZ) for 7 minutes, we can trigger it to try again from the I2C master. We will want to do this as if a solar panel goes into shade for a bit we want it to try again.

9.3.4.3 ILIM_HIZ Pin:
- Will limit through software so this just gets pulled up to VREGN

9.3.4.4 Default VINDPM Setting:
- TODO

9.3.4.5 Input Source Type Detection:
- Runs Input Source Type Detection if AUTO_INDET_EN bit is set (default enabled)
- Do we want to just disable this?

9.3.4.5.1 D+/D– Detection Sets Input Current Limit:
- 



9.3.9.5:
- Set reg in  REG18_NTC_Control_1 for what voltage percentage it will be







9.3.10 ADC:
- Disable for low power when not needed.
- IBUS (positive in forward converter mode)
• IBAT (positive for charging)
• VBUS
• VPMID
• VBAT
• VSYS
• TS
• TDIE

9.3.11.1 STAT Pin:
- Can attached LED but remove LED for final product.

9.3.11.2 Interrupt to Host ( INT):
- Check status change when this triggers
- Disable some of the triggers for INT that we don't want.
- Just sends out a pulse, not held low

9.3.12 Ship FET Control:
TODO

9.3.12.1 Shutdown Mode:
- Will disable the I2C so probably not something we want to use.

9.3.12.2 Ship Mode
- Might be useful when trying to reduce power losses.

9.3.13 Protections:
- Monitor if any of the voltage and current monitoring triggers go off
- Monitor thermal regulation and set max temps

9.3.14 Serial interface:
- Just standard I2C device reading and writing to registers without crc

9.4.1:
- Handle the I2C WDT
- If I2C WDT triggers, make sure that we set all the registers again to what we want.

9.4.2 Register Bit Reset:
- register and the timer could be reset
to the default value by writing the REG_RST bit to 1
- Will want to use this on first power up from ATtiny so we know what state the chip is in



