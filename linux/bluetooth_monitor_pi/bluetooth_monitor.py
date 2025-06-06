import os
import time
import json
import subprocess
from connection_driver import ConnectionDriver

"""
Allows the Raspberry Pi to connect to one target Bluetooth device
with one or two Bluetooth interfaces (an additional BT dongle is required
for the second one).

The script enables one key sequence and one LED per interface to watch and control
the status of the connection to the target device.
"""

# Same target device for either interface to connect to.
DEVICE_MAC_ADDRESS = os.environ["DEVICE_MAC_ADDRESS"]

# Interface 1 params
CON1_KEY_SEQ = os.environ["CON1_KEY_SEQ"]
GPIO_LED1_PIN = os.environ["GPIO_LED1_PIN"]

# Interface 2 params (optional)
CON2_KEY_SEQ = os.getenv("CON2_KEY_SEQ")
GPIO_LED2_PIN = os.getenv("GPIO_LED2_PIN")

def get_adapter_mac_addresses() -> list[str]:
    output = subprocess.check_output("bluetoothctl list | awk '{print $2}'", shell=True).decode().strip()
    addresses = output.split("\n")
    return addresses

if __name__ == "__main__":

    adapters = get_adapter_mac_addresses()[:2] # take at most 2 adapters

    control_objects = [{"led": GPIO_LED1_PIN, "sequence": CON1_KEY_SEQ}]
    if GPIO_LED2_PIN and CON2_KEY_SEQ:
        control_objects.append({"led": GPIO_LED2_PIN, "sequence": CON2_KEY_SEQ})

    # Wanted to control 2 connections but only one adapter is available
    if len(control_objects) > len(adapters):
        # We ignore the LED and sequence for the second connection
        control_objects.pop()
    # There are two adapters available but just need to control 1
    elif len(control_objects) < len(adapters):
        # We ignore the second adapter
        adapters.pop()
    # There are as many controllers as connections we want to control
    else:
        # We assert there is one or two connections to be controlled
        assert len(control_objects) in (1, 2)
        assert len(adapters) in (1, 2)

    # We create connection drivers
    drivers: list[ConnectionDriver] = []
    for adapter, control_object in zip(adapters, control_objects):
        led_pin = control_object["led"]
        sequence = json.loads(control_object["sequence"])
        driver = ConnectionDriver(led_pin, sequence, adapter, DEVICE_MAC_ADDRESS)
        drivers.append(driver)

    # Will poll connection(s) every few seconds
    while True:

        for driver in drivers:
            driver.update_led()

        time.sleep(2)
