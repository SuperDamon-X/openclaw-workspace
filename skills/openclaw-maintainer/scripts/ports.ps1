param(
  [int[]]$Ports = @(18790, 18793, 18801),
  [switch]$Fix = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Describe-Port([int]$port) {
  $conns = @()
  try { $conns = @(Get-NetTCPConnection -LocalPort $port -ErrorAction Stop) } catch { $conns = @() }
  if (-not $conns -or $conns.Count -eq 0) {
    [pscustomobject]@{ Port = $port; State = "free"; OwningProcess = $null; ProcessName = $null }
    return
  }
  $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($pid in $pids) {
    $pname = $null
    try { $pname = (Get-Process -Id $pid -ErrorAction Stop).ProcessName } catch { $pname = "unknown" }
    [pscustomobject]@{ Port = $port; State = ($conns | Select-Object -First 1).State; OwningProcess = $pid; ProcessName = $pname }
  }
}

$report = @()
foreach ($p in $Ports) { $report += Describe-Port $p }
$report | Sort-Object Port, OwningProcess | Format-Table -AutoSize

if (-not $Fix) {
  Write-Host "`nFix mode is off. Re-run with -Fix to attempt to free ports."
  exit 0
}

$toKill = $report | Where-Object { $_.State -ne "free" -and $_.OwningProcess } | Select-Object -ExpandProperty OwningProcess -Unique
if (-not $toKill -or $toKill.Count -eq 0) {
  Write-Host "No processes found to terminate."
  exit 0
}

Write-Host "`nAttempting to terminate processes holding these ports: $($Ports -join ', ')"
foreach ($pid in $toKill) {
  try {
    $p = Get-Process -Id $pid -ErrorAction Stop
    Write-Host "Stopping PID=$pid ($($p.ProcessName))"
    Stop-Process -Id $pid -Force -ErrorAction Stop
  } catch {
    Write-Host "Failed to stop PID=$pid: $($_.Exception.Message)"
  }
}

