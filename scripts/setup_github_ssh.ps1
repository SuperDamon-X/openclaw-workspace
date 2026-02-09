param(
  [string]$RepoPath = "C:\\Users\\Administrator\\.openclaw\\workspace",
  [string]$KeyDir = "C:\\Users\\Administrator\\.openclaw\\credentials\\github",
  [string]$KeyName = "openclaw-workspace_ed25519",
  [string]$Remote = "origin",
  [string]$RemoteSshUrl = "git@github.com:SuperDamon-X/openclaw-workspace.git"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step([string]$msg) { Write-Host "`n== $msg" }

if (-not (Test-Path $RepoPath)) { throw "RepoPath not found: $RepoPath" }

$computer = $env:COMPUTERNAME
$keyPath = Join-Path $KeyDir $KeyName
$pubPath = "$keyPath.pub"

Write-Step "Prepare key directory"
New-Item -ItemType Directory -Force -Path $KeyDir | Out-Null
try {
  icacls $KeyDir /inheritance:r /grant:r "$computer\\Administrator:(OI)(CI)F" /grant:r "SYSTEM:(OI)(CI)F" | Out-Null
} catch {}

Write-Step "Generate SSH key (no passphrase) if missing"
if (-not (Test-Path $keyPath) -or -not (Test-Path $pubPath)) {
  if (Test-Path $keyPath) { cmd /c del /f /q "$keyPath" | Out-Null }
  if (Test-Path $pubPath) { cmd /c del /f /q "$pubPath" | Out-Null }

  # Windows PowerShell drops empty-string args for native commands; `--%` preserves `-N ""`.
  ssh-keygen --% -t ed25519 -C openclaw-workspace@HOST -f C:\Users\Administrator\.openclaw\credentials\github\openclaw-workspace_ed25519 -N ""
}

Write-Step "Lock down key permissions"
try {
  icacls $keyPath /inheritance:r /grant:r "$computer\\Administrator:F" /grant:r "SYSTEM:F" | Out-Null
  icacls $pubPath /inheritance:r /grant:r "$computer\\Administrator:F" /grant:r "SYSTEM:F" | Out-Null
} catch {}

Write-Step "Configure repo to use SSH + this key"
git -C $RepoPath remote set-url $Remote $RemoteSshUrl
git -C $RepoPath remote set-url --push $Remote $RemoteSshUrl
git -C $RepoPath config --local core.sshCommand "ssh -i C:/Users/Administrator/.openclaw/credentials/github/openclaw-workspace_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

Write-Step "Public key (add to GitHub as a Deploy Key with write access)"
Get-Content $pubPath

Write-Host @"

Next:
1) Open the repo settings: SuperDamon-X/openclaw-workspace -> Settings -> Deploy keys
2) Add deploy key, paste the public key above
3) Check: "Allow write access"

Verify after adding:
  ssh -i $keyPath -o IdentitiesOnly=yes -T git@github.com
  cd $RepoPath
  git ls-remote $Remote
  git push $Remote master
"@

