#!/usr/bin/env python3

import subprocess
import threading
import time
import RPi.GPIO as GPIO

# GPIO pin numbers (BCM)
PIN_LED_RED   = None  # TODO
PIN_LED_GREEN = None  # TODO
PIN_LED_BLUE  = None  # TODO
PIN_BUTTON    = None  # TODO

FIRMWARE_PATH = "firmware.hex"
DEVICE        = "attiny1616"
UART_PORT     = "/dev/serial0"

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_LED_RED,   GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(PIN_LED_GREEN, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(PIN_LED_BLUE,  GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(PIN_BUTTON,    GPIO.IN,  pull_up_down=GPIO.PUD_UP)

_blink_thread = None
_blink_stop   = threading.Event()


def _blink_worker(pins, interval=0.3):
    while not _blink_stop.is_set():
        for pin in pins:
            GPIO.output(pin, GPIO.HIGH)
        _blink_stop.wait(interval)
        for pin in pins:
            GPIO.output(pin, GPIO.LOW)
        _blink_stop.wait(interval)

def start_blink(pins, interval=0.3):
    global _blink_thread
    stop_blink()
    _blink_stop.clear()
    _blink_thread = threading.Thread(target=_blink_worker, args=(pins, interval), daemon=True)
    _blink_thread.start()


def stop_blink():
    global _blink_thread
    _blink_stop.set()
    if _blink_thread:
        _blink_thread.join()
        _blink_thread = None
    for pin in (PIN_LED_RED, PIN_LED_GREEN, PIN_LED_BLUE):
        GPIO.output(pin, GPIO.LOW)


def run_pymcuprog(args):
    cmd = ["pymcuprog", "-d", DEVICE, "-t", "uart", "-u", UART_PORT] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def program():
    start_blink([PIN_LED_BLUE])

    success = run_pymcuprog(["erase"])
    if success:
        success = run_pymcuprog(["write", "-f", FIRMWARE_PATH])

    if not success:
        start_blink([PIN_LED_RED, PIN_LED_GREEN, PIN_LED_BLUE], interval=0.15)
        time.sleep(10)
        return False

    stop_blink()
    start_blink([PIN_LED_GREEN])
    time.sleep(3)
    return True


def wait_for_button():
    start_blink([PIN_LED_RED])
    while True:
        if GPIO.input(PIN_BUTTON) == GPIO.LOW:
            break
        time.sleep(0.01)

try:
    while True:
        wait_for_button()
        program()
finally:
    stop_blink()
    GPIO.cleanup()
