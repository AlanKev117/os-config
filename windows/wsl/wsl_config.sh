
# Put these lines in the ~/.zshrc file after running linux/shell/setup-omz.sh

# Fixes some anoying colors from the terminal color schema
export LS_COLORS="${LS_COLORS}ow=0;34:tw=0;34"
zstyle ':completion:*' list-colors

# Alias to enter the Windows home directory for my user
export WHOME=/mnt/c/Users/fuent
alias cdw='cd $WHOME'
