# Creates Windows shortcuts with key bindings that perform a specific action.

$shortcutsFolder = "$env:USERPROFILE\Desktop"

# We define all shortcuts to be created
$shortcutTurnOffScreen = @{
    Path = "$shortcutsFolder\TurnOffScreen.lnk"
    TargetPath = (Get-Command nircmd.exe).Path
    Arguments = "monitor off"
    Hotkey = "CTRL+ALT+B"
}

$shortcutMuteMics = @{
    Path = "$shortcutsFolder\MuteMics.lnk"
    TargetPath = (Get-Command controlmic.exe).Path
    Arguments = "mute"
    Hotkey = "CTRL+ALT+M"
}

$shortcutUnmuteMics = @{
    Path = "$shortcutsFolder\UnmuteMics.lnk"
    TargetPath = (Get-Command controlmic.exe).Path
    Arguments = "unmute"
    Hotkey = "CTRL+ALT+N"
}

$shortcuts = @()
$shortcuts += $shortcutTurnOffScreen
$shortcuts += $shortcutMuteMics
$shortcuts += $shortcutUnmuteMics

$ws = New-Object -ComObject WScript.Shell

$shortcuts | ForEach-Object {

    if (Test-Path -Path $_["Path"]) {
        Remove-Item -Path $_["Path"] -Force
    }

    $shortcut = $ws.CreateShortcut($_["Path"])
    $shortcut.TargetPath = $_["TargetPath"]
    $shortcut.Arguments = $_["Arguments"]
    $shortcut.Hotkey = $_["Hotkey"]
    $shortcut.WindowStyle = 7 # 7 = min, 4 = normal, 3 = max
    $shortcut.Save()

    Set-ItemProperty -Path $_["Path"] -Name Attributes -Value Hidden
}
