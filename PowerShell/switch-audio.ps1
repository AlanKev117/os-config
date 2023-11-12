# Arguments: type ["input" or "output"] name [unique part of the name of the device].
$type=$args[0]
$name=$args[1]

# Auciliar hash maps.
$type_translator = @{
    input = "Recording"
    output = "Playback"
}

# Get all audio devices with this tool: https://github.com/frgnca/AudioDeviceCmdlets
$list = Get-AudioDevice -List

# Filter by type.
$typed_list = $list | where{$_.type -eq $type_translator[$type]}

# Filter by name.
$singleton_list = $typed_list | where{$_.name.contains($name)}

if ($singleton_list.count -eq 1) {
    # Extract unique device in list.
    $chosen_device = $singleton_list[0]

    # Switch device with same tool from above.
    Set-AudioDevice	$chosen_device.index
}