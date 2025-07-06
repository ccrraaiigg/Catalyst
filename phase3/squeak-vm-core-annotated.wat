;; squeak-vm-core.wat - Core SqueakWASM Virtual Machine with JIT compilation

(module
 ;; Import external functions from JavaScript
 (import "env" "reportResult" (func $reportResult (param i32)))
 (import "env" "compileMethod" (func $compileMethod 
				     (param i32 i32 i32) (result i32))) ;; (method, bytecode, length) -> function
 (import "env" "debugLog" (func $debugLog (param i32 i32 i32))) ;; level, message, length

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

 ;; Global VM state

 ;; initializers
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
  
 ;; Array operations with proper typing
 (func $array_len_byte
       (param $array (ref $ByteArray))
       (result i32)
       local.get $array
       array.len
       ) ;; (func $array_len_byte
 
 (func $array_get_byte
       (param $array (ref $ByteArray))
       (param $index i32)
       (result i32)
       local.get $array
       local.get $index
       array.get_u $ByteArray
       ) ;; (func $array_get_byte
 
 (func $array_len_object
       (param $array (ref $ObjectArray))
       (result i32)
       local.get $array
       array.len
       ) ;; (func $array_len_object
 
 (func $array_get_object
       (param $array (ref $ObjectArray))
       (param $index i32)
       (result (ref null eq))
       local.get $array
       local.get $index
       array.get $ObjectArray
       ) ;; (func $array_get_object
 
 (func $is_small_integer
       (param $obj (ref null eq))
       (result i32)
       local.get $obj
       ref.test (ref i31)
       ) ;; (func $is_small_integer
 
 (func $get_small_integer_value
       (param $obj (ref null eq))
       (result i32)
       local.get $obj
       ref.cast (ref i31)
       i31.get_s
       ) ;; (func $get_small_integer_value
 
 ;; Memory management
 (func $nextIdentityHash (result i32)
       global.get $nextIdentityHash
       i32.const 1
       i32.add
       global.set $nextIdentityHash
       global.get $nextIdentityHash
       ) ;; (func $nextIdentityHash (result i32)

 ;; Stack operations
 (func $pushOnStack
       (param $context (ref $Context))
       (param $value eqref)
       (local $stack (ref null $ObjectArray))
       (local $sp i32)

       local.get $context
       struct.get $Context $stack
       local.tee $stack
       ref.is_null
       if
       return
       end ;; if

       local.get $context
       struct.get $Context $sp
       local.set $sp

       local.get $sp
       local.get $stack
       ref.as_non_null
       array.len
       i32.ge_u
       if
       return
       end ;; if

       local.get $stack
       ref.as_non_null
       local.get $sp
       local.get $value
       array.set $ObjectArray

       local.get $context
       local.get $sp
       i32.const 1
       i32.add
       struct.set $Context $sp
       return
       ) ;; (func $pushOnStack
 
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
       end ;; if
       
       local.get $context
       struct.get $Context $sp
       local.set $sp
       
       ;; Check empty stack
       local.get $sp
       i32.const 0
       i32.le_u
       if
         ref.null eq
         return
       end ;; if
       
       ;; Decrement stack pointer
       local.get $context
       local.get $sp
       i32.const 1
       i32.sub
       struct.set $Context $sp
       
       ;; Return top value
       local.get $stack
       ref.as_non_null
       local.get $sp
       i32.const 1
       i32.sub
       array.get $ObjectArray
       return
       ) ;; (func $popFromStack
 
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
       end ;; if
       
       local.get $context
       struct.get $Context $sp
       local.set $sp
       
       ;; Check empty stack
       local.get $sp
       i32.const 0
       i32.le_u
       if
       ref.null eq
       return
       end ;; if
       
       ;; Return top value without popping
       local.get $stack
       ref.as_non_null
       local.get $sp
       i32.const 1
       i32.sub
       array.get $ObjectArray
       return
       ) ;; (func $topOfStack

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
       end ;; else
       ) ;; if (result (ref null $Class))

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
       end ;; if
       
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
       end ;; if
       
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
       end ;; if
       
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
       end ;; if
       
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
       end ;; if
       
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
       ref.cast (ref $CompiledMethod)
       return
       end ;; if
       
       ;; Increment and continue
       local.get $i
       i32.const 1
       i32.add
       local.set $i
       br $search_loop
       end ;; loop $search_loop
       end ;; loop $hierarchy_loop
       
       ;; Should never reach here
       ref.null $CompiledMethod
       ) ;; (func $lookupMethod

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
       end ;; if
       
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
       end ;; if
       
       ;; Get cache entry
       local.get $cache
       ref.as_non_null
       local.get $index
       array.get $ObjectArray
       ref.cast (ref null $PICEntry)
       local.tee $entry
       ref.is_null
       if
       ;; Empty slot - cache miss
       ref.null $CompiledMethod
       return
       end ;; if
       
       ;; Check if entry matches
       local.get $entry
       ref.cast (ref $PICEntry)
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
       end ;; if
       
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
       end ;; loop $probe_loop
       
       ;; Should never reach here
       ref.null $CompiledMethod
       ) ;; (func $lookupInCache

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
       end ;; if
       
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
       ) ;; (func $storeInCache

 ;; Create context for method call
 (func $createMethodContext 
       (param $receiver (ref null eq))
       (param $method (ref $CompiledMethod))
       (param $selector (ref null eq))
       (result (ref $Context))
       (local $stack (ref $ObjectArray))
       
       ;; Create new stack for the method
       ref.null eq
       i32.const 20
       array.new $ObjectArray
       local.set $stack
       
       ;; Create context for method
       global.get $objectClass ;; class (Context is-a Object for now)
       call $nextIdentityHash
       i32.const 14         ;; format (MethodContext)
       i32.const 14         ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 8
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
       ) ;; (func $createMethodContext

 ;; SmallInteger operations
 (func $createSmallInteger (param $value i32) (result (ref i31))
       local.get $value
       ref.i31
       ) ;; (func $createSmallInteger (param $value i32) (result (ref i31))
 
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
       end ;; else
       ) ;; if (result i32)

 ;; Check if method has compiled function
 (func $hasCompiledFunction (param $method (ref $CompiledMethod)) (result i32)
       local.get $method
       struct.get $CompiledMethod $compiledFunc
       i32.const 0
       i32.ne
       ) ;; (func $hasCompiledFunction (param $method (ref $CompiledMethod)) (result i32)

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
       ) ;; (func $executeCompiledFunction

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
       end ;; if
       
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
       end ;; if
       ) ;; (func $triggerJITCompilation (param $method (ref $CompiledMethod))

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
       i32.eqz ;; not
       if
       ;; Push result onto sender's stack
       local.get $sender
       ref.as_non_null
       local.get $result
       ref.as_non_null
       call $pushOnStack
       
       ;; Increment sender's PC
       local.get $sender
       ref.as_non_null
       local.get $sender
       ref.as_non_null
       struct.get $Context $pc
       i32.const 1
       i32.add
       struct.set $Context $pc
       end ;; if
       
       ;; make the sender the active context again.
       local.get $sender
       ref.is_null
       if
       ref.null $Context
       global.set $activeContext
       else
       local.get $sender
       ref.as_non_null
       global.set $activeContext
       end ;; else
       
       local.get $result
       ) ;; if

 ;; VM initialization and bootstrap
 (func $initialize (export "initialize") (result i32)
       ;; Create minimal object memory for 3 squared example
       call $createMinimalBootstrap
       ) ;; (func $initialize (export "initialize") (result i32)

 ;; Create minimal bootstrap environment for 3 squared
 (func $createMinimalBootstrap (result i32)
       (local $mainMethod (ref $CompiledMethod))
       (local $squaredMethod (ref $CompiledMethod))
       (local $mainContext (ref $Context))
       (local $mainBytecodes (ref $ByteArray))
       (local $squaredBytecodes (ref $ByteArray))
       (local $stack (ref $ObjectArray))
       (local $receiver (ref i31))
       (local $methodDict (ref $Dictionary))
       
       ;; Initialize method cache
       ref.null eq
       global.get $methodCacheSize
       array.new $ObjectArray
       global.set $methodCache
       
       ;; Create Class class first (bootstrap issue)
       ref.null $Class     ;; class (will be set to itself)
       call $nextIdentityHash
       i32.const 1         ;; format (regular object)
       i32.const 11        ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 6
       array.new $ObjectArray ;; slots
       ref.null $Class     ;; superclass
       ref.null $Dictionary ;; methodDict
       ref.null $SqueakObject ;; instVarNames
       ref.null $Symbol    ;; name
       i32.const 0         ;; instSize
       struct.new $Class
       global.set $classClass
       
       ;; Set Class class to itself (bootstrap)
       global.get $classClass
       global.get $classClass
       struct.set $Class $class
       
       ;; Create Object class
       global.get $classClass ;; class
       call $nextIdentityHash
       i32.const 1         ;; format
       i32.const 11        ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 6
       array.new $ObjectArray ;; slots
       ref.null $Class     ;; superclass (nil for Object)
       ref.null $Dictionary ;; methodDict
       ref.null $SqueakObject ;; instVarNames
       ref.null $Symbol    ;; name
       i32.const 0         ;; instSize
       struct.new $Class
       global.set $objectClass
       
       ;; Create SmallInteger class
       global.get $classClass ;; class
       call $nextIdentityHash
       i32.const 1         ;; format
       i32.const 11        ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 6
       array.new $ObjectArray ;; slots
       global.get $objectClass ;; superclass (Object)
       ref.null $Dictionary ;; methodDict (will be created)
       ref.null $SqueakObject ;; instVarNames
       ref.null $Symbol    ;; name
       i32.const 0         ;; instSize
       struct.new $Class
       global.set $smallIntegerClass

       ;; Create method dictionary for SmallInteger
       global.get $objectClass ;; class (Dictionary is-a Object for now)
       call $nextIdentityHash
       i32.const 2         ;; format (variable object)
       i32.const 9         ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 2
       array.new $ObjectArray ;; slots
       ref.null eq
       i32.const 2
       array.new $ObjectArray ;; keys
       ref.null eq
       i32.const 2
       array.new $ObjectArray ;; values
       i32.const 0         ;; count
       struct.new $Dictionary
       local.set $methodDict
       
       ;; Install method dictionary in SmallInteger class
       global.get $smallIntegerClass
       local.get $methodDict
       struct.set $Class $methodDict
       
       ;; Create #squared selector symbol
       global.get $objectClass ;; class (Symbol is-a Object for now)
       call $nextIdentityHash
       i32.const 8         ;; format (byte object)
       i32.const 7         ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 1
       array.new $ObjectArray ;; slots
       i32.const 115 ;; 's'
       i32.const 113 ;; 'q'
       i32.const 117 ;; 'u'
       i32.const 97  ;; 'a'
       i32.const 114 ;; 'r'
       i32.const 101 ;; 'e'
       i32.const 100 ;; 'd'
       array.new_fixed $ByteArray 7 ;; "squared"
       struct.new $Symbol
       global.set $squaredSelector
       
       ;; Create SmallInteger 3 as receiver
       i32.const 3
       ref.i31
       local.set $receiver
       
       ;; Create bytecode sequence for main method: "3 squared"
       ;; Bytecodes: push receiver (3), send #squared (selector index 0)
       i32.const 0x70  ;; Push receiver
       i32.const 0xD0  ;; Send message
       i32.const 0x7C  ;; Return top of stack
       array.new_fixed $ByteArray 3
       local.set $mainBytecodes
       
       ;; Create bytecode sequence for SmallInteger>>squared
       ;; Bytecodes: push receiver, push receiver, multiply, return
       i32.const 0x70  ;; Push receiver (self)
       i32.const 0x70  ;; Push receiver (self) again
       i32.const 0xB8  ;; Multiply (pop two, push result)
       i32.const 0x7C  ;; Return top-of-stack
       array.new_fixed $ByteArray 4
       local.set $squaredBytecodes
       
       ;; Create main CompiledMethod (sends #squared to 3)
       global.get $objectClass ;; class (CompiledMethod is-a Object for now)
       i32.const 1001    ;; identityHash
       i32.const 12      ;; format (CompiledMethod)
       i32.const 11      ;; size
       ref.null $SqueakObject ;; nextObject
       ;; Create literal array containing the #squared selector
       global.get $squaredSelector
       array.new_fixed $ObjectArray 1 ;; slots (literal array)
       i32.const 0       ;; header
       local.get $mainBytecodes
       i32.const 0       ;; invocationCount
       i32.const 0       ;; compiledFunc (none initially)
       i32.const 10      ;; jitThreshold
       struct.new $CompiledMethod
       local.set $mainMethod
       
       ;; Create SmallInteger>>squared method
       global.get $objectClass ;; class
       i32.const 1002    ;; identityHash
       i32.const 12      ;; format (CompiledMethod)
       i32.const 11      ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 6
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
       global.get $squaredSelector
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
       ref.null eq
       i32.const 20
       array.new $ObjectArray
       local.set $stack
       
       ;; Create initial context for main method
       global.get $objectClass ;; class (Context is-a Object for now)
       i32.const 2001       ;; identityHash
       i32.const 14         ;; format (MethodContext)
       i32.const 14         ;; size
       ref.null $SqueakObject ;; nextObject
       ref.null eq
       i32.const 8
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

       ;; success
       i32.const 1
       ) ;; (func $createMinimalBootstrap (result i32)

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
       (local $selectorIndex i32)
       
       ;; Execute bytecode based on opcode
       local.get $bytecode
       i32.const 0x70  ;; Push receiver
       i32.eq
       if
       ;; Push receiver onto stack
       local.get $context
       local.get $context
       struct.get $Context $receiver
       ref.as_non_null
       call $pushOnStack
       i32.const 0  ;; Continue execution
       return
       end ;; if
       
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
       end ;; if
       
       local.get $context
       call $popFromStack
       local.tee $value1
       ref.is_null
       if
       ;; Push value2 back and continue
       local.get $context
       local.get $value2
       ref.as_non_null
       call $pushOnStack
       i32.const 0
       return
       end ;; if
       
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
       local.get $context
       local.get $result
       call $createSmallInteger
       ref.as_non_null
       call $pushOnStack
       
       i32.const 0  ;; Continue execution
       return
       end ;; if
       
       local.get $bytecode
       i32.const 0x7C  ;; Return top-of-stack
       i32.eq
       if
       ;; Return - top of stack is already the result
       i32.const 1  ;; Signal method return
       return
       end ;; if
       
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
       end ;; if
       
       ;; Extract selector index from low 4 bits of bytecode
       local.get $bytecode
       i32.const 0x0F  ;; Mask for low 4 bits
       i32.and
       local.set $selectorIndex  ;; Use meaningful name instead of reusing $int1
       
       ;; Get selector from method's literal array at index
       local.get $context
       struct.get $Context $method
       ref.as_non_null
       struct.get $CompiledMethod $slots
       ref.as_non_null
       local.get $selectorIndex
       array.get $ObjectArray
       local.set $selector
       
       ;; No need to increment PC since we're not reading next byte
       
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
       ref.as_non_null
       call $pushOnStack
       i32.const 0
       return
       end ;; if
       
       ;; Store in cache for future use
       local.get $selector
       local.get $receiverClass
       local.get $method
       ref.as_non_null
       call $storeInCache
       end ;; if
       
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
       end ;; if
       
       ;; Unknown bytecode - continue execution
       i32.const 0
       ) ;; (func $interpretBytecode

 ;; Main interpreter loop
 (func $interpret (export "interpret") (result i32)
       (local $context (ref null $Context))
       (local $method (ref null $CompiledMethod))
       (local $bytecode i32)
       (local $pc i32)
       (local $resultValue (ref null eq))
       (local $invocationCount i32)
       (local $bytecodes (ref null $ByteArray))
       (local $funcIndex i32)
       
       ;; Main execution loop
       loop $execution_loop ;; 1
       ;; Get active context
       global.get $activeContext
       local.tee $context
       ref.is_null
       if
       ;; No active context - execution complete
       br $execution_loop
       end ;; if
       
       ;; Cast to non-null and get method
       local.get $context
       ref.as_non_null
       struct.get $Context $method
       local.tee $method
       ref.is_null
       if
       ;; No method in context
       br $execution_loop
       end ;; if
       
       ;; Get method and check for JIT compilation
       local.get $method
       ref.as_non_null
       local.set $method
       
       ;; Increment invocation count
       local.get $method
       struct.get $CompiledMethod $invocationCount
       i32.const 1
       i32.add
       local.set $invocationCount
       
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
       ref.as_non_null
       call $triggerJITCompilation
       end ;; if
       
       ;; Check if method has compiled function
       local.get $method
       ref.as_non_null
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
       end ;; if
       
       ;; Bytecode interpreter loop
       loop $interpreter_loop
       ;; Get current PC
       global.get $activeContext
       local.tee $context
       ref.is_null
       i32.eqz
       if
       local.get $context
       ref.as_non_null
       struct.get $Context $pc
       local.set $pc

       local.get $context
       ref.as_non_null
       struct.get $Context $method
       local.tee $method
       struct.get $CompiledMethod $bytecodes
       local.tee $bytecodes
       ref.as_non_null
       array.len
       
       ;; Check if we've reached end of bytecodes
       local.get $pc
       i32.le_u
       if
       ;; End of method - handle return
       local.get $context
       ref.as_non_null
       call $handleMethodReturn
       local.set $resultValue
       br $interpreter_loop
       end ;; if
       
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
       
       ;; Check if method should return
       if
       ;; Method returned - handle return and switch contexts
       local.get $context
       ref.as_non_null
       call $handleMethodReturn
       local.set $resultValue
       br $interpreter_loop
       end ;; if
       
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
       end ;; if
       
       br $interpreter_loop ;; default - restart interpreter loop
       end ;; if
       end ;; loop $interpreter_loop
       end ;; else
      
       br $execution_loop ;; default - restart execution loop
       end ;; if
       
       ;; Extract integer result for reporting
       local.get $resultValue
       call $extractIntegerValue
       
       ;; Report result to JavaScript
       call $reportResult
       
       i32.const 1 ;; success
       return
       ) ;; loop $execution_loop
 ) ;; (func $interpret (export "interpret") (result i32)
