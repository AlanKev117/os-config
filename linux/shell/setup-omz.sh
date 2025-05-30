#!/bin/zsh

# Install Oh-my-zsh
if [ ! -d "${HOME}/.oh-my-zsh" ]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "[INFO] Installed Oh-my-zsh"
else
    echo "[INFO] Oh-my-zsh already installed"
fi

# Source ~/.zshrc source file to load omz
source ${HOME}/.zshrc

# Install aphrodite theme
target_theme_dir="${HOME}/.oh-my-zsh/custom/themes/aphrodite"
if [ -d ${target_theme_dir} ] && [ -d ${target_theme_dir}/.git ]
then
    echo "[INFO] aphrodite repo already cloned in ${target_theme_dir}"
else
    git clone --quiet https://github.com/win0err/aphrodite-terminal-theme ${target_theme_dir}
fi
omz theme set aphrodite/aphrodite
echo "[INFO] aphrodite theme installed"

# Install zsh-syntax-highlighting theme
target_plugin_dir="${ZSH_CUSTOM:-"${HOME}/.oh-my-zsh/custom"}/plugins/zsh-syntax-highlighting"
if [ -d "${target_plugin_dir}" ] && [ -d "${target_plugin_dir}/.git" ]
then
    echo "[INFO] zsh-syntax-highlighting repo already cloned in ${target_plugin_dir}"
else
    git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${target_plugin_dir}
fi

if ! grep -q "zsh-syntax-highlighting" ${HOME}/.zshrc
then
    sed -i '/^plugins=/ s/)/ zsh-syntax-highlighting)/' ${HOME}/.zshrc
fi
echo "[INFO] Installed omz plugins"

[ "$(basename -- "$SHELL")" = "zsh" ] || chsh -s $(which zsh)
echo "[INFO] Set zsh as default shell"