# MEMORY.md - Long-Term Memory

## OpenClaw (Local Gateway) — Known State

- Gateway runs locally on `ws://127.0.0.1:18789` (Control UI: `http://127.0.0.1:18789/`).
- Default agent model is `zai/glm-4.7` (GLM-4.7). If the assistant self-identifies as “Claude”, treat it as a hallucination and verify via `session_status` / `openclaw models status`.
- Kimi Coding: configured as `kimi-coding/k2p5`, but the current API key may return `401` (needs refresh).

## “Hands” / Execution

- The assistant can control the computer via tools like `exec` / `browser` when running through OpenClaw.
- If it says it “has no hands”, it must explain the concrete blocker (tool unavailable, approvals required, allowlist miss) and tell the user what to change in Control UI (**Agent → Nodes → Exec approvals**).

## Memory

- Local memory search is enabled (provider `local`) and indexed from `workspace/memory/*.md`.
- Keep daily notes in `workspace/memory/YYYY-MM-DD.md` so memory search can retrieve them later.

