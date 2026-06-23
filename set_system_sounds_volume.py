"""Set the Windows System Sounds volume.

Usage:
    set_system_sounds_volume.py [percent]

If no percentage is given, defaults to 10%.
"""

import ctypes
import sys
import time
import winsound

from comtypes import CLSCTX_ALL
from pycaw.api.endpointvolume import IAudioEndpointVolume
from pycaw.utils import AudioUtilities

RETRY_ATTEMPTS = 10
RETRY_DELAY_SECONDS = 0.15


def find_system_sounds_session():
    for session in AudioUtilities.GetAllSessions():
        if session._ctl.IsSystemSoundsSession() == 0:
            return session
    return None


def set_volume(level: float) -> str:
    speakers = AudioUtilities.GetSpeakers()
    endpoint_volume = speakers._dev.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
    endpoint_volume = endpoint_volume.QueryInterface(IAudioEndpointVolume)

    # We always mute the output device, play a trigger sound to (re)create the System Sounds
    # session, adjust its volume, then unmute -- so the user never hears the trigger at full volume.
    endpoint_volume.SetMute(True, None)
    try:
        winsound.PlaySound("SystemAsterisk", winsound.SND_ALIAS | winsound.SND_NODEFAULT)

        session = find_system_sounds_session()
        for _ in range(RETRY_ATTEMPTS):
            if session is not None:
                break
            time.sleep(RETRY_DELAY_SECONDS)
            session = find_system_sounds_session()
    finally:
        endpoint_volume.SetMute(False, None)

    if session is None:
        return "WARNING: System Sounds session not found. Play any system sound and try again."

    volume = session.SimpleAudioVolume
    volume.SetMasterVolume(level, None)
    return f"System Sounds volume set to {volume.GetMasterVolume():.0%}"


def show_toast(message: str) -> None:
    try:
        from windows_toasts import Toast, WindowsToaster

        toaster = WindowsToaster("System Sounds Volume")
        toast = Toast()
        toast.text_fields = ["System Sounds Volume", message]
        toaster.show_toast(toast)
    except Exception:
        print(message)


def main() -> None:
    percent = float(sys.argv[1]) if len(sys.argv) > 1 else 10.0
    result = set_volume(percent / 100)
    show_toast(result)


if __name__ == "__main__":
    main()
