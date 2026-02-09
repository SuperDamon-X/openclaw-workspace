param(
  [string]$StateDir = "C:\\Users\\Administrator\\.openclaw",
  [string]$WorkspaceRepo = "C:\\Users\\Administrator\\.openclaw\\workspace",
  [int[]]$Ports = @(18790, 18793, 18801, 18789),
  [switch]$Deep = $false,
  [switch]$Json = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function TryRun([string]$label, [scriptblock]$fn) {
  try {
    $res = & $fn
    return [pscustomobject]@{ ok = $true; label = $label; output = $res }
  } catch {
    return [pscustomobject]@{ ok = $false; label = $label; error = $_.Exception.Message }
  }
}

function PortInfo([int]$port) {
  try {
    $conns = @(Get-NetTCPConnection -LocalPort $port -ErrorAction Stop)
  } catch { $conns = @() }

  if (-not $conns -or $conns.Count -eq 0) {
    return [pscustomobject]@{ port = $port; state = "free"; pid = $null; process = $null }
  }

  $owningPid = ($conns | Select-Object -First 1).OwningProcess
  $pname = $null
  try { $pname = (Get-Process -Id $owningPid -ErrorAction Stop).ProcessName } catch { $pname = "unknown" }
  return [pscustomobject]@{ port = $port; state = [string](($conns | Select-Object -First 1).State); pid = $owningPid; process = $pname }
}

$report = [ordered]@{
  timestamp = (Get-Date).ToString("s")
  machine = $env:COMPUTERNAME
  stateDir = $StateDir
  workspaceRepo = $WorkspaceRepo
  ports = @()
  checks = @()
  recommendations = @()
}

foreach ($p in $Ports) { $report.ports += (PortInfo $p) }

$report.checks += TryRun "openclaw_version" { & openclaw --version 2>&1 }
$report.checks += TryRun "openclaw_health" { & openclaw health --timeout 8000 2>&1 }
$report.checks += TryRun "browser_status" { & openclaw browser status --json 2>&1 }

if (Test-Path $WorkspaceRepo) {
  $report.checks += TryRun "git_status" { & git -C $WorkspaceRepo status -sb 2>&1 }
  $report.checks += TryRun "git_remote" { & git -C $WorkspaceRepo remote -v 2>&1 }
} else {
  $report.recommendations += "Workspace repo missing; check agents.defaults.workspace path in openclaw.json."
}

if ($Deep) {
  $report.checks += TryRun "models_probe" { & openclaw models status --probe --probe-timeout 20000 --probe-concurrency 2 2>&1 }
  $report.checks += TryRun "tasks" { & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $WorkspaceRepo 'skills\\openclaw-maintainer\\scripts\\tasks.ps1') 2>&1 }
}

# Recommendations heuristics
$gatewayPort = ($report.ports | Where-Object { $_.port -eq 18790 } | Select-Object -First 1)
if ($gatewayPort -and $gatewayPort.state -ne "free" -and $gatewayPort.process -notmatch "node") {
  $report.recommendations += "Gateway port 18790 is in use by non-node process: PID=$($gatewayPort.pid) $($gatewayPort.process). Consider freeing the port before restarting gateway."
}

$cdpPort = ($report.ports | Where-Object { $_.port -eq 18793 } | Select-Object -First 1)
if ($cdpPort -and $cdpPort.state -eq "free") {
  $report.recommendations += "Browser CDP port 18793 is free. Start headless browser: openclaw browser start --browser-profile chrome --json"
}

$health = ($report.checks | Where-Object { $_.label -eq "openclaw_health" } | Select-Object -First 1)
if ($health -and -not $health.ok) {
  $report.recommendations += "OpenClaw health check failed. Start with: openclaw doctor --deep --repair --non-interactive, then re-run openclaw health."
}

if ($Json) {
  $report | ConvertTo-Json -Depth 6
  exit 0
}

Write-Host "OpenClaw Maintainer Report ($($report.timestamp))"
Write-Host "StateDir: $StateDir"
Write-Host "Workspace: $WorkspaceRepo"

Write-Host "`nPorts:"
$report.ports | Format-Table -AutoSize

Write-Host "`nChecks:"
foreach ($c in $report.checks) {
  if ($c.ok) {
    Write-Host "`n- $($c.label): ok"
    $txt = ($c.output | Out-String).Trim()
    if ($txt) { Write-Host $txt }
  } else {
    Write-Host "`n- $($c.label): FAIL: $($c.error)"
  }
}

Write-Host "`nRecommendations:"
if ($report.recommendations.Count -eq 0) {
  Write-Host "- (none)"
} else {
  $report.recommendations | ForEach-Object { "- $_" }
}
