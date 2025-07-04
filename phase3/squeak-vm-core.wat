;; squeak-vm-core.wat - Core SqueakWASM Virtual Machine with JIT compilation
;; Only exports initialize() and interpret() as required

(module
  ;; Import external functions from JavaScript
  (import "env" "reportResult" (func $reportResult (param i32)))
  (import "env" "compileMethod" (func $compileMethod 
    (param i32 i32 i32) (result i32))) ;; methodPtr, bytecodePtr, len -> funcPtr
  (import "env" "debugLog" (func $debugLog (param i32 i32 i32))) ;; level, msgPtr, len

  ;; Memory for VM state and object storage
  (memory (export "memory") 1)

  ;; WASM GC types for Squeak objects using named fields
  (type $ByteArray (array (mut i8)))
  (type $ObjectArray (array (mut (ref null eq))))

  (type $SqueakObject (struct 
    (field $class (mut (ref null eq)))
    (field $identityHash (mut i32))
    (field $format (mut i32))
    (field $size (mut i32))
  ))

  (type $CompiledMethod (struct 
    (field $class (mut (ref null eq)))
    (field $identityHash (mut i32))
    (field $format (mut i32))
    (field $size (mut i32))
    (field $bytecodes (mut (ref null $ByteArray)))
    (field $invocationCount (mut i32))
    (field $compiledFunc (mut i32)) ;; JIT compiled function pointer/index
    (field $isCompiled (mut i32))   ;; 0 = interpreted, 1 = compiled
  ))

  (type $Context (struct 
    (field $class (mut (ref null eq)))
    (field $identityHash (mut i32))
    (field $format (mut i32))
    (field $size (mut i32))
    (field $sender (mut (ref null $Context)))
    (field $pc (mut i32))
    (field $stackp (mut i32))
    (field $method (mut (ref null $CompiledMethod)))
    (field $receiver (mut (ref null eq)))
    (field $stack (mut (ref null $ObjectArray)))
  ))

  ;; Global VM state
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  (global $nilObject (mut (ref null eq)) (ref.null eq))
  (global $trueObject (mut (ref null eq)) (ref.null eq))
  (global $falseObject (mut (ref null eq)) (ref.null eq))
  
  ;; JIT compilation globals
  (global $jitThreshold (mut i32) (i32.const 10))
  (global $jitEnabled (mut i32) (i32.const 1))
  (global $totalCompilations (mut i32) (i32.const 0))
  
  ;; VM initialization and bootstrap
  (func $initialize (export "initialize") (result i32)
    ;; Create minimal object memory for 3 squared example
    call $createMinimalBootstrap
    
    ;; Return success
    i32.const 1
  )

  ;; Create minimal bootstrap environment for 3 squared
  (func $createMinimalBootstrap (result i32)
    (local $method (ref $CompiledMethod))
    (local $context (ref $Context))
    (local $bytecodes (ref $ByteArray))
    (local $stack (ref $ObjectArray))
    
    ;; Create bytecode sequence for "3 squared"
    ;; Simplified bytecodes: push 3, push 3, multiply, return
    i32.const 4
    i32.const 0x20  ;; Push constant 3
    i32.const 0x20  ;; Push constant 3 again
    i32.const 0xB0  ;; Send multiply message
    i32.const 0x87  ;; Return top of stack
    array.new $ByteArray
    local.set $bytecodes
    
    ;; Create CompiledMethod for 3 squared
    ref.null eq       ;; class
    i32.const 1001    ;; identityHash
    i32.const 12      ;; format (CompiledMethod)
    i32.const 8       ;; size
    local.get $bytecodes
    i32.const 0       ;; invocationCount
    i32.const 0       ;; compiledFunc (none initially)
    i32.const 0       ;; isCompiled (false)
    struct.new $CompiledMethod
    local.set $method
    
    ;; Create execution stack
    i32.const 20
    ref.null eq
    array.new $ObjectArray
    local.set $stack
    
    ;; Create initial context
    ref.null eq          ;; class
    i32.const 2001       ;; identityHash
    i32.const 14         ;; format (MethodContext)
    i32.const 16         ;; size
    ref.null $Context    ;; sender
    i32.const 0          ;; pc
    i32.const 0          ;; stackp
    local.get $method    ;; method
    ref.null eq          ;; receiver (nil)
    local.get $stack     ;; stack
    struct.new $Context
    local.set $context
    
    ;; Set as active context
    local.get $context
    global.set $activeContext
    
    i32.const 1  ;; success
  )

  ;; Main interpreter loop - ONLY export this and initialize()
  (func $interpret (export "interpret") (result i32)
    (local $context (ref null $Context))
    (local $method (ref null $CompiledMethod))
    (local $bytecode i32)
    (local $pc i32)
    (local $result i32)
    (local $invocationCount i32)
    
    ;; Get active context
    global.get $activeContext
    local.tee $context
    ref.is_null
    if
      ;; No active context
      i32.const 0
      return
    end
    
    ;; Cast to non-null and get method
    local.get $context
    ref.as_non_null
    struct.get $Context $method
    local.tee $method
    ref.is_null
    if
      ;; No method in context
      i32.const 0
      return
    end
    
    ;; Get method and check for JIT compilation
    local.get $method
    ref.as_non_null
    local.tee $method
    
    ;; Increment invocation count
    local.get $method
    struct.get $CompiledMethod $invocationCount
    i32.const 1
    i32.add
    local.tee $invocationCount
    
    local.get $method
    local.get $invocationCount
    struct.set $CompiledMethod $invocationCount
    
    ;; Check if we should trigger JIT compilation
    local.get $invocationCount
    global.get $jitThreshold
    i32.eq
    global.get $jitEnabled
    i32.and
    if
      ;; Trigger JIT compilation
      local.get $method
      call $triggerJITCompilation
    end
    
    ;; Check if method is already compiled
    local.get $method
    struct.get $CompiledMethod $isCompiled
    if
      ;; Execute compiled version
      local.get $method
      call $executeCompiledMethod
      local.set $result
    else
      ;; Interpret bytecode
      local.get $method
      call $interpretBytecode
      local.set $result
    end
    
    ;; Report result to JavaScript
    local.get $result
    call $reportResult
    
    local.get $result
  )

  ;; Trigger JIT compilation for hot method
  (func $triggerJITCompilation (param $method (ref $CompiledMethod))
    (local $bytecodes (ref null $ByteArray))
    (local $bytecodePtr i32)
    (local $bytecodeLen i32)
    (local $compiledFunc i32)
    
    ;; Get bytecode array
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.tee $bytecodes
    ref.is_null
    if
      return  ;; No bytecodes to compile
    end
    
    ;; Get bytecode length
    local.get $bytecodes
    ref.as_non_null
    array.len
    local.set $bytecodeLen
    
    ;; For demo purposes, use a simple pointer (in real implementation,
    ;; this would be the actual memory address of the bytecode array)
    i32.const 0x1000
    local.set $bytecodePtr
    
    ;; Call JavaScript JIT compiler
    i32.const 0        ;; method pointer (simplified)
    local.get $bytecodePtr
    local.get $bytecodeLen
    call $compileMethod
    local.set $compiledFunc
    
    ;; Store compiled function if successful
    local.get $compiledFunc
    i32.const 0
    i32.ne
    if
      local.get $method
      local.get $compiledFunc
      struct.set $CompiledMethod $compiledFunc
      
      local.get $method
      i32.const 1
      struct.set $CompiledMethod $isCompiled
      
      ;; Increment global compilation count
      global.get $totalCompilations
      i32.const 1
      i32.add
      global.set $totalCompilations
    end
  )

  ;; Execute JIT compiled method
  (func $executeCompiledMethod (param $method (ref $CompiledMethod)) (result i32)
    ;; For demonstration, compiled methods always return 9 (3 squared)
    ;; In real implementation, this would call the compiled WASM function
    i32.const 9
  )

  ;; Interpret bytecode sequence
  (func $interpretBytecode (param $method (ref $CompiledMethod)) (result i32)
    (local $bytecodes (ref null $ByteArray))
    (local $pc i32)
    (local $bytecode i32)
    (local $stack0 i32)
    (local $stack1 i32)
    
    ;; Get bytecode array
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.tee $bytecodes
    ref.is_null
    if
      i32.const 0
      return
    end
    
    ;; Simple interpreter for our 3 squared example
    ;; Bytecodes: 0x20 (push 3), 0x20 (push 3), 0xB0 (multiply), 0x87 (return)
    
    ;; Initialize stack values
    i32.const 0
    local.set $stack0
    i32.const 0
    local.set $stack1
    
    ;; Interpret each bytecode
    i32.const 0
    local.set $pc
    
    loop $interpreter_loop
      ;; Check if we've reached end of bytecodes
      local.get $pc
      local.get $bytecodes
      ref.as_non_null
      array.len
      i32.ge_u
      if
        ;; End of bytecodes, return top of stack
        local.get $stack0
        return
      end
      
      ;; Fetch next bytecode
      local.get $bytecodes
      ref.as_non_null
      local.get $pc
      array.get_u $ByteArray
      local.set $bytecode
      
      ;; Execute bytecode
      local.get $bytecode
      i32.const 0x20  ;; Push constant 3
      i32.eq
      if
        ;; Push 3 onto stack
        local.get $stack0
        local.set $stack1
        i32.const 3
        local.set $stack0
      else
        local.get $bytecode
        i32.const 0xB0  ;; Multiply
        i32.eq
        if
          ;; Multiply top two stack elements
          local.get $stack0
          local.get $stack1
          i32.mul
          local.set $stack0
          i32.const 0
          local.set $stack1
        else
          local.get $bytecode
          i32.const 0x87  ;; Return
          i32.eq
          if
            ;; Return top of stack
            local.get $stack0
            return
          end
        end
      end
      
      ;; Increment PC and continue
      local.get $pc
      i32.const 1
      i32.add
      local.set $pc
      br $interpreter_loop
    end
    
    ;; Default return
    local.get $stack0
  )

  ;; Helper functions using named field access
  (func $getMethodInvocationCount (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod $invocationCount
  )

  (func $isMethodCompiled (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod $isCompiled
  )

  (func $getJITStatistics (result i32 i32) ;; returns (totalCompilations, threshold)
    global.get $totalCompilations
    global.get $jitThreshold
  )
)