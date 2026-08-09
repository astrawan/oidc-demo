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

# Enable WSL and Virtual Machine Platform
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set WSL default version to 2
wsl --set-default-version 2

# Restart is often required after enabling features
Write-Host "Done. You may need to reboot."

