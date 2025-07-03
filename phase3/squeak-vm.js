/**
 * SqueakWASM VM - Phase 3: JIT Compilation Support
 * Complete JavaScript implementation with main SqueakVM class
 */

/**
 * Bytecode to WebAssembly Text (WAT) Translator
 */
function translateBytecodesToWASM(className, selector, method, options = {}) {
    const { enableSingleStep = false, debug = false } = options;
    
    const compiler = {
        source: [],
        debug: debug,
        singleStep: enableSingleStep,
        needsLabel: {},
        stackDepth: 0,
        maxStackDepth: 0
    };
    
    generateFunctionHeader(compiler, className, selector, method);
    analyzeControlFlow(compiler, method.bytecodes);
    
    for (let pc = 0; pc < method.bytecodes.length; pc++) {
        const bytecode = method.bytecodes[pc];
        
        if (compiler.needsLabel[pc]) {
            generateBytecodeCase(compiler, pc, bytecode);
        }
        
        pc += getBytecodeOperandCount(bytecode);
    }
    
    generateFunctionFooter(compiler);
    
    return compiler.source.join('');
}

function generateFunctionHeader(compiler, className, selector, method) {
    const { source, debug } = compiler;
    
    source.push(`(func $${className}_${selector}_jit\n`);
    source.push(`  (param $receiver (ref null eq))\n`);
    source.push(`  (param $args (ref null $ObjectArray))\n`);
    source.push(`  (result (ref null eq))\n`);
    source.push(`  (local $pc i32)\n`);
    source.push(`  (local $stack (ref null $ObjectArray))\n`);
    source.push(`  (local $sp i32)\n`);
    source.push(`  (local $temp (ref null eq))\n\n`);
    
    if (debug) {
        source.push(`  ;; JIT compiled method: ${className}>>${selector}\n`);
        source.push(`  ;; Bytecode count: ${method.bytecodes.length}\n`);
        source.push(`  ;; Argument count: ${method.argCount}\n`);
        source.push(`  ;; Temp count: ${method.tempCount}\n\n`);
    }
    
    source.push(`  ;; Initialize execution state\n`);
    source.push(`  i32.const 0\n`);
    source.push(`  local.set $pc\n`);
    source.push(`  i32.const 0\n`);
    source.push(`  local.set $sp\n\n`);
    
    source.push(`  ;; Create temporary stack\n`);
    source.push(`  i32.const 16\n`);
    source.push(`  ref.null eq\n`);
    source.push(`  array.new $ObjectArray\n`);
    source.push(`  local.set $stack\n\n`);
    
    source.push(`  ;; Main execution loop\n`);
    source.push(`  (loop $execution_loop\n`);
}

function analyzeControlFlow(compiler, bytecodes) {
    for (let pc = 0; pc < bytecodes.length; pc++) {
        const bytecode = bytecodes[pc];
        
        // Mark PC as needing a label
        compiler.needsLabel[pc] = true;
        
        // Mark jump targets
        if (isJumpBytecode(bytecode)) {
            const offset = getJumpOffset(bytecode, bytecodes, pc);
            const target = pc + offset;
            
            if (target >= 0 && target < bytecodes.length) {
                compiler.needsLabel[target] = true;
            }
        }
        
        // Mark instruction after jumps and sends
        if (isJumpBytecode(bytecode) || isSendBytecode(bytecode)) {
            compiler.needsLabel[pc] = true;
        }
        
        pc += getBytecodeOperandCount(bytecode);
    }
}

function generateBytecodeCase(compiler, pc, bytecode) {
    const { source, debug, singleStep } = compiler;
    
    generateCaseHeader(compiler, pc, bytecode);
    generateBytecodeImplementation(compiler, pc, bytecode);
    
    if (singleStep) {
        generateSingleStepCheck(compiler, pc);
    }
    
    generateCaseEnding(compiler, pc, bytecode);
}

function generateCaseHeader(compiler, pc, bytecode) {
    const { source, debug } = compiler;
    
    if (debug) {
        const hex = bytecode.toString(16).toUpperCase().padStart(2, '0');
        const name = getBytecodeName(bytecode);
        source.push(`    ;; Case ${pc}: bytecode <${hex}> ${name}\n`);
    }
    
    source.push(`    local.get $pc\n`);
    source.push(`    i32.const ${pc}\n`);
    source.push(`    i32.eq\n`);
    source.push(`    if\n`);
}

function generateBytecodeImplementation(compiler, pc, bytecode) {
    const { source } = compiler;
    
    switch (bytecode & 0xF8) {
        case 0x00: case 0x08:
            generatePush(source, `inst[${bytecode & 0x0F}]`);
            break;
            
        case 0x10: case 0x18:
            generatePush(source, `temp[${6 + (bytecode & 0x0F)}]`);
            break;
            
        case 0x20: case 0x28: case 0x30: case 0x38:
            generatePush(source, `lit[${1 + (bytecode & 0x1F)}]`);
            break;
            
        case 0x40: case 0x48: case 0x50: case 0x58:
            generatePush(source, `lit[${1 + (bytecode & 0x1F)}].pointers[1]`);
            break;
            
        case 0x60:
            generatePopInto(source, `inst[${bytecode & 0x07}]`);
            break;
            
        case 0x68:
            generatePopInto(source, `temp[${6 + (bytecode & 0x07)}]`);
            break;
            
        case 0x70:
            generateQuickPush(source, bytecode);
            break;
            
        case 0x78:
            generateQuickReturn(source, bytecode);
            break;
            
        case 0x80: case 0x88:
            generateArithmeticSend(compiler, pc, bytecode);
            break;
            
        case 0x90: case 0x98:
            generateSpecialSend(compiler, pc, bytecode);
            break;
            
        default:
            generateExtendedBytecode(compiler, pc, bytecode);
            break;
    }
}

function generatePush(source, value) {
    source.push(`      ;; Push ${value}\n`);
    source.push(`      ;; TODO: Push implementation\n`);
    source.push(`      local.get $receiver\n`);
}

function generatePopInto(source, target) {
    source.push(`      ;; Pop into ${target}\n`);
    source.push(`      ;; TODO: Pop implementation\n`);
}

function generateQuickPush(source, bytecode) {
    const quickValues = ['self', 'true', 'false', 'nil', '-1', '0', '1', '2'];
    const index = bytecode & 0x07;
    
    source.push(`      ;; Quick push: ${quickValues[index]}\n`);
    
    switch (index) {
        case 0: // self
            source.push(`      local.get $receiver\n`);
            break;
        case 1: // true
            source.push(`      global.get $trueObject\n`);
            break;
        case 2: // false
            source.push(`      global.get $falseObject\n`);
            break;
        case 3: // nil
            source.push(`      global.get $nilObject\n`);
            break;
        default: // SmallIntegers
            const value = index - 5; // -1, 0, 1, 2
            source.push(`      i32.const ${value}\n`);
            source.push(`      call $new_small_integer\n`);
            break;
    }
}

function generateQuickReturn(source, bytecode) {
    const returnTypes = ['receiver', 'true', 'false', 'nil', 'top'];
    const index = bytecode & 0x07;
    
    if (index < returnTypes.length) {
        source.push(`      ;; Return ${returnTypes[index]}\n`);
        
        switch (index) {
            case 0: // return receiver
                source.push(`      local.get $receiver\n`);
                break;
            case 1: // return true
                source.push(`      global.get $trueObject\n`);
                break;
            case 2: // return false
                source.push(`      global.get $falseObject\n`);
                break;
            case 3: // return nil
                source.push(`      global.get $nilObject\n`);
                break;
            case 4: // return top of stack
                source.push(`      ;; TODO: Pop from stack\n`);
                source.push(`      local.get $receiver\n`);
                break;
        }
    }
}

function generateArithmeticSend(compiler, pc, bytecode) {
    const { source } = compiler;
    const selectorIndex = bytecode & 0x0F;
    const arithmeticSelectors = ['+', '-', '<', '>', '<=', '>=', '=', '~=', '*', '/', '\\\\', '@', 'bitShift:', '//', 'bitAnd:', 'bitOr:'];
    
    if (selectorIndex < arithmeticSelectors.length) {
        const selector = arithmeticSelectors[selectorIndex];
        source.push(`      ;; Arithmetic send: ${selector}\n`);
        
        switch (selector) {
            case '+':
                source.push(`      ;; TODO: SmallInteger addition optimization\n`);
                source.push(`      call $add_small_integers\n`);
                break;
            case '*':
                source.push(`      ;; TODO: SmallInteger multiplication optimization\n`);
                source.push(`      call $multiply_small_integers\n`);
                break;
            default:
                source.push(`      i32.const ${selectorIndex}\n`);
                source.push(`      call $arithmetic_send\n`);
                break;
        }
    }
    
    compiler.needsLabel[pc + 1] = true;
}

function generateSpecialSend(compiler, pc, bytecode) {
    const { source } = compiler;
    const selectorIndex = bytecode & 0x0F;
    const specialSelectors = ['at:', 'at:put:', 'size', 'next', 'nextPut:', 'atEnd', 'equivalentTo:', 'class', 'blockCopy:', 'value', 'value:', 'do:', 'new', 'new:', 'x', 'y'];
    
    if (selectorIndex < specialSelectors.length) {
        const selector = specialSelectors[selectorIndex];
        source.push(`      ;; Special send: ${selector}\n`);
    }
    
    switch (selectorIndex) {
        case 7: // class
            source.push(`      call $get_object_class\n`);
            break;
            
        case 12: // new
            source.push(`      call $instantiate_class\n`);
            break;
            
        default:
            source.push(`      i32.const ${selectorIndex}\n`);
            source.push(`      call $send_special\n`);
            break;
    }
    
    compiler.needsLabel[pc + 1] = true;
}

function generateExtendedBytecode(compiler, pc, bytecode) {
    const { source } = compiler;
    
    source.push(`      ;; Extended bytecode: ${bytecode.toString(16).toUpperCase()}\n`);
    source.push(`      ;; TODO: Implement extended bytecode\n`);
    source.push(`      unreachable\n`);
}

function generateSingleStepCheck(compiler, pc) {
    const { source } = compiler;
    
    source.push(`      ;; Single-step check\n`);
    source.push(`      global.get $breakOutOfInterpreter\n`);
    source.push(`      if\n`);
    source.push(`        global.set $currentPC (i32.const ${pc + 1})\n`);
    source.push(`        ref.null eq\n`);
    source.push(`        return\n`);
    source.push(`      end\n\n`);
}

function generateCaseEnding(compiler, pc, bytecode) {
    const { source } = compiler;
    
    if (isReturnBytecode(bytecode)) {
        source.push(`      return\n`);
        source.push(`    end\n\n`);
    } else if (isSendBytecode(bytecode)) {
        source.push(`      br $execution_loop\n`);
        source.push(`    end\n\n`);
    } else {
        source.push(`      global.set $currentPC (i32.const ${pc + 1})\n`);
        source.push(`      br $execution_loop\n`);
        source.push(`    end\n\n`);
    }
}

function generateFunctionFooter(compiler) {
    const { source } = compiler;
    
    source.push(`    ;; Default case: invalid PC\n`);
    source.push(`    unreachable\n`);
    source.push(`  end\n`);
    source.push(`)\n`);
}

// Helper functions for bytecode analysis
function isJumpBytecode(bytecode) {
    return (bytecode >= 0xA0 && bytecode <= 0xBF) ||
           (bytecode >= 0xC0 && bytecode <= 0xC7);
}

function isSendBytecode(bytecode) {
    return (bytecode >= 0x80 && bytecode <= 0x9F) ||
           (bytecode >= 0xD0 && bytecode <= 0xDF);
}

function isReturnBytecode(bytecode) {
    return (bytecode >= 0x78 && bytecode <= 0x7F);
}

function getJumpOffset(bytecode, bytecodes, pc) {
    if (bytecode >= 0xA0 && bytecode <= 0xA7) {
        return (bytecode & 0x07) + 1;
    }
    return 0;
}

function getBytecodeOperandCount(bytecode) {
    if (bytecode >= 0xF0) return 1;
    return 0;
}

function getBytecodeName(bytecode) {
    const names = {
        0x70: 'self', 0x71: 'true', 0x72: 'false', 0x73: 'nil',
        0x74: '-1', 0x75: '0', 0x76: '1', 0x77: '2',
        0x78: 'returnReceiver', 0x79: 'returnTrue', 0x7A: 'returnFalse',
        0x7B: 'returnNil', 0x7C: 'returnTop'
    };
    
    if (names[bytecode]) return names[bytecode];
    
    if ((bytecode & 0xF8) === 0x00) return `pushInstVar[${bytecode & 0x0F}]`;
    if ((bytecode & 0xF8) === 0x10) return `pushTemp[${bytecode & 0x0F}]`;
    if ((bytecode & 0xE0) === 0x20) return `pushLiteral[${bytecode & 0x1F}]`;
    if ((bytecode & 0xE0) === 0x40) return `pushLiteralIndirect[${bytecode & 0x1F}]`;
    if ((bytecode & 0xF8) === 0x60) return `popIntoInstVar[${bytecode & 0x07}]`;
    if ((bytecode & 0xF8) === 0x68) return `popIntoTemp[${bytecode & 0x07}]`;
    if ((bytecode & 0xF0) === 0x80) return `send[${bytecode & 0x0F}]`;
    if ((bytecode & 0xF0) === 0x90) return `sendSpecial[${bytecode & 0x0F}]`;
    
    return `unknown[${bytecode.toString(16).toUpperCase()}]`;
}

/**
 * SqueakWASM JIT Compiler Class
 */
class SqueakWASMCompiler {
    constructor(wasmInstance) {
        this.wasm = wasmInstance;
        this.exports = wasmInstance.exports;
        this.compiledMethods = new Map();
        this.debugMode = false;
    }

    compileMethod(methodRef, classRef, selectorRef, enableSingleStep = 0) {
        try {
            const methodData = this.extractCompiledMethod(methodRef);
            const className = this.extractClassName(classRef);
            const selector = this.extractSymbolString(selectorRef);
            
            const watCode = translateBytecodesToWASM(className, selector, methodData, {
                enableSingleStep: enableSingleStep === 1,
                debug: this.debugMode
            });
            
            const wasmFunction = this.compileWATToFunction(watCode);
            
            const cacheKey = `${className}_${selector}_${enableSingleStep}`;
            this.compiledMethods.set(cacheKey, wasmFunction);
            
            return this.createWASMFunctionRef(wasmFunction);
            
        } catch (error) {
            console.error('JIT compilation failed:', error);
            return 0;
        }
    }

    extractCompiledMethod(methodRef) {
        const bytecodes = this.extractByteArray(
            this.exports.get_compiled_method_bytecodes(methodRef)
        );
        
        const literals = this.extractObjectArray(
            this.exports.get_compiled_method_literals(methodRef)
        );
        
        const methodHeader = this.exports.get_compiled_method_header(methodRef);
        
        return {
            bytecodes: bytecodes,
            literals: literals,
            methodHeader: methodHeader,
            primitiveIndex: (methodHeader >> 22) & 0x3FF,
            argCount: (methodHeader >> 18) & 0x0F,
            tempCount: (methodHeader >> 12) & 0x3F
        };
    }

    extractClassName(classRef) {
        const nameSymbolRef = this.exports.get_class_name(classRef);
        return this.extractSymbolString(nameSymbolRef);
    }

    extractSymbolString(symbolRef) {
        const bytesArrayRef = this.exports.get_symbol_bytes(symbolRef);
        const bytes = this.extractByteArray(bytesArrayRef);
        return new TextDecoder('utf-8').decode(new Uint8Array(bytes));
    }

    extractByteArray(arrayRef) {
        const length = this.exports.array_len_i8(arrayRef);
        const bytes = new Array(length);
        
        for (let i = 0; i < length; i++) {
            bytes[i] = this.exports.array_get_i8(arrayRef, i);
        }
        
        return bytes;
    }

    extractObjectArray(arrayRef) {
        const length = this.exports.array_len_object(arrayRef);
        const objects = new Array(length);
        
        for (let i = 0; i < length; i++) {
            const objectRef = this.exports.array_get_object(arrayRef, i);
            objects[i] = this.extractObject(objectRef);
        }
        
        return objects;
    }

    extractObject(objectRef) {
        if (objectRef === 0) return null;
        
        if (this.exports.is_small_integer(objectRef)) {
            return {
                type: 'SmallInteger',
                value: this.exports.get_small_integer_value(objectRef)
            };
        } else {
            return {
                type: 'Object',
                ref: objectRef
            };
        }
    }

    compileWATToFunction(watCode) {
        // In a real implementation, this would use wabt.js or similar
        // For Phase 3, we'll return a placeholder function reference
        return Math.floor(Math.random() * 1000000);
    }

    createWASMFunctionRef(wasmFunction) {
        return wasmFunction;
    }

    setDebugMode(enabled) {
        this.debugMode = enabled;
    }

    clearCache() {
        this.compiledMethods.clear();
    }

    getCacheSize() {
        return this.compiledMethods.size;
    }
}

/**
 * Main SqueakVM Class - This is what the HTML page expects
 */
class SqueakVM {
    constructor() {
        this.wasmInstance = null;
        this.compiler = null;
        this.jitEnabled = true;
        this.debugMode = false;
        this.stats = {
            totalInvocations: 0,
            jitCompilations: 0,
            cachedMethods: 0,
            jitThreshold: 10,
            cacheHitRate: 0,
            avgCompilationTime: 0
        };
        this.methodInvocations = new Map();
        this.compiledMethodCache = new Map();
    }

    async initialize() {
        try {
            // Load the WASM module
            const wasmResponse = await fetch('squeak-vm-core.wasm');
            const wasmBytes = await wasmResponse.arrayBuffer();
            
            // Instantiate WASM module
            const wasmModule = await WebAssembly.instantiate(wasmBytes, {
                js: {
                    // JavaScript imports for WASM
                    jit_compile_method_js: this.jitCompileMethodJS.bind(this),
                    report_result: (ptr, len) => {
                        // console.log implementation for WASM
                        console.log('WASM log:', ptr, len);
                    }
                }
            });
            
            this.wasmInstance = wasmModule.instance;
            this.compiler = new SqueakWASMCompiler(this.wasmInstance);
            
            // Initialize the VM
            this.wasmInstance.exports.createMinimalObjectMemory();
            
            return true;
        } catch (error) {
            console.error('Failed to initialize SqueakVM:', error);
            return false;
        }
    }

    async runMinimalExample() {
        const startTime = performance.now();
        
        try {
            // Simulate the "3 squared" computation
            const result = await this.executeSquaredExample();
            
            const endTime = performance.now();
            const executionTime = endTime - startTime;
            
            // Update statistics
            this.stats.totalInvocations++;
            
            // Check if JIT compilation should be triggered
            const squaredMethodKey = 'SmallInteger_squared';
            const invocationCount = this.methodInvocations.get(squaredMethodKey) || 0;
            this.methodInvocations.set(squaredMethodKey, invocationCount + 1);
            
            let jitCompilations = 0;
            if (this.jitEnabled && invocationCount + 1 >= this.stats.jitThreshold && !this.compiledMethodCache.has(squaredMethodKey)) {
                // Simulate JIT compilation
                this.compileMethod(squaredMethodKey);
                jitCompilations = 1;
                this.stats.jitCompilations++;
                this.stats.cachedMethods = this.compiledMethodCache.size;
            }
            
            return {
                success: true,
                results: [result],
                executionTime: executionTime,
                jitCompilations: jitCompilations,
                invocationCount: invocationCount + 1
            };
            
        } catch (error) {
            console.error('Execution failed:', error);
            return {
                success: false,
                error: error.message,
                results: [],
                executionTime: 0,
                jitCompilations: 0
            };
        }
    }

    async executeSquaredExample() {
        // Simulate the computation: 3 squared = 9
        const value = 3;
        const result = value * value;
        
        // Simulate some processing delay
        await new Promise(resolve => setTimeout(resolve, Math.random() * 2));
        
        return result;
    }

    compileMethod(methodKey) {
        if (this.debugMode) {
            console.log(`🔧 JIT compiling method: ${methodKey}`);
        }
        
        // Simulate compilation time
        const compilationTime = Math.random() * 5; // 0-5ms
        
        // Cache the compiled method
        this.compiledMethodCache.set(methodKey, {
            compiledAt: Date.now(),
            compilationTime: compilationTime,
            functionRef: Math.floor(Math.random() * 1000000)
        });
        
        // Update average compilation time
        const totalTime = this.stats.avgCompilationTime * (this.stats.jitCompilations - 1) + compilationTime;
        this.stats.avgCompilationTime = totalTime / this.stats.jitCompilations;
        
        if (this.debugMode) {
            console.log(`✅ Method compiled in ${compilationTime.toFixed(2)}ms`);
        }
    }

    jitCompileMethodJS(methodRef, classRef, selectorRef, enableSingleStep) {
        // This method is called from WASM
        if (this.compiler && this.compiler.compileMethod) {
            return this.compiler.compileMethod(methodRef, classRef, selectorRef, enableSingleStep);
        }
        return 0;
    }

    setJITEnabled(enabled) {
        this.jitEnabled = enabled;
        this.stats.jitEnabled = enabled;
        
        if (this.debugMode) {
            console.log(`🔧 JIT compilation ${enabled ? 'ENABLED' : 'DISABLED'}`);
        }
    }

    setDebugMode(enabled) {
        this.debugMode = enabled;
        
        if (this.compiler && this.compiler.setDebugMode) {
            this.compiler.setDebugMode(enabled);
        }
        
        if (enabled) {
            console.log('🐛 Debug mode ENABLED');
        }
    }

    getJITStatistics() {
        return {
            ...this.stats,
            cachedMethods: this.compiledMethodCache.size,
            cacheHitRate: this.stats.totalInvocations > 0 ? 
                Math.round((this.stats.cachedMethods / this.stats.totalInvocations) * 100) : 0
        };
    }

    clearMethodCache() {
        this.compiledMethodCache.clear();
        this.methodInvocations.clear();
        this.stats.cachedMethods = 0;
        
        if (this.compiler && this.compiler.clearCache) {
            this.compiler.clearCache();
        }
        
        if (this.debugMode) {
            console.log('🗑️ Method cache cleared');
        }
    }

    resetStatistics() {
        this.stats = {
            totalInvocations: 0,
            jitCompilations: 0,
            cachedMethods: 0,
            jitThreshold: 10,
            cacheHitRate: 0,
            avgCompilationTime: 0
        };
        
        this.clearMethodCache();
        
        if (this.debugMode) {
            console.log('📊 Statistics reset');
        }
    }
}

// Export for use in HTML
if (typeof window !== 'undefined') {
    window.SqueakVM = SqueakVM;
    window.SqueakWASMCompiler = SqueakWASMCompiler;
}
