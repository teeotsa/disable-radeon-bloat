# Disable AMD Bloat without breaking the control panel

# Disable Services...
$ServiceList = @(
    'AMD Crash Defender Service' # AMD Crash Defender Service
    'AUEPLauncher'               # AMD User Experience Program Data Uploader
    'AMDRyzenMasterDriverV19'    # AMD Ryzen Master Driver
    'amdfendr'                   # AMD Crash Defender Driver
    'amdfendrmgr'                # AMD Crash Defender Manager Driver
)

Foreach ($AMD_Service in $ServiceList)
{
    $RegistryKey = "HKLM:\SYSTEM\CurrentControlSet\Services\$($AMD_Service)"
    
    If (Test-Path $RegistryKey)
    {
        Set-ItemProperty -Path $RegistryKey -Name 'Start' -Value 4 -Force -ErrorAction SilentlyContinue
    }
}

# Remove AMD User Experience Program
$Software = Get-WmiObject -ClassName 'Win32_Product' | Where-Object {$_.Name -match "AMD User Experience Program"}
If (($Software | Measure-Object).Count -gt 0)
{
    $Software.Uninstall() | Out-Null
}

# Disable Auto Updates & AMD Tweaks
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\CN" -Name 'AutoUpdate' -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\CN" -Name 'AutoDownload' -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\CN" -Name 'SystemTray' -Value 'false' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\CN" -Name 'AnimationEffect' -Value 'false' -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\CN" -Name 'AutoUpdateTriggered' -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\AMD\AIM" -Name 'LaunchBugTool' -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null

# Restart AMD Control Panel
Stop-Service -Name 'AMD External Events Utility' -Force -NoWait -ErrorAction SilentlyContinue | Out-Null
@('atieclxx', 'atiesrxx', 'RadeonSoftware') | %{ Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue | Out-Null}