import os
import time
import subprocess
from gpiozero import LED, Button

# GPIO pins
GPIO_BUTTON_PIN = os.environ["GPIO_BUTTON_PIN"]
GPIO_LED_PIN = os.environ["GPIO_LED_PIN"]

# GPIO objects
led = LED(GPIO_LED_PIN)
button = Button(GPIO_BUTTON_PIN, pull_up=False)

def is_bluetooth_on() -> bool:
    output = subprocess.check_output("bluetoothctl show", shell=True).decode()
    return "Powered: yes" in output

def set_bluetooth(state: bool) -> None:
    action = "power on" if state else "power off"
    subprocess.run(f"bluetoothctl {action}", shell=True)

def update_led() -> None:
    if is_bluetooth_on():
        led.on()
    else:
        led.off()

def toggle_bluetooth() -> None:
    current_state = is_bluetooth_on()
    set_bluetooth(not current_state)
    time.sleep(0.5)
    update_led()

# Add handler to button when pressed.
button.when_pressed = toggle_bluetooth

# Pause process to be run in the background
print(f"Watching bluetooth status with LED on GPIO pin {GPIO_LED_PIN}. "
      f"Toggle status by pressing button on GPIO pin {GPIO_BUTTON_PIN}. "
      "CTRL+C to exit.")

# Will poll BT status every minute
while True:
    update_led()
    time.sleep(60)