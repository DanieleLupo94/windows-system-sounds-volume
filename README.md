# Windows System Sounds Volume

Tired of Windows blasting a notification sound directly into your eardrums at full volume??? Same. So I wrote this script that sets it to a civilized 10%.

A PowerShell script to set the **System Sounds** volume on Windows 10/11 without any external dependencies.

Windows exposes System Sounds as a separate audio session in the Volume Mixer. This script uses the Windows Core Audio API (WASAPI) via inline C# to locate and adjust that session directly.

## Usage

```powershell
# Set to 10% (default)
powershell -ExecutionPolicy Bypass -File set_system_sounds_volume.ps1

# Set to a custom percentage (0–100)
powershell -ExecutionPolicy Bypass -File set_system_sounds_volume.ps1 50
```

No admin rights required.

## How it works

The script enumerates all active audio sessions on the default output device using `IAudioSessionManager2`. The System Sounds session is identified by having **PID = 0** — it is not owned by any user process. Once found, `ISimpleAudioVolume::SetMasterVolume` is called to set the level.

> **Note:** The System Sounds session only appears in the mixer after Windows has played at least one sound since boot. If the session isn't found, the script automatically plays a system sound and retries before giving up.

## Requirements

- Windows 10 or 11
- PowerShell 5.1 or later (built-in on all modern Windows)

## Building the .exe

The standalone `set_system_sounds_volume.exe` is built from the `.ps1` script using [ps2exe](https://github.com/MScholtes/PS2EXE):

```powershell
# One-time install
Install-Module -Name ps2exe -Scope CurrentUser

# Build (uses icon.ico from the repo)
Invoke-ps2exe -inputFile "set_system_sounds_volume.ps1" -outputFile "set_system_sounds_volume.exe" -iconFile "icon.ico" -noConsole:$false
```

Arguments are forwarded to the script's `$args`, so `set_system_sounds_volume.exe 20` works the same as the `.ps1` equivalent. Rebuild and commit the `.exe` whenever the `.ps1` changes.
