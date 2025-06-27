#!/usr/bin/env node

/**
 * Build script for SqueakJS to WASM VM
 * Compiles WAT files to WASM using wasm-tools with WASM GC support
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

function checkWasmToolsGCSupport() {
    try {
        // Create a minimal GC test file
        const testWat = `(module
          (type $test (struct (field i32)))
          (func (export "test") (result i32) (i32.const 42))
        )`;
        
        fs.writeFileSync('.test-gc.wat', testWat);
        execSync('wasm-tools parse ".test-gc.wat" -o ".test-gc.wasm"', { stdio: 'ignore' });
        
        // Clean up test files
        fs.unlinkSync('.test-gc.wat');
        fs.unlinkSync('.test-gc.wasm');
        
        return true;
    } catch (error) {
        // Clean up test files if they exist
        try {
            fs.unlinkSync('.test-gc.wat');
            fs.unlinkSync('.test-gc.wasm');
        } catch (e) {
            // Ignore cleanup errors
        }
        return false;
    }
}

function compileWatToWasm(watFile, wasmFile) {
    try {
        console.log(`Compiling ${watFile} to ${wasmFile}...`);
        
        // GC support is enabled by default in wasm-tools 1.235.0+
        const command = `wasm-tools parse "${watFile}" -o "${wasmFile}"`;
        execSync(command, { stdio: 'inherit' });
        
        console.log(`✓ Successfully compiled ${wasmFile}`);
        return true;
    } catch (error) {
        console.error(`✗ Failed to compile ${watFile}:`, error.message);
        console.error(`\nDebugging steps:`);
        console.error(`1. Check WASM GC support: wasm-tools --version (need 1.200+)`);
        console.error(`2. Validate WAT syntax: wasm-tools print "${watFile}"`);
        console.error(`3. Check type definitions and references`);
        console.error(`4. Ensure all type indices are valid (0-based)`);
        return false;
    }
}

function validateWasmFile(wasmFile) {
    try {
        console.log(`Validating ${wasmFile}...`);
        
        // GC support is enabled by default in validation
        const command = `wasm-tools validate "${wasmFile}"`;
        execSync(command, { stdio: 'inherit' });
        
        console.log(`✓ ${wasmFile} is valid`);
        return true;
    } catch (error) {
        console.error(`✗ ${wasmFile} validation failed:`, error.message);
        
        // Additional debugging info available if needed
        console.error(`\nTo debug further, run: wasm-tools print "${wasmFile}"`);
        
        return false;
    }
}

function copyFile(source, destination) {
    try {
        fs.copyFileSync(source, destination);
        console.log(`✓ Copied ${source} to ${destination}`);
        return true;
    } catch (error) {
        console.error(`✗ Failed to copy ${source}:`, error.message);
        return false;
    }
}

function createTestHtml() {
    const testHtml = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SqueakWASM VM Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .output {
            background: #f5f5f5;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
            white-space: pre-wrap;
        }
        button {
            background: #007cba;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover {
            background: #005a87;
        }
    </style>
</head>
<body>
    <h1>SqueakWASM VM Test</h1>
    <p>This tests the WASM VM running a simple Smalltalk computation: <code>3 + 4</code></p>
    
    <button onclick="runTest()">Run Test</button>
    <button onclick="clearOutput()">Clear Output</button>
    
    <div id="output" class="output"></div>

    <script src="squeak-vm.js"></script>
    <script>
        let vm = null;
        
        function log(message) {
            const output = document.getElementById('output');
            output.textContent += new Date().toLocaleTimeString() + ': ' + message + '\\n';
        }
        
        function clearOutput() {
            document.getElementById('output').textContent = '';
        }
        
        async function runTest() {
            try {
                log('Initializing SqueakWASM VM...');
                
                if (!vm) {
                    vm = new SqueakWASMVM();
                    vm.setResultCallback((result) => {
                        log(\`Smalltalk computation result: \${result}\`);
                    });
                }
                
                const initialized = await vm.initialize();
                if (!initialized) {
                    log('ERROR: Failed to initialize VM');
                    return;
                }
                
                log('VM initialized successfully');
                log('Running 3 + 4 computation...');
                
                const results = await vm.runMinimalExample();
                log(\`Test completed. Results: \${JSON.stringify(results)}\`);
                
            } catch (error) {
                log(\`ERROR: \${error.message}\`);
                console.error('Full error:', error);
            }
        }
        
        // Auto-run test on page load
        window.addEventListener('load', () => {
            log('Page loaded. Click "Run Test" to start.');
        });
    </script>
</body>
</html>`;

    try {
        fs.writeFileSync('dist/test.html', testHtml);
        console.log('✓ Created test.html');
        return true;
    } catch (error) {
        console.error('✗ Failed to create test.html:', error.message);
        return false;
    }
}

function main() {
    console.log('SqueakJS to WASM Build Script (WASM GC enabled by default)');
    console.log('==============================================================');

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
        console.log(`Using ${version}`);
    } catch (error) {
        console.log('Using wasm-tools (version unknown)');
    }

    // Check GC support (should be enabled by default in 1.235.0+)
    console.log('Checking WASM GC support...');
    if (!checkWasmToolsGCSupport()) {
        console.warn('WARNING: Could not verify WASM GC support. Continuing anyway...');
        console.warn('This might indicate an older wasm-tools version.');
    } else {
        console.log('✓ WASM GC support confirmed (enabled by default)');
    }
    console.log('');

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
        
        // Compile WAT to WASM (GC enabled by default)
        if (!compileWatToWasm(watFile, wasmFile)) {
            allSuccess = false;
            continue;
        }
        
        // Validate the generated WASM (GC enabled by default)
        if (!validateWasmFile(wasmFile)) {
            allSuccess = false;
            continue;
        }
    }

    // Copy JavaScript files
    const jsFiles = ['squeak-vm.js'];
    for (const jsFile of jsFiles) {
        if (fs.existsSync(jsFile)) {
            if (!copyFile(jsFile, path.join(outputDir, jsFile))) {
                allSuccess = false;
            }
        } else {
            console.error(`✗ JavaScript file not found: ${jsFile}`);
            allSuccess = false;
        }
    }

    // Create test HTML
    if (!createTestHtml()) {
        allSuccess = false;
    }

    // Final status
    console.log('\\n' + '='.repeat(50));
    if (allSuccess) {
        console.log('✅ Build completed successfully with WASM GC!');
        console.log('');
        console.log('Next steps:');
        console.log('1. Start a local server: npm run serve');
        console.log('2. Open http://localhost:8000/dist/test.html');
        console.log('3. Click "Run Test" to test the VM');
    } else {
        console.log('❌ Build completed with errors');
        console.log('');
        console.log('Check the error messages above and:');
        console.log('1. Ensure wasm-tools supports WASM GC (version 1.200+)');
        console.log('2. Verify your WAT syntax is correct');
        console.log('3. Update wasm-tools if needed: cargo install wasm-tools --force');
    }
    
    process.exit(allSuccess ? 0 : 1);
}

if (require.main === module) {
    main();
}

