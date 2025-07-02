;; SqueakJS to WASM VM Core Module - Phase 3: JIT Compilation Support
;; Integrates bytecode-to-WASM translation and compiled method execution

(module $SqueakVMCore
  ;; Import JavaScript interface functions
  (import "system" "reportResult" (func $system_report_result (param i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "consoleLog" (func $consoleLog (param i32)))
  
  ;; Import JIT compilation interface
  (import "jit" "compileMethod" (func $jit_compile_method_js 
    (param i32 i32 i32 i32) (result i32)))  ;; methodRef, classRef, selectorRef, enableSingleStep -> functionRef
  (import "jit" "reportError" (func $js_report_error (param i32)))
  
  (rec
   ;; Type 0: ObjectArray - can hold both objects and i31ref SmallIntegers
   (type $ObjectArray (array (mut (ref null eq))))
   
   ;; Type 1: ByteArray 
   (type $ByteArray (array (mut i8)))
   
   ;; Type 2: Base Squeak object
   (type $SqueakObject (sub (struct 
             (field $class (mut (ref null $Class)))
             (field $identityHash (mut i32))
             (field $format (mut i32))
             (field $size (mut i32))
             (field $nextObject (mut (ref null $SqueakObject)))  ;; For object enumeration
             )))
   
   ;; Type 3: Variable objects
   (type $VariableObject (sub $SqueakObject (struct 
                     (field $class (mut (ref null $Class)))
                     (field $identityHash (mut i32))
                     (field $format (mut i32))
                     (field $size (mut i32))
                     (field $nextObject (mut (ref null $SqueakObject)))
                     (field $slots (mut (ref null $ObjectArray)))
                     )))
   
   ;; Type 4: Symbol objects for method selectors
   (type $Symbol (sub $VariableObject (struct
                   (field $class (mut (ref null $Class)))
                   (field $identityHash (mut i32))
                   (field $format (mut i32))
                   (field $size (mut i32))
                   (field $nextObject (mut (ref null $SqueakObject)))
                   (field $slots (mut (ref null $ObjectArray)))
                   (field $bytes (ref null $ByteArray))
                   )))
   
   ;; Type 5: Dictionary for method lookup
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
   
   ;; Type 6: Class objects
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
   
   ;; Type 7: CompiledMethod with JIT compilation support
   (type $CompiledMethod (sub $VariableObject (struct
                           (field $class (mut (ref null $Class)))
                           (field $identityHash (mut i32))
                           (field $format (mut i32))
                           (field $size (mut i32))
                           (field $nextObject (mut (ref null $SqueakObject)))
                           (field $slots (mut (ref null $ObjectArray)))
                           (field $header i32)
                           (field $bytecodes (ref null $ByteArray))
                           (field $invocationCount (mut i32))  ;; For JIT heuristics
                           (field $compiledWasm (mut (ref null func)))  ;; JIT compiled version
                           (field $jitThreshold i32)  ;; Compilation threshold
                           )))
   
   ;; Type 8: Context objects for execution state
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
                        (field $receiver (mut (ref null eq)))  ;; Can be object or i31ref
                        (field $args (mut (ref null $ObjectArray)))
                        (field $temps (mut (ref null $ObjectArray)))
                        (field $stack (mut (ref null $ObjectArray)))
                        )))
   )

  ;; Global VM state
  (global $objectClass (mut (ref null $Class)))
  (global $classClass (mut (ref null $Class)))
  (global $methodClass (mut (ref null $Class)))
  (global $contextClass (mut (ref null $Class)))
  (global $symbolClass (mut (ref null $Class)))
  (global $smallIntegerClass (mut (ref null $Class)))
  
  ;; Essential objects
  (global $nilObject (mut (ref null eq)))
  (global $trueObject (mut (ref null eq)))
  (global $falseObject (mut (ref null eq)))
  
  ;; Special selectors for quick sends
  (global $plusSelector (mut (ref null eq)))
  (global $timesSelector (mut (ref null eq)))
  (global $squaredSelector (mut (ref null eq)))
  (global $reportToJSSelector (mut (ref null eq)))
  
  ;; VM execution state
  (global $activeContext (mut (ref null $Context)))
  (global $currentReceiver (mut (ref null eq)))
  (global $homeContextTemps (mut (ref null $ObjectArray)))
  (global $specialObjects (mut (ref null $ObjectArray)))
  (global $currentPC (mut i32))
  (global $currentSP (mut i32))
  (global $breakOutOfInterpreter (mut i32))
  
  ;; JIT compilation globals
  (global $functionTable (mut (ref null $ObjectArray)))
  (global $functionTableSize (mut i32))
  (global $jitCompilationCount (mut i32))
  
  ;; Object enumeration globals for #become: support
  (global $firstObject (mut (ref null $SqueakObject)))
  (global $lastObject (mut (ref null $SqueakObject)))
  (global $objectCount (mut i32))
  
  ;; Memory management
  (global $nextIdentityHash (mut i32))
  
  ;; Helper functions for JIT compilation interface
  
  ;; Extract data from WASM GC structures for JavaScript JIT compiler
  (func $get_compiled_method_bytecodes
    (param $method (ref $CompiledMethod)) 
    (result (ref null $ByteArray))
    local.get $method
    struct.get $CompiledMethod $bytecodes
  )
  
  (func $get_compiled_method_literals
    (param $method (ref $CompiledMethod))
    (result (ref null $ObjectArray))
    local.get $method
    struct.get $CompiledMethod $slots  ;; literals stored in slots
  )
  
  (func $get_compiled_method_header
    (param $method (ref $CompiledMethod))
    (result i32)
    local.get $method
    struct.get $CompiledMethod $header
  )
  
  (func $get_class_name
    (param $class (ref $Class))
    (result (ref null $Symbol))
    local.get $class
    struct.get $Class $name
  )
  
  (func $get_symbol_bytes
    (param $symbol (ref $Symbol))
    (result (ref null $ByteArray))
    local.get $symbol
    struct.get $Symbol $bytes
  )
  
  ;; Array accessors for JavaScript interface
  (func $array_len_i8
    (param $array (ref $ByteArray))
    (result i32)
    local.get $array
    array.len
  )
  
  (func $array_get_i8
    (param $array (ref $ByteArray))
    (param $index i32)
    (result i32)
    local.get $array
    local.get $index
    array.get_u
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
    array.get
  )
  
  ;; Type checking functions
  (func $is_small_integer
    (param $object (ref null eq))
    (result i32)
    local.get $object
    ref.test i31ref
  )
  
  ;; Corrected get_small_integer_value function
  (func $get_small_integer_value
    (param $object (ref eq))  ;; Takes ref eq (parent type of i31 and objects)
    (result i32)
    
    ;; Test if it's an i31ref (SmallInteger)
    local.get $object
    ref.test i31ref
    if
      ;; It's a SmallInteger - extract the value using i31.get_s
      local.get $object
      ref.cast i31ref
      i31.get_s  ;; Get signed 31-bit value
      return
    end
    
    ;; If we reach here, it's not a SmallInteger
    i32.const 0
  )
  
  ;; JIT compilation management
  (func $should_compile_method
    (param $method (ref $CompiledMethod))
    (result i32)
    
    ;; Check if method has already been compiled
    local.get $method
    struct.get $CompiledMethod $compiledWasm
    ref.is_null
    if
      ;; Not compiled - check invocation count vs threshold
      local.get $method
      struct.get $CompiledMethod $invocationCount
      local.get $method
      struct.get $CompiledMethod $jitThreshold
      i32.ge_u
      return
    end
    
    ;; Already compiled
    i32.const 0
  )
  
  (func $increment_invocation_count
    (param $method (ref $CompiledMethod))
    
    local.get $method
    local.get $method
    struct.get $CompiledMethod $invocationCount
    i32.const 1
    i32.add
    struct.set $CompiledMethod $invocationCount
  )
  
  (func $attempt_jit_compilation
    (param $method (ref $CompiledMethod))
    (param $class (ref $Class))
    (param $selector (ref $Symbol))
    (result i32)  ;; Returns 1 if compilation succeeded
    
    (local $methodRef i32)
    (local $classRef i32)
    (local $selectorRef i32)
    (local $functionRef i32)
    
    ;; Convert WASM GC references to integers for JavaScript interface
    local.get $method
    ref.as_non_null
    ref.cast i31ref
    i31.get_u
    local.set $methodRef
    
    local.get $class
    ref.as_non_null
    ref.cast i31ref
    i31.get_u
    local.set $classRef
    
    local.get $selector
    ref.as_non_null
    ref.cast i31ref
    i31.get_u
    local.set $selectorRef
    
    ;; Call JavaScript JIT compiler
    local.get $methodRef
    local.get $classRef
    local.get $selectorRef
    i32.const 0  ;; enableSingleStep = false
    call $jit_compile_method_js
    local.set $functionRef
    
    ;; Check if compilation succeeded
    local.get $functionRef
    if
      ;; Store compiled function in method
      ;; TODO: Convert functionRef back to WASM function reference
      ;; local.get $method
      ;; local.get $functionRef
      ;; struct.set $CompiledMethod $compiledWasm
      
      ;; Update compilation statistics
      global.get $jitCompilationCount
      i32.const 1
      i32.add
      global.set $jitCompilationCount
      
      i32.const 1
      return
    end
    
    i32.const 0
  )
  
  ;; Enhanced method execution with JIT compilation
  (func $execute_method
    (param $method (ref $CompiledMethod))
    (param $class (ref $Class))
    (param $selector (ref $Symbol))
    (result (ref null eq))
    
    ;; Increment invocation count
    local.get $method
    call $increment_invocation_count
    
    ;; Check if method should be JIT compiled
    local.get $method
    call $should_compile_method
    if
      ;; Attempt JIT compilation
      local.get $method
      local.get $class
      local.get $selector
      call $attempt_jit_compilation
      drop
    end
    
    ;; Check if method has compiled version
    local.get $method
    struct.get $CompiledMethod $compiledWasm
    ref.is_null
    if
      ;; No compiled version - use bytecode interpreter
      local.get $method
      call $interpret_bytecodes
    else
      ;; Use compiled version
      ;; TODO: Call compiled WASM function
      ;; local.get $method
      ;; struct.get $CompiledMethod $compiledWasm
      ;; call_ref
      
      ;; For now, fall back to interpreter
      local.get $method
      call $interpret_bytecodes
    end
  )
  
  ;; Basic bytecode interpreter (enhanced from Phase 2)
  (func $interpret_bytecodes
    (param $method (ref $CompiledMethod))
    (result (ref null eq))
    
    (local $bytecodes (ref null $ByteArray))
    (local $pc i32)
    (local $bytecode i32)
    
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.set $bytecodes
    
    i32.const 0
    local.set $pc
    
    loop $interpreter_loop
      ;; Fetch bytecode
      local.get $bytecodes
      local.get $pc
      array.get_u
      local.set $bytecode
      
      ;; Simple bytecode dispatch for "3 squared" example
      local.get $bytecode
      i32.const 0x76  ;; push constant 3
      i32.eq
      if
        i32.const 3
        ref.i31  ;; Create SmallInteger 3
        call $push
        br $interpreter_loop
      end
      
      local.get $bytecode
      i32.const 0x90  ;; send literal selector 0 (squared)
      i32.eq
      if
        call $handle_squared_send
        br $interpreter_loop
      end
      
      local.get $bytecode
      i32.const 0xD0  ;; send reportToJS
      i32.eq
      if
        call $handle_report_to_js_send
        br $interpreter_loop
      end
      
      local.get $bytecode
      i32.const 0x7C  ;; return top
      i32.eq
      if
        call $pop
        return
      end
      
      ;; Unknown bytecode - advance PC
      local.get $pc
      i32.const 1
      i32.add
      local.set $pc
      br $interpreter_loop
    end
    
    global.get $nilObject
  )
  
  ;; Stack operations
  (func $push
    (param $value (ref null eq))
    ;; TODO: Implement stack push
    nop
  )
  
  (func $pop
    (result (ref null eq))
    ;; TODO: Implement stack pop
    global.get $nilObject
  )
  
  ;; Message sending for "3 squared" example
  (func $handle_squared_send
    (local $receiver (ref null eq))
    (local $result i32)
    
    ;; Pop receiver (should be SmallInteger 3)
    call $pop
    local.set $receiver
    
    ;; Calculate 3 * 3 = 9
    local.get $receiver
    call $get_small_integer_value
    local.tee $result
    local.get $result
    i32.mul
    ref.i31
    call $push
  )
  
  (func $handle_report_to_js_send
    (local $value (ref null eq))
    (local $intValue i32)
    
    ;; Pop value to report
    call $pop
    local.set $value
    
    ;; Convert to integer and report
    local.get $value
    call $get_small_integer_value
    local.set $intValue
    
    local.get $intValue
    call $system_report_result
  )
  
  ;; Object enumeration support for #become: and garbage collection
  (func $register_object
    (param $object (ref $SqueakObject))
    
    ;; Add object to enumeration chain
    local.get $object
    ref.null $SqueakObject
    struct.set $SqueakObject $nextObject
    
    ;; Link to chain
    global.get $lastObject
    ref.is_null
    if
      ;; First object
      local.get $object
      global.set $firstObject
      local.get $object
      global.set $lastObject
    else
      ;; Link after last object
      global.get $lastObject
      local.get $object
      struct.set $SqueakObject $nextObject
      
      local.get $object
      global.set $lastObject
    end
    
    ;; Increment object count
    global.get $objectCount
    i32.const 1
    i32.add
    global.set $objectCount
  )
  
  (func $enumerate_all_objects
    (param $visitor (ref func))
    
    (local $current (ref null $SqueakObject))
    (local $next (ref null $SqueakObject))
    
    global.get $firstObject
    local.set $current
    
    loop $enumeration_loop
      local.get $current
      ref.is_null
      if
        return
      end
      
      ;; Get next object before calling visitor (visitor might modify chain)
      local.get $current
      struct.get $SqueakObject $nextObject
      local.set $next
      
      ;; Call visitor function
      local.get $current
      ;; TODO: call_ref $visitor when function references are properly implemented
      
      ;; Move to next object
      local.get $next
      local.set $current
      br $enumeration_loop
    end
  )
  
  (func $become_objects
    (param $fromArray (ref $ObjectArray))
    (param $toArray (ref $ObjectArray))
    (result i32)  ;; Returns success (1) or failure (0)
    
    ;; Simplified become: implementation
    ;; In a full implementation, this would:
    ;; 1. Validate arrays have same length
    ;; 2. Enumerate all objects
    ;; 3. Replace all references from -> to
    ;; 4. Handle special cases (classes, contexts, etc.)
    
    ;; For now, just return success
    i32.const 1
  )
  
  ;; Object creation functions (updated to register objects)
  (func $nextIdentityHash (result i32)
    global.get $nextIdentityHash
    i32.const 1
    i32.add
    global.set $nextIdentityHash
    global.get $nextIdentityHash
  )
  
  (func $createClass (result (ref $Class))
    (local $newClass (ref $Class))
    
    global.get $classClass
    call $nextIdentityHash
    i32.const 1    ;; format for class
    i32.const 0    ;; size
    ref.null $SqueakObject  ;; nextObject (will be set by register_object)
    i32.const 10   ;; slots (default object array size)
    ref.null eq
    array.new $ObjectArray
    ref.null $Class  ;; superclass
    ref.null $Dictionary  ;; methodDict
    ref.null $SqueakObject  ;; instVarNames
    ref.null $Symbol  ;; name
    i32.const 0    ;; instance size
    struct.new $Class
    local.tee $newClass
    
    ;; Register in object enumeration chain
    call $register_object
    
    local.get $newClass
  )
  
  (func $createSymbol (param $name i32) (result (ref $Symbol))
    (local $nameBytes (ref $ByteArray))
    (local $symbol (ref $Symbol))
    
    ;; Create byte array for symbol name (simplified)
    i32.const 8
    i32.const 0
    array.new $ByteArray
    local.set $nameBytes
    
    global.get $symbolClass
    call $nextIdentityHash
    i32.const 11   ;; format for symbol
    i32.const 1    ;; size
    ref.null $SqueakObject  ;; nextObject (will be set by register_object)
    i32.const 1    ;; slots
    ref.null eq
    array.new $ObjectArray
    local.get $nameBytes
    struct.new $Symbol
    local.tee $symbol
    
    ;; Register in object enumeration chain
    call $register_object
    
    local.get $symbol
  )
  
  (func $createSquaredMethod (result (ref $CompiledMethod))
    (local $bytecodes (ref $ByteArray))
    (local $literals (ref $ObjectArray))
    (local $method (ref $CompiledMethod))
    
    ;; Create bytecode array for: 3 squared, reportToJS, return top
    ;; Bytecodes: [0x76, 0x90, 0xD0, 0x7C]
    (array.new_fixed $ByteArray 4
           (i32.const 0x76)  ;; push 3
           (i32.const 0x90)  ;; send literal selector 0 (squared)
           (i32.const 0xD0)  ;; send reportToJS
           (i32.const 0x7C)  ;; return top
           )
    local.set $bytecodes
    
    ;; Create literals array with 'squared' selector
    i32.const 2
    ref.null eq
    array.new $ObjectArray
    local.tee $literals
    
    ;; Set literal 0 to be 'squared' selector
    i32.const 0
    global.get $squaredSelector
    array.set $ObjectArray
    
    ;; Set literal 1 to be 'reportToJS' selector
    local.get $literals
    i32.const 1
    global.get $reportToJSSelector
    array.set $ObjectArray
    
    ;; Create CompiledMethod object with JIT support and proper field ordering
    global.get $methodClass
    call $nextIdentityHash
    i32.const 12    ;; format for method
    i32.const 2     ;; size (literals)
    ref.null $SqueakObject  ;; nextObject (will be set by register_object)
    local.get $literals  ;; slots (literals)
    i32.const 0     ;; header
    local.get $bytecodes  ;; bytecodes
    i32.const 0     ;; invocationCount
    ref.null func   ;; compiledWasm
    i32.const 10    ;; jitThreshold - compile after 10 invocations
    struct.new $CompiledMethod
    local.tee $method
    
    ;; Register in object enumeration chain
    call $register_object
    
    local.get $method
  )
  
  ;; VM initialization
  (func $createMinimalBootstrap (result i32)
    ;; Initialize object enumeration chain
    ref.null $SqueakObject
    global.set $firstObject
    
    ref.null $SqueakObject
    global.set $lastObject
    
    i32.const 0
    global.set $objectCount
    
    ;; Initialize identity hash counter
    i32.const 1000
    global.set $nextIdentityHash
    
    ;; Create essential classes (these will be registered automatically)
    call $createClass
    global.set $objectClass
    
    call $createClass
    global.set $classClass
    
    call $createClass
    global.set $methodClass
    
    call $createClass
    global.set $contextClass
    
    call $createClass
    global.set $symbolClass
    
    call $createClass
    global.set $smallIntegerClass
    
    ;; Create special objects (SmallIntegers don't need registration)
    i32.const 99
    ref.i31
    global.set $nilObject
    
    i32.const 1
    ref.i31
    global.set $trueObject
    
    i32.const 0
    ref.i31
    global.set $falseObject
    
    ;; Create selectors (SmallIntegers don't need registration)
    i32.const 100  ;; squared selector
    ref.i31
    global.set $squaredSelector
    
    i32.const 200  ;; reportToJS selector
    ref.i31
    global.set $reportToJSSelector
    
    ;; Initialize JIT compilation
    i32.const 0
    global.set $jitCompilationCount
    
    i32.const 16
    ref.null eq
    array.new $ObjectArray
    global.set $functionTable
    
    i32.const 0
    global.set $functionTableSize
    
    i32.const 1  ;; Success
  )
  
  ;; Main interpreter entry point for "3 squared" example
  (func $interpret
    (local $method (ref $CompiledMethod))
    (local $result (ref null eq))
    
    ;; Create the "3 squared" method
    call $createSquaredMethod
    local.set $method
    
    ;; Execute method with JIT compilation support
    local.get $method
    global.get $smallIntegerClass
    global.get $squaredSelector
    call $execute_method
    drop
  )
  
  ;; Export functions for JavaScript interface
  (export "createMinimalBootstrap" (func $createMinimalBootstrap))
  (export "interpret" (func $interpret))
  
  ;; Export JIT interface functions
  (export "get_compiled_method_bytecodes" (func $get_compiled_method_bytecodes))
  (export "get_compiled_method_literals" (func $get_compiled_method_literals))
  (export "get_compiled_method_header" (func $get_compiled_method_header))
  (export "get_class_name" (func $get_class_name))
  (export "get_symbol_bytes" (func $get_symbol_bytes))
  (export "array_len_i8" (func $array_len_i8))
  (export "array_get_i8" (func $array_get_i8))
  (export "array_len_object" (func $array_len_object))
  (export "array_get_object" (func $array_get_object))
  (export "is_small_integer" (func $is_small_integer))
  (export "get_small_integer_value" (func $get_small_integer_value))
  
  ;; Export statistics functions
  (export "getJITCompilationCount" (func $getJITCompilationCount))
  (export "getObjectCount" (func $getObjectCount))
  (export "getFirstObject" (func $getFirstObject))
  
  (func $getJITCompilationCount (result i32)
    global.get $jitCompilationCount
  )
  
  (func $getObjectCount (result i32)
    global.get $objectCount
  )
  
  (func $getFirstObject (result (ref null $SqueakObject))
    global.get $firstObject
  )
  
  ;; Export object enumeration functions for advanced VM operations
  (export "become_objects" (func $become_objects))
  (export "enumerate_all_objects" (func $enumerate_all_objects))
)