# Creates Windows shortcuts with key bindings that perform a specific action.

$shortcutsFolder = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\shortcuts"

if (Test-Path -Path $shortcutsFolder) {
    Remove-Item -Path $shortcutsFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $shortcutsFolder -Force

# We define all shortcuts to be created
$shortcutTurnOffScreen = @{
    Path = "$shortcutsFolder\TurnOffScreen.lnk"
    TargetPath = (Get-Command nircmd.exe).Path
    Arguments = "monitor off"
    Hotkey = "CTRL+ALT+B"
}

$shortcutMuteMics = @{
    Path = "$shortcutsFolder\MuteMics.lnk"
    TargetPath = (Get-Command powershell.exe).Path
    Arguments = '-File ' + '"' + (Resolve-Path -Path "..\utils\ControlMic\ControlMic.ps1").Path + '"' + " mute"
    Hotkey = "CTRL+ALT+M"
}

$shortcutUnmuteMics = @{
    Path = "$shortcutsFolder\UnmuteMics.lnk"
    TargetPath = (Get-Command powershell.exe).Path
    Arguments = '-File ' + '"' + (Resolve-Path -Path "..\utils\ControlMic\ControlMic.ps1").Path + '"' + " unmute"
    Hotkey = "CTRL+ALT+N"
}

$shortcuts = @()
$shortcuts += $shortcutTurnOffScreen
$shortcuts += $shortcutMuteMics
$shortcuts += $shortcutUnmuteMics

$ws = New-Object -ComObject WScript.Shell

$shortcuts | ForEach-Object {
    $shortcut = $ws.CreateShortcut($_["Path"])
    $shortcut.TargetPath = $_["TargetPath"]
    $shortcut.Arguments = $_["Arguments"]
    $shortcut.Hotkey = $_["Hotkey"]
    $shortcut.WindowStyle = 4 # 7 = min, 4 = normal, 3 = max
    $shortcut.Save()
}
