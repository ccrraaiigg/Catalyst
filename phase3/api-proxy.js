#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8001;

// Read API keys for both providers
let apiKeys = {};
let primaryProvider = null;

try {
    const keysPath = path.join(__dirname, 'dist', 'keys');
    const keysContent = fs.readFileSync(keysPath, 'utf8');
    const lines = keysContent.split('\n');
    const keyOrder = [];
    
    for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#')) {
            if (trimmed.includes('=')) {
                const [key, value] = trimmed.split('=', 2);
                if (key && value) {
                    const provider = key.trim().toLowerCase();
                    const apiKey = value.trim();
                    
                    if ((provider === 'openai' && apiKey.startsWith('sk-')) ||
                        (provider === 'anthropic' && apiKey.startsWith('sk-ant-'))) {
                        apiKeys[provider] = apiKey;
                        if (!keyOrder.includes(provider)) {
                            keyOrder.push(provider);
                        }
                    }
                }
            }
        }
    }
    
    primaryProvider = keyOrder[0];
} catch (error) {
    console.error('❌ Could not read API keys:', error.message);
    process.exit(1);
}

if (!primaryProvider || !apiKeys[primaryProvider]) {
    console.error('❌ No valid API keys found in dist/keys file');
    console.error('💡 Expected format: openai=sk-proj-... or anthropic=sk-ant-api03-...');
    process.exit(1);
}

const server = http.createServer(async (req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key, anthropic-version');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // Handle both OpenAI and Anthropic endpoints
    if (req.method === 'POST' && (req.url === '/api/openai' || req.url === '/api/anthropic')) {
        let body = '';
        
        req.on('data', chunk => {
            body += chunk.toString();
        });
        
        req.on('end', async () => {
            try {
                const requestData = JSON.parse(body);
                const isOpenAI = req.url === '/api/openai';
                const provider = isOpenAI ? 'openai' : 'anthropic';
                
                // Check if we have the requested provider's key
                if (!apiKeys[provider]) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ 
                        error: `${provider.toUpperCase()} API key not configured. Available providers: ${Object.keys(apiKeys).join(', ')}` 
                    }));
                    return;
                }
                
                console.log(`🔄 Proxying request to ${provider.toUpperCase()} API...`);
                console.log('📝 Prompt length:', requestData.messages?.[0]?.content?.length || 0);
                
                let apiUrl, headers;
                
                if (isOpenAI) {
                    // OpenAI configuration
                    apiUrl = 'https://api.openai.com/v1/chat/completions';
                    headers = {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${apiKeys.openai}`
                    };
                } else {
                    // Anthropic configuration
                    apiUrl = 'https://api.anthropic.com/v1/messages';
                    headers = {
                        'Content-Type': 'application/json',
                        'x-api-key': apiKeys.anthropic,
                        'anthropic-version': '2023-06-01'
                    };
                }
                
                // Forward request to the appropriate API
                const response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: headers,
                    body: JSON.stringify(requestData)
                });
                
                const data = await response.json();
                
                if (!response.ok) {
                    console.error(`❌ ${provider.toUpperCase()} API error:`, response.status, data);
                    res.writeHead(response.status, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify(data));
                    return;
                }
                
                console.log(`✅ ${provider.toUpperCase()} API response received`);
                console.log('📊 Usage:', data.usage);
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
                
            } catch (error) {
                console.error('❌ Proxy error:', error.message);
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: error.message }));
            }
        });
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log('🔗 Multi-Provider LLM API Proxy Server running!');
    console.log(`📍 URL: http://localhost:${PORT}`);
    console.log(`🔑 Primary provider: ${primaryProvider.toUpperCase()}`);
    console.log(`🔑 Available providers: ${Object.keys(apiKeys).map(p => p.toUpperCase()).join(', ')}`);
    console.log(`📡 Endpoints: /api/openai, /api/anthropic`);
    console.log('🌐 CORS enabled for localhost:8000');
    console.log('💡 To switch providers, reorder keys in the "keys" file');
    console.log('🛑 Press Ctrl+C to stop');
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down API proxy server...');
    server.close();
    process.exit(0);
}); 