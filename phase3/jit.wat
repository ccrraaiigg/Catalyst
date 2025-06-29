;; SqueakJS WASM VM - Phase 3: JIT Compilation Engine
;; Bytecode-to-WASM translation with hot method detection

(module $JITCompiler
  ;; Import the base VM types and functions
  (import "vm" "CompiledMethod" (type $CompiledMethod))
  (import "vm" "Context" (type $Context))
  (import "vm" "system_report_result" (func $system_report_result (param i32)))
  
  ;; JIT compilation types
  (type $JITEntry (struct 
    (field $method (ref $CompiledMethod))
    (field $compiledFunc (ref null func))
    (field $compilationLevel i32)  ;; 0=uncompiled, 1=basic, 2=optimized
    (field $lastUsed i64)          ;; timestamp for cache eviction
  ))
  
  (type $JITCache (struct
    (field $entries (ref array (ref null $JITEntry)))
    (field $size i32)
    (field $capacity i32)
  ))

  ;; Global JIT state
  (global $jitCache (mut (ref null $JITCache)) (ref.null $JITCache))
  (global $jitThreshold i32 (i32.const 100))      ;; Invocations before JIT
  (global $jitOptThreshold i32 (i32.const 1000))  ;; Invocations for optimization
  (global $maxCacheSize i32 (i32.const 512))      ;; Max cached methods
  
  ;; JIT statistics
  (global $totalCompilations (mut i32) (i32.const 0))
  (global $cacheHits (mut i32) (i32.const 0))
  (global $cacheMisses (mut i32) (i32.const 0))
  
  ;; Initialize JIT cache
  (func $initJITCache
    (local $cache (ref $JITCache))
    
    ;; Create cache structure
    global.get $maxCacheSize
    ref.null $JITEntry
    array.new $JITEntry
    i32.const 0      ;; size
    global.get $maxCacheSize  ;; capacity
    struct.new $JITCache
    local.set $cache
    
    local.get $cache
    global.set $jitCache
  )
  
  ;; Check if method should be JIT compiled
  (func $shouldCompileMethod (param $method (ref $CompiledMethod)) (result i32)
    (local $invocationCount i32)
    (local $bytecodeLength i32)
    
    ;; Get invocation count
    local.get $method
    struct.get $CompiledMethod $invocationCount
    local.set $invocationCount
    
    ;; Get bytecode length
    local.get $method
    struct.get $CompiledMethod $bytecodes
    array.len
    local.set $bytecodeLength
    
    ;; Check thresholds
    local.get $invocationCount
    global.get $jitThreshold
    i32.ge_u
    
    ;; Don't compile if too large (> 200 bytecodes)
    local.get $bytecodeLength
    i32.const 200
    i32.le_u
    
    i32.and
  )
  
  ;; Find method in JIT cache
  (func $findJITEntry (param $method (ref $CompiledMethod)) (result (ref null $JITEntry))
    (local $cache (ref $JITCache))
    (local $entries (ref array (ref null $JITEntry)))
    (local $i i32)
    (local $entry (ref null $JITEntry))
    
    global.get $jitCache
    ref.as_non_null
    local.tee $cache
    struct.get $JITCache $entries
    local.set $entries
    
    ;; Linear search through cache
    loop $search_loop
      local.get $i
      local.get $cache
      struct.get $JITCache $size
      i32.ge_u
      br_if $search_loop
      
      local.get $entries
      local.get $i
      array.get $JITEntry
      local.tee $entry
      ref.is_null
      br_if $next_entry
      
      ;; Check if this entry matches our method
      local.get $entry
      ref.as_non_null
      struct.get $JITEntry $method
      local.get $method
      ref.eq
      if (result (ref null $JITEntry))
        ;; Found it! Update access time
        global.get $cacheHits
        i32.const 1
        i32.add
        global.set $cacheHits
        
        local.get $entry
        call $currentTimeMillis
        struct.set $JITEntry $lastUsed
        
        local.get $entry
        return
      end
      
      block $next_entry
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $search_loop
    end
    
    ;; Not found
    global.get $cacheMisses
    i32.const 1
    i32.add
    global.set $cacheMisses
    
    ref.null $JITEntry
  )
  
  ;; Add compiled method to cache
  (func $addToJITCache (param $method (ref $CompiledMethod)) (param $compiledFunc (ref func))
    (local $cache (ref $JITCache))
    (local $entry (ref $JITEntry))
    (local $entries (ref array (ref null $JITEntry)))
    (local $index i32)
    
    global.get $jitCache
    ref.as_non_null
    local.set $cache
    
    ;; Create new JIT entry
    local.get $method
    local.get $compiledFunc
    i32.const 1  ;; basic compilation level
    call $currentTimeMillis
    struct.new $JITEntry
    local.set $entry
    
    ;; Find slot in cache
    local.get $cache
    struct.get $JITCache $size
    local.set $index
    
    ;; Check if cache is full
    local.get $index
    local.get $cache
    struct.get $JITCache $capacity
    i32.ge_u
    if
      ;; Evict least recently used entry
      call $evictLRUEntry
      local.get $cache
      struct.get $JITCache $size
      i32.const 1
      i32.sub
      local.set $index
    end
    
    ;; Add to cache
    local.get $cache
    struct.get $JITCache $entries
    local.get $index
    local.get $entry
    array.set $JITEntry
    
    ;; Update cache size
    local.get $cache
    local.get $index
    i32.const 1
    i32.add
    struct.set $JITCache $size
  )
  
  ;; Evict least recently used entry
  (func $evictLRUEntry
    (local $cache (ref $JITCache))
    (local $entries (ref array (ref null $JITEntry)))
    (local $i i32)
    (local $oldestIndex i32)
    (local $oldestTime i64)
    (local $entry (ref null $JITEntry))
    (local $entryTime i64)
    
    global.get $jitCache
    ref.as_non_null
    local.tee $cache
    struct.get $JITCache $entries
    local.set $entries
    
    i64.const 0x7FFFFFFFFFFFFFFF  ;; max i64
    local.set $oldestTime
    
    ;; Find oldest entry
    loop $find_oldest
      local.get $i
      local.get $cache
      struct.get $JITCache $size
      i32.ge_u
      br_if $find_oldest
      
      local.get $entries
      local.get $i
      array.get $JITEntry
      local.tee $entry
      ref.is_null
      br_if $next_check
      
      local.get $entry
      ref.as_non_null
      struct.get $JITEntry $lastUsed
      local.tee $entryTime
      
      local.get $oldestTime
      i64.lt_u
      if
        local.get $entryTime
        local.set $oldestTime
        local.get $i
        local.set $oldestIndex
      end
      
      block $next_check
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $find_oldest
    end
    
    ;; Remove oldest entry by shifting array
    local.get $oldestIndex
    i32.const 1
    i32.add
    local.set $i
    
    loop $shift_array
      local.get $i
      local.get $cache
      struct.get $JITCache $size
      i32.ge_u
      br_if $shift_array
      
      local.get $entries
      local.get $i
      i32.const 1
      i32.sub
      local.get $entries
      local.get $i
      array.get $JITEntry
      array.set $JITEntry
      
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $shift_array
    end
  )
  
  ;; JIT compile method to WASM
  (func $jitCompileMethod (param $method (ref $CompiledMethod)) (result (ref null func))
    (local $bytecodes (ref array i8))
    (local $literals (ref array (ref null any)))
    (local $wasmFunc (ref null func))
    (local $pc i32)
    (local $bytecode i32)
    (local $functionBuilder (ref $FunctionBuilder))
    
    global.get $totalCompilations
    i32.const 1
    i32.add
    global.set $totalCompilations
    
    ;; Get method bytecodes and literals
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.set $bytecodes
    
    local.get $method
    struct.get $CompiledMethod $slots  ;; literals in first part
    local.set $literals
    
    ;; Create function builder
    call $createFunctionBuilder
    local.set $functionBuilder
    
    ;; Generate WASM function prologue
    local.get $functionBuilder
    call $generatePrologue
    
    ;; Translate bytecodes to WASM
    loop $compile_loop
      local.get $pc
      local.get $bytecodes
      array.len
      i32.ge_u
      br_if $compile_loop
      
      ;; Get next bytecode
      local.get $bytecodes
      local.get $pc
      array.get_u $ByteArray
      local.set $bytecode
      
      ;; Translate bytecode to WASM instructions
      local.get $functionBuilder
      local.get $bytecode
      local.get $pc
      local.get $literals
      call $translateBytecode
      
      ;; Advance PC
      local.get $pc
      i32.const 1
      i32.add
      local.set $pc
      br $compile_loop
    end
    
    ;; Generate function epilogue
    local.get $functionBuilder
    call $generateEpilogue
    
    ;; Build final WASM function
    local.get $functionBuilder
    call $buildFunction
  )
  
  ;; Function builder type for dynamic WASM generation
  (type $FunctionBuilder (struct
    (field $instructions (ref array i32))
    (field $instructionCount i32)
    (field $locals (ref array i32))
    (field $localCount i32)
  ))
  
  ;; Create function builder
  (func $createFunctionBuilder (result (ref $FunctionBuilder))
    i32.const 1000  ;; max instructions
    i32.const 0
    array.new i32   ;; instructions array
    i32.const 0     ;; instruction count
    i32.const 20    ;; max locals
    i32.const 0
    array.new i32   ;; locals array
    i32.const 0     ;; local count
    struct.new $FunctionBuilder
  )
  
  ;; Generate function prologue (setup locals, etc.)
  (func $generatePrologue (param $builder (ref $FunctionBuilder))
    ;; Add local declarations
    local.get $builder
    i32.const 0x20  ;; local.get instruction
    call $addInstruction
    
    local.get $builder
    i32.const 0x21  ;; local.set instruction  
    call $addInstruction
  )
  
  ;; Generate function epilogue (return handling)
  (func $generateEpilogue (param $builder (ref $FunctionBuilder))
    ;; Add return instruction
    local.get $builder
    i32.const 0x0F  ;; return instruction
    call $addInstruction
  )
  
  ;; Add instruction to function builder
  (func $addInstruction (param $builder (ref $FunctionBuilder)) (param $instruction i32)
    (local $instructions (ref array i32))
    (local $count i32)
    
    local.get $builder
    struct.get $FunctionBuilder $instructions
    local.set $instructions
    
    local.get $builder
    struct.get $FunctionBuilder $instructionCount
    local.tee $count
    
    local.get $instructions
    local.get $count
    local.get $instruction
    array.set i32
    
    local.get $builder
    local.get $count
    i32.const 1
    i32.add
    struct.set $FunctionBuilder $instructionCount
  )
  
  ;; Translate single bytecode to WASM instructions for "3 squared" demo
  (func $translateBytecode 
    (param $builder (ref $FunctionBuilder)) 
    (param $bytecode i32) 
    (param $pc i32)
    (param $literals (ref array (ref null any)))
    
    local.get $bytecode
    
    block $end
      block $case255
      ;; Classic bytecodes for "3 squared" demo
      block $case0xD0  ;; send reportToJS
      block $case0xB1  ;; send * (multiply)
      block $case0x90  ;; send literal selector 0 (squared)
      block $case0x7C  ;; returnTop
      block $case0x76  ;; push 3
      block $case0x70  ;; push receiver (self)
      block $case0    ;; pushInstVar 0
        br_table $case0 ... $case0x70 $case0x76 $case0x7C $case0x90 $case0xB1 $case0xD0 ... $case255 $end
      end $case0
      ;; pushInstVar 0 - load first instance variable
      local.get $builder
      call $generateInstVarAccess
      br $end
      
      end $case0x70
      ;; pushReceiver (self) - load receiver from context
      local.get $builder
      i32.const 0x20  ;; local.get
      call $addInstruction
      local.get $builder
      i32.const 0    ;; receiver local index
      call $addInstruction
      br $end
      
      end $case0x76
      ;; push 3 - load immediate i31ref
      local.get $builder
      i32.const 0x41  ;; i32.const
      call $addInstruction
      local.get $builder
      i32.const 3     ;; value 3
      call $addInstruction
      local.get $builder
      i32.const 0xFB  ;; ref.i31
      call $addInstruction
      br $end
      
      end $case0x7C
      ;; returnTop - return top of stack
      local.get $builder
      call $generateReturn
      br $end
      
      end $case0x90
      ;; send literal selector 0 (squared) - message send
      local.get $builder
      i32.const 0    ;; literal index 0 (squared selector)
      i32.const 0    ;; arg count
      call $generateMessageSend
      br $end
      
      end $case0xB1
      ;; send * (multiply) - optimized SmallInteger multiplication
      local.get $builder
      call $generateOptimizedMultiply
      br $end
      
      end $case0xD0
      ;; send reportToJS - call JavaScript function
      local.get $builder
      call $generateReportToJS
      br $end
      
      ;; More bytecode cases...
      end $case255
      ;; Unknown bytecode - generate interpreter call
      local.get $builder
      local.get $bytecode
      call $generateInterpreterCall
    end
  )
  
  ;; Generate optimized SmallInteger multiplication for "3 squared"
  (func $generateOptimizedMultiply (param $builder (ref $FunctionBuilder))
    ;; Optimized path for SmallInteger * SmallInteger
    ;; Pop two values, check if both i31ref, multiply, push result
    
    ;; Generate type checks and fast path
    local.get $builder
    i32.const 0x20  ;; local.get (stack top)
    call $addInstruction
    
    local.get $builder  
    i32.const 0x20  ;; local.get (stack top-1)
    call $addInstruction
    
    ;; Check if both are i31ref
    local.get $builder
    call $generateI31RefCheck
    
    ;; Fast path: direct i31 multiplication
    local.get $builder
    i32.const 0x6C  ;; i32.mul
    call $addInstruction
    
    ;; Slow path: call message send
    local.get $builder
    call $generateMessageSend
  )
  
  ;; Generate call to reportToJS
  (func $generateReportToJS (param $builder (ref $FunctionBuilder))
    ;; Generate call to JavaScript reportResult function
    local.get $builder
    i32.const 0x10  ;; call
    call $addInstruction
    local.get $builder
    i32.const 1     ;; function index for system_report_result
    call $addInstruction
  )
  
  ;; Generate i31ref type check
  (func $generateI31RefCheck (param $builder (ref $FunctionBuilder))
    ;; Generate WASM code to check if value is i31ref
    local.get $builder
    i32.const 0xFB  ;; ref prefix
    call $addInstruction
    local.get $builder
    i32.const 0x05  ;; ref.test i31
    call $addInstruction
  )
  
  ;; Generate message send fallback
  (func $generateMessageSend (param $builder (ref $FunctionBuilder))
    ;; Generate call to interpreter message send
    local.get $builder
    i32.const 0x10  ;; call
    call $addInstruction
    local.get $builder
    i32.const 0     ;; function index for sendMessage
    call $addInstruction
  )
  
  ;; Build final WASM function from builder
  (func $buildFunction (param $builder (ref $FunctionBuilder)) (result (ref null func))
    ;; This would use WASM function instantiation
    ;; For now, return null (would be implemented with dynamic compilation)
    ref.null func
  )
  
  ;; Entry point for JIT compilation decision
  (func (export "checkAndCompileMethod") (param $method (ref $CompiledMethod)) (result (ref null func))
    (local $entry (ref null $JITEntry))
    (local $compiledFunc (ref null func))
    
    ;; Check if already compiled
    local.get $method
    call $findJITEntry
    local.tee $entry
    ref.is_null
    if
      ;; Not in cache - check if should compile
      local.get $method
      call $shouldCompileMethod
      if
        ;; Compile method
        local.get $method
        call $jitCompileMethod
        local.tee $compiledFunc
        ref.is_null
        br_if $compilation_failed
        
        ;; Add to cache
        local.get $method
        local.get $compiledFunc
        call $addToJITCache
        
        local.get $compiledFunc
        return
        
        block $compilation_failed
        ;; Compilation failed, use interpreter
        ref.null func
        return
      else
        ;; Not hot enough yet
        ref.null func
      end
    else
      ;; Found in cache
      local.get $entry
      ref.as_non_null
      struct.get $JITEntry $compiledFunc
    end
  )
  
  ;; Get JIT statistics
  (func (export "getJITStats") (result i32 i32 i32 i32)
    global.get $totalCompilations
    global.get $cacheHits  
    global.get $cacheMisses
    global.get $jitCache
    ref.as_non_null
    struct.get $JITCache $size
  )
  
  ;; Clear JIT cache (for debugging)
  (func (export "clearJITCache")
    global.get $jitCache
    ref.as_non_null
    i32.const 0
    struct.set $JITCache $size
  )
)
