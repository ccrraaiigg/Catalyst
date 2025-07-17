#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Starting SqueakWASM with LLM optimization...\n');

// Start API proxy
console.log('🔗 Starting API proxy server...');
const proxy = spawn('node', ['api-proxy.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    cwd: __dirname
});

proxy.stdout.on('data', (data) => {
    console.log(`[PROXY] ${data}`);
});

proxy.stderr.on('data', (data) => {
    console.error(`[PROXY] ${data}`);
});

// Give proxy time to start
setTimeout(() => {
    console.log('🌐 Starting web server...');
    const server = spawn('node', ['serve-coi.js', 'dist', '8000'], {
        stdio: ['pipe', 'pipe', 'pipe'],
        cwd: __dirname
    });

    server.stdout.on('data', (data) => {
        console.log(`[SERVER] ${data}`);
    });

    server.stderr.on('data', (data) => {
        console.error(`[SERVER] ${data}`);
    });

    server.on('close', (code) => {
        console.log(`🛑 Web server stopped with code ${code}`);
        proxy.kill();
        process.exit(code);
    });

    // Handle cleanup
    process.on('SIGINT', () => {
        console.log('\n🛑 Shutting down...');
        proxy.kill();
        server.kill();
        process.exit(0);
    });
    
}, 2000);

proxy.on('close', (code) => {
    console.log(`🛑 API proxy stopped with code ${code}`);
    process.exit(code);
});

console.log('\n📍 Once both servers are running:');
console.log('   Open: http://localhost:8000/test.html');
console.log('   The VM will have LLM optimization enabled');
console.log('   Press Ctrl+C to stop both servers\n'); 