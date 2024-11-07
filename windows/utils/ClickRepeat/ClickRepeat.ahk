!+c:: ; Alt+Shift+C to trigger the repeated click
{
    ; Set the number of clicks and the delay between clicks (in milliseconds)
    ClickCount := 10 ; Change this number to adjust the number of clicks
    ClickDelay := 100 ; Change this number to adjust the delay between clicks

    ; Loop through the number of clicks
    Loop ClickCount {
        ; Simulate a mouse click
        Click
        ; Pause for the specified delay
        Sleep ClickDelay
    }
}