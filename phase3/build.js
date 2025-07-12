#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function ensureDir(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
}

function compileWatToWasm(watFile, wasmFile) {
    console.log(`📝 Compiling ${watFile} to ${wasmFile}...`);
    
    try {
        const result = spawnSync('wasm-tools', ['parse', watFile, '-o', wasmFile], { 
            stdio: 'inherit',
            cwd: process.cwd()
        });
        
        if (result.error) {
            console.error(`✗ Error running wasm-tools:`, result.error.message);
            return false;
        }
        
        if (result.status === 0) {
            console.log(`✓ Successfully compiled ${watFile}`);
            return true;
        } else {
            console.error(`✗ Compilation failed for ${watFile} with exit code ${result.status}`);
            return false;
        }
    } catch (error) {
        console.error(`✗ Failed to compile ${watFile}:`, error.message);
        return false;
    }
}

function dumpWasm(wasmFile) {
    try {
        console.log(`🔍 Analyzing ${wasmFile}...`);
        
        const dumpFile = wasmFile.replace('.wasm', '.dump.wat');
        const result = spawnSync('wasm-tools', ['dump', wasmFile], {
            cwd: process.cwd()
        });
        
        if (result.error) {
            console.error(`✗ Error running wasm-tools for analysis:`, result.error.message);
            return false;
        }
        
        if (result.status === 0) {
            fs.writeFileSync(dumpFile, result.stdout.toString(), 'utf8');
            console.log(`✓ Generated analysis dump: ${dumpFile}`);
            return true;
        } else {
            console.error(`✗ Failed to analyze ${wasmFile}`);
            return false;
        }
    } catch (error) {
        console.error(`✗ Failed to analyze ${wasmFile}:`, error.message);
        return false;
    }
}

function validateWasmFile(wasmFile) {
    try {
        console.log(`✅ Validating ${wasmFile}...`);
        
        const result = spawnSync('wasm-tools', ['validate', wasmFile], { 
            stdio: 'inherit',
            cwd: process.cwd()
        });
        
        if (result.error) {
            console.error(`✗ Error running wasm-tools for validation:`, result.error.message);
            return false;
        }
        
        if (result.status === 0) {
            console.log(`✓ ${wasmFile} is valid`);
            return true;
        } else {
            console.error(`✗ Validation failed for ${wasmFile}`);
            return false;
        }
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

function main() {
    console.log('🚀 Building SqueakWASM Phase 3 with JIT Compilation...\n');

    const outputDir = './dist';
    ensureDir(outputDir);

    // Compile WAT files to WASM
    const watFiles = ['catalyst.wat'];
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
    const jsFiles = ['catalyst.js'];

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

    // Copy .htaccess file for cross-origin isolation (high-resolution timers)
    const htaccessSrc = '.htaccess';
    const htaccessDest = path.join(outputDir, '.htaccess');
    
    if (!copyFile(htaccessSrc, htaccessDest)) {
        console.error(`✗ Failed to copy .htaccess - cross-origin isolation will not work`);
        allSuccess = false;
    }

    // Copy keys file for LLM API access (if it exists)
    const keysSrc = 'keys';
    const keysDest = path.join(outputDir, 'keys');
    
    if (fs.existsSync(keysSrc)) {
        if (!copyFile(keysSrc, keysDest)) {
            console.error(`✗ Failed to copy keys file - LLM optimization will not work`);
            // Don't fail the build for missing keys - it's optional
        }
    } else {
        console.log(`⚠️ Keys file not found - LLM optimization will be disabled`);
                        console.log(`💡 Create a 'keys' file with: openai=sk-proj-... or anthropic=sk-ant-api03-...`);
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
            'Enhanced 3 workload example with translated methods',
            'Proper UTF-8 character encoding for emoji and symbols',
            'Runtime JIT enable/disable controls',
            'Cross-origin isolation for 5μs timer resolution'
        ],
        buildDate: new Date().toISOString(),
        files: {
            wasm: watFiles.map(f => f.replace('.wat', '.wasm')),
            javascript: jsFiles,
            test: 'test.html',
            config: '.htaccess'
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
        console.log('3. Click "Run (3 workload) with JIT" to execute the basic example');
        console.log('4. Use "Run Multiple Times" to trigger JIT compilation (threshold: 1000 invocations)');
        console.log('\nPhase 3 Features:');
        console.log('• ⚡ Bytecode-to-WASM translation during execution');
        console.log('• 📊 JIT compilation statistics and monitoring');
        console.log('• 🔧 Runtime JIT enable/disable toggle');
        console.log('• 🐛 Debug mode for detailed compilation logs');
        console.log('• 🚀 Performance improvements for hot methods');
        console.log('• 🎨 Proper UTF-8 character display for all emoji and symbols');
        console.log('• ⏱️ Cross-origin isolation for 5μs timer resolution');
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
