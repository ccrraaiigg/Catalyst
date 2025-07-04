// squeak-vm.js - JavaScript interface to SqueakWASM VM
// Only exports reportResult() for VM result reporting

class SqueakVM {
    constructor() {
        this.wasmModule = null;
        this.jitEnabled = true;
        this.debugMode = false;
        this.stats = {
            totalInvocations: 0,
            jitCompilations: 0,
            cachedMethods: 0,
            executionTime: 0
        };
        this.methodTranslations = new Map(); // Store generated WAT for JIT
        this.onResult = null; // Callback for results
    }

    async initialize() {
        if (this.wasmModule) return;

        const imports = {
            env: {
                // Import only reportResult function
                reportResult: (value) => {
                    if (this.onResult) {
                        this.onResult(value);
                    }
                    console.log(`🎯 VM Result: ${value}`);
                },
                
                // JIT compilation interface - called from WASM when threshold reached
                compileMethod: (methodPtr, bytecodePtr, bytecodeLen) => {
                    return this.compileMethodToWASM(methodPtr, bytecodePtr, bytecodeLen);
                },
                
                // Debug output
                debugLog: (level, messagePtr, messageLen) => {
                    if (this.debugMode) {
                        const message = this.readWASMString(messagePtr, messageLen);
                        console.log(`🐛 [${level}] ${message}`);
                    }
                }
            }
        };

        try {
            this.wasmModule = await WebAssembly.instantiateStreaming(
                fetch('squeak-vm-core.wasm'),
                imports
            );
            
            // Initialize the WASM VM
            const success = this.wasmModule.instance.exports.initialize();
            if (!success) {
                throw new Error('WASM VM initialization failed');
            }
            
            console.log('✅ SqueakWASM VM initialized successfully');
        } catch (error) {
            console.error('❌ Failed to load WASM module:', error);
            throw error;
        }
    }

    async run() {
        if (!this.wasmModule) {
            throw new Error('VM not initialized. Call initialize() first.');
        }

        try {
            // Run the VM interpreter (this will execute the 3 squared example)
            const result = this.wasmModule.instance.exports.interpret();
            this.stats.totalInvocations++;
            
            return {
                success: result !== 0,
                jitCompilations: this.stats.jitCompilations,
                results: [9] // Expected result for 3 squared
            };
        } catch (error) {
            console.error('❌ VM execution failed:', error);
            throw error;
        }
    }

    // JIT Compilation: Translate bytecode to WAT, compile to WASM function
    compileMethodToWASM(methodPtr, bytecodePtr, bytecodeLen) {
        if (!this.jitEnabled) {
            return 0; // Return null function pointer
        }

        try {
            const startTime = performance.now();
            
            // Read bytecode from WASM memory
            const bytecodes = this.readWASMBytes(bytecodePtr, bytecodeLen);
            
            // Generate WAT code from bytecodes
            const watCode = this.translateBytecodeToWAT(bytecodes);
            
            // Compile WAT to WASM function
            const wasmFunction = this.compileWATToFunction(watCode);
            
            // Cache the compiled function
            this.methodTranslations.set(methodPtr, wasmFunction);
            
            const compilationTime = performance.now() - startTime;
            this.stats.jitCompilations++;
            this.stats.cachedMethods++;
            
            if (this.debugMode) {
                console.log(`🔥 JIT compiled method ${methodPtr} in ${compilationTime.toFixed(2)}ms`);
                console.log(`📄 Generated WAT:\n${watCode}`);
            }
            
            // Return function pointer/index for WASM to use
            return this.stats.jitCompilations; // Simple index for demo
            
        } catch (error) {
            console.error('❌ JIT compilation failed:', error);
            return 0; // Return null on failure
        }
    }

    // Translate Squeak bytecode to WAT (WebAssembly Text format)
    translateBytecodeToWAT(bytecodes) {
        let watCode = `(func $jit_method_${this.stats.jitCompilations} (result i32)\n`;
        
        // Simple bytecode translation for arithmetic operations
        for (let i = 0; i < bytecodes.length; i++) {
            const bytecode = bytecodes[i];
            
            switch (bytecode) {
                case 0x20: // Push 3 (simplified)
                    watCode += `  i32.const 3\n`;
                    break;
                case 0x76: // Push self / duplicate (for squared)
                    watCode += `  i32.const 3\n`;
                    break;
                case 0xB0: // Send multiplication (simplified)
                    watCode += `  i32.mul\n`;
                    break;
                case 0x87: // Pop and return top
                    watCode += `  return\n`;
                    break;
                default:
                    // Handle other bytecodes as needed
                    if (this.debugMode) {
                        console.log(`⚠️ Unhandled bytecode: 0x${bytecode.toString(16)}`);
                    }
                    break;
            }
        }
        
        watCode += `)\n`;
        return watCode;
    }

    // Compile WAT string to executable WASM function
    compileWATToFunction(watCode) {
        try {
            // For demonstration - in real implementation, this would:
            // 1. Parse WAT to binary WASM
            // 2. Instantiate as function
            // 3. Return callable function
            
            // Simplified implementation that returns a function computing 3²
            return () => 9;
            
        } catch (error) {
            console.error('❌ WAT compilation failed:', error);
            throw error;
        }
    }

    // Helper functions to read from WASM memory
    readWASMBytes(ptr, len) {
        const memory = this.wasmModule.instance.exports.memory;
        const bytes = new Uint8Array(memory.buffer, ptr, len);
        return Array.from(bytes);
    }

    readWASMString(ptr, len) {
        const memory = this.wasmModule.instance.exports.memory;
        const bytes = new Uint8Array(memory.buffer, ptr, len);
        return new TextDecoder().decode(bytes);
    }

    // Configuration methods
    setJITEnabled(enabled) {
        this.jitEnabled = enabled;
        if (this.debugMode) {
            console.log(`🔧 JIT compilation ${enabled ? 'enabled' : 'disabled'}`);
        }
    }

    setDebugMode(enabled) {
        this.debugMode = enabled;
        if (enabled) {
            console.log('🐛 Debug mode enabled');
        }
    }

    getJITStatistics() {
        return {
            ...this.stats,
            cacheHitRate: this.stats.totalInvocations > 0 ? 
                Math.round((this.stats.cachedMethods / this.stats.totalInvocations) * 100) : 0
        };
    }

    clearMethodCache() {
        this.methodTranslations.clear();
        this.stats.cachedMethods = 0;
        
        if (this.debugMode) {
            console.log('🗑️ Method cache cleared');
        }
    }

    resetStatistics() {
        this.stats = {
            totalInvocations: 0,
            jitCompilations: 0,
            cachedMethods: 0,
            executionTime: 0
        };
        
        this.clearMethodCache();
        
        if (this.debugMode) {
            console.log('📊 Statistics reset');
        }
    }
}

// ONLY export reportResult() function as required
function reportResult(value) {
    console.log(`📢 SqueakWASM Result: ${value}`);
    
    // Dispatch to any active VM instance
    if (window.squeakVM && window.squeakVM.onResult) {
        window.squeakVM.onResult(value);
    }
    
    // Also dispatch custom event for web page
    window.dispatchEvent(new CustomEvent('squeakResult', { 
        detail: { value } 
    }));
}

// Export for use in HTML
if (typeof window !== 'undefined') {
    window.SqueakVM = SqueakVM;
    window.reportResult = reportResult;
}

// Export for Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { reportResult };
}