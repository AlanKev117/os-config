import time
import logging
import subprocess

from gpiozero import LED, Button

class ConnectionDriver:
    def __init__(self, led_pin: int | str, button_pin: int | str, adapter_mac: str, device_mac: str):

        # Herdware setup
        self.led = LED(led_pin)
        self.button = Button(button_pin, pull_up=False, bounce_time=0.1)
        self.adapter_mac = adapter_mac
        self.device_mac = device_mac
        self.button.when_released = self.toggle_connection

        # Logger setup
        self.logger = logging.getLogger(f"logger_l-{led_pin}_b-{button_pin}")
        self.logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        handler.setLevel(logging.INFO)
        formatter = logging.Formatter('[%(levelname)s] [%(asctime)s] [%(name)s] - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def is_connected(self) -> bool:
        cmd = f"""
            bluetoothctl << EOF
            select {self.adapter_mac}
            info {self.device_mac}
            exit
            EOF
        """
        output = subprocess.check_output(cmd, shell=True).decode()
        return "Connected: yes" in output

    def set_connection(self, active: bool) -> bool:
        action = "connect" if active else "disconnect"
        cmd = f"""
            bluetoothctl << EOF
            select {self.adapter_mac}
            {action} {self.device_mac}
            exit
            EOF
        """
        output = subprocess.check_output(cmd, shell=True).decode()
        expected_message = "Connection successful" if active else "Successful disconnected"
        return expected_message in output

    def update_led(self):
        current_status = self.is_connected()
        if current_status == self.latest_status:
            # Don't do anyting if the latest status hasn't changed
            return

        if current_status == True:
            self.led.on()
            self.logger.info(f"Connected to {self.device_mac}")
        else:
            self.led.off()
            self.logger.info(f"Disconnected from {self.device_mac}")

        self.latest_status = current_status

    def toggle_connection(self):
        current_state = self.is_connected()
        succeeded = self.set_connection(not current_state)
        if not succeeded:
            self.logger.error("Failed to switch status of connection.")
        self.update_led()
