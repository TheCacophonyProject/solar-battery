# Solar Programmer

This is a hat to go on a Raspberry Pi Zero to help programming the solar batteries.

## Setup

### Materials

- Raspberry Pi Zero 2 W (Raspberry Pi 3 would probably be fine also)
- SD card
- Hat
- Cable

### Raspberry Pi OS

- Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- 
Flash Raspberry Pi OS Lite (64-bit) to an SD card using Raspberry Pi Imager. In the imager settings, configure your hostname, SSH, and Wi-Fi before flashing.

### Enable UART



The ATtiny1616 is programmed over UART (`/dev/serial0`). By default the Pi uses the UART for a serial console, so that must be disabled and the hardware UART freed up.

1. Open `/boot/firmware/config.txt`:

   ```ini
   enable_uart=1
   ```

2. Open `/boot/firmware/cmdline.txt` and remove the `console=serial0,115200` fragment so the kernel does not claim the port.

3. Disable the serial console service:

   ```bash
   sudo systemctl disable serial-getty@ttyAMA0.service
   ```

4. Reboot:

   ```bash
   sudo reboot
   ```

After rebooting, `/dev/serial0` should be free for use by `pymcuprog`.

### Software

Install the required Python packages:

```bash
sudo apt update
sudo apt install -y python3-pip python3-rpi.gpio
pip3 install pymcuprog
```

### Configure GPIO pins

Open `program.py` and set the four pin constants at the top of the file to match your hat's wiring (BCM numbering):

```python
PIN_LED_RED   = None  # e.g. 17
PIN_LED_GREEN = None  # e.g. 27
PIN_LED_BLUE  = None  # e.g. 22
PIN_BUTTON    = None  # e.g. 23
```

### Firmware file

Place the compiled firmware at the same path as `program.py` and ensure the `FIRMWARE_PATH` constant in `program.py` matches the filename (default: `firmware.hex`).

## Running

```bash
python3 program.py
```

To run automatically on boot, create a systemd service at `/etc/systemd/system/solar-programmer.service`:

```ini
[Unit]
Description=Solar Battery Programmer
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/solar-programmer/program.py
WorkingDirectory=/home/pi/solar-programmer
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
```

Then enable it:

```bash
sudo systemctl enable solar-programmer
sudo systemctl start solar-programmer
```

## LED Status

| LED | Meaning |
| --- | ------- |
| Red flashing | Idle — waiting for button press |
| Blue flashing | Programming in progress |
| Green flashing | Programming succeeded |
| All three flashing | Error — check connections and firmware file |
