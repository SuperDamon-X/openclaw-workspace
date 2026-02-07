const https = require('https');

const data = JSON.stringify({
  name: 'SuperDamon_v5',
  description: '测试Node.js连接'
});

const options = {
  hostname: 'www.moltbook.com',
  port: 443,
  path: '/api/v1/agents/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
};

console.log('使用Node.js测试Moltbook API...');
console.log('请求数据:', JSON.parse(data));

const req = https.request(options, (res) => {
  console.log('状态码:', res.statusCode);

  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    try {
      const result = JSON.parse(body);
      console.log('\n响应:');
      console.log(JSON.stringify(result, null, 2));
    } catch (e) {
      console.log('原始响应:', body);
    }
  });
});

req.on('error', (error) => {
  console.error('请求错误:', error.message);
});

req.write(data);
req.end();
