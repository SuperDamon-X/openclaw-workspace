"""
飞书多维表格命令行工具
"""

import argparse
import json
import sys
import os
from typing import Optional
import requests

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from feishu_bitable import FeishuBitable
except ImportError:
    print("错误: 无法导入 feishu_bitable 模块")
    sys.exit(1)


def parse_field_value(value_str: str) -> dict:
    """
    解析字段值字符串为字典

    支持格式:
    - name=value
    - "字段名"="值"
    - 数组: field=[item1,item2]
    """
    try:
        # 尝试解析JSON
        return json.loads(value_str)
    except:
        # 如果不是JSON，尝试键值对格式
        parts = value_str.split('=', 1)
        if len(parts) == 2:
            key, value = parts
            # 移除引号
            key = key.strip('"\'')
            value = value.strip('"\'')
            return {key: value}
        else:
            raise ValueError(f"无法解析字段值: {value_str}")


def format_record(record: dict, show_id: bool = False) -> str:
    """格式化记录为易读的字符串"""
    fields = record.get("fields", {})
    result = []

    if show_id:
        result.append(f"[ID: {record.get('record_id', 'N/A')[:12]}...]")

    for key, value in fields.items():
        if value is not None:
            # 处理不同类型的值
            if isinstance(value, list):
                value_str = ", ".join(str(v) for v in value)
            elif isinstance(value, dict):
                value_str = json.dumps(value, ensure_ascii=False)
            else:
                value_str = str(value)
            result.append(f"{key}: {value_str}")

    return "\n".join(result)


def cmd_list(args):
    """列出所有表格"""
    client = FeishuBitable(args.app_id, args.app_secret)

    try:
        tables = client.list_tables(args.app_token)

        if not tables:
            print(f"多维表格 {args.app_token} 中没有找到数据表")
            return

        print(f"\n找到 {len(tables)} 个数据表:\n")
        for i, table in enumerate(tables, 1):
            print(f"{i}. {table.get('name')} (ID: {table.get('table_id')})")
            if args.verbose:
                print(f"   字段数: {len(table.get('fields', []))}")

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


def cmd_get(args):
    """获取记录"""
    client = FeishuBitable(args.app_id, args.app_secret)

    try:
        if args.all:
            # 获取所有记录
            records = client.get_all_records(args.app_token, args.table_id, args.page_size)
        else:
            # 获取一页记录
            result = client.get_records(args.app_token, args.table_id, args.page_size)
            records = result.get("items", [])

        if not records:
            print(f"表格中没有找到记录")
            return

        print(f"\n找到 {len(records)} 条记录:\n")
        for i, record in enumerate(records, 1):
            print(f"--- 记录 {i} ---")
            print(format_record(record, show_id=args.show_id))
            print()

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


def cmd_add(args):
    """添加记录"""
    client = FeishuBitable(args.app_id, args.app_secret)

    try:
        # 解析字段
        if args.fields:
            fields = {}
            for field_str in args.fields:
                parsed = parse_field_value(field_str)
                fields.update(parsed)
        elif args.json:
            fields = json.loads(args.json)
        else:
            print("错误: 必须提供 --fields 或 --json 参数")
            sys.exit(1)

        # 添加记录
        result = client.create_record(args.app_token, args.table_id, fields)
        record = result.get("record", {})

        print(f"\n✓ 记录添加成功!")
        print(f"记录ID: {record.get('record_id', 'N/A')}")
        print(f"创建时间: {record.get('created_time', 'N/A')}")
        print(f"\n字段内容:")
        print(format_record(record))

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


def cmd_update(args):
    """更新记录"""
    client = FeishuBitable(args.app_id, args.app_secret)

    try:
        # 解析字段
        if args.fields:
            fields = {}
            for field_str in args.fields:
                parsed = parse_field_value(field_str)
                fields.update(parsed)
        elif args.json:
            fields = json.loads(args.json)
        else:
            print("错误: 必须提供 --fields 或 --json 参数")
            sys.exit(1)

        # 更新记录
        result = client.update_record(args.app_token, args.table_id, args.record_id, fields)
        record = result.get("record", {})

        print(f"\n✓ 记录更新成功!")
        print(f"记录ID: {record.get('record_id', 'N/A')}")
        print(f"更新时间: {record.get('modified_time', 'N/A')}")
        print(f"\n字段内容:")
        print(format_record(record))

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


def cmd_delete(args):
    """删除记录"""
    client = FeishuBitable(args.app_id, args.app_secret)

    try:
        client.delete_record(args.app_token, args.table_id, args.record_id)
        print(f"\n✓ 记录删除成功!")
        print(f"记录ID: {args.record_id}")

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="飞书多维表格命令行工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  # 列出所有表格
  python feishu_bitable_cli.py list <app_token> --app-id <id> --app-secret <secret>

  # 获取记录
  python feishu_bitable_cli.py get <app_token> <table_id> --app-id <id> --app-secret <secret>

  # 添加记录
  python feishu_bitable_cli.py add <app_token> <table_id> --app-id <id> --app-secret <secret> \\
      --fields "名称=测试" "数量=10"

  # 更新记录
  python feishu_bitable_cli.py update <app_token> <table_id> <record_id> \\
      --app-id <id> --app-secret <secret> --fields "数量=20"

  # 删除记录
  python feishu_bitable_cli.py delete <app_token> <table_id> <record_id> \\
      --app-id <id> --app-secret <secret>

环境变量:
  FEISHU_APP_ID 和 FEISHU_APP_SECRET 可省略 --app-id 和 --app-secret
        """
    )

    # 全局参数
    parser.add_argument("--app-id", help="飞书应用ID (也可用 FEISHU_APP_ID 环境变量)")
    parser.add_argument("--app-secret", help="飞书应用密钥 (也可用 FEISHU_APP_SECRET 环境变量)")

    subparsers = parser.add_subparsers(dest="command", help="命令")

    # list 命令
    list_parser = subparsers.add_parser("list", help="列出所有表格")
    list_parser.add_argument("app_token", help="多维表格的app_token")
    list_parser.add_argument("-v", "--verbose", action="store_true", help="显示详细信息")

    # get 命令
    get_parser = subparsers.add_parser("get", help="获取记录")
    get_parser.add_argument("app_token", help="多维表格的app_token")
    get_parser.add_argument("table_id", help="数据表ID")
    get_parser.add_argument("--all", action="store_true", help="获取所有记录")
    get_parser.add_argument("--page-size", type=int, default=20, help="每页记录数 (默认: 20)")
    get_parser.add_argument("--show-id", action="store_true", help="显示记录ID")

    # add 命令
    add_parser = subparsers.add_parser("add", help="添加记录")
    add_parser.add_argument("app_token", help="多维表格的app_token")
    add_parser.add_argument("table_id", help="数据表ID")
    add_parser.add_argument("--fields", nargs="+", help="字段键值对，格式: name=value")
    add_parser.add_argument("--json", help="JSON格式的字段数据")

    # update 命令
    update_parser = subparsers.add_parser("update", help="更新记录")
    update_parser.add_argument("app_token", help="多维表格的app_token")
    update_parser.add_argument("table_id", help="数据表ID")
    update_parser.add_argument("record_id", help="记录ID")
    update_parser.add_argument("--fields", nargs="+", help="字段键值对，格式: name=value")
    update_parser.add_argument("--json", help="JSON格式的字段数据")

    # delete 命令
    delete_parser = subparsers.add_parser("delete", help="删除记录")
    delete_parser.add_argument("app_token", help="多维表格的app_token")
    delete_parser.add_argument("table_id", help="数据表ID")
    delete_parser.add_argument("record_id", help="记录ID")

    args = parser.parse_args()

    # 处理环境变量
    if not args.app_id:
        args.app_id = os.environ.get("FEISHU_APP_ID")
    if not args.app_secret:
        args.app_secret = os.environ.get("FEISHU_APP_SECRET")

    if not args.app_id or not args.app_secret:
        print("错误: 必须提供 --app-id 和 --app-secret，或设置环境变量 FEISHU_APP_ID 和 FEISHU_APP_SECRET")
        sys.exit(1)

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # 执行命令
    command_map = {
        "list": cmd_list,
        "get": cmd_get,
        "add": cmd_add,
        "update": cmd_update,
        "delete": cmd_delete
    }

    command_map[args.command](args)


if __name__ == "__main__":
    main()
