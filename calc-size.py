import os
import shutil

def get_folder_size(folder_path):
    """计算文件夹大小（GB）"""
    total_size = 0
    
    # 遍历所有子目录和文件
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            # 获取文件大小
            if os.path.exists(file_path):
                total_size += os.path.getsize(file_path)
    
    # 转换为GB
    size_gb = total_size / (1024 ** 3)
    
    return size_gb

if __name__ == "__main__":
    skills_path = r"C:\Users\Administrator\.openclaw\workspace\skills"
    
    if os.path.exists(skills_path):
        size_gb = get_folder_size(skills_path)
        print(f"skills目录大小: {size_gb:.2f} GB")
    else:
        print("目录不存在")