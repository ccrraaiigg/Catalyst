;; squeak-vm-core.wat - Core SqueakWASM Virtual Machine with JIT compilation
;; Only exports initialize() and interpret() as required

(module
  ;; Import external functions from JavaScript
  (import "env" "reportResult" (func $reportResult (param i32)))
  (import "env" "compileMethod" (func $compileMethod 
    (param i32 i32 i32) (result i32))) ;; methodPtr, bytecodePtr, len -> funcPtr
  (import "env" "debugLog" (func $debugLog (param i32 i32 i32))) ;; level, msgPtr, len

  ;; WASM GC types for Squeak objects using named fields
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
                           (field $compiledFunc (mut i32))  ;; Index into function table
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
   
   ;; Type 9: Polymorphic Inline Cache entry
   (type $PICEntry (struct
                    (field $selector (mut (ref null eq)))
                    (field $receiverClass (mut (ref null $Class)))
                    (field $method (mut (ref null $CompiledMethod)))
                    (field $hitCount (mut i32))
                    ))
   )

  ;; Global VM state with proper initializers
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
  (global $squaredSelector (mut (ref null eq)) (ref.null eq))
  
  ;; VM execution state
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  
  ;; Object memory management
  (global $nextIdentityHash (mut i32) (i32.const 1000))
  (global $firstObject (mut (ref null $SqueakObject)) (ref.null $SqueakObject))
  (global $lastObject (mut (ref null $SqueakObject)) (ref.null $SqueakObject))
  (global $objectCount (mut i32) (i32.const 0))
  
  ;; JIT compilation globals and method cache
  (global $jitThreshold (mut i32) (i32.const 10))
  (global $jitEnabled (mut i32) (i32.const 1))
  (global $totalCompilations (mut i32) (i32.const 0))
  
  ;; Polymorphic Inline Cache - global method cache
  (global $methodCacheSize (mut i32) (i32.const 256))
  (global $methodCache (mut (ref null $ObjectArray)) (ref.null $ObjectArray))
  
  ;; Function table for compiled methods
  (table $funcTable 100 funcref)
  
  ;; Function table for compiled methods  
  (global $compiledFunctions (mut (ref null $ObjectArray)) (ref.null $ObjectArray))
  (global $nextFunctionIndex (mut i32) (i32.const 1))
  
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

  ;; Stack operations using Context's real stack
  (func $pushOnStack
    (param $context (ref $Context))
    (param $value (ref null eq))
    (local $stack (ref null $ObjectArray))
    (local $sp i32)
    
    ;; Get stack and stack pointer
    local.get $context
    struct.get $Context $stack
    local.tee $stack
    ref.is_null
    if
      return  ;; No stack allocated
    end
    
    local.get $context
    struct.get $Context $sp
    local.tee $sp
    
    ;; Check bounds
    local.get $sp
    local.get $stack
    ref.as_non_null
    array.len
    i32.ge_u
    if
      return  ;; Stack overflow
    end
    
    ;; Push value onto stack
    local.get $stack
    ref.as_non_null
    local.get $sp
    local.get $value
    array.set $ObjectArray
    
    ;; Increment stack pointer
    local.get $context
    local.get $sp
    i32.const 1
    i32.add
    struct.set $Context $sp
  )
  
  (func $popFromStack
    (param $context (ref $Context))
    (result (ref null eq))
    (local $stack (ref null $ObjectArray))
    (local $sp i32)
    
    ;; Get stack and stack pointer
    local.get $context
    struct.get $Context $stack
    local.tee $stack
    ref.is_null
    if
      ref.null eq
      return
    end
    
    local.get $context
    struct.get $Context $sp
    local.tee $sp
    
    ;; Check underflow
    local.get $sp
    i32.const 0
    i32.le_u
    if
      ref.null eq
      return
    end
    
    ;; Decrement stack pointer
    local.get $sp
    i32.const 1
    i32.sub
    local.tee $sp
    
    local.get $context
    local.get $sp
    struct.set $Context $sp
    
    ;; Pop and return value
    local.get $stack
    ref.as_non_null
    local.get $sp
    array.get $ObjectArray
  )
  
  (func $topOfStack
    (param $context (ref $Context))
    (result (ref null eq))
    (local $stack (ref null $ObjectArray))
    (local $sp i32)
    
    ;; Get stack and stack pointer
    local.get $context
    struct.get $Context $stack
    local.tee $stack
    ref.is_null
    if
      ref.null eq
      return
    end
    
    local.get $context
    struct.get $Context $sp
    local.tee $sp
    
    ;; Check empty stack
    local.get $sp
    i32.const 0
    i32.le_u
    if
      ref.null eq
      return
    end
    
    ;; Return top value without popping
    local.get $stack
    ref.as_non_null
    local.get $sp
    i32.const 1
    i32.sub
    array.get $ObjectArray
  )

  ;; Get class of any object (including SmallIntegers)
  (func $getClass (param $obj (ref null eq)) (result (ref null $Class))
    local.get $obj
    ref.test (ref i31)
    if (result (ref null $Class))
      ;; SmallInteger
      global.get $smallIntegerClass
    else
      ;; Regular object
      local.get $obj
      ref.cast (ref $SqueakObject)
      struct.get $SqueakObject $class
    end
  )

  ;; Generic method lookup that works for all messages
  (func $lookupMethod 
    (param $receiver (ref null eq))
    (param $selector (ref null eq))
    (result (ref null $CompiledMethod))
    (local $class (ref null $Class))
    (local $currentClass (ref null $Class))
    (local $methodDict (ref null $Dictionary))
    (local $keys (ref null $ObjectArray))
    (local $values (ref null $ObjectArray))
    (local $count i32)
    (local $i i32)
    (local $key (ref null eq))
    
    ;; Get receiver's class
    local.get $receiver
    call $getClass
    local.set $currentClass
    
    ;; Walk up the class hierarchy
    loop $hierarchy_loop
      local.get $currentClass
      ref.is_null
      if
        ;; Reached top of hierarchy - method not found
        ref.null $CompiledMethod
        return
      end
      
      ;; Get method dictionary from current class
      local.get $currentClass
      ref.as_non_null
      struct.get $Class $methodDict
      local.tee $methodDict
      ref.is_null
      if
        ;; No method dictionary - try superclass
        local.get $currentClass
        ref.as_non_null
        struct.get $Class $superclass
        local.set $currentClass
        br $hierarchy_loop
      end
      
      ;; Search in current class's method dictionary
      local.get $methodDict
      ref.as_non_null
      struct.get $Dictionary $keys
      local.tee $keys
      ref.is_null
      if
        ;; No keys - try superclass
        local.get $currentClass
        ref.as_non_null
        struct.get $Class $superclass
        local.set $currentClass
        br $hierarchy_loop
      end
      
      local.get $methodDict
      ref.as_non_null
      struct.get $Dictionary $values
      local.tee $values
      ref.is_null
      if
        ;; No values - try superclass
        local.get $currentClass
        ref.as_non_null
        struct.get $Class $superclass
        local.set $currentClass
        br $hierarchy_loop
      end
      
      ;; Get count
      local.get $methodDict
      ref.as_non_null
      struct.get $Dictionary $count
      local.set $count
      
      ;; Linear search for selector in current class
      i32.const 0
      local.set $i
      
      loop $search_loop
        local.get $i
        local.get $count
        i32.ge_u
        if
          ;; Not found in this class - try superclass
          local.get $currentClass
          ref.as_non_null
          struct.get $Class $superclass
          local.set $currentClass
          br $hierarchy_loop
        end
        
        ;; Get key at index i
        local.get $keys
        ref.as_non_null
        local.get $i
        array.get $ObjectArray
        local.set $key
        
        ;; Compare with selector
        local.get $key
        local.get $selector
        ref.eq
        if
          ;; Found! Get the method
          local.get $values
          ref.as_non_null
          local.get $i
          array.get $ObjectArray
          ref.cast $CompiledMethod
          return
        end
        
        ;; Increment and continue
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $search_loop
      end
    end
    
    ;; Should never reach here
    ref.null $CompiledMethod
  )

  ;; Polymorphic Inline Cache lookup
  (func $lookupInCache
    (param $selector (ref null eq))
    (param $receiverClass (ref null $Class))
    (result (ref null $CompiledMethod))
    (local $cache (ref null $ObjectArray))
    (local $cacheSize i32)
    (local $hash i32)
    (local $index i32)
    (local $entry (ref null $PICEntry))
    (local $probeLimit i32)
    
    ;; Get method cache
    global.get $methodCache
    local.tee $cache
    ref.is_null
    if
      ref.null $CompiledMethod
      return
    end
    
    ;; Simple hash function (identity hash of selector + class)
    local.get $selector
    ref.cast (ref $SqueakObject)
    struct.get $SqueakObject $identityHash
    
    local.get $receiverClass
    ref.as_non_null
    struct.get $Class $identityHash
    i32.add
    
    global.get $methodCacheSize
    i32.rem_u
    local.set $index
    
    ;; Linear probing with limit
    i32.const 8  ;; Max probe distance
    local.set $probeLimit
    
    loop $probe_loop
      local.get $probeLimit
      i32.const 0
      i32.le_s
      if
        ;; Probe limit exceeded
        ref.null $CompiledMethod
        return
      end
      
      ;; Get cache entry
      local.get $cache
      ref.as_non_null
      local.get $index
      array.get $ObjectArray
      local.tee $entry
      ref.is_null
      if
        ;; Empty slot - cache miss
        ref.null $CompiledMethod
        return
      end
      
      ;; Check if entry matches
      local.get $entry
      ref.cast $PICEntry
      local.tee $entry
      struct.get $PICEntry $selector
      local.get $selector
      ref.eq
      
      local.get $entry
      struct.get $PICEntry $receiverClass
      local.get $receiverClass
      ref.eq
      i32.and
      if
        ;; Cache hit - increment hit count and return method
        local.get $entry
        local.get $entry
        struct.get $PICEntry $hitCount
        i32.const 1
        i32.add
        struct.set $PICEntry $hitCount
        
        local.get $entry
        struct.get $PICEntry $method
        return
      end
      
      ;; Try next slot
      local.get $index
      i32.const 1
      i32.add
      global.get $methodCacheSize
      i32.rem_u
      local.set $index
      
      local.get $probeLimit
      i32.const 1
      i32.sub
      local.set $probeLimit
      
      br $probe_loop
    end
    
    ;; Should never reach here
    ref.null $CompiledMethod
  )

  ;; Store method in cache
  (func $storeInCache
    (param $selector (ref null eq))
    (param $receiverClass (ref null $Class))
    (param $method (ref $CompiledMethod))
    (local $cache (ref null $ObjectArray))
    (local $index i32)
    (local $entry (ref $PICEntry))
    
    ;; Get method cache
    global.get $methodCache
    local.tee $cache
    ref.is_null
    if
      return
    end
    
    ;; Simple hash function
    local.get $selector
    ref.cast (ref $SqueakObject)
    struct.get $SqueakObject $identityHash
    
    local.get $receiverClass
    ref.as_non_null
    struct.get $Class $identityHash
    i32.add
    
    global.get $methodCacheSize
    i32.rem_u
    local.set $index
    
    ;; Create new cache entry
    local.get $selector
    local.get $receiverClass
    local.get $method
    i32.const 1  ;; Initial hit count
    struct.new $PICEntry
    local.set $entry
    
    ;; Store in cache
    local.get $cache
    ref.as_non_null
    local.get $index
    local.get $entry
    array.set $ObjectArray
  )

  ;; Create context for method call
  (func $createMethodContext 
    (param $receiver (ref null eq))
    (param $method (ref $CompiledMethod))
    (param $selector (ref null eq))
    (result (ref $Context))
    (local $stack (ref $ObjectArray))
    
    ;; Create new stack for the method
    i32.const 20
    ref.null eq
    array.new $ObjectArray
    local.set $stack
    
    ;; Create context for method
    global.get $objectClass ;; class (Context is-a Object for now)
    call $nextIdentityHash
    i32.const 14         ;; format (MethodContext)
    i32.const 14         ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 8
    ref.null eq
    array.new $ObjectArray ;; slots
    global.get $activeContext  ;; sender (current context)
    i32.const 0          ;; pc
    i32.const 0          ;; sp
    local.get $method    ;; method
    local.get $receiver  ;; receiver
    ref.null $ObjectArray ;; args
    ref.null $ObjectArray ;; temps
    local.get $stack     ;; stack
    struct.new $Context
  )

  ;; SmallInteger operations
  (func $createSmallInteger (param $value i32) (result (ref i31))
    local.get $value
    ref.i31
  )
  
  (func $extractIntegerValue (param $obj (ref null eq)) (result i32)
    local.get $obj
    ref.test (ref i31)
    if (result i32)
      local.get $obj
      ref.cast (ref i31)
      i31.get_s
    else
      ;; Not a SmallInteger - return 0 for safety
      i32.const 0
    end
  )

  ;; Check if method has compiled function
  (func $hasCompiledFunction (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod $compiledFunc
    i32.const 0
    i32.ne
  )

  ;; Execute compiled WASM function by calling it directly
  (func $executeCompiledFunction 
    (param $context (ref $Context))
    (param $funcIndex i32)
    (result i32)
    ;; Call the compiled function directly using call_indirect
    ;; The function should operate on the context and return 0 for success
    local.get $context
    local.get $funcIndex
    call_indirect (param (ref $Context)) (result i32)
  )

  ;; Trigger JIT compilation for hot method
  (func $triggerJITCompilation (param $method (ref $CompiledMethod))
    (local $bytecodes (ref null $ByteArray))
    (local $bytecodeLen i32)
    (local $compiledFuncIndex i32)
    
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
    
    ;; Call JavaScript JIT compiler
    local.get $method
    ref.cast (ref $SqueakObject)
    struct.get $SqueakObject $identityHash  ;; Use method identity as pointer
    i32.const 0x1000  ;; Simplified bytecode pointer
    local.get $bytecodeLen
    call $compileMethod
    local.set $compiledFuncIndex
    
    ;; Store compiled function if successful
    local.get $compiledFuncIndex
    i32.const 0
    i32.ne
    if
      ;; Store function index in method
      local.get $method
      local.get $compiledFuncIndex
      struct.set $CompiledMethod $compiledFunc
      
      ;; Increment compilation count
      global.get $totalCompilations
      i32.const 1
      i32.add
      global.set $totalCompilations
    end
  )

  ;; Handle method return and context switching
  (func $handleMethodReturn (param $context (ref $Context)) (result (ref null eq))
    (local $sender (ref null $Context))
    (local $result (ref null eq))
    
    ;; Get result from top of stack
    local.get $context
    call $topOfStack
    local.set $result
    
    ;; Get sender context
    local.get $context
    struct.get $Context $sender
    local.tee $sender
    ref.is_null
    if
      ;; No sender - we're done
      local.get $result
      return
    end
    
    ;; Switch back to sender context
    local.get $sender
    ref.as_non_null
    global.set $activeContext
    
    ;; Push result onto sender's stack
    local.get $sender
    ref.as_non_null
    local.get $result
    call $pushOnStack
    
    local.get $result
  )

  ;; VM initialization and bootstrap
  (func $initialize (export "initialize") (result i32)
    ;; Create minimal object memory for 3 squared example
    call $createMinimalBootstrap
    
    ;; Return success
    i32.const 1
  )

  ;; Create minimal bootstrap environment for 3 squared
  (func $createMinimalBootstrap (result i32)
    (local $mainMethod (ref $CompiledMethod))
    (local $squaredMethod (ref $CompiledMethod))
    (local $mainContext (ref $Context))
    (local $mainBytecodes (ref $ByteArray))
    (local $squaredBytecodes (ref $ByteArray))
    (local $stack (ref $ObjectArray))
    (local $receiver (ref i31))
    (local $objectClass (ref $Class))
    (local $classClass (ref $Class))
    (local $smallIntClass (ref $Class))
    (local $methodDict (ref $Dictionary))
    (local $squaredSelector (ref $Symbol))
    
    ;; Initialize method cache
    global.get $methodCacheSize
    ref.null eq
    array.new $ObjectArray
    global.set $methodCache
    
    ;; Initialize compiled functions array
    i32.const 100
    ref.null eq
    array.new $ObjectArray
    global.set $compiledFunctions
    
    ;; Create Class class first (bootstrap issue)
    ref.null $Class     ;; class (will be set to itself)
    call $nextIdentityHash
    i32.const 1         ;; format (regular object)
    i32.const 11        ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 6
    ref.null eq
    array.new $ObjectArray ;; slots
    ref.null $Class     ;; superclass
    ref.null $Dictionary ;; methodDict
    ref.null $SqueakObject ;; instVarNames
    ref.null $Symbol    ;; name
    i32.const 0         ;; instSize
    struct.new $Class
    local.tee $classClass
    global.set $classClass
    
    ;; Set Class class to itself (bootstrap)
    local.get $classClass
    local.get $classClass
    struct.set $Class $class
    
    ;; Create Object class
    local.get $classClass ;; class
    call $nextIdentityHash
    i32.const 1         ;; format
    i32.const 11        ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 6
    ref.null eq
    array.new $ObjectArray ;; slots
    ref.null $Class     ;; superclass (nil for Object)
    ref.null $Dictionary ;; methodDict
    ref.null $SqueakObject ;; instVarNames
    ref.null $Symbol    ;; name
    i32.const 0         ;; instSize
    struct.new $Class
    local.tee $objectClass
    global.set $objectClass
    
    ;; Create SmallInteger class
    local.get $classClass ;; class
    call $nextIdentityHash
    i32.const 1         ;; format
    i32.const 11        ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 6
    ref.null eq
    array.new $ObjectArray ;; slots
    local.get $objectClass ;; superclass (Object)
    ref.null $Dictionary ;; methodDict (will be created)
    ref.null $SqueakObject ;; instVarNames
    ref.null $Symbol    ;; name
    i32.const 0         ;; instSize
    struct.new $Class
    local.tee $smallIntClass
    global.set $smallIntegerClass
    
    ;; Create method dictionary for SmallInteger
    local.get $objectClass ;; class (Dictionary is-a Object for now)
    call $nextIdentityHash
    i32.const 2         ;; format (variable object)
    i32.const 9         ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 2
    ref.null eq
    array.new $ObjectArray ;; slots
    i32.const 2
    ref.null eq
    array.new $ObjectArray ;; keys
    i32.const 2
    ref.null eq
    array.new $ObjectArray ;; values
    i32.const 0         ;; count
    struct.new $Dictionary
    local.set $methodDict
    
    ;; Install method dictionary in SmallInteger class
    local.get $smallIntClass
    local.get $methodDict
    struct.set $Class $methodDict
    
    ;; Create #squared selector symbol
    local.get $objectClass ;; class (Symbol is-a Object for now)
    call $nextIdentityHash
    i32.const 8         ;; format (byte object)
    i32.const 7         ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 1
    ref.null eq
    array.new $ObjectArray ;; slots
    i32.const 7
    i32.const 115 ;; 's'
    i32.const 113 ;; 'q'
    i32.const 117 ;; 'u'
    i32.const 97  ;; 'a'
    i32.const 114 ;; 'r'
    i32.const 101 ;; 'e'
    i32.const 100 ;; 'd'
    array.new $ByteArray ;; "squared"
    struct.new $Symbol
    local.set $squaredSelector
    global.set $squaredSelector
    
    ;; Create SmallInteger 3 as receiver
    i32.const 3
    ref.i31
    local.set $receiver
    
    ;; Create bytecode sequence for main method: "3 squared"
    ;; Bytecodes: push receiver (3), send #squared (selector index 0)
    i32.const 3
    i32.const 0x70  ;; Push receiver
    i32.const 0xD0  ;; Send message
    i32.const 0     ;; Selector index (0 = #squared in literal array)
    array.new $ByteArray
    local.set $mainBytecodes
    
    ;; Create bytecode sequence for SmallInteger>>squared
    ;; Bytecodes: push receiver, push receiver, multiply, return
    i32.const 4
    i32.const 0x70  ;; Push receiver (self)
    i32.const 0x70  ;; Push receiver (self) again
    i32.const 0xB8  ;; Multiply (pop two, push result)
    i32.const 0x7C  ;; Return top-of-stack
    array.new $ByteArray
    local.set $squaredBytecodes
    
    ;; Create main CompiledMethod (sends #squared to 3)
    local.get $objectClass ;; class (CompiledMethod is-a Object for now)
    i32.const 1001    ;; identityHash
    i32.const 12      ;; format (CompiledMethod)
    i32.const 11      ;; size
    ref.null $SqueakObject ;; nextObject
    ;; Create literal array containing the #squared selector
    i32.const 1
    local.get $squaredSelector
    array.new $ObjectArray ;; slots (literal array)
    i32.const 0       ;; header
    local.get $mainBytecodes
    i32.const 0       ;; invocationCount
    i32.const 0       ;; compiledFunc (none initially)
    i32.const 10      ;; jitThreshold
    struct.new $CompiledMethod
    local.set $mainMethod
    
    ;; Create SmallInteger>>squared method
    local.get $objectClass ;; class
    i32.const 1002    ;; identityHash
    i32.const 12      ;; format (CompiledMethod)
    i32.const 11      ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 6
    ref.null eq
    array.new $ObjectArray ;; slots
    i32.const 0       ;; header
    local.get $squaredBytecodes
    i32.const 0       ;; invocationCount
    i32.const 0       ;; compiledFunc (none initially)
    i32.const 10      ;; jitThreshold
    struct.new $CompiledMethod
    local.set $squaredMethod
    
    ;; Install #squared method in SmallInteger method dictionary
    local.get $methodDict
    struct.get $Dictionary $keys
    ref.as_non_null
    i32.const 0
    local.get $squaredSelector
    array.set $ObjectArray
    
    local.get $methodDict
    struct.get $Dictionary $values
    ref.as_non_null
    i32.const 0
    local.get $squaredMethod
    array.set $ObjectArray
    
    local.get $methodDict
    i32.const 1
    struct.set $Dictionary $count
    
    ;; Create execution stack with proper size
    i32.const 20
    ref.null eq
    array.new $ObjectArray
    local.set $stack
    
    ;; Create initial context for main method
    local.get $objectClass ;; class (Context is-a Object for now)
    i32.const 2001       ;; identityHash
    i32.const 14         ;; format (MethodContext)
    i32.const 14         ;; size
    ref.null $SqueakObject ;; nextObject
    i32.const 8
    ref.null eq
    array.new $ObjectArray ;; slots
    ref.null $Context    ;; sender
    i32.const 0          ;; pc
    i32.const 0          ;; sp (stack pointer)
    local.get $mainMethod ;; method
    local.get $receiver   ;; receiver (SmallInteger 3)
    ref.null $ObjectArray ;; args
    ref.null $ObjectArray ;; temps
    local.get $stack      ;; stack
    struct.new $Context
    local.set $mainContext
    
    ;; Set as active context
    local.get $mainContext
    global.set $activeContext
    
    i32.const 1  ;; success
  )

  ;; Interpret single bytecode - returns 1 if method should return, 0 to continue
  (func $interpretBytecode 
    (param $context (ref $Context))
    (param $bytecode i32) 
    (result i32)
    (local $receiver (ref null eq))
    (local $value1 (ref null eq))
    (local $value2 (ref null eq))
    (local $int1 i32)
    (local $int2 i32)
    (local $result i32)
    (local $newContext (ref $Context))
    (local $selector (ref null eq))
    (local $method (ref null $CompiledMethod))
    (local $receiverClass (ref null $Class))
    
    ;; Execute bytecode based on opcode
    local.get $bytecode
    i32.const 0x70  ;; Push receiver
    i32.eq
    if
      ;; Push receiver onto stack
      local.get $context
      struct.get $Context $receiver
      local.get $context
      swap
      call $pushOnStack
      i32.const 0  ;; Continue execution
      return
    end
    
    local.get $bytecode
    i32.const 0xB8  ;; Multiply (pop two, multiply, push result)
    i32.eq
    if
      ;; Pop two values from stack
      local.get $context
      call $popFromStack
      local.tee $value2
      ref.is_null
      if
        i32.const 0  ;; Continue if stack underflow
        return
      end
      
      local.get $context
      call $popFromStack
      local.tee $value1
      ref.is_null
      if
        ;; Push value2 back and continue
        local.get $context
        local.get $value2
        call $pushOnStack
        i32.const 0
        return
      end
      
      ;; Extract integer values
      local.get $value1
      call $extractIntegerValue
      local.set $int1
      
      local.get $value2
      call $extractIntegerValue
      local.set $int2
      
      ;; Multiply integers
      local.get $int1
      local.get $int2
      i32.mul
      local.set $result
      
      ;; Create result SmallInteger and push onto stack
      local.get $result
      call $createSmallInteger
      local.get $context
      swap
      call $pushOnStack
      
      i32.const 0  ;; Continue execution
      return
    end
    
    local.get $bytecode
    i32.const 0x7C  ;; Return top-of-stack
    i32.eq
    if
      ;; Return - top of stack is already the result
      i32.const 1  ;; Signal method return
      return
    end
    
    local.get $bytecode
    i32.const 0xD0  ;; Send message (generic for any selector)
    i32.eq
    if
      ;; Pop receiver from stack
      local.get $context
      call $popFromStack
      local.tee $receiver
      ref.is_null
      if
        i32.const 0
        return
      end
      
      ;; Decode selector from bytecode stream
      ;; Get current method and PC to read selector index
      local.get $context
      struct.get $Context $method
      ref.as_non_null
      struct.get $CompiledMethod $bytecodes
      ref.as_non_null
      
      local.get $context
      struct.get $Context $pc
      i32.const 1
      i32.add  ;; Next byte after 0xD0 is selector index
      array.get_u $ByteArray
      local.tee $int1  ;; Reuse local for selector index
      
      ;; Get selector from method's literal array at index
      local.get $context
      struct.get $Context $method
      ref.as_non_null
      struct.get $CompiledMethod $slots
      ref.as_non_null
      local.get $int1
      array.get $ObjectArray
      local.set $selector
      
      ;; Increment PC to skip selector index byte
      local.get $context
      local.get $context
      struct.get $Context $pc
      i32.const 1
      i32.add
      struct.set $Context $pc
      
      ;; Get receiver's class
      local.get $receiver
      call $getClass
      local.set $receiverClass
      
      ;; Try polymorphic inline cache first
      local.get $selector
      local.get $receiverClass
      call $lookupInCache
      local.tee $method
      ref.is_null
      if
        ;; Cache miss - do full method lookup
        local.get $receiver
        local.get $selector
        call $lookupMethod
        local.tee $method
        ref.is_null
        if
          ;; Method not found - push receiver back
          local.get $context
          local.get $receiver
          call $pushOnStack
          i32.const 0
          return
        end
        
        ;; Store in cache for future use
        local.get $selector
        local.get $receiverClass
        local.get $method
        ref.as_non_null
        call $storeInCache
      end
      
      ;; Create new context for method
      local.get $receiver
      local.get $method
      ref.as_non_null
      local.get $selector
      call $createMethodContext
      local.set $newContext
      
      ;; Switch to new context
      local.get $newContext
      global.set $activeContext
      
      i32.const 0  ;; Continue execution in new context
      return
    end
    
    ;; Unknown bytecode - continue execution
    i32.const 0
  )

  ;; Main interpreter loop - ONLY export this and initialize()
  (func $interpret (export "interpret") (result i32)
    (local $context (ref null $Context))
    (local $method (ref null $CompiledMethod))
    (local $bytecode i32)
    (local $pc i32)
    (local $resultValue (ref null eq))
    (local $invocationCount i32)
    (local $bytecodes (ref null $ByteArray))
    (local $bytecodeLength i32)
    (local $shouldReturn i32)
    (local $funcIndex i32)
    
    ;; Main execution loop - handle multiple method calls
    loop $execution_loop
      ;; Get active context
      global.get $activeContext
      local.tee $context
      ref.is_null
      if
        ;; No active context - execution complete
        br $execution_loop
      end
      
      ;; Cast to non-null and get method
      local.get $context
      ref.as_non_null
      struct.get $Context $method
      local.tee $method
      ref.is_null
      if
        ;; No method in context
        br $execution_loop
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
      
      ;; Check if method has compiled function
      local.get $method
      call $hasCompiledFunction
      if
        ;; Execute compiled WASM function
        local.get $method
        struct.get $CompiledMethod $compiledFunc
        local.set $funcIndex
        
        local.get $context
        ref.as_non_null
        local.get $funcIndex
        call $executeCompiledFunction
        drop  ;; Ignore return value
        
        ;; Handle return from compiled method
        local.get $context
        ref.as_non_null
        call $handleMethodReturn
        local.set $resultValue
        
        br $execution_loop
      else
        ;; Bytecode interpreter loop for current method
        local.get $method
        struct.get $CompiledMethod $bytecodes
        local.tee $bytecodes
        ref.is_null
        if
          br $execution_loop
        end
        
        ;; Get bytecode length for bounds checking
        local.get $bytecodes
        ref.as_non_null
        array.len
        local.set $bytecodeLength
        
        ;; Bytecode interpreter loop
        loop $interpreter_loop
          ;; Get current PC
          local.get $context
          ref.as_non_null
          struct.get $Context $pc
          local.tee $pc
          
          ;; Check if we've reached end of bytecodes
          local.get $pc
          local.get $bytecodeLength
          i32.ge_u
          if
            ;; End of method - handle return
            local.get $context
            ref.as_non_null
            call $handleMethodReturn
            local.set $resultValue
            br $interpreter_loop
          end
          
          ;; Fetch next bytecode
          local.get $bytecodes
          ref.as_non_null
          local.get $pc
          array.get_u $ByteArray
          local.set $bytecode
          
          ;; Interpret single bytecode
          local.get $context
          ref.as_non_null
          local.get $bytecode
          call $interpretBytecode
          local.set $shouldReturn
          
          ;; Check if method should return
          local.get $shouldReturn
          if
            ;; Method returned - handle return and switch contexts
            local.get $context
            ref.as_non_null
            call $handleMethodReturn
            local.set $resultValue
            br $interpreter_loop
          end
          
          ;; Check if context switched (for message sends)
          global.get $activeContext
          local.get $context
          ref.eq
          if
            ;; Same context - increment PC and continue
            local.get $context
            ref.as_non_null
            local.get $pc
            i32.const 1
            i32.add
            struct.set $Context $pc
          else
            ;; Context switched - break to outer loop
            br $interpreter_loop
          end
          
          br $interpreter_loop
        end
      end
      
      ;; Check if execution is complete
      global.get $activeContext
      ref.is_null
      if
        br $execution_loop
      end
      
      br $execution_loop
    end
    
    ;; Extract integer result for reporting
    local.get $resultValue
    call $extractIntegerValue
    local.tee $pc  ;; Reuse local for result
    
    ;; Report result to JavaScript
    local.get $pc
    call $reportResult
    
    local.get $pc
  )
)