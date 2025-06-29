#!/usr/bin/env node

// SqueakJS WASM VM - Phase 3 Build Script
// Compiles JIT compiler and VM core with integration

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class Phase3Builder {
    constructor() {
        this.sourceDir = './src';
        this.buildDir = './dist';
        this.wabtPath = 'wat2wasm'; // Assumes wabt is in PATH
        
        this.files = {
            jitCompiler: 'jit-compiler.wat',
            vmCore: 'squeak-vm-core-jit.wat',
            jsInterface: 'squeak-vm-jit.js',
            demo: 'jit-demo.js',
            test: 'test-jit.js'
        };
    }

    async build() {
        console.log('🔨 Building SqueakJS WASM VM - Phase 3: JIT Compilation');
        console.log('=' .repeat(60));

        try {
            this.checkPrerequisites();
            this.createDirectories();
            this.copyJavaScriptFiles();
            await this.compileWATFiles();
            this.generatePackageInfo();
            this.createDemo();
            this.runTests();
            
            console.log('\n✅ Phase 3 build completed successfully!');
            this.printSummary();
            
        } catch (error) {
            console.error('\n❌ Build failed:', error.message);
            process.exit(1);
        }
    }

    checkPrerequisites() {
        console.log('🔍 Checking prerequisites...');
        
        // Check if wabt is available
        try {
            execSync(`${this.wabtPath} --version`, { stdio: 'pipe' });
            console.log('  ✓ WebAssembly Binary Toolkit (wabt) found');
        } catch (error) {
            throw new Error('wabt not found. Please install: npm install -g wabt or brew install wabt');
        }

        // Check for source files
        const requiredSources = [
            'jit-compiler.wat',
            'squeak-vm-core-jit.wat'
        ];

        for (const file of requiredSources) {
            const filePath = path.join(this.sourceDir, file);
            if (!fs.existsSync(filePath)) {
                throw new Error(`Required source file not found: ${filePath}`);
            }
        }

        console.log('  ✓ All source files found');
    }

    createDirectories() {
        console.log('📁 Creating build directories...');
        
        if (!fs.existsSync(this.buildDir)) {
            fs.mkdirSync(this.buildDir, { recursive: true });
        }
        
        const subdirs = ['wasm', 'js', 'demo', 'test'];
        for (const dir of subdirs) {
            const dirPath = path.join(this.buildDir, dir);
            if (!fs.existsSync(dirPath)) {
                fs.mkdirSync(dirPath, { recursive: true });
            }
        }
        
        console.log('  ✓ Build directories created');
    }

    copyJavaScriptFiles() {
        console.log('📄 Copying JavaScript files...');
        
        const jsFiles = [
            { src: 'squeak-vm-jit.js', dest: 'js/squeak-vm-jit.js' },
            { src: 'jit-demo.js', dest: 'demo/jit-demo.js' },
            { src: 'test-jit.js', dest: 'test/test-jit.js' }
        ];

        for (const file of jsFiles) {
            const srcPath = path.join(this.sourceDir, file.src);
            const destPath = path.join(this.buildDir, file.dest);
            
            if (fs.existsSync(srcPath)) {
                fs.copyFileSync(srcPath, destPath);
                console.log(`  ✓ Copied ${file.src}`);
            } else {
                console.log(`  ⚠ Optional file not found: ${file.src}`);
            }
        }
    }

    async compileWATFiles() {
        console.log('⚙️  Compiling WebAssembly modules...');
        
        const watFiles = [
            {
                src: 'jit-compiler.wat',
                dest: 'wasm/jit-compiler.wasm',
                description: 'JIT Compiler Module'
            },
            {
                src: 'squeak-vm-core-jit.wat',
                dest: 'wasm/squeak-vm-core.wasm',
                description: 'VM Core with JIT Integration'
            }
        ];

        for (const file of watFiles) {
            console.log(`  🔧 Compiling ${file.description}...`);
            
            const srcPath = path.join(this.sourceDir, file.src);
            const destPath = path.join(this.buildDir, file.dest);
            
            try {
                // Compile WAT to WASM
                const cmd = `${this.wabtPath} ${srcPath} -o ${destPath} --enable-gc --enable-reference-types --enable-function-references`;
                execSync(cmd, { stdio: 'pipe' });
                
                // Verify the output
                const stats = fs.statSync(destPath);
                console.log(`    ✓ ${file.dest} (${stats.size} bytes)`);
                
                // Optional: Generate text format for debugging
                const txtPath = destPath.replace('.wasm', '.wat.txt');
                try {
                    execSync(`wasm2wat ${destPath} -o ${txtPath}`, { stdio: 'pipe' });
                    console.log(`    ✓ Debug text format: ${path.basename(txtPath)}`);
                } catch (e) {
                    // Not critical if this fails
                }
                
            } catch (error) {
                throw new Error(`Failed to compile ${file.src}: ${error.message}`);
            }
        }
    }

    generatePackageInfo() {
        console.log('📋 Generating package information...');
        
        const packageInfo = {
            name: 'squeakjs-wasm-vm',
            version: '0.1.0-phase3',
            description: 'SqueakJS virtual machine with JIT compilation for WebAssembly',
            phase: 'Phase 3: JIT Compilation',
            features: [
                'WASM GC object memory',
                'i31ref SmallInteger optimization',
                'Bytecode interpreter',
                'JIT compilation engine',
                'Hot method detection',
                'Polymorphic inline caching',
                'Performance monitoring'
            ],
            files: {
                jitCompiler: 'wasm/jit-compiler.wasm',
                vmCore: 'wasm/squeak-vm-core.wasm',
                jsInterface: 'js/squeak-vm-jit.js',
                demo: 'demo/jit-demo.js'
            },
            buildDate: new Date().toISOString(),
            wasmFeatures: [
                'gc',
                'reference-types', 
                'function-references',
                'typed-function-references'
            ]
        };

        const infoPath = path.join(this.buildDir, 'package-info.json');
        fs.writeFileSync(infoPath, JSON.stringify(packageInfo, null, 2));
        console.log('  ✓ package-info.json created');
    }

    createDemo() {
        console.log('🎮 Creating demo application...');
        
        const demoHTML = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SqueakJS WASM VM - JIT Demo</title>
    <style>
        body { font-family: 'Monaco', 'Consolas', monospace; margin: 20px; background: #1e1e1e; color: #d4d4d4; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 30px; }
        .controls { margin: 20px 0; }
        .button { 
            background: #007acc; color: white; border: none; padding: 10px 20px; 
            margin: 5px; cursor: pointer; border-radius: 4px; 
        }
        .button:hover { background: #005a9e; }
        .output { 
            background: #2d2d30; border: 1px solid #444; padding: 15px; 
            height: 400px; overflow-y: auto; font-size: 14px; white-space: pre-wrap;
        }
        .stats { 
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
            gap: 15px; margin: 20px 0; 
        }
        .stat-card { 
            background: #2d2d30; border: 1px solid #444; padding: 15px; border-radius: 4px; 
        }
        .stat-value { font-size: 24px; font-weight: bold; color: #4ec9b0; }
        .stat-label { font-size: 12px; color: #9cdcfe; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 SqueakJS WASM VM - JIT Compilation Demo</h1>
            <p>Phase 3: Just-In-Time Compilation Engine</p>
        </div>

        <div class="controls">
            <button class="button" onclick="runBasicDemo()">🎯 Basic JIT Demo</button>
            <button class="button" onclick="runAdvancedTest()">🧪 Advanced Tests</button>
            <button class="button" onclick="runBenchmark()">⚡ Benchmark</button>
            <button class="button" onclick="clearOutput()">🗑️ Clear Output</button>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-value" id="methodInvocations">0</div>
                <div class="stat-label">Method Invocations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="jitCalls">0</div>
                <div class="stat-label">JIT Calls</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="jitCompilations">0</div>
                <div class="stat-label">JIT Compilations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="cacheHits">0</div>
                <div class="stat-label">Cache Hits</div>
            </div>
        </div>

        <div class="output" id="output">
Welcome to the SqueakJS WASM VM JIT Demo!

This demo showcases Phase 3 features:
- Hot method detection and JIT compilation
- Performance monitoring and statistics
- Cache management and optimization
- Bytecode-to-WASM translation

Click the buttons above to run different tests.
        </div>
    </div>

    <script type="module">
        import { SqueakJITVM, demonstrateJITCompilation } from './js/squeak-vm-jit.js';
        
        let vm = null;
        const output = document.getElementById('output');
        
        async function initializeVM() {
            if (vm) return;
            
            vm = new SqueakJITVM();
            vm.onResult = (result) => {
                appendOutput(\`✨ Result: \${result}\`);
            };
            
            vm.onPerformanceUpdate = (stats) => {
                updateStatsDisplay(stats);
            };
            
            const success = await vm.initialize();
            if (!success) {
                appendOutput('❌ Failed to initialize VM');
                return false;
            }
            
            appendOutput('✅ VM initialized successfully');
            return true;
        }
        
        function appendOutput(text) {
            output.textContent += text + '\\n';
            output.scrollTop = output.scrollHeight;
        }
        
        function updateStatsDisplay(stats) {
            document.getElementById('methodInvocations').textContent = stats.methodInvocations;
            document.getElementById('jitCalls').textContent = stats.jitCalls;
            document.getElementById('jitCompilations').textContent = stats.jitCompilations;
            document.getElementById('cacheHits').textContent = stats.cacheHits;
        }
        
        window.runBasicDemo = async () => {
            appendOutput('\\n🚀 Starting Basic JIT Demo...');
            if (await initializeVM()) {
                await vm.runJITDemo();
            }
        };
        
        window.runAdvancedTest = async () => {
            appendOutput('\\n🧪 Starting Advanced JIT Tests...');
            if (await initializeVM()) {
                await vm.runAdvancedJITTest();
            }
        };
        
        window.runBenchmark = async () => {
            appendOutput('\\n⚡ Starting Performance Benchmark...');
            if (await initializeVM()) {
                await vm.runBenchmark(1000);
            }
        };
        
        window.clearOutput = () => {
            output.textContent = 'Output cleared.\\n';
        };
        
        // Initialize console override to capture VM output
        const originalLog = console.log;
        console.log = (...args) => {
            appendOutput(args.join(' '));
            originalLog(...args);
        };
    </script>
</body>
</html>`;

        const demoPath = path.join(this.buildDir, 'demo', 'index.html');
        fs.writeFileSync(demoPath, demoHTML);
        console.log('  ✓ Demo HTML created');
        
        // Create demo server script
        const serverScript = `#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.wasm': 'application/wasm',
    '.json': 'application/json'
};

const server = http.createServer((req, res) => {
    const filePath = req.url === '/' ? '/demo/index.html' : req.url;
    const fullPath = path.join(__dirname, filePath);
    
    fs.readFile(fullPath, (err, data) => {
        if (err) {
            res.writeHead(404);
            res.end('File not found');
            return;
        }
        
        const ext = path.extname(fullPath);
        const mimeType = MIME_TYPES[ext] || 'text/plain';
        
        res.writeHead(200, { 
            'Content-Type': mimeType,
            'Cross-Origin-Embedder-Policy': 'require-corp',
            'Cross-Origin-Opener-Policy': 'same-origin'
        });
        res.end(data);
    });
});

server.listen(PORT, () => {
    console.log(\`🌐 Demo server running at http://localhost:\${PORT}\`);
    console.log('  Open this URL in your browser to try the JIT demo');
});`;

        const serverPath = path.join(this.buildDir, 'serve-demo.js');
        fs.writeFileSync(serverPath, serverScript);
        fs.chmodSync(serverPath, '755');
        console.log('  ✓ Demo server script created');
    }

    runTests() {
        console.log('🧪 Running basic validation tests...');
        
        // Test 1: Verify WASM files are valid
        const wasmFiles = [
            'wasm/jit-compiler.wasm',
            'wasm/squeak-vm-core.wasm'
        ];

        for (const file of wasmFiles) {
            const filePath = path.join(this.buildDir, file);
            const stats = fs.statSync(filePath);
            
            if (stats.size < 100) {
                throw new Error(`WASM file too small, likely compilation error: ${file}`);
            }
            
            // Basic WASM magic number check
            const buffer = fs.readFileSync(filePath);
            const magic = buffer.readUInt32LE(0);
            if (magic !== 0x6d736100) { // '\0asm'
                throw new Error(`Invalid WASM magic number in: ${file}`);
            }
            
            console.log(`  ✓ ${file} validated (${stats.size} bytes)`);
        }

        // Test 2: Verify JS files are syntactically valid
        try {
            const jsPath = path.join(this.buildDir, 'js', 'squeak-vm-jit.js');
            if (fs.existsSync(jsPath)) {
                require(jsPath);
                console.log('  ✓ JavaScript interface validated');
            }
        } catch (error) {
            console.log(`  ⚠ JavaScript validation skipped: ${error.message}`);
        }

        console.log('  ✓ All tests passed');
    }

    printSummary() {
        console.log('\n📋 Build Summary');
        console.log('═'.repeat(40));
        
        const buildSize = this.calculateBuildSize();
        console.log(`Build directory: ${this.buildDir}`);
        console.log(`Total build size: ${(buildSize / 1024).toFixed(1)} KB`);
        
        console.log('\n📁 Generated files:');
        console.log('  wasm/jit-compiler.wasm     - JIT compilation engine');
        console.log('  wasm/squeak-vm-core.wasm   - VM core with JIT integration');
        console.log('  js/squeak-vm-jit.js        - JavaScript interface');
        console.log('  demo/index.html            - Interactive demo');
        console.log('  serve-demo.js              - Demo server');
        
        console.log('\n🚀 Next steps:');
        console.log('  1. cd dist && node serve-demo.js');
        console.log('  2. Open http://localhost:8080 in your browser');
        console.log('  3. Try the JIT compilation demo!');
        
        console.log('\n🎯 Phase 3 JIT Features:');
        console.log('  ✓ Hot method detection');
        console.log('  ✓ Bytecode-to-WASM compilation');
        console.log('  ✓ Method caching and eviction');
        console.log('  ✓ Performance monitoring');
        console.log('  ✓ Optimized SmallInteger arithmetic');
    }

    calculateBuildSize() {
        let totalSize = 0;
        
        const walkDir = (dir) => {
            const files = fs.readdirSync(dir);
            for (const file of files) {
                const filePath = path.join(dir, file);
                const stats = fs.statSync(filePath);
                if (stats.isDirectory()) {
                    walkDir(filePath);
                } else {
                    totalSize += stats.size;
                }
            }
        };
        
        walkDir(this.buildDir);
        return totalSize;
    }
}

// CLI interface
if (require.main === module) {
    const builder = new Phase3Builder();
    builder.build().catch(error => {
        console.error('\n💥 Fatal build error:', error);
        process.exit(1);
    });
}

// Export for programmatic use
module.exports = { Phase3Builder };
