#!/usr/bin/env node

/**
 * 飞书多维表格命令行工具 - Node.js版本
 */

const { FeishuBitable } = require('./feishu-bitable');
const fs = require('fs');

// 从环境变量或命令行参数获取凭证
function getCredentials() {
    let appId = process.env.FEISHU_APP_ID;
    let appSecret = process.env.FEISHU_APP_SECRET;

    // 从参数中获取
    const args = process.argv.slice(2);
    const appIdIndex = args.indexOf('--app-id');
    const secretIndex = args.indexOf('--app-secret');

    if (appIdIndex !== -1 && appIdIndex + 1 < args.length) {
        appId = args[appIdIndex + 1];
    }
    if (secretIndex !== -1 && secretIndex + 1 < args.length) {
        appSecret = args[secretIndex + 1];
    }

    if (!appId || !appSecret) {
        console.error('错误: 必须提供 --app-id 和 --app-secret，或设置环境变量 FEISHU_APP_ID 和 FEISHU_APP_SECRET');
        process.exit(1);
    }

    return { appId, appSecret };
}

/**
 * 格式化记录为易读的字符串
 */
function formatRecord(record, showId = false) {
    const fields = record.fields || {};
    const result = [];

    if (showId) {
        result.push(`[ID: ${record.record_id ? record.record_id.substring(0, 12) + '...' : 'N/A'}]`);
    }

    for (const [key, value] of Object.entries(fields)) {
        if (value !== null && value !== undefined) {
            // 处理不同类型的值
            let valueStr;
            if (Array.isArray(value)) {
                valueStr = value.join(', ');
            } else if (typeof value === 'object') {
                valueStr = JSON.stringify(value);
            } else {
                valueStr = String(value);
            }
            result.push(`${key}: ${valueStr}`);
        }
    }

    return result.join('\n');
}

/**
 * 解析字段值
 */
function parseFields(fieldArgs) {
    const fields = {};
    for (const arg of fieldArgs) {
        const parts = arg.split('=', 2);
        if (parts.length === 2) {
            let key = parts[0].trim().replace(/^["']|["']$/g, '');
            let value = parts[1].trim().replace(/^["']|["']$/g, '');

            // 尝试转换为数字
            if (/^\d+$/.test(value)) {
                value = parseInt(value, 10);
            } else if (/^\d+\.\d+$/.test(value)) {
                value = parseFloat(value);
            }

            fields[key] = value;
        }
    }
    return fields;
}

/**
 * 显示帮助信息
 */
function showHelp() {
    console.log(`
飞书多维表格命令行工具

使用方法:

  # 创建多维表格（Base）
  node cli.js create-base <名称> [--app-id <id>] [--app-secret <secret>] [--folder <folder_token>]

  # 创建数据表
  node cli.js create-table <app_token> <表格名称> [--app-id <id>] [--app-secret <secret>] [--json <file.json>]

  # 列出所有表格
  node cli.js list <app_token> [--app-id <id>] [--app-secret <secret>] [-v|--verbose]

  # 获取记录
  node cli.js get <app_token> <table_id> [--app-id <id>] [--app-secret <secret>]
             [--all] [--page-size <n>] [--show-id]

  # 添加记录
  node cli.js add <app_token> <table_id> [--app-id <id>] [--app-secret <secret>]
             <field1=value1> <field2=value2> | --json <file.json>

  # 更新记录
  node cli.js update <app_token> <table_id> <record_id> [--app-id <id>] [--app-secret <secret>]
                <field1=value1> <field2=value2> | --json <file.json>

  # 删除记录
  node cli.js delete <app_token> <table_id> <record_id> [--app-id <id>] [--app-secret <secret>]

环境变量:
  FEISHU_APP_ID 和 FEISHU_APP_SECRET 可省略 --app-id 和 --app-secret

示例:
  # 创建多维表格
  node cli.js create-base "项目管理系统"

  # 创建数据表
  node cli.js create-table bascnxxxxxxxxxxxxx "任务清单"

  # 列出表格
  node cli.js list bascnxxxxxxxxxxxxx

  # 获取记录
  node cli.js get bascnxxxxxxxxxxxxx tblxxxxxxxxxxxxx

  # 添加记录
  node cli.js add bascnxxxxxxxxxxxxx tblxxxxxxxxxxxxx "名称=测试" "数量=10"

  # 更新记录
  node cli.js update bascnxxxxxxxxxxxxx tblxxxxxxxxxxxxx recxxxxxxxxxxxxx "数量=20"

  # 删除记录
  node cli.js delete bascnxxxxxxxxxxxxx tblxxxxxxxxxxxxx recxxxxxxxxxxxxx
                `);
}

/**
 * 主函数
 */
async function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    // 对于help命令或没有命令，显示帮助
    if (command === 'help' || !command) {
        showHelp();
        return;
    }

    const { appId, appSecret } = getCredentials();
    const client = new FeishuBitable(appId, appSecret);

    try {
        switch (command) {
            case 'list': {
                const appToken = args[1];
                const verbose = args.includes('-v') || args.includes('--verbose');

                if (!appToken) {
                    console.error('错误: 请提供 app_token');
                    process.exit(1);
                }

                const tables = await client.listTables(appToken);

                if (!tables || tables.items.length === 0) {
                    console.log(`多维表格 ${appToken} 中没有找到数据表`);
                    return;
                }

                console.log(`\n找到 ${tables.items.length} 个数据表:\n`);
                tables.items.forEach((table, index) => {
                    console.log(`${index + 1}. ${table.name} (ID: ${table.table_id})`);
                    if (verbose) {
                        console.log(`   字段数: ${table.fields ? table.fields.length : 0}`);
                    }
                });
                break;
            }

            case 'get': {
                const appToken = args[1];
                const tableId = args[2];
                const all = args.includes('--all');
                const showId = args.includes('--show-id');
                let pageSize = 20;

                const sizeIndex = args.indexOf('--page-size');
                if (sizeIndex !== -1 && sizeIndex + 1 < args.length) {
                    pageSize = parseInt(args[sizeIndex + 1], 10);
                }

                if (!appToken || !tableId) {
                    console.error('错误: 请提供 app_token 和 table_id');
                    process.exit(1);
                }

                let records;
                if (all) {
                    records = await client.getAllRecords(appToken, tableId, pageSize);
                } else {
                    const result = await client.getRecords(appToken, tableId, { pageSize });
                    records = result.items || [];
                }

                if (records.length === 0) {
                    console.log(`表格中没有找到记录`);
                    return;
                }

                console.log(`\n找到 ${records.length} 条记录:\n`);
                records.forEach((record, index) => {
                    console.log(`--- 记录 ${index + 1} ---`);
                    console.log(formatRecord(record, showId));
                    console.log();
                });
                break;
            }

            case 'add': {
                const appToken = args[1];
                const tableId = args[2];

                const fieldArgs = [];
                let jsonFile = null;

                for (let i = 3; i < args.length; i++) {
                    if (args[i] === '--json' && i + 1 < args.length) {
                        jsonFile = args[i + 1];
                        i++;
                    } else if (!args[i].startsWith('--')) {
                        fieldArgs.push(args[i]);
                    }
                }

                if (!appToken || !tableId) {
                    console.error('错误: 请提供 app_token 和 table_id');
                    process.exit(1);
                }

                let fields;
                if (jsonFile) {
                    const jsonContent = fs.readFileSync(jsonFile, 'utf8');
                    fields = JSON.parse(jsonContent);
                } else if (fieldArgs.length > 0) {
                    fields = parseFields(fieldArgs);
                } else {
                    console.error('错误: 必须提供字段数据');
                    process.exit(1);
                }

                const result = await client.createRecord(appToken, tableId, fields);
                const record = result.record || {};

                console.log('\n✓ 记录添加成功!');
                console.log(`记录ID: ${record.record_id || 'N/A'}`);
                console.log(`创建时间: ${record.created_time || 'N/A'}`);
                console.log('\n字段内容:');
                console.log(formatRecord(record));
                break;
            }

            case 'update': {
                const appToken = args[1];
                const tableId = args[2];
                const recordId = args[3];

                const fieldArgs = [];
                let jsonFile = null;

                for (let i = 4; i < args.length; i++) {
                    if (args[i] === '--json' && i + 1 < args.length) {
                        jsonFile = args[i + 1];
                        i++;
                    } else if (!args[i].startsWith('--')) {
                        fieldArgs.push(args[i]);
                    }
                }

                if (!appToken || !tableId || !recordId) {
                    console.error('错误: 请提供 app_token, table_id 和 record_id');
                    process.exit(1);
                }

                let fields;
                if (jsonFile) {
                    const jsonContent = fs.readFileSync(jsonFile, 'utf8');
                    fields = JSON.parse(jsonContent);
                } else if (fieldArgs.length > 0) {
                    fields = parseFields(fieldArgs);
                } else {
                    console.error('错误: 必须提供字段数据');
                    process.exit(1);
                }

                const result = await client.updateRecord(appToken, tableId, recordId, fields);
                const record = result.record || {};

                console.log('\n✓ 记录更新成功!');
                console.log(`记录ID: ${record.record_id || 'N/A'}`);
                console.log(`更新时间: ${record.modified_time || 'N/A'}`);
                console.log('\n字段内容:');
                console.log(formatRecord(record));
                break;
            }

            case 'delete': {
                const appToken = args[1];
                const tableId = args[2];
                const recordId = args[3];

                if (!appToken || !tableId || !recordId) {
                    console.error('错误: 请提供 app_token, table_id 和 record_id');
                    process.exit(1);
                }

                await client.deleteRecord(appToken, tableId, recordId);
                console.log('\n✓ 记录删除成功!');
                console.log(`记录ID: ${recordId}`);
                break;
            }

            case 'create-base': {
                const name = args[1];
                const folderTokenIndex = args.indexOf('--folder');
                const folderToken = folderTokenIndex !== -1 && folderTokenIndex + 1 < args.length
                    ? args[folderTokenIndex + 1]
                    : null;

                if (!name) {
                    console.error('错误: 请提供多维表格名称');
                    process.exit(1);
                }

                const result = await client.createBase(name, folderToken);
                console.log('\n✓ 多维表格创建成功!');
                console.log(`名称: ${result.app.name}`);
                console.log(`App Token: ${result.app.app_token}`);
                console.log(`URL: https://${result.app.app_token}.bitable.cn`);
                break;
            }

            case 'create-table': {
                const appToken = args[1];
                const name = args[2];
                const jsonFileIndex = args.indexOf('--json');
                let tableConfig = { name };

                if (jsonFileIndex !== -1 && jsonFileIndex + 1 < args.length) {
                    const jsonContent = fs.readFileSync(args[jsonFileIndex + 1], 'utf8');
                    tableConfig = JSON.parse(jsonContent);
                }

                if (!appToken || !name) {
                    console.error('错误: 请提供 app_token 和表格名称');
                    process.exit(1);
                }

                const result = await client.createTable(appToken, tableConfig);
                console.log('\n✓ 数据表创建成功!');

                // 飞书 API 返回格式可能不同，兼容处理
                const table = result.table || result;
                console.log(`名称: ${table.name}`);
                console.log(`Table ID: ${table.table_id}`);
                break;
            }

            default:
                console.error(`未知命令: ${command}`);
                showHelp();
                process.exit(1);
        }
    } catch (error) {
        console.error(`错误: ${error.message}`);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { main };
