param(
  [string]$RepoPath = "C:\\Users\\Administrator\\.openclaw\\workspace",
  [string[]]$DenyPathPrefixes = @("skills/.skills_full_"),
  [int]$MaxFindings = 50
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $RepoPath)) { throw "Repo not found: $RepoPath" }
if (-not (Get-Command rg -ErrorAction SilentlyContinue)) { throw "ripgrep (rg) not found; install rg or adjust this script." }

Write-Host "Repo: $RepoPath"

Write-Host "`n[1/2] Denylisted path prefix scan"
$badPaths = @()
Get-ChildItem -LiteralPath $RepoPath -Recurse -Force -File | ForEach-Object {
  $rel = $_.FullName.Substring($RepoPath.Length).TrimStart('\', '/').Replace('\\', '/')
  foreach ($prefix in $DenyPathPrefixes) {
    if ($rel.StartsWith($prefix)) { $badPaths += $rel; break }
  }
}

if ($badPaths.Count -gt 0) {
  Write-Host "Found suspicious paths (should be ignored / not committed):"
  $badPaths | Select-Object -First $MaxFindings | ForEach-Object { " - $_" }
} else {
  Write-Host "OK: no denylisted dump paths found."
}

Write-Host "`n[2/2] Quick regex scan (best-effort; may false-positive)"
$patterns = @(
  # Stripe (common)
  'sk_live_[0-9a-zA-Z]{20,}',
  # Google API key (common)
  'AIza[0-9A-Za-z\-_]{20,}',
  # Private keys
  '-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----',
  # OAuth-ish markers (keep regex simple to avoid parser edge cases)
  'client_secret.{0,80}',
  'refresh_token.{0,120}'
)

$hits = 0
foreach ($pat in $patterns) {
  Write-Host "`nPattern: $pat"
  $out = $null
  $code = 0
  try {
    $out = & rg -n --hidden --no-mmap -S `
      --glob "!node_modules/**" `
      --glob "!skills/git-secrets-guard/**" `
      -e $pat -- $RepoPath 2>$null
    $code = $LASTEXITCODE
  } catch {
    $code = 2
    $out = $null
  }

  if ($code -eq 0 -and $out) {
    $lines = @($out)
    $hits += $lines.Count
    $lines | Select-Object -First ([Math]::Min($MaxFindings, $lines.Count)) | ForEach-Object { "  $_" }
    continue
  }

  if ($code -ne 0 -and $code -ne 1) {
    Write-Host "  (rg error; skipped)"
    continue
  }

  Write-Host "  (none)"
}

Write-Host "`nDone. Total findings (approx): $hits"
