/**
 * SqueakJS to WASM VM - Phase 3: JIT Compilation Support
 * JavaScript Interface with integrated bytecode-to-WASM translation
 */

/**
 * Bytecode to WebAssembly Translator
 * Converts Smalltalk bytecodes to WAT text format for JIT compilation
 */
function translateBytecodesToWASM(className, selector, method, options = {}) {
    const enableSingleStep = options.enableSingleStep || false;
    const debug = options.debug || false;
    
    // Initialize compiler state
    const compiler = {
        method: method,
        bytecodes: method.bytecodes || method.bytes,
        literals: method.literals || method.pointers,
        pc: 0,
        endPC: 0,
        prevPC: 0,
        source: [],
        needsLabel: {},
        singleStep: enableSingleStep,
        debug: debug,
        
        // Special selectors for quick sends
        specialSelectors: ['+', '-', '<', '>', '<=', '>=', '=', '~=', '*', '/', '\\\\', '@',
            'bitShift:', '//', 'bitAnd:', 'bitOr:', 'at:', 'at:put:', 'size', 'next', 'nextPut:',
            'atEnd', '==', 'class', 'blockCopy:', 'value', 'value:', 'do:', 'new', 'new:', 'x', 'y']
    };
    
    // Generate function name (sanitize selector)
    const funcName = generateFunctionName(className, selector);
    
    // Generate function header
    generateFunctionHeader(compiler, funcName, className, selector);
    
    // Generate bytecode cases
    generateBytecodes(compiler);
    
    // Generate function footer
    generateFunctionFooter(compiler);
    
    // Return complete WAT function
    return compiler.source.join('');
}

function generateFunctionName(className, selector) {
    let cls = className.replace(/ /g, "_").replace("[]", "Block");
    
    if (!/[^a-zA-Z0-9:_]/.test(selector)) {
        return cls + "_" + selector.replace(/:/g, "ː"); // unicode colon
    }
    
    // Complex selector - encode special characters
    const op = selector.replace(/./g, function(char) {
        const repl = {
            '|': "OR", '~': "NOT", '<': "LT", '=': "EQ", '>': "GT",
            '&': "AND", '@': "AT", '*': "TIMES", '+': "PLUS", '\\\\': "MOD",
            '-': "MINUS", ',': "COMMA", '/': "DIV", '?': "IF"
        }[char];
        return repl || 'OPERATOR';
    });
    return cls + "__" + op + "__";
}

function generateFunctionHeader(compiler, funcName, className, selector) {
    const { source, debug } = compiler;
    
    source.push(`(func ${funcName} (result (ref null eq))\n`);
    source.push(`  (local $context (ref $Context))\n`);
    source.push(`  (local $stack (ref $ObjectArray))\n`);
    source.push(`  (local $receiver (ref null eq))\n`);
    source.push(`  (local $temps (ref $ObjectArray))\n`);
    source.push(`  (local $pc i32)\n\n`);
    
    if (debug) {
        source.push(`  ;; ${className}>>${selector}\n`);
    }
    
    // VM state initialization
    source.push(`  ;; Get VM state from globals\n`);
    source.push(`  global.get $activeContext\n`);
    source.push(`  ref.cast $Context\n`);
    source.push(`  local.set $context\n`);
    source.push(`  local.get $context\n`);
    source.push(`  struct.get $Context $stack\n`);
    source.push(`  local.set $stack\n`);
    source.push(`  global.get $currentReceiver\n`);
    source.push(`  local.set $receiver\n`);
    source.push(`  global.get $homeContextTemps\n`);
    source.push(`  local.set $temps\n\n`);
    
    // Start main execution loop
    source.push(`  ;; Main execution loop for context switching support\n`);
    source.push(`  loop $execution_loop\n`);
    source.push(`    global.get $currentPC\n`);
    source.push(`    local.set $pc\n\n`);
}

function generateBytecodes(compiler) {
    const { bytecodes } = compiler;
    
    // First pass: analyze bytecodes to determine labels needed
    analyzeBytecodes(compiler);
    
    // Generate cases for each bytecode
    compiler.pc = 0;
    compiler.prevPC = 0;
    
    while (compiler.pc < bytecodes.length) {
        const pc = compiler.pc;
        const bytecode = bytecodes[compiler.pc++];
        
        generateBytecodeCase(compiler, pc, bytecode);
        
        if (compiler.pc > compiler.endPC) {
            break;
        }
    }
}

function analyzeBytecodes(compiler) {
    const { bytecodes } = compiler;
    let pc = 0;
    
    while (pc < bytecodes.length) {
        const bytecode = bytecodes[pc];
        pc++;
        
        if (isJumpBytecode(bytecode)) {
            const offset = getJumpOffset(bytecode, bytecodes, pc);
            const target = pc + offset;
            compiler.needsLabel[target] = true;
            if (target > compiler.endPC) {
                compiler.endPC = target;
            }
        }
        
        if (isSendBytecode(bytecode)) {
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
    source.push(`      local.get $stack\n`);
    source.push(`      global.get $currentSP\n`);
    source.push(`      i32.const 1\n`);
    source.push(`      i32.add\n`);
    source.push(`      global.set $currentSP\n`);
    source.push(`      global.get $currentSP\n`);
    
    if (value.startsWith('inst[')) {
        const index = value.match(/\d+/)[0];
        source.push(`      local.get $receiver\n`);
        source.push(`      ref.cast (ref $SqueakObject)\n`);
        source.push(`      struct.get $SqueakObject $slots\n`);
        source.push(`      i32.const ${index}\n`);
        source.push(`      array.get\n`);
    } else if (value.startsWith('temp[')) {
        const index = value.match(/\d+/)[0];
        source.push(`      local.get $temps\n`);
        source.push(`      i32.const ${index}\n`);
        source.push(`      array.get\n`);
    } else if (value === 'rcvr') {
        source.push(`      local.get $receiver\n`);
    } else {
        source.push(`      global.get $nilObject\n`);
    }
    
    source.push(`      array.set\n`);
}

function generatePopInto(source, target) {
    source.push(`      ;; Pop into ${target}\n`);
    source.push(`      local.get $stack\n`);
    source.push(`      global.get $currentSP\n`);
    source.push(`      array.get\n`);
    source.push(`      local.tee $value\n`);
    
    if (target.startsWith('inst[')) {
        const index = target.match(/\d+/)[0];
        source.push(`      local.get $receiver\n`);
        source.push(`      ref.cast (ref $SqueakObject)\n`);
        source.push(`      struct.get $SqueakObject $slots\n`);
        source.push(`      i32.const ${index}\n`);
        source.push(`      local.get $value\n`);
        source.push(`      array.set\n`);
    } else if (target.startsWith('temp[')) {
        const index = target.match(/\d+/)[0];
        source.push(`      local.get $temps\n`);
        source.push(`      i32.const ${index}\n`);
        source.push(`      local.get $value\n`);
        source.push(`      array.set\n`);
    }
    
    source.push(`      global.get $currentSP\n`);
    source.push(`      i32.const 1\n`);
    source.push(`      i32.sub\n`);
    source.push(`      global.set $currentSP\n`);
}

function generateQuickPush(source, bytecode) {
    const quickValues = {
        0x70: 'receiver', 0x71: 'true', 0x72: 'false', 0x73: 'nil',
        0x74: '-1', 0x75: '0', 0x76: '1', 0x77: '2'
    };
    
    const value = quickValues[bytecode];
    if (value === 'receiver') {
        generatePush(source, 'rcvr');
    } else if (value === 'true') {
        source.push(`      global.get $trueObject\n`);
        source.push(`      call $push\n`);
    } else if (value === 'false') {
        source.push(`      global.get $falseObject\n`);
        source.push(`      call $push\n`);
    } else if (value === 'nil') {
        source.push(`      global.get $nilObject\n`);
        source.push(`      call $push\n`);
    } else {
        // Numeric constant
        source.push(`      i32.const ${value}\n`);
        source.push(`      ref.i31\n`);
        source.push(`      call $push\n`);
    }
}

function generateQuickReturn(source, bytecode) {
    const returnValues = {
        0x78: 'receiver', 0x79: 'true', 0x7A: 'false',
        0x7B: 'nil', 0x7C: 'top'
    };
    
    const value = returnValues[bytecode];
    source.push(`      ;; Return ${value}\n`);
    
    if (value === 'top') {
        source.push(`      call $pop\n`);
        source.push(`      return\n`);
    } else if (value === 'receiver') {
        source.push(`      local.get $receiver\n`);
        source.push(`      return\n`);
    } else {
        source.push(`      global.get ${value}Object\n`);
        source.push(`      return\n`);
    }
}

function generateArithmeticSend(compiler, pc, bytecode) {
    const { source } = compiler;
    const selectorIndex = bytecode & 0x0F;
    
    source.push(`      ;; Arithmetic send: ${selectorIndex}\n`);
    source.push(`      local.get $receiver\n`);
    source.push(`      i32.const ${selectorIndex}\n`);
    source.push(`      call $quick_send_other\n`);
    source.push(`      if\n`);
    source.push(`        ;; Quick send succeeded\n`);
    source.push(`      else\n`);
    source.push(`        i32.const ${selectorIndex}\n`);
    source.push(`        call $send_special\n`);
    source.push(`        ref.null eq\n`);
    source.push(`        return\n`);
    source.push(`      end\n`);
    
    compiler.needsLabel[pc + 1] = true;
}

function generateSpecialSend(compiler, pc, bytecode) {
    const { source } = compiler;
    const selectorIndex = bytecode & 0x0F;
    
    source.push(`      ;; Special send: ${selectorIndex}\n`);
    
    switch (selectorIndex) {
        case 0x8: // blockCopy:
        case 0x9: // value
        case 0xA: // value:
        case 0xB: // do:
            source.push(`      local.get $receiver\n`);
            source.push(`      i32.const ${selectorIndex}\n`);
            source.push(`      call $quick_send_other\n`);
            source.push(`      if\n`);
            source.push(`        ;; Quick send succeeded\n`);
            source.push(`      else\n`);
            source.push(`        i32.const ${selectorIndex}\n`);
            source.push(`        call $send_special\n`);
            source.push(`        ref.null eq\n`);
            source.push(`        return\n`);
            source.push(`      end\n`);
            break;
            
        default:
            source.push(`      i32.const ${selectorIndex}\n`);
            source.push(`      call $send_special\n`);
            source.push(`      ref.null eq\n`);
            source.push(`      return\n`);
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
}

/**
 * Enhanced SqueakWASM VM with JIT Compilation
 */
class SqueakWASMVM {
    constructor() {
        this.vmModule = null;
        this.compiler = null;
        this.results = [];
        this.jitEnabled = true;
        this.debugMode = false;
    }

    async initialize() {
        const vm = this; // Capture for closures
        
        const imports = {
            system: {
                reportResult: (value) => {
                    console.log(`Smalltalk result: ${value}`);
                    this.results.push(value);
                    if (this.onResult) {
                        this.onResult(value);
                    }
                },
                currentTimeMillis: () => Date.now(),
                consoleLog: (stringRef) => {
                    console.log('Smalltalk log:', stringRef);
                }
            },
            jit: {
                compileMethod: (methodRef, classRef, selectorRef, enableSingleStep) => {
                    if (!vm.jitEnabled || !vm.compiler) {
                        return 0; // JIT disabled or not available
                    }
                    
                    try {
                        return vm.compiler.compileMethod(
                            methodRef, classRef, selectorRef, enableSingleStep
                        );
                    } catch (error) {
                        console.error('JIT compilation error:', error);
                        return 0;
                    }
                },
                reportError: (errorCode) => {
                    console.error('WASM JIT error:', errorCode);
                }
            }
        };

        try {
            const response = await fetch('dist/squeak-vm-core.wasm');
            const bytes = await response.arrayBuffer();
            const module = await WebAssembly.compile(bytes);
            this.vmModule = await WebAssembly.instantiate(module, imports);
            
            // Initialize JIT compiler
            this.compiler = new SqueakWASMCompiler(this.vmModule);
            this.compiler.setDebugMode(this.debugMode);
            
            console.log('SqueakWASM VM with JIT compilation initialized successfully');
            return true;
        } catch (error) {
            console.error('Failed to initialize SqueakWASM VM:', error);
            return false;
        }
    }

    async runMinimalExample() {
        if (!this.vmModule) {
            throw new Error('VM not initialized. Call initialize() first.');
        }

        try {
            const success = this.vmModule.exports.createMinimalBootstrap();
            if (!success) {
                throw new Error('Failed to create minimal bootstrap');
            }

            console.log('Running "3 squared" example with JIT compilation...');
            
            this.results = [];
            
            const startTime = performance.now();
            this.vmModule.exports.interpret();
            const endTime = performance.now();
            
            const jitCompilations = this.vmModule.exports.getJITCompilationCount();
            
            console.log(`Execution completed in ${(endTime - startTime).toFixed(2)}ms`);
            console.log(`JIT compilations performed: ${jitCompilations}`);
            
            return {
                results: this.results,
                executionTime: endTime - startTime,
                jitCompilations: jitCompilations
            };
        } catch (error) {
            console.error('Error running minimal example:', error);
            throw error;
        }
    }

    getResults() {
        return [...this.results];
    }

    setResultCallback(callback) {
        this.onResult = callback;
    }

    enableJIT(enabled = true) {
        this.jitEnabled = enabled;
        console.log(`JIT compilation ${enabled ? 'enabled' : 'disabled'}`);
    }

    setDebugMode(enabled = true) {
        this.debugMode = enabled;
        if (this.compiler) {
            this.compiler.setDebugMode(enabled);
        }
        console.log(`Debug mode ${enabled ? 'enabled' : 'disabled'}`);
    }

    getJITStatistics() {
        if (!this.vmModule) return null;
        
        return {
            compilationCount: this.vmModule.exports.getJITCompilationCount(),
            cachedMethods: this.compiler ? this.compiler.compiledMethods.size : 0,
            jitEnabled: this.jitEnabled
        };
    }
}

// Export for use in browsers or Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        SqueakWASMVM,
        SqueakWASMCompiler,
        translateBytecodesToWASM
    };
} else if (typeof window !== 'undefined') {
    window.SqueakWASMVM = SqueakWASMVM;
    window.SqueakWASMCompiler = SqueakWASMCompiler;
    window.translateBytecodesToWASM = translateBytecodesToWASM;
}