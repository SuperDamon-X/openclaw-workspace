param(
  [string]$StateDir = "C:\\Users\\Administrator\\.openclaw",
  [switch]$Fix = $true,
  [switch]$RestartGateway = $true,
  [switch]$EnsureBrowser = $true,
  [string]$BrowserProfile = "chrome"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Step([string]$msg) { Write-Host "`n== $msg" }

function Run([string]$cmd, [int]$timeoutSeconds = 180) {
  Step $cmd
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command ""$cmd"""
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true

  $p = [System.Diagnostics.Process]::Start($psi)
  if (-not $p.WaitForExit($timeoutSeconds * 1000)) {
    try { $p.Kill() } catch {}
    throw "Timeout running: $cmd"
  }
  $out = ($p.StandardOutput.ReadToEnd() + "`n" + $p.StandardError.ReadToEnd()).Trim()
  if ($out) { Write-Host $out }
  if ($p.ExitCode -ne 0) { throw "Command failed ($($p.ExitCode)): $cmd" }
}

if (-not $Fix) {
  Write-Host "Fix is disabled. Re-run with -Fix to apply repairs."
  exit 0
}

Step "OpenClaw doctor + security audit"
Run "cd $StateDir; openclaw doctor --deep --repair --non-interactive" 240
Run "cd $StateDir; openclaw security audit --deep" 240

if ($RestartGateway) {
  Step "Restart gateway scheduled task"
  try {
    & schtasks /end /tn "OpenClaw Gateway (Interactive)" | Out-Null
  } catch {}
  Start-Sleep -Milliseconds 800
  & schtasks /run /tn "OpenClaw Gateway (Interactive)" | Out-Null
  Write-Host "Restart requested: OpenClaw Gateway (Interactive)"
}

if ($EnsureBrowser) {
  Step "Ensure headless CDP browser is running"
  Run "cd $StateDir; openclaw browser start --browser-profile $BrowserProfile --json" 90
}

Step "Health check"
Run "cd $StateDir; openclaw health --timeout 10000" 60

