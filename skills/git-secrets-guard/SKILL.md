---
name: git-secrets-guard
description: Prevent and resolve GitHub secret-scanning “push protection” blocks (e.g. GH013 “Push cannot contain secrets”) in this workspace repo. Use when `git push` is rejected due to secrets, when large dumps like `skills/.skills_full_*` appear, or when you need a safe workflow to remove leaked keys from git history, add `.gitignore` rules, and rotate exposed credentials.
---

# Git Secrets Guard

## Workflow (report → then fix)

Goal: keep the repo pushable without ever committing secrets.

1) Scan working tree (read-only)

```powershell
cd C:\Users\Administrator\.openclaw\workspace
powershell -NoProfile -ExecutionPolicy Bypass -File .\skills\git-secrets-guard\scripts\scan.ps1
```

2) If GitHub blocks push (GH013)

Do **not** use “put token in URL”. Do **not** “unblock” unless you fully understand impact.

Preferred fix: remove offending paths from history and force-push.

Dry run (shows what would be rewritten):

```powershell
cd C:\Users\Administrator\.openclaw\workspace
powershell -NoProfile -ExecutionPolicy Bypass -File .\skills\git-secrets-guard\scripts\scrub_history.ps1 -DryRun
```

When ready (destructive; rewrites history):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\skills\git-secrets-guard\scripts\scrub_history.ps1 -RewriteHistory -ConfirmRewrite YES
git push --force-with-lease origin master
```

3) Guardrails

- Add ignore rules for dump folders (example already used): `skills/.skills_full_*/`
- Treat any detected secret as compromised: rotate/revoke it.
- Never store secrets in git; prefer `C:\Users\Administrator\.openclaw\credentials\` for local-only state.

4) Install local guardrails (recommended)

This repo is configured to use `core.hooksPath=git-hooks`. Ensure the folder exists and contains hooks:

- `C:\Users\Administrator\.openclaw\workspace\git-hooks\pre-commit`
- `C:\Users\Administrator\.openclaw\workspace\git-hooks\pre-push`

These hooks block committing/pushing `skills/.skills_full_*` and catch common secret patterns early.
