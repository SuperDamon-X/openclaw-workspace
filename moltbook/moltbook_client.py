"""
Moltbook API Client
AI Agent 社交网络
"""

import requests
import json
import os
from typing import Dict, List, Optional, Any

class MoltbookClient:
    def __init__(self, api_key: str = None):
        """
        初始化客户端

        Args:
            api_key: Moltbook API key，如果不提供则从环境变量读取
        """
        self.api_key = api_key or os.environ.get("MOLTBOOK_API_KEY")
        self.base_url = "https://www.moltbook.com/api/v1"

        if not self.api_key:
            raise ValueError("API key is required. Provide it or set MOLTBOOK_API_KEY environment variable.")

    def _request(self, method: str, endpoint: str, data: Dict = None, files: Dict = None) -> Dict:
        """
        发送请求到 Moltbook API

        Args:
            method: HTTP 方法 (GET, POST, PATCH, DELETE)
            endpoint: API 端点
            data: 请求数据 (JSON)
            files: 文件上传

        Returns:
            响应数据
        """
        url = f"{self.base_url}{endpoint}"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        # 如果有文件上传，移除 Content-Type 让 requests 自动设置
        if files:
            headers.pop("Content-Type")

        response = requests.request(method, url, headers=headers, json=data, files=files)
        result = response.json()

        if not result.get("success"):
            raise Exception(f"API Error: {result.get('error', 'Unknown error')}")

        return result.get("data", result)

    def get_me(self) -> Dict:
        """获取自己的 profile"""
        return self._request("GET", "/agents/me")

    def get_status(self) -> Dict:
        """获取 claim 状态"""
        return self._request("GET", "/agents/status")

    def update_profile(self, description: str = None, metadata: Dict = None) -> Dict:
        """
        更新 profile

        Args:
            description: 新描述
            metadata: 元数据

        Returns:
            更新后的 profile
        """
        data = {}
        if description:
            data["description"] = description
        if metadata:
            data["metadata"] = metadata
        return self._request("PATCH", "/agents/me", data)

    def create_post(self, submolt: str, title: str, content: str, url: str = None) -> Dict:
        """
        创建帖子

        Args:
            submolt: 社区名称
            title: 标题
            content: 内容
            url: 链接（可选）

        Returns:
            创建的帖子
        """
        data = {
            "submolt": submolt,
            "title": title,
            "content": content
        }
        if url:
            data["url"] = url
        return self._request("POST", "/posts", data)

    def delete_post(self, post_id: str) -> Dict:
        """删除帖子"""
        return self._request("DELETE", f"/posts/{post_id}")

    def get_posts(self, submolt: str = None, sort: str = "new", limit: int = 25) -> Dict:
        """
        获取帖子列表

        Args:
            submolt: 社区名称（可选）
            sort: 排序方式 (new, hot, top, rising)
            limit: 数量限制

        Returns:
            帖子列表
        """
        params = {"sort": sort, "limit": limit}
        if submolt:
            params["submolt"] = submolt
        # 直接在 URL 中构建参数
        endpoint = f"/posts?sort={sort}&limit={limit}"
        if submolt:
            endpoint += f"&submolt={submolt}"
        return self._request("GET", endpoint)

    def get_feed(self, sort: str = "new", limit: int = 25) -> Dict:
        """
        获取个性化 feed

        Args:
            sort: 排序方式 (new, hot, top)
            limit: 数量限制

        Returns:
            feed 列表
        """
        return self._request("GET", f"/feed?sort={sort}&limit={limit}")

    def add_comment(self, post_id: str, content: str, parent_id: str = None) -> Dict:
        """
        添加评论

        Args:
            post_id: 帖子 ID
            content: 评论内容
            parent_id: 回复的评论 ID（可选）

        Returns:
            创建的评论
        """
        data = {"content": content}
        if parent_id:
            data["parent_id"] = parent_id
        return self._request("POST", f"/posts/{post_id}/comments", data)

    def get_comments(self, post_id: str, sort: str = "top") -> Dict:
        """
        获取评论列表

        Args:
            post_id: 帖子 ID
            sort: 排序方式 (top, new, controversial)

        Returns:
            评论列表
        """
        return self._request("GET", f"/posts/{post_id}/comments?sort={sort}")

    def upvote_post(self, post_id: str) -> Dict:
        """点赞帖子"""
        return self._request("POST", f"/posts/{post_id}/upvote")

    def downvote_post(self, post_id: str) -> Dict:
        """点踩帖子"""
        return self._request("POST", f"/posts/{post_id}/downvote")

    def upvote_comment(self, comment_id: str) -> Dict:
        """点赞评论"""
        return self._request("POST", f"/comments/{comment_id}/upvote")

    def search(self, query: str, search_type: str = "all", limit: int = 20) -> Dict:
        """
        语义搜索

        Args:
            query: 搜索查询
            search_type: 搜索类型 (posts, comments, all)
            limit: 数量限制

        Returns:
            搜索结果
        """
        return self._request("GET", f"/search?q={query}&type={search_type}&limit={limit}")

    def get_submolts(self) -> Dict:
        """获取所有社区列表"""
        return self._request("GET", "/submolts")

    def get_submolt(self, name: str) -> Dict:
        """获取社区详情"""
        return self._request("GET", f"/submolts/{name}")

    def create_submolt(self, name: str, display_name: str, description: str) -> Dict:
        """创建社区"""
        data = {
            "name": name,
            "display_name": display_name,
            "description": description
        }
        return self._request("POST", "/submolts", data)

    def follow_agent(self, agent_name: str) -> Dict:
        """关注其他 agent"""
        return self._request("POST", f"/agents/{agent_name}/follow")

    def unfollow_agent(self, agent_name: str) -> Dict:
        """取消关注"""
        return self._request("DELETE", f"/agents/{agent_name}/follow")


def get_moltbook_client() -> MoltbookClient:
    """
    从配置文件获取 Moltbook 客户端

    Returns:
        MoltbookClient 实例
    """
    credentials_path = "C:\\Users\\Administrator\\.openclaw\\workspace\\moltbook\\credentials.json"

    if not os.path.exists(credentials_path):
        raise FileNotFoundError(f"Credentials file not found: {credentials_path}")

    with open(credentials_path, 'r', encoding='utf-8') as f:
        credentials = json.load(f)

    return MoltbookClient(credentials.get("api_key"))


if __name__ == "__main__":
    # 测试
    client = get_moltbook_client()

    print("检查状态...")
    status = client.get_status()
    print(f"Status: {status}")

    print("\n获取 profile...")
    profile = client.get_me()
    print(json.dumps(profile, indent=2, ensure_ascii=False))
