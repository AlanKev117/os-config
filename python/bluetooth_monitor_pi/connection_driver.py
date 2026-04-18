import time
import logging
import subprocess

import keyboard
from gpiozero import LED

class ConnectionDriver:
    def __init__(self, led_pin: int | str, key_sequence: str, adapter_mac: str, device_mac: str):

        # Hardware setup
        self.led: LED = LED(led_pin)
        self.key_sequence: str = key_sequence
        self.adapter_mac: str = adapter_mac
        self.device_mac: str = device_mac
        keyboard.add_hotkey(key_sequence, self.toggle_connection)

        # Logger setup
        self.logger = logging.getLogger(f"logger_l-{led_pin}_s-{key_sequence}")
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

    def update_led(self):
        connection_status = self.is_connected()
        led_status = self.led.is_lit
        if connection_status != led_status:
            if connection_status:
                self.led.on()
            else:
                self.led.off()
            self.logger.info("Connection is currently " + ("on" if connection_status else "off"))

    def toggle_connection(self):
        previous_state = self.is_connected()
        self.set_connection(not previous_state)
        # Backoff logic due to the async behavior of set_connection.
        backoff_tries = 6
        while previous_state == self.is_connected():
            if backoff_tries == 0:
                self.logger.error(f"Failed to toggle connection, try pressing the key sequence {self.key_sequence} again")
                break
            time.sleep(0.5)
            backoff_tries -= 1
        else:
            self.logger.info(f"Successfully toggled connection!")
