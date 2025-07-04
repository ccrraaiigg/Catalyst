#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

function ensureDir(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
}

function compileWatToWasm(watFile, wasmFile) {
    console.log(`📝 Compiling ${watFile} to ${wasmFile}...`);
    
    try {
        const result = spawn('wasm-tools', ['parse', watFile, '-o', wasmFile], { 
            stdio: 'inherit',
            cwd: process.cwd()
        });
        
        result.on('close', (code) => {
            if (code === 0) {
                console.log(`✓ Successfully compiled ${watFile}`);
            } else {
                console.error(`✗ Compilation failed for ${watFile} with exit code ${code}`);
            }
        });
        
        result.on('error', (err) => {
            console.error(`✗ Error compiling ${watFile}:`, err.message);
            return false;
        });
        
        return code === 0;
    } catch (error) {
        console.error(`✗ Failed to compile ${watFile}:`, error.message);
        return false;
    }
}

function dumpWasm(wasmFile) {
    try {
        console.log(`🔍 Analyzing ${wasmFile}...`);
        
        const dumpFile = wasmFile.replace('.wasm', '.dump.wat');
        const result = spawn('wasm-tools', ['print', wasmFile], {
            stdio: ['pipe', 'pipe', 'pipe'],
            cwd: process.cwd()
        });
        
        let output = '';
        result.stdout.on('data', (data) => {
            output += data.toString();
        });
        
        result.on('close', (code) => {
            if (code === 0) {
                fs.writeFileSync(dumpFile, output, 'utf8');
                console.log(`✓ Generated analysis dump: ${dumpFile}`);
            } else {
                console.error(`✗ Failed to analyze ${wasmFile}`);
            }
        });
        
        return code === 0;
    } catch (error) {
        console.error(`✗ Failed to analyze ${wasmFile}:`, error.message);
        return false;
    }
}

function validateWasmFile(wasmFile) {
    try {
        console.log(`✅ Validating ${wasmFile}...`);
        
        const result = spawn('wasm-tools', ['validate', wasmFile], { 
            stdio: 'inherit',
            cwd: process.cwd()
        });
        
        result.on('close', (code) => {
            if (code === 0) {
                console.log(`✓ ${wasmFile} is valid`);
            } else {
                console.error(`✗ Validation failed for ${wasmFile}`);
            }
        });
        
        return code === 0;
    } catch (error) {
        console.error(`✗ Failed to validate ${wasmFile}:`, error.message);
        return false;
    }
}

function copyFile(src, dest) {
    try {
        if (!fs.existsSync(src)) {
            console.error(`✗ Source file not found: ${src}`);
            return false;
        }
        
        fs.copyFileSync(src, dest);
        console.log(`✓ Copied ${src} to ${dest}`);
        return true;
    } catch (error) {
        console.error(`✗ Failed to copy ${src} to ${dest}:`, error.message);
        return false;
    }
}

async function main() {
    console.log('🚀 Building SqueakWASM Phase 3 with JIT Compilation...\n');

    const outputDir = './dist';
    ensureDir(outputDir);

    // Compile WAT files to WASM
    const watFiles = ['squeak-vm-core.wat'];
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
        const destFile = path.join(outputDir, jsFile);
        if (!copyFile(jsFile, destFile)) {
            allSuccess = false;
        }
    }

    // Copy test.html file instead of generating it
    const testHtmlSrc = 'test.html';
    const testHtmlDest = path.join(outputDir, 'test.html');
    
    if (!copyFile(testHtmlSrc, testHtmlDest)) {
        console.error(`✗ Failed to copy test.html - make sure ${testHtmlSrc} exists`);
        allSuccess = false;
    }

    // Create package info
    const packageInfo = {
        name: 'squeakwasm-phase3',
        version: '3.0.0',
        description: 'SqueakWASM VM Phase 3: JIT Compilation Support',
        phase: 3,
        features: [
            'Real bytecode-to-WASM JIT compilation',
            'Hot method detection and compilation',
            'JIT compilation statistics',
            'Performance monitoring',
            'Debug mode support',
            'Enhanced 3 squared example with translated methods',
            'Proper UTF-8 character encoding for emoji and symbols',
            'Runtime JIT enable/disable controls'
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
        console.log('3. Click "Run (3 squared) with JIT" to execute the basic example');
        console.log('4. Use "Run Multiple Times" to trigger JIT compilation (threshold: 10 invocations)');
        console.log('\nPhase 3 Features:');
        console.log('• ⚡ Bytecode-to-WASM translation during execution');
        console.log('• 📊 JIT compilation statistics and monitoring');
        console.log('• 🔧 Runtime JIT enable/disable toggle');
        console.log('• 🐛 Debug mode for detailed compilation logs');
        console.log('• 🚀 Performance improvements for hot methods');
        console.log('• 🎨 Proper UTF-8 character display for all emoji and symbols');
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
    copyFile
};