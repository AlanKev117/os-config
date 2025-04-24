import os
import time
import subprocess
from connection_driver import ConnectionDriver

"""
Allows the Raspberry Pi to connect to one target Bluetooth device
with one or two Bluetooth interfaces (an additional BT dongle is required
for the second one).

The script enables one button and one LED per interface to watch and control
the status of the connection to the target device.
"""

# Same target device for either interface to connect to.
DEVICE_MAC_ADDRESS = os.environ["DEVICE_MAC_ADDRESS"]

# Interface 1 params
GPIO_BUTTON1_PIN = os.environ["GPIO_BUTTON1_PIN"]
GPIO_LED1_PIN = os.environ["GPIO_LED1_PIN"]

# Interface 2 params (optional)
GPIO_BUTTON2_PIN = os.getenv("GPIO_BUTTON2_PIN")
GPIO_LED2_PIN = os.getenv("GPIO_LED2_PIN")

def get_adapter_mac_addresses() -> list[str]:
    output = subprocess.check_output("bluetoothctl list | awk '{print $2}'", shell=True).decode().strip()
    addresses = output.split("\n")
    return addresses

if __name__ == "__main__":

    adapters = get_adapter_mac_addresses()[:2] # take at most 2 adapters

    control_objects = [{"led": GPIO_LED1_PIN, "button": GPIO_BUTTON1_PIN}]
    if GPIO_LED2_PIN and GPIO_BUTTON2_PIN:
        control_objects.append({"led": GPIO_LED2_PIN, "button": GPIO_BUTTON2_PIN})

    # Wanted to control 2 connections but only one adapter is available
    if len(control_objects) > len(adapters):
        # We ignore the LED and Button for the second connection
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
        button_pin = control_object["button"]
        driver = ConnectionDriver(led_pin, button_pin, adapter, DEVICE_MAC_ADDRESS)
        drivers.append(driver)

    # Will poll connection(s) every few seconds
    while True:

        for driver in drivers:
            driver.update_led()

        time.sleep(2)
