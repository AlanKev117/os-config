import os
import time
import subprocess
from gpiozero import LED, Button

"""
Controls the connection to a specific Bluetooth device showing the status
of the connection in an LED and making possible to toggle it with a button.
"""

# GPIO pins
GPIO_BUTTON_PIN = os.environ["GPIO_BUTTON_PIN"]
GPIO_LED_PIN = os.environ["GPIO_LED_PIN"]
DEVICE_MAC_ADDRESS = os.environ["DEVICE_MAC_ADDRESS"]

# GPIO objects
led = LED(GPIO_LED_PIN)
button = Button(GPIO_BUTTON_PIN, pull_up=False, bounce_time=0.5)

def is_connected(device: str) -> bool:
    output = subprocess.check_output(f"bluetoothctl info {device}", shell=True).decode()
    return "Connected: yes" in output

def set_connection(state: bool, device: str) -> None:
    action = "connect" if state else "disconnect"
    subprocess.run(f"bluetoothctl {action} {device}", shell=True)

def update_led(device: str) -> None:
    if is_connected(device):
        led.on()
    else:
        led.off()

def toggle_connection(device: str) -> None:
    current_state = is_connected(device)
    set_connection(not current_state, device)
    time.sleep(0.5)
    update_led(device)

if __name__ == "__main__":
    # Add handler to button when pressed.
    button.when_released = lambda: toggle_connection(DEVICE_MAC_ADDRESS)

    # Pause process to be run in the background
    print(f"Watching status of connection to {DEVICE_MAC_ADDRESS} "
        f"with LED on GPIO pin {GPIO_LED_PIN}. "
        f"Toggle status by pressing button on GPIO pin {GPIO_BUTTON_PIN}. "
        "CTRL+C to exit.")

    # Will poll connection status every few seconds
    while True:
        update_led(DEVICE_MAC_ADDRESS)
        time.sleep(5)
