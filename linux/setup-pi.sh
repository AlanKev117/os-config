#!/bin/bash
set -e

# Validate IP address is passed
ip_addr=$1
if [ -z "$ip_addr" ]
then
    echo "Error: IP address not provided." >&2
    exit 1
fi

# Install apt packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y zsh curl git-all python3-full vim
echo "[INFO] Installed apt packages"

# Set static IP address
gateway=${2:-"192.168.1.254"}
connection=${3:-"preconfigured"}
sudo nmcli con mod ${connection} ipv4.addresses ${ip_addr}/24 ipv4.method manual
sudo nmcli con mod ${connection} ipv4.gateway ${gateway}
sudo nmcli con mod ${connection} ipv4.dns "${gateway},8.8.8.8"
echo "[INFO] Set static IP to ${ip_addr}, gateway to ${gateway} and dns to ${gateway},8.8.8.8 (effective after reboot)"

# Finish setup in zsh
zsh ./setup-omz.sh

# Reboot countdown
seconds_to_wait=10
for i in $(seq $seconds_to_wait -1 1)
do
    echo -ne "[INFO] System will reboot in ${i} seconds to make all changes effective...\r"
    sleep 1
done
sudo reboot
