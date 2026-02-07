import os
import json
from pathlib import Path

# 搜索热门技能的依据
SEARCH_CRITERIA = [
    "ocr",        # 识图
    "web",        # 网络操作
    "file",       # 文件处理
    "api",        # API调用
    "ai",         # AI相关
    "bot",        # 机器人
    "media",      # 媒体
    "chat",       # 聊天
    "search",      # 搜索
    "crypto",      # 加密货币
    "finance",    # 金融
]

def scan_skills_for_hot(skills_path):
    """扫描skills目录，查找可能的热门技能"""
    
    hot_skills = []
    
    skills_dir = Path(skills_path) / "skills"
    if not skills_dir.exists():
        print(f"Skills目录不存在: {skills_dir}")
        return hot_skills
    
    # 遍历所有技能目录
    for skill_dir in skills_dir.iterdir():
        if not skill_dir.is_dir():
            continue
        
        # 查找SKILL.md
        skill_md = skill_dir / "SKILL.md"
        metadata_file = skill_dir / "metadata.json"
        
        if not skill_md.exists():
            continue
        
        # 读取描述
        try:
            with open(skill_md, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 检查是否匹配热门关键词
            matches = []
            for keyword in SEARCH_CRITERIA:
                if keyword in content.lower():
                    matches.append(keyword)
            
            if matches:
                skill_name = skill_dir.name
                # 尝试从description提取第一行
                description = content.split('\n')[0].strip() if content else ""
                
                # 检查metadata
                stars = 0
                downloads = 0
                
                if metadata_file.exists():
                    try:
                        with open(metadata_file, 'r', encoding='utf-8') as m:
                            metadata = json.load(m)
                            stars = metadata.get('stars', 0)
                            downloads = metadata.get('downloads', 0)
                    except:
                        pass
                
                hot_skills.append({
                    'name': skill_name,
                    'path': str(skill_dir.relative_to(skills_path)),
                    'description': description,
                    'matches': matches,
                    'stars': stars,
                    'downloads': downloads
                })
        except Exception as e:
            print(f"读取{skill_md.name}失败: {e}")
    
    # 排序：匹配关键词多的优先，然后是stars多的
    hot_skills.sort(key=lambda x: (
        -len(x['matches']),
        -x['stars']
    ))
    
    return hot_skills

def main():
    skills_path = r"C:\Users\Administrator\.openclaw\workspace\skills"
    
    print("正在扫描skills目录...")
    hot_skills = scan_skills_for_hot(skills_path)
    
    print(f"\n找到 {len(hot_skills)} 个热门技能：\n")
    
    for skill in hot_skills[:30]:  # 前30个
        print(f"\n🔥 {skill['name']}")
        print(f"   路径: skills/{skill['path']}")
        print(f"   描述: {skill['description']}")
        print(f"   匹配: {', '.join(skill['matches'])}")
        print(f"   Stars: {skill['stars']} | Downloads: {skill['downloads']}")
    
    # 保存列表
    with open(r"C:\Users\Administrator\.openclaw\workspace\hot-skills.txt", 'w', encoding='utf-8') as f:
        f.write("# 热门技能列表\n\n")
        for skill in hot_skills:
            f.write(f"## {skill['name']}\n")
            f.write(f"路径: skills/{skill['path']}\n")
            f.write(f"描述: {skill['description']}\n")
            f.write(f"匹配: {', '.join(skill['matches'])}\n")
            f.write(f"Stars: {skill['stars']}\n")
            f.write(f"Downloads: {skill['downloads']}\n")
            f.write("\n")
    
    print(f"\n✅ 列表已保存到: C:\Users\Administrator\.openclaw\workspace\hot-skills.txt")

if __name__ == "__main__":
    main()
