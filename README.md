# Windows System Sounds Volume

Tired of Windows blasting a notification sound directly into your eardrums at full volume??? Same. So I wrote this script that sets it to a civilized 10%.

A Python script to set the **System Sounds** volume on Windows 10/11.

Windows exposes System Sounds as a separate audio session in the Volume Mixer. This script uses the Windows Core Audio API (WASAPI), via [pycaw](https://github.com/AndreMiras/pycaw), to locate and adjust that session directly.

## Usage

```powershell
# Set to 10% (default)
python set_system_sounds_volume.py

# Set to a custom percentage (0–100)
python set_system_sounds_volume.py 50
```

No admin rights required. Result is reported via a Windows toast notification.

## How it works

The script enumerates all active audio sessions on the default output device using `IAudioSessionManager2`. The System Sounds session is identified via `IAudioSessionControl2::IsSystemSoundsSession()` (its owning PID isn't reliably 0 across Windows builds/devices, so that can't be used as the check). Once found, `ISimpleAudioVolume::SetMasterVolume` is called to set the level.

The System Sounds session only appears in the mixer after Windows has played at least one sound since boot. The script always mutes the output device, plays a trigger sound to (re)create the session, adjusts its volume, then unmutes — so the user never hears the trigger sound at full volume, and the session is reliably found even right after a reboot or an output device switch.

## Requirements

- Windows 10 or 11
- Python 3.9+

## Setup

```powershell
python -m venv .venv
.venv\Scripts\pip install -r requirements.txt
```

## Building the .exe

The standalone `set_system_sounds_volume.exe` is built with [PyInstaller](https://pyinstaller.org/):

```powershell
.venv\Scripts\pip install pyinstaller
.venv\Scripts\pyinstaller --onefile --noconsole --icon icon.ico --name set_system_sounds_volume set_system_sounds_volume.py
copy dist\set_system_sounds_volume.exe .
```

Arguments are forwarded as-is, so `set_system_sounds_volume.exe 20` works the same as the script. Rebuild and commit the `.exe` whenever `set_system_sounds_volume.py` changes.
