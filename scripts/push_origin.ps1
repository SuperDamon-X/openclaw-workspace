Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [string]$RepoPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$Remote = "origin",
  [string]$Branch = "master"
)

function Assert-GitRepo([string]$Path) {
  if (-not (Test-Path $Path)) { throw "RepoPath not found: $Path" }
  $null = git -C $Path rev-parse --is-inside-work-tree 2>$null
  if ($LASTEXITCODE -ne 0) { throw "Not a git repo: $Path" }
}

function Assert-CleanWorktree([string]$Path) {
  $status = git -C $Path status --porcelain
  if ($status) {
    throw "Working tree not clean. Commit/stash changes first.`n$status"
  }
}

function New-AskPassScript([string]$Token) {
  if (-not $Token) { throw "Missing token." }
  $tmp = Join-Path $env:TEMP ("git-askpass-" + [Guid]::NewGuid().ToString("N") + ".cmd")

  @"
@echo off
setlocal
set "prompt=%*"
echo %prompt% | findstr /i "username" >nul && (echo x-access-token & exit /b 0)
echo %prompt% | findstr /i "password" >nul && (echo %GITHUB_TOKEN% & exit /b 0)
echo %GITHUB_TOKEN%
"@ | Out-File -FilePath $tmp -Encoding ASCII -NoNewline

  return $tmp
}

Assert-GitRepo $RepoPath
Assert-CleanWorktree $RepoPath

$token = $env:GITHUB_TOKEN
if (-not $token) { $token = $env:GH_TOKEN }

if (-not $token) {
  Write-Host "Missing auth token. Set env var GITHUB_TOKEN (recommended) or GH_TOKEN, then re-run." -ForegroundColor Yellow
  Write-Host "Example (PowerShell):" -ForegroundColor Yellow
  Write-Host "  `$env:GITHUB_TOKEN = '<github_pat_or_fine_grained_token_with_repo_access>'" -ForegroundColor Yellow
  exit 2
}

$askpass = $null
$hadGithubTokenEnv = [bool]$env:GITHUB_TOKEN
$originalGithubToken = $env:GITHUB_TOKEN
try {
  if (-not $hadGithubTokenEnv) { $env:GITHUB_TOKEN = $token }
  $askpass = New-AskPassScript $token
  $env:GIT_ASKPASS = $askpass
  $env:GIT_TERMINAL_PROMPT = "0"
  $env:GCM_INTERACTIVE = "Never"

  # Avoid hanging on interactive credential helpers. We supply credentials via GIT_ASKPASS.
  git -C $RepoPath -c credential.helper= push $Remote "HEAD:$Branch"
} finally {
  if ($askpass -and (Test-Path $askpass)) { cmd /c del /f /q "$askpass" | Out-Null }
  Remove-Item Env:GIT_ASKPASS -ErrorAction SilentlyContinue
  Remove-Item Env:GIT_TERMINAL_PROMPT -ErrorAction SilentlyContinue
  Remove-Item Env:GCM_INTERACTIVE -ErrorAction SilentlyContinue
  if (-not $hadGithubTokenEnv) {
    if ($originalGithubToken) { $env:GITHUB_TOKEN = $originalGithubToken } else { Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue }
  }
}
