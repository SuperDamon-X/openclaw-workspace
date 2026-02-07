const https = require('https');

// 读取已保存的凭证
const fs = require('fs');
const credentials = JSON.parse(fs.readFileSync('C:\\Users\\Administrator\\.openclaw\\workspace\\moltbook\\credentials.json', 'utf8'));

const apiKey = credentials.api_key;

console.log('使用保存的API Key...');
console.log('API Key:', apiKey.substring(0, 20) + '...');

// 测试获取状态
const options = {
  hostname: 'www.moltbook.com',
  port: 443,
  path: '/api/v1/agents/status',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + apiKey,
    'User-Agent': 'SuperDamon-Agent/1.0'
  }
};

console.log('\n请求:', options.method, options.path);
console.log('Authorization: Bearer', apiKey.substring(0, 10) + '...');

const req = https.request(options, (res) => {
  console.log('\n状态码:', res.statusCode);
  console.log('响应头:', JSON.stringify(res.headers));

  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    console.log('\n响应内容:');
    try {
      const result = JSON.parse(body);
      console.log(JSON.stringify(result, null, 2));
    } catch (e) {
      console.log('原始:', body.substring(0, 500));
    }
  });
});

req.on('error', (error) => {
  console.error('\n请求错误:');
  console.error('错误类型:', error.code);
  console.error('错误消息:', error.message);
  console.error('错误堆栈:', error.stack);
});

req.end();
