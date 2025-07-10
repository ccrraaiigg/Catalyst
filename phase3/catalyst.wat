;; catalyst.wat: multiple simultaneous Catalyst Smalltalk virtual
;; machines with method translation

(module
 ;; imported external functions from JS
 
 (import "env" "reportResult" (
			       func $reportResult
			       (param i32)))

 ;; JS translates method and installs translation function
 (import "env" "translateMethod" (
				  func $translateMethod
				  (param eqref)   ;; method
				  (param eqref)   ;; class
				  (param eqref))) ;; selector

 ;; level, message, length
 (import "env" "debugLog" (
			   func $debugLog
			   (param i32)
			   (param i32)
			   (param i32)))

 ;; types defining Smalltalk classes
 ;;
 ;; To start, we only define classes with functions which must exist
 ;; for the virtual machine to operate, and the superclasses of such
 ;; classes which define instance variables.
 ;;
 ;; Instances of Smalltalk class SmallInteger are of built-in
 ;; reference type i31, each instance of every other class is of a
 ;; reference type using a user-defined struct type. The common
 ;; supertype of all those reference types is built-in reference type
 ;; eqref. The type for arrays of bytes has built-in type i8 as its
 ;; default type.
 ;; 
 ;; For Smalltalk, we use the terms "slots" and "methods". For WASM,
 ;; we use "fields" and "functions". Smalltalk source is "compiled" to
 ;; a struct of type $CompiledMethod. A $CompiledMethod is
 ;; "translated" to a WASM function.
 ;; 
 ;; Nullable fields are only nullable because their initial values
 ;; aren't always knowable at creation time.
 
 (rec ;; recursive (mutually referential) type definitions
  (type $ObjectArray (array (mut eqref)))
  (type $ByteArray (array (mut i8)))

  (type $Object (sub (struct
		      (field $class (mut null eqref)) ;; $Class or $Metaclass
		      (field $identityHash (mut i32))
		      (field $nextObject (mut (ref null $Object)))
		      )))
  
  (type $VariableObject (sub $Object (struct
				      (field $class (mut null eqref)) ;; $Class or $Metaclass
				      (field $identityHash (mut i32))
				      (field $nextObject (mut (ref null $Object)))
				      (field $slots (mut (ref $ObjectArray)))
				      )))
  
  (type $Symbol (sub $VariableObject (struct
				      (field $class (mut null eqref)) ;; $Class or $Metaclass
				      (field $identityHash (mut i32))
				      (field $nextObject (mut (ref null $Object)))
				      (field $slots (mut (ref $ObjectArray)))
				      (field $bytes (ref $ByteArray))
				      )))

  (type $Dictionary (sub $VariableObject (struct
					  (field $class (mut null eqref)) ;; $Class or $Metaclass
					  (field $identityHash (mut i32))
					  (field $nextObject (mut (ref null $Object)))
					  (field $slots (mut (ref $ObjectArray)))
					  (field $keys (ref $ObjectArray))
					  (field $values (ref $ObjectArray))
					  (field $count (mut i32))
					  )))
  
  (type $Behavior (sub $VariableObject (struct
					;; a $Class or $Metaclass
					(field $class (mut null eqref))

					(field $identityHash (mut i32))
					(field $nextObject (mut (ref null $Object)))
					(field $slots (mut (ref $ObjectArray)))

					;; a $Class or $Metaclass
					(field $superclass (mut null eqref))

					(field $methodDictionary (mut (ref $Dictionary)))
					(field $format (mut i32))
					)))

  (type $ClassDescription (sub $Behavior (struct
					  ;; a $Class or $Metaclass
					  (field $class (mut null eqref))

					  (field $identityHash (mut i32))
					  (field $nextObject (mut (ref null $Object)))
					  (field $slots (mut (ref $ObjectArray)))

					  ;; a $Class or $Metaclass
					  (field $superclass (mut null eqref))

					  (field $methodDictionary (mut (ref $Dictionary)))
					  (field $format (mut i32))
					  (field $instanceVariableNames (mut (ref $ObjectArray)))
					  (field $baseID (mut (ref $ByteArray)))
					  )))

  (type $Class (sub $ClassDescription (struct
				       ;; a $Class or $Metaclass
				       (field $class (mut null eqref))

				       (field $identityHash (mut i32))
				       (field $nextObject (mut (ref null $Object)))
				       (field $slots (mut (ref $ObjectArray)))

				       ;; a $Class or $Metaclass
				       (field $superclass (mut null eqref))

				       (field $methodDictionary (mut (ref $Dictionary)))
				       (field $format (mut i32))
				       (field $instanceVariableNames (mut (ref $ObjectArray)))
				       (field $baseID (mut (ref null $ByteArray)))
				       (field $subclasses (mut (ref $ObjectArray)))
				       (field $name (mut (ref $Symbol)))
				       (field $classPool (mut (ref $Dictionary)))
				       (field $sharedPools (mut (ref $ObjectArray)))
				       )))

  (type $Metaclass (sub $ClassDescription (struct
					   ;; a $Class or $Metaclass
					   (field $class (mut null eqref))

					   (field $identityHash (mut i32))
					   (field $nextObject (mut (ref null $Object)))
					   (field $slots (mut (ref $ObjectArray)))

					   ;; a $Class or $Metaclass
					   (field $superclass (mut null eqref))

					   (field $methodDictionary (mut (ref $Dictionary)))
					   (field $format (mut i32))
					   (field $instanceVariableNames (mut (ref $ObjectArray)))
					   (field $baseID (mut (ref $ByteArray)))
					   (field $thisClass (mut (ref $Class)))
					   )))

  (type $CompiledMethod (sub $VariableObject (struct
					      (field $class (mut null eqref)) ;; $Class or $Metaclass
					      (field $identityHash (mut i32))
					      (field $nextObject (mut (ref null $Object)))
					      (field $slots (mut (ref $ObjectArray)))
					      (field $header i32)
					      (field $bytecodes (ref $ByteArray))
					      (field $invocationCount (mut i32))
					      ;; Index into function table
					      (field $functionIndex (mut i32))  
					      (field $translationThreshold i32)
					      ;; 0 = not installed, 1 = installed
					      (field $isInstalled (mut i32))   
					      )))
  
  (type $Context (sub $VariableObject (struct
				       (field $class (mut null eqref)) ;; $Class or $Metaclass
				       (field $identityHash (mut i32))
				       (field $nextObject (mut (ref null $Object)))
				       (field $slots (mut (ref $ObjectArray)))
				       (field $sender (mut (ref null $Context)))
				       (field $pc (mut i32))
				       (field $sp (mut i32))
				       (field $method (mut (ref $CompiledMethod)))
				       (field $receiver (mut eqref))
				       (field $args (mut (ref $ObjectArray)))
				       (field $temps (mut (ref $ObjectArray)))
				       (field $stack (mut (ref $ObjectArray)))
				       )))
  
  (type $PICEntry (struct
                   (field $selector (mut eqref))
                   (field $receiverClass (mut (ref $Class)))
                   (field $method (mut (ref $CompiledMethod)))
                   (field $hitCount (mut i32))
                   ))
  
  (type $VirtualMachine (struct
			 ;; created with a null $activeContext; it's set later
			 (field $activeContext (mut (ref null $Context)))

			 (field $jitEnabled (mut i32))
			 (field $methodCache (mut (ref $ObjectArray)))
			 (field $functionTableBaseIndex (mut i32))

			 ;; object memory management
			 (field $nextIdentityHash (mut i32))

			 ;; created with null $firstObject and
			 ;; $lastObject; they're set later
			 (field $firstObject (mut (ref null $Object)))
			 (field $lastObject (mut (ref null $Object))))))

 ;; global state for all virtual machines
 ;;
 ;; NOTE: Globals are nullable due to current WASM limitations, but
 ;; are enforced to be non-null after runtime initialization.

 ;; special selectors for quick sends
 (global $workloadSelector (mut null eqref) (ref.null eq))
 
 ;; method translation globals and method lookup cache
 ;; default translation threshold; each method can have its own
 (global $translationThreshold (mut i32) (i32.const 1000))
 (global $methodCacheSize (mut i32) (i32.const 256))

 ;; start of staging bytes
 (global $byteArrayCopyPointer (mut i32) (i32.const 1024))

 ;; linear memory for staging byte arrays visible to JS. See $copyByteArrayToMemory.
 (memory (export "bytes") 1)
 
 ;; translated methods function table (the only table in this module)
 (table $functionTable (export "functionTable") 100 funcref)

 (func $newDictionary
       (param $vm (ref $VirtualMachine))
       (result (ref $Dictionary))

       ref.null eq            ;; $class to be set later, to class Dictionary
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object       ;; $nextObject to be set later, once there is one
       ref.null eq            ;; default array element
       i32.const 0            ;; empty
       array.new $ObjectArray ;; $slots
       ref.null eq            ;; default array element
       i32.const 0            ;; empty
       array.new $ObjectArray ;; $keys
       ref.null eq            ;; default array element
       i32.const 0            ;; empty
       array.new $ObjectArray ;; $values
       i32.const 0            ;; $count
       struct.new $Dictionary
       )

 ;; Create and answer a virtual machine with an object memory.
 (func (export "initialize")
       (result (ref $VirtualMachine))
       
       (local $vm (ref $VirtualMachine))
       (local $classBehavior (ref $Class))
       (local $classClass (ref $Class))
       (local $classObject (ref $Class))
       
       ;; create virtual machine
       ref.null $Context            ;; $activeContext to be set later
       i32.const 1                  ;; jitEnabled

       ;; initialize method cache
       ref.null eq                  ;; default array element
       global.get $methodCacheSize
       array.new $ObjectArray       ;; $methodCache

       i32.const 0                  ;; $functionTableBaseIndex
       i32.const 1001               ;; $nextIdentityHash
       ref.null $Object             ;; $firstObject
       ref.null $Object             ;; $lastObject
       struct.new $VirtualMachine
       local.set $vm

       ;; Create class SmallInteger.
       ;; First create a Metaclass to be the class of class SmallInteger.
       ;; First create class Class to be the superclass of (SmallInteger class).
       ;; First create a Metaclass to be the class of class Class.
       ;; First create class Class to be the superclass of (Class class). We've been here before.
       ;; First create class Class with a null class, to be set later.
       ;; First create class Object to be the superclass of class Class.
       ;; First create a Metaclass to be the class of class Object. We've been here before.
       ;; First create class Class with a null class and superclass, to be set later.
       ;; 
       ;; This is why $class and $superclass of $Class are nullable
       ;; ($class is also nullable because the class of class
       ;; Metaclass is also an instance of class Metaclass, and
       ;; $superclass is also nullable because the superclass of class
       ;; Object is nil).

       ;; Create class Behavior with a null class and superclass, to be set later.

       ref.null eq                  ;; $class to be set later, to a Metaclass
       local.get $vm
       call $nextIdentityHash       ;; $identityHash
       ref.null $Object             ;; nextObject
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $slots
       ref.null eq                  ;; $superclass to be set later, to class Object
       local.get $vm
       call $newDictionary          ;; $methodDictionary
       i32.const 2                  ;; $format
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $instanceVariableNames
       ref.null $ByteArray          ;; $baseID to be set later (should be a $UUID)
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $subclasses

       ;; create name symbol
       ref.null $Class              ;; $class to be set later, to class Symbol
       local.get $vm
       call $nextIdentityHash
       ref.null $Object             ;; $nextObject
       ref.null eq                  ;; default array element
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $slots
       i32.const 67                 ;; 'C'
       i32.const 108                ;; 'l'
       i32.const 97                 ;; 'a'
       i32.const 115                ;; 's'
       i32.const 115                ;; 's'
       array.new_fixed $ByteArray 5
       struct.new $Symbol

       local.get $vm
       call $newDictionary          ;; $classPool
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $sharedPools
       struct.new $Class
       local.set $classBehavior

       ;; Create class ClassDescription with a null class, to be set later.

       ;; Create class Metaclass with a null class, to be set later.

       ;; Create class Class with a null class and superclass, to be set later.

       ref.null eq                  ;; $class to be set later, to (Class class)
       local.get $vm
       call $nextIdentityHash       ;; $identityHash
       ref.null $Object             ;; nextObject
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $slots
       ref.null eq                  ;; $superclass to be set later
       local.get $vm
       call $newDictionary          ;; $methodDictionary
       i32.const 2                  ;; $format
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $instanceVariableNames
       ref.null $ByteArray          ;; $baseID to be set later (should be a $UUID)
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $subclasses

       ;; create name symbol
       ref.null $Class              ;; $class to be set later (to class Symbol)
       local.get $vm
       call $nextIdentityHash
       ref.null $Object             ;; $nextObject
       ref.null eq                  ;; default array element
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $slots
       i32.const 67                 ;; 'C'
       i32.const 108                ;; 'l'
       i32.const 97                 ;; 'a'
       i32.const 115                ;; 's'
       i32.const 115                ;; 's'
       array.new_fixed $ByteArray 5
       struct.new $Symbol

       local.get $vm
       call $newDictionary          ;; $classPool
       ref.null eq                  ;; default array element type
       i32.const 0                  ;; empty
       array.new $ObjectArray       ;; $sharedPools
       struct.new $Class
       local.set $classClass

       ;; Create class Object.
       ;; Create (Object class).
       


       
       global.get $objectClass    ;; superclass (class Object)
       local.get $emptyDict ;; methodDictionary (non-nullable)
       local.get $emptyInstVarNames ;; instanceVariableNames (non-nullable $ObjectArray)
       local.get $emptySymbol ;; name (non-nullable)
       i32.const 0         ;; instanceSize
       struct.new $Class
       local.set $newObject
       ;; Link this object to the chain
       local.get $vm
       struct.get $VirtualMachine $lastObject
       ref.as_non_null
       local.get $newObject
       struct.set $Object $nextObject
       local.get $newObject
       local.get $vm
       struct.set $VirtualMachine $lastObject
       local.get $newObject
       global.set $smallIntegerClass

       ;; Create method dictionary for SmallInteger
       global.get $objectClass ;; class (ref $Class)
       call $nextIdentityHash
       i32.const 2         ;; format (variable object)
       i32.const 9         ;; size
       ref.null $Object ;; nextObject (ref null $Object)
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       ref.as_non_null      ;; $slots (non-nullable)
       ref.null eq
       i32.const 1
       array.new $ObjectArray
       ref.as_non_null      ;; $keys (non-nullable)
       ref.null eq
       i32.const 1
       array.new $ObjectArray
       ref.as_non_null      ;; $values (non-nullable)
       i32.const 0         ;; count
       struct.new $Dictionary
       local.set $newObject
       ;; Link this object to the chain
       local.get $vm
       struct.get $VirtualMachine $lastObject
       ref.as_non_null
       local.get $newObject
       struct.set $Object $nextObject
       local.get $newObject
       local.get $vm
       struct.set $VirtualMachine $lastObject
       local.get $newObject
       local.set $methodDictionary



       ;; Create minimal object memory for (3 workload) example.
       local.get $vm
       call $createMinimalBootstrap
       )

 ;; utilities for method translation in JS
 (func (export "compiledMethodBytecodes")
       (param $method eqref)
       (result (ref $ByteArray))
       
       local.get $method
       ref.cast (ref $CompiledMethod)
       struct.get $CompiledMethod $bytecodes)

 (func (export "setMethodFunctionIndex")
       (param $method eqref)
       (param $index i32)
       
       local.get $method
       ref.cast (ref $CompiledMethod)
       local.get $index
       struct.set $CompiledMethod $functionIndex) 

 (func (export "onContextPush")
       (param $context eqref)
       (param $pushedObject eqref)
       
       local.get $context
       ref.cast (ref $Context)
       local.get $pushedObject
       call $pushOnStack)
 
 (func (export "popFromContext")
       (param $context eqref)
       (result eqref)
       
       local.get $context
       ref.cast (ref $Context)
       call $popFromStack)
 
 (func (export "valueOfSmallInteger")
       (param $smallInteger (ref i31))
       (result i32)
       
       local.get $smallInteger
       call $valueOfSmallInteger)
 
 (func (export "smallIntegerForValue")
       (param $value i32)
       (result (ref i31))
       
       local.get $value
       call $smallIntegerForValue)
 
 (func (export "classOfObject")
       (param $object eqref)
       (result eqref)
       
       local.get $object
       call $classOfObject)
 
 (func (export "contextReceiver")
       (param $context eqref)
       (result eqref)
       
       local.get $context
       ref.cast (ref $Context)
       struct.get $Context $receiver)

 (func (export "methodSlots")
       (param $method eqref)
       (result eqref)
       
       local.get $method
       ref.cast (ref $CompiledMethod)
       struct.get $CompiledMethod $slots)

 (func (export "contextLiteralAt")
       (param $context eqref)
       (param $index i32)
       (result eqref)

       local.get $context
       ref.cast (ref $Context)
       struct.get $Context $method
       struct.get $CompiledMethod $slots
       local.get $index
       call $objectArrayAt)

 (func (export "contextMethod")
       (param $context eqref)
       (result eqref)
       
       local.get $context
       ref.cast (ref $Context)
       struct.get $Context $method)
 
 (func $arrayOkayAt
       (param $array eqref)
       (param $index i32)
       (result i32)

       (local $length i32)
       
       ;; Get array length.
       local.get $array
       array.len
       local.set $length
       
       ;; Check bounds.
       local.get $index
       i32.const 0
       i32.lt_s
       if
       i32.const 0
       return
       else
       local.get $index
       local.get $length
       i32.ge_u
       if
       i32.const 0
       return
       end
       return 1
       )

 (func $objectArrayAt
       (param $array (ref $ObjectArray))
       (param $index i32)
       (result (ref null eq))

       local.get $array
       ref.cast (ref eq)
       local.get $index
       call $arrayOkayAt
       i32.eqz
       if
       i32.const -1
       return
       else
       
       ;; Safe to access array
       local.get $array
       local.get $index
       array.get $ObjectArray
       )
 
 (func (export "byteArrayAt")
       (param $array eqref)
       (param $index i32)
       (result i32)

       local.get $array
       local.get $index
       call $arrayOkayAt
       i32.eqz
       if
       i32.const -1
       return
       else
       
       ;; Safe to access array
       local.get $array
       ref.cast (ref $ByteArray)
       local.get $index
       array.get_s $ByteArray
       )

 (func (export "byteArrayLength")
       (param $array eqref)
       (result i32)

       local.get $array
       ref.cast (ref $ByteArray)
       array.len
       )

 (func (export "copyByteArrayToMemory")
       (param (ref $ByteArray))
       (result i32)
       
       (local $len i32)
       (local $i i32)
       
       local.get 0
       ref.is_null
       if
       i32.const 0
       return
       end
       local.get 0
       ref.as_non_null
       array.len
       local.set $len
       i32.const 0
       local.set $i
       loop $copy
       local.get $i
       local.get $len
       i32.ge_u
       if
       global.get $byteArrayCopyPointer
       return
       end
       global.get $byteArrayCopyPointer
       local.get $i
       i32.add
       local.get 0
       ref.as_non_null
       local.get $i
       array.get_u $ByteArray
       i32.store8
       local.get $i
       i32.const 1
       i32.add
       local.set $i
       br $copy
       end
       i32.const 0
       )

 ;; Memory management
 (func $nextIdentityHash
       (param $vm (ref $VirtualMachine))
       (result i32)
       
       local.get $vm
       local.get $vm
       struct.get $VirtualMachine $nextIdentityHash
       i32.const 1
       i32.add
       struct.set $VirtualMachine $nextIdentityHash
       local.get $vm
       struct.get $VirtualMachine $nextIdentityHash
       ) ;; (func $nextIdentityHash (result i32)

 ;; Stack operations
 (func $pushOnStack
       (param $context (ref $Context))
       (param $value eqref)

       (local $stack (ref $ObjectArray))
       (local $sp i32)

       local.get $context
       struct.get $Context $stack
       local.set $stack

       local.get $context
       struct.get $Context $sp
       local.set $sp

       local.get $sp
       local.get $stack
       array.len
       i32.ge_u
       if
       return
       end ;; if

       local.get $stack
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
       (param $context (ref null $Context))
       (result (ref null eq))

       (local $stack (ref $ObjectArray))
       (local $sp i32)
       
       ;; Get stack and stack pointer
       local.get $context
       struct.get $Context $stack
       local.set $stack
       
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
       local.get $sp
       i32.const 1
       i32.sub
       array.get $ObjectArray
       return
       ) ;; (func $popFromStack
 
 (func $topOfStack
       (param $context (ref null $Context))
       (result (ref null eq))

       (local $stack (ref $ObjectArray))
       (local $sp i32)
       
       ;; Get stack and stack pointer
       local.get $context
       struct.get $Context $stack
       local.set $stack
       
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
       local.get $sp
       i32.const 1
       i32.sub
       array.get $ObjectArray
       return
       ) ;; (func $topOfStack

 ;; Get class of any object (including SmallIntegers)
 (func $classOfObject
       (param $obj (ref null eq))
       (result (ref $Class))
       
       local.get $obj
       ref.test (ref i31)
       if (result (ref $Class))
       ;; SmallInteger
       global.get $smallIntegerClass
       else
       ;; Regular object
       local.get $obj
       ref.cast (ref $Object)
       struct.get $Object $class
       end ;; else
       ) ;; if (result (ref $Class))

 (func $lookupMethod 
       (param $receiver (ref null eq))
       (param $selector (ref null eq))
       (result (ref null $CompiledMethod))

       (local $class (ref $Class))
       (local $currentClass (ref $Class))
       (local $methodDictionary (ref null $Dictionary))
       (local $keys (ref null $ObjectArray))
       (local $values (ref null $ObjectArray))
       (local $count i32)
       (local $i i32)
       (local $key (ref null eq))
       
       ;; Get receiver's class
       local.get $receiver
       call $classOfObject
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
       struct.get $Class $methodDictionary
       local.tee $methodDictionary
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
       local.get $methodDictionary
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
       
       local.get $methodDictionary
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
       local.get $methodDictionary
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
       
       ref.null $CompiledMethod
       return
       )

 ;; Polymorphic Inline Cache lookup
 (func $lookupInCache
       (param $vm (ref $VirtualMachine))
       (param $selector (ref null eq))
       (param $receiverClass (ref $Class))
       (result (ref null $CompiledMethod))

       (local $cache (ref null $ObjectArray))
       (local $cacheSize i32)
       (local $hash i32)
       (local $index i32)
       (local $entry (ref null $PICEntry))
       (local $probeLimit i32)
       
       ;; Get method cache
       local.get $vm
       struct.get $VirtualMachine $methodCache
       local.tee $cache
       ref.is_null
       if
       ref.null $CompiledMethod
       return
       end ;; if
       
       ;; Simple hash function (identity hash of selector + class)
       local.get $selector
       ref.cast (ref $Object)
       struct.get $Object $identityHash
       
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
       
       ref.null $CompiledMethod
       return
       )

 ;; Store method in cache
 (func $storeInCache
       (param $vm (ref $VirtualMachine))
       (param $selector (ref null eq))
       (param $receiverClass (ref $Class))
       (param $method (ref $CompiledMethod))

       (local $cache (ref null $ObjectArray))
       (local $index i32)
       (local $entry (ref $PICEntry))
       
       ;; Get method cache
       local.get $vm
       struct.get $VirtualMachine $methodCache
       local.tee $cache
       ref.is_null
       if
       return
       end ;; if
       
       ;; Simple hash function
       local.get $selector
       ref.cast (ref $Object)
       struct.get $Object $identityHash
       
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
       ref.null eq
       i32.const 20
       array.new $ObjectArray
       local.set $stack

       ;; Create empty arrays for slots, args, temps
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $slots
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $args
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $temps

       ;; Create context for method
       global.get $objectClass ;; class (Context is-a Object for now)
       local.get $vm
       call $nextIdentityHash
       i32.const 14         ;; format (MethodContext)
       i32.const 14         ;; size
       ref.null $Object ;; nextObject
       local.get $slots     ;; slots (non-nullable)
       local.get $vm
       struct.get $VirtualMachine $activeContext  ;; sender (current context)
       i32.const 0          ;; pc
       i32.const 0          ;; sp
       local.get $method    ;; method
       local.get $receiver  ;; receiver
       local.get $args      ;; args (non-nullable)
       local.get $temps     ;; temps (non-nullable)
       local.get $stack     ;; stack (non-nullable)
       struct.new $Context
       ) ;; (func $createMethodContext

 ;; SmallInteger operations
 (func $smallIntegerForValue
       (param $value i32)
       (result (ref i31))
       
       local.get $value
       ref.i31
       ) ;; (func $smallIntegerForValue (param $value i32) (result (ref i31))
 
 (func $valueOfSmallInteger
       (param $obj (ref null eq))
       (result i32)
       
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
 (func $isTranslated
       (param $method (ref $CompiledMethod))
       (result i32)
       
       local.get $method
       struct.get $CompiledMethod $functionIndex
       i32.const 0
       i32.gt_u  ;; Check if > 0 (since we start at index 1)
       ) ;; (func $isTranslated (param $method (ref $CompiledMethod)) (result i32)

 ;; Execute compiled WASM function by calling it directly
 (func $executeTranslatedMethod 
       (param $context (ref null $Context))
       (param $funcIndex i32)
       (result i32)
       
       ;; Call the compiled function directly using call_indirect
       ;; The function should operate on the context and return 0 for success
       local.get $context
       local.get $funcIndex
       call_indirect (param eqref) (result i32)
       ) ;; (func $executeTranslatedMethod

 ;; Trigger JIT compilation for hot method
 (func $triggerMethodTranslation
       (param $method (ref $CompiledMethod))
       (param $class eqref)
       (param $selector (ref $Symbol))
       
       (local $bytecodes (ref null $ByteArray))
       (local $bytecodeLen i32)
       (local $functionIndexIndex i32)
       (local $memoryOffset i32)
       
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
       
       ;; Call JS method translator with method info
       local.get $method
       local.get $class
       local.get $selector
       call $translateMethod
       ) ;; (func $triggerMethodTranslation (param $method (ref $CompiledMethod))

 ;; Handle method return and context switching
 (func $handleMethodReturn
       (param $vm (ref $VirtualMachine))
       (param $context (ref null $Context))
       (result (ref null eq))
       
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
       local.get $vm
       ref.null $Context
       struct.set $VirtualMachine $activeContext
       else
       local.get $vm
       local.get $sender
       struct.set $VirtualMachine $activeContext
       end ;; else
       
       local.get $result
       ) ;; if

 ;; Create minimal bootstrap environment for 3 workload
 (func $createMinimalBootstrap
       (result i32)
       
       (local $vm (ref $VirtualMachine))
       (local $workloadMethod (ref $CompiledMethod))
       (local $mainMethod (ref $CompiledMethod))
       (local $mainBytecodes (ref $ByteArray))
       (local $workloadBytecodes (ref $ByteArray))
       (local $workloadSelector (ref $Symbol))
       (local $methodDictionary (ref $Dictionary))
       (local $newObject (ref $Object))
       (local $slots (ref $ObjectArray))
       (local $keys (ref $ObjectArray))
       (local $values (ref $ObjectArray))
       (local $emptySymbol (ref $Symbol))
       (local $emptyInstVarNames (ref $ObjectArray))
       (local $workloadSlots (ref $ObjectArray))
       
       ;; Create bytecodes for main method: [push_receiver, send_workload, return]
       i32.const 0x70      ;; push_receiver 
       i32.const 0xD0      ;; send_workload
       i32.const 0x7C      ;; return_top
       array.new_fixed $ByteArray 3
       local.set $mainBytecodes

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
       i32.const 0x21      ;; push literal 1
       i32.const 0xB0      ;; add (receiver + 1)
       i32.const 0x22      ;; push literal 2  
       i32.const 0xB8      ;; multiply (* 2)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB0      ;; add (+ 2)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB8      ;; multiply (* 3)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB0      ;; add (+ 3)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB8      ;; multiply (* 2)
       
       ;; Iteration 2 (same pattern)
       i32.const 0x21      ;; push literal 1
       i32.const 0xB0      ;; add (+ 1)
       i32.const 0x22      ;; push literal 2  
       i32.const 0xB8      ;; multiply (* 2)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB0      ;; add (+ 2)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB8      ;; multiply (* 3)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB0      ;; add (+ 3)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB8      ;; multiply (* 2)
       
       ;; Iteration 3
       i32.const 0x21      ;; push literal 1
       i32.const 0xB0      ;; add (+ 1)
       i32.const 0x22      ;; push literal 2  
       i32.const 0xB8      ;; multiply (* 2)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB0      ;; add (+ 2)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB8      ;; multiply (* 3)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB0      ;; add (+ 3)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB8      ;; multiply (* 2)
       
       ;; Iteration 4
       i32.const 0x21      ;; push literal 1
       i32.const 0xB0      ;; add (+ 1)
       i32.const 0x22      ;; push literal 2  
       i32.const 0xB8      ;; multiply (* 2)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB0      ;; add (+ 2)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB8      ;; multiply (* 3)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB0      ;; add (+ 3)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB8      ;; multiply (* 2)
       
       ;; Iteration 5
       i32.const 0x21      ;; push literal 1
       i32.const 0xB0      ;; add (+ 1)
       i32.const 0x22      ;; push literal 2  
       i32.const 0xB8      ;; multiply (* 2)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB0      ;; add (+ 2)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB8      ;; multiply (* 3)
       i32.const 0x23      ;; push literal 3
       i32.const 0xB0      ;; add (+ 3)
       i32.const 0x22      ;; push literal 2
       i32.const 0xB8      ;; multiply (* 2)
       
       ;; Final return
       i32.const 0x7C      ;; return_top
       array.new_fixed $ByteArray 62
       local.set $workloadBytecodes

       ;; Create "workload" selector symbol with actual bytes
       ;; Now create the Symbol with the byte array (push fields in correct order)
       global.get $objectClass ;; $class
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object ;; nextObject (ref null $Object)
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       ref.as_non_null
       ;; Create the byte array with ASCII values for "workload" as the last field
       ;; 'w'=119, 'o'=111, 'r'=114, 'k'=107, 'l'=108, 'o'=111, 'a'=97, 'd'=100
       i32.const 119       ;; 'w'
       i32.const 111       ;; 'o'
       i32.const 114       ;; 'r'
       i32.const 107       ;; 'k'
       i32.const 108       ;; 'l'
       i32.const 111       ;; 'o'
       i32.const 97        ;; 'a'
       i32.const 100       ;; 'd'
       array.new_fixed $ByteArray 8
       struct.new $Symbol
       local.set $workloadSelector
       ;; Link selector to object chain
       local.get $vm
       struct.get $VirtualMachine $lastObject
       ref.as_non_null
       local.get $workloadSelector
       ref.as_non_null
       struct.set $Object $nextObject
       local.get $workloadSelector
       ref.as_non_null
       local.get $vm
       struct.set $VirtualMachine $lastObject

       ;; Create literals array with workload selector at index 0
       ref.null eq
       i32.const 1
       array.new $ObjectArray
       local.set $slots
       local.get $slots
       i32.const 0  ;; index 0
       local.get $workloadSelector
       ref.as_non_null
       array.set $ObjectArray

       ;; Create main method (sends >>workload message)
       global.get $objectClass ;; class (ref $Class)
       call $nextIdentityHash  ;; identityHash (i32)
       i32.const 6         ;; format (i32)
       i32.const 14        ;; size (i32)
       ref.null $Object ;; nextObject (ref null $Object)
       local.get $slots      ;; slots (ref $ObjectArray)
       i32.const 0         ;; header (i32)
       local.get $mainBytecodes ;; bytecodes (ref null $ByteArray)
       i32.const 0         ;; invocationCount (i32)
       i32.const 0         ;; functionIndex (i32)
       global.get $translationThreshold
       i32.const 0         ;; isInstalled (i32)
       struct.new $CompiledMethod
       local.set $newObject
       local.get $newObject
       local.set $mainMethod
       ;; Link this object to the chain
       local.get $vm
       struct.get $VirtualMachine $lastObject
       local.get $newObject
       struct.set $Object $nextObject
       local.get $newObject
       local.get $vm
       struct.set $VirtualMachine $lastObject

       ;; Create workload method (does the intensive computation)
       ;; First create the literals array that the workload method needs
       ref.null eq
       i32.const 4          ;; Need 4 literal slots (0-3, but we only use 1-3)
       array.new $ObjectArray
       ref.as_non_null
       local.set $workloadSlots
       
       ;; Fill the slots with SmallInteger literals we actually use
       local.get $workloadSlots
       i32.const 0  ;; literal[0] = 0 (unused but keep for consistency)
       i32.const 0
       call $smallIntegerForValue
       ref.as_non_null
       array.set $ObjectArray
       
       local.get $workloadSlots
       i32.const 1  ;; literal[1] = 1
       i32.const 1
       call $smallIntegerForValue
       ref.as_non_null
       array.set $ObjectArray
       
       local.get $workloadSlots
       i32.const 2  ;; literal[2] = 2
       i32.const 2
       call $smallIntegerForValue
       ref.as_non_null
       array.set $ObjectArray
       
       local.get $workloadSlots
       i32.const 3  ;; literal[3] = 3
       i32.const 3
       call $smallIntegerForValue
       ref.as_non_null
       array.set $ObjectArray
       
       ;; Now create the workload method with proper slots
       global.get $objectClass ;; class (ref $Class)
       call $nextIdentityHash  ;; identityHash (i32)
       i32.const 6         ;; format (i32)
       i32.const 14        ;; size (i32)
       ref.null $Object ;; nextObject (ref null $Object)
       local.get $workloadSlots ;; slots (ref $ObjectArray) - now has proper literals
       i32.const 0         ;; header (i32)
       local.get $workloadBytecodes ;; bytecodes (ref null $ByteArray)
       i32.const 0         ;; invocationCount (i32)
       i32.const 0         ;; functionIndex (i32)
       global.get $translationThreshold
       i32.const 0         ;; isInstalled (i32)
       struct.new $CompiledMethod
       local.set $newObject
       local.get $newObject
       local.set $workloadMethod
       ;; Link this object to the chain
       local.get $vm
       struct.get $VirtualMachine $lastObject
       ref.as_non_null
       local.get $newObject
       struct.set $Object $nextObject
       local.get $newObject
       local.get $vm
       struct.set $VirtualMachine $lastObject

       ;; Install method dictionary in SmallInteger class
       global.get $smallIntegerClass
       ref.as_non_null
       local.get $methodDictionary
       ref.as_non_null
       struct.set $Class $methodDictionary
       
       ;; Install workload selector in dictionary keys array
       local.get $methodDictionary
       ref.as_non_null
       struct.get $Dictionary $keys
       ref.as_non_null
       i32.const 0  ;; index 0
       local.get $workloadSelector
       ref.as_non_null
       array.set $ObjectArray
       
       ;; Install workload method in dictionary values array
       local.get $methodDictionary
       ref.as_non_null
       struct.get $Dictionary $values
       ref.as_non_null
       i32.const 0  ;; index 0
       local.get $workloadMethod
       ref.as_non_null
       array.set $ObjectArray
       
       ;; Set method dictionary count
       local.get $methodDictionary
       ref.as_non_null
       i32.const 1
       struct.set $Dictionary $count
       
       ;; Mark method as installed
       local.get $workloadMethod
       ref.as_non_null
       i32.const 1
       struct.set $CompiledMethod $isInstalled
       
       ;; Set as main method for execution
       local.get $mainMethod
       global.set $mainMethod
       
       ;; Return success
       i32.const 1
       )

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
       local.get $bytecode
       i32.const 0x20  ;; Push literal base
       i32.ge_u
       local.get $bytecode
       i32.const 0x2F  ;; Push literal end
       i32.le_u
       i32.and
       if
       ;; Extract literal index
       local.get $bytecode
       i32.const 0x20
       i32.sub
       local.set $selectorIndex  ;; Reuse variable for literal index
       
       ;; Get method's literal array
       local.get $context
       struct.get $Context $method
       ref.as_non_null
       struct.get $CompiledMethod $slots
       ref.as_non_null
       local.tee $slots
       
       ;; Check bounds
       local.get $selectorIndex
       local.get $slots
       array.len
       i32.ge_u
       if
       ;; Index out of bounds - push 0 as fallback
       local.get $context
       i32.const 0
       call $smallIntegerForValue
       ref.as_non_null
       call $pushOnStack
       else
       ;; Get literal at index and push
       local.get $context
       local.get $slots
       local.get $selectorIndex
       array.get $ObjectArray
       ref.as_non_null
       call $pushOnStack
       end ;; else
       
       i32.const 0  ;; Continue execution
       return
       end ;; if
       
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
       call $valueOfSmallInteger
       local.set $int1
       
       local.get $value2
       call $valueOfSmallInteger
       local.set $int2
       
       ;; Multiply integers
       local.get $int1
       local.get $int2
       i32.mul
       local.set $result
       
       ;; Create result SmallInteger and push onto stack
       local.get $context
       local.get $result
       call $smallIntegerForValue
       ref.as_non_null
       call $pushOnStack
       
       i32.const 0  ;; Continue execution
       return
       end ;; if
       
       local.get $bytecode
       i32.const 0xB0  ;; Add (pop two, add, push result)
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
       call $valueOfSmallInteger
       local.set $int1
       
       local.get $value2
       call $valueOfSmallInteger
       local.set $int2
       
       ;; Add integers
       local.get $int1
       local.get $int2
       i32.add
       local.set $result
       
       ;; Create result SmallInteger and push onto stack
       local.get $context
       local.get $result
       call $smallIntegerForValue
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
       local.tee $slots
       
       ;; Check bounds before accessing
       local.get $selectorIndex
       local.get $slots
       array.len
       i32.ge_u
       if
       ;; Index out of bounds - push receiver back and continue
       local.get $context
       local.get $receiver
       ref.as_non_null
       call $pushOnStack
       i32.const 0
       return
       end ;; if
       
       ;; Get selector at index
       local.get $slots
       local.get $selectorIndex
       array.get $ObjectArray
       local.set $selector
       
       ;; No need to increment PC since we're not reading next byte
       
       ;; Get receiver's class
       local.get $receiver
       call $classOfObject
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
       local.get $vm
       struct.set $VirtualMachine $activeContext
       
       i32.const 0 ;; Continue execution in new context
       return
       end ;; if
       
       ;; Unknown bytecode - continue execution
       i32.const 0
       ) ;; (func $interpretBytecode

 ;; Main interpreter loop
 (func $interpret (export "interpret")
       (result i32)
       
       (local $vm (ref $VirtualMachine))
       (local $context (ref $Context))
       (local $method (ref $CompiledMethod))
       (local $bytecode i32)
       (local $pc i32)
       (local $stack (ref $ObjectArray))
       (local $slots (ref $ObjectArray))
       (local $args (ref $ObjectArray))
       (local $temps (ref $ObjectArray))
       (local $receiver eqref)
       (local $resultValue eqref)
       (local $invocationCount i32)
       (local $bytecodes (ref $ByteArray))
       (local $funcIndex i32)

       ;; Create execution stack with proper size
       ref.null eq
       i32.const 20
       array.new $ObjectArray
       local.set $stack
       ;; Create empty arrays for slots, args, temps
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $slots
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $args
       ref.null eq
       i32.const 0
       array.new $ObjectArray
       local.set $temps
       
       ;; Create SmallInteger 100 as receiver (for more intensive computation)
       i32.const 100
       ref.i31
       local.set $receiver
       
       ;; Create initial context for main method
       global.get $objectClass ;; class (Context is-a Object for now)
       i32.const 2001       ;; identityHash
       i32.const 14         ;; format (MethodContext)
       i32.const 14         ;; size
       ref.null $Object     ;; nextObject
       local.get $slots     ;; slots (non-nullable)
       ref.null $Context    ;; sender
       i32.const 0          ;; pc
       i32.const 0          ;; sp (stack pointer)
       global.get $mainMethod ;; method
       local.get $receiver   ;; receiver (SmallInteger 3)
       local.get $args      ;; args (non-nullable)
       local.get $temps     ;; temps (non-nullable)
       local.get $stack     ;; stack (non-nullable)
       struct.new $Context
       local.get $vm
       struct.set $VirtualMachine $activeContext

       block $finished
       
       ;; Main execution loop
       loop $execution_loop
       ;; Get active context
       local.get $vm
       struct.get $VirtualMachine $activeContext
       local.tee $context
       ref.is_null
       if
       ;; No active context - execution complete
       br $finished
       end ;; if
       
       ;; Cast to non-null and get method
       local.get $context
       ref.as_non_null
       struct.get $Context $method
       local.tee $method
       
       ;; Increment invocation count
       local.get $method
       struct.get $CompiledMethod $invocationCount
       i32.const 1
       i32.add
       local.set $invocationCount
       
       local.get $method
       local.get $invocationCount
       struct.set $CompiledMethod $invocationCount
       
       ;; Check if we should trigger translation
       local.get $invocationCount
       local.get $method
       struct.get $CompiledMethod $translationThreshold
       i32.eq
       local.get $vm
       struct.get $VirtualMachine $jitEnabled
       i32.and
       if
       ;; Check if method is installed in a method dictionary
       local.get $method
       struct.get $CompiledMethod $isInstalled
       i32.const 1
       i32.eq
       if
       ;; Check if method already has compiled function
       local.get $method
       ref.as_non_null
       call $isTranslated
       i32.eqz ;; Only translate if not already translated.
       if
       ;; Trigger method translation.
       local.get $method
       ref.as_non_null
       call $triggerMethodTranslation
       end ;; if
       end ;; if
       end ;; if
       
       ;; Check if method has compiled function
       local.get $method
       ref.as_non_null
       call $isTranslated
       if
       ;; Execute compiled WASM function
       local.get $method
       struct.get $CompiledMethod $functionIndex
       local.set $funcIndex
       
       local.get $context
       ref.as_non_null
       local.get $funcIndex
       call $executeTranslatedMethod
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
       local.get $vm
       struct.get $VirtualMachine $activeContext
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
       local.get $vm
       struct.get $VirtualMachine $activeContext
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
       ;; Context switched (message send or return)
       local.get $vm
       struct.get $VirtualMachine $activeContext
       ref.as_non_null
       struct.get $Context $pc
       i32.eqz
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
       local.get $resultValue
       call $valueOfSmallInteger
       
       ;; Report result to JS
       call $reportResult
       
       end ;; loop $execution_loop
       end ;; block $finished

       i32.const 1 ;; success
       return
       ) ;; (func $interpret
 )
