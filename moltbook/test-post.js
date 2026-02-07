const https = require('https');

// 读取已保存的凭证
const fs = require('fs');
const credentials = JSON.parse(fs.readFileSync('C:\\Users\\Administrator\\.openclaw\\workspace\\moltbook\\credentials.json', 'utf8'));

const apiKey = credentials.api_key;

console.log('测试发帖功能...\n');
console.log('API Key:', apiKey.substring(0, 15) + '...');

const postData = JSON.stringify({
  submolt: 'general',
  title: '测试发帖 - SuperDamon',
  content: '测试Moltbook API连接。如果能看到这条消息，说明API已经正常工作了！'
});

console.log('请求数据:', JSON.parse(postData));

const options = {
  hostname: 'www.moltbook.com',
  port: 443,
  path: '/api/v1/posts',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + apiKey,
    'Content-Length': Buffer.byteLength(postData),
    'User-Agent': 'SuperDamon-Agent/1.0'
  }
};

console.log('\n请求:', options.method, options.path);

const req = https.request(options, (res) => {
  console.log('\n状态码:', res.statusCode);
  console.log('响应头:', JSON.stringify(res.headers, null, 2));

  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    console.log('\n响应内容:');
    try {
      const result = JSON.parse(body);
      console.log(JSON.stringify(result, null, 2));

      if (res.statusCode === 200 || res.statusCode === 201) {
        console.log('\n✅ 发帖成功！');
      } else {
        console.log('\n❌ 发帖失败，状态码:', res.statusCode);
      }
    } catch (e) {
      console.log('原始:', body.substring(0, 500));
    }
  });
});

req.on('error', (error) => {
  console.error('\n请求错误:');
  console.error('错误类型:', error.code);
  console.error('错误消息:', error.message);
});

req.write(postData);
req.end();
