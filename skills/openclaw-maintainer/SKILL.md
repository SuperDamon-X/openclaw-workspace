---
name: openclaw-maintainer
description: Diagnose and self-heal an OpenClaw installation on Windows (gateway/service flapping, Feishu disconnects, browser CDP/headless issues, model auth 401/403/timeouts, Git conflicts/submodules, and GitHub push failures). Use when OpenClaw shows “Connection error”, frequent watchdog restarts, tool/API 401/404/429, “Invalid input[*].name … ^[a-zA-Z0-9_-]+$”, or when `git push` hangs/fails in `C:\Users\Administrator\.openclaw\workspace`.
---

# OpenClaw Maintainer

## Workflow (fast)

Goal: get back to a stable, repeatable “green” state (gateway ok, Feishu ok, models usable, browser CDP ready, git clean).

1) Collect facts (read-only)

Run the bundled triage script (read-only by default):

```powershell
cd C:\Users\Administrator\.openclaw\workspace
powershell -NoProfile -ExecutionPolicy Bypass -File .\skills\openclaw-maintainer\scripts\triage.ps1
```

2) If gateway/service is flapping or “Connection error”

Run OpenClaw repair (safe defaults, non-interactive):

```powershell
cd C:\Users\Administrator\.openclaw
openclaw doctor --deep --repair --non-interactive
openclaw security audit --deep
```

If the watchdog keeps restarting, check `C:\Users\Administrator\.openclaw\watchdog.log` and confirm the scheduled task `OpenClaw Gateway (Interactive)` exists and points at `C:\Users\Administrator\.openclaw\gateway.cmd`.

3) If browser automation is unstable

This environment is configured for **chrome profile + headless**, but Chrome may be missing; OpenClaw will auto-detect Edge and still provide CDP.

Verify and start CDP:

```powershell
cd C:\Users\Administrator\.openclaw
openclaw browser status --json
openclaw browser start --browser-profile chrome --json
```

If `attachOnly=true`, starting a non-running profile will fail. Prefer `browser-profile chrome` (CDP `18793`) unless you explicitly run the relay/extension profile.

4) If models show 401/403/timeouts (API conflicts)

Probe providers and interpret:

```powershell
cd C:\Users\Administrator\.openclaw
openclaw models status --probe --probe-timeout 20000
```

Common meanings:
- `kimi-coding/*` `HTTP 401` => key expired/invalid; remove from fallbacks or rotate key.
- `anthropic/*` `HTTP 403 access_denied` => account/token lacks permission.
- `openai/*` `timeout` => network/proxy issue or outbound blocked; verify proxy and try again with higher timeout.

5) If `git push` cannot be done by OpenClaw

Root cause is almost always **missing non-interactive GitHub credentials**.

Use `C:\Users\Administrator\.openclaw\workspace\scripts\push_origin.ps1` with a PAT via `GITHUB_TOKEN`/`GH_TOKEN`.

See: `references/github-push.md`.

## Guardrails (security)

- Never paste/store tokens in git.
- Prefer “read-only triage” first; only run “fix mode” when the failure mode is clear.
- For any operation that edits `openclaw.json` / scheduled tasks / services, keep a backup and report exactly what changed.
