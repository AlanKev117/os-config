# Windows setup for new installations

## 1. `shell/`

Contains software instalation scripts. Enter this folder and then run the following scripts in this order:

1. `install_choco.ps1` will install the chocolately package manager`
1. `install_programs.ps1` will install programs and required software for being able to use the utilities in `utils/`
1. `create_shortcuts.ps1` will create shortcuts with hotkeys to trigger utilities from `utils/` and also add an extra keybind to turn off your screen by typing `AltGr + B`. 

## 2. `utils/`

Contains utilities like scripts and key bindings for your computer.

### 2.1. `ControlMic`

A PowerShell script that mutes/unmutes all the mics in your system.

> You need to assign unique names to your recording devices in the Admin Panel or the Settings app for the script to work properly.

#### Usage

* `AltGr + M` = Mute mics
* `AltGr + N` = Unmute mics

> Make sure you have run both scripts in the `shell` folder. 

### 2.2. `ClickRepeat`

An AHK v2 script that simulates repeated mouse clicks with a hotkey.

#### Usage

1. Double click the script to activate it
2. Type `Alt + Shift + C` to simulate many click events

> You can configure the number and speed of the clicks in the `ClickRepeat.ahk` script.
> Make sure you have run both scripts in the `shell` folder

## 3. `wsl/`

The config file in the `wsl` folder is meant to be appended to the .zshrc file of your WSL distribution. That way, the terminal color schema becomes more simple.

It also adds a new WHOME env var in WSL so you can easily access Windows' user's home folder by typing `cd $WHOME`. You can also type `cdw` for more simplicity.