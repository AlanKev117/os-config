# Before running this script make sure you assign a unique name to every
# input device. That name must not be the same for any output device.

param (
    [string]$action
)

$actions = @{"mute" = "/Mute"; "unmute" = "/Unmute"}

# Validate action is valid
if (-Not ($actions.Keys -contains $action)) {
    $validActions = ($actions.Keys | ForEach-Object {"'$_'"}) -join ", "
    Write-Error "Wrong action selected: '$action'. Valid actions are $validActions"
    exit 1
}

# Filter active input devices only
$micNames = SoundVolumeView.exe /stab "" | GetNir.exe "Name" "Type=Device && Direction=Capture && 'Device State'=Active"

# Execute action on devices
$micNames | ForEach-Object {
    SoundVolumeView.exe $actions[$action] "$_"
}