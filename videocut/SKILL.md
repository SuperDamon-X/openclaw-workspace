---
name: videocut
description: AI驱动的口播视频剪辑工具，自动识别静音、口误、重复、卡顿等问题，生成审核网页，人工确认后自动剪辑。
---

# 视频剪辑 (Videocut) - OpenClaw 版本

> AI驱动的口播视频剪辑，自动识别静音、口误、重复、卡顿等问题

## 核心功能

| 功能 | 说明 |
|------|------|
| **语义理解** | AI 逐句分析，识别重说/纠正/卡顿 |
| **静音检测** | >0.3s 自动标记，可调阈值 |
| **重复句检测** | 相邻句开头≥5字相同 → 删前保后 |
| **口误识别** | 语气词、卡顿词、句内重复等 |
| **审核网页** | 可视化确认，支持播放、勾选 |
| **一键剪辑** | FFmpeg 精确剪辑，保留片段拼接 |

## 快速开始

### 1. 安装环境

需要安装以下工具：

- **FFmpeg** - 视频处理
  - Windows: 从 https://ffmpeg.org/download.html 下载
  - 解压后添加到系统 PATH

- **Node.js** - 运行脚本（电脑已安装 v24.13.0）

### 2. 配置火山引擎 API Key

访问 https://console.volcengine.com/speech/new/experience/asr

1. 注册火山引擎账号
2. 开通语音识别服务
3. 获取 API Key

创建配置文件：

```bash
# 在 workspace/videocut 目录创建 .env 文件
echo VOLCENGINE_API_KEY=your_api_key_here > C:\Users\Administrator\.openclaw\workspace\videocut\.env
```

### 3. 使用方法

```
用户: 帮我剪这个口播视频: C:\path\to\video.mp4
用户: 处理视频，识别口误
```

## 使用流程

```
1. 提取音频 → 上传云端
2. 火山引擎转录 → 字级别时间戳
3. AI 审核：静音/口误/重复/语气词
4. 生成审核网页 → 浏览器打开
5. 人工确认 → 点击「执行剪辑」
6. FFmpeg 自动剪辑 → 输出视频
```

## 输出目录结构

```
videocut/
├── output/
│   └── YYYY-MM-DD_视频名/
│       ├── 剪口播/
│       │   ├── 1_转录/
│       │   │   ├── audio.mp3
│       │   │   ├── volcengine_result.json
│       │   │   └── subtitles_words.json
│       │   ├── 2_分析/
│       │   │   ├── readable.txt
│       │   │   ├── auto_selected.json
│       │   │   └── 口误分析.md
│       │   └── 3_审核/
│       │       └── review.html
│       └── 剪辑后/
│           └── video_cut.mp4
```

## 使用示例

### 剪辑一个视频

```
用户: 剪这个视频: C:\Users\Videos\test.mp4
```

### 只生成字幕

```
用户: 生成字幕: C:\Users\Videos\test.mp4
```

### 查看删除规则

查看 `用户习惯/` 目录下的规则文件，可以自定义：
- 1-核心原则.md - 删前保后
- 2-语气词检测.md - 嗯啊呃
- 3-静音段处理.md - >0.3s 删除
- 4-重复句检测.md - 相邻句开头相同
- 5-卡顿词.md - 那个那个、就是就是
- 6-句内重复检测.md - A+中间+A 模式
- 7-连续语气词.md - 嗯啊、啊呃
- 8-重说纠正.md - 部分重复、否定纠正
- 9-研究用.md - 其他研究

## 技术架构

```
┌──────────────────┐     ┌──────────────────┐
│   火山引擎 ASR   │────▶│  字级别时间戳    │
│  （云端转录）    │     │  subtitles.json  │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  ▼
┌──────────────────┐     ┌──────────────────┐
│   AI (OpenClaw)  │────▶│   AI 审核结果    │
│  （语义分析）    │     │  auto_selected   │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  ▼
┌──────────────────┐     ┌──────────────────┐
│   审核网页       │────▶│   最终删除列表   │
│  （人工确认）    │     │  delete_segments │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  ▼
┌──────────────────┐     ┌──────────────────┐
│     FFmpeg       │────▶│   剪辑后视频     │
│  filter_complex  │     │   xxx_cut.mp4    │
└──────────────────┘     └──────────────────┘
```

## 常见问题

### Q: 火山引擎转录超时？
上传音频到公网服务（脚本使用 uguu.se）

### Q: 审核网页打不开？
检查端口 8899 是否被占用

### Q: 剪辑后音画不同步？
使用 `filter_complex + trim` 而非 `concat demuxer`，脚本已处理

### Q: 如何添加自定义词典？
编辑 `字幕/词典.txt`，每行一个词：
```
Claude Code
MCP
API
```

## 与原版区别

| 项目 | Claude Code 版本 | OpenClaw 版本 |
|------|------------------|---------------|
| 系统 | macOS (brew) | Windows |
| 脚本语言 | bash | PowerShell/bat |
| 技能目录 | `~/.claude/skills/` | `workspace/videocut/` |
| 触发方式 | `/videocut:剪口播` | 自然语言指令 |
| AI 分析 | Claude Code | OpenClaw |

## 文件说明

- `scripts/transcribe.ps1` - 火山引擎转录（Windows PowerShell）
- `scripts/generate_review.js` - 生成审核网页
- `scripts/review_server.js` - 审核网页服务器
- `scripts/cut_video.ps1` - FFmpeg 剪辑（Windows PowerShell）
- `scripts/generate_subtitles.js` - 生成字幕
- `scripts/subtitle_server.js` - 字幕预览服务器
- `用户习惯/` - 删除规则（可自定义）
- `字幕/词典.txt` - 自定义专业术语词典

## License

MIT
