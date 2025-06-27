#!/usr/bin/env node

/**
 * Build script for SqueakJS to WASM VM
 * Compiles WAT files to WASM using wasm-tools
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

function main() {
    console.log('SqueakJS to WASM Build Script (using wasm-tools)');
    console.log('=================================================');

    // Check if wasm-tools is installed
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

    // Show wasm-tools version
    try {
        const version = execSync('wasm-tools --version', { encoding: 'utf8' }).trim();
        console.log(`Using ${version}\n`);
    } catch (error) {
        console.log('Using wasm-tools (version unknown)\n');
    }

    // Ensure output directory exists
    const outputDir = 'dist';
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    // Compile WAT files to WASM
    const watFiles = [
        'squeak-vm-core.wat'
    ];

    let allSuccess = true;

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

        if (!validateWasmFile(wasmFile)) {
            allSuccess = false;
            continue;
        }
    }

    // Copy JavaScript files
    const jsFiles = [
        'squeak-vm.js'
    ];

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

    // Create test HTML file
    const testHtml = `<!DOCTYPE html>
<html>
<head>
    <title>SqueakJS WASM VM Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .result { background: #f0f8ff; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .error { background: #ffe0e0; padding: 10px; margin: 10px 0; border-radius: 5px; }
        button { padding: 10px 20px; font-size: 16px; margin: 5px; }
    </style>
</head>
<body>
    <h1>SqueakJS WASM VM Test</h1>
    <p>This page tests the minimal SqueakJS WASM VM with a 3 + 4 = 7 example.</p>
    
    <button id="runTest">Run 3 + 4 Test</button>
    <button id="clearResults">Clear Results</button>
    
    <div id="output"></div>

    <script src="squeak-vm.js"></script>
    <script>
        let vm = null;
        const output = document.getElementById('output');

        async function initVM() {
            if (!vm) {
                vm = new SqueakWASMVM();
                const success = await vm.initialize();
                if (!success) {
                    throw new Error('Failed to initialize VM');
                }
            }
        }

        document.getElementById('runTest').addEventListener('click', async () => {
            try {
                await initVM();
                
                const startTime = performance.now();
                const results = await vm.runMinimalExample();
                const endTime = performance.now();
                
                const div = document.createElement('div');
                div.className = 'result';
                div.innerHTML = \`
                    <strong>Test Result:</strong> \${results.join(', ')}<br>
                    <strong>Expected:</strong> 7<br>
                    <strong>Status:</strong> \${results.includes(7) ? '✓ PASS' : '✗ FAIL'}<br>
                    <strong>Execution Time:</strong> \${(endTime - startTime).toFixed(2)}ms
                \`;
                output.appendChild(div);
            } catch (error) {
                const div = document.createElement('div');
                div.className = 'error';
                div.innerHTML = \`<strong>Error:</strong> \${error.message}\`;
                output.appendChild(div);
            }
        });

        document.getElementById('clearResults').addEventListener('click', () => {
            output.innerHTML = '';
        });
    </script>
</body>
</html>`;

    fs.writeFileSync(path.join(outputDir, 'test.html'), testHtml);
    console.log('✓ Created test.html');

    // Final status
    console.log('');
    if (allSuccess) {
        console.log('🎉 Build completed successfully!');
        console.log('');
        console.log('To test:');
        console.log(`  cd ${outputDir}`);
        console.log('  python3 -m http.server 8000  # or any static file server');
        console.log('  open http://localhost:8000/test.html');
    } else {
        console.log('❌ Build completed with errors');
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { compileWatToWasm, validateWasmFile };
