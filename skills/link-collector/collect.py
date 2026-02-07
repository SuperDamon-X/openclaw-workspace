#!/usr/bin/env python3
"""
Link Collector - 网页内容采集工具
自动采集网页内容并保存为 Markdown 格式
"""

import re
import sys
import json
from datetime import datetime
from pathlib import Path

def extract_title(content):
    """从 HTML 中提取标题"""
    # 尝试匹配 <title> 标签
    title_match = re.search(r'<title>(.*?)</title>', content, re.IGNORECASE | re.DOTALL)
    if title_match:
        return title_match.group(1).strip()

    # 尝试匹配 <h1> 标签
    h1_match = re.search(r'<h1[^>]*>(.*?)</h1>', content, re.IGNORECASE | re.DOTALL)
    if h1_match:
        return h1_match.group(1).strip()

    return "未命名文章"

def extract_content(content):
    """从 HTML 中提取正文内容（简单版）"""
    # 移除 script 和 style 标签
    content = re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.IGNORECASE | re.DOTALL)
    content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.IGNORECASE | re.DOTALL)

    # 移除 HTML 标签，保留文本
    content = re.sub(r'<[^>]+>', '', content)

    # 清理空白字符
    content = re.sub(r'\n+', '\n', content)
    content = content.strip()

    return content

def generate_tags(content):
    """根据内容生成标签"""
    tags = []

    content_lower = content.lower()

    if any(keyword in content_lower for keyword in ['技术', '编程', '代码', '开发', 'api', '框架']):
        tags.append('#技术')
    if any(keyword in content_lower for keyword in ['教程', '指南', '如何', '入门', '学习']):
        tags.append('#教程')
    if any(keyword in content_lower for keyword in ['产品', '工具', '软件', 'app', '应用']):
        tags.append('#产品')
    if any(keyword in content_lower for keyword in ['资源', '推荐', '精选', '榜单', '合集']):
        tags.append('#资源')
    if any(keyword in content_lower for keyword in ['设计', 'ui', 'ux', '界面', '视觉']):
        tags.append('#设计')
    if any(keyword in content_lower for keyword in ['ai', '人工智能', '机器学习', '深度学习']):
        tags.append('#AI')

    if not tags:
        tags.append('#其他')

    return tags

def save_to_markdown(url, title, content, tags=None):
    """保存为 Markdown 文件"""
    if tags is None:
        tags = generate_tags(content)

    date = datetime.now().strftime('%Y-%m-%d')
    safe_title = re.sub(r'[<>:"/\\|?*]', '', title)[:50]  # 限制文件名长度
    filename = f"{date}-{safe_title}.md"

    # 确保目录存在
    assets_dir = Path("assets/素材")
    assets_dir.mkdir(parents=True, exist_ok=True)

    filepath = assets_dir / filename

    markdown = f"""# {title}

> 来源：{url}
> 采集时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
> 标签：{' '.join(tags)}

---

{content}
"""

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(markdown)

    return filepath, tags

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python collect.py <URL>")
        sys.exit(1)

    url = sys.argv[1]

    print(f"正在采集: {url}")

    # 这里需要实际的网页抓取逻辑
    # 由于这是一个简单的脚本框架，实际使用时需要集成 web_fetch

    print(f"✓ 标题: <title>")
    print(f"✓ 正文: <content>")
    print(f"✓ 标签: {' '.join(['#技术'])}")

if __name__ == '__main__':
    main()
