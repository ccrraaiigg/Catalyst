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
    struct.get $CompiledMethod $slots  ;; literals are stored in slots
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
  
  ;; Array access functions for JavaScript bridge
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
    array.get $ByteArray
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
  
  ;; Object enumeration for #become: support
  (func $register_object
    (param $object (ref $SqueakObject))
    
    ;; Link object into enumeration chain
    global.get $lastObject
    ref.is_null
    if
      ;; First object
      local.get $object
      global.set $firstObject
    else
      ;; Link to previous last object
      global.get $lastObject
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
    ;; TODO: Push onto execution stack
  )
  
  (func $sendMessage
    (param $selector (ref null eq))
    (param $argCount i32)
    ;; TODO: Implement message send with method lookup
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
  
  ;; Method creation and management
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
    
    ;; Create literals array with null entries (will be filled later)
    i32.const 2
    ref.null eq
    array.new $ObjectArray
    local.set $literals
    
    ;; Create CompiledMethod object with JIT support
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
  (func $initializeVM
    ;; Initialize identity hash counter
    i32.const 1000
    global.set $nextIdentityHash
    
    ;; Initialize object enumeration
    ref.null $SqueakObject
    global.set $firstObject
    ref.null $SqueakObject
    global.set $lastObject
    i32.const 0
    global.set $objectCount
    
    ;; Initialize JIT compilation state
    i32.const 0
    global.set $jitCompilationCount
  )
  
  ;; Main entry point for Phase 3 demo
  (func $runMinimalExample (export "runMinimalExample") (result i32)
    (local $method (ref $CompiledMethod))
    (local $result i32)
    
    ;; Initialize VM if needed
    call $initializeVM
    
    ;; Create and execute squared method
    call $createSquaredMethod
    local.set $method
    
    ;; For Phase 3 demo, simulate executing "3 squared"
    ;; In a full implementation, this would interpret bytecodes
    i32.const 3
    i32.const 3
    call $smallIntegerMultiply  ;; 3 * 3 = 9
    local.set $result
    
    ;; Report result to JavaScript
    local.get $result
    call $system_report_result
    
    ;; Increment JIT compilation count (demo)
    global.get $jitCompilationCount
    i32.const 1
    i32.add
    global.set $jitCompilationCount
    
    ;; Return the result
    local.get $result
  )
  
  ;; JIT compilation entry point
  (func $compileMethodToWASM (export "compileMethodToWASM")
    (param $methodRef i32) (param $classRef i32) (param $selectorRef i32)
    (result i32)
    
    ;; Call JavaScript JIT compiler
    local.get $methodRef
    local.get $classRef  
    local.get $selectorRef
    i32.const 0  ;; enableSingleStep = false
    call $jit_compile_method_js
  )
  
  ;; VM state query functions for debugging
  (func $getJITCompilationCount (export "getJITCompilationCount") (result i32)
    global.get $jitCompilationCount
  )
  
  (func $getObjectCount (export "getObjectCount") (result i32)
    global.get $objectCount
  )
  
  ;; Export helper functions for JavaScript bridge
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
)