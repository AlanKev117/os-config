# Put the following content here: $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

function ListVolumes {
    wmic diskdrive list brief
}

function MountVolumeWsl {
    param (
        $VolumeIndex
    )

    wsl --mount \\.\PHYSICALDRIVE$VolumeIndex --bare
}

function UnmountVolumeWsl {
    param (
        $VolumeIndex
    )
    wsl --unmount \\.\PHYSICALDRIVE$VolumeIndex
}


Set-Alias -Name llist -Value ListVolumes
Set-Alias -Name lmount -Value MountVolumeWsl
Set-Alias -Name lumount -Value UnmountVolumeWsl

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
