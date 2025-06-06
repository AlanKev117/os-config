#!/bin/bash

set -e

# Installs/updates the systemd service that runs the Bluetooth monitor
# IMPORTANT: run this script inside its folder, `bluetooth_monitor_pi/`.

# Optional command line args:

DEVICE_MAC_ADDRESS=$1 # MAC address of target device to control

GPIO_LED1_PIN=${2:-17} # To show status of connection from interface 1
CON1_KEY_SEQ=${3:-'["shift", "f5"]'} # To control status of connection from interface 1

GPIO_LED2_PIN=${4:-27} # To show status of connection from interface 2
CON2_KEY_SEQ=${5:-'["shift", "f6"]'} # To control status of connection from interface 2

# If no MAC address is provided, we take the one from the first paired device
[ -z "${DEVICE_MAC_ADDRESS}" ] && DEVICE_MAC_ADDRESS=$(bluetoothctl devices Paired | head -1 | awk '{print $2}')

SERVICE_FILE_NAME="bluetooth-monitor.service"

echo "Installing dependencies..."
sudo apt update
sudo apt upgrade --yes
sudo apt install python3-full python3-dev python3-gpiozero --yes

SERVICE_DIR=$(pwd)
ENV_DIR=env
if [ -d "${SERVICE_DIR}/${ENV_DIR}" ]
then
    echo "Virtual env exists, dependencies should be there too..."
else
    python3 -m venv ${ENV_DIR}
    source ${ENV_DIR}/bin/activate
    pip3 install -r requirements.txt

echo "Creating systemd service..."
sed "s|{SERVICE_DIR}|${SERVICE_DIR}|g" bluetooth-monitor.service.template > ./${SERVICE_FILE_NAME}
sed -i "s|{ENV_DIR}|${ENV_DIR}|" ./${SERVICE_FILE_NAME}
sed -i "s/{DEVICE_MAC_ADDRESS}/${DEVICE_MAC_ADDRESS}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_LED1_PIN}/${GPIO_LED1_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{CON1_KEY_SEQ}/${CON1_KEY_SEQ}/" ./${SERVICE_FILE_NAME}
sed -i "s/{GPIO_LED2_PIN}/${GPIO_LED2_PIN}/" ./${SERVICE_FILE_NAME}
sed -i "s/{CON2_KEY_SEQ}/${CON2_KEY_SEQ}/" ./${SERVICE_FILE_NAME}

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
