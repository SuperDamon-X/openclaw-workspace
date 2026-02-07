# 飞书多维表格 (Feishu Bitable) 集成

让 OpenClaw 能够操作飞书的多维表格，实现**创建表格、读取、写入、更新和删除**。

## ✅ 完整功能

### 📊 表格管理
- ✅ **创建多维表格（Base）** - 全新功能！
- ✅ 创建数据表（支持自定义字段）
- ✅ 添加/修改/删除字段
- ✅ 列出所有表格

### 📝 数据操作
- ✅ 读取记录（单页/全量）
- ✅ 添加记录
- ✅ 更新记录
- ✅ 删除记录
- ✅ 批量操作

## 快速开始

### 1. 配置飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/app)
2. 创建企业自建应用
3. 获取 `App ID` 和 `App Secret`
4. 开启以下权限：
   - `bitable:app` - 多维表格应用权限
   - `bitable:app:readonly` - 多维表格只读权限
   - `bitable:app:write` - 多维表格写入权限

### 2. 设置环境变量

```bash
# Windows
set FEISHU_APP_ID=cli_xxxxxxxxxxxxxxxx
set FEISHU_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Linux/Mac
export FEISHU_APP_ID=cli_xxxxxxxxxxxxxxxx
export FEISHU_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 3. 创建第一个多维表格

```bash
# 创建一个新的多维表格
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-base "我的项目"

# 输出示例：
# ✓ 多维表格创建成功!
# 名称: 我的项目
# App Token: bascnxxxxxxxxxxxxx
# URL: https://bascnxxxxxxxxxxxxx.bitable.cn
```

### 4. 创建数据表

```bash
# 创建带默认字段的简单表格
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-table <app_token> "任务清单"

# 或者使用配置文件创建复杂表格
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-table <app_token> "" --json "C:\Users\Administrator\.openclaw\workspace\feishu-bitable\table-examples\project-tasks.json"
```

### 5. 操作数据

```bash
# 添加记录
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js add <app_token> <table_id> "任务名称=完成文档" "状态=进行中"

# 查看记录
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js get <app_token> <table_id>

# 更新记录
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js update <app_token> <table_id> <record_id> "状态=已完成"
```

## 📋 预置表格模板

我为你准备了常用表格模板：

### 项目任务表
```bash
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-table <app_token> "" --json "C:\Users\Administrator\.openclaw\workspace\feishu-bitable\table-examples\project-tasks.json"
```
包含：任务名称、状态、优先级、截止日期、负责人、备注

### 客户管理表
```bash
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-table <app_token> "" --json "C:\Users\Administrator\.openclaw\workspace\feishu-bitable\table-examples\customers.json"
```
包含：客户名称、联系人、电话、邮箱、公司、客户状态、客户等级、最后联系时间、备注

查看更多字段类型配置：`FIELD_TYPES.md`

## 命令参考

### 创建类

| 命令 | 说明 |
|------|------|
| `create-base <名称>` | 创建多维表格 |
| `create-table <app_token> <名称>` | 创建数据表 |
| `list <app_token>` | 列出所有表格 |

### 数据操作类

| 命令 | 说明 |
|------|------|
| `get <app_token> <table_id>` | 获取记录 |
| `add <app_token> <table_id> <field=value> ...` | 添加记录 |
| `update <app_token> <table_id> <record_id> <field=value> ...` | 更新记录 |
| `delete <app_token> <table_id> <record_id>` | 删除记录 |

## 字段数据格式

### 常用字段类型

| 字段类型 | 数据格式 | 示例 |
|----------|----------|------|
| 文本 | 字符串 | `"任务名称=完成文档"` |
| 数字 | 整数/小数 | `"数量=10"` 或 `"价格=99.5"` |
| 单选 | 选项名称 | `"状态=进行中"` |
| 日期 | YYYY-MM-DD | `"截止日期=2026-01-31"` |
| 复选框 | true/false | `"已完成=true"` |

## 在 OpenClaw 中使用

### 示例：创建项目管理表格

```
# 创建多维表格
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-base "项目管理系统"

# 创建任务表
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js create-table <app_token> "" --json "C:\Users\Administrator\.openclaw\workspace\feishu-bitable\table-examples\project-tasks.json"

# 添加一些任务
node C:\Users\Administrator\.openclaw\workspace\feishu-bitable\cli.js add <app_token> <table_id> "任务名称=设计数据库" "状态=待开始" "优先级=高"
```

### Node.js 编程接口

```javascript
const { FeishuBitable } = require('C:\\Users\\Administrator\\.openclaw\\workspace\\feishu-bitable\\feishu-bitable.js');

const client = new FeishuBitable('cli_xxx', 'xxx');

// 创建多维表格
const base = await client.createBase('新项目');
console.log(base.app.app_token);

// 创建数据表
await client.createTable(base.app.app_token, {
  name: '任务',
  fields: [
    { field_name: '名称', type: 1 },
    { field_name: '状态', type: 3 }
  ]
});

// 添加记录
await client.createRecord(appToken, tableId, { '名称': '任务1' });
```

## 文件说明

- `feishu-bitable.js` - 核心SDK（Node.js）
- `cli.js` - 命令行工具
- `table-examples/` - 预置表格模板
- `FIELD_TYPES.md` - 字段类型配置说明
- `SKILL.md` - 完整技能文档

## 下一步

**准备开始使用？我需要你提供：**

1. **飞书应用凭证**
   - App ID
   - App Secret

2. **想创建什么表格？**
   - 项目管理？
   - 客户管理？
   - 数据收集？
   - 自定义？

告诉我，我帮你快速搭建！
