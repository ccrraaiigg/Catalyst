# SqueakJS to WASM with Bytecode JIT and Minimal Object Memory

## Squeak Snapshot Compatibility and Minimal Bootstrap

### Snapshot Resume Architecture

The VM must be able to resume any existing Squeak snapshot, including:
- **Classic bytecode sets** (Blue Book, Closure, etc.)
- **Sista instruction set** from Cog VM
- **Multi-process environments** with scheduler state
- **Mid-snapshot processes** that were creating/resuming snapshots

### WASM GC Object Memory Compatible with Squeak Format

```wat
;; Squeak-compatible object header using WASM GC
(type $SqueakObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)    ;; Squeak object format (0-31)
  (field $size i32)      ;; Object size for GC coordination
))

;; Variable objects (most Squeak objects) - can contain SmallIntegers as i31refs
(type $VariableObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $slots (ref array (ref null anyref)))  ;; Both inst vars and indexable fields
))

;; Byte objects (Strings, ByteArrays, etc.)
(type $ByteObject (struct
  (field $class (ref $Class))
  (field $identityHash i32) 
  (field $format i32)
  (field $size i32)
  (field $bytes (ref array i8))
))

;; Word objects (Bitmaps, etc.)
(type $WordObject (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32) 
  (field $size i32)
  (field $words (ref array i32))
))

;; CompiledMethod with support for both classic and Sista bytecodes
(type $CompiledMethod (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $header i32)           ;; Method header with primitive, args, temps
  (field $literals (ref array (ref null anyref)))  ;; Can contain objects or i31refs
  (field $bytecodes (ref array i8))
  (field $sistaFlag i32)        ;; 0 = classic, 1 = Sista
  (field $compiledWasm (ref null func))  ;; JIT compiled version
  (field $invocationCount i32)  ;; For JIT heuristics
))

;; SmallInteger object type for immediate integers
(type $SmallIntegerObject (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $value i32)  ;; The actual integer value
))

(type $Process (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $nextLink (ref null $Process))
  (field $suspendedContext (ref null $Context))
  (field $priority i32)
  (field $myList (ref null $SqueakObject))  ;; Semaphore or ProcessorScheduler
  (field $threadId i32)         ;; For future threading support
))

;; Context object matching Squeak format exactly
(type $Context (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $sender (ref null $Context))
  (field $pc i32)
  (field $stackp i32)
  (field $method (ref $CompiledMethod))
  (field $closureOrNil (ref null anyref))  ;; Can be object or i31ref
  (field $receiver (ref null anyref))     ;; Can be object or i31ref (SmallInteger)
  ;; Stack and temps stored in variable part - can contain objects or i31refs
  (field $stackAndTemps (ref array (ref null anyref)))
))
```

## Minimal Bootstrap for Development

### JavaScript Interface

```javascript
class MinimalSqueakVM {
    constructor() {
        this.onResult = null;
    }

    async initialize() {
        const imports = {
            system: {
                reportResult: (value) => {
                    if (this.onResult) this.onResult(value);
                },
                currentTimeMillis: () => Date.now()
            }
        };

        this.vmModule = await WebAssembly.instantiateStreaming(
            fetch('squeak-vm.wasm'),
            imports
        );
    }

    async runMinimalExample() {
        // Create minimal 3 + 4 example
        const success = this.vmModule.exports.createMinimalBootstrap();
        if (!success) {
            throw new Error('Failed to create minimal bootstrap');
        }

        // Run until completion
        this.vmModule.exports.interpret();
    }

    async loadSnapshot(snapshotData) {
        // Load existing Squeak snapshot
        const gcArray = this.vmModule.exports.createByteArray(snapshotData.length);
        for (let i = 0; i < snapshotData.length; i++) {
            this.vmModule.exports.setByteAt(gcArray, i, snapshotData[i]);
        }

        const success = this.vmModule.exports.loadSnapshot(gcArray);
        if (!success) {
            throw new Error('Failed to load snapshot');
        }

        // Resume execution
        this.vmModule.exports.interpret();
    }
}

// Usage
async function main() {
    const vm = new MinimalSqueakVM();
    await vm.initialize();
    
    // Start with minimal example
    vm.onResult = (result) => {
        console.log(`Got result: ${result}`);
        // Expected output: "Got result: 7"
    };
    
    await vm.runMinimalExample();
    
    // Later: load full Squeak snapshot
    // const snapshotData = await fetch('squeak6.2.image');
    // await vm.loadSnapshot(new Uint8Array(await snapshotData.arrayBuffer()));
}
```

## Development Path

### Phase 1: Minimal Bootstrap (1-2 weeks)
- Implement minimal class hierarchy
- Create 3 + 4 = 7 example
- Basic bytecode interpreter for essential opcodes
- JavaScript result reporting

### Phase 2: Classic Bytecode Support (2-3 weeks)  
- Complete classic bytecode set implementation
- Method lookup and message sending
- Context creation and stack management
- Process scheduling basics

### Phase 3: JIT Compilation (3-4 weeks)
- Bytecode to WASM translation engine
- Hot method detection and invocation counting
- Compiled method caching and invalidation
- Performance optimization for arithmetic and control flow
- **Critical for performance**: JIT enables the VM to run efficiently before handling complex snapshots

### Phase 4: Snapshotting (2-3 weeks)
- **Object Memory Persistence**: Implement facilities for serializing the complete WASM GC object memory state, including all live objects, their references, and metadata
- **Live State Capture**: Capture execution state including active processes, contexts, stack frames, and program counters for seamless resumption
- **Incremental Snapshotting**: Support differential snapshots that only save changes since the last full snapshot, optimizing storage and transfer
- **Cross-Session Persistence**: Enable saving VM state to browser storage or external files for persistence across browser sessions
- **Live Cloning**: Implement in-memory object memory duplication for creating independent VM instances or rollback points
- **Snapshot Validation**: Verify snapshot integrity and compatibility before loading, with graceful error handling for corrupted or incompatible snapshots
- **JIT State Preservation**: Handle compiled method persistence and restoration, including JIT compilation metadata and optimized method caches
- **Memory Layout Optimization**: Organize snapshotted object memory for efficient loading and minimal memory fragmentation on restoration
- **Development Workflow Integration**: Provide snapshot creation/restoration APIs for integration with Smalltalk development tools and debugging workflows
- **Version Compatibility**: Support loading snapshots created by different VM versions with appropriate migration strategies

### Phase 5: Slang for WASM
- Like Squeak and SqueakJS before it, SqueakWASM should generate all
  of its virtual machine sources from Smalltalk. This will make
  maintenance and modification easier, through the use of familiar
  Smalltalk tools. In this phase, we want to develop facilities for
  generating all the WAT files of the virtual machine from a working
  Smalltalk version of the same logic. After this phase, we shouldn't
  need to write WAT by hand. This subsystem is traditionally called
  "Slang".

### Phase 6: Snapshot Loading (2-3 weeks)
- Squeak image format parser
- Object memory reconstruction with JIT-compiled methods
- Reference fixing and finalization
- Multi-process resume capability
- **Benefits from JIT**: Loading large snapshots runs much faster with compiled methods

### Phase 7: Sista Bytecode Support (1-2 weeks)
- Extended Sista instruction set
- Full closure support with JIT compilation
- Advanced control flow optimizations
- JIT compilation of Sista-specific bytecodes

### Phase 8: Adaptive Optimization (2-3 weeks)
- **Performance Profiling Infrastructure**: Instrument VM with automated profiling hooks for method execution time, memory usage, and call frequency
- **Usage Metrics Collection**: Track method invocation patterns, object allocation rates, and memory pressure indicators
- **Dynamic JIT Threshold Adjustment**: Automatically adjust compilation thresholds based on runtime performance characteristics and memory constraints
- **Profile-Guided Optimization**: Use collected metrics to optimize method translation strategies (inlining decisions, register allocation, loop optimizations)
- **Adaptive Memory Management**: Adjust GC frequency and object allocation strategies based on observed memory usage patterns
- **Hot Path Detection**: Identify and optimize frequently executed code paths across method boundaries
- **Performance Regression Detection**: Monitor for performance degradations and automatically trigger re-optimization
- **Machine Learning Integration**: Use collected metrics to predict optimal compilation strategies for similar method patterns
- **Real-time Optimization Feedback**: Provide live performance insights to developers through Smalltalk tools and browser console

## Rationale for JIT-First Approach

**Performance Foundation**: JIT compilation provides the performance foundation needed for the VM to be practical. Without it, even basic operations would be too slow for real development work.

**Snapshot Loading Efficiency**: Loading and initializing large Squeak snapshots involves executing many methods. Having JIT compilation available makes this process much faster and more responsive.

**Early Optimization Validation**: Implementing JIT early allows us to validate and tune the performance characteristics before dealing with the complexity of full snapshot compatibility.

**Development Workflow**: Once JIT is working, the development experience becomes much more pleasant, making subsequent phases more productive.

This approach ensures we build performance into the foundation rather than trying to add it later, and gives us a fast, responsive VM for loading and working with complex Squeak environments.

## WASM GC Object Memory Structure

### Core Object Types

```wat
;; Base Smalltalk object using WASM GC
(type $Object (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
))

;; Objects with pointer fields
(type $PointersObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $fields (ref array (ref null $Object)))
))

;; Objects with byte data  
(type $BytesObject (struct
  (field $class (ref $Class))
  (field $identityHash i32) 
  (field $bytes (ref array i8))
))

;; Method objects containing bytecodes
(type $Method (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $bytecodes (ref array i8))
  (field $literals (ref array (ref null $Object)))
  (field $header i32)  ;; encoded: primitive index, arg count, temp count
  (field $compiledWasm (ref null func))  ;; JIT compiled version
))

;; Class objects
(type $Class (struct
  (field $class (ref $Class))  ;; metaclass
  (field $identityHash i32)
  (field $superclass (ref null $Class))
  (field $methodDict (ref $Dictionary))
  (field $format i32)
  (field $instVarNames (ref array (ref string)))
  (field $name (ref string))
))

;; Process execution context
(type $Context (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $sender (ref null $Context))
  (field $pc i32)
  (field $sp i32)
  (field $method (ref $Method))
  (field $receiver (ref null $Object))
  (field $stack (ref array (ref null $Object)))
))

;; Process object
(type $Process (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $suspendedContext (ref null $Context))
  (field $priority i32)
  (field $nextLink (ref null $Process))
))
```

## Bytecode Interpreter with JIT Compilation

### Core VM Module

```wat
(module $VMCore
  ;; Import JavaScript I/O services
  (import "io" "readFile" (func $readFile (param (ref string)) (result (ref extern))))
  (import "display" "updateDisplay" (func $updateDisplay (param i32 i32 i32 i32)))
  (import "events" "getNextEvent" (func $getNextEvent (result i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "reportResult" (func $system_report_result (param i32)))
  
  ;; WASM exception types for VM control flow
  (tag $Return (param (ref null $Object)))
  (tag $ProcessSwitch (param (ref $Process)))
  (tag $PrimitiveFailed)
  
  ;; Global VM state
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  (global $newMethod (mut (ref null $Method)) (ref.null $Method))
  (global $newReceiver (mut (ref null $Object)) (ref.null $Object))
  (global $argumentCount (mut i32) (i32.const 0))
  (global $primitiveIndex (mut i32) (i32.const 0))
  
  ;; Current method execution state
  (global $pc (mut i32) (i32.const 0))
  (global $sp (mut i32) (i32.const 0))
  
  ;; Central interpretation loop
  (func (export "interpret")
    (local $bytecode i32)
    (local $method (ref $Method))
    
    loop $interpretation_loop
      ;; Fetch current bytecode
      global.get $activeContext
      call $get_method
      local.tee $method
      
      call $get_bytecode_at_pc
      local.set $bytecode
      
      ;; Execute bytecode with exception handling
      try_table (catch $Return 0) (catch $ProcessSwitch 1) (catch $PrimitiveFailed 2)
        local.get $bytecode
        call $execute_bytecode
        
        ;; Increment PC after normal instruction
        call $increment_pc
        br $interpretation_loop
        
        ;; Label 0: Method return
        call $handle_method_return
        br $interpretation_loop
        
        ;; Label 1: Process switch
        call $switch_to_process
        br $interpretation_loop
        
        ;; Label 2: Primitive failure - continue with bytecodes
        br $interpretation_loop
      end
    end
  )
  
  ;; Stack operations using WASM GC
  (func $push_object (param $object (ref null $Object))
    (local $context (ref $Context))
    (local $stack (ref array (ref null $Object)))
    (local $sp i32)
    
    global.get $activeContext
    ref.cast $Context
    local.tee $context
    
    ;; Get current stack pointer
    struct.get $Context 4
    local.tee $sp
    
    ;; Push object onto stack
    struct.get $Context 7  ;; stack field
    local.get $sp
    local.get $object
    array.set
    
    ;; Increment stack pointer
    local.get $context
    local.get $sp
    i32.const 1
    i32.add
    struct.set $Context 4
  )
  
  (func $pop_object (result (ref null $Object))
    (local $context (ref $Context))
    (local $sp i32)
    
    global.get $activeContext
    ref.cast $Context
    local.tee $context
    
    ;; Decrement stack pointer
    struct.get $Context 4
    i32.const 1
    i32.sub
    local.tee $sp
    
    local.get $context
    local.get $sp
    struct.set $Context 4
    
    ;; Get object from stack
    struct.get $Context 7  ;; stack field
    local.get $sp
    array.get
  )
)
```

## JIT Compiler: Bytecode to WASM

### JIT Compilation Engine

```wat
;; JIT compiler module
(func $jit_compile_method (param $method (ref $Method))
  (local $bytecodes (ref array i8))
  (local $compiled_func (ref null func))
  
  local.get $method
  struct.get $Method 2  ;; bytecodes field
  local.tee $bytecodes
  
  ;; Analyze bytecode sequence
  call $analyze_bytecodes
  
  ;; Generate WASM function
  call $generate_wasm_function
  local.set $compiled_func
  
  ;; Cache compiled version
  local.get $method
  local.get $compiled_func
  struct.set $Method 5  ;; compiledWasm field
  
  ;; Add to JIT cache
  local.get $method
  local.get $compiled_func
  call $cache_jit_method
)

;; Generate WASM function from bytecode sequence
(func $generate_wasm_function (param $bytecodes (ref array i8)) (result (ref func))
  (local $func_body (ref array i32))  ;; WASM instructions
  (local $i i32)
  (local $bytecode i32)
  
  ;; Create dynamic function body
  local.get $bytecodes
  array.len
  call $create_instruction_array
  local.set $func_body
  
  ;; Translate each bytecode to WASM instructions
  loop $translate_loop
    local.get $bytecodes
    local.get $i
    array.get_u
    local.set $bytecode
    
    ;; Generate WASM instructions for this bytecode
    local.get $bytecode
    call $bytecode_to_wasm
    local.get $func_body
    local.get $i
    call $append_instructions
    
    ;; Next bytecode
    local.get $i
    i32.const 1
    i32.add
    local.tee $i
    
    local.get $bytecodes
    array.len
    i32.lt_u
    br_if $translate_loop
  end
  
  ;; Compile WASM function
  local.get $func_body
  call $compile_wasm_function
)

;; Bytecode to WASM instruction translation
(func $bytecode_to_wasm (param $bytecode i32) (result (ref array i32))
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... cases for each bytecode
    block $case144  ;; pushConstant
      br_table 0 1 2 ... 144 ... 255 $end
    end $case144
    ;; Generate WASM for pushConstant
    call $generate_push_constant_wasm
    br $end
    
    ;; ... more bytecode translations
  end
)
```

## Performance Optimizations

### 1. Polymorphic Inline Caching

```wat
;; Polymorphic inline cache using WASM GC
(type $PIC (struct
  (field $selector (ref string))
  (field $class0 (ref null $Class))
  (field $method0 (ref null $Method))
  (field $class1 (ref null $Class))
  (field $method1 (ref null $Method))
  (field $class2 (ref null $Class))
  (field $method2 (ref null $Method))
  (field $miss_count i32)
))

(func $pic_lookup (param $pic (ref $PIC)) (param $class (ref $Class)) (result (ref null $Method))
  ;; Check cache entries
  local.get $pic
  struct.get $PIC 1  ;; class0 field
  local.get $class
  ref.eq
  if (result (ref null $Method))
    local.get $pic
    struct.get $PIC 2  ;; method0 field
  else
    local.get $pic
    struct.get $PIC 3  ;; class1 field
    local.get $class
    ref.eq
    if (result (ref null $Method))
      local.get $pic
      struct.get $PIC 4  ;; method1 field
    else
      local.get $pic
      struct.get $PIC 5  ;; class2 field
      local.get $class
      ref.eq
      if (result (ref null $Method))
        local.get $pic
        struct.get $PIC 6  ;; method2 field
      else
        ;; Cache miss
        ref.null $Method
      end
    end
  end
)
```

### 2. JIT Compilation Heuristics

```wat
;; JIT compilation decision logic
(func $check_jit_threshold (param $method (ref $Method)) (result i32)
  (local $invocation_count i32)
  (local $bytecode_length i32)
  
  local.get $method
  call $get_invocation_count
  local.set $invocation_count
  
  local.get $method
  struct.get $Method 2  ;; bytecodes field
  array.len
  local.set $bytecode_length
  
  ;; Compile if hot enough and not too large
  local.get $invocation_count
  i32.const 100  ;; threshold
  i32.ge_u
  
  local.get $bytecode_length
  i32.const 500  ;; max size for JIT
  i32.le_u
  
  i32.and
)
```

## Development Workflow

### 1. Bootstrap Sequence

```javascript
async function bootstrapSmalltalkVM() {
    // Load minimal WASM VM
    const vmModule = await WebAssembly.instantiateStreaming(
        fetch('squeak-vm.wasm'), 
        createVMImports()
    );
    
    // Create minimal object memory
    vmModule.exports.createMinimalObjectMemory();
    
    // Load essential classes
    await loadEssentialClasses(vmModule);
    
    // Start initial process
    vmModule.exports.interpret();
}

async function loadEssentialClasses(vmModule) {
    const classData = await fetch('essential-classes.image');
    const classBytes = new Uint8Array(await classData.arrayBuffer());
    
    // Convert to WASM GC byte array
    const gcBytes = vmModule.exports.createByteArray(classBytes.length);
    for (let i = 0; i < classBytes.length; i++) {
        vmModule.exports.setByteAt(gcBytes, i, classBytes[i]);
    }
    
    // Load classes into object memory
    vmModule.exports.loadClasses(gcBytes);
}
```

### 2. Live Development Support

```javascript
// Hot method replacement
async function replaceMethod(className, selector, newBytecodes) {
    // Invalidate JIT cache
    vmModule.exports.invalidateJITCache(className, selector);
    
    // Replace method
    vmModule.exports.replaceMethod(className, selector, newBytecodes);
    
    // Continue execution
    vmModule.exports.interpret();
}

// Class Hot-Swapping

async function hotSwapClass(className, newClassData) {
    // Invalidate JIT cache for this class
    vmModule.exports.invalidateJITForClass(className);
    
    // Replace class definition
    vmModule.exports.replaceClass(className, newClassData);
    
    // Migrate existing instances
    vmModule.exports.migrateInstances(className);
}
```

## Benefits

**Authentic Smalltalk Semantics**: Bytecode interpretation preserves exact Smalltalk behavior
**JIT Performance**: Hot methods get compiled to efficient WASM for near-native speed  
**Minimal Bootstrap**: Small, focused object memory enables fast startup
**Exception-Based Control**: Clean, efficient VM control flow using WASM exceptions
**Live Development**: Dynamic class loading and method replacement
**Type Safety**: WASM GC prevents memory corruption and enables safe optimizations

This architecture provides an authentic Smalltalk virtual machine that leverages WebAssembly's strengths while maintaining the live, dynamic development experience that makes Smalltalk unique.
