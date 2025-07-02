#!/usr/bin/env node

/**
 * Build script for SqueakJS to WASM VM - Phase 3: JIT Compilation Support
 * Compiles WAT files to WASM using wasm-tools and sets up JIT compilation interface
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
        console.error(`✗ Failed to dump ${watFile}:`, error.message);
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
<html>
<head>
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
            max-width: 1000px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        h1 { 
            text-align: center; 
            margin-bottom: 10px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        .subtitle {
            text-align: center;
            font-size: 1.2em;
            margin-bottom: 30px;
            opacity: 0.9;
        }
        .controls {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        button { 
            padding: 12px 24px; 
            font-size: 16px; 
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            backdrop-filter: blur(5px);
        }
        button:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
        }
        button:active {
            transform: translateY(0);
        }
        .result { 
            background: rgba(0, 255, 0, 0.1); 
            padding: 15px; 
            margin: 15px 0; 
            border-radius: 8px; 
            border-left: 4px solid #00ff00;
            backdrop-filter: blur(5px);
        }
        .error { 
            background: rgba(255, 0, 0, 0.1); 
            padding: 15px; 
            margin: 15px 0; 
            border-radius: 8px; 
            border-left: 4px solid #ff0000;
            backdrop-filter: blur(5px);
        }
        .info {
            background: rgba(0, 150, 255, 0.1);
            padding: 15px;
            margin: 15px 0;
            border-radius: 8px;
            border-left: 4px solid #0096ff;
            backdrop-filter: blur(5px);
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            backdrop-filter: blur(5px);
        }
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #00ff88;
        }
        .stat-label {
            font-size: 0.9em;
            opacity: 0.8;
            margin-top: 5px;
        }
        #output {
            max-height: 400px;
            overflow-y: auto;
            background: rgba(0, 0, 0, 0.2);
            padding: 20px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
        }
        .toggle {
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 8px 16px;
            font-size: 14px;
        }
        .toggle.active {
            background: rgba(0, 255, 0, 0.3);
            border-color: #00ff00;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 SqueakWASM VM</h1>
        <div class="subtitle">Phase 3: JIT Compilation Support</div>
        
        <div class="info">
            <strong>Phase 3 Features:</strong>
            <ul>
                <li>✨ Bytecode-to-WASM JIT compilation</li>
                <li>⚡ Hot method detection and compilation</li>
                <li>📊 JIT compilation statistics</li>
                <li>🔄 Same "3 squared" example with translated methods</li>
                <li>🎯 Performance monitoring and debug modes</li>
            </ul>
        </div>
        
        <div class="controls">
            <button id="runTest">🚀 Run (3 squared) with JIT</button>
            <button id="runMultiple">🔄 Run Multiple Times</button>
            <button id="toggleJIT" class="toggle">🔧 Toggle JIT</button>
            <button id="toggleDebug" class="toggle">🐛 Toggle Debug</button>
            <button id="clearResults">🗑️ Clear Results</button>
            <button id="showStats">📊 Show Statistics</button>
        </div>
        
        <div class="stats" id="statsPanel" style="display: none;">
            <div class="stat-card">
                <div class="stat-value" id="executionTime">--</div>
                <div class="stat-label">Execution Time (ms)</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="jitCompilations">--</div>
                <div class="stat-label">JIT Compilations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="cachedMethods">--</div>
                <div class="stat-label">Cached Methods</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="jitStatus">--</div>
                <div class="stat-label">JIT Status</div>
            </div>
        </div>
        
        <div id="output"></div>
    </div>

    <script src="squeak-vm.js"></script>
    <script>
        let vm = null;
        let jitEnabled = true;
        let debugEnabled = false;
        const output = document.getElementById('output');

        async function initVM() {
            if (!vm) {
                vm = new SqueakWASMVM();
                vm.enableJIT(jitEnabled);
                vm.setDebugMode(debugEnabled);
                
                const success = await vm.initialize();
                if (!success) {
                    throw new Error('Failed to initialize VM');
                }
                
                updateToggleButtons();
            }
        }

        function addOutput(content, className = 'info') {
            const div = document.createElement('div');
            div.className = className;
            div.innerHTML = content;
            output.appendChild(div);
            output.scrollTop = output.scrollHeight;
        }

        function updateStats(stats) {
            document.getElementById('executionTime').textContent = 
                stats.executionTime ? stats.executionTime.toFixed(2) : '--';
            document.getElementById('jitCompilations').textContent = 
                stats.jitCompilations || '--';
            document.getElementById('cachedMethods').textContent = 
                stats.cachedMethods || '--';
            document.getElementById('jitStatus').textContent = 
                stats.jitEnabled ? '✅ ON' : '❌ OFF';
        }

        function updateToggleButtons() {
            const jitButton = document.getElementById('toggleJIT');
            const debugButton = document.getElementById('toggleDebug');
            
            jitButton.textContent = jitEnabled ? '🔧 JIT: ON' : '🔧 JIT: OFF';
            jitButton.classList.toggle('active', jitEnabled);
            
            debugButton.textContent = debugEnabled ? '🐛 Debug: ON' : '🐛 Debug: OFF';
            debugButton.classList.toggle('active', debugEnabled);
        }

        document.getElementById('runTest').addEventListener('click', async () => {
            try {
                await initVM();
                
                addOutput('<strong>🚀 Starting "3 squared" test with JIT compilation...</strong>');
                
                const result = await vm.runMinimalExample();
                const stats = vm.getJITStatistics();
                
                const success = result.results.includes(9);
                addOutput(\`
                    <strong>📋 Test Results:</strong><br>
                    • Result: \${result.results.join(', ')}<br>
                    • Expected: 9<br>
                    • Status: \${success ? '✅ PASSED' : '❌ FAILED'}<br>
                    • Execution Time: \${result.executionTime.toFixed(2)}ms<br>
                    • JIT Compilations: \${result.jitCompilations}<br>
                    • JIT Status: \${jitEnabled ? 'Enabled' : 'Disabled'}
                \`, success ? 'result' : 'error');
                
                updateStats({
                    executionTime: result.executionTime,
                    jitCompilations: result.jitCompilations,
                    cachedMethods: stats.cachedMethods,
                    jitEnabled: stats.jitEnabled
                });
                
            } catch (error) {
                addOutput(\`<strong>❌ Error:</strong> \${error.message}\`, 'error');
            }
        });

        document.getElementById('runMultiple').addEventListener('click', async () => {
            try {
                await initVM();
                
                addOutput('<strong>🔄 Running multiple tests to trigger JIT compilation...</strong>');
                
                const runs = 15; // Exceed JIT threshold
                const results = [];
                
                for (let i = 0; i < runs; i++) {
                    const result = await vm.runMinimalExample();
                    results.push(result);
                    
                    if (i === 0 || i === 4 || i === 9 || i === 14) {
                        addOutput(\`Run \${i + 1}: \${result.results[0]} (JIT: \${result.jitCompilations})\`);
                    }
                }
                
                const lastResult = results[results.length - 1];
                const totalJIT = results.reduce((sum, r) => sum + r.jitCompilations, 0);
                const avgTime = results.reduce((sum, r) => sum + r.executionTime, 0) / runs;
                const stats = vm.getJITStatistics();
                
                addOutput(\`
                    <strong>📊 Multiple Run Summary:</strong><br>
                    • Total Runs: \${runs}<br>
                    • Total JIT Compilations: \${totalJIT}<br>
                    • Average Execution Time: \${avgTime.toFixed(2)}ms<br>
                    • Cached Methods: \${stats.cachedMethods}<br>
                    • All results correct: \${results.every(r => r.results.includes(9)) ? '✅ YES' : '❌ NO'}
                \`, 'result');
                
                updateStats({
                    executionTime: avgTime,
                    jitCompilations: totalJIT,
                    cachedMethods: stats.cachedMethods,
                    jitEnabled: stats.jitEnabled
                });
                
            } catch (error) {
                addOutput(\`<strong>❌ Error:</strong> \${error.message}\`, 'error');
            }
        });

        document.getElementById('toggleJIT').addEventListener('click', () => {
            jitEnabled = !jitEnabled;
            if (vm) {
                vm.enableJIT(jitEnabled);
            }
            updateToggleButtons();
            addOutput(\`🔧 JIT compilation \${jitEnabled ? 'enabled' : 'disabled'}\`);
        });

        document.getElementById('toggleDebug').addEventListener('click', () => {
            debugEnabled = !debugEnabled;
            if (vm) {
                vm.setDebugMode(debugEnabled);
            }
            updateToggleButtons();
            addOutput(\`🐛 Debug mode \${debugEnabled ? 'enabled' : 'disabled'}\`);
        });

        document.getElementById('clearResults').addEventListener('click', () => {
            output.innerHTML = '';
            addOutput('<strong>🗑️ Results cleared</strong>');
        });

        document.getElementById('showStats').addEventListener('click', () => {
            const statsPanel = document.getElementById('statsPanel');
            const isVisible = statsPanel.style.display !== 'none';
            statsPanel.style.display = isVisible ? 'none' : 'grid';
            
            if (!isVisible && vm) {
                const stats = vm.getJITStatistics();
                updateStats({
                    jitCompilations: stats.compilationCount,
                    cachedMethods: stats.cachedMethods,
                    jitEnabled: stats.jitEnabled
                });
            }
        });

        // Initialize display
        updateToggleButtons();
        addOutput('<strong>🎯 SqueakWASM VM Phase 3 Ready</strong><br>Click "Run (3 squared) with JIT" to start!');
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

    // Create enhanced test HTML file for Phase 3
    const testHtmlPath = path.join(outputDir, 'test.html');
    fs.writeFileSync(testHtmlPath, createTestHtml());
    console.log(`✓ Created enhanced test.html with JIT compilation features`);

    // Create package info
    const packageInfo = {
        name: 'squeakwasm-phase3',
        version: '3.0.0',
        description: 'SqueakWASM VM Phase 3: JIT Compilation Support',
        phase: 3,
        features: [
            'Bytecode-to-WASM JIT compilation',
            'Hot method detection and compilation',
            'JIT compilation statistics',
            'Performance monitoring',
            'Debug mode support',
            'Enhanced 3 squared example with translated methods'
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
        JSON.stringify(packageInfo, null, 2)
    );
    console.log(`✓ Created package-info.json`);

    if (allSuccess) {
        console.log('\n🎉 Phase 3 build completed successfully!');
        console.log('\nTo test the JIT compilation:');
        console.log('1. Start a web server: python -m http.server 8000');
        console.log('2. Open: http://localhost:8000/dist/test.html');
        console.log('3. Click "Run (3 squared) with JIT" to see JIT compilation in action');
        console.log('4. Use "Run Multiple Times" to trigger JIT compilation thresholds');
        console.log('\nPhase 3 Features:');
        console.log('• ⚡ Bytecode-to-WASM translation during execution');
        console.log('• 📊 JIT compilation statistics and monitoring');
        console.log('• 🔧 Runtime JIT enable/disable toggle');
        console.log('• 🐛 Debug mode for detailed compilation logs');
        console.log('• 🚀 Performance improvements for hot methods');
    } else {
        console.log('\n❌ Build completed with errors');
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = {
    compileWatToWasm,
    dumpWasm,
    validateWasmFile,
    createTestHtml
};
