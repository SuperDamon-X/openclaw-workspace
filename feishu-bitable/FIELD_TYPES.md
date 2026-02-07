# 飞书多维表格字段类型说明

## 字段类型列表

| 类型ID | 类型名称 | 说明 | 示例配置 |
|--------|----------|------|----------|
| 1 | 文本 | 单行或多行文本 | `{"type": 1}` |
| 2 | 数字 | 整数或小数 | `{"type": 2}` |
| 3 | 单选 | 从预设选项中选择一个 | 见下方示例 |
| 4 | 多选 | 从预设选项中选择多个 | 见下方示例 |
| 5 | 日期 | 日期或日期时间 | `{"type": 5}` |
| 11 | 电话 | 电话号码 | `{"type": 11}` |
| 13 | 进度条 | 百分比进度 | `{"type": 13}` |
| 15 | 评级 | 星级评分 | `{"type": 15}` |
| 17 | 人员 | 飞书用户 | `{"type": 17}` |
| 18 | 邮箱 | 邮箱地址 | `{"type": 18}` |
| 20 | 附件 | 文件附件 | `{"type": 20}` |
| 23 | 复选框 | 勾选框 | `{"type": 23}` |
| 1001 | 创建人 | 记录创建者（只读） | `{"type": 1001}` |
| 1002 | 创建时间 | 记录创建时间（只读） | `{"type": 1002}` |
| 1003 | 修改人 | 最后修改者（只读） | `{"type": 1003}` |
| 1004 | 修改时间 | 最后修改时间（只读） | `{"type": 1004}` |

## 字段配置示例

### 文本（多行）
```json
{
  "field_name": "备注",
  "type": 1,
  "property": {
    "multi_line": true
  }
}
```

### 单选
```json
{
  "field_name": "状态",
  "type": 3,
  "property": {
    "options": [
      { "name": "待开始", "color": "grey" },
      { "name": "进行中", "color": "blue" },
      { "name": "已完成", "color": "green" }
    ]
  }
}
```

### 多选
```json
{
  "field_name": "标签",
  "type": 4,
  "property": {
    "options": [
      { "name": "重要", "color": "red" },
      { "name": "紧急", "color": "orange" },
      { "name": "日常", "color": "green" }
    ]
  }
}
```

### 日期
```json
{
  "field_name": "截止日期",
  "type": 5,
  "property": {
    "date_format": "YYYY-MM-DD",
    "time_format": "HH:mm",
    "include_time": false
  }
}
```

### 评级（5星）
```json
{
  "field_name": "满意度",
  "type": 15,
  "property": {
    "max": 5
  }
}
```

## 颜色选项

单选和多选字段支持的选项颜色：
- `grey` - 灰色
- `blue` - 蓝色
- `turquoise` - 青色
- `green` - 绿色
- `yellow` - 黄色
- `orange` - 橙色
- `red` - 红色
- `purple` - 紫色

## 完整表格配置示例

```json
{
  "name": "任务表",
  "default_view": {
    "type": "grid"
  },
  "fields": [
    {
      "field_name": "任务名称",
      "type": 1
    },
    {
      "field_name": "状态",
      "type": 3,
      "property": {
        "options": [
          { "name": "待开始", "color": "grey" },
          { "name": "进行中", "color": "blue" },
          { "name": "已完成", "color": "green" }
        ]
      }
    },
    {
      "field_name": "截止日期",
      "type": 5
    }
  ]
}
```
