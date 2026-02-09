param(
  [string[]]$TaskNames = @(
    "OpenClaw Gateway (Interactive)",
    "OpenClaw Gateway",
    "OpenClaw Gateway Watchdog",
    "OpenClaw Browser Chrome CDP",
    "OpenClaw Node"
  )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Task([string]$name) {
  Write-Host "`n== $name"
  try {
    $out = & schtasks /query /tn $name /fo LIST /v 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host "NOT FOUND"
      return
    }
    $out | Select-String -Pattern "TaskName:|Task To Run:|Run As User:|Schedule:|Status:|Last Run Time:|Next Run Time:" | ForEach-Object { $_.Line }
  } catch {
    Write-Host "ERROR: $($_.Exception.Message)"
  }
}

foreach ($t in $TaskNames) { Show-Task $t }

