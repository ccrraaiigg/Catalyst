// Only run main if this is#!/usr/bin/env node

/**
 * Build script for SqueakJS to WASM VM - Phase 3: JIT Compilation Support
 * Compiles WAT files to WASM using wasm-tools and sets up JIT compilation interface
 * Fixed to properly handle UTF-8 character encoding for emoji and symbols
 */

const fs = require('fs');
const { execSync } = require('child_process');
const path = require('path');

function checkWasmToolsInstalled() {
    try {
        execSync('wasm-tools --version', { stdio: 'ignore' });
        return true;
    } catch (error) {
        return false;
    }
}

function compileWatToWasm(watFile, wasmFile) {
    try {
        console.log(`Compiling ${watFile} to ${wasmFile}...`);
        
        const command = `wasm-tools parse "${watFile}" -o "${wasmFile}"`;
        execSync(command, { stdio: 'inherit' });
        
        console.log(`✓ Successfully compiled ${wasmFile}`);
        return true;
    } catch (error) {
        console.error(`✗ Failed to compile ${watFile}:`, error.message);
        return false;
    }
}

function dumpWasm(wasmFile) {
    try {
        console.log(`Dumping ${wasmFile}...`);
        
        const command = `wasm-tools dump "${wasmFile}" > dump`;
        execSync(command, { stdio: 'inherit' });
        
        console.log(`✓ Successfully dumped ${wasmFile}`);
        return true;
    } catch (error) {
        console.error(`✗ Failed to dump ${wasmFile}:`, error.message);
        return false;
    }
}

function validateWasmFile(wasmFile) {
    try {
        console.log(`Validating ${wasmFile}...`);
        
        const command = `wasm-tools validate "${wasmFile}"`;
        execSync(command, { stdio: 'inherit' });
        
        console.log(`✓ ${wasmFile} is valid`);
        return true;
    } catch (error) {
        console.error(`✗ ${wasmFile} validation failed:`, error.message);
        return false;
    }
}

function createTestHtml() {
    const testHtml = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SqueakWASM VM - Phase 3: JIT Compilation Test</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            margin: 20px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 40px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .header h1 {
            margin: 0 0 10px 0;
            font-size: 2.5em;
            font-weight: 300;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .header .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
            margin-bottom: 20px;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        
        .feature {
            background: rgba(255, 255, 255, 0.15);
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .controls {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .control-group {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(5px);
            padding: 25px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .control-group h3 {
            margin: 0 0 20px 0;
            color: #fff;
            font-size: 1.3em;
        }
        
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 20px;
            margin: 8px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.3);
            width: 100%;
            min-height: 45px;
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
            background: linear-gradient(135deg, #5a6fd8 0%, #6b4190 100%);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        button.primary {
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            font-size: 16px;
            font-weight: 600;
        }
        
        button.secondary {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
        }
        
        button.toggle {
            background: linear-gradient(135deg, #FF9800 0%, #F57000 100%);
        }
        
        button.toggle.active {
            background: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%);
        }
        
        .output {
            background: rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 25px;
            margin-top: 30px;
            font-family: 'Consolas', 'Monaco', monospace;
            white-space: pre-wrap;
            overflow-y: auto;
            max-height: 400px;
        }
        
        .result {
            color: #4CAF50;
            font-weight: bold;
        }
        
        .error {
            color: #f44336;
            font-weight: bold;
        }
        
        .info {
            color: #2196F3;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        
        .stat {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #4CAF50;
            margin-bottom: 5px;
        }
        
        .stat-label {
            opacity: 0.8;
            font-size: 0.9em;
        }
        
        .status {
            background: rgba(0, 0, 0, 0.2);
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            border-left: 4px solid #4CAF50;
        }
        
        .status.ready {
            border-left-color: #4CAF50;
        }
        
        .status.error {
            border-left-color: #f44336;
        }
        
        @media (max-width: 768px) {
            .controls {
                grid-template-columns: 1fr;
            }
            
            .features {
                grid-template-columns: 1fr;
            }
            
            .stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 SqueakWASM VM</h1>
            <div class="subtitle">Phase 3: JIT Compilation Support</div>
            
            <div class="features">
                <div class="feature">⚡ Bytecode-to-WASM JIT compilation</div>
                <div class="feature">🔥 Hot method detection and compilation</div>
                <div class="feature">📊 JIT compilation statistics</div>
                <div class="feature">🎛️ Same "3 squared" example with translated methods</div>
                <div class="feature">🔧 Performance monitoring and debug modes</div>
            </div>
            
            <div class="status ready" id="status">
                <strong>🎯 SqueakWASM VM Phase 3 Ready</strong><br>
                Click "Run (3 squared) with JIT" to start!
            </div>
        </div>

        <div class="controls">
            <div class="control-group">
                <h3>🧪 Test Execution</h3>
                <button id="runExample" class="primary">🚀 Run (3 squared) with JIT</button>
                <button id="runMultiple" class="secondary">🔄 Run Multiple Times</button>
            </div>
            
            <div class="control-group">
                <h3>⚙️ JIT Controls</h3>
                <button id="toggleJIT" class="toggle active">🔧 JIT: ON</button>
                <button id="toggleDebug" class="toggle">🐛 Debug: OFF</button>
            </div>
            
            <div class="control-group">
                <h3>📊 Analysis</h3>
                <button id="showStats">📈 Show Statistics</button>
                <button id="clearResults">🗑️ Clear Results</button>
            </div>
        </div>
        
        <div class="stats" id="statsContainer">
            <div class="stat">
                <div class="stat-value" id="execTime">-</div>
                <div class="stat-label">Execution Time (ms)</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="jitCount">-</div>
                <div class="stat-label">JIT Compilations</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="cacheHits">-</div>
                <div class="stat-label">Cached Methods</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="jitStatus">ON</div>
                <div class="stat-label">JIT Status</div>
            </div>
        </div>

        <div class="output" id="output">
<strong>🎉 SqueakWASM VM Phase 3 - JIT Compilation Test Interface</strong>

This page demonstrates bytecode-to-WASM Just-In-Time compilation in the SqueakWASM virtual machine.

<strong>🎯 Test Features:</strong>
• Runtime bytecode translation to WebAssembly
• Hot method detection and automatic compilation
• Performance monitoring and statistics
• Debug mode with detailed compilation logs

<strong>🚀 Getting Started:</strong>
1. Click "Run (3 squared) with JIT" to execute the basic example
2. Use "Run Multiple Times" to trigger JIT compilation (threshold: 10 invocations)
3. Toggle JIT compilation and debug modes to see different behaviors
4. View statistics to monitor performance improvements

Ready to test JIT compilation!
        </div>
    </div>

    <script type="module" src="squeak-vm.js"></script>
    <script type="module">
        let vm = null;
        let jitEnabled = true;
        let debugMode = false;
        
        const stats = {
            executionTime: 0,
            jitCompilations: 0,
            cachedMethods: 0,
            jitEnabled: true
        };

        async function initVM() {
            if (!vm) {
                try {
                    addOutput('<strong>🔧 Initializing SqueakWASM VM...</strong>');
                    vm = new SqueakVM();
                    await vm.initialize();
                    addOutput('<strong>✅ VM initialized successfully!</strong>\\n');
                } catch (error) {
                    addOutput(\`<strong>❌ VM initialization failed:</strong> \${error.message}\`, 'error');
                    throw error;
                }
            }
        }

        function addOutput(text, className = '') {
            const output = document.getElementById('output');
            const line = document.createElement('div');
            if (className) line.className = className;
            line.innerHTML = text;
            output.appendChild(line);
            output.scrollTop = output.scrollHeight;
        }

        function updateStats(newStats) {
            document.getElementById('execTime').textContent = newStats.executionTime.toFixed(2);
            document.getElementById('jitCount').textContent = newStats.jitCompilations;
            document.getElementById('cacheHits').textContent = newStats.cachedMethods;
            document.getElementById('jitStatus').textContent = newStats.jitEnabled ? 'ON' : 'OFF';
            
            Object.assign(stats, newStats);
        }

        // Event Listeners
        document.getElementById('runExample').addEventListener('click', async () => {
            try {
                await initVM();
                
                addOutput('<strong>🚀 Running 3 squared with JIT compilation...</strong>');
                
                // Configure VM settings
                vm.setJITEnabled(jitEnabled);
                vm.setDebugMode(debugMode);
                
                const startTime = performance.now();
                const result = await vm.runMinimalExample();
                const endTime = performance.now();
                
                const success = result.results && result.results.includes(9);
                const stats = vm.getJITStatistics();
                
                addOutput(\`
                    <strong>📊 Execution Result:</strong> \${success ? '✅ PASSED' : '❌ FAILED'}<br>
                    • Result: \${result.results ? result.results.join(', ') : 'No results'}<br>
                    • Execution Time: \${(endTime - startTime).toFixed(2)}ms<br>
                    • JIT Compilations: \${result.jitCompilations || 0}<br>
                    • JIT Status: \${jitEnabled ? 'Enabled' : 'Disabled'}
                \`, success ? 'result' : 'error');
                
                updateStats({
                    executionTime: endTime - startTime,
                    jitCompilations: result.jitCompilations || 0,
                    cachedMethods: stats.cachedMethods || 0,
                    jitEnabled: jitEnabled
                });
                
            } catch (error) {
                addOutput(\`<strong>❌ Error:</strong> \${error.message}\`, 'error');
            }
        });

        document.getElementById('runMultiple').addEventListener('click', async () => {
            try {
                await initVM();
                
                addOutput('<strong>🔄 Running multiple tests to trigger JIT compilation...</strong>');
                
                vm.setJITEnabled(jitEnabled);
                vm.setDebugMode(debugMode);
                
                const runs = 15; // Exceed JIT threshold
                const results = [];
                
                for (let i = 0; i < runs; i++) {
                    const startTime = performance.now();
                    const result = await vm.runMinimalExample();
                    const endTime = performance.now();
                    
                    results.push({
                        ...result,
                        executionTime: endTime - startTime
                    });
                    
                    if (i === 0 || i === 4 || i === 9 || i === 14) {
                        addOutput(\`Run \${i + 1}: \${result.results ? result.results[0] : 'N/A'} (JIT: \${result.jitCompilations || 0}, Time: \${(endTime - startTime).toFixed(2)}ms)\`);
                    }
                }
                
                const totalJIT = results.reduce((sum, r) => sum + (r.jitCompilations || 0), 0);
                const avgTime = results.reduce((sum, r) => sum + r.executionTime, 0) / runs;
                const vmStats = vm.getJITStatistics();
                
                addOutput(\`
                    <strong>📊 Multiple Run Summary:</strong><br>
                    • Total Runs: \${runs}<br>
                    • Total JIT Compilations: \${totalJIT}<br>
                    • Average Execution Time: \${avgTime.toFixed(2)}ms<br>
                    • Cached Methods: \${vmStats.cachedMethods || 0}<br>
                    • All results correct: \${results.every(r => r.results && r.results.includes(9)) ? '✅ YES' : '❌ NO'}
                \`, 'result');
                
                updateStats({
                    executionTime: avgTime,
                    jitCompilations: totalJIT,
                    cachedMethods: vmStats.cachedMethods || 0,
                    jitEnabled: jitEnabled
                });
                
            } catch (error) {
                addOutput(\`<strong>❌ Error:</strong> \${error.message}\`, 'error');
            }
        });

        document.getElementById('toggleJIT').addEventListener('click', () => {
            jitEnabled = !jitEnabled;
            const button = document.getElementById('toggleJIT');
            button.textContent = jitEnabled ? '🔧 JIT: ON' : '🔧 JIT: OFF';
            button.className = jitEnabled ? 'toggle active' : 'toggle';
            
            if (vm) {
                vm.setJITEnabled(jitEnabled);
            }
            
            addOutput(\`🔧 JIT Compilation \${jitEnabled ? 'ENABLED' : 'DISABLED'}\`, 'info');
            updateStats({...stats, jitEnabled});
        });

        document.getElementById('toggleDebug').addEventListener('click', () => {
            debugMode = !debugMode;
            const button = document.getElementById('toggleDebug');
            button.textContent = debugMode ? '🐛 Debug: ON' : '🐛 Debug: OFF';
            button.className = debugMode ? 'toggle active' : 'toggle';
            
            if (vm) {
                vm.setDebugMode(debugMode);
            }
            
            addOutput(\`🐛 Debug Mode \${debugMode ? 'ENABLED' : 'DISABLED'}\`, 'info');
        });

        document.getElementById('showStats').addEventListener('click', () => {
            if (vm) {
                const vmStats = vm.getJITStatistics();
                addOutput(\`
                    <strong>📊 Detailed JIT Statistics:</strong><br>
                    • Total Method Invocations: \${vmStats.totalInvocations || 0}<br>
                    • JIT Compilation Threshold: \${vmStats.jitThreshold || 10}<br>
                    • Compiled Methods in Cache: \${vmStats.cachedMethods || 0}<br>
                    • Cache Hit Rate: \${vmStats.cacheHitRate || 0}%<br>
                    • Average Compilation Time: \${vmStats.avgCompilationTime || 0}ms<br>
                    • JIT Enabled: \${jitEnabled ? 'Yes' : 'No'}<br>
                    • Debug Mode: \${debugMode ? 'Yes' : 'No'}
                \`, 'info');
            } else {
                addOutput('🔧 VM not initialized. Run a test first.', 'info');
            }
        });

        document.getElementById('clearResults').addEventListener('click', () => {
            document.getElementById('output').innerHTML = \`
<strong>🎉 SqueakWASM VM Phase 3 - JIT Compilation Test Interface</strong>

This page demonstrates bytecode-to-WASM Just-In-Time compilation in the SqueakWASM virtual machine.

<strong>🎯 Test Features:</strong>
• Runtime bytecode translation to WebAssembly
• Hot method detection and automatic compilation
• Performance monitoring and statistics
• Debug mode with detailed compilation logs

<strong>🚀 Getting Started:</strong>
1. Click "Run (3 squared) with JIT" to execute the basic example
2. Use "Run Multiple Times" to trigger JIT compilation (threshold: 10 invocations)
3. Toggle JIT compilation and debug modes to see different behaviors
4. View statistics to monitor performance improvements

Ready to test JIT compilation!
            \`;
            
            updateStats({
                executionTime: 0,
                jitCompilations: 0,
                cachedMethods: 0,
                jitEnabled: jitEnabled
            });
        });

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', () => {
            addOutput('🚀 Phase 3 JIT Compilation Test Interface loaded!\\n');
            addOutput('💡 <strong>Tip:</strong> Use "Run Multiple Times" to see JIT compilation kick in after the threshold is reached.\\n');
        });
    </script>
</body>
</html>`;
    
    return testHtml;
}

function main() {
    console.log('SqueakWASM Build Script - Phase 3: JIT Compilation Support');
    console.log('================================================================');

    if (!checkWasmToolsInstalled()) {
        console.error('Error: wasm-tools not found!');
        console.error('Please install wasm-tools: https://github.com/bytecodealliance/wasm-tools');
        console.error('');
        console.error('Installation options:');
        console.error('  cargo install wasm-tools');
        console.error('  brew install wasm-tools  (macOS)');
        console.error('  Download from: https://github.com/bytecodealliance/wasm-tools/releases');
        process.exit(1);
    }

    try {
        const version = execSync('wasm-tools --version', { encoding: 'utf8' }).trim();
        console.log(`Using ${version}\n`);
    } catch (error) {
        console.log('Using wasm-tools (version unknown)\n');
    }

    const outputDir = 'dist';
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const watFiles = ['squeak-vm-core.wat'];
    let allSuccess = true;

    // Compile WAT files to WASM
    for (const watFile of watFiles) {
        if (!fs.existsSync(watFile)) {
            console.error(`✗ WAT file not found: ${watFile}`);
            allSuccess = false;
            continue;
        }

        const wasmFile = path.join(outputDir, watFile.replace('.wat', '.wasm'));
        
        if (!compileWatToWasm(watFile, wasmFile)) {
            allSuccess = false;
            continue;
        }

        if (!dumpWasm(wasmFile)) {
            allSuccess = false;
            continue;
        }

        if (!validateWasmFile(wasmFile)) {
            allSuccess = false;
            continue;
        }
    }

    // Copy JavaScript files
    const jsFiles = ['squeak-vm.js'];

    for (const jsFile of jsFiles) {
        if (fs.existsSync(jsFile)) {
            const destFile = path.join(outputDir, jsFile);
            fs.copyFileSync(jsFile, destFile);
            console.log(`✓ Copied ${jsFile} to ${destFile}`);
        } else {
            console.error(`✗ JavaScript file not found: ${jsFile}`);
            allSuccess = false;
        }
    }

    // Create enhanced test HTML file for Phase 3 with proper UTF-8 encoding
    const testHtmlPath = path.join(outputDir, 'test.html');
    fs.writeFileSync(testHtmlPath, createTestHtml(), 'utf8');
    console.log(`✓ Created enhanced test.html with JIT compilation features and proper UTF-8 encoding`);

    // Create package info
    const packageInfo = {
        name: 'squeakwasm-phase3',
        version: '3.0.0',
        description: 'SqueakWASM VM Phase 3: JIT Compilation Support',
        phase: 3,
        features: [
            'Real bytecode-to-WASM JIT compilation using CDN-loaded WASM tools',
            'Hot method detection and compilation',
            'JIT compilation statistics',
            'Performance monitoring',
            'Debug mode support',
            'Enhanced 3 squared example with translated methods',
            'Proper UTF-8 character encoding for emoji and symbols',
            'No build step required - loads tools from CDN'
        ],
        buildDate: new Date().toISOString(),
        files: {
            wasm: watFiles.map(f => f.replace('.wat', '.wasm')),
            javascript: jsFiles,
            test: 'test.html'
        }
    };

    fs.writeFileSync(
        path.join(outputDir, 'package-info.json'), 
        JSON.stringify(packageInfo, null, 2),
        'utf8'
    );
    console.log(`✓ Created package-info.json`);

    if (allSuccess) {
        console.log('\n🎉 Phase 3 build completed successfully!');
        console.log('\nTo test the JIT compilation:');
        console.log('1. Start a web server: python -m http.server 8000');
        console.log('2. Open: http://localhost:8000/dist/test.html');
        console.log('3. Click "🚀 Run (3 squared) with JIT" to see JIT compilation in action');
        console.log('4. Use "🔄 Run Multiple Times" to trigger JIT compilation thresholds');
        console.log('\nPhase 3 Features:');
        console.log('• ⚡ Bytecode-to-WASM translation during execution');
        console.log('• 📊 JIT compilation statistics and monitoring');
        console.log('• 🔧 Runtime JIT enable/disable toggle');
        console.log('• 🐛 Debug mode for detailed compilation logs');
        console.log('• 🚀 Performance improvements for hot methods');
        console.log('• 🎨 Proper UTF-8 character display for all emoji and symbols');
        console.log('• 🌐 CDN-based WASM tools loading without build dependencies');
    } else {
        console.log('\n❌ Build completed with errors');
        process.exit(1);
    }
}

// Only run main if this is the main module
if (require.main === module) {
    main();
}

module.exports = {
    compileWatToWasm,
    dumpWasm,
    validateWasmFile,
    createTestHtml
};