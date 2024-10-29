#!/bin/bash
set -e

# Validate params are passed
ip_addr=$1
if [ -z "$ip_addr" ]
then
    echo "Error: IP address not provided." >&2
    exit 1
fi
samba_pw=$2
if [ -z "${samba_pw}" ]
then
    echo "Error: Must provide password for samba user." >&2
    exit -1
fi

# Install apt packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y zsh curl git-all python3-full vim cryptsetup samba
echo "[INFO] Installed apt packages"

# Set static IP address
gateway=${3:-"192.168.1.254"}
connection=${4:-"preconfigured"}
sudo nmcli con mod ${connection} ipv4.addresses ${ip_addr}/24 ipv4.method manual
sudo nmcli con mod ${connection} ipv4.gateway ${gateway}
sudo nmcli con mod ${connection} ipv4.dns "${gateway},8.8.8.8"
echo "[INFO] Set static IP to ${ip_addr}, gateway to ${gateway} and dns to ${gateway},8.8.8.8 (effective after reboot)"

# Inject volume aliases to .zshrc
if ! grep -q "smount" ${HOME}/.zshrc
then
    cat ./volume-tools.sh >> ${HOME}/.zshrc
fi
echo "[INFO] Set up luks and mount aliases"

# Create samba user and inject samba config
if ! sudo pdbedit -L | grep -q "${5:-'alan'}"
then
    (echo "${samba_pw}"; echo "${samba_pw}") | sudo smbpasswd -a -s ${5:-"alan"}
fi
if ! grep -q "Append to /etc/samba/smb.conf"
then
    sudo bash -c 'cat ../config/smb.conf >> /etc/samba/smb.conf'
fi
echo "[INFO] Set up samba file sharing"

# Finish setup in zsh
zsh ./setup-omz.sh
echo "[INFO] Oh-my-zsh with plugins and theme installed"

# Reboot countdown
seconds_to_wait=10
for i in $(seq $seconds_to_wait -1 1)
do
    echo -ne "[INFO] System will reboot in ${i} seconds to make all changes effective...\r"
    sleep 1
done
sudo reboot
