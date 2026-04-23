# Advanced function for the Git prompt status
parse_git_status() {
    # 1. Get the current branch name
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    # Exit if not in a git repository
    [ -z "$branch" ] && return

    local status_color="\033[01;32m" # Default Green (Clean)
    local marks=""

    # 2. Check for staged changes (Index)
    if ! git diff --cached --quiet 2>/dev/null; then
        status_color="\033[38;5;208m" # Orange if changes are staged
        marks="${marks}+"
    fi

    # 3. Check for unstaged changes (Working Tree)
    if ! git diff --quiet 2>/dev/null; then
        status_color="\033[01;33m" # Yellow if files are modified but not staged
        marks="${marks}*"
    fi

    # 4. Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        marks="${marks}?"
    fi

    # 5. Add space before marks if any
    if [ -n "${marks}" ]; then
        marks=" ${marks}"
    fi

    # Using \001 and \002 as wrappers tells Bash these are non-printing characters.
    # This prevents the literal "\[\]" bug and fixes line-wrapping issues.
    if [ "${NO_MARKS}" == "true" ]
    then
        echo -ne " \001${status_color}\002\u27e8${branch}\u27e9\001\033[00m\002"
    else
        echo -ne " \001${status_color}\002\u27e8${branch}${marks}\u27e9\001\033[00m\002"
    fi
}

# PS1 Configuration
# \u = username, \h = hostname, \w = working directory
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(parse_git_status)\n\$ "