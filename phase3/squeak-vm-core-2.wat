;; SqueakJS WASM VM Core with JIT Integration - Phase 3
;; Extends the bytecode interpreter with JIT compilation

(module $SqueakVMWithJIT
  ;; Import JavaScript interface functions
  (import "system" "reportResult" (func $system_report_result (param i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "consoleLog" (func $consoleLog (param i32)))
  
  ;; Import JIT compiler functions
  (import "jit" "checkAndCompileMethod" (func $checkAndCompileMethod 
    (param (ref $CompiledMethod)) (result (ref null func))))
  (import "jit" "getJITStats" (func $getJITStats (result i32 i32 i32 i32)))
  (import "jit" "clearJITCache" (func $clearJITCache))
  
  ;; Type definitions (unchanged from Phase 2)
  (rec
    (type $ObjectArray (array (mut (ref null eq))))
    (type $ByteArray (array (mut i8)))
    
    (type $SqueakObject (sub (struct 
      (field $class (mut (ref null $Class)))
      (field $identityHash (mut i32))
      (field $format (mut i32))
      (field $size (mut i32))
    )))
    
    (type $VariableObject (sub $SqueakObject (struct 
      (field $class (mut (ref null $Class)))
      (field $identityHash (mut i32))
      (field $format (mut i32))
      (field $size (mut i32))
      (field $slots (mut (ref null $ObjectArray)))
    )))
    
    (type $CompiledMethod (sub $VariableObject (struct
      (field $class (mut (ref null $Class)))
      (field $identityHash (mut i32))
      (field $format (mut i32))
      (field $size (mut i32))
      (field $slots (mut (ref null $ObjectArray)))
      (field $header i32)
      (field $bytecodes (ref null $ByteArray))
      (field $invocationCount (mut i32))        ;; For JIT hotness tracking
      (field $compiledWasm (mut (ref null func)))  ;; JIT compiled version
    )))
    
    (type $Context (sub $VariableObject (struct
      (field $class (mut (ref null $Class)))
      (field $identityHash (mut i32))
      (field $format (mut i32))
      (field $size (mut i32))
      (field $slots (mut (ref null $ObjectArray)))
      (field $sender (mut (ref null $Context)))
      (field $pc (mut i32))
      (field $sp (mut i32))
      (field $method (mut (ref null $CompiledMethod)))
      (field $receiver (mut (ref null eq)))
    )))
    
    (type $Class (sub $VariableObject (struct
      (field $class (mut (ref null $Class)))
      (field $identityHash (mut i32))
      (field $format (mut i32))
      (field $size (mut i32))
      (field $slots (mut (ref null $ObjectArray)))
      (field $superclass (mut (ref null $Class)))
      (field $methodDict (mut (ref null $VariableObject)))
      (field $instVarNames (mut (ref null $SqueakObject)))
      (field $name (mut (ref null $SqueakObject)))
      (field $instSize (mut i32))
    )))
  )
  
  ;; Global VM state
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  (global $methodReturned (mut i32) (i32.const 0))
  (global $lastIdentityHash (mut i32) (i32.const 1000))
  
  ;; Class globals
  (global $objectClass (mut (ref null $Class)) (ref.null $Class))
  (global $contextClass (mut (ref null $Class)) (ref.null $Class))
  (global $methodClass (mut (ref null $Class)) (ref.null $Class))
  (global $smallIntegerClass (mut (ref null $Class)) (ref.null $Class))
  
  ;; JIT performance counters
  (global $interpreterCalls (mut i32) (i32.const 0))
  (global $jitCalls (mut i32) (i32.const 0))
  (global $methodInvocations (mut i32) (i32.const 0))
  
  ;; Enhanced method invocation with JIT compilation
  (func $invokeMethod (param $method (ref $CompiledMethod)) (param $receiver (ref null eq))
    (local $compiledFunc (ref null func))
    (local $newContext (ref $Context))
    
    ;; Increment global method invocation counter
    global.get $methodInvocations
    i32.const 1
    i32.add
    global.set $methodInvocations
    
    ;; Increment method-specific invocation counter
    local.get $method
    local.get $method
    struct.get $CompiledMethod $invocationCount
    i32.const 1
    i32.add
    struct.set $CompiledMethod $invocationCount
    
    ;; Check if method has cached JIT compilation
    local.get $method
    struct.get $CompiledMethod $compiledWasm
    local.tee $compiledFunc
    ref.is_null
    if
      ;; No cached compilation - check if should JIT compile
      local.get $method
      call $checkAndCompileMethod
      local.tee $compiledFunc
      ref.is_null
      br_if $use_interpreter
      
      ;; Cache the compiled function
      local.get $method
      local.get $compiledFunc
      struct.set $CompiledMethod $compiledWasm
    end
    
    ;; Use JIT compiled version
    global.get $jitCalls
    i32.const 1
    i32.add
    global.set $jitCalls
    
    ;; Create context for JIT execution
    call $createMethodContext
    local.get $method
    local.get $receiver
    call $setupMethodContext
    local.set $newContext
    
    ;; Call JIT compiled function
    local.get $compiledFunc
    local.get $newContext
    call_ref $Context
    return
    
    block $use_interpreter
    ;; Fall back to interpreter
    global.get $interpreterCalls
    i32.const 1
    i32.add
    global.set $interpreterCalls
    
    ;; Create context and execute via interpreter
    call $createMethodContext
    local.get $method
    local.get $receiver
    call $setupMethodContext
    global.set $activeContext
    
    ;; Execute using bytecode interpreter
    call $interpretMethod
  )
  
  ;; Enhanced bytecode interpreter with hotness tracking
  (func $interpretMethod
    (local $bytecode i32)
    (local $pc i32)
    (local $method (ref null $CompiledMethod))
    (local $bytecodes (ref null $ByteArray))
    (local $context (ref null $Context))
    (local $hotness i32)
    
    global.get $activeContext
    local.set $context
    
    block $exit_loop
    loop $interpreter_loop
      global.get $methodReturned
      i32.const 1
      i32.eq
      br_if $exit_loop
      
      ;; Get current method and check for JIT opportunities
      local.get $context
      struct.get $Context $method
      local.tee $method
      ref.is_null
      br_if $exit_loop
      
      ;; Check method hotness every 10 bytecodes
      local.get $context
      struct.get $Context $pc
      i32.const 10
      i32.rem_u
      i32.eqz
      if
        ;; Check if method became hot enough for JIT
        local.get $method
        ref.as_non_null
        struct.get $CompiledMethod $invocationCount
        local.set $hotness
        
        local.get $hotness
        i32.const 100  ;; JIT threshold
        i32.ge_u
        if
          ;; Method is hot - attempt JIT compilation
          local.get $method
          ref.as_non_null
          call $checkAndCompileMethod
          local.get $method
          ref.as_non_null
          swap
          struct.set $CompiledMethod $compiledWasm
        end
      end
      
      local.get $context
      struct.get $Context $pc
      local.set $pc
      
      local.get $method
      ref.as_non_null
      struct.get $CompiledMethod $bytecodes
      local.set $bytecodes
      
      ;; Check PC bounds
      local.get $pc
      local.get $bytecodes
      array.len
      i32.ge_u
      br_if $exit_loop
      
      ;; Fetch and execute bytecode
      local.get $bytecodes
      local.get $pc
      array.get_u $ByteArray
      local.set $bytecode
      
      local.get $bytecode
      call $executeBytecode
      
      ;; Increment PC
      local.get $context
      local.get $pc
      i32.const 1
      i32.add
      struct.set $Context $pc
      
      global.get $activeContext
      local.set $context
      
      br $interpreter_loop
    end
    end
  )
  
  ;; Create method context for JIT execution
  (func $createMethodContext (result (ref $Context))
    (local $newContext (ref $Context))
    (local $contextSlots (ref $ObjectArray))
    
    ;; Create context slots array (32 slots for stack + temps)
    i32.const 32
    ref.null eq
    array.new $ObjectArray
    local.set $contextSlots
    
    ;; Create context object
    global.get $contextClass
    call $nextIdentityHash
    i32.const 3  ;; MethodContext format
    i32.const 32 ;; size
    local.get $contextSlots
    global.get $activeContext  ;; sender
    i32.const 0  ;; pc
    i32.const 6  ;; sp (after receiver + args + temps)
    ref.null $CompiledMethod  ;; method (set later)
    ref.null eq  ;; receiver (set later)
    struct.new $Context
    local.set $newContext
    
    local.get $newContext
  )
  
  ;; Setup context for method execution
  (func $setupMethodContext 
    (param $context (ref $Context))
    (param $method (ref $CompiledMethod)) 
    (param $receiver (ref null eq))
    (result (ref $Context))
    
    ;; Set method and receiver
    local.get $context
    local.get $method
    struct.set $Context $method
    
    local.get $context
    local.get $receiver
    struct.set $Context $receiver
    
    ;; Initialize stack with receiver
    local.get $context
    struct.get $Context $slots
    i32.const 6  ;; receiver slot
    local.get $receiver
    array.set $ObjectArray
    
    local.get $context
  )
  
  ;; Enhanced bytecode execution with performance monitoring
  (func $executeBytecode (param $bytecode i32)
    (local $value (ref null eq))
    (local $context (ref $Context))
    (local $receiver (ref null eq))
    (local $arg1 (ref null eq))
    (local $arg2 (ref null eq))
    
    global.get $activeContext
    ref.as_non_null
    local.set $context
    
    local.get $bytecode
    
    block $end
      block $case255
      block $case176  ;; send + (optimized)
      block $case120  ;; returnTop
      block $case118  ;; pushConstant 4
      block $case117  ;; pushConstant 3
      block $case16   ;; pushInstVar 0
      block $case0    ;; pushReceiver
        br_table $case0 ... $case16 $case117 $case118 $case120 $case176 ... $case255 $end
      end $case0
      ;; pushReceiver
      local.get $context
      struct.get $Context $receiver
      call $push
      br $end
      
      end $case16
      ;; pushInstVar 0
      local.get $context
      struct.get $Context $receiver
      i32.const 0
      call $getInstanceVariable
      call $push
      br $end
      
      end $case117
      ;; pushConstant 3 - create i31ref for immediate integer
      i32.const 3
      call $makeSmallInteger
      call $push
      br $end
      
      end $case118
      ;; pushConstant 4 - create i31ref for immediate integer
      i32.const 4
      call $makeSmallInteger
      call $push
      br $end
      
      end $case120
      ;; returnTop
      call $pop
      call $methodReturn
      br $end
      
      end $case176
      ;; send + (with fast path optimization)
      call $optimizedIntegerAdd
      br $end
      
      end $case255
      ;; Extended bytecodes or unknown
      local.get $bytecode
      call $handleExtendedBytecode
    end
  )
  
  ;; Optimized integer addition with JIT-style fast path
  (func $optimizedIntegerAdd
    (local $receiver (ref null eq))
    (local $argument (ref null eq))
    (local $result i32)
    
    ;; Pop argument and receiver
    call $pop
    local.set $argument
    call $pop 
    local.set $receiver
    
    ;; Fast path: both SmallIntegers
    local.get $receiver
    ref.test i31
    local.get $argument
    ref.test i31
    i32.and
    if
      ;; Both are i31ref SmallIntegers - do fast addition
      local.get $receiver
      ref.cast i31
      i31.get_s
      
      local.get $argument
      ref.cast i31
      i31.get_s
      
      i32.add
      
      ;; Check for overflow (simplified)
      local.tee $result
      i32.const -1073741824  ;; SmallInteger min
      i32.ge_s
      local.get $result
      i32.const 1073741823   ;; SmallInteger max
      i32.le_s
      i32.and
      if
        ;; No overflow - create result SmallInteger
        local.get $result
        call $makeSmallInteger
        call $push
        return
      end
    end
    
    ;; Slow path: use message send
    local.get $receiver
    call $push
    local.get $argument
    call $push
    
    ;; Send + message
    call $getPlusSelector
    i32.const 1  ;; arg count
    call $sendMessage
  )
  
  ;; Create SmallInteger from i32 value
  (func $makeSmallInteger (param $value i32) (result (ref eq))
    local.get $value
    ref.i31
  )
  
  ;; Get + selector for message sending
  (func $getPlusSelector (result (ref null eq))
    ;; Return cached + symbol
    ;; For now, create a simple marker
    i32.const 999  ;; Special marker for +
    ref.i31
  )
  
  ;; Message sending (fallback for non-optimized cases)
  (func $sendMessage (param $selector (ref null eq)) (param $argCount i32)
    (local $receiver (ref null eq))
    (local $method (ref null $CompiledMethod))
    
    ;; Get receiver (it's at stackValue(argCount))
    local.get $argCount
    call $stackValue
    local.set $receiver
    
    ;; Look up method
    local.get $receiver
    local.get $selector
    call $lookupMethod
    local.set $method
    
    local.get $method
    ref.is_null
    if
      ;; Method not found - handle doesNotUnderstand
      call $handleDoesNotUnderstand
      return
    end
    
    ;; Invoke method (may trigger JIT compilation)
    local.get $method
    ref.as_non_null
    local.get $receiver
    call $invokeMethod
  )
  
  ;; Method lookup in class hierarchy
  (func $lookupMethod 
    (param $receiver (ref null eq)) 
    (param $selector (ref null eq)) 
    (result (ref null $CompiledMethod))
    
    ;; Simplified method lookup
    ;; In a real implementation, this would search the method dictionary
    
    ;; For + selector on SmallIntegers, return a stub
    local.get $selector
    ref.test i31
    if
      local.get $selector
      ref.cast i31
      i31.get_s
      i32.const 999  ;; + selector marker
      i32.eq
      if
        ;; Return addition method
        call $createAdditionMethod
        return
      end
    end
    
    ref.null $CompiledMethod
  )
  
  ;; Create addition method for JIT testing
  (func $createAdditionMethod (result (ref $CompiledMethod))
    (local $bytecodes (ref $ByteArray))
    (local $literals (ref $ObjectArray))
    
    ;; Create bytecode sequence for simple addition
    ;; [pushInstVar 0, pushInstVar 1, primitive 1, returnTop]
    i32.const 4
    i32.const 0
    array.new i8
    local.tee $bytecodes
    i32.const 0
    i32.const 16  ;; pushInstVar 0
    array.set i8
    
    local.get $bytecodes
    i32.const 1
    i32.const 17  ;; pushInstVar 1
    array.set i8
    
    local.get $bytecodes
    i32.const 2
    i32.const 139 ;; primitive 1 (addition)
    array.set i8
    
    local.get $bytecodes
    i32.const 3
    i32.const 120 ;; returnTop
    array.set i8
    
    ;; Create empty literals array
    i32.const 1
    ref.null eq
    array.new $ObjectArray
    local.set $literals
    
    ;; Create method object
    global.get $methodClass
    call $nextIdentityHash
    i32.const 12  ;; CompiledMethod format
    i32.const 8   ;; size
    local.get $literals
    i32.const 0x20001  ;; header: primitive 1, 1 arg, 0 temps
    local.get $bytecodes
    i32.const 0    ;; invocation count
    ref.null func  ;; no compiled WASM yet
    struct.new $CompiledMethod
  )
  
  ;; Stack operations (unchanged from Phase 2)
  (func $push (param $value (ref null eq))
    global.get $activeContext
    struct.get $Context $slots
    global.get $activeContext
    struct.get $Context $sp
    local.get $value
    array.set $ObjectArray
    
    global.get $activeContext
    global.get $activeContext
    struct.get $Context $sp
    i32.const 1
    i32.add
    struct.set $Context $sp
  )
  
  (func $pop (result (ref null eq))
    global.get $activeContext
    global.get $activeContext
    struct.get $Context $sp
    i32.const 1
    i32.sub
    struct.set $Context $sp
    
    global.get $activeContext
    struct.get $Context $slots
    global.get $activeContext
    struct.get $Context $sp
    array.get $ObjectArray
  )
  
  (func $stackValue (param $offset i32) (result (ref null eq))
    global.get $activeContext
    struct.get $Context $slots
    global.get $activeContext
    struct.get $Context $sp
    i32.const 1
    i32.sub
    local.get $offset
    i32.sub
    array.get $ObjectArray
  )
  
  ;; Identity hash generation
  (func $nextIdentityHash (result i32)
    global.get $lastIdentityHash
    i32.const 1
    i32.add
    global.set $lastIdentityHash
    global.get $lastIdentityHash
  )
  
  ;; Method return handling
  (func $methodReturn (param $value (ref null eq))
    (local $sender (ref null $Context))
    
    ;; Get sender context
    global.get $activeContext
    struct.get $Context $sender
    local.set $sender
    
    local.get $sender
    ref.is_null
    if
      ;; No sender - report result and exit
      local.get $value
      ref.test i31
      if
        local.get $value
        ref.cast i31
        i31.get_s
        call $system_report_result
      end
      
      i32.const 1
      global.set $methodReturned
      return
    end
    
    ;; Switch to sender context
    local.get $sender
    ref.as_non_null
    global.set $activeContext
    
    ;; Push return value
    local.get $value
    call $push
  )
  
  ;; Bootstrap functions
  (func $createBasicClasses
    (local $objectClass (ref $Class))
    (local $contextClass (ref $Class))
    (local $methodClass (ref $Class))
    (local $smallIntClass (ref $Class))
    
    ;; Create minimal class hierarchy
    call $createObjectClass
    local.set $objectClass
    local.get $objectClass
    global.set $objectClass
    
    local.get $objectClass
    call $createContextClass
    local.set $contextClass
    local.get $contextClass
    global.set $contextClass
    
    local.get $objectClass
    call $createMethodClass
    local.set $methodClass
    local.get $methodClass
    global.set $methodClass
    
    local.get $objectClass
    call $createSmallIntegerClass
    local.set $smallIntClass
    local.get $smallIntClass
    global.set $smallIntegerClass
  )
  
  ;; Create Object class
  (func $createObjectClass (result (ref $Class))
    (local $slots (ref $ObjectArray))
    
    i32.const 10
    ref.null eq
    array.new $ObjectArray
    local.set $slots
    
    ref.null $Class  ;; class (will be set to metaclass later)
    call $nextIdentityHash
    i32.const 1      ;; format
    i32.const 10     ;; size
    local.get $slots
    ref.null $Class  ;; superclass
    ref.null $VariableObject  ;; methodDict
    ref.null $SqueakObject    ;; instVarNames
    ref.null $SqueakObject    ;; name
    i32.const 0      ;; instSize
    struct.new $Class
  )
  
  ;; Create Context class
  (func $createContextClass (param $superclass (ref $Class)) (result (ref $Class))
    (local $slots (ref $ObjectArray))
    
    i32.const 10
    ref.null eq
    array.new $ObjectArray
    local.set $slots
    
    local.get $superclass
    call $nextIdentityHash
    i32.const 1
    i32.const 10
    local.get $slots
    local.get $superclass
    ref.null $VariableObject
    ref.null $SqueakObject
    ref.null $SqueakObject
    i32.const 9      ;; 9 instance variables for Context
    struct.new $Class
  )
  
  ;; Create CompiledMethod class
  (func $createMethodClass (param $superclass (ref $Class)) (result (ref $Class))
    (local $slots (ref $ObjectArray))
    
    i32.const 10
    ref.null eq
    array.new $ObjectArray
    local.set $slots
    
    local.get $superclass
    call $nextIdentityHash
    i32.const 12     ;; CompiledMethod format
    i32.const 10
    local.get $slots
    local.get $superclass
    ref.null $VariableObject
    ref.null $SqueakObject
    ref.null $SqueakObject
    i32.const 4      ;; 4 instance variables for CompiledMethod
    struct.new $Class
  )
  
  ;; Create SmallInteger class
  (func $createSmallIntegerClass (param $superclass (ref $Class)) (result (ref $Class))
    (local $slots (ref $ObjectArray))
    
    i32.const 10
    ref.null eq
    array.new $ObjectArray
    local.set $slots
    
    local.get $superclass
    call $nextIdentityHash
    i32.const 7      ;; immediate object format
    i32.const 10
    local.get $slots
    local.get $superclass
    ref.null $VariableObject
    ref.null $SqueakObject
    ref.null $SqueakObject
    i32.const 0      ;; no instance variables
    struct.new $Class
  )
  
  ;; Create minimal bootstrap (3 + 4 example)
  (func (export "createMinimalBootstrap") (result i32)
    (local $method (ref $CompiledMethod))
    (local $context (ref $Context))
    
    ;; Initialize classes
    call $createBasicClasses
    
    ;; Create test method
    call $createAdditionMethod
    local.set $method
    
    ;; Create initial context
    call $createMethodContext
    local.get $method
    ref.null eq  ;; nil receiver for DoIt
    call $setupMethodContext
    global.set $activeContext
    
    ;; Push constants 3 and 4 onto stack
    i32.const 3
    call $makeSmallInteger
    call $push
    
    i32.const 4
    call $makeSmallInteger
    call $push
    
    i32.const 1  ;; success
  )
  
  ;; Main interpreter loop (export for JavaScript)
  (func (export "interpret")
    call $interpretMethod
  )
  
  ;; Get performance statistics
  (func (export "getPerformanceStats") (result i32 i32 i32 i32 i32 i32 i32)
    global.get $methodInvocations
    global.get $interpreterCalls
    global.get $jitCalls
    
    ;; Get JIT compiler stats
    call $getJITStats  ;; returns: compilations, hits, misses, cache_size
  )
  
  ;; Reset performance counters
  (func (export "resetPerformanceStats")
    i32.const 0
    global.set $methodInvocations
    i32.const 0
    global.set $interpreterCalls
    i32.const 0
    global.set $jitCalls
    
    call $clearJITCache
  )
  
  ;; Utility functions
  (func $getInstanceVariable (param $object (ref null eq)) (param $index i32) (result (ref null eq))
    local.get $object
    ref.test (ref $VariableObject)
    if (result (ref null eq))
      local.get $object
      ref.cast (ref $VariableObject)
      struct.get $VariableObject $slots
      local.get $index
      array.get $ObjectArray
    else
      ref.null eq
    end
  )
  
  (func $handleExtendedBytecode (param $bytecode i32)
    ;; Handle extended bytecode set (Sista, etc.)
    ;; For now, just ignore unknown bytecodes
    nop
  )
  
  (func $handleDoesNotUnderstand
    ;; Handle message not understood
    ;; For now, just return nil
    ref.null eq
    call $push
  )
)
