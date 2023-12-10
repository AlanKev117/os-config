param (
    [string]$action
)

$actions = @{"mute" = "/Mute"; "unmute" = "/Unmute"; "toggle" = "/Switch"}

# Validate action is valid
if (-Not ($actions.Keys -contains $action)) {
    $validActions = ($actions.Keys | % {"'$_'"}) -join ", "
    Write-Error "Wrong action selected: '$action'. Valid actions are $validActions"
    exit 1
}

# Constants
$devicesFile = "$HOME/Software/control_microphone/devices.tsv"
$maxRetries = 10

# Get a list of all audio devices in a file
SoundVolumeView /stab $devicesFile /Columns "Name, Direction, Type, Device State"

# Polling to check the file exists
$tryNo = 0
while (-Not (Test-Path -Path $devicesFile -PathType Leaf)) {
    Start-Sleep -Milliseconds 100
    if ($tryNo -eq $maxRetries) {
        Break
    }
}

if ($tryNo -eq $maxRetries) {
    Write-Error "Error generating file with device info"
    exit 2
}

# Parse the file into memory
$devices = Import-Csv -Path $devicesFile -Delimiter "`t"

# Filter active input devices only
$inputDevices = $devices | Where-Object { $_."Device State" -eq "Active" -and $_.Direction -eq "Capture" -and $_.Type -eq "Device"}

# Get unique names of valid devices
$inputDeviceNames = $inputDevices | % {$_.Name} | Sort-Object | Get-Unique

# Execute action on devices
$inputDeviceNames | % {SoundVolumeView $actions[$action] "$_"}

# Remove file with device info
Remove-Item $devicesFile