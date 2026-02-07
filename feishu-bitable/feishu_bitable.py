"""
飞书多维表格 (Feishu Bitable) SDK
支持数据表的增删改查操作
"""

import requests
import json
from typing import Dict, List, Optional, Any
from datetime import datetime

class FeishuBitable:
    """飞书多维表格客户端"""

    def __init__(self, app_id: str, app_secret: str):
        """
        初始化客户端

        Args:
            app_id: 飞书应用ID
            app_secret: 飞书应用密钥
        """
        self.app_id = app_id
        self.app_secret = app_secret
        self.base_url = "https://open.feishu.cn/open-apis"
        self.access_token = None
        self.token_expire_time = 0

    def get_access_token(self) -> str:
        """
        获取访问令牌（自动缓存）

        Returns:
            access_token: 访问令牌
        """
        # 检查缓存是否有效
        if self.access_token and datetime.now().timestamp() < self.token_expire_time:
            return self.access_token

        # 获取新令牌
        url = f"{self.base_url}/auth/v3/tenant_access_token/internal"
        payload = {
            "app_id": self.app_id,
            "app_secret": self.app_secret
        }

        response = requests.post(url, json=payload)
        data = response.json()

        if data.get("code") != 0:
            raise Exception(f"获取访问令牌失败: {data.get('msg')}")

        self.access_token = data["tenant_access_token"]
        # 提前5分钟过期，避免边界情况
        self.token_expire_time = datetime.now().timestamp() + data["expire"] - 300

        return self.access_token

    def _request(self, method: str, endpoint: str, **kwargs) -> Dict:
        """
        封装API请求

        Args:
            method: HTTP方法 (GET, POST, PUT, DELETE)
            endpoint: API端点
            **kwargs: 其他请求参数

        Returns:
            响应数据
        """
        headers = kwargs.pop("headers", {})
        headers["Authorization"] = f"Bearer {self.get_access_token()}"

        url = f"{self.base_url}{endpoint}"
        response = requests.request(method, url, headers=headers, **kwargs)
        data = response.json()

        if data.get("code") != 0:
            raise Exception(f"API请求失败: {data.get('msg')} (code: {data.get('code')})")

        return data.get("data", {})

    def list_tables(self, app_token: str) -> List[Dict]:
        """
        列出多维表格中的所有数据表

        Args:
            app_token: 多维表格的app_token

        Returns:
            数据表列表
        """
        return self._request(
            "GET",
            f"/bitable/v1/apps/{app_token}/tables"
        ).get("items", [])

    def get_records(
        self,
        app_token: str,
        table_id: str,
        page_size: int = 20,
        page_token: Optional[str] = None,
        sort: Optional[List[Dict]] = None
    ) -> Dict:
        """
        获取表格记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            page_size: 每页记录数（1-500）
            page_token: 翻页token
            sort: 排序规则

        Returns:
            记录数据
        """
        params = {"page_size": page_size}
        if page_token:
            params["page_token"] = page_token
        if sort:
            params["sort"] = json.dumps(sort)

        return self._request(
            "GET",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records",
            params=params
        )

    def get_all_records(
        self,
        app_token: str,
        table_id: str,
        page_size: int = 100
    ) -> List[Dict]:
        """
        获取所有记录（自动翻页）

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            page_size: 每页记录数

        Returns:
            所有记录列表
        """
        all_records = []
        page_token = None

        while True:
            result = self.get_records(app_token, table_id, page_size, page_token)
            all_records.extend(result.get("items", []))

            if not result.get("has_more"):
                break

            page_token = result.get("page_token")

        return all_records

    def create_record(
        self,
        app_token: str,
        table_id: str,
        fields: Dict[str, Any]
    ) -> Dict:
        """
        创建单条记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            fields: 字段数据

        Returns:
            创建的记录
        """
        return self._request(
            "POST",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records",
            json={"fields": fields}
        )

    def batch_create_records(
        self,
        app_token: str,
        table_id: str,
        records: List[Dict[str, Any]]
    ) -> Dict:
        """
        批量创建记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            records: 记录列表

        Returns:
            创建结果
        """
        return self._request(
            "POST",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_create",
            json={"records": [{"fields": r} for r in records]}
        )

    def update_record(
        self,
        app_token: str,
        table_id: str,
        record_id: str,
        fields: Dict[str, Any]
    ) -> Dict:
        """
        更新单条记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            record_id: 记录ID
            fields: 要更新的字段

        Returns:
            更新后的记录
        """
        return self._request(
            "PUT",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records/{record_id}",
            json={"fields": fields}
        )

    def batch_update_records(
        self,
        app_token: str,
        table_id: str,
        records: List[Dict[str, Any]]
    ) -> Dict:
        """
        批量更新记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            records: 记录列表，每个记录包含 record_id 和 fields

        Returns:
            更新结果
        """
        formatted_records = []
        for record in records:
            formatted_records.append({
                "record_id": record["record_id"],
                "fields": record["fields"]
            })

        return self._request(
            "POST",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_update",
            json={"records": formatted_records}
        )

    def delete_record(
        self,
        app_token: str,
        table_id: str,
        record_id: str
    ) -> Dict:
        """
        删除单条记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            record_id: 记录ID

        Returns:
            删除结果
        """
        return self._request(
            "DELETE",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records/{record_id}"
        )

    def batch_delete_records(
        self,
        app_token: str,
        table_id: str,
        record_ids: List[str]
    ) -> Dict:
        """
        批量删除记录

        Args:
            app_token: 多维表格的app_token
            table_id: 数据表ID
            record_ids: 记录ID列表

        Returns:
            删除结果
        """
        return self._request(
            "POST",
            f"/bitable/v1/apps/{app_token}/tables/{table_id}/records/batch_delete",
            json={"records": [{"record_id": rid} for rid in record_ids]}
        )


def get_feishu_bitable() -> FeishuBitable:
    """
    从环境变量或配置获取飞书Bitable客户端

    Returns:
        FeishuBitable 实例
    """
    import os

    app_id = os.environ.get("FEISHU_APP_ID")
    app_secret = os.environ.get("FEISHU_APP_SECRET")

    if not app_id or not app_secret:
        raise ValueError(
            "请设置环境变量 FEISHU_APP_ID 和 FEISHU_APP_SECRET，"
            "或者在配置文件中设置飞书API凭证"
        )

    return FeishuBitable(app_id, app_secret)


# 便捷函数
def list_tables(app_token: str) -> List[Dict]:
    """列出所有表格"""
    client = get_feishu_bitable()
    return client.list_tables(app_token)


def get_records(app_token: str, table_id: str, **kwargs) -> List[Dict]:
    """获取记录"""
    client = get_feishu_bitable()
    return client.get_all_records(app_token, table_id, **kwargs)


def add_record(app_token: str, table_id: str, fields: Dict[str, Any]) -> Dict:
    """添加记录"""
    client = get_feishu_bitable()
    return client.create_record(app_token, table_id, fields)


def update_record_data(app_token: str, table_id: str, record_id: str, fields: Dict[str, Any]) -> Dict:
    """更新记录"""
    client = get_feishu_bitable()
    return client.update_record(app_token, table_id, record_id, fields)


def remove_record(app_token: str, table_id: str, record_id: str) -> Dict:
    """删除记录"""
    client = get_feishu_bitable()
    return client.delete_record(app_token, table_id, record_id)


if __name__ == "__main__":
    # 测试代码
    print("飞书多维表格 SDK")
    print("使用方法:")
    print("1. 设置环境变量: export FEISHU_APP_ID=xxx FEISHU_APP_SECRET=xxx")
    print("2. 导入: from feishu_bitable import FeishuBitable, get_feishu_bitable")
    print("3. 使用: client = get_feishu_bitable(); tables = client.list_tables('app_token')")
