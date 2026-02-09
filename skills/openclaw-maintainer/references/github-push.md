# GitHub push (stable)

## Why it fails on Windows/OpenClaw

If Git cannot prompt for credentials, pushes to `https://github.com/...` will fail with `401` and messages like:

- `fatal: could not read Username for 'https://github.com': terminal prompts disabled`
- `fatal: Cannot prompt because user interactivity has been disabled.`

## Option A (recommended): SSH deploy key (no prompts)

Create a repo-scoped SSH key and add the **public** key to GitHub as a **Deploy key** with **write** access.

This workspace includes a helper that generates the key, locks permissions, and configures the repo remote:

- `C:\Users\Administrator\.openclaw\workspace\scripts\setup_github_ssh.ps1`

Run (PowerShell):

```powershell
cd C:\Users\Administrator\.openclaw\workspace
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup_github_ssh.ps1
```

Then add the printed public key in:
Repo -> Settings -> Deploy keys -> Add deploy key -> check “Allow write access”.

## Option B: PAT over HTTPS (still non-interactive)

Use a GitHub Personal Access Token (classic or fine-grained) with repo write permission and provide it non-interactively.

Helper:

- `C:\Users\Administrator\.openclaw\workspace\scripts\push_origin.ps1`

It uses `GITHUB_TOKEN` (preferred) or `GH_TOKEN` and `GIT_ASKPASS` to avoid hangs.

## One-shot usage (PowerShell)

```powershell
cd C:\Users\Administrator\.openclaw\workspace
$env:GITHUB_TOKEN = "<YOUR_TOKEN>"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push_origin.ps1
```

Do not commit tokens to git.
