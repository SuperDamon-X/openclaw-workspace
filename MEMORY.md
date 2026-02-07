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

## 2026-02-08 优化升级

参考 [OpenClaw + VPS + 飞书 + Obsidian 工作流](https://mp.weixin.qq.com/s/gCfGfcS5RZHAysoDVVrvtg) 进行了以下优化：

### 目录结构优化
- 新增 `assets/` - 素材库
- 新增 `docs/` - 文档
- 新增 `scripts/` - 自定义脚本
- 新增 `assets/素材/` - 网页采集内容存储

### Git 版本控制
- 配置 Git 用户信息：SuperDamon <superdamon@openclaw.ai>
- 初始化 Git 仓库并完成首次提交
- 添加 `.gitignore` 排除不必要文件（node_modules、临时文件等）
- 已提交：初始化 workspace + link-collector skill

### Skills 优化
- 创建 `link-collector` skill：网页内容采集工具
- 支持单个/批量采集网页
- 自动保存为 Markdown 格式到素材库
- 采集完成后自动提交到 Git

### 待优化项目
- 启用更多 hooks：command-logger、session-memory（当前只有 boot-md）
- 配置 GitHub SSH 密钥实现远程备份
- 开发更多实用 skills

