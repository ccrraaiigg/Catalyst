;; SqueakJS to WASM VM Core Module - Phase 3: JIT Compilation Support
;; FIXED VERSION - Fixed struct.set calls in register_object function

(module $SqueakVMCore
  ;; Import JavaScript interface functions
  (import "system" "reportResult" (func $system_report_result (param i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "consoleLog" (func $consoleLog (param i32)))
  
  ;; Import JIT compilation interface
  (import "jit" "compileMethod" (func $jit_compile_method_js 
    (param i32 i32 i32 i32) (result i32)))
  (import "jit" "reportError" (func $js_report_error (param i32)))
  
  ;; FIXED: Use proper recursive type group with named fields
  (rec
   ;; Type 0: ObjectArray - can hold both objects and i31ref SmallIntegers
   (type $ObjectArray (array (mut (ref null eq))))
   
   ;; Type 1: ByteArray 
   (type $ByteArray (array (mut i8)))
   
   ;; Type 2: Base Squeak object - now properly recursive with named fields
   (type $SqueakObject (sub (struct 
             (field $class (mut (ref null $Class)))
             (field $identityHash (mut i32))
             (field $format (mut i32))
             (field $size (mut i32))
             (field $nextObject (mut (ref null $SqueakObject)))
             )))
   
   ;; Type 3: Variable objects with named fields
   (type $VariableObject (sub $SqueakObject (struct
                     (field $class (mut (ref null $Class)))
                     (field $identityHash (mut i32))
                     (field $format (mut i32))
                     (field $size (mut i32))
                     (field $nextObject (mut (ref null $SqueakObject)))
                     (field $slots (mut (ref null $ObjectArray)))
                     )))
   
   ;; Type 4: Symbol objects for method selectors with named fields
   (type $Symbol (sub $VariableObject (struct
                   (field $class (mut (ref null $Class)))
                   (field $identityHash (mut i32))
                   (field $format (mut i32))
                   (field $size (mut i32))
                   (field $nextObject (mut (ref null $SqueakObject)))
                   (field $slots (mut (ref null $ObjectArray)))
                   (field $bytes (ref null $ByteArray))
                   )))
   
   ;; Type 5: Class objects with named fields
   (type $Class (sub $VariableObject (struct
                      (field $class (mut (ref null $Class)))
                      (field $identityHash (mut i32))
                      (field $format (mut i32))
                      (field $size (mut i32))
                      (field $nextObject (mut (ref null $SqueakObject)))
                      (field $slots (mut (ref null $ObjectArray)))
                      (field $superclass (mut (ref null $Class)))
                      (field $methodDict (mut (ref null $Dictionary)))
                      (field $instVarNames (mut (ref null $SqueakObject)))
                      (field $name (mut (ref null $Symbol)))
                      (field $instSize (mut i32))
                      )))
   
   ;; Type 6: Dictionary for method lookup with named fields
   (type $Dictionary (sub $VariableObject (struct
                       (field $class (mut (ref null $Class)))
                       (field $identityHash (mut i32))
                       (field $format (mut i32))
                       (field $size (mut i32))
                       (field $nextObject (mut (ref null $SqueakObject)))
                       (field $slots (mut (ref null $ObjectArray)))
                       (field $keys (ref null $ObjectArray))
                       (field $values (ref null $ObjectArray))
                       (field $count (mut i32))
                       )))
   
   ;; Type 7: CompiledMethod with JIT compilation support and named fields
   (type $CompiledMethod (sub $VariableObject (struct
                           (field $class (mut (ref null $Class)))
                           (field $identityHash (mut i32))
                           (field $format (mut i32))
                           (field $size (mut i32))
                           (field $nextObject (mut (ref null $SqueakObject)))
                           (field $slots (mut (ref null $ObjectArray)))
                           (field $header i32)
                           (field $bytecodes (ref null $ByteArray))
                           (field $invocationCount (mut i32))
                           (field $compiledWasm (mut (ref null func)))
                           (field $jitThreshold i32)
                           )))
   
   ;; Type 8: Context objects for execution state with named fields
   (type $Context (sub $VariableObject (struct
                        (field $class (mut (ref null $Class)))
                        (field $identityHash (mut i32))
                        (field $format (mut i32))
                        (field $size (mut i32))
                        (field $nextObject (mut (ref null $SqueakObject)))
                        (field $slots (mut (ref null $ObjectArray)))
                        (field $sender (mut (ref null $Context)))
                        (field $pc (mut i32))
                        (field $sp (mut i32))
                        (field $method (mut (ref null $CompiledMethod)))
                        (field $receiver (mut (ref null eq)))
                        (field $args (mut (ref null $ObjectArray)))
                        (field $temps (mut (ref null $ObjectArray)))
                        (field $stack (mut (ref null $ObjectArray)))
                        )))
   )

  ;; Global VM state
  (global $objectClass (mut (ref null $Class)) (ref.null $Class))
  (global $classClass (mut (ref null $Class)) (ref.null $Class))
  (global $methodClass (mut (ref null $Class)) (ref.null $Class))
  (global $contextClass (mut (ref null $Class)) (ref.null $Class))
  (global $symbolClass (mut (ref null $Class)) (ref.null $Class))
  (global $smallIntegerClass (mut (ref null $Class)) (ref.null $Class))
  
  ;; Essential objects
  (global $nilObject (mut (ref null eq)) (ref.null eq))
  (global $trueObject (mut (ref null eq)) (ref.null eq))
  (global $falseObject (mut (ref null eq)) (ref.null eq))
  
  ;; Special selectors for quick sends
  (global $plusSelector (mut (ref null eq)) (ref.null eq))
  (global $timesSelector (mut (ref null eq)) (ref.null eq))
  (global $squaredSelector (mut (ref null eq)) (ref.null eq))
  (global $reportToJSSelector (mut (ref null eq)) (ref.null eq))
  
  ;; VM execution state
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  (global $currentMethod (mut (ref null $CompiledMethod)) (ref.null $CompiledMethod))
  (global $currentReceiver (mut (ref null eq)) (ref.null eq))
  
  ;; Object memory management
  (global $nextIdentityHash (mut i32) (i32.const 1000))
  (global $firstObject (mut (ref null $SqueakObject)) (ref.null $SqueakObject))
  (global $lastObject (mut (ref null $SqueakObject)) (ref.null $SqueakObject))
  (global $objectCount (mut i32) (i32.const 0))
  
  ;; WASM exception types for VM control flow
  (tag $Return (param (ref null eq)))
  (tag $PrimitiveFailed)
  (tag $DoesNotUnderstand (param (ref null eq)) (param (ref null $ObjectArray)))
  
  ;; Array operations with proper typing
  (func $array_len_byte
    (param $array (ref $ByteArray))
    (result i32)
    local.get $array
    array.len
  )
  
  (func $array_get_byte
    (param $array (ref $ByteArray))
    (param $index i32)
    (result i32)
    local.get $array
    local.get $index
    array.get_u $ByteArray
  )
  
  (func $array_len_object
    (param $array (ref $ObjectArray))
    (result i32)
    local.get $array
    array.len
  )
  
  (func $array_get_object
    (param $array (ref $ObjectArray))
    (param $index i32)
    (result (ref null eq))
    local.get $array
    local.get $index
    array.get $ObjectArray
  )
  
  (func $is_small_integer
    (param $obj (ref null eq))
    (result i32)
    local.get $obj
    ref.test (ref i31)
  )
  
  (func $get_small_integer_value
    (param $obj (ref null eq))
    (result i32)
    local.get $obj
    ref.cast (ref i31)
    i31.get_s
  )
  
  ;; Memory management
  (func $nextIdentityHash (result i32)
    global.get $nextIdentityHash
    i32.const 1
    i32.add
    global.set $nextIdentityHash
    global.get $nextIdentityHash
  )
  
  ;; FIXED: Object enumeration for #become: support - proper struct.set handling
  (func $register_object
    (param $object (ref $SqueakObject))
    (local $lastObj (ref null $SqueakObject))
    
    ;; Link object into enumeration chain
    global.get $lastObject
    local.tee $lastObj
    ref.is_null
    if
      ;; First object
      local.get $object
      global.set $firstObject
    else
      ;; Link to previous last object - FIXED: handle nullable reference
      local.get $lastObj
      ref.as_non_null
      local.get $object
      struct.set $SqueakObject $nextObject
    end
    
    ;; Update last object pointer
    local.get $object
    global.set $lastObject
    
    ;; Increment object count
    global.get $objectCount
    i32.const 1
    i32.add
    global.set $objectCount
  )
  
  ;; Bytecode interpretation functions
  (func $pushSmallInteger
    (param $value i32)
    ;; Convert to i31ref and push on stack
    local.get $value
    ref.i31
    drop  ;; For now, just drop the value since we don't have a real stack yet
  )
  
  (func $sendMessage
    (param $selector (ref null eq))
    (param $argCount i32)
    ;; TODO: Implement message send with method lookup
    ;; For now, this is a stub function
  )
  
  ;; Context operations using named field access
  (func $get_context_pc
    (param $context (ref $Context))
    (result i32)
    local.get $context
    struct.get $Context $pc
  )
  
  (func $set_context_pc
    (param $context (ref $Context))
    (param $pc i32)
    local.get $context
    local.get $pc
    struct.set $Context $pc
  )
  
  (func $get_context_method
    (param $context (ref $Context))
    (result (ref null $CompiledMethod))
    local.get $context
    struct.get $Context $method
  )
  
  ;; Method operations using named field access
  (func $get_method_bytecodes
    (param $method (ref $CompiledMethod))
    (result (ref null $ByteArray))
    local.get $method
    struct.get $CompiledMethod $bytecodes
  )
  
  (func $increment_invocation_count
    (param $method (ref $CompiledMethod))
    (local $current i32)
    
    ;; Get current count
    local.get $method
    struct.get $CompiledMethod $invocationCount
    local.set $current
    
    ;; Increment and store
    local.get $method
    local.get $current
    i32.const 1
    i32.add
    struct.set $CompiledMethod $invocationCount
  )
  
  ;; Basic arithmetic operations for JIT compilation
  (func $smallIntegerAdd
    (param $a i32) (param $b i32)
    (result i32)
    local.get $a
    local.get $b
    i32.add
  )
  
  (func $smallIntegerMultiply  
    (param $a i32) (param $b i32)
    (result i32)
    local.get $a
    local.get $b
    i32.mul
  )
  
  ;; Bytecode interpreter with named field access
  (func $interpret (export "interpret")
    (local $context (ref null $Context))
    (local $method (ref null $CompiledMethod))
    (local $pc i32)
    (local $bytecode i32)
    (local $bytecodes (ref null $ByteArray))
    
    loop $interpreter_loop
      try $execution_block
        ;; Get current context and fetch bytecode
        global.get $activeContext
        ref.as_non_null
        local.tee $context
        
        ;; Get current method
        struct.get $Context $method
        ref.as_non_null
        local.tee $method
        
        ;; Get and increment PC
        local.get $context
        struct.get $Context $pc
        local.tee $pc
        
        ;; Get bytecodes array
        local.get $method
        struct.get $CompiledMethod $bytecodes
        ref.as_non_null
        local.tee $bytecodes
        
        ;; Fetch bytecode - need both array and index parameters
        local.get $bytecodes
        local.get $pc
        call $array_get_byte
        local.set $bytecode
        
        ;; Increment PC
        local.get $context
        local.get $pc
        i32.const 1
        i32.add
        struct.set $Context $pc
        
        ;; Check JIT compilation threshold
        local.get $method
        call $check_jit_compilation
        
        ;; Dispatch bytecode
        local.get $bytecode
        call $dispatch_bytecode
        
        br $interpreter_loop
        
      catch $Return
        ;; Return value caught
        call $system_report_result
        return
      catch $PrimitiveFailed
        ;; Continue with interpreter
        br $interpreter_loop
      catch $DoesNotUnderstand
        ;; Handle DNU
        drop ;; selector
        drop ;; args
        br $interpreter_loop
      end
    end
  )
  
  ;; JIT compilation check using named field access
  (func $check_jit_compilation
    (param $method (ref $CompiledMethod))
    (local $count i32)
    (local $threshold i32)
    
    ;; Get invocation count
    local.get $method
    struct.get $CompiledMethod $invocationCount
    local.set $count
    
    ;; Get threshold
    local.get $method
    struct.get $CompiledMethod $jitThreshold
    local.set $threshold
    
    ;; Check if we should compile
    local.get $count
    local.get $threshold
    i32.ge_u
    if
      ;; Check if not already compiled
      local.get $method
      struct.get $CompiledMethod $compiledWasm
      ref.is_null
      if
        ;; JIT compile this method
        local.get $method
        call $jit_compile_method
      end
    end
    
    ;; Increment invocation count
    local.get $method
    call $increment_invocation_count
  )
  
  ;; JIT compilation function
  (func $jit_compile_method
    (param $method (ref $CompiledMethod))
    (local $bytecodes (ref null $ByteArray))
    (local $length i32)
    (local $header i32)
    
    ;; Get method details
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.set $bytecodes
    
    local.get $method
    struct.get $CompiledMethod $header
    local.set $header
    
    ;; Get bytecode length
    local.get $bytecodes
    ref.as_non_null
    call $array_len_byte
    local.set $length
    
    ;; Call JavaScript JIT compiler (stub for now)
    local.get $length
    local.get $header
    i32.const 0 ;; bytecodes pointer (placeholder)
    i32.const 0 ;; literals pointer (placeholder)
    call $jit_compile_method_js
    drop
  )
  
  ;; Basic bytecode dispatch
  (func $dispatch_bytecode
    (param $bytecode i32)
    
    ;; Simple dispatch for testing
    local.get $bytecode
    i32.const 16
    i32.lt_u
    if
      ;; pushReceiverVariable
      local.get $bytecode
      call $push_receiver_variable
      return
    end
    
    local.get $bytecode
    i32.const 32
    i32.lt_u
    if
      ;; pushLiteralConstant
      local.get $bytecode
      i32.const 16
      i32.sub
      call $push_literal_constant
      return
    end
    
    ;; More bytecode cases would go here
    ;; For now, just return
  )
  
  ;; Stub implementations for bytecode operations
  (func $push_receiver_variable
    (param $index i32)
    ;; TODO: Implement receiver variable push
  )
  
  (func $push_literal_constant
    (param $index i32)
    ;; TODO: Implement literal constant push
  )
  
  ;; Bootstrap function to create minimal object memory
  (func $createMinimalObjectMemory (export "createMinimalObjectMemory")
    ;; Initialize identity hash counter
    i32.const 1000
    global.set $nextIdentityHash
    
    ;; TODO: Create essential classes and objects
    ;; This is a stub for now
  )
  
  ;; Simple test function
  (func $test (export "test") (result i32)
    (local $result i32)
    
    ;; Simple arithmetic test: 3 + 4 = 7
    i32.const 3
    i32.const 4
    call $smallIntegerAdd
    local.tee $result
    
    ;; Report result to JavaScript
    call $system_report_result
    
    ;; Return result
    local.get $result
  )
)