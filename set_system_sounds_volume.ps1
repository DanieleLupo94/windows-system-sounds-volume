if (-not ([System.Management.Automation.PSTypeName]'SystemSoundsVolume').Type) {
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
class MMDeviceEnumeratorCOM { }

[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
    int EnumAudioEndpoints(int dataFlow, int stateMask, out IMMDeviceCollection devices);
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppDevice);
    int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IMMDevice ppDevice);
    int RegisterEndpointNotificationCallback(IntPtr pClient);
    int UnregisterEndpointNotificationCallback(IntPtr pClient);
}

[Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceCollection {
    int GetCount(out uint pcDevices);
    int Item(uint nDevice, out IMMDevice ppDevice);
}

[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
    int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface);
    int OpenPropertyStore(int stgmAccess, out IntPtr ppProperties);
    int GetId([MarshalAs(UnmanagedType.LPWStr)] out string ppstrId);
    int GetState(out int pdwState);
}

[Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionManager2 {
    int GetAudioSessionControl(ref Guid AudioSessionGuid, int StreamFlags, out IAudioSessionControl SessionControl);
    int GetSimpleAudioVolume(ref Guid AudioSessionGuid, int StreamFlags, out ISimpleAudioVolume AudioVolume);
    int GetSessionEnumerator(out IAudioSessionEnumerator SessionEnum);
    int RegisterSessionNotification(IntPtr SessionNotification);
    int UnregisterSessionNotification(IntPtr SessionNotification);
    int RegisterDuckNotification([MarshalAs(UnmanagedType.LPWStr)] string sessionID, IntPtr duckNotification);
    int UnregisterDuckNotification(IntPtr duckNotification);
}

[Guid("E2F5BB11-0570-40CA-ACDD-3AA01277DEE8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionEnumerator {
    int GetCount(out int SessionCount);
    int GetSession(int SessionIndex, out IAudioSessionControl Session);
}

[Guid("F4B1A599-7266-4319-A8CA-E70ACB11E8CD"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionControl {
    int GetState(out int pRetVal);
    int GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetDisplayName([MarshalAs(UnmanagedType.LPWStr)] string Value, ref Guid EventContext);
    int GetIconPath([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetIconPath([MarshalAs(UnmanagedType.LPWStr)] string Value, ref Guid EventContext);
    int GetGroupingParam(out Guid pRetVal);
    int SetGroupingParam(ref Guid Override, ref Guid EventContext);
    int RegisterAudioSessionNotification(IntPtr NewNotifications);
    int UnregisterAudioSessionNotification(IntPtr NewNotifications);
}

[Guid("bfb7ff88-7239-4fc9-8fa2-07c950be9c6d"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionControl2 {
    int GetState(out int pRetVal);
    int GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetDisplayName([MarshalAs(UnmanagedType.LPWStr)] string Value, ref Guid EventContext);
    int GetIconPath([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetIconPath([MarshalAs(UnmanagedType.LPWStr)] string Value, ref Guid EventContext);
    int GetGroupingParam(out Guid pRetVal);
    int SetGroupingParam(ref Guid Override, ref Guid EventContext);
    int RegisterAudioSessionNotification(IntPtr NewNotifications);
    int UnregisterAudioSessionNotification(IntPtr NewNotifications);
    int GetSessionIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int GetSessionInstanceIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int GetProcessId(out uint pRetVal);
    int IsSystemSoundsSession();
    int SetDuckingPreference(bool optOut);
}

[Guid("87CE5498-68D6-44E5-9215-6DA47EF883D8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface ISimpleAudioVolume {
    int SetMasterVolume(float fLevel, ref Guid EventContext);
    int GetMasterVolume(out float pfLevel);
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid EventContext);
    int GetMute([MarshalAs(UnmanagedType.Bool)] out bool pbMute);
}

[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
    int RegisterControlChangeNotify(IntPtr pNotify);
    int UnregisterControlChangeNotify(IntPtr pNotify);
    int GetChannelCount(out uint pnChannelCount);
    int SetMasterVolumeLevel(float fLevelDB, ref Guid pguidEventContext);
    int SetMasterVolumeLevelScalar(float fLevel, ref Guid pguidEventContext);
    int GetMasterVolumeLevel(out float pfLevelDB);
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int SetChannelVolumeLevel(uint nChannel, float fLevelDB, ref Guid pguidEventContext);
    int SetChannelVolumeLevelScalar(uint nChannel, float fLevel, ref Guid pguidEventContext);
    int GetChannelVolumeLevel(uint nChannel, out float pfLevelDB);
    int GetChannelVolumeLevelScalar(uint nChannel, out float pfLevel);
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid pguidEventContext);
    int GetMute([MarshalAs(UnmanagedType.Bool)] out bool pbMute);
    int GetVolumeStepInfo(out uint pnStep, out uint pnStepCount);
    int VolumeStepUp(ref Guid pguidEventContext);
    int VolumeStepDown(ref Guid pguidEventContext);
    int QueryHardwareSupport(out uint pdwHardwareSupportMask);
    int GetVolumeRange(out float pflMin, out float pflMax, out float pflIncrement);
}

public static class SystemSoundsVolume {
    [DllImport("winmm.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool PlaySound(string pszSound, IntPtr hmod, uint fdwSound);

    const uint SND_ALIAS = 0x00010000;
    const uint SND_SYNC = 0x0000;
    const uint SND_NODEFAULT = 0x0002;

    static bool TryFindSystemSoundsSession(IAudioSessionManager2 sessionManager, out IAudioSessionControl found) {
        IAudioSessionEnumerator sessionEnum;
        sessionManager.GetSessionEnumerator(out sessionEnum);

        int count;
        sessionEnum.GetCount(out count);

        for (int i = 0; i < count; i++) {
            IAudioSessionControl session;
            sessionEnum.GetSession(i, out session);

            var session2 = (IAudioSessionControl2) session;

            // IsSystemSoundsSession returns S_OK (0) when this is the genuine System Sounds
            // session. Its owning PID isn't reliably 0 on all Windows builds/devices, so we
            // can't use GetProcessId as the check.
            if (session2.IsSystemSoundsSession() == 0) {
                found = session;
                return true;
            }
        }
        found = null;
        return false;
    }

    public static string SetVolume(float level) {
        var enumerator = (IMMDeviceEnumerator) new MMDeviceEnumeratorCOM();

        IMMDevice device;
        enumerator.GetDefaultAudioEndpoint(0, 1, out device);

        var sessionManagerGuid = new Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F");
        object sessionManagerObj;
        device.Activate(ref sessionManagerGuid, 23, IntPtr.Zero, out sessionManagerObj);
        var sessionManager = (IAudioSessionManager2) sessionManagerObj;

        // We always mute the output device, play a trigger sound to (re)create the System Sounds
        // session, adjust its volume, then unmute — so the user never hears the trigger at full volume.
        var endpointVolumeGuid = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
        object endpointVolumeObj;
        device.Activate(ref endpointVolumeGuid, 23, IntPtr.Zero, out endpointVolumeObj);
        var endpointVolume = (IAudioEndpointVolume) endpointVolumeObj;
        var emptyGuid2 = Guid.Empty;

        IAudioSessionControl session;
        bool found;

        endpointVolume.SetMute(true, ref emptyGuid2);
        try {
            PlaySound("SystemAsterisk", IntPtr.Zero, SND_ALIAS | SND_SYNC | SND_NODEFAULT);
            found = TryFindSystemSoundsSession(sessionManager, out session);

            for (int attempt = 0; attempt < 10 && !found; attempt++) {
                System.Threading.Thread.Sleep(150);
                found = TryFindSystemSoundsSession(sessionManager, out session);
            }
        } finally {
            endpointVolume.SetMute(false, ref emptyGuid2);
        }

        if (found) {
            var volume = (ISimpleAudioVolume) session;
            var emptyGuid = Guid.Empty;
            volume.SetMasterVolume(level, ref emptyGuid);

            float current;
            volume.GetMasterVolume(out current);
            return string.Format("System Sounds volume set to {0:P0}", current);
        }

        return "WARNING: System Sounds session not found. Play any system sound and try again.";
    }
}
"@
}

$volume = if ($args.Count -gt 0) { [float]$args[0] / 100 } else { 0.10 }
$result = [SystemSoundsVolume]::SetVolume($volume)

try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null

    $toastXml = [xml] @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>System Sounds Volume</text>
            <text>$result</text>
        </binding>
    </visual>
</toast>
"@

    $xmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xmlDoc.LoadXml($toastXml.OuterXml)
    $toast = New-Object Windows.UI.Notifications.ToastNotification($xmlDoc)
    $aumid = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($aumid).Show($toast)
} catch {
    Write-Host $result
    Start-Sleep -Seconds 5
}
