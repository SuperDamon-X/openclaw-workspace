---
name: feishu-bitable
description: 支持飞书多维表格（Bitable）的操作和管理，包括数据增删改查、表格管理等。
---

# 飞书多维表格 (Feishu Bitable) 操作指南

## 简介
这个技能让你能够通过 OpenClaw 操作飞书的多维表格（Bitable），实现数据的读取、写入、更新和删除。

## 前置要求

### 1. 飞书应用配置
需要创建一个飞书企业自建应用或企业应用：
- 访问 https://open.feishu.cn/app
- 创建应用，获取 `App ID` 和 `App Secret`
- 在权限管理中开启以下权限：
  - `bitable:app` - 多维表格应用权限
  - `bitable:app:readonly` - 多维表格只读权限（读取时）
  - `bitable:app:write` - 多维表格写入权限（写入时）

### 2. 配置 OpenClaw
在 OpenClaw 配置文件中添加飞书 API 凭证：
```yaml
feishu:
  appId: "cli_xxxxxxxxxxxxxxxx"
  appSecret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 3. 获取多维表格信息
需要提供以下信息：
- `app_token` - 多维表格的标识（从URL中获取，如 `xxx.bitable.cn/xxxxx/xxxxx` 中的第一个部分）
- `table_id` - 数据表的ID（通过API获取或手动查看）
- `view_id` - 视图ID（可选，用于特定视图操作）

## 主要功能

### 1. 列出所有表格
```python
# 列出多维表格中的所有数据表
list_tables(app_token)
```

### 2. 读取数据
```python
# 获取表格数据
get_records(app_token, table_id, page_size=20, page_token=None)
```

### 3. 创建记录
```python
# 插入新记录
create_record(app_token, table_id, fields)
# fields 示例: {"名称": "测试", "数量": 10, "日期": "2026-01-31"}
```

### 4. 更新记录
```python
# 更新现有记录
update_record(app_token, table_id, record_id, fields)
```

### 5. 删除记录
```python
# 删除记录
delete_record(app_token, table_id, record_id)
```

### 6. 批量操作
```python
# 批量创建记录
batch_create_records(app_token, table_id, records)

# 批量更新记录
batch_update_records(app_token, table_id, records)
```

## 使用场景

### 场景1: 从CSV导入数据
```bash
# 读取CSV文件并导入到飞书表格
csv_to_bitable("data.csv", app_token, table_id)
```

### 场景2: 同步外部数据
```python
# 定期同步外部数据源到飞书表格
sync_external_data_to_bitable()
```

### 场景3: 数据查询和报告
```python
# 查询特定条件的数据
query_records(app_token, table_id, filter_conditions)
```

## API 参考

### 认证
所有API调用都需要获取 access_token：
```
POST https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal
```

### 主要端点
- 列出表格: `GET /open-apis/bitable/v1/apps/{app_token}/tables`
- 获取记录: `GET /open-apis/bitable/v1/apps/{app_token}/tables/{table_id}/records`
- 创建记录: `POST /open-apis/bitable/v1/apps/{app_token}/tables/{table_id}/records`
- 更新记录: `PUT /open-apis/bitable/v1/apps/{app_token}/tables/{table_id}/records/{record_id}`
- 删除记录: `DELETE /open-apis/bitable/v1/apps/{app_token}/tables/{table_id}/records/{record_id}`

## 注意事项

1. **权限管理**: 确保飞书应用有足够的权限
2. **字段类型**: 飞书表格字段类型包括文本、数字、日期、单选、多选等，需要正确映射
3. **API限制**: 飞书API有速率限制，批量操作时注意控制频率
4. **错误处理**: 所有操作都需要处理API错误和网络异常
5. **数据格式**: 日期需要按 `YYYY-MM-DD` 格式，时间需要按 `HH:mm:ss` 格式

## 开发计划

- [ ] 基础SDK封装（Python）
- [ ] 认证模块
- [ ] CRUD操作封装
- [ ] 字段类型映射工具
- [ ] 批量操作工具
- [ ] 数据导入/导出工具
- [ ] 错误处理和重试机制
- [ ] 命令行工具
