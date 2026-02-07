# -*- coding: utf-8 -*-
import os
import json
from pathlib import Path

SEARCH_KEYWORDS = [
    "ocr", "web", "file", "api", "ai", 
    "bot", "media", "chat", "search", "crypto", "finance"
]

def scan_skills(skills_path):
    hot_skills = []
    
    skills_dir = Path(skills_path) / "skills"
    if not skills_dir.exists():
        print(f"❌ 目录不存在: {skills_dir}")
        return hot_skills
    
    for skill_dir in skills_dir.iterdir():
        if not skill_dir.is_dir():
            continue
        
        skill_md = skill_dir / "SKILL.md"
        metadata_json = skill_dir / "metadata.json"
        
        if not skill_md.exists():
            continue
        
        try:
            with open(skill_md, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            matches = []
            for keyword in SEARCH_KEYWORDS:
                if keyword in content.lower():
                    matches.append(keyword)
            
            if matches:
                skill_name = skill_dir.name
                description = ""
                for line in content.split('\n')[:5]:
                    if line.strip():
                        description = line.strip()
                        break
                
                stars = 0
                downloads = 0
                
                if metadata_json.exists():
                    try:
                        with open(metadata_json, 'r', encoding='utf-8') as m:
                            metadata = json.load(m)
                            stars = metadata.get('stars', 0)
                            downloads = metadata.get('downloads', 0)
                    except:
                        pass
                
                hot_skills.append({
                    'name': skill_name,
                    'path': str(skill_dir.relative_to(skills_dir)),
                    'description': description,
                    'matches': ', '.join(matches),
                    'stars': stars,
                    'downloads': downloads
                })
        except Exception as e:
            continue
    
    hot_skills.sort(key=lambda x: (-len(x['matches']), -x['stars']))
    return hot_skills

def main():
    skills_path = r"C:\Users\Administrator\.openclaw\workspace\skills"
    
    print("🔍 扫描热门技能...")
    hot_skills = scan_skills(skills_path)
    
    print(f"\n✅ 找到 {len(hot_skills)} 个热门技能\n")
    
    output_file = r"C:\Users\Administrator\.openclaw\workspace\hot-skills.txt"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("🔥 热门技能推荐\n\n")
        for i, skill in enumerate(hot_skills[:30], 1):
            f.write(f"\n{i}. {skill['name']}\n")
            f.write(f"   路径: skills/{skill['path']}\n")
            f.write(f"   描述: {skill['description']}\n")
            f.write(f"   匹配: {skill['matches']}\n")
            f.write(f"   Stars: {skill['stars']} | Downloads: {skill['downloads']}\n")
    
    print(f"✅ 列表已保存: {output_file}")

if __name__ == "__main__":
    main()
