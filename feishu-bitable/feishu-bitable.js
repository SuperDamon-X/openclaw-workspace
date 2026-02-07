/**
 * 飞书多维表格 (Feishu Bitable) SDK - Node.js版本
 * 支持数据表的增删改查操作
 */

const https = require('https');

class FeishuBitable {
    constructor(appId, appSecret) {
        this.appId = appId;
        this.appSecret = appSecret;
        this.baseUrl = 'https://open.feishu.cn/open-apis';
        this.accessToken = null;
        this.tokenExpireTime = 0;
    }

    /**
     * 不带认证的请求（用于获取token）
     */
    async _requestWithoutAuth(method, endpoint, data = null) {
        return await this._requestInternal(method, endpoint, data, false);
    }

    /**
     * 获取访问令牌（自动缓存）
     */
    async getAccessToken() {
        // 检查缓存是否有效
        if (this.accessToken && Date.now() < this.tokenExpireTime) {
            return this.accessToken;
        }

        // 获取新令牌
        const token = await this._requestWithoutAuth(
            'POST',
            '/auth/v3/tenant_access_token/internal',
            {
                app_id: this.appId,
                app_secret: this.appSecret
            }
        );

        if (token.code !== 0) {
            throw new Error(`获取访问令牌失败: ${token.msg}`);
        }

        this.accessToken = token.tenant_access_token;
        // 提前5分钟过期，避免边界情况
        this.tokenExpireTime = Date.now() + (token.expire * 1000) - (5 * 60 * 1000);

        return this.accessToken;
    }

    /**
     * 封装API请求
     */
    async _request(method, endpoint, data = null) {
        return await this._requestInternal(method, endpoint, data, true);
    }

    /**
     * 内部请求方法
     */
    async _requestInternal(method, endpoint, data = null, withAuth = true) {
        const url = `${this.baseUrl}${endpoint}`;
        const headers = {
            'Content-Type': 'application/json'
        };

        if (withAuth) {
            headers['Authorization'] = `Bearer ${await this.getAccessToken()}`;
        }

        const options = {
            method,
            headers,
        };

        return new Promise((resolve, reject) => {
            const req = https.request(url, options, (res) => {
                let body = '';
                res.on('data', chunk => body += chunk);
                res.on('end', () => {
                    try {
                        const result = JSON.parse(body);
                        if (result.code !== 0) {
                            reject(new Error(`API请求失败: ${result.msg} (code: ${result.code})`));
                        } else {
                            resolve(result.data || result);
                        }
                    } catch (e) {
                        reject(new Error(`解析响应失败: ${e.message}`));
                    }
                });
            });

            req.on('error', reject);

            if (data) {
                req.write(JSON.stringify(data));
            }

            req.end();
        });
    }

    /**
     * 列出多维表格中的所有数据表
     */
    async listTables(appToken) {
        return await this._request('GET', `/bitable/v1/apps/${appToken}/tables`);
    }

    /**
     * 获取表格记录
     */
    async getRecords(appToken, tableId, options = {}) {
        const { pageSize = 20, pageToken = null } = options;
        let url = `/bitable/v1/apps/${appToken}/tables/${tableId}/records?page_size=${pageSize}`;
        if (pageToken) {
            url += `&page_token=${pageToken}`;
        }
        return await this._request('GET', url);
    }

    /**
     * 获取所有记录（自动翻页）
     */
    async getAllRecords(appToken, tableId, pageSize = 100) {
        const allRecords = [];
        let pageToken = null;

        while (true) {
            const result = await this.getRecords(appToken, tableId, { pageSize, pageToken });
            allRecords.push(...(result.items || []));

            if (!result.has_more) break;

            pageToken = result.page_token;
        }

        return allRecords;
    }

    /**
     * 创建单条记录
     */
    async createRecord(appToken, tableId, fields) {
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables/${tableId}/records`, {
            fields
        });
    }

    /**
     * 批量创建记录
     */
    async batchCreateRecords(appToken, tableId, records) {
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables/${tableId}/records/batch_create`, {
            records: records.map(r => ({ fields: r }))
        });
    }

    /**
     * 更新单条记录
     */
    async updateRecord(appToken, tableId, recordId, fields) {
        return await this._request('PUT', `/bitable/v1/apps/${appToken}/tables/${tableId}/records/${recordId}`, {
            fields
        });
    }

    /**
     * 批量更新记录
     */
    async batchUpdateRecords(appToken, tableId, records) {
        const formattedRecords = records.map(r => ({
            record_id: r.recordId || r.record_id,
            fields: r.fields
        }));
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables/${tableId}/records/batch_update`, {
            records: formattedRecords
        });
    }

    /**
     * 删除单条记录
     */
    async deleteRecord(appToken, tableId, recordId) {
        return await this._request('DELETE', `/bitable/v1/apps/${appToken}/tables/${tableId}/records/${recordId}`);
    }

    /**
     * 批量删除记录
     */
    async batchDeleteRecords(appToken, tableId, recordIds) {
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables/${tableId}/records/batch_delete`, {
            records: recordIds.map(id => ({ record_id: id }))
        });
    }

    /**
     * 创建多维表格（Base）
     */
    async createBase(name, folderToken = null) {
        const data = { name };
        if (folderToken) {
            data.folder_token = folderToken;
        }
        return await this._request('POST', '/bitable/v1/apps', data);
    }

    /**
     * 获取多维表格信息
     */
    async getBaseInfo(appToken) {
        return await this._request('GET', `/bitable/v1/apps/${appToken}`);
    }

    /**
     * 创建数据表
     */
    async createTable(appToken, table) {
        // 飞书 API 需要用 table 对象包裹
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables`, { table });
    }

    /**
     * 获取数据表信息
     */
    async getTableInfo(appToken, tableId) {
        return await this._request('GET', `/bitable/v1/apps/${appToken}/tables/${tableId}`);
    }

    /**
     * 更新数据表
     */
    async updateTable(appToken, tableId, updates) {
        return await this._request('PATCH', `/bitable/v1/apps/${appToken}/tables/${tableId}`, updates);
    }

    /**
     * 删除数据表
     */
    async deleteTable(appToken, tableId) {
        return await this._request('DELETE', `/bitable/v1/apps/${appToken}/tables/${tableId}`);
    }

    /**
     * 添加字段
     */
    async addField(appToken, tableId, field) {
        return await this._request('POST', `/bitable/v1/apps/${appToken}/tables/${tableId}/fields`, field);
    }

    /**
     * 更新字段
     */
    async updateField(appToken, tableId, fieldId, updates) {
        return await this._request('PATCH', `/bitable/v1/apps/${appToken}/tables/${tableId}/fields/${fieldId}`, updates);
    }

    /**
     * 删除字段
     */
    async deleteField(appToken, tableId, fieldId) {
        return await this._request('DELETE', `/bitable/v1/apps/${appToken}/tables/${tableId}/fields/${fieldId}`);
    }
}

/**
 * 从环境变量获取飞书Bitable客户端
 */
function getFeishuBitable() {
    const appId = process.env.FEISHU_APP_ID;
    const appSecret = process.env.FEISHU_APP_SECRET;

    if (!appId || !appSecret) {
        throw new Error('请设置环境变量 FEISHU_APP_ID 和 FEISHU_APP_SECRET');
    }

    return new FeishuBitable(appId, appSecret);
}

module.exports = { FeishuBitable, getFeishuBitable };
