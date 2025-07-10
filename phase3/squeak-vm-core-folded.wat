;; squeak-vm-core.wat: multiple simultaneous SqueakWASM virtual
;; machines with method translation

(module
 ;; imported external functions from JS
 (import "env" "reportResult" (func $reportResult (param i32)))

 ;; method, class, selector; JS installs translated function
 (import "env" "translateMethod" (func $translateMethod (param eqref) (param eqref) (param eqref)))

 ;; level, message, length
 (import "env" "debugLog" (func $debugLog (param i32 i32 i32)))

 (rec ;; recursive (mutually referential) type definitions
  ;; type 0: ObjectArray - can hold both objects and i31ref SmallIntegers
  (type $ObjectArray (array (mut (ref null eq))))
  
  ;; type 1: ByteArray 
  (type $ByteArray (array (mut i8)))
  
  ;; type 2: Base Squeak object
  (type $SqueakObject (sub (struct 
			    (field $class (mut (ref null $Class)))
			    (field $identityHash (mut i32))
			    (field $format (mut i32))
			    (field $size (mut i32))
			    (field $nextObject (mut (ref null $SqueakObject)))
			    )))
  
  ;; type 3: Variable objects with named fields
  (type $VariableObject (sub $SqueakObject (struct
					    (field $class (mut (ref null $Class)))
					    (field $identityHash (mut i32))
					    (field $format (mut i32))
					    (field $size (mut i32))
					    (field $nextObject (mut (ref null $SqueakObject)))
					    (field $slots (mut (ref $ObjectArray)))
					    )))
  
  ;; type 4: Symbol objects for method selectors with named fields
  (type $Symbol (sub $VariableObject (struct
				      (field $class (mut (ref null $Class)))
				      (field $identityHash (mut i32))
				      (field $format (mut i32))
				      (field $size (mut i32))
				      (field $nextObject (mut (ref null $SqueakObject)))
				      (field $slots (mut (ref $ObjectArray)))
				      (field $bytes (ref null $ByteArray))
				      )))
  
  ;; type 5: Class objects with named fields
  (type $Class (sub $VariableObject (struct
				     (field $class (mut (ref null $Class)))
				     (field $identityHash (mut i32))
				     (field $format (mut i32))
				     (field $size (mut i32))
				     (field $nextObject (mut (ref null $SqueakObject)))
				     (field $slots (mut (ref $ObjectArray)))
				     (field $superclass (mut (ref null $Class)))
				     (field $methodDictionary (mut (ref $Dictionary)))
				     (field $instanceVariableNames (mut (ref $ObjectArray)))
				     (field $name (mut (ref $Symbol)))
				     (field $instanceSize (mut i32))
				     )))
  
  ;; type 6: Dictionary for method lookup with named fields
  (type $Dictionary (sub $VariableObject (struct
					  (field $class (mut (ref null $Class)))
					  (field $identityHash (mut i32))
					  (field $format (mut i32))
					  (field $size (mut i32))
					  (field $nextObject (mut (ref null $SqueakObject)))
					  (field $slots (mut (ref $ObjectArray)))
					  (field $keys (ref $ObjectArray))
					  (field $values (ref $ObjectArray))
					  (field $count (mut i32))
					  )))
  
  ;; type 7: CompiledMethod with JIT compilation support and named fields
  (type $CompiledMethod (sub $VariableObject (struct
					      (field $class (mut (ref null $Class)))
					      (field $identityHash (mut i32))
					      (field $format (mut i32))
					      (field $size (mut i32))
					      (field $nextObject (mut (ref null $SqueakObject)))
					      (field $slots (mut (ref $ObjectArray)))
					      (field $header i32)
					      (field $bytecodes (ref null $ByteArray))
					      (field $invocationCount (mut i32))
					      ;; Index into function table
					      (field $functionIndex (mut i32))  
					      (field $translationThreshold i32)
					      ;; 0 = not installed, 1 = installed
					      (field $isInstalled (mut i32))   
					      )))
  
  ;; type 8: Context objects for execution state with named fields
  (type $Context (sub $VariableObject (struct
				       (field $class (mut (ref null $Class)))
				       (field $identityHash (mut i32))
				       (field $format (mut i32))
				       (field $size (mut i32))
				       (field $nextObject (mut (ref null $SqueakObject)))
				       (field $slots (mut (ref $ObjectArray)))
				       (field $sender (mut (ref null $Context)))
				       (field $pc (mut i32))
				       (field $sp (mut i32))
				       (field $method (mut (ref null $CompiledMethod)))
				       (field $receiver (mut (ref null eq)))
				       (field $args (mut (ref $ObjectArray)))
				       (field $temps (mut (ref $ObjectArray)))
				       (field $stack (mut (ref $ObjectArray)))
				       )))
  
  ;; type 9: Polymorphic Inline Cache entry
  (type $PICEntry (struct
                   (field $selector (mut (ref null eq)))
                   (field $receiverClass (mut (ref null $Class)))
                   (field $method (mut (ref null $CompiledMethod)))
                   (field $hitCount (mut i32))
                   ))
  
  ;; type 10: JIT function type
  (type $jit_func_type (func (param eqref) (result i32)))

  ;; type 11: virtual machine
  (type $VirtualMachine (struct
			 (field $activeContext (mut (ref $Context)))
			 (field $jitEnabled (mut i32))
			 (field $methodCache (mut (ref $ObjectArray)))
			 (field $functionTableBaseIndex (mut i32))

			 ;; object memory management
			 (field $nextIdentityHash (mut i32))
			 (field $firstObject (mut (ref $SqueakObject)))
			 (field $lastObject (mut (ref $SqueakObject))))))

 ;; global VM state
 ;;
 ;; NOTE: Globals are nullable due to current WASM limitations, but
 ;; are enforced to be non-null after initialization at runtime.

 ;; initializers
 (global $objectClass (mut (ref null $Class)) (ref.null $Class))
 (global $classClass (mut (ref null $Class)) (ref.null $Class))
 (global $methodClass (mut (ref null $Class)) (ref.null $Class))
 (global $contextClass (mut (ref null $Class)) (ref.null $Class))
 (global $symbolClass (mut (ref null $Class)) (ref.null $Class))
 (global $smallIntegerClass (mut (ref null $Class)) (ref.null $Class))
 (global $mainMethod (mut (ref null $CompiledMethod)) (ref.null $CompiledMethod))
 
 ;; essential objects
 (global $nilObject (mut (ref null eq)) (ref.null eq))
 (global $trueObject (mut (ref null eq)) (ref.null eq))
 (global $falseObject (mut (ref null eq)) (ref.null eq))
 
 ;; special selectors for quick sends
 (global $workloadSelector (mut (ref null eq)) (ref.null eq))
 
 ;; method translation globals and method lookup cache
 ;; default translation threshold; each method can have its own
 (global $translationThreshold (mut i32) (i32.const 1000))
 (global $methodCacheSize (mut i32) (i32.const 256))

 ;; translated methods function table
 (table $functionTable (export "functionTable") 100 funcref)

 ;; linear memory for staging bytes as return values to JS. See $copyByteArrayToMemory
 (memory (export "memory") 1)
 
 ;; exported utilities for method translation in JS
 (func (export "compiledMethodBytecodes")
       (param $vm (ref $VirtualMachine))
       (param (ref null $CompiledMethod))
       (result (ref null $ByteArray))
       
       (local.get 0)
       (struct.get $CompiledMethod $bytecodes))

 (func (export "methodWithID")
       (param $vm (ref $VirtualMachine))
       (param i32)
       (result (ref null $CompiledMethod))

       (local $targetHash i32)
       (local $currentObject (ref null $SqueakObject))
       (local $currentHash i32)
       
       (local.set $targetHash ;; Stack: [] (local.get 0 ;; Stack: [id]))
       
       ;; Start with first object
       (local.get $vm)
       (local.set $currentObject ;; Stack: [] 
         (struct.get $VirtualMachine $firstObject ;; Stack: [firstObject]))
       
       ;; Traverse object chain
       search_loop
         local.get $currentObject ;; Stack: [currentObject]
         ref.is_null              ;; Stack: [isNull]
         if                       ;; Stack: []
         ;; Reached end of object list - method not found
         ref.null $CompiledMethod ;; Stack: [null]
         return                 ;; Stack: []
         end ;; if
         
         ;; Get identity hash of current object
         (ref.as_non_null ;; Stack: [currentObject 
           (non-null)] 
           (local.get $currentObject ;; Stack: [currentObject]))
         (local.set $currentHash ;; Stack: [] 
           (struct.get $SqueakObject $identityHash ;; Stack: [identityHash]))
         
         ;; Check if this is the method we're looking for
         (i32.eq ;; Stack: [isEq] 
           (local.get $currentHash ;; Stack: [currentHash]) 
           (local.get $targetHash ;; Stack: [currentHash, targetHash]))
         if                      ;; Stack: []
         ;; Found it! Cast to CompiledMethod and return
         local.get $currentObject ;; Stack: [currentObject]
         ref.cast (ref $CompiledMethod) ;; Stack: [compiledMethod]
         return               ;; Stack: []
         end ;; if
         
         ;; Move to next object
         (ref.as_non_null ;; Stack: [currentObject 
           (non-null)] 
           (local.get $currentObject ;; Stack: [currentObject]))
         (local.set $currentObject ;; Stack: [] 
           (struct.get $SqueakObject $nextObject ;; Stack: [nextObject]))
         
         br $search_loop          ;; Stack: []
       )
       
       ref.null $CompiledMethod   ;; Stack: [null]
       )
 
 (func (export "setMethodFunctionIndex")
       (param (ref null $CompiledMethod))
       (param i32)
       
       (struct.set $CompiledMethod $functionIndex 
         (local.get 0) 
         (local.get 1))
       ) 

 (func (export "onContextPush")
       (param $context eqref)
       (param $value eqref)
       
       local.get $context
       ref.cast (ref null $Context)
       (local.get $value)
       (call $pushOnStack))
 
 (func (export "popFromContext")
       (param $context eqref)
       ((result eqref))
       (local.get $context)
       (ref.cast (ref null $Context))
       (call $popFromStack))
 
 (func (export "valueOfSmallInteger")
       (param $obj (ref null eq))
       (result i32)
       
       (local.get $obj)
       (call $valueOfSmallInteger))
 
 (func (export "smallIntegerForValue")
       (param $value i32)
       (result eqref)
       
       (local.get $value)
       (call $smallIntegerForValue))
 
 (func (export "classOfObject")
       (param $obj eqref)
       (result eqref)
       
       (local.get $obj)
       (call $classOfObject))
 
 (func (export "lookupInCache")
       (param $selector eqref)
       (param $receiverClass eqref)
       (result eqref)
       ((local.get $selector))
       ((local.get $receiverClass))
       (ref.cast (ref null $Class))
       (call $lookupInCache))
 
 (func (export "lookupMethod") (param $receiver eqref) (param $selector eqref) (result eqref)
       (local.get $receiver)
       (local.get $selector)
       (call $lookupMethod))
 
 (func (export "storeInCache") (param $selector eqref) (param $receiverClass eqref) (param $method eqref)
       local.get $method
       ref.cast (ref null $CompiledMethod)
       ref.is_null
             (then
           return
         )
       )
       (local.get $selector)
       (local.get $receiverClass)
       ref.cast (ref null $Class)
       local.get $method
       ref.cast (ref null $CompiledMethod)
       (ref.as_non_null)
       (call $storeInCache))
 
 (func (export "createMethodContext") (param $receiver eqref) (param $method eqref) (param $selector eqref) (result eqref)
       local.get $method
       ref.cast (ref null $CompiledMethod)
       ref.is_null
             (then
           ref.null $Context
           return
         )
       )
       (local.get $receiver)
       (local.get $method)
       ref.cast (ref null $CompiledMethod)
       (ref.as_non_null)
       (local.get $selector)
       (call $createMethodContext))
 
 (func (export "interpretBytecode") (param $context eqref) (param $bytecode i32) (result i32)
       local.get $context
       ref.cast (ref null $Context)
       (local.get $bytecode)
       (call $interpretBytecode))
 
 (func (export "getActiveContext") (param $vm eqref) (result eqref)
       (local.get $vm)
       (struct.get $VirtualMachine $activeContext))
 
 (func (export "getContextReceiver") (param $context eqref) (result eqref)
       local.get $context
       ref.cast (ref null $Context)
       struct.get $Context $receiver)

 (func (export "getCompiledMethodSlots") (param $method eqref) (result eqref)
       local.get $method
       ref.cast (ref $CompiledMethod)
       struct.get $CompiledMethod $slots)

 (func $contextLiteralAt
       (param $context (ref $Context))
       (param $index i32)
       (result eqref)

       local.get $context
       ref.cast (ref null $Context)
       (struct.get $Context $method)
       (struct.get $CompiledMethod $slots)
       ref.cast (ref null $ObjectArray)
       (local.get $index)
       (call $objectArrayAt))
 
 (func (export "getContextLiteral") (param $context eqref) (param $index i32) (result eqref)
       local.get $context
       ref.cast (ref $Context)
       (local.get $index)
       (call $contextLiteralAt))

 (func (export "getContextMethod") (param $context eqref) (result eqref)
       local.get $context
       ref.cast (ref null $Context)
       struct.get $Context $method)
 
 (func (export "objectArrayAt") (param $array eqref) (param $index i32) (result eqref)
       local.get $array
       ref.cast (ref null $ObjectArray)
       (local.get $index)
       (call $objectArrayAt))
 ((func (export "getObjectArrayLength") (param $array eqref) (result i32))
 (local.get $array)
 (ref.cast (ref null $ObjectArray))
 (call $array_len_object))

 (global $byteArrayCopyPtr (mut i32) (i32.const 1024)) ;; Start of copy buffer

 (func (export "copyByteArrayToMemory") (param (ref null $ByteArray)) (result i32)
       (local $len i32)
       (local $i i32)
       local.get 0
       ref.is_null
             (then
           i32.const 0
           return
         )
       )
       (ref.as_non_null (local.get 0))
       array.len
       (local.set $len)
       (local.set $i (i32.const 0))
       copy
         (local.get $i)
         (local.get $len)
         i32.ge_u
         if
         global.get $byteArrayCopyPtr
         return
         end
         (i32.add (global.get $byteArrayCopyPtr) (local.get $i))
         (ref.as_non_null (local.get 0))
         (local.get $i)
         (array.get_u $ByteArray)
         i32.store8
         (local.set $i (i32.add (local.get $i) (i32.const 1)))
         br $copy
       )
       i32.const 0
       )

 (func (export "getByteArrayLen") (param (ref null $ByteArray)) (result i32)
       local.get 0
       ref.is_null
             (then
           i32.const 0
           return
         )
       )
       (ref.as_non_null (local.get 0))
       array.len)

 ;; Array operations with proper typing
 (func $array_len_byte
       (param $array (ref null $ByteArray))
       (result i32)
       local.get $array
       ref.is_null
             (then
           i32.const 0
           return
         )
       )
       (ref.as_non_null (local.get $array))
       array.len
       ) ;; (func $array_len_byte
 
 (func $array_get_byte
       (param $array (ref null $ByteArray))
       (param $index i32)
       (result i32)
       (local $length i32)
       
       ;; Check for null array
       local.get $array
       ref.is_null
             (then
           i32.const 0
           return
         )
       )
       
       ;; Get array length
       (ref.as_non_null (local.get $array))
       array.len
       local.set $length
       
       ;; Check bounds
       (i32.lt_s (local.get $index) (i32.const 0))
             (then
           i32.const 0
           return
         )
       )
       
       (local.get $index)
       (local.get $length)
       i32.ge_u
             (then
           i32.const 0
           return
         )
       )
       
       ;; Safe to access array
       (local.get $array)
       (local.get $index)
       (array.get_u $ByteArray)
       ) ;; (func $array_get_byte

 ;; Array operations with proper typing
 (func $array_len_object
       (param $array (ref null $ObjectArray))
       (result i32)
       local.get $array
       ref.is_null
             (then
           i32.const 0
           return
         )
       )
       (ref.as_non_null (local.get $array))
       array.len
       ) ;; (func $array_len_object
 
 (func $objectArrayAt
       (param $array (ref null $ObjectArray))
       (param $index i32)
       (result (ref null eq))
       (local $length i32)
       
       ;; Check for null array
       local.get $array
       ref.is_null
             (then
           ref.null eq
           return
         )
       )
       
       ;; Get array length
       (ref.as_non_null (local.get $array))
       array.len
       local.set $length
       
       ;; Check bounds
       (i32.lt_s (local.get $index) (i32.const 0))
             (then
           ref.null eq
           return
         )
       )
       
       (local.get $index)
       (local.get $length)
       i32.ge_u
             (then
           ref.null eq
           return
         )
       )
       
       ;; Safe to access array
       (local.get $array)
       (local.get $index)
       (array.get $ObjectArray)
       ) ;; (func $objectArrayAt
 
 (func $isSmallInteger
       (param $obj (ref null eq))
       (result i32)
       local.get $obj
       ref.test (ref i31)
       ) ;; (func $isSmallInteger
 
 (func $smallIntegerValue
       (param $obj (ref null eq))
       (result i32)
       local.get $obj
       ref.cast (ref i31)
       i31.get_s
       ) ;; (func $smallIntegerValue

 ;; Memory management
 (func $nextIdentityHash (param $vm (ref $VirtualMachine)) (result i32)
       (local.get $vm)
       (struct.set $VirtualMachine $nextIdentityHash 
         (i32.add 
           (struct.get $VirtualMachine $nextIdentityHash) 
           (i32.const 1)) 
         (local.get $vm))
       (local.get $vm)
       (struct.get $VirtualMachine $nextIdentityHash)
       ) ;; (func $nextIdentityHash (result i32)

 ;; Stack operations
 (func $pushOnStack
       (param $context (ref null $Context))
       (param $value eqref)
       (local $stack (ref $ObjectArray))
       (local $sp i32)

       (local.get $context)
       (local.set $stack 
         (struct.get $Context $stack))

       (local.get $context)
       (local.set $sp 
         (struct.get $Context $sp))

       (local.get $sp)
       (local.get $stack)
       array.len
       i32.ge_u
             (then
           return
         )
       )

       (array.set $ObjectArray (local.get $stack) (local.get $sp) (local.get $value))

       (struct.set $Context $sp 
         (local.get $context) 
         (i32.add 
           (local.get $sp) 
           (i32.const 1)))
       return
       ) ;; (func $pushOnStack
 
 (func $popFromStack
       (param $context (ref null $Context))
       (result (ref null eq))
       (local $stack (ref $ObjectArray))
       (local $sp i32)
       
       ;; Get stack and stack pointer
       (local.get $context)
       (local.set $stack 
         (struct.get $Context $stack))
       
       (local.get $context)
       (local.set $sp 
         (struct.get $Context $sp))
       
       ;; Check empty stack
       (local.get $sp)
       (i32.const 0)
       i32.le_u
             (then
           ref.null eq
           return
         )
       )
       
       ;; Decrement stack pointer
       (struct.set $Context $sp 
         (local.get $context) 
         (i32.sub 
           (local.get $sp) 
           (i32.const 1)))
       
       ;; Return top value
       (local.get $stack)
       (i32.sub (local.get $sp) (i32.const 1))
       (array.get $ObjectArray)
       return
       ) ;; (func $popFromStack
 
 (func $topOfStack
       (param $context (ref null $Context))
       (result (ref null eq))
       (local $stack (ref $ObjectArray))
       (local $sp i32)
       
       ;; Get stack and stack pointer
       (local.get $context)
       (local.set $stack 
         (struct.get $Context $stack))
       
       (local.get $context)
       (local.set $sp 
         (struct.get $Context $sp))
       
       ;; Check empty stack
       (local.get $sp)
       (i32.const 0)
       i32.le_u
             (then
           ref.null eq
           return
         )
       )
       
       ;; Return top value without popping
       (local.get $stack)
       (i32.sub (local.get $sp) (i32.const 1))
       (array.get $ObjectArray)
       return
       ) ;; (func $topOfStack

 ;; Get class of any object (including SmallIntegers)
 (func $classOfObject (param $obj (ref null eq)) (result (ref null $Class))
       local.get $obj
       ref.test (ref i31)
       sult (ref null $Class))
         (then
           ;; SmallInteger
           global.get $smallIntegerClass
         )
         (else
           ;; Regular object
           local.get $obj
           ref.cast (ref $SqueakObject)
           struct.get $SqueakObject $class
         )
       )
       ) ;; if (result (ref null $Class))

 (func $lookupMethod 
       (param $receiver (ref null eq))
       (param $selector (ref null eq))
       (result (ref null $CompiledMethod))
       (local $class (ref null $Class))
       (local $currentClass (ref null $Class))
       (local $methodDictionary (ref null $Dictionary))
       (local $keys (ref null $ObjectArray))
       (local $values (ref null $ObjectArray))
       (local $count i32)
       (local $i i32)
       (local $key (ref null eq))
       
       ;; Get receiver's class
       (local.get $receiver)
       (local.set $currentClass 
         (call $classOfObject))
       
       ;; Walk up the class hierarchy
       hierarchy_loop
         local.get $currentClass
         ref.is_null
         if
         ;; Reached top of hierarchy - method not found
         ref.null $CompiledMethod
         return
         end ;; if
         
         ;; Get method dictionary from current class
         (ref.as_non_null (local.get $currentClass))
         (local.tee $methodDictionary 
           (struct.get $Class $methodDictionary))
         ref.is_null
         if
         ;; No method dictionary - try superclass
         (ref.as_non_null (local.get $currentClass))
         (local.set $currentClass 
           (struct.get $Class $superclass))
         br $hierarchy_loop
         end ;; if
         
         ;; Search in current class's method dictionary
         (ref.as_non_null (local.get $methodDictionary))
         (local.tee $keys 
           (struct.get $Dictionary $keys))
         ref.is_null
         if
         ;; No keys - try superclass
         (ref.as_non_null (local.get $currentClass))
         (local.set $currentClass 
           (struct.get $Class $superclass))
         br $hierarchy_loop
         end ;; if
         
         (ref.as_non_null (local.get $methodDictionary))
         (local.tee $values 
           (struct.get $Dictionary $values))
         ref.is_null
         if
         ;; No values - try superclass
         (ref.as_non_null (local.get $currentClass))
         (local.set $currentClass 
           (struct.get $Class $superclass))
         br $hierarchy_loop
         end ;; if
         
         ;; Get count
         (ref.as_non_null (local.get $methodDictionary))
         (local.set $count 
           (struct.get $Dictionary $count))
         
         ;; Linear search for selector in current class
         (local.set $i (i32.const 0))
         
         loop $search_loop
         (local.get $i)
         (local.get $count)
         i32.ge_u
         if
         ;; Not found in this class - try superclass
         (ref.as_non_null (local.get $currentClass))
         (local.set $currentClass 
           (struct.get $Class $superclass))
         br $hierarchy_loop
         end ;; if
         
         ;; Get key at index i
         (ref.as_non_null (local.get $keys))
         (local.get $i)
         (local.set $key (array.get $ObjectArray))
         
         ;; Compare with selector
         (ref.eq (local.get $key) (local.get $selector))
         if
         ;; Found! Get the method
         (ref.as_non_null (local.get $values))
         (local.get $i)
         (array.get $ObjectArray)
         ref.cast (ref $CompiledMethod)
         return
         end ;; if
         
         ;; Increment and continue
         (local.set $i (i32.add (local.get $i) (i32.const 1)))
         br $search_loop
         end ;; loop $search_loop
       )
       
       ref.null $CompiledMethod
       return
       )

 ;; Polymorphic Inline Cache lookup
 (func $lookupInCache
       (param $vm (ref $VirtualMachine))
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
       (local.get $vm)
       (local.tee $cache 
         (struct.get $VirtualMachine $methodCache))
       ref.is_null
             (then
           ref.null $CompiledMethod
           return
         )
       )
       
       ;; Simple hash function (identity hash of selector + class)
       local.get $selector
       ref.cast (ref $SqueakObject)
       struct.get $SqueakObject $identityHash
       
       (i32.add 
         (ref.as_non_null 
           (local.get $receiverClass)) 
         (struct.get $Class $identityHash))
       
       global.get $methodCacheSize
       i32.rem_u
       local.set $index
       
       ;; Linear probing with limit
       (local.set $probeLimit (i32.const 8 ;; Max probe distance))
       
       probe_loop
         (i32.le_s (local.get $probeLimit) (i32.const 0))
         if
         ;; Probe limit exceeded
         ref.null $CompiledMethod
         return
         end ;; if
         
         ;; Get cache entry
         (ref.as_non_null (local.get $cache))
         (local.get $index)
         (array.get $ObjectArray)
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
         (local.tee $entry)
         (ref.eq 
           (struct.get $PICEntry $selector) 
           (local.get $selector))
         
         (local.get $entry)
         (ref.eq 
           (struct.get $PICEntry $receiverClass) 
           (local.get $receiverClass))
         i32.and
         if
         ;; Cache hit - increment hit count and return method
         (local.get $entry)
         (struct.set $PICEntry $hitCount 
           (local.get $entry) 
           (i32.add 
             (struct.get $PICEntry $hitCount) 
             (i32.const 1)))
         
         (local.get $entry)
         (struct.get $PICEntry $method)
         return
         end ;; if
         
         ;; Try next slot
         (i32.add (local.get $index) (i32.const 1))
         (global.get $methodCacheSize)
         i32.rem_u
         local.set $index
         
         (local.set $probeLimit (i32.sub (local.get $probeLimit) (i32.const 1)))
         
         br $probe_loop
       )
       
       ref.null $CompiledMethod
       return
       )

 ;; Store method in cache
 (func $storeInCache
       (param $vm (ref $VirtualMachine))
       (param $selector (ref null eq))
       (param $receiverClass (ref null $Class))
       (param $method (ref $CompiledMethod))
       (local $cache (ref null $ObjectArray))
       (local $index i32)
       (local $entry (ref $PICEntry))
       
       ;; Get method cache
       (local.get $vm)
       (local.tee $cache 
         (struct.get $VirtualMachine $methodCache))
       ref.is_null
             (then
           return
         )
       )
       
       ;; Simple hash function
       local.get $selector
       ref.cast (ref $SqueakObject)
       struct.get $SqueakObject $identityHash
       
       (i32.add 
         (ref.as_non_null 
           (local.get $receiverClass)) 
         (struct.get $Class $identityHash))
       
       global.get $methodCacheSize
       i32.rem_u
       local.set $index
       
       ;; Create new cache entry
       (local.get $selector)
       (local.get $receiverClass)
       (local.get $method)
       (i32.const 1 ;; Initial hit count)
       (local.set $entry 
         (struct.new $PICEntry))
       
       ;; Store in cache
       (array.set $ObjectArray 
         (ref.as_non_null 
           (local.get $cache)) 
         (local.get $index) 
         (local.get $entry))
       ) ;; (func $storeInCache

 ;; Create context for method call
 (func $createMethodContext
       (param $vm (ref $VirtualMachine))
       (param $receiver eqref)
       (param $method (ref $CompiledMethod))
       (param $selector eqref)
       (result (ref null $Context))
       (local $stack (ref $ObjectArray))
       (local $slots (ref $ObjectArray))
       (local $args (ref $ObjectArray))
       (local $temps (ref $ObjectArray))

       ;; Create new stack for the method
       (local.set $stack (array.new $ObjectArray (ref.null eq) (i32.const 20)))

       ;; Create empty arrays for slots, args, temps
       (local.set $slots (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       (local.set $args (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       (local.set $temps (array.new $ObjectArray (ref.null eq) (i32.const 0)))

       ;; Create context for method
       (global.get $objectClass ;; class (Context is-a Object for now))
       (call $nextIdentityHash)
       (i32.const 14 ;; format (MethodContext))
       (i32.const 14 ;; size)
       (ref.null $SqueakObject ;; nextObject)
       (local.get $slots ;; slots (non-nullable))
       (local.get $vm)
       (struct.get $VirtualMachine $activeContext ;; sender 
         (current context))
       (i32.const 0 ;; pc)
       (i32.const 0 ;; sp)
       (local.get $method ;; method)
       (local.get $receiver ;; receiver)
       (local.get $args ;; args (non-nullable))
       (local.get $temps ;; temps (non-nullable))
       (local.get $stack ;; stack (non-nullable))
       (struct.new $Context)
       ) ;; (func $createMethodContext

 ;; SmallInteger operations
 (func $smallIntegerForValue (param $value i32) (result (ref i31))
       local.get $value
       ref.i31
       ) ;; (func $smallIntegerForValue (param $value i32) (result (ref i31))
 
 (func $valueOfSmallInteger (param $obj (ref null eq)) (result i32)
       local.get $obj
       ref.test (ref i31)
       sult i32)
         (then
           local.get $obj
           ref.cast (ref i31)
           i31.get_s
         )
         (else
           ;; Not a SmallInteger - return 0 for safety
           i32.const 0
         )
       )
       ) ;; if (result i32)

 ;; Check if method has compiled function
 (func $isTranslated (param $method (ref $CompiledMethod)) (result i32)
       (local.get $method)
       (struct.get $CompiledMethod $functionIndex)
       (i32.const 0)
       i32.gt_u  ;; Check if > 0 (since we start at index 1)
       ) ;; (func $isTranslated (param $method (ref $CompiledMethod)) (result i32)

 ;; Execute compiled WASM function by calling it directly
 (func $executeTranslatedMethod 
       (param $context (ref null $Context))
       (param $funcIndex i32)
       (result i32)
       ;; Call the compiled function directly using call_indirect
       ;; The function should operate on the context and return 0 for success
       (local.get $context)
       (local.get $funcIndex)
       (call_indirect (param eqref) (result i32))
       ) ;; (func $executeTranslatedMethod

 ;; Trigger JIT compilation for hot method
 (func $triggerMethodTranslation (param $method (ref $CompiledMethod))
       (local $bytecodes (ref null $ByteArray))
       (local $bytecodeLen i32)
       (local $functionIndexIndex i32)
       (local $memoryOffset i32)
       
       ;; Get bytecode array
       (local.get $method)
       (local.tee $bytecodes 
         (struct.get $CompiledMethod $bytecodes))
       ref.is_null
             (then
           return  ;; No bytecodes to compile
         )
       )
       
       ;; Get bytecode length
       (ref.as_non_null (local.get $bytecodes))
       array.len
       local.set $bytecodeLen
       (local.get $method)
       (call $translateMethod)
       ) ;; (func $triggerMethodTranslation (param $method (ref $CompiledMethod))

 ;; Handle method return and context switching
 (func $handleMethodReturn (param $vm (ref $VirtualMachine)) (param $context (ref null $Context)) (result (ref null eq))
       (local $sender (ref null $Context))
       (local $result (ref null eq))
       
       ;; Get result from top of stack
       (local.get $context)
       (local.set $result 
         (call $topOfStack))
       
       ;; Get sender context
       (local.get $context)
       (local.tee $sender 
         (struct.get $Context $sender))
       ref.is_null
       i32.eqz ;; not
             (then
           ;; Push result onto sender's stack
           (ref.as_non_null (local.get $sender))
           (ref.as_non_null (local.get $result))
           (call $pushOnStack)
           
           ;; Increment sender's PC
           (ref.as_non_null (local.get $sender))
           (struct.set $Context $pc 
             (ref.as_non_null 
               (local.get $sender)) 
             (i32.add 
               (struct.get $Context $pc) 
               (i32.const 1)))
         )
       )
       
       ;; make the sender the active context again.
       local.get $sender
       ref.is_null
             (then
           (struct.set $VirtualMachine $activeContext 
             (ref.null $Context) 
             (local.get $vm))
         )
         (else
           (struct.set $VirtualMachine $activeContext 
             (ref.as_non_null 
               (local.get $sender)) 
             (local.get $vm))
         )
       )
       
       local.get $result
       ) ;; if

 ;; VM initialization and bootstrap
 (func $initialize (export "initialize") (result (ref $VirtualMachine))
       (local $vm (ref $VirtualMachine))



       
       (local.set $vm 
         (struct.new $VirtualMachine))
       ;; Create minimal object memory for 3 workload example
       (local.get $vm)
       (call $createMinimalBootstrap)
       ) ;; (func $initialize (export "initialize") (result i32)

 ;; Create minimal bootstrap environment for 3 workload
 (func $createMinimalBootstrap (result i32)
       (local $vm (ref $VirtualMachine))
       (local $workloadMethod (ref null $CompiledMethod))
       (local $mainMethod (ref null $CompiledMethod))
       (local $mainBytecodes (ref null $ByteArray))
       (local $workloadBytecodes (ref null $ByteArray))
       (local $workloadSelector (ref null $Symbol))
       (local $methodDictionary (ref null $Dictionary))
       (local $newObject (ref null $SqueakObject))
       (local $slots (ref $ObjectArray))
       (local $keys (ref $ObjectArray))
       (local $values (ref $ObjectArray))
       (local $emptyDict (ref $Dictionary))
       (local $emptySymbol (ref $Symbol))
       (local $emptyInstVarNames (ref $ObjectArray))
       (local $workloadSlots (ref $ObjectArray))
       
       ;; Initialize method cache
       (struct.set $VirtualMachine $methodCache 
         (ref.as_non_null 
           (array.new $ObjectArray 
             (ref.null eq) 
             (global.get $methodCacheSize))) 
         (local.get $vm))
       
       ;; Create minimal objects for non-nullable fields
       ;; Empty Dictionary for methodDictionary
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 2 ;; format (variable object))
       (i32.const 9 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null ;; $slots 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 0)))
       (array.new $ObjectArray (ref.null eq) (i32.const 0))
       (array.new $ObjectArray (ref.null eq) (i32.const 0))
       (i32.const 0 ;; count)
       (local.set $emptyDict 
         (struct.new $Dictionary))

       ;; Empty Symbol for name
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 8 ;; format (byte object))
       (i32.const 7 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       (ref.null $ByteArray)
       (local.set $emptySymbol 
         (struct.new $Symbol))

       ;; Empty ObjectArray for instanceVariableNames (array of $Symbol, but empty for bootstrap)
       (local.set $emptyInstVarNames 
         (ref.as_non_null 
           (array.new $ObjectArray 
             (ref.null eq) 
             (i32.const 0))))

       ;; Create Class class first (bootstrap issue)
       (ref.null $Class ;; class (will be set to itself))
       (call $nextIdentityHash)
       (i32.const 1 ;; format (regular object))
       (i32.const 11 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null ;; $slots 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 0)))
       (ref.null $Class ;; superclass (nullable))
       (local.get $emptyDict ;; methodDictionary (non-nullable))
       (local.get $emptyInstVarNames ;; instanceVariableNames 
         (non-nullable $ObjectArray))
       (local.get $emptySymbol ;; name (non-nullable))
       (i32.const 0 ;; instanceSize)
       (local.set $newObject 
         (struct.new $Class))
       (local.get $newObject)
       ref.cast (ref null $Class)
       (global.set $classClass)
       (global.get $classClass)
       ;; Set its own class field to itself (must be (ref null $Class))
       local.get $newObject
       ref.cast (ref null $Class)
       struct.set $Class $class
       ;; For the very first object, set both $firstObject and $lastObject
       (struct.set $VirtualMachine $firstObject 
         (local.get $newObject) 
         (local.get $vm))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))

       ;; Create Object class
       (global.get $classClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 1 ;; format)
       (i32.const 11 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null ;; $slots 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 0)))
       (ref.null $Class ;; superclass (ref null $Class))
       (local.get $emptyDict ;; methodDictionary (non-nullable))
       (local.get $emptyInstVarNames ;; instanceVariableNames 
         (non-nullable $ObjectArray))
       (local.get $emptySymbol ;; name (non-nullable))
       (i32.const 0 ;; instanceSize)
       (local.set $newObject 
         (struct.new $Class))
       ;; Link this object to the chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (struct.get $VirtualMachine $lastObject) 
         (local.get $newObject))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))
       (local.get $newObject)
       ref.cast (ref null $Class)
       global.set $objectClass

       ;; Create SmallInteger class
       (global.get $classClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 1 ;; format)
       (i32.const 11 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null ;; $slots 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 0)))
       (global.get $objectClass ;; superclass (class Object))
       ref.cast (ref null $Class)
       (local.get $emptyDict ;; methodDictionary (non-nullable))
       (local.get $emptyInstVarNames ;; instanceVariableNames 
         (non-nullable $ObjectArray))
       (local.get $emptySymbol ;; name (non-nullable))
       (i32.const 0 ;; instanceSize)
       (local.set $newObject 
         (struct.new $Class))
       ;; Link this object to the chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (ref.as_non_null 
           (struct.get $VirtualMachine $lastObject)) 
         (local.get $newObject))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))
       (local.get $newObject)
       ref.cast (ref null $Class)
       global.set $smallIntegerClass

       ;; Create method dictionary for SmallInteger
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 2 ;; format (variable object))
       (i32.const 9 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null ;; $slots 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 0)))
       (ref.as_non_null ;; $keys 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 1)))
       (ref.as_non_null ;; $values 
         (non-nullable) 
         (array.new $ObjectArray 
           (ref.null eq) 
           (i32.const 1)))
       (i32.const 0 ;; count)
       (local.set $newObject 
         (struct.new $Dictionary))
       ;; Link this object to the chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (ref.as_non_null 
           (struct.get $VirtualMachine $lastObject)) 
         (local.get $newObject))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))
       (local.get $newObject)
       ref.cast (ref null $Dictionary)
       local.set $methodDictionary

       ;; Create bytecodes for main method: [push_receiver, send_workload, return]
       (i32.const 0x70 ;; push_receiver)
       (i32.const 0xD0 ;; send_workload)
       (i32.const 0x7C ;; return_top)
       (local.set $mainBytecodes (array.new_fixed $ByteArray 3))

       ;; Create simple repetitive computation: iterative arithmetic progression (~100μs target)
       ;;
       ;; ALGORITHM EXPLANATION:
       ;; This workload method performs a simple iterative arithmetic progression that's easy for LLMs to understand and optimize.
       ;; 
       ;; Pattern (repeated 5 times):
       ;; 1. result = (receiver + 1) * 2
       ;; 2. result = (result + 2) * 3  
       ;; 3. result = (result + 3) * 2
       ;;
       ;; This creates a simple, predictable pattern that:
       ;; - Is easy for an LLM to analyze and understand
       ;; - Has clear optimization opportunities (can be reduced to a mathematical formula)
       ;; - Takes sufficient time when interpreted (~45 operations × 15 iterations = ~90μs)
       ;; - Has predictable, testable results
       ;;
       ;; With receiver = 100, this performs 45 arithmetic operations in a simple pattern
       ;; that an LLM can easily translate to optimized WAT code.
       ;;
       ;; Simple repetitive pattern (15 iterations of 3-operation sequence)
       i32.const 0x70      ;; push_receiver (start with receiver)
       
       ;; Iteration 1
       (i32.const 0x21 ;; push literal 1)
       (i32.const 0xB0 ;; add (receiver + 1))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB0 ;; add (+ 2))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB8 ;; multiply (* 3))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB0 ;; add (+ 3))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       
       ;; Iteration 2 (same pattern)
       (i32.const 0x21 ;; push literal 1)
       (i32.const 0xB0 ;; add (+ 1))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB0 ;; add (+ 2))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB8 ;; multiply (* 3))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB0 ;; add (+ 3))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       
       ;; Iteration 3
       (i32.const 0x21 ;; push literal 1)
       (i32.const 0xB0 ;; add (+ 1))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB0 ;; add (+ 2))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB8 ;; multiply (* 3))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB0 ;; add (+ 3))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       
       ;; Iteration 4
       (i32.const 0x21 ;; push literal 1)
       (i32.const 0xB0 ;; add (+ 1))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB0 ;; add (+ 2))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB8 ;; multiply (* 3))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB0 ;; add (+ 3))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       
       ;; Iteration 5
       (i32.const 0x21 ;; push literal 1)
       (i32.const 0xB0 ;; add (+ 1))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB0 ;; add (+ 2))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB8 ;; multiply (* 3))
       (i32.const 0x23 ;; push literal 3)
       (i32.const 0xB0 ;; add (+ 3))
       (i32.const 0x22 ;; push literal 2)
       (i32.const 0xB8 ;; multiply (* 2))
       
       ;; Final return
       (i32.const 0x7C ;; return_top)
       (local.set $workloadBytecodes (array.new_fixed $ByteArray 62))

       ;; Create "workload" selector symbol with actual bytes
       ;; Now create the Symbol with the byte array (push fields in correct order)
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash)
       (i32.const 8 ;; format (byte object))
       (i32.const 7 ;; size)
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (ref.as_non_null (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       ;; Create the byte array with ASCII values for "workload" as the last field
       ;; 'w'=119, 'o'=111, 'r'=114, 'k'=107, 'l'=108, 'o'=111, 'a'=97, 'd'=100
       (i32.const 119 ;; 'w')
       (i32.const 111 ;; 'o')
       (i32.const 114 ;; 'r')
       (i32.const 107 ;; 'k')
       (i32.const 108 ;; 'l')
       (i32.const 111 ;; 'o')
       (i32.const 97 ;; 'a')
       (i32.const 100 ;; 'd')
       (array.new_fixed $ByteArray 8)
       (local.set $workloadSelector 
         (struct.new $Symbol))
       ;; Link selector to object chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (ref.as_non_null 
           (struct.get $VirtualMachine $lastObject)) 
         (ref.as_non_null 
           (local.get $workloadSelector)))
       (struct.set $VirtualMachine $lastObject 
         (ref.as_non_null 
           (local.get $workloadSelector)) 
         (local.get $vm))

       ;; Create literals array with workload selector at index 0
       (local.set $slots (array.new $ObjectArray (ref.null eq) (i32.const 1)))
       (array.set $ObjectArray 
         (local.get $slots) 
         (i32.const 0 ;; index 0) 
         (ref.as_non_null 
           (local.get $workloadSelector)))

       ;; Create main method (sends >>workload message)
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash ;; identityHash 
         (i32))
       (i32.const 6 ;; format (i32))
       (i32.const 14 ;; size (i32))
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (local.get $slots ;; slots (ref $ObjectArray))
       (i32.const 0 ;; header (i32))
       (local.get $mainBytecodes ;; bytecodes (ref null $ByteArray))
       (i32.const 0 ;; invocationCount (i32))
       (i32.const 0 ;; functionIndex (i32))
       (global.get $translationThreshold)
       (i32.const 0 ;; isInstalled (i32))
       (local.set $newObject 
         (struct.new $CompiledMethod))
       (local.get $newObject)
       ref.cast (ref null $CompiledMethod)
       local.set $mainMethod
       ;; Link this object to the chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (ref.as_non_null 
           (struct.get $VirtualMachine $lastObject)) 
         (local.get $newObject))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))

       ;; Create workload method (does the intensive computation)
       ;; First create the literals array that the workload method needs
       (local.set $workloadSlots 
         (ref.as_non_null 
           (array.new $ObjectArray 
             (ref.null eq) 
             (i32.const 4 ;; Need 4 literal slots 
               (0-3, but we only use 1-3)))))
       
       ;; Fill the slots with SmallInteger literals we actually use
       (local.get $workloadSlots)
       (array.set $ObjectArray 
         (i32.const 0 ;; literal[0] = 0 
           (unused but keep for consistency)) 
         (i32.const 0) 
         (ref.as_non_null 
           (call $smallIntegerForValue)))
       
       (local.get $workloadSlots)
       (array.set $ObjectArray 
         (i32.const 1 ;; literal[1] = 1) 
         (i32.const 1) 
         (ref.as_non_null 
           (call $smallIntegerForValue)))
       
       (local.get $workloadSlots)
       (array.set $ObjectArray 
         (i32.const 2 ;; literal[2] = 2) 
         (i32.const 2) 
         (ref.as_non_null 
           (call $smallIntegerForValue)))
       
       (local.get $workloadSlots)
       (array.set $ObjectArray 
         (i32.const 3 ;; literal[3] = 3) 
         (i32.const 3) 
         (ref.as_non_null 
           (call $smallIntegerForValue)))
       
       ;; Now create the workload method with proper slots
       (global.get $objectClass ;; class (ref null $Class))
       (call $nextIdentityHash ;; identityHash 
         (i32))
       (i32.const 6 ;; format (i32))
       (i32.const 14 ;; size (i32))
       (ref.null $SqueakObject ;; nextObject (ref null $SqueakObject))
       (local.get $workloadSlots ;; slots 
         (ref $ObjectArray) - now has proper literals)
       (i32.const 0 ;; header (i32))
       (local.get $workloadBytecodes ;; bytecodes (ref null $ByteArray))
       (i32.const 0 ;; invocationCount (i32))
       (i32.const 0 ;; functionIndex (i32))
       (global.get $translationThreshold)
       (i32.const 0 ;; isInstalled (i32))
       (local.set $newObject 
         (struct.new $CompiledMethod))
       (local.get $newObject)
       ref.cast (ref null $CompiledMethod)
       local.set $workloadMethod
       ;; Link this object to the chain
       (local.get $vm)
       (struct.set $SqueakObject $nextObject 
         (ref.as_non_null 
           (struct.get $VirtualMachine $lastObject)) 
         (local.get $newObject))
       (struct.set $VirtualMachine $lastObject 
         (local.get $newObject) 
         (local.get $vm))

       ;; Install method dictionary in SmallInteger class
       (struct.set $Class $methodDictionary 
         (ref.as_non_null 
           (global.get $smallIntegerClass)) 
         (ref.as_non_null 
           (local.get $methodDictionary)))
       
       ;; Install workload selector in dictionary keys array
       (ref.as_non_null (local.get $methodDictionary))
       (array.set $ObjectArray 
         (ref.as_non_null 
           (struct.get $Dictionary $keys)) 
         (i32.const 0 ;; index 0) 
         (ref.as_non_null 
           (local.get $workloadSelector)))
       
       ;; Install workload method in dictionary values array
       (ref.as_non_null (local.get $methodDictionary))
       (array.set $ObjectArray 
         (ref.as_non_null 
           (struct.get $Dictionary $values)) 
         (i32.const 0 ;; index 0) 
         (ref.as_non_null 
           (local.get $workloadMethod)))
       
       ;; Set method dictionary count
       (struct.set $Dictionary $count 
         (ref.as_non_null 
           (local.get $methodDictionary)) 
         (i32.const 1))
       
       ;; Mark method as installed
       (struct.set $CompiledMethod $isInstalled 
         (ref.as_non_null 
           (local.get $workloadMethod)) 
         (i32.const 1))
       
       ;; Set as main method for execution
       (global.set $mainMethod (local.get $mainMethod))
       
       ;; Return success
       i32.const 1
       ) ;; (func $createMinimalBootstrap (result i32)

 ;; Interpret single bytecode - returns 1 if method should return, 0 to continue
 (func $interpretBytecode
       (param $vm (ref $VirtualMachine))
       (param $context (ref $Context))
       (param $bytecode i32) 
       (result i32)
       (local $receiver eqref)
       (local $value1 eqref)
       (local $value2 eqref)
       (local $int1 i32)
       (local $int2 i32)
       (local $result i32)
       (local $newContext (ref $Context))
       (local $selector eqref)
       (local $method (ref $CompiledMethod))
       (local $receiverClass (ref $Class))
       (local $selectorIndex i32)
       (local $slots (ref $ObjectArray))
       
       ;; Execute bytecode based on opcode
       
       ;; Handle push literal opcodes (0x20-0x2F for literals 0-15)
       (local.get $bytecode)
       (i32.const 0x20 ;; Push literal base)
       i32.ge_u
       (local.get $bytecode)
       (i32.const 0x2F ;; Push literal end)
       i32.le_u
       i32.and
             (then
           ;; Extract literal index
           (local.set $selectorIndex ;; Reuse variable for literal index 
             (i32.sub 
               (local.get $bytecode) 
               (i32.const 0x20)))
           
           ;; Get method's literal array
           (local.get $context)
           (ref.as_non_null 
             (struct.get $Context $method))
           (local.tee $slots 
             (ref.as_non_null 
               (struct.get $CompiledMethod $slots)))
           
           ;; Check bounds
           (local.get $selectorIndex)
           (local.get $slots)
           array.len
           i32.ge_u
           if
           ;; Index out of bounds - push 0 as fallback
           (local.get $context)
           (i32.const 0)
           (ref.as_non_null 
             (call $smallIntegerForValue))
           (call $pushOnStack)
           else
           ;; Get literal at index and push
           (local.get $context)
           (local.get $slots)
           (local.get $selectorIndex)
           (ref.as_non_null (array.get $ObjectArray))
           (call $pushOnStack)
           end ;; else
           
           i32.const 0  ;; Continue execution
           return
         )
       )
       
       (i32.eq (local.get $bytecode) (i32.const 0x70 ;; Push receiver))
             (then
           ;; Push receiver onto stack
           (local.get $context)
           (local.get $context)
           (ref.as_non_null 
             (struct.get $Context $receiver))
           (call $pushOnStack)
           (i32.const 0 ;; Continue execution)
           return
         )
       )
       
       (i32.eq 
         (local.get $bytecode) 
         (i32.const 0xB8 ;; Multiply 
           (pop two, multiply, push result)))
             (then
           ;; Pop two values from stack
           (local.get $context)
           (local.tee $value2 
             (call $popFromStack))
           ref.is_null
           if
           i32.const 0  ;; Continue if stack underflow
           return
           end ;; if
           
           (local.get $context)
           (local.tee $value1 
             (call $popFromStack))
           ref.is_null
           if
           ;; Push value2 back and continue
           (local.get $context)
           (ref.as_non_null (local.get $value2))
           (call $pushOnStack)
           (i32.const 0)
           return
           end ;; if
           
           ;; Extract integer values
           (local.get $value1)
           (local.set $int1 
             (call $valueOfSmallInteger))
           
           (local.get $value2)
           (local.set $int2 
             (call $valueOfSmallInteger))
           
           ;; Multiply integers
           (local.set $result (i32.mul (local.get $int1) (local.get $int2)))
           
           ;; Create result SmallInteger and push onto stack
           (local.get $context)
           (local.get $result)
           (ref.as_non_null 
             (call $smallIntegerForValue))
           (call $pushOnStack)
           
           i32.const 0  ;; Continue execution
           return
         )
       )
       
       (i32.eq 
         (local.get $bytecode) 
         (i32.const 0xB0 ;; Add 
           (pop two, add, push result)))
             (then
           ;; Pop two values from stack
           (local.get $context)
           (local.tee $value2 
             (call $popFromStack))
           ref.is_null
           if
           i32.const 0  ;; Continue if stack underflow
           return
           end ;; if
           
           (local.get $context)
           (local.tee $value1 
             (call $popFromStack))
           ref.is_null
           if
           ;; Push value2 back and continue
           (local.get $context)
           (ref.as_non_null (local.get $value2))
           (call $pushOnStack)
           (i32.const 0)
           return
           end ;; if
           
           ;; Extract integer values
           (local.get $value1)
           (local.set $int1 
             (call $valueOfSmallInteger))
           
           (local.get $value2)
           (local.set $int2 
             (call $valueOfSmallInteger))
           
           ;; Add integers
           (local.set $result (i32.add (local.get $int1) (local.get $int2)))
           
           ;; Create result SmallInteger and push onto stack
           (local.get $context)
           (local.get $result)
           (ref.as_non_null 
             (call $smallIntegerForValue))
           (call $pushOnStack)
           
           i32.const 0  ;; Continue execution
           return
         )
       )
       
       (i32.eq (local.get $bytecode) (i32.const 0x7C ;; Return top-of-stack))
             (then
           ;; Return - top of stack is already the result
           i32.const 1  ;; Signal method return
           return
         )
       )
       
       (i32.eq 
         (local.get $bytecode) 
         (i32.const 0xD0 ;; Send message 
           (generic for any selector)))
             (then
           ;; Pop receiver from stack
           (local.get $context)
           (local.tee $receiver 
             (call $popFromStack))
           ref.is_null
           if
           i32.const 0
           return
           end ;; if
           
           ;; Extract selector index from low 4 bits of bytecode
           (local.get $bytecode)
           (i32.const 0x0F ;; Mask for low 4 bits)
           i32.and
           local.set $selectorIndex  ;; Use meaningful name instead of reusing $int1
           
           ;; Get selector from method's literal array at index
           (local.get $context)
           (ref.as_non_null 
             (struct.get $Context $method))
           (local.tee $slots 
             (ref.as_non_null 
               (struct.get $CompiledMethod $slots)))
           
           ;; Check bounds before accessing
           (local.get $selectorIndex)
           (local.get $slots)
           array.len
           i32.ge_u
           if
           ;; Index out of bounds - push receiver back and continue
           (local.get $context)
           (ref.as_non_null (local.get $receiver))
           (call $pushOnStack)
           (i32.const 0)
           return
           end ;; if
           
           ;; Get selector at index
           (local.get $slots)
           (local.get $selectorIndex)
           (local.set $selector (array.get $ObjectArray))
           
           ;; No need to increment PC since we're not reading next byte
           
           ;; Get receiver's class
           (local.get $receiver)
           (local.set $receiverClass 
             (call $classOfObject))
           
           ;; Try polymorphic inline cache first
           (local.get $selector)
           (local.get $receiverClass)
           (local.tee $method 
             (call $lookupInCache))
           ref.is_null
           if
           ;; Cache miss - do full method lookup
           (local.get $receiver)
           (local.get $selector)
           (local.tee $method 
             (call $lookupMethod))
           ref.is_null
           if
           ;; Method not found - push receiver back
           (local.get $context)
           (ref.as_non_null (local.get $receiver))
           (call $pushOnStack)
           (i32.const 0)
           return
           end ;; if
           
           ;; Store in cache for future use
           (local.get $selector)
           (local.get $receiverClass)
           (ref.as_non_null (local.get $method))
           (call $storeInCache)
           end ;; if
           
           ;; Create new context for method
           (local.get $receiver)
           (ref.as_non_null (local.get $method))
           (local.get $selector)
           (local.set $newContext 
             (call $createMethodContext))
           
           ;; Switch to new context
           (struct.set $VirtualMachine $activeContext 
             (local.get $newContext) 
             (local.get $vm))
           
           i32.const 0 ;; Continue execution in new context
           return
         )
       )
       
       ;; Unknown bytecode - continue execution
       i32.const 0
       ) ;; (func $interpretBytecode

 ;; Main interpreter loop
 (func $interpret (export "interpret") (result i32)
       (local $vm (ref $VirtualMachine))
       (local $context (ref $Context))
       (local $method (ref $CompiledMethod))
       (local $bytecode i32)
       (local $pc i32)
       (local $stack (ref $ObjectArray))
       (local $slots (ref $ObjectArray))
       (local $args (ref $ObjectArray))
       (local $temps (ref $ObjectArray))
       (local $receiver (ref eq))
       (local $resultValue (ref eq))
       (local $invocationCount i32)
       (local $bytecodes (ref $ByteArray))
       (local $funcIndex i32)

       ;; Create execution stack with proper size
       (local.set $stack (array.new $ObjectArray (ref.null eq) (i32.const 20)))
       ;; Create empty arrays for slots, args, temps
       (local.set $slots (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       (local.set $args (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       (local.set $temps (array.new $ObjectArray (ref.null eq) (i32.const 0)))
       
       ;; Create SmallInteger 100 as receiver (for more intensive computation)
       i32.const 100
       ref.i31
       local.set $receiver
       
       ;; Create initial context for main method
       (global.get $objectClass ;; class (Context is-a Object for now))
       (i32.const 2001 ;; identityHash)
       (i32.const 14 ;; format (MethodContext))
       (i32.const 14 ;; size)
       (ref.null $SqueakObject ;; nextObject)
       (local.get $slots ;; slots (non-nullable))
       (ref.null $Context ;; sender)
       (i32.const 0 ;; pc)
       (i32.const 0 ;; sp (stack pointer))
       (global.get $mainMethod ;; method)
       (local.get $receiver ;; receiver (SmallInteger 3))
       (local.get $args ;; args (non-nullable))
       (local.get $temps ;; temps (non-nullable))
       (local.get $stack ;; stack (non-nullable))
       (struct.set $VirtualMachine $activeContext 
         (struct.new $Context) 
         (local.get $vm))

       $finished
         
         ;; Main execution loop
         loop $execution_loop
         ;; Get active context
         (local.get $vm)
         (local.tee $context 
           (struct.get $VirtualMachine $activeContext))
         ref.is_null
         if
         ;; No active context - execution complete
         br $finished
         end ;; if
         
         ;; Cast to non-null and get method
         (ref.as_non_null (local.get $context))
         (local.tee $method 
           (struct.get $Context $method))
         
         ;; Increment invocation count
         (local.get $method)
         (local.set $invocationCount 
           (i32.add 
             (struct.get $CompiledMethod $invocationCount) 
             (i32.const 1)))
         
         (struct.set $CompiledMethod $invocationCount 
           (local.get $method) 
           (local.get $invocationCount))
         
         ;; Check if we should trigger translation
         (local.get $invocationCount)
         (i32.eq 
           (local.get $method) 
           (struct.get $CompiledMethod $translationThreshold))
         (local.get $vm)
         (struct.get $VirtualMachine $jitEnabled)
         i32.and
         if
         ;; Check if method is installed in a method dictionary
         (local.get $method)
         (i32.eq 
           (struct.get $CompiledMethod $isInstalled) 
           (i32.const 1))
         if
         ;; Check if method already has compiled function
         (ref.as_non_null (local.get $method))
         (call $isTranslated)
         (i32.eqz ;; Only translate if not already translated.)
         if
         ;; Trigger method translation.
         (ref.as_non_null (local.get $method))
         (call $triggerMethodTranslation)
         end ;; if
         end ;; if
         end ;; if
         
         ;; Check if method has compiled function
         (ref.as_non_null (local.get $method))
         (call $isTranslated)
         if
         ;; Execute compiled WASM function
         (local.get $method)
         (local.set $funcIndex 
           (struct.get $CompiledMethod $functionIndex))
         
         (ref.as_non_null (local.get $context))
         (local.get $funcIndex)
         (call $executeTranslatedMethod)
         drop  ;; Ignore return value
         
         ;; Handle return from compiled method
         (ref.as_non_null (local.get $context))
         (local.set $resultValue 
           (call $handleMethodReturn))
         
         br $execution_loop
         else
         ;; Bytecode interpreter loop for current method
         (local.get $method)
         (local.tee $bytecodes 
           (struct.get $CompiledMethod $bytecodes))
         ref.is_null
         if
         br $execution_loop
         end ;; if
         
         ;; Bytecode interpreter loop
         loop $interpreter_loop
         ;; Get current PC
         (local.get $vm)
         (local.tee $context 
           (struct.get $VirtualMachine $activeContext))
         ref.is_null
         i32.eqz
         if
         (ref.as_non_null (local.get $context))
         (local.set $pc 
           (struct.get $Context $pc))
         
         (ref.as_non_null (local.get $context))
         (local.tee $method 
           (struct.get $Context $method))
         (ref.as_non_null 
           (local.tee $bytecodes 
             (struct.get $CompiledMethod $bytecodes)))
         array.len
         
         ;; Check if we've reached end of bytecodes
         local.get $pc
         i32.le_u
         if
         ;; End of method - handle return
         (ref.as_non_null (local.get $context))
         (local.set $resultValue 
           (call $handleMethodReturn))
         br $interpreter_loop
         end ;; if
         
         ;; Fetch next bytecode
         (ref.as_non_null (local.get $bytecodes))
         (local.get $pc)
         (local.set $bytecode (array.get_u $ByteArray))
         
         ;; Interpret single bytecode
         (ref.as_non_null (local.get $context))
         (local.get $bytecode)
         (call $interpretBytecode)
         
         ;; Check if method should return
         if
         ;; Method returned - handle return and switch contexts
         (ref.as_non_null (local.get $context))
         (local.set $resultValue 
           (call $handleMethodReturn))
         br $interpreter_loop
         end ;; if
         
         ;; Check if context switched (for message sends)
         (local.get $vm)
         (ref.eq 
           (struct.get $VirtualMachine $activeContext) 
           (local.get $context))
         if
         ;; Same context - increment PC and continue
         (struct.set $Context $pc 
           (ref.as_non_null 
             (local.get $context)) 
           (i32.add 
             (local.get $pc) 
             (i32.const 1)))
         else
         ;; Context switched (message send or return)
         (local.get $vm)
         (ref.as_non_null 
           (struct.get $VirtualMachine $activeContext))
         (struct.get $Context $pc)
         (i32.eqz)
         if
         ;; New context, pc == 0, check for JIT
         br $execution_loop ;; exits interpreter_loop, resumes execution_loop
         end ;; end inner if (pc == 0)
         ;; Otherwise, continue interpreting (fall through)
         end ;; end outer if (context switched)
         
         br $interpreter_loop ;; default - restart interpreter loop
         end ;; loop $interpreter_loop
         end ;; if
         end ;; $finished
         
         ;; Extract integer result for reporting
         ((local.get $resultValue))
         (
           (call $valueOfSmallInteger))
         (call $reportResult)
         
         end ;; loop $execution_loop
       )

       i32.const 1 ;; success
       return
       ) ;; (func $interpret
 )
