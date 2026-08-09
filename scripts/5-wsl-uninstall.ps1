# Self-elevate if needed
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$runningAsAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $runningAsAdmin) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell.exe"
  $psi.Arguments = "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Hostname `"$Hostname`" -IP `"$IP`""
  $psi.Verb = "runas"
  [System.Diagnostics.Process]::Start($psi) | Out-Null
  exit
}

wsl --unregister Debian

# Disable WSL and Virtual Machine Platform
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

wsl --uninstall

# Restart is often required after enabling features
Write-Host "Done. You may need to reboot."
