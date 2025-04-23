#!/bin/bash

# Installs/updates the systemd service that runs the Bluetooth monitor
# IMPORTANT: run this script inside its folder, `bluetooth_monitor_py/`.

GPIO_LED_PIN = ${1:-17}
GPIO_BUTTON_PIN = ${2:-27}

SERVICE_FILE_NAME="bluetooth-monitor.service"

echo "Installing dependencies..."
sudo apt update
sudo apt upgrade --yes
sudo apt install python3-full python3-gpiozero --yes

echo "Creating systemd service..."
sed "s|{MONITOR_DIR}|$(pwd)|" bluetooth-monitor.service.template > "./${SERVICE_FILE_NAME}"
sed -i "s/{GPIO_LED_PIN}/${GPIO_LED_PIN}/" "./${SERVICE_FILE_NAME}"
sed -i "s/{GPIO_BUTTON_PIN}/${GPIO_BUTTON_PIN}/" "./${SERVICE_FILE_NAME}"

echo "Updating systemd service..."
sudo mv "./${SERVICE_FILE_NAME}" "/etc/systemd/system/${SERVICE_FILE_NAME}"
sudo systemctl daemon-reload
sudo systemctl restart ${SERVICE_FILE_NAME}