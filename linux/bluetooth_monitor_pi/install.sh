#!/bin/bash

set -e

# Installs/updates the systemd service that runs the Bluetooth monitor
# IMPORTANT: run this script inside its folder, `bluetooth_monitor_py/`.

# Optional inputs
GPIO_LED_PIN=${1:-17}
GPIO_BUTTON_PIN=${2:-27}
DEVICE_MAC_ADDRESS=${3}

# If no MAC address is provided, the one of the first linked device is taken
[ -z "${DEVICE_MAC_ADDRESS}" ] && DEVICE_MAC_ADDRESS=$(bluetoothctl devices | head -1 | awk '{print $2}')

SERVICE_FILE_NAME="bluetooth-monitor.service"

echo "Installing dependencies..."
sudo apt update
sudo apt upgrade --yes
sudo apt install python3-full python3-gpiozero --yes

echo "Creating systemd service..."
sed "s|{MONITOR_DIR}|$(pwd)|" bluetooth-monitor.service.template > ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_LED_PIN}/${GPIO_LED_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_BUTTON_PIN}/${GPIO_BUTTON_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{DEVICE_MAC_ADDRESS}/${DEVICE_MAC_ADDRESS}/" ./${SERVICE_FILE_NAME}

echo "Creating/updating systemd service..."
sudo mv ./${SERVICE_FILE_NAME} /etc/systemd/system/${SERVICE_FILE_NAME}
sudo systemctl daemon-reload

if systemctl list-units --full -all | grep -Fq "${SERVICE_FILE_NAME}"
then
    sudo systemctl restart ${SERVICE_FILE_NAME}
    echo "Service ${SERVICE_FILE_NAME} udpated!"
else
    sudo systemctl enable ${SERVICE_FILE_NAME}
    sudo systemctl start ${SERVICE_FILE_NAME}
    echo "Service ${SERVICE_FILE_NAME} created!"
fi
