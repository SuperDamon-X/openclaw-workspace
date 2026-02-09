param(
  [string]$RepoPath = "C:\\Users\\Administrator\\.openclaw\\workspace",
  [string[]]$RemovePaths = @("skills/.skills_full_20260204-145848"),
  [switch]$DryRun = $true,
  [switch]$RewriteHistory = $false,
  [ValidateSet("YES")]
  [string]$ConfirmRewrite
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $RepoPath)) { throw "Repo not found: $RepoPath" }

Write-Host "Repo: $RepoPath"
Write-Host "Paths to remove from history:"
$RemovePaths | ForEach-Object { " - $_" }

if ($DryRun -or -not $RewriteHistory) {
  Write-Host "`nDry run only. This script will not rewrite history unless you pass:"
  Write-Host "  -RewriteHistory -ConfirmRewrite YES"
  exit 0
}

if ($ConfirmRewrite -ne "YES") { throw "Missing -ConfirmRewrite YES (required)." }

Write-Host "`nRewriting history (destructive)..."
foreach ($p in $RemovePaths) {
  $filter = "git rm -r --cached --ignore-unmatch $p"
  git -C $RepoPath filter-branch --force --index-filter $filter --prune-empty --tag-name-filter cat -- --all
}

Write-Host "`nFollow-ups:"
Write-Host " - Add/verify .gitignore rules to prevent re-adding dumps."
Write-Host " - Rotate any exposed keys."
Write-Host " - Push with: git push --force-with-lease origin master"

