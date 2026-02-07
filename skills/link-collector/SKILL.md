---
name: link-collector
description: 自动采集网页内容并保存为 Markdown 格式到素材库。支持标题、正文、标签提取，适合批量收集参考资料。
metadata:
  {
    "openclaw":
      {
        "triggers": ["采集", "保存", "网页", "链接"],
      },
  }
---

# Link-Collector Skill

自动采集网页内容，保存为 Markdown 格式到素材库。

## 功能

- 自动提取网页标题、作者、正文
- 保存为 Markdown 格式
- 支持标签分类
- 记录来源链接
- 自动添加到素材库

## 使用方式

### 单个链接采集

```
采集这个链接 https://example.com/article
```

### 批量采集

```
采集这些链接：
- https://example.com/article1
- https://example.com/article2
- https://example.com/article3
```

## 保存路径

素材保存到：
- `assets/素材/[日期]-[标题].md`

## 标签规则

自动根据内容生成标签：
- #技术 - 技术类文章
- #教程 - 教程指南
- #产品 - 产品介绍
- #资源 - 资源推荐

## 工作流程

1. 用户发送链接
2. 使用 web_fetch 读取网页内容
3. 提取标题、正文、作者等信息
4. 保存为 Markdown 文件
5. 自动提交到 Git
6. 通知用户完成

## 示例

**用户：**
```
采集这篇文章 https://openclaw.ai/docs
```

**助手：**
```
正在采集...

✓ 标题：OpenClaw 文档
✓ 作者：OpenClaw Team
✓ 正文：已保存 3200 字

已保存到：assets/素材/2026-02-08-OpenClaw文档.md
来源：https://openclaw.ai/docs
标签：#技术 #文档

已提交到 Git
```
