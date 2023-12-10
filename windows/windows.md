# Windows assets

## Prerequirements

* Enable `WSL` and install a distro for it like `Ubuntu`
  * Install `zsh` and `Oh-My-Zsh`
  * Install `aphrodite` osmyzsh theme
* Install `AutoHotKeys` (AHK) V2
* Install `SoundVolumeView`
* Install `ps2exe`
* Install `Python` (recommended from MS Store)

## 1. `utils/`

Here are some utilities like scripts or key bindings for your computer.

### 1.1 `control_microphone`

This is a small utility that consists of a PowerShell script that can be triggered via keyboard shortcuts so you mute or unmute all recording devices in your Windows machine.

#### Installation

1. Copy the `control_microphone` folder wherever you want.

```bash
# WSL
cp -r windows/utils/control_microphone $WHOME/Software # mandatory dest. folder

# PS
xcopy windows\utils\control_microphone $HOME\Software # mandatory dest. folder
``` 
> To learn how to set up the `WHOME` var in WSL, go to the [WSL config section](#2-wsl-config).

2. Add the destination folder to Windows' user's path environment variable
    * Open the env. variables panel by following this route: `Win + X` > `System` > `Advanced system settings` > `Environment Variables`
    * Click `Path` under _User variables for \<your user\>_ and then click __Edit__
    * Add a new entry with the destination folder of step one, in this case `$HOME\Software\control_microphone`

> Note that the $HOME var could not be resolved, which will require you to manually fill the full destination folder path.

3. Create a shortcut to ControlMic.ahk and put it in the Startup apps folder.

    * Place on the destination folder from step 1, then right click on `ControlMic.ahk` > `Show more options` > `Create shortcut`.

    * You'll have a new shortcut file in the folder. Move it to `$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

4. Make an executable file off the `miccon.ps1` PS script
    * Place on the destination folder from step 1 in a PowerShell terminal
    * Type `ps2exe .\miccon.ps1 .\miccon.exe`
    * You'll have a new executable file in the folder, keep it there.

5. Restart your machine to make all changes effective and to have the AHK script enabled.

#### Usage

The AHK script is written so that you can make use of the following key bindings:

* `AltGr` + `F10` to mute all microphones in your machine
* `AltGr` + `F11` to unmute all microphones in your machine
* `AltGr` + `F12` to toggle mute state of all microphones in your machine

> You can change this behavior by changing the Key Prefixes in your copy of the `ControlMic.ahk` file.

### 1.2 `password_generator`

This is a small script that can generate a random secure password in a PS terminal.

#### Installation

1. Copy the `password_generator` folder wherever you want.

```bash
# WSL
cp -r windows/utils/password_generator $WHOME/Software # mandatory dest. folder

# PS
xcopy windows\utils\password_generator $HOME\Software # mandatory dest. folder
```
> To learn how to set up the `WHOME` var in WSL, go to the [WSL config section](#2-wsl-config).

2. Add the destination folder to Windows' user's path environment variable
    * Open the env. variables panel by following this route: `Win + X` > `System` > `Advanced system settings` > `Environment Variables`
    * Click `Path` under _User variables for \<your user\>_ and then click __Edit__
    * Add a new entry with the destination folder of step one, in this case `$HOME\Software\password_generator`

> Note that the $HOME var could not be resolved, which will require you to manually fill the full destination folder path.

3. Install `random-password-generator` Python library.

```bash
# Type this in a PS shell
pip install random-password-generator
```

4. Restart your machine to make all changes effective.

#### Usage

Open a PowerShell terminal and type:

```bash
pwgen.ps1
# 3g9!sdYh5N0ad_2
```
> You can change the features of the password by modifying the attributes in your copy of the `pwgen.py` script.

## 2. WSL config

The config file in the `wsl` folder is meant to be appended to the .zshrc file of your WSL distribution. That way, the terminal color schema becomes more simple.

It also adds a new WHOME env var in WSL so you can easily access Windows' user's home folder by typing `cd $WHOME`. You can also type `cdw` for more simplicity.