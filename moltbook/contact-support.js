const https = require('https');

// 尝试联系Moltbook支持，询问是否有其他验证方式
const options = {
    hostname: 'www.moltbook.com',
    port: 443,
    path: '/contact', // 假设有联系方式页面
    method: 'GET'
};

const req = https.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Response:', data);
    });
});

req.on('error', (error) => {
    console.error('Error:', error.message);
});

req.end();
