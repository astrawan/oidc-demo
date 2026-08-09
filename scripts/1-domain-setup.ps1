$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

function Add-HostsEntryIfMissing {
  param(
    [Parameter(Mandatory)] [string] $Path,
    [Parameter(Mandatory)] [string] $Hostname,
    [Parameter(Mandatory)] [string] $IP
  )

  $line        = "$IP $Hostname"

  $escapedHost = [regex]::Escape($Hostname)
  $escapedIP   = [regex]::Escape($IP)

  $pattern     = "^\s*$escapedIP\s+$escapedHost(\s*($|#).*)?$"

  if (-not (Test-Path $Path)) {
    throw "Hosts file not found: $Path"
  }

  $exists = Select-String -Path $Path -Pattern $pattern -SimpleMatch:$false -Quiet
  if (-not $exists) {
    Add-Content -Path $Path -Value $line
  }
}

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

# Elevated: perform the add
Add-HostsEntryIfMissing -Path $hostsPath -Hostname "idm.demo.local" -IP "127.0.0.1"
Add-HostsEntryIfMissing -Path $hostsPath -Hostname "app.demo.local" -IP "127.0.0.1"

