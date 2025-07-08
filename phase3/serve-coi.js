#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');

// MIME types for different file extensions
const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.wasm': 'application/wasm',
    '.wat': 'text/plain',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon'
};

function getMimeType(filePath) {
    const ext = path.extname(filePath).toLowerCase();
    return mimeTypes[ext] || 'application/octet-stream';
}

function createServer(rootDir, port = 8000) {
    const server = http.createServer((req, res) => {
        const reqUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
        let pathname = reqUrl.pathname;
        
        // Default to test.html
        if (pathname === '/') {
            pathname = 'test.html';
        }
        
        // Remove leading slash to prevent path.join issues
        if (pathname.startsWith('/')) {
            pathname = pathname.slice(1);
        }
        
        const filePath = path.join(rootDir, pathname);
        const resolvedRootDir = path.resolve(rootDir);
        const resolvedFilePath = path.resolve(filePath);
        
        // Security check - prevent directory traversal
        if (!resolvedFilePath.startsWith(resolvedRootDir)) {
            res.writeHead(403, { 'Content-Type': 'text/plain' });
            res.end('403 Forbidden');
            return;
        }
        
        fs.readFile(filePath, (err, data) => {
            if (err) {
                if (err.code === 'ENOENT') {
                    res.writeHead(404, { 'Content-Type': 'text/plain' });
                    res.end('404 Not Found');
                } else {
                    res.writeHead(500, { 'Content-Type': 'text/plain' });
                    res.end('500 Internal Server Error');
                }
                return;
            }
            
            const mimeType = getMimeType(filePath);
            
            // Set cross-origin isolation headers for ALL responses
            const headers = {
                'Content-Type': mimeType,
                'Cross-Origin-Opener-Policy': 'same-origin',
                'Cross-Origin-Embedder-Policy': 'require-corp',
                'Cross-Origin-Resource-Policy': 'cross-origin'
            };
            
            // Add cache control for development
            if (pathname.endsWith('.wasm') || pathname.endsWith('.wat')) {
                headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
            }
            
            res.writeHead(200, headers);
            res.end(data);
        });
    });
    
    server.listen(port, () => {
        console.log(`🚀 SqueakWASM server running with cross-origin isolation!`);
        console.log(`📍 URL: http://localhost:${port}`);
        console.log(`📁 Serving: ${path.resolve(rootDir)}`);
        console.log(`⏱️  Timer resolution: 5μs (cross-origin isolated)`);
        console.log(`🛑 Press Ctrl+C to stop`);
    });
    
    return server;
}

// Run if this is the main module
if (require.main === module) {
    const args = process.argv.slice(2);
    const rootDir = args[0] || './dist';
    const port = parseInt(args[1]) || 8000;
    
    if (!fs.existsSync(rootDir)) {
        console.error(`❌ Directory not found: ${rootDir}`);
        console.log(`💡 Usage: node serve-coi.js [directory] [port]`);
        console.log(`💡 Example: node serve-coi.js dist 8000`);
        process.exit(1);
    }
    
    createServer(rootDir, port);
}

module.exports = { createServer }; 