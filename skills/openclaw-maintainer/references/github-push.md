# GitHub push (non-interactive)

## Why it fails

If Git cannot prompt for credentials, pushes to `https://github.com/...` will fail with `401` and messages like:

- `fatal: could not read Username for 'https://github.com': terminal prompts disabled`
- `fatal: Cannot prompt because user interactivity has been disabled.`

## Stable fix

Use a GitHub Personal Access Token (classic or fine-grained) with repo write permission and provide it non-interactively.

This workspace includes a helper: `C:\Users\Administrator\.openclaw\workspace\scripts\push_origin.ps1`

It uses `GITHUB_TOKEN` (preferred) or `GH_TOKEN` and `GIT_ASKPASS` to avoid hangs.

## One-shot usage (PowerShell)

```powershell
cd C:\Users\Administrator\.openclaw\workspace
$env:GITHUB_TOKEN = "<YOUR_TOKEN>"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push_origin.ps1
```

Do not commit tokens to git.

