# Start SSH agent and add key automatically
env=~/.ssh/agent.env

# Define all your SSH keys here, separated by a space
SSH_KEYS="$HOME/.ssh/<key1> $HOME/.ssh/<key2> $HOME/.ssh/<key3>"

agent_load_env () {
    test -f "$env" && . "$env" >| /dev/null ;
}

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ;
}

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add ${SSH_KEYS}
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add ${SSH_KEYS}
fi

unset env