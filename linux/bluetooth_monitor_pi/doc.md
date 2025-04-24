# Bluetooth Monitor Service for Raspberry Pi

## Use case

I created this systemd service to use my Raspberry Pi as an on-demand passive sound device connected to my room's Bluetooth speaker.

Once every blue moon, a random device establishes a connection to my room's speakers. My speakers support a double connection,
which means that even if I have my phone connected to them, an external device can yet connect and start playing sound.

I realised then that I could use my Raspberry Pi to occupy the unused slot so that new devices could not connect to my speakers.

But if I don't have a device connected that plays sound, that still leaves an empty slot for an intruder to hijack, right?

Well, that's why I created this piece of software, so that I can have a second on-demand device whose connection to my speakers I can monitor and control.

## How it works

- There's an LED that shows the status of the connection to the speakers
- There's a button that toggles the connection to the speakers

## Installation

```bash
# Arguments are optional, but if specified, 
# they should be passed in the following order
bash install.sh [GPIO_LED_PIN] [GPIO_BUTTON_PIN] [SPEAKERS_MAC_ADDRESS]
```