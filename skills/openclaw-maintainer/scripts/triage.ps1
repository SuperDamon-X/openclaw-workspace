param(
  [string]$StateDir = "C:\\Users\\Administrator\\.openclaw",
  [string]$WorkspaceRepo = "C:\\Users\\Administrator\\.openclaw\\workspace",
  [switch]$Fix = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Run([string]$cmd) {
  Write-Host "==> $cmd"
  $out = & powershell -NoProfile -ExecutionPolicy Bypass -Command $cmd 2>&1
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    Write-Host $out
    throw "Command failed ($code): $cmd"
  }
  return $out
}

if (-not (Test-Path $WorkspaceRepo)) { throw "Workspace repo missing: $WorkspaceRepo" }

Write-Host "OpenClaw version:"
try { Run "openclaw --version" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nGateway health:"
try { Run "openclaw health --timeout 8000" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nModels probe (auth/timeouts):"
try { Run "openclaw models status --probe --probe-timeout 20000 --probe-concurrency 2" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nBrowser status:"
try { Run "openclaw browser status --json" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nGit status:"
try { Run "cd $WorkspaceRepo; git status -sb" | Out-Null } catch { Write-Host $_.Exception.Message }

if (-not $Fix) { exit 0 }

Write-Host "`n=== FIX MODE ==="
Write-Host "Running: openclaw doctor --deep --repair --non-interactive"
try { Run "openclaw doctor --deep --repair --non-interactive" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nRunning: openclaw security audit --deep"
try { Run "openclaw security audit --deep" | Out-Null } catch { Write-Host $_.Exception.Message }

Write-Host "`nEnsuring headless browser CDP (profile=chrome) is running:"
try { Run "openclaw browser start --browser-profile chrome --json" | Out-Null } catch { Write-Host $_.Exception.Message }

