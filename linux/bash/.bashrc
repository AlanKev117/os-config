# ========================================================
# Append to .bashrc 
# ========================================================

# Load ssh keys automatically once per boot
if [ -f ~/.ssh-load-keys.sh ]; then
    . ~/.ssh-load-keys.sh
fi

# Adds the status of the current git branch to the prompt
if [ -f ~/.git-prompt-status.sh ]; then
    . ~/.git-prompt-status.sh
fi

# Ensure the prompt always prints at the beginning of the line
# regardless of the last output.
if [ -f ~/.check-new-line.sh ]; then
    . ~/.check-new-line.sh
fi

# Enable function to set static DHCP
if [ -f ~/.dhcp-set-static.sh ]; then
    . ~/.dhcp-set-static.sh
fi

# Enable functions to mount volumes
if [ -f ~/.volume-tools.sh ]; then
    . ~/.volume-tools.sh
fi

# Set vim as default terminal editor
export VISUAL=vim
export EDITOR=vim