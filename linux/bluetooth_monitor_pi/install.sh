#!/bin/bash

set -e

# Installs/updates the systemd service that runs the Bluetooth monitor
# IMPORTANT: run this script inside its folder, `bluetooth_monitor_py/`.

# Optional command line args:

DEVICE_MAC_ADDRESS=$1 # MAC address of target device to control

GPIO_LED1_PIN=${2:-17} # To show status of connection from interface 1
GPIO_BUTTON1_PIN=${3:-27} # To control status of connection from interface 1

GPIO_LED2_PIN=${4:-5} # To show status of connection from interface 2
GPIO_BUTTON2_PIN=${5:-6} # To control status of connection from interface 2

# If no MAC address is provided, we take the one from the first paired device
[ -z "${DEVICE_MAC_ADDRESS}" ] && DEVICE_MAC_ADDRESS=$(bluetoothctl devices Paired | head -1 | awk '{print $2}')

SERVICE_FILE_NAME="bluetooth-monitor.service"

echo "Installing dependencies..."
sudo apt update
sudo apt upgrade --yes
sudo apt install python3-full python3-dev python3-gpiozero  --yes

echo "Creating systemd service..."
sed "s|{SERVICE_DIR}|$(pwd)|" bluetooth-monitor.service.template > ./${SERVICE_FILE_NAME}
sed -i "s/{DEVICE_MAC_ADDRESS}/${DEVICE_MAC_ADDRESS}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_LED1_PIN}/${GPIO_LED1_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_BUTTON1_PIN}/${GPIO_BUTTON1_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_LED2_PIN}/${GPIO_LED2_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_BUTTON2_PIN}/${GPIO_BUTTON2_PIN}/" ./${SERVICE_FILE_NAME}

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
