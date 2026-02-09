# Common failure scenarios (Windows)

Use this as a **menu of hypotheses** after running `scripts/report.ps1` / `scripts/triage.ps1`.

## Gateway “Connection error” / frequent watchdog restarts

Typical causes:
- Gateway process crashed or is wedged (health endpoint not responding).
- Port conflict: `18790` is occupied by another process.
- Scheduled task points to an old `openclaw` install path.
- Proxy/network instability causes downstream timeouts that look like “disconnect”.

Suggested flow (report → targeted fix):
1) `scripts/ports.ps1` (identify owner of `18790/18793/18801/18789`)
2) `scripts/tasks.ps1` (verify task targets + user)
3) `openclaw doctor --deep --repair --non-interactive`
4) If needed, `scripts/repair.ps1 -Fix -ConfirmFix YES`

## Port occupied (18790/18793/18801/18789)

Typical causes:
- Stale Node/Edge process not exited.
- Multiple OpenClaw installs/old scheduled tasks.

Suggested flow:
1) `scripts/ports.ps1`
2) If the owning process is clearly stale, `scripts/ports.ps1 -Fix`
3) Re-run `scripts/report.ps1`

## Model errors: 401 / 403 / timeout

Interpretation:
- `401` credential invalid/expired → rotate or remove from fallbacks.
- `403 access_denied` permission issue → change account/plan, or stop probing that model.
- `timeout` network/proxy/DNS/TLS problem → verify proxy service and try again with higher timeout.

Use:
- `openclaw models status --probe --probe-timeout 20000`

## Browser CDP not ready

Typical causes:
- `attachOnly=true` and requested profile isn’t running.
- CDP port occupied or browser crashed.

Suggested flow:
1) `openclaw browser status --json`
2) Start preferred profile: `openclaw browser start --browser-profile chrome --json`
3) If CDP port occupied, use `scripts/ports.ps1` to identify owner.

## Git push fails

Typical causes:
- Missing auth (SSH key not added / PAT not provided).
- GitHub secret scanning blocks (GH013).

Suggested flow:
1) Prefer SSH deploy key (see `references/github-push.md`).
2) If GH013, use `git-secrets-guard` skill to scan + scrub history.

