# 视频剪辑 (Videocut) - OpenClaw 版本

> AI驱动的口播视频剪辑工具，自动识别静音、口误、重复、卡顿等问题

## 功能特点

✨ **智能识别**：AI 逐句分析，识别重说、纠正、卡顿
🔇 **静音检测**：>0.3s 自动标记，可调阈值
🔁 **重复句检测**：相邻句开头≥5字相同 → 删前保后
📝 **口误识别**：语气词、卡顿词、句内重复等
👀 **审核网页**：可视化确认，支持播放、勾选
✂️ **一键剪辑**：FFmpeg 精确剪辑，保留片段拼接

## 安装

### 1. 安装 FFmpeg

从 https://ffmpeg.org/download.html 下载 Windows 版本

解压后，将 `bin` 目录添加到系统 PATH 环境变量

验证安装：
```bash
ffmpeg -version
```

### 2. 配置火山引擎 API Key

1. 访问 https://console.volcengine.com/speech/new/experience/asr
2. 注册账号并开通语音识别服务
3. 获取 API Key

创建配置文件：
```bash
echo VOLCENGINE_API_KEY=your_api_key_here > C:\Users\Administrator\.openclaw\workspace\videocut\.env
```

## 使用方法

### 剪辑视频

告诉 OpenClaw：
```
帮我剪这个视频: C:\path\to\video.mp4
```

AI 会自动：
1. 提取音频并上传云端
2. 调用火山引擎转录
3. 分析静音、口误、重复等问题
4. 生成审核网页
5. 你在网页中确认后，自动剪辑

### 生成字幕

```
生成字幕: C:\path\to\video.mp4
```

## 目录结构

```
videocut/
├── SKILL.md                      # 技能文档
├── README.md                     # 本文件
├── .env                          # API 配置（需创建）
├── scripts/
│   ├── transcribe.ps1            # 火山引擎转录
│   ├── generate_subtitles.js     # 生成字幕
│   ├── generate_review.js        # 生成审核网页
│   ├── review_server.js          # 审核网页服务器
│   ├── cut_video.ps1             # FFmpeg 剪辑
│   └── subtitle_server.js        # 字幕预览服务器
├── 用户习惯/                     # 删除规则
│   ├── 1-核心原则.md             # 删前保后
│   ├── 2-语气词检测.md           # 嗯啊呃
│   ├── 3-静音段处理.md           # >0.3s 删除
│   ├── 4-重复句检测.md           # 相邻句开头相同
│   ├── 5-卡顿词.md               # 那个那个、就是就是
│   ├── 6-句内重复检测.md         # A+中间+A 模式
│   ├── 7-连续语气词.md           # 嗯啊、啊呃
│   ├── 8-重说纠正.md             # 部分重复、否定纠正
│   └── 9-研究用.md               # 其他研究
└── 字幕/
    └── 词典.txt                  # 自定义专业术语词典
```

## 输出示例

```
output/
└── 2026-01-31_test_video/
    ├── 剪口播/
    │   ├── 1_转录/
    │   │   ├── audio.mp3
    │   │   ├── volcengine_result.json
    │   │   └── subtitles_words.json
    │   ├── 2_分析/
    │   │   ├── readable.txt
    │   │   ├── auto_selected.json
    │   │   └── 口误分析.md
    │   └── 3_审核/
    │       └── review.html
    └── 剪辑后/
        └── test_video_cut.mp4
```

## 常见问题

### Q: FFmpeg 命令找不到？

确保已将 FFmpeg 的 `bin` 目录添加到系统 PATH

### Q: 火山引擎 API Key 在哪获取？

访问 https://console.volcengine.com/speech/new/experience/asr

### Q: 审核网页打不开？

检查端口 8899 是否被占用

### Q: 如何添加自定义词典？

编辑 `字幕/词典.txt`，每行一个词

## 技术栈

- **火山引擎 ASR**：云端语音识别，提供字级别时间戳
- **FFmpeg**：视频剪辑和字幕烧录
- **Node.js**：运行分析脚本和服务器
- **OpenClaw AI**：语义分析和口误识别

## License

MIT
