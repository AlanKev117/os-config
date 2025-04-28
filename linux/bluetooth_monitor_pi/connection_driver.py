import time
import logging
import subprocess

from gpiozero import LED, Button

class ConnectionDriver:
    def __init__(self, led_pin: int | str, button_pin: int | str, adapter_mac: str, device_mac: str):
        self.led = LED(led_pin)
        self.button = Button(button_pin, pull_up=False, bounce_time=0.1)
        self.adapter_mac = adapter_mac
        self.device_mac = device_mac
        self.button.when_released = self.toggle_connection
        self.logger = logging.getLogger(f"logger_l-{led_pin}_b-{button_pin}")
        self.logger.setLevel(logging.INFO)
    
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
    
    def set_connection(self, active: bool):
        action = "connect" if active else "disconnect"
        cmd = f"""
            bluetoothctl << EOF
            select {self.adapter_mac}
            {action} {self.device_mac}
            exit
            EOF
        """
        output = subprocess.check_output(cmd, shell=True).decode()
        if "Failed to connect" in output:
            raise Exception(f"Could not connect to device {self.device_mac} with adapter {self.adapter_mac}")

    def update_led(self):
        if self.is_connected():
            self.led.on()
            self.logger.info(f"Connected to {self.device_mac}")
        else:
            self.led.off()
            self.logger.info(f"Disconnected from {self.device_mac}")

    def toggle_connection(self):
        current_state = self.is_connected()
        self.set_connection(not current_state)
        self.update_led()
