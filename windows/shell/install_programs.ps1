# Requirements to install WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Install WSL
wsl --install

# Install software from winget
winget install Brave.Brave
winget install AutoHotkey.AutoHotkey
winget install Adobe.Acrobat.Reader.64-bit
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
winget install Zoom.Zoom
winget install Discord.Discord
winget install Mozilla.Firefox
winget install Logitech.GHUB
winget install Python.Python.3.12
winget install NirSoft.SoundVolumeView
winget install flux.flux
winget install Microsoft.PowerShell

# Install module ps2exe
Install-Module ps2exe -Force

# Install programs with choco
choco install nircmd -y
choco install nmap -y

# Install getnir
# 1. Download GetNir ZIP file
$ZipPath = "$HOME\Downloads\getnir.zip"
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/getnir.zip" -OutFile $ZipPath
# 2. Extract the ZIP file
$GetNirPath = "$HOME\AppData\Local\Programs\GetNir"
Expand-Archive -Path $ZipPath -DestinationPath $GetNirPath
# 3. Add GetNir folder to the system PATH
[System.Environment]::SetEnvironmentVariable("Path", "$($env:Path);$GetNirPath", [System.EnvironmentVariableTarget]::User)
# 4. Clean up ZIP file
Remove-Item $ZipPath

# Install LapLock
$downloadLink = "https://github.com/dechamps/laplock/releases/download/laplock-0.2/laplock.exe"
$startupFolder = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\laplock.exe"
Invoke-WebRequest -Uri $downloadLink -OutFile $startupFolder

# Compile ControlMic.ps1 as executable
$ControlMicExeDir = "$HOME\AppData\Local\Programs\ControlMic"
if (Test-Path -Path $ControlMicExeDir) {
    Remove-Item -Path $ControlMicExeDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ControlMicExeDir -Force
Invoke-ps2exe -inputFile (Resolve-Path -Path "..\utils\ControlMic\ControlMic.ps1").Path -outputFile "$ControlMicExeDir\ControlMic.exe" -Verbose
[System.Environment]::SetEnvironmentVariable("Path", "$($env:Path);$ControlMicExeDir", [System.EnvironmentVariableTarget]::User)