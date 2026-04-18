# Ensure the prompt always prints at the beginning of the line
# regardless of the last output.

check_newline() {
    local _ y x
    # Request the current cursor position from the terminal
    echo -en "\e[6n"
    
    # Read the response (timeout of 1s to prevent hanging)
    IFS='[;' read -t 1 -sd R _ y x
    
    # If the x coordinate (column) is not 1, we are not at the start of the line
    if [[ "$x" != 1 ]]; then
        # Print an inverted '%' symbol, followed by a newline
        echo -e "\e[7m%\e[0m"
    fi
}

# Prepend the function to PROMPT_COMMAND so it runs before every prompt
PROMPT_COMMAND="check_newline; ${PROMPT_COMMAND:-}"