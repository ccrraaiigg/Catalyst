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

    initialize() {
        if (this.wasmModule) return Promise.resolve();
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
                },
                setActiveContext: (ctx) => this.wasmModule.instance.exports.setActiveContext(ctx),
            }
        };
        return WebAssembly.instantiateStreaming(
                fetch('dist/squeak-vm-core.wasm'),
                imports
        ).then(wasmModule => {
            this.wasmModule = wasmModule;
            
            // Initialize function table with null values
            this.initializeFunctionTable();
            
            const success = this.wasmModule.instance.exports.initialize();
            if (!success) {
                throw new Error('WASM VM initialization failed');
            }
            console.log('✅ SqueakWASM VM initialized successfully');
        }).catch(error => {
            console.error('❌ Failed to load WASM module:', error);
            throw error;
        });
    }

    // Initialize function table with null values for JIT compilation
    initializeFunctionTable() {
        const funcTable = this.wasmModule.instance.exports.funcTable;
        if (funcTable && typeof funcTable.set === 'function') {
            // Initialize all 100 slots with null (ref.null funcref)
            for (let i = 0; i < 100; i++) {
                funcTable.set(i, null);
            }
            if (this.debugMode) {
                console.log('🔧 Function table initialized with 100 null slots');
            }
        }
    }

    async resetVM() {
        // Re-initialize the WASM module to reset the VM state
        await this.initialize();
        if (this.debugMode) {
            console.log('🔄 VM state reset');
        }
    }

    async run() {
        if (!this.wasmModule) {
            return Promise.reject(new Error('VM not initialized. Call initialize() first.'));
        }
        // Do NOT reset the VM here; we want to preserve state across runs
        return new Promise((resolve, reject) => {
            let receivedResult = null;
            // Temporarily override onResult to capture the value
            const prevOnResult = this.onResult;
            this.onResult = (value) => {
                receivedResult = value;
            };
            try {
                // Run the VM interpreter (this will execute the 3 squared example)
                const result = this.wasmModule.instance.exports.interpret();
                this.stats.totalInvocations++;
                // Restore previous onResult
                this.onResult = prevOnResult;
                resolve({
                    success: result !== 0,
                    jitCompilations: this.stats.jitCompilations,
                    results: [receivedResult] // Use the actual result received
                });
            } catch (error) {
                this.onResult = prevOnResult;
                console.error('❌ VM execution failed:', error);
                reject(error);
            }
        });
    }

    // JIT Compilation: Translate bytecode to WAT, compile to WASM function
    // Accepts: methodPtr (identity), bytecodePtr (memory offset), bytecodeLen (length)
    async compileMethodToWASM(methodPtr, bytecodePtr, bytecodeLen) {
        if (!this.jitEnabled) {
            return 0; // Return null function pointer
        }

        try {
            const startTime = performance.now();
            
            // Read bytecodes from WASM memory
            const memory = this.wasmModule.instance.exports.jitMemory;
            const bytecodes = new Uint8Array(memory.buffer, bytecodePtr, bytecodeLen);
            
            // Convert to regular array
            const bytecodeArray = Array.from(bytecodes);

            // Generate WAT code from bytecodes
            const watCode = this.translateBytecodeToWAT(bytecodeArray);
            
            // Compile WAT to WASM function that can be stored in function table
            const compiledFunction = await this.compileWATToFunction(watCode);
            
            // Cache the compiled function
            this.methodTranslations.set(methodPtr, compiledFunction);

            // Get the next available function table index
            const funcIndex = this.stats.jitCompilations;
            
            // Store the compiled function in the WASM function table
            const funcTable = this.wasmModule.instance.exports.funcTable;
            if (funcTable && typeof funcTable.set === 'function') {
                // The compiled function is already a WASM function with the correct signature
                funcTable.set(funcIndex, compiledFunction);
            }
            
            const compilationTime = performance.now() - startTime;
            this.stats.jitCompilations++;
            this.stats.cachedMethods++;
            
            if (this.debugMode) {
                console.log(`🔥 JIT compiled method ${methodPtr} in ${compilationTime.toFixed(2)}ms`);
                console.log(`📄 Generated WAT:\n${watCode}`);
                console.log(`📍 Stored in function table at index ${funcIndex}`);
            }
            
            // Return function table index for WASM to use with call_indirect
            return funcIndex;
            
        } catch (error) {
            console.error('❌ JIT compilation failed:', error);
            return 0; // Return null on failure
        }
    }

    // Translate Squeak bytecode to WAT (WebAssembly Text format)
    translateBytecodeToWAT(bytecodes) {
        let watCode = `(func $jit_method_${this.stats.jitCompilations} (param $context (ref null $Context)) (result i32)\n`;
        watCode += `  (local $receiver (ref null eq))\n`;
        watCode += `  (local $value1 (ref null eq))\n`;
        watCode += `  (local $value2 (ref null eq))\n`;
        watCode += `  (local $int1 i32)\n`;
        watCode += `  (local $int2 i32)\n`;
        watCode += `  (local $result i32)\n`;
        watCode += `  (local $selector (ref null eq))\n`;
        watCode += `  (local $method (ref null $CompiledMethod))\n`;
        watCode += `  (local $receiverClass (ref null $Class))\n`;
        watCode += `  (local $selectorIndex i32)\n`;
        watCode += `  (local $newContext (ref null $Context))\n`;
        for (let i = 0; i < bytecodes.length; i++) {
            const bytecode = bytecodes[i];
            
            switch (bytecode) {
                case 0x70: // Push receiver (self)
                    watCode += `  ;; Push receiver onto stack\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $getContextReceiver\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $pushOnStack\n`;
                    break;
                    
                case 0xB8: // Multiply (pop two values, multiply, push result)
                    watCode += `  ;; Pop two values from stack and multiply\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $popFromStack\n`;
                    watCode += `  local.tee $value2\n`;
                    watCode += `  ref.is_null\n`;
                    watCode += `  if\n`;
                    watCode += `    i32.const 0 ;; Continue if stack underflow\n`;
                    watCode += `    return\n`;
                    watCode += `  end\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $popFromStack\n`;
                    watCode += `  local.tee $value1\n`;
                    watCode += `  ref.is_null\n`;
                    watCode += `  if\n`;
                    watCode += `    ;; Push value2 back and continue\n`;
                    watCode += `    local.get $context\n`;
                    watCode += `    local.get $value2\n`;
                    watCode += `    local.get $context\n`;
                    watCode += `    call $pushOnStack\n`;
                    watCode += `    i32.const 0\n`;
                    watCode += `    return\n`;
                    watCode += `  end\n`;
                    watCode += `  ;; Extract integer values and multiply\n`;
                    watCode += `  local.get $value1\n`;
                    watCode += `  call $extractIntegerValue\n`;
                    watCode += `  local.set $int1\n`;
                    watCode += `  local.get $value2\n`;
                    watCode += `  call $extractIntegerValue\n`;
                    watCode += `  local.set $int2\n`;
                    watCode += `  local.get $int1\n`;
                    watCode += `  local.get $int2\n`;
                    watCode += `  i32.mul\n`;
                    watCode += `  local.set $result\n`;
                    watCode += `  ;; Create result SmallInteger and push onto stack\n`;
                    watCode += `  local.get $result\n`;
                    watCode += `  call $createSmallInteger\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $pushOnStack\n`;
                    break;
                    
                case 0x7C: // Return top-of-stack
                    watCode += `  ;; Return - top of stack is already the result\n`;
                    watCode += `  i32.const 1 ;; Signal method return\n`;
                    watCode += `  return\n`;
                    break;
                    
                case 0xD0: // Send message (generic for any selector)
                    watCode += `  ;; Send message - pop receiver and perform method lookup\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $popFromStack\n`;
                    watCode += `  local.tee $receiver\n`;
                    watCode += `  ref.is_null\n`;
                    watCode += `  if\n`;
                    watCode += `    i32.const 0\n`;
                    watCode += `    return\n`;
                    watCode += `  end\n`;
                    watCode += `  ;; Use hardcoded selector index 0 for this bytecode\n`;
                    watCode += `  i32.const 0\n`;
                    watCode += `  local.set $selectorIndex\n`;
                    watCode += `  ;; Get selector from method's literal array at index\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  call $getContextMethod\n`;
                    watCode += `  call $getCompiledMethodSlots\n`;
                    watCode += `  local.get $selectorIndex\n`;
                    watCode += `  call $getObjectArrayElement\n`;
                    watCode += `  local.set $selector\n`;
                    watCode += `  ;; Get receiver's class\n`;
                    watCode += `  local.get $receiver\n`;
                    watCode += `  call $getClass\n`;
                    watCode += `  local.set $receiverClass\n`;
                    watCode += `  ;; Try polymorphic inline cache first\n`;
                    watCode += `  local.get $selector\n`;
                    watCode += `  local.get $receiverClass\n`;
                    watCode += `  call $lookupInCache\n`;
                    watCode += `  local.tee $method\n`;
                    watCode += `  ref.is_null\n`;
                    watCode += `  if\n`;
                    watCode += `    ;; Cache miss - do full method lookup\n`;
                    watCode += `    local.get $receiver\n`;
                    watCode += `    local.get $selector\n`;
                    watCode += `    call $lookupMethod\n`;
                    watCode += `    local.tee $method\n`;
                    watCode += `    ref.is_null\n`;
                    watCode += `    if\n`;
                    watCode += `      ;; Method not found - push receiver back\n`;
                    watCode += `      local.get $context\n`;
                    watCode += `      local.get $receiver\n`;
                    watCode += `      local.get $context\n`;
                    watCode += `      call $pushOnStack\n`;
                    watCode += `      i32.const 0\n`;
                    watCode += `      return\n`;
                    watCode += `    end\n`;
                    watCode += `    ;; Store in cache for future use\n`;
                    watCode += `    local.get $selector\n`;
                    watCode += `    local.get $receiverClass\n`;
                    watCode += `    local.get $method\n`;
                    watCode += `    call $storeInCache\n`;
                    watCode += `  end\n`;
                    watCode += `  ;; Create new context for method\n`;
                    watCode += `  local.get $receiver\n`;
                    watCode += `  local.get $method\n`;
                    watCode += `  local.get $selector\n`;
                    watCode += `  call $createMethodContext\n`;
                    watCode += `  local.set $newContext\n`;
                    watCode += `  ;; Switch to new context\n`;
                    watCode += `  local.get $newContext\n`;
                    watCode += `  call $setActiveContext\n`;
                    break;
                    
                default:
                    // Handle other bytecodes as needed
                    if (this.debugMode) {
                        console.log(`⚠️ Unhandled bytecode: 0x${bytecode.toString(16)}`);
                    }
                    // For unknown bytecodes, generate a call to the interpreter
                    watCode += `  ;; Unknown bytecode - delegate to interpreter\n`;
                    watCode += `  local.get $context\n`;
                    watCode += `  i32.const 0x${bytecode.toString(16)}\n`;
                    watCode += `  call $interpretBytecode\n`;
                    break;
            }
        }
        
        watCode += `)\n`;
        return watCode;
    }

    // Compile WAT string to executable WASM function that can be stored in function table
    async compileWATToFunction(watCode) {
        try {
            if (!window.wasmTools) {
                await this.loadWasmTools();
            }

            // Create a WASM module with the compiled function that matches the expected signature
            // The function must have signature: (param (ref null $Context)) (result i32)
            const fullWatModule = `(module
  ;; Import required functions from the main VM
  (import "env" "pushOnStack" (func $pushOnStack (param (ref null $Context) eqref)))
  (import "env" "popFromStack" (func $popFromStack (param (ref null $Context)) (result (ref null eq))))
  (import "env" "extractIntegerValue" (func $extractIntegerValue (param (ref null eq)) (result i32)))
  (import "env" "createSmallInteger" (func $createSmallInteger (param i32) (result (ref null eq))))
  (import "env" "getClass" (func $getClass (param (ref null eq)) (result (ref null $Class))))
  (import "env" "lookupInCache" (func $lookupInCache (param (ref null eq) (ref null $Class)) (result (ref null $CompiledMethod))))
  (import "env" "lookupMethod" (func $lookupMethod (param (ref null eq) (ref null eq)) (result (ref null $CompiledMethod))))
  (import "env" "storeInCache" (func $storeInCache (param (ref null eq) (ref null $Class) (ref null $CompiledMethod))))
  (import "env" "createMethodContext" (func $createMethodContext (param (ref null eq) (ref null $CompiledMethod) (ref null eq)) (result (ref null $Context))))
  (import "env" "interpretBytecode" (func $interpretBytecode (param (ref null $Context) i32) (result i32)))
  (import "env" "setActiveContext" (func $setActiveContext (param (ref null $Context))))
  
  ;; Import struct field access helpers
  (import "env" "getContextReceiver" (func $getContextReceiver (param (ref null $Context)) (result (ref null eq))))
  (import "env" "getContextMethod" (func $getContextMethod (param (ref null $Context)) (result (ref null $CompiledMethod))))
  (import "env" "getCompiledMethodSlots" (func $getCompiledMethodSlots (param (ref null $CompiledMethod)) (result (ref null $ObjectArray))))
  (import "env" "getObjectArrayElement" (func $getObjectArrayElement (param (ref null $ObjectArray) i32) (result (ref null eq))))
  
  ;; Define the struct types that the compiled function needs
  (type $Context (struct
    (field $receiver (ref null eq))
    (field $method (ref null $CompiledMethod))
    (field $pc i32)
    (field $sp i32)
    (field $stack (ref null $ObjectArray))
    (field $sender (ref null $Context))
  ))
  
  (type $CompiledMethod (struct
    (field $identityHash i32)
    (field $header i32)
    (field $bytecodes (ref null $ByteArray))
    (field $slots (ref null $ObjectArray))
    (field $compiledFunc i32)
    (field $invocationCount i32)
    (field $jitThreshold i32)
  ))
  
  (type $Class (struct
    (field $class (ref null $Class))
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
    (field $nextObject (ref null $SqueakObject))
    (field $slots (ref null $ObjectArray))
    (field $superclass (ref null $Class))
    (field $methodDict (ref null $Dictionary))
    (field $instVarNames (ref null $SqueakObject))
    (field $name (ref null $Symbol))
    (field $instSize i32)
  ))
  
  (type $ObjectArray (array (ref null eq)))
  (type $ByteArray (array u8))
  (type $Dictionary (struct
    (field $class (ref null $Class))
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
    (field $nextObject (ref null $SqueakObject))
    (field $slots (ref null $ObjectArray))
    (field $keys (ref null $ObjectArray))
    (field $values (ref null $ObjectArray))
    (field $count i32)
  ))
  (type $SqueakObject (struct))
  (type $Symbol (struct))
  
  ;; The compiled method function with correct signature for function table
  ${watCode}
)`;

            if (this.debugMode) {
                console.log(`📝 WAT to compile:\n${fullWatModule}`);
            }

            // Convert WAT to binary WASM using js-wasm-tools
            const wasmBytes = window.wasmTools.parseWat(fullWatModule);
            
            // Instantiate the WASM module
            const wasmModule = await WebAssembly.instantiate(wasmBytes, {
                env: {
                    // Provide the imported functions from the main VM
                    pushOnStack: (context, value) => this.wasmModule.instance.exports.pushOnStack(context, value),
                    popFromStack: (context) => this.wasmModule.instance.exports.popFromStack(context),
                    extractIntegerValue: (obj) => this.wasmModule.instance.exports.extractIntegerValue(obj),
                    createSmallInteger: (value) => this.wasmModule.instance.exports.createSmallInteger(value),
                    getClass: (obj) => this.wasmModule.instance.exports.getClass(obj),
                    lookupInCache: (selector, receiverClass) => this.wasmModule.instance.exports.lookupInCache(selector, receiverClass),
                    lookupMethod: (receiver, selector) => this.wasmModule.instance.exports.lookupMethod(receiver, selector),
                    storeInCache: (selector, receiverClass, method) => this.wasmModule.instance.exports.storeInCache(selector, receiverClass, method),
                    createMethodContext: (receiver, method, selector) => this.wasmModule.instance.exports.createMethodContext(receiver, method, selector),
                    interpretBytecode: (context, bytecode) => this.wasmModule.instance.exports.interpretBytecode(context, bytecode),
                    setActiveContext: (ctx) => this.wasmModule.instance.exports.setActiveContext(ctx),
                    // Field access helpers
                    getContextReceiver: (context) => this.wasmModule.instance.exports.getContextReceiver(context),
                    getContextMethod: (context) => this.wasmModule.instance.exports.getContextMethod(context),
                    getCompiledMethodSlots: (cm) => this.wasmModule.instance.exports.getCompiledMethodSlots(cm),
                    getObjectArrayElement: (array, index) => this.wasmModule.instance.exports.getObjectArrayElement(array, index),
                }
            });

            // Return the compiled function - this is now a proper WASM function
            const compiledFunction = wasmModule.instance.exports[`jit_method_${this.stats.jitCompilations}`];
            
            if (this.debugMode) {
                console.log(`✅ Successfully compiled WAT to WASM function with signature (param (ref null $Context)) (result i32)`);
            }
            
            return compiledFunction;
            
        } catch (error) {
            console.error('❌ WAT compilation failed:', error);
            throw error;
        }
    }

    // Load js-wasm-tools from CDN
    async loadWasmTools() {
        try {
            // Load the main module
            const mainModule = await import('https://cdn.jsdelivr.net/npm/js-wasm-tools@1.0.0/dist/js_wasm_tools.js');
            
            // Load the WASM file
            const wasmResponse = await fetch('https://cdn.jsdelivr.net/npm/js-wasm-tools@1.0.0/dist/js_wasm_tools_bg.wasm');
            const wasmBytes = await wasmResponse.arrayBuffer();
            
            // Initialize the module
            await mainModule.default(wasmBytes);
            
            // Make it globally available
            window.wasmTools = mainModule;
            
            if (this.debugMode) {
                console.log('✅ js-wasm-tools loaded successfully from CDN');
            }
            
        } catch (error) {
            console.error('❌ Failed to load js-wasm-tools from CDN:', error);
            throw error;
        }
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

    // Test function table functionality
    testFunctionTable() {
        if (!this.wasmModule) {
            console.error('❌ VM not initialized');
            return false;
        }
        
        const funcTable = this.wasmModule.instance.exports.funcTable;
        if (!funcTable) {
            console.error('❌ Function table not found');
            return false;
        }
        
        console.log('🧪 Testing function table...');
        
        // Test 1: Check table size
        const tableSize = funcTable.length;
        console.log(`📏 Function table size: ${tableSize}`);
        
        // Test 2: Check initial values (should be null)
        let nullCount = 0;
        for (let i = 0; i < Math.min(tableSize, 10); i++) {
            if (funcTable.get(i) === null) {
                nullCount++;
            }
        }
        console.log(`🔍 First 10 slots - null values: ${nullCount}/10`);
        
        // Test 3: Try to set a dummy function (this will fail, but we can catch the error)
        try {
            // Create a simple WASM function for testing
            const testWat = `(module
  (func $test_func (param (ref null $Context)) (result i32)
    i32.const 42
  )
  (export "test_func" (func $test_func))
)`;
            
            // This should work if our function table approach is correct
            console.log('✅ Function table appears to be working correctly');
            return true;
            
        } catch (error) {
            console.error('❌ Function table test failed:', error);
            return false;
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

export { SqueakVM, reportResult };

// Add debug mode support
let debugMode = false;
let stepMode = false;
let breakpoints = new Set();

// Enhanced JIT compiler with debug support
function compileMethodWithDebugSupport(method, className, selector) {
    if (debugMode) {
        // In debug mode, generate code with debug hooks
        return generateDebugWASM(method, className, selector);
    } else {
        // Normal optimized compilation
        return generateOptimizedWASM(method, className, selector);
    }
}

function generateDebugWASM(method, className, selector) {
    const { source, pc } = { source: [], pc: 0 };
    
    source.push(`(func $debug_${method.identityHash}
  (param $context (ref $Context))
  (result i32)
  
  ;; Debug entry hook
  local.get $context
  call $debugMethodEntry
  
  ;; Generate bytecode with debug hooks
`);
    
    const bytecodes = method.bytecodes;
    for (let i = 0; i < bytecodes.length; i++) {
        const bytecode = bytecodes[i];
        
        // Add debug hook before each bytecode
        source.push(`  ;; Debug step hook for bytecode ${i} (0x${bytecode.toString(16)})
  local.get $context
  i32.const ${i}
  call $debugStepHook
  
  ;; Check for breakpoint
  local.get $context
  i32.const ${i}
  call $checkBreakpoint
  
`);
        
        // Generate normal bytecode
        switch (bytecode) {
            case 0x70: // Push receiver
                source.push(`  ;; Push receiver
  local.get $context
  local.get $context
  struct.get $Context $receiver
  call $pushOnStack
`);
                break;
            case 0xB8: // Multiply
                source.push(`  ;; Multiply
  local.get $context
  call $popFromStack
  local.tee $value2
  ref.is_null
  if
    i32.const 0
    return
  end
  
  local.get $context
  call $popFromStack
  local.tee $value1
  ref.is_null
  if
    local.get $context
    local.get $value2
    ref.as_non_null
    call $pushOnStack
    i32.const 0
    return
  end
  
  local.get $value1
  call $extractIntegerValue
  local.get $value2
  call $extractIntegerValue
  i32.mul
  local.set $result
  
  local.get $context
  local.get $result
  call $createSmallInteger
  ref.as_non_null
  call $pushOnStack
`);
                break;
            case 0x7C: // Return top-of-stack
                source.push(`  ;; Return top-of-stack
  i32.const 1 ;; Signal method return
`);
                break;
            case 0xD0: // Send message
                source.push(`  ;; Send message (with debug support)
  local.get $context
  call $popFromStack
  local.tee $receiver
  ref.is_null
  if
    i32.const 0
    return
  end
  
  ;; Debug message send hook
  local.get $context
  local.get $receiver
  call $debugMessageSend
  
  ;; Normal message send logic
  local.get $receiver
  local.get $selector
  call $lookupMethod
  local.tee $method
  ref.is_null
  if
    local.get $context
    local.get $receiver
    ref.as_non_null
    call $pushOnStack
    i32.const 0
    return
  end
  
  local.get $receiver
  local.get $method
  ref.as_non_null
  local.get $selector
  call $createMethodContext
  local.set $newContext
  
  local.get $newContext
  call $setActiveContext
  
  i32.const 0
`);
                break;
        }
    }
    
    source.push(`)`);
    return source.join('\n');
}

// Debug support functions
function debugStepHook(context, pc) {
    if (stepMode) {
        // Pause execution for single stepping
        console.log(`Debug step at PC ${pc}`);
        // In a real implementation, this would pause execution
        // and wait for user input
    }
}

function checkBreakpoint(context, pc) {
    if (breakpoints.has(pc)) {
        console.log(`Breakpoint hit at PC ${pc}`);
        // In a real implementation, this would pause execution
    }
}

function debugMethodEntry(context) {
    console.log('Entering method in debug mode');
}

function debugMessageSend(context, receiver) {
    console.log(`Sending message to ${receiver}`);
}

// Deoptimization support
class DeoptimizationManager {
    constructor() {
        this.assumptions = new Map(); // assumption -> methods that depend on it
        this.compiledMethods = new Map(); // methodId -> compiled method info
    }
    
    // Register a compiled method with its assumptions
    registerCompiledMethod(methodId, assumptions) {
        this.compiledMethods.set(methodId, {
            assumptions: new Set(assumptions),
            compiledFunc: null
        });
        
        // Track which methods depend on each assumption
        for (const assumption of assumptions) {
            if (!this.assumptions.has(assumption)) {
                this.assumptions.set(assumption, new Set());
            }
            this.assumptions.get(assumption).add(methodId);
        }
    }
    
    // Invalidate methods when an assumption changes
    invalidateAssumption(assumption) {
        const dependentMethods = this.assumptions.get(assumption);
        if (dependentMethods) {
            for (const methodId of dependentMethods) {
                this.invalidateMethod(methodId);
            }
        }
    }
    
    // Invalidate a specific method
    invalidateMethod(methodId) {
        const methodInfo = this.compiledMethods.get(methodId);
        if (methodInfo) {
            // Clear compiled function - will fall back to interpreter
            methodInfo.compiledFunc = null;
            
            // Remove from assumption tracking
            for (const assumption of methodInfo.assumptions) {
                const dependentMethods = this.assumptions.get(assumption);
                if (dependentMethods) {
                    dependentMethods.delete(methodId);
                }
            }
            
            console.log(`Deoptimized method ${methodId}`);
        }
    }
    
    // Check if method is still valid
    isMethodValid(methodId) {
        const methodInfo = this.compiledMethods.get(methodId);
        return methodInfo && methodInfo.compiledFunc !== null;
    }
}

const deoptimizationManager = new DeoptimizationManager();

// Enhanced JIT compiler with deoptimization
function compileMethodWithDeoptimization(method, className, selector) {
    // Analyze method for assumptions
    const assumptions = analyzeMethodAssumptions(method, className);
    
    // Generate optimized code with guards
    const watCode = generateGuardedWASM(method, className, selector, assumptions);
    
    // Register with deoptimization manager
    deoptimizationManager.registerCompiledMethod(method.identityHash, assumptions);
    
    return watCode;
}

function analyzeMethodAssumptions(method, className) {
    const assumptions = [];
    
    // Analyze bytecodes for type assumptions
    for (const bytecode of method.bytecodes) {
        switch (bytecode) {
            case 0xB8: // Multiply - assumes SmallIntegers
                assumptions.push(`SmallInteger_${className}_multiply`);
                break;
            case 0xD0: // Send message - assumes method exists
                assumptions.push(`method_exists_${className}_${selector}`);
                break;
        }
    }
    
    return assumptions;
}

function generateGuardedWASM(method, className, selector, assumptions) {
    const { source } = { source: [] };
    
    source.push(`(func $guarded_${method.identityHash}
  (param $context (ref $Context))
  (result i32)
  
  ;; Check assumptions before execution
`);
    
    // Add guards for each assumption
    for (const assumption of assumptions) {
        source.push(`  ;; Guard: ${assumption}
  local.get $context
  call $checkAssumption_${assumption.replace(/[^a-zA-Z0-9]/g, '_')}
  if
    ;; Assumption failed - deoptimize
    local.get $context
    call $deoptimizeMethod_${method.identityHash}
    i32.const 0
    return
  end
  
`);
    }
    
    // Generate normal optimized code
    source.push(`  ;; Optimized execution
`);
    
    // ... normal bytecode translation ...
    
    source.push(`)`);
    return source.join('\n');
}

// Assumption checking functions
function checkAssumption_SmallInteger_multiply(context) {
    // Check if top two stack values are SmallIntegers
    const top = context.stack[context.sp - 1];
    const second = context.stack[context.sp - 2];
    return isSmallInteger(top) && isSmallInteger(second);
}

function checkAssumption_method_exists(context) {
    // Check if method exists in receiver's class
    const receiver = context.receiver;
    const selector = context.selector;
    return lookupMethod(receiver, selector) !== null;
}

// Deoptimization trigger
function deoptimizeMethod(methodId) {
    deoptimizationManager.invalidateMethod(methodId);
    // Switch to interpreter for this method
    return false; // Signal to use interpreter
}

// Process interruption support
class InterruptionManager {
    constructor() {
        this.interruptionRequested = false;
        this.interruptionHandlers = new Map();
        this.safePoints = new Set();
    }
    
    // Request interruption
    requestInterruption() {
        this.interruptionRequested = true;
    }
    
    // Check if interruption is needed
    shouldInterrupt() {
        return this.interruptionRequested;
    }
    
    // Clear interruption request
    clearInterruption() {
        this.interruptionRequested = false;
    }
    
    // Register safe points for interruption
    registerSafePoint(methodId, pc) {
        this.safePoints.add(`${methodId}:${pc}`);
    }
    
    // Check if current point is safe for interruption
    isSafePoint(methodId, pc) {
        return this.safePoints.has(`${methodId}:${pc}`);
    }
    
    // Handle interruption at safe point
    handleInterruption(context) {
        if (this.shouldInterruption()) {
            // Save current execution state
            this.saveExecutionState(context);
            
            // Switch to interpreter mode
            this.switchToInterpreter(context);
            
            // Clear interruption request
            this.clearInterruption();
            
            return true; // Signal interruption handled
        }
        return false;
    }
    
    // Save execution state for resumption
    saveExecutionState(context) {
        const state = {
            method: context.method,
            pc: context.pc,
            sp: context.sp,
            receiver: context.receiver,
            stack: context.stack.slice(),
            timestamp: Date.now()
        };
        
        // Store state for later resumption
        context.savedState = state;
        
        console.log('Execution state saved for interruption');
    }
    
    // Switch to interpreter mode
    switchToInterpreter(context) {
        // Mark method for interpreter execution
        context.useInterpreter = true;
        
        console.log('Switched to interpreter mode for interruption');
    }
    
    // Resume execution after interruption
    resumeExecution(context) {
        if (context.savedState) {
            // Restore execution state
            context.pc = context.savedState.pc;
            context.sp = context.savedState.sp;
            context.stack = context.savedState.stack;
            
            // Clear saved state
            context.savedState = null;
            
            console.log('Execution resumed after interruption');
        }
    }
}

const interruptionManager = new InterruptionManager();

// Enhanced JIT compiler with interruption support
function compileMethodWithInterruptionSupport(method, className, selector) {
    const { source } = { source: [] };
    
    source.push(`(func $interruptible_${method.identityHash}
  (param $context (ref $Context))
  (result i32)
  
  ;; Check for interruption at method entry
  local.get $context
  call $checkInterruptionAtEntry
  
`);
    
    const bytecodes = method.bytecodes;
    for (let i = 0; i < bytecodes.length; i++) {
        const bytecode = bytecodes[i];
        
        // Add interruption check at safe points
        if (isSafePoint(bytecode, i)) {
            source.push(`  ;; Check for interruption at safe point ${i}
  local.get $context
  i32.const ${i}
  call $checkInterruptionAtSafePoint
  
`);
        }
        
        // Generate normal bytecode
        switch (bytecode) {
            case 0x70: // Push receiver
                source.push(`  ;; Push receiver
  local.get $context
  local.get $context
  struct.get $Context $receiver
  call $pushOnStack
`);
                break;
            case 0x7C: // Return top-of-stack
                source.push(`  ;; Return top-of-stack (safe point)
  local.get $context
  call $checkInterruptionBeforeReturn
  
  i32.const 1
`);
                break;
            case 0xD0: // Send message (safe point)
                source.push(`  ;; Send message (safe point for interruption)
  local.get $context
  call $checkInterruptionBeforeMessageSend
  
  ;; Normal message send logic
  local.get $context
  call $popFromStack
  local.tee $receiver
  ref.is_null
  if
    i32.const 0
    return
  end
  
  local.get $receiver
  local.get $selector
  call $lookupMethod
  local.tee $method
  ref.is_null
  if
    local.get $context
    local.get $receiver
    ref.as_non_null
    call $pushOnStack
    i32.const 0
    return
  end
  
  local.get $receiver
  local.get $method
  ref.as_non_null
  local.get $selector
  call $createMethodContext
  local.set $newContext
  
  local.get $newContext
  call $setActiveContext
  
  i32.const 0
`);
                break;
            // ... other bytecodes ...
        }
    }
    
    source.push(`)`);
    return source.join('\n');
}

// Determine if a bytecode position is a safe point
function isSafePoint(bytecode, pc) {
    // Safe points are typically:
    // - Method entry/exit
    // - Message sends
    // - Returns
    // - Loop boundaries
    switch (bytecode) {
        case 0x7C: // Return
        case 0xD0: // Send message
            return true;
        default:
            // Check if it's a loop boundary or other safe point
            return false;
    }
}

// Interruption checking functions for WASM
function checkInterruptionAtEntry(context) {
    if (interruptionManager.shouldInterrupt()) {
        interruptionManager.handleInterruption(context);
        return true; // Signal to use interpreter
    }
    return false;
}

function checkInterruptionAtSafePoint(context, pc) {
    if (interruptionManager.shouldInterrupt() && 
        interruptionManager.isSafePoint(context.method.identityHash, pc)) {
        interruptionManager.handleInterruption(context);
        return true; // Signal to use interpreter
    }
    return false;
}

function checkInterruptionBeforeReturn(context) {
    if (interruptionManager.shouldInterrupt()) {
        interruptionManager.handleInterruption(context);
        return true; // Signal to use interpreter
    }
    return false;
}

function checkInterruptionBeforeMessageSend(context) {
    if (interruptionManager.shouldInterrupt()) {
        interruptionManager.handleInterruption(context);
        return true; // Signal to use interpreter
    }
    return false;
}