#!/bin/bash

ip_addr=$1
if [ -z "$ip_addr" ]
then
    echo "Error: IP address not provided." >&2
    exit 1
fi

# Install Python, zsh and git
sudo apt update
sudo apt upgrade -y
sudo apt install -y zsh curl git-all python3-full
echo "[INFO] Installed apt packages"

# Install Oh-my-zsh
if [ -z "${ZSH}" ]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "[INFO] Installed omz"
else
    echo "[INFO] omz already installed"
fi

# Install aphrodite theme
target_theme_dir="~/.oh-my-zsh/custom/themes/aphrodite"
if [ -d "${target_theme_dir}" ] && [ -d "${target_theme_dir}/.git" ]
then
    echo "[INFO] aphrodite repo already cloned in ${target_theme_dir}"
else
    git clone --quiet https://github.com/win0err/aphrodite-terminal-theme $target_theme_dir
fi
omz theme set aphrodite/aphrodite
omz reload
echo "[INFO] Installed aphrodite theme"

# Install zsh-syntax-highlighting theme
target_plugin_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "${target_plugin_dir}" ] && [ -d "${target_plugin_dir}/.git" ]
then
    echo "[INFO] zsh-syntax-highlighting repo already cloned in ${target_plugin_dir}"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${target_plugin_dir}    
fi

if ! grep -q "zsh-syntax-highlighting" ~/.zshrc
then
    sed -i '/^plugins=/ s/)/ zsh-syntax-highlighting)/' ~/.zshrc
fi
echo "[INFO] Installed omz plugins"

# Set static IP address
gateway=${2:-"192.168.1.254"}
connection=${3:-"preconfigured"}
sudo nmcli con mod ${connection} ipv4.addresses ${ip_addr}/24 ipv4.method manual
sudo nmcli con mod ${connection} ipv4.gateway ${gateway}
sudo nmcli con mod ${connection} ipv4.dns "${gateway},8.8.8.8"

# Reboot countdown
seconds_to_wait=5
for i in $(seq $seconds_to_wait -1 1)
do
    echo -ne "[INFO] System will reboot in ${i} seconds to make all changes effective...\r"
    sleep 1
done
[ "$SHELL" != "/usr/bin/zsh" ] && (chsh -s $(which zsh) && sudo reboot) || sudo reboot