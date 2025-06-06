import time
import logging
import subprocess
from gpiozero import LED

from pynput import keyboard

# Diccionario de mapeo
allowed_keys = {
    'shift': keyboard.Key.shift,
    'ctrl': keyboard.Key.ctrl,
    'alt': keyboard.Key.alt,
    'f1': keyboard.Key.f1,
    'f2': keyboard.Key.f2,
    'f3': keyboard.Key.f3,
    'f4': keyboard.Key.f4,
    'f5': keyboard.Key.f5,
    'f6': keyboard.Key.f6,
    'f7': keyboard.Key.f7,
    'f8': keyboard.Key.f8,
    'f9': keyboard.Key.f9,
    'f10': keyboard.Key.f10,
    'f11': keyboard.Key.f11,
    'f12': keyboard.Key.f12
}

class ConnectionDriver:
    def __init__(self, led_pin: int | str, key_sequence: list[str], adapter_mac: str, device_mac: str):

        # Hardware setup
        self.led: LED = LED(led_pin)
        self.key_sequence: list[keyboard.Key] = [allowed_keys[key_str.lower()] for key_str in key_sequence]
        self.adapter_mac: str = adapter_mac
        self.device_mac: str = device_mac
        self.key_sequence_str: str = " + ".join([key_str.upper() for key_str in key_sequence])
        self.pressed_keys: list[keyboard.Key] = []
        self.listener = keyboard.Listener(on_press=self.handle_press, on_release=self.handle_release)

        # Logger setup
        self.logger = logging.getLogger(f"logger_l-{led_pin}")
        self.logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        handler.setLevel(logging.INFO)
        formatter = logging.Formatter('[%(levelname)s] [%(asctime)s] [%(name)s] - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)

        self.latest_status = self.is_connected()
    
    def is_connected(self) -> bool:
        input = f"""
            select {self.adapter_mac}
            info {self.device_mac}
            exit
        """.strip()

        output = subprocess.check_output(["bluetoothctl"], input=input, text=True)
        return "Connected: yes" in output

    def set_connection(self, active: bool) -> bool:
        action = "connect" if active else "disconnect"
        input = f"""
            select {self.adapter_mac}
            {action} {self.device_mac}
            exit
        """.strip()
        subprocess.run(["bluetoothctl"], input=input, text=True, capture_output=True)
        time.sleep(5)
        self.logger.info("Tried to set connection " + "on" if active else "off")

    def update_led(self):
        connection_status = self.is_connected()
        led_status = self.led.active
        if connection_status != led_status:
            self.led.value = connection_status
        self.logger.info("Connection is currently " + "on" if connection_status else "off")

    def toggle_connection(self):
        previous_state = self.is_connected()
        self.set_connection(not previous_state)
        # Backoff logic due to the async behavior of set_connection.
        backoff_tries = 6
        while previous_state == self.is_connected():
            if backoff_tries == 0:
                self.logger.error(f"Failed to toggle connection, try pressing the key sequence {self.key_sequence_str} again")
                break
            time.sleep(0.5)
            backoff_tries -= 1

    def handle_press(self, key: keyboard.Key):
        try:
            if key in self.key_sequence:
                self.pressed_keys.append(key)

            if self.pressed_keys == self.key_sequence:
                self.logger.info(f"Sequence {self.key_sequence_str} detected, connection will toggle!")
                self.toggle_connection()
                
        except Exception as e:
            self.logger.error(f"An error ocurred while reading input (press): {e}")

    def handle_release(self, key: keyboard.Key):
        try:
            if key in self.key_sequence:
                self.pressed_keys.remove(key)
        except Exception as e:
            print(f"An error ocurred while reading input (release): {e}")
