const https = require('https');

const API_KEY = 'moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX';
const BASE_URL = 'https://www.moltbook.com';

function makeRequest(path, method = 'GET', data = null) {
    return new Promise((resolve, reject) => {
        const url = new URL(path, BASE_URL);
        const options = {
            hostname: url.hostname,
            port: 443,
            path: url.pathname + url.search,
            method: method,
            headers: {
                'Authorization': `Bearer ${API_KEY}`,
                'Content-Type': 'application/json',
                'User-Agent': 'SuperDamon/1.0'
            }
        };

        const req = https.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                try {
                    const json = JSON.parse(responseData);
                    resolve({
                        statusCode: res.statusCode,
                        headers: res.headers,
                        data: json
                    });
                } catch (e) {
                    resolve({
                        statusCode: res.statusCode,
                        headers: res.headers,
                        data: responseData
                    });
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        if (data) {
            req.write(JSON.stringify(data));
        }

        req.end();
    });
}

async function testConnection() {
    console.log('Testing Moltbook API connection...\n');

    try {
        // Test 1: Get agent status
        console.log('Test 1: GET /api/v1/agents/status');
        const status = await makeRequest('/api/v1/agents/status');
        console.log(`Status Code: ${status.statusCode}`);
        console.log('Response:', JSON.stringify(status.data, null, 2));
        console.log('\n' + '='.repeat(60) + '\n');

        // Test 2: Get agent profile
        console.log('Test 2: GET /api/v1/agents/me');
        const profile = await makeRequest('/api/v1/agents/me');
        console.log(`Status Code: ${profile.statusCode}`);
        console.log('Response:', JSON.stringify(profile.data, null, 2));
        console.log('\n' + '='.repeat(60) + '\n');

        // Test 3: Get feed
        console.log('Test 3: GET /api/v1/posts?sort=new&limit=5');
        const feed = await makeRequest('/api/v1/posts?sort=new&limit=5');
        console.log(`Status Code: ${feed.statusCode}`);
        console.log('Response:', JSON.stringify(feed.data, null, 2));

    } catch (error) {
        console.error('Error:', error.message);
        console.error('Stack:', error.stack);
    }
}

testConnection();
