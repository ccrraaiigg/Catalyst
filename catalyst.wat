;; catalyst.wat: multiple simultaneous Catalyst Smalltalk virtual
;; machines, with method translation
;;
;; This source code is a decompilation of the Smalltalk
;; implementation.
;;
;; Craig Latta, July 2025

(module

 ;; imported JS functions

 ;; function 0
 
 (import "env" "reportResult"
	 (func $reportResult
	       (param i32))) ;; result

 ;; JS translates method and installs translation function
 ;; function 1

 (import "env" "translateMethod"
	 (func $translateMethod
	       (param (ref eq)) ;; method
	       (param i32)))    ;; receiver identity hash

 ;; function 2
 
 (import "env" "debugLog"
	 (func $debugLog
	       (param i32))) ;; level

 ;; linear memory for efficient byte transfer between WASM and JS
 (export "bytes" (memory $0))

 (export "functionTable" (table $functionTable))

 ;; functions exported to JS (in roughly the order JS uses them).

 (export "newVirtualMachine" (func $newVirtualMachine))
 (export "createMinimalObjectMemory" (func $createMinimalObjectMemory))
 (export "resetMinimalMemory" (func $resetMinimalMemory))
 (export "interpret" (func $interpret))
 (export "byteArrayAt" (func $byteArrayAt))
 (export "byteArrayLength" (func $byteArrayLength))
 (export "copyByteArrayToMemory" (func $copyByteArrayToMemory))
 (export "methodBytecodes" (func $methodBytecodes))
 (export "setMethodFunctionIndex" (func $setMethodFunctionIndex))
 (export "getMethodFunctionIndex" (func $getMethodFunctionIndex))
 (export "onContextPush" (func $onContextPush))
 (export "popFromContext" (func $popFromContext))
 (export "valueOfSmallInteger" (func $valueOfSmallInteger))
 (export "smallIntegerForValue" (func $smallIntegerForValue))
 (export "classOfObject" (func $classOfObject))
 (export "contextReceiver" (func $contextReceiver))
 (export "methodLiterals" (func $methodLiterals))
 (export "contextLiteralAt" (func $contextLiteralAt))

 (elem declare func $fixMetalevelFields)
 
 ;; types defining Smalltalk classes
 ;;
 ;; To start, we only define classes with functions which must exist
 ;; for the virtual machine to operate (and perform a minimal demo),
 ;; and the superclasses of such classes which define instance
 ;; variables. We can dynamically add more classes and methods
 ;; remotely from SqueakJS later, through behavior similar to
 ;; $createMinimalObjectMemory, using the exported linear memory as a
 ;; communication channel.
 ;;
 ;; Instances of Smalltalk class SmallInteger are of built-in
 ;; reference type i31, each instance of every other class is of a
 ;; reference type using a user-defined struct type. The common
 ;; supertype of all those reference types is built-in reference type
 ;; (ref eq). The type for raw arrays of bytes has built-in type i8 as
 ;; its default element type, and $ByteArray is a Smalltalk object
 ;; type that wraps it. There's a similar relationship between
 ;; $wordArray and $WordArray, and between $objectArray and $Array.
 ;; 
 ;; For Smalltalk, we use the terms "slots" and "methods". For WASM,
 ;; we use "fields" and "functions". Smalltalk source is "compiled" to
 ;; a struct of type $CompiledMethod. A $CompiledMethod is
 ;; "translated" to a WASM function. In the case of this virtual
 ;; machine code, Smalltalk source can be compiled to a compiled
 ;; method and decompiled into this source.
 ;; 
 ;; The nullable fields are only nullable because their initial values
 ;; aren't always knowable at creation time.
 ;; 
 ;; Behind the scenes here in the virtual machine, null references in
 ;; fields of Smalltalk objects are given as the nil Smalltalk object
 ;; when anything at the Smalltalk level asks about them. This saves
 ;; us the effort of fixing up them up to be nil.

 (rec ;; recursive (mutually referential) type definitions
  (type $objectArray
	;; null is taken to be nil as far as the Smalltalk level is
	;; concerned.
	(array (mut (ref null eq))))
  
  (type $byteArray
	(array (mut i8)))
  
  (type $wordArray
	(array (mut i32)))
  
  (type $Object (sub
		 (struct
		  ;; $Class or $Metaclass
		  (field $class (mut (ref eq)))
		  
		  (field $identityHash (mut i32))
		  (field $nextObject (mut (ref null eq))))))

  (type $UndefinedObject (sub $Object
			  (struct
			   ;; $Class or $Metaclass
			   (field $class (mut (ref eq)))
			   
			   (field $identityHash (mut i32))
			   (field $nextObject (mut (ref null eq))))))
  
  (type $Array (sub $Object 
		    (struct
		     ;; $Class or $Metaclass
		     (field $class (mut (ref eq)))
		     
		     (field $identityHash (mut i32)) 
		     (field $nextObject (mut (ref null eq))) 
		     (field $array (mut (ref $objectArray))))))

  (type $ByteArray (sub $Object 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut (ref eq)))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut (ref null eq))) 
			 (field $array (ref $byteArray)))))

  (type $WordArray (sub $Object 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut (ref eq)))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut (ref null eq))) 
			 (field $array (ref $wordArray)))))

  (type $VariableObject (sub $Object 
			     (struct
			      ;; $Class or $Metaclass
			      (field $class (mut (ref eq)))
			      
			      (field $identityHash (mut i32)) 
			      (field $nextObject (mut (ref null eq)))

			      ;; $Array, $ByteArray, or $WordArray
			      (field $slots (mut (ref eq))))))

  (type $Symbol (sub $VariableObject 
		     (struct
		      ;; $Class or $Metaclass
		      (field $class (mut (ref eq)))
		      
		      (field $identityHash (mut i32)) 
		      (field $nextObject (mut (ref null eq)))

		      ;; $Array, $ByteArray, or $WordArray
		      (field $slots (mut (ref eq))))))

  (type $Dictionary (sub $Object 
			 (struct
			  ;; $Class or $Metaclass
			  (field $class (mut (ref eq)))
			  
			  (field $identityHash (mut i32)) 
			  (field $nextObject (mut (ref null eq))) 
			  (field $keys (mut (ref $Array))) 
			  (field $values (mut (ref $Array))) 
			  (field $count (mut i32)))))

  (type $Behavior (sub $Object 
		       (struct
			;; $Class or $Metaclass
			(field $class (mut (ref eq)))
			
			(field $identityHash (mut i32)) 
			(field $nextObject (mut (ref null eq)))

			;; a $Class or $Metaclass
			(field $superclass (mut (ref null eq))) 
			(field $methodDictionary (mut (ref $Dictionary))) 
			(field $format (mut i32)))))

  (type $ClassDescription (sub $Behavior 
			       (struct
				;; $Class or $Metaclass
				(field $class (mut (ref eq)))
				
				(field $identityHash (mut i32)) 
				(field $nextObject (mut (ref null eq)))

				;; a $Class or $Metaclass
				(field $superclass (mut (ref null eq))) 
				(field $methodDictionary (mut (ref $Dictionary))) 
				(field $format (mut i32)) 
				(field $instanceVariableNames (mut (ref $Array))) 
				(field $baseID (mut (ref $ByteArray))))))

  (type $Class (sub $ClassDescription 
		    (struct
		     ;; $Class or $Metaclass
		     (field $class (mut (ref eq)))
		     
		     (field $identityHash (mut i32)) 
		     (field $nextObject (mut (ref null eq)))

		     ;; a $Class or $Metaclass
		     (field $superclass (mut (ref null eq))) 
		     (field $methodDictionary (mut (ref $Dictionary))) 
		     (field $format (mut i32)) 
		     (field $instanceVariableNames (mut (ref $Array))) 
		     (field $baseID (mut (ref $ByteArray))) 
		     (field $subclasses (mut (ref $Array))) 
		     (field $name (mut (ref $Symbol))) 
		     (field $classPool (mut (ref $Dictionary))) 
		     (field $sharedPools (mut (ref $Array))))))

  (type $Metaclass (sub $ClassDescription 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut (ref eq)))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut (ref null eq)))

			 ;; a $Class or $Metaclass
			 (field $superclass (mut (ref null eq))) 
			 (field $methodDictionary (mut (ref $Dictionary))) 
			 (field $format (mut i32)) 
			 (field $instanceVariableNames (mut (ref $Array))) 
			 (field $baseID (mut (ref $ByteArray))) 
			 (field $thisClass (mut (ref $Class))))))

  (type $CompiledMethod (sub $VariableObject 
			     (struct
			      ;; $Class or $Metaclass
			      (field $class (mut (ref eq)))
			      
			      (field $identityHash (mut i32)) 
			      (field $nextObject (mut (ref null eq)))

			      ;; $Array, $ByteArray, or $WordArray
			      (field $slots (mut (ref eq))) 
			      (field $literals (ref $Array)) 
			      (field $header i32) 
			      (field $invocationCount (mut i32)) 
			      (field $functionIndex (mut i32)) 
			      (field $translationThreshold i32) 
			      (field $isInstalled (mut i32)))))

  (type $Context (sub $Object 
		      (struct
		       ;; $Class or $Metaclass
		       (field $class (mut (ref eq))) 

		       (field $identityHash (mut i32)) 
		       (field $nextObject (mut (ref null eq))) 
		       (field $sender (mut (ref null $Context))) 
		       (field $pc (mut i32)) 
		       (field $sp (mut i32))
		       (field $method (mut (ref $CompiledMethod)))		       
		       (field $receiver (mut (ref eq))) 
		       (field $args (mut (ref $Array))) 
		       (field $temps (mut (ref $Array))) 
		       (field $stack (mut (ref $Array))))))

  (type $PICEntry 
	(struct 
	 (field $selector (mut (ref eq))) 
	 (field $receiverClass (mut (ref eq))) 
	 (field $method (mut (ref $CompiledMethod)))
	 (field $hitCount (mut i32)))) 

  (type $VirtualMachine 
	(struct
	 ;; created with a null $activeContext; it's set later
	 (field $activeContext (mut (ref null $Context)))
	 
	 (field $translationEnabled (mut i32)) 
	 (field $methodCache (mut (ref $objectArray))) 
	 (field $functionTableBaseIndex (mut i32)) 
	 (field $translationThreshold (mut i32)) 
	 (field $nextIdentityHash (mut i32))

	 ;; created with null $firstObject and $lastObject; they're
	 ;; set later
	 (field $firstObject (mut (ref null eq)))
	 (field $lastObject (mut (ref null eq)))

	 ;; frequently used for $superclass in $newSubclassOfWithName
	 (field $classObject (mut (ref null $Class)))

	 (field $classMetaclass (mut (ref null $Class)))
	 (field $classClass (mut (ref null $Class)))
	 (field $classArray (mut (ref null $Class)))
	 (field $classByteArray (mut (ref null $Class)))
	 (field $classWordArray (mut (ref null $Class)))
	 (field $classContext (mut (ref null $Class)))
	 (field $classCompiledMethod (mut (ref null $Class)))
	 (field $classSymbol (mut (ref null $Class)))
	 (field $classSmallInteger (mut (ref null $Class))))))

 ;; function types

 (type $enumerator (func
		    (param (ref $VirtualMachine))
		    (param (ref null eq))))
 
 ;; exception types

 (type $messageNotUnderstoodType (func
				  (param (ref $Symbol)))) ;; selector

 (type $emptyStackType (func))
 (type $valuesLeftOnStackType (func))
 (type $outOfBoundsType (func
       (param i32)))
 
 ;; exception tags

 (tag $messageNotUnderstood (type $messageNotUnderstoodType))
 (tag $emptyStack (type $emptyStackType))
 (tag $valuesLeftOnStack (type $valuesLeftOnStackType))
 (tag $outOfBounds (type $outOfBoundsType))
 
 ;; Reference-type globals are nullable due to current WASM
 ;; limitations, but are enforced to be non-null after object memory
 ;; creation.

 (global $benchmarkSelector (mut (ref null $Symbol)) (ref.null none))
 
 ;; start of staging bytes
 (global $byteArrayCopyPointer (mut i32) (i32.const 1024))

 ;; linear memory for staging byte arrays visible to JS. See $copyByteArrayToMemory.
 (memory $0 1)

 ;; translated methods function table (the only table in this module)
 (table $functionTable 100 funcref)

 ;; function 3: Return whether two $byteArrays are equivalent.
 
 (func $byteArrayIsEquivalentTo
       (param $firstObject (ref $ByteArray))
       (param $secondObject (ref $ByteArray))
       (result i32)

       (local $firstArray (ref $byteArray))
       (local $secondArray (ref $byteArray))
       (local $length i32)
       (local $index i32)

       ;; Quick reference equality check first
       (if (result i32)
	   (ref.eq
	    (local.get $firstObject)
	    (local.get $secondObject))
	   (then
	    (return
	      (i32.const 1)))
	   (else
	    (local.set $firstArray
		       (struct.get $ByteArray $array
				   (local.get $firstObject)))

	    (local.set $secondArray
		       (struct.get $ByteArray $array
				   (local.get $secondObject)))

	    (if (result i32)
		(ref.eq
		 (local.get $firstArray)
		 (local.get $secondArray))
		(then
		 (return
		   (i32.const 1)))
		(else
		 ;; Check lengths
		 (if (result i32)
		     (i32.ne 
		      (local.tee $length
				 (array.len (local.get $firstArray)))
		      (array.len
		       (local.get $secondArray)))
		     (then
		      (return
			(i32.const 0)))
		     (else
		      ;; Compare elements
		      (loop $loop (result i32)
			    (if (result i32)
				(i32.eq
				 (local.get $index)
				 (local.get $length))
				(then
				 ;; All elements equal
				 (return (i32.const 1)))  
				(else
				 ;; Compare current elements
				 (if (result i32)
				     (i32.ne
				      (array.get_u $byteArray
						   (local.get $firstArray)
						   (local.get $index))
				      (array.get_u $byteArray
						   (local.get $secondArray)
						   (local.get $index)))
				     (then
				      ;; Elements different
				      (return (i32.const 0)))  
				     (else
				      (local.set $index
						 (i32.add
						  (local.get $index)
						  (i32.const 1)))
				      (br $loop)))))))))))))

 ;; function 4
 
 (func $symbolIsEquivalentTo
       (param $firstSymbol (ref $Symbol))
       (param $secondSymbol (ref $Symbol))
       (result i32)

       (if (result i32)
	   (ref.eq
	    (local.get $firstSymbol)
	    (local.get $secondSymbol))
	   (then
	    (return
	      (i32.const 1)))
	   (else
	    (call $byteArrayIsEquivalentTo
		  (ref.cast (ref $ByteArray)
			    (struct.get $Symbol $slots
					(local.get $firstSymbol)))
		  (ref.cast (ref $ByteArray)
			    (struct.get $Symbol $slots
					(local.get $secondSymbol)))))))

 ;; function 5

 (func $newArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $objectArray)) 
       (result (ref $Array))
       
       (struct.new $Array
		   ;; $class
		   (if (result (ref eq))
		       (ref.is_null
			(struct.get $VirtualMachine $classArray 
				    (local.get $vm)))
		       (then
			(ref.cast (ref eq)
				  (ref.i31
				   (i32.const -1337))))
		       (else
			(ref.cast (ref eq)
				  (struct.get $VirtualMachine $classArray 
					      (local.get $vm)))))
		   
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array

 ;; function 6
 
 (func $newByteArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $byteArray)) 
       (result (ref $ByteArray))
       
       (struct.new $ByteArray
		   (if (result (ref eq))
		       ;; class
		       (ref.is_null
			(struct.get $VirtualMachine $classByteArray 
				    (local.get $vm)))
		       (then
			(ref.cast (ref eq)
				  (ref.i31
				   (i32.const -1337))))
		       (else
			(ref.cast (ref eq)
				  (struct.get $VirtualMachine $classByteArray 
					      (local.get $vm)))))
		   
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array

 ;; function 7
 
 (func $newWordArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $wordArray)) 
       (result (ref $WordArray))
       
       (struct.new $WordArray
		   ;; class
		   (if (result (ref eq))
		       (ref.is_null
			(struct.get $VirtualMachine $classWordArray 
				    (local.get $vm)))
		       (then
			(ref.cast (ref eq)
				  (ref.i31
				   (i32.const -1337))))
		       (else
			(ref.cast (ref eq)
				  (struct.get $VirtualMachine $classWordArray 
					      (local.get $vm)))))

		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array

 ;; function 8
 
 (func $newDictionary
       (param $vm (ref $VirtualMachine)) 
       (result (ref $Dictionary))
       
       (struct.new $Dictionary
		   ;; $class to be set later, to class Dictionary
		   (if (result (ref eq))
		       (ref.is_null
			(struct.get $VirtualMachine $classObject
				    (local.get $vm)))
		       (then
			(ref.cast (ref eq)
				  (ref.i31
				   (i32.const -1337))))
		       (else
			(ref.cast (ref eq)      
				  (struct.get $VirtualMachine $classObject
					      (local.get $vm)))))
		   
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (call $newArray         ;; $keys
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 10))) ;; initial capacity 10
		   (call $newArray         ;; $values
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 10))) ;; initial capacity 10         
		   (i32.const 0)))         ;; $count

 ;; function 9
 
 (func $dictionaryAdd
       (param $vm (ref $VirtualMachine))
       (param $dictionary (ref $Dictionary))
       (param $key (ref eq))
       (param $value (ref eq))
       
       (local $keys (ref $Array))
       (local $values (ref $Array))
       (local $count i32)
       (local $capacity i32)
       (local $newKeys (ref $Array))
       (local $newValues (ref $Array))
       (local $newKeysArray (ref $objectArray))
       (local $newValuesArray (ref $objectArray))
       (local $index i32)
       (local $existingKey (ref null eq))
       
       (local.set $keys
		  (struct.get $Dictionary $keys
			      (local.get $dictionary)))
       (local.set $values
		  (struct.get $Dictionary $values
			      (local.get $dictionary)))
       (local.set $count
		  (struct.get $Dictionary $count
			      (local.get $dictionary)))
       (local.set $capacity
		  (array.len
		   (struct.get $Array $array
			       (local.get $keys))))
       
       ;; Check if we need to grow
       (if
	(i32.ge_u (local.get $count) (local.get $capacity))
	(then
	 ;; Need to grow - create new arrays with capacity + 10
	 (local.set $newKeysArray
		    (array.new $objectArray
			       (ref.null none)
			       (i32.add
				(local.get $capacity)
				(i32.const 10))))
	 (local.set $newValuesArray
		    (array.new $objectArray
			       (ref.null none)
			       (i32.add
				(local.get $capacity)
				(i32.const 10))))
	 
	 ;; Copy existing elements
	 (local.set $index (i32.const 0))
	 (block $done_copying
	   (loop $copy_loop
		 (br_if $done_copying
			(i32.ge_u
			 (local.get $index)
			 (local.get $count)))
		 
		 (array.set $objectArray
			    (local.get $newKeysArray)
			    (local.get $index)
			    (array.get $objectArray
				       (struct.get $Array $array
						   (local.get $keys))
				       (local.get $index)))
		 (array.set $objectArray
			    (local.get $newValuesArray)
			    (local.get $index)
			    (array.get $objectArray
				       (struct.get $Array $array
						   (local.get $values))
				       (local.get $index)))
		 
		 (local.set $index
			    (i32.add
			     (local.get $index)
			     (i32.const 1)))
		 (br $copy_loop)))
	 
	 ;; Create new Array objects and update dictionary
	 (local.set $newKeys
		    (call $newArray
			  (local.get $vm)
			  (local.get $newKeysArray)))
	 (local.set $newValues
		    (call $newArray
			  (local.get $vm)
			  (local.get $newValuesArray)))
	 
	 (struct.set $Dictionary $keys
		     (local.get $dictionary)
		     (local.get $newKeys))
	 (struct.set $Dictionary $values
		     (local.get $dictionary)
		     (local.get $newValues))
	 
	 (local.set $keys
		    (local.get $newKeys))
	 (local.set $values
		    (local.get $newValues))))
       
       ;; Check if key is a Symbol and if an equivalent Symbol already exists
       (if
	(ref.test
	 (ref $Symbol)
	 (local.get $key))
	(then
	 ;; Key is a Symbol - check for equivalent existing Symbol
	 (local.set $index
		    (i32.const 0))
	 (block $check_done
	   (loop $check_loop
		 (br_if $check_done
			(i32.ge_u
			 (local.get $index)
			 (local.get $count)))
		 
		 ;; Get existing key at index
		 (local.set $existingKey
			    (array.get $objectArray
				       (struct.get $Array $array
						   (local.get $keys))
				       (local.get $index)))
		 
		 ;; Check if existing key is also a Symbol and is equivalent
		 (if
		  (ref.test
		   (ref $Symbol)
		   (local.get $existingKey))
		  (then
		   (if (call $symbolIsEquivalentTo
			     (ref.cast (ref $Symbol)
				       (local.get $key))
			     (ref.cast (ref $Symbol)
				       (local.get $existingKey)))
		       (then
			;; Found equivalent Symbol - don't add, just return
			(return)))))
		 
		 (local.set $index
			    (i32.add
			     (local.get $index)
			     (i32.const 1)))
		 (br $check_loop)))))
       
       ;; Add the new key/value pair
       (array.set $objectArray
		  (struct.get $Array $array
			      (local.get $keys))
		  (local.get $count)
		  (local.get $key))
       (array.set $objectArray
		  (struct.get $Array $array
			      (local.get $values))
		  (local.get $count)
		  (local.get $value))
       
       ;; Increment count
       (struct.set $Dictionary $count
		   (local.get $dictionary)
		   (i32.add
		    (local.get $count)
		    (i32.const 1))))

 ;; function 10: Link $objects via their $nextObject fields.
 
 (func $linkObjects
       (param $vm (ref $VirtualMachine)) 
       (param $objects (ref $objectArray))
       
       (local $previousObject (ref null eq))
       (local $nextObject (ref null eq))
       (local $limit i32)
       (local $index i32)
       (local $scratch (ref $VirtualMachine))
       
       (local.set $limit
		  (array.len
		   (local.get $objects)))
       
       (local.set $index
		  (i32.const 0))
       
       (loop $link
	     (if
	      (i32.eq
	       (local.get $index)
	       (local.get $limit))
	      (then
	       (return)))

	     (local.tee $nextObject
			(array.get $objectArray
				   (local.get $objects)
				   (local.get $index)))

	     (if
	      (i32.eqz
	       (ref.is_null))
	      (then
	       (local.set $previousObject
			  (struct.get $VirtualMachine $lastObject
				      (local.get $vm)))

	       (struct.set $VirtualMachine $lastObject
			   (block (result (ref $VirtualMachine))
			     (local.set $scratch
					(local.get $vm))

			     (struct.set $Object $nextObject
					 (ref.cast (ref $Object)
						   (local.get $previousObject))
					 (local.get $nextObject))

			     (local.get $scratch))
			   (local.get $nextObject))

	       (local.set $index
			  (i32.add
			   (local.get $index)
			   (i32.const 1)))
	       
	       (br $link)))))

 ;; function 11
 
 (func $newEmptyArray
       (param $vm (ref $VirtualMachine)) 
       (result (ref $Array))
       
       (call $newArray                   
	     (local.get $vm)
	     (array.new $objectArray
			(ref.null none)  ;; default array element type (irrelevant here)
			(i32.const 0)))) ;; empty

 ;; function 12: Add an element to the end of an $Array's elements, by
 ;; replacing the elements array.

 (func $arrayAdd
       (param $array (ref $Array))
       (param $element (ref eq))

       (local $newObjectArray (ref $objectArray))
       (local $oldObjectArray (ref $objectArray))
       (local $index i32)
       (local $limit i32)

       (local.set $oldObjectArray
		  (struct.get $Array $array
			      (local.get $array)))

       (local.set $index
		  (i32.const 0))
       
       (local.set $limit
		  (array.len (local.get $oldObjectArray)))
       
       ;; Create a new $objectArray that is one larger than the old
       ;; one.
       (local.set $newObjectArray
		  (array.new $objectArray
			     (ref.null none)
			     (i32.add
			      (local.get $limit)
			      (i32.const 1))))

       (if
	(i32.gt_u
	 (local.get $limit)
	 (i32.const 0))
	(then
	 ;; Copy the contents of the old array into the new one.
	 (loop $loop
	       (array.set $objectArray
			  (local.get $newObjectArray)
			  (local.get $index)
			  (array.get $objectArray
				     (local.get $oldObjectArray)
				     (local.get $index)))

	       (br_if $loop
		      (i32.lt_s
		       (local.tee $index
				  (i32.add
				   (local.get $index)
				   (i32.const 1)))
		       (local.get $limit))))))
       
       ;; Put the new element in the last slot of the new array.
       (array.set $objectArray
		  (local.get $newObjectArray)
		  (local.get $index)
		  (local.get $element))
       
       ;; Set the $array's $objectArray to the new array.
       (struct.set $Array $array
		   (local.get $array)
		   (local.get $newObjectArray)))

 ;; function 13
 
 (func $newSubclassOfWithName
       (param $vm (ref $VirtualMachine))
       (param $superclass (ref null $Class))
       (param $name (ref $Symbol)) 
       (result (ref $Class))

       (local $class (ref $Class))
       (local $metaclass (ref $Metaclass))
       (local $bootstrapping i32)

       (local.set $bootstrapping (i32.const 0))
       
       (local.set $class
		  (struct.new $Class
			      ;; $class to be set later, to an appropriate Metaclass.
			      (if (result (ref eq))
				  (ref.is_null
				   (struct.get $VirtualMachine $classObject
					       (local.get $vm)))
				  (then
				   (local.set $bootstrapping (i32.const 1))

				   (ref.cast (ref eq)
					     (ref.i31
					      (i32.const -1337))))
				  (else
				   (ref.cast (ref eq)
					     (struct.get $VirtualMachine $classObject
							 (local.get $vm)))))

			      (call $nextIdentityHash           ;; $identityHash
				    (local.get $vm))
			      (ref.null none)                   ;; $nextObject to be set later
			      (local.get $superclass)           ;; $superclass
			      (call $newDictionary              ;; $methodDictionary
				    (local.get $vm))
			      (i32.const 0)                     ;; $format to be set later
			      (call $newEmptyArray              ;; $instanceVariableNames
				    (local.get $vm))
			      (call $newByteArray               ;; $baseID to be set later
				    (local.get $vm)
				    (array.new $byteArray
					       (i32.const 0)
					       (i32.const 16))) 
			      (call $newEmptyArray              ;; $subclasses
				    (local.get $vm))
			      (local.get $name)                 ;; $name
			      (call $newDictionary              ;; $classPool
				    (local.get $vm))
			      (call $newEmptyArray              ;; $sharedPools
				    (local.get $vm))))

       (if
	(i32.eqz
	 (ref.is_null
	  (local.get $superclass)))
	(then
	 (call $arrayAdd
	       (struct.get $Class $subclasses
			   (local.get $superclass))
	       (local.get $class))))
       
       (local.set $metaclass
		  (struct.new $Metaclass
			      ;; $class
			      (if (result (ref eq))
				  (ref.is_null
				   (struct.get $VirtualMachine $classMetaclass 
					       (local.get $vm)))
				  (then
				   (local.set $bootstrapping (i32.const 1))

				   (ref.cast (ref eq)
					     (ref.i31
					      (i32.const -1337))))
				  (else
				   (ref.cast (ref eq)      
					     (struct.get $VirtualMachine $classMetaclass 
							 (local.get $vm)))))
			      
			      (call $nextIdentityHash ;; $identityHash
				    (local.get $vm))

			      ;; $nextObject to be set later
			      (ref.null none)                                    

			      ;; $superclass
			      (if (result (ref null eq))
				  (ref.is_null (local.get $superclass))
				  (then
				   (struct.get $VirtualMachine $classClass
					       (local.get $vm)))
				  (else
				   (struct.get $Class $class                          
					       (local.get $superclass))))

			      ;; $methodDictionary
			      (call $newDictionary                               
				    (local.get $vm))

			      (i32.const 152)         ;; $format

			      ;; $instanceVariableNames
			      (call $newEmptyArray                               
				    (local.get $vm))

			      ;; $baseID to be set later (should be a $UUID)
			      (call $newByteArray                                
				    (local.get $vm)
				    (array.new $byteArray
					       (i32.const 0)
					       (i32.const 16)))                                    

			      (local.get $class)))    ;; $thisClass

       (struct.set $Class $class
		   (local.get $class)
		   (local.get $metaclass))

       (if
	(i32.eqz
	 (local.get $bootstrapping))
	(then
	 (call $linkObjects
	       (local.get $vm)
	       (array.new_fixed $objectArray 6
				(struct.get $Metaclass $class
					    (local.get $metaclass))
				(struct.get $Metaclass $superclass
					    (local.get $metaclass))
				(struct.get $Metaclass $methodDictionary
					    (local.get $metaclass))
				(struct.get $Metaclass $instanceVariableNames
					    (local.get $metaclass))
				(struct.get $Metaclass $baseID
					    (local.get $metaclass))
				(struct.get $Metaclass $thisClass
					    (local.get $metaclass))))

	 (call $linkObjects
	       (local.get $vm)
	       (array.new_fixed $objectArray 9
				(struct.get $Class $class
					    (local.get $class))
				(struct.get $Class $superclass
					    (local.get $class))
				(struct.get $Class $methodDictionary
					    (local.get $class))
				(struct.get $Class $instanceVariableNames
					    (local.get $class))
				(struct.get $Class $baseID
					    (local.get $class))
				(struct.get $Class $subclasses
					    (local.get $class))
				(struct.get $Class $name
					    (local.get $class))
				(struct.get $Class $classPool
					    (local.get $class))
				(struct.get $Class $sharedPools
					    (local.get $class))))))

       (local.get $class))

 ;; function 14
 
 (func $newSymbolFromBytes
       (param $vm (ref $VirtualMachine)) 
       (param $bytes (ref $byteArray)) 
       (result (ref $Symbol))
       
       (struct.new $Symbol
		   ;; $class
		   (if (result (ref eq))                                    
		       (ref.is_null
			(struct.get $VirtualMachine $classSymbol 
				    (local.get $vm)))
		       (then
			(ref.cast (ref eq)
				  (ref.i31
				   (i32.const -1337))))
		       (else
			(ref.cast (ref eq)
				  (struct.get $VirtualMachine $classSymbol 
					      (local.get $vm)))))
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $bytes)))    ;; $slots

 ;; function 15
 
 (func $do
       (param $vm (ref $VirtualMachine))
       (param $array (ref $objectArray))
       (param $function (ref $enumerator))

       (local $index i32)
       (local $limit i32)

       (local.set $index (i32.const 0))
       
       (local.set $limit
		  (array.len (local.get $array)))

       (loop $enumerate
	     (if
	      (i32.eq
	       (local.get $index)
	       (local.get $limit))
	      (then
	       (return))
	      (else
	       (call_ref $enumerator
			 (local.get $vm)
			 (array.get $objectArray
				    (local.get $array)
				    (local.get $index))
			 (local.get $function))))

	     (local.set $index
			(i32.add
			 (local.get $index)
			 (i32.const 1)))
	     (br $enumerate)))

 ;; function 16
 
 (func $fixMetalevelFields
       (param $vm (ref $VirtualMachine))
       (param $class (ref null eq))
       
       (struct.set $Array $class
		   (struct.get $Class $subclasses
			       (ref.cast (ref $Class)
					 (local.get $class)))
		   (ref.cast (ref eq)
			     (struct.get $VirtualMachine $classArray
					 (local.get $vm))))

       (struct.set $Array $class
		   (struct.get $Class $sharedPools
			       (ref.cast (ref $Class)
					 (local.get $class)))
		   (ref.cast (ref eq)
			     (struct.get $VirtualMachine $classArray
					 (local.get $vm))))

       (struct.set $Metaclass $class
		   (ref.cast (ref $Metaclass)
			     (struct.get $Class $class
					 (ref.cast (ref $Class)
						   (local.get $class))))
		   (ref.cast (ref eq)
			     (struct.get $VirtualMachine $classMetaclass
					 (local.get $vm))))

       (call $do
	     (local.get $vm)
	     (struct.get $Array $array
			 (struct.get $Class $subclasses
				     (ref.cast (ref $Class)
					       (local.get $class))))
	     (ref.func $fixMetalevelFields)))

 ;; function 17
 
 (func $newVirtualMachine
       (result (ref $VirtualMachine))
       
       (local $vm (ref $VirtualMachine))

       ;; Used in this function as the $superclass of class Metaclass and class Class.
       (local $classClassDescription (ref $Class))

       ;; Used to fix the $class of class Behavior.
       (local $classBehavior (ref $Class))
       (local $classArrayedCollection (ref $Class))

       ;; Create a $vm.
       (local.set $vm
		  (struct.new $VirtualMachine
			      (ref.null none)   ;; $activeContext to be set later
			      (i32.const 1)     ;; $translationEnabled

			      ;; $methodCache
			      (array.new $objectArray  
					 (ref.null none)
					 (i32.const 256))
			      
			      (i32.const 0)     ;; $functionTableBaseIndex
			      (i32.const 1000)  ;; $translationThreshold
			      (i32.const 1)     ;; $nextIdentityHash
			      (ref.null none)   ;; $firstObject to be set later
			      (ref.null none)   ;; $lastObject to be set later

			      (ref.null none)   ;; $classObject to be set later
			      (ref.null none)   ;; $classMetaclass to be set later
			      (ref.null none)   ;; $classClass to be set later
			      (ref.null none)   ;; $classArray to be set later
			      (ref.null none)   ;; $classByteArray to be set later
			      (ref.null none)   ;; $classWordArray to be set later
			      (ref.null none)   ;; $classContext to be set later
			      (ref.null none)   ;; $classCompiledMethod to be set later
			      (ref.null none)   ;; $classSymbol to be set later
			      (ref.null none))) ;; $classSmallInteger to be set later

       ;; The simplest virtual machine runs (3 benchmark). Create
       ;; class SmallInteger and as much of the metalevel as we need.
       
       ;; The $vm needed to exist before we could create any classes
       ;; (in particular, before we could create any metaclasses,
       ;; because it involves getting a field of the $vm). The $class
       ;; of class Object is null after this, though; fix it
       ;; later. Until we create class Metaclass and class Symbol, the
       ;; $class of every $Metaclass and $Symbol we create will be
       ;; null; fix them later. Until we create class Array, the
       ;; $class of the $subclasses and $sharedPools of every $Class
       ;; we create will be null; fix them later.

       (struct.set $VirtualMachine $classObject
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)           ;; $vm     
			 (ref.null $Class)         ;; $superclass
			 (call $newSymbolFromBytes ;; $name
			       (local.get $vm)               ;; $vm
			       (array.new_fixed $byteArray 6 ;; $bytes
						(i32.const 79)      ;; 'O'
						(i32.const 98)      ;; 'b'
						(i32.const 106)     ;; 'j'
						(i32.const 101)     ;; 'e'
						(i32.const 99)      ;; 'c'
						(i32.const 116))))) ;; 't'

       ;; Now that class Object exists, create its subclass class
       ;; UndefinedObject and set the $firstObject and $lastObject to
       ;; nil.
       (struct.set $VirtualMachine $firstObject
		   (local.get $vm)
		   (struct.new $UndefinedObject
			       ;; $class
			       (call $newSubclassOfWithName 
				     (local.get $vm)
				     (struct.get $VirtualMachine $classObject ;; $superclass
						 (local.get $vm))

				     ;; $name
				     (call $newSymbolFromBytes                  
					   (local.get $vm)
					   (array.new_fixed $byteArray 15
							    (i32.const 85)     ;; 'U'
							    (i32.const 110)    ;; 'n'
							    (i32.const 100)    ;; 'd'
							    (i32.const 101)    ;; 'e'
							    (i32.const 102)    ;; 'f'
							    (i32.const 105)    ;; 'i'
							    (i32.const 110)    ;; 'n'
							    (i32.const 101)    ;; 'e'
							    (i32.const 100)    ;; 'd'
							    (i32.const 79)     ;; 'O'
							    (i32.const 98)     ;; 'b'
							    (i32.const 106)    ;; 'j'
							    (i32.const 101)    ;; 'e'
							    (i32.const 99)     ;; 'c'
							    (i32.const 116)))) ;; 't'

			       (call $nextIdentityHash ;; $identityHash
				     (local.get $vm))
			       (ref.null none)))       ;; $nextObject to be set later

       (struct.set $VirtualMachine $lastObject
		   (local.get $vm)
		   (struct.get $VirtualMachine $firstObject
			       (local.get $vm)))

       (local.set $classBehavior
		  (call $newSubclassOfWithName
			(local.get $vm)
			(struct.get $VirtualMachine $classObject ;; $superclass
				    (local.get $vm))
			(call $newSymbolFromBytes                ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 8
					       (i32.const 66)      ;; 'B'
					       (i32.const 101)     ;; 'e'
					       (i32.const 104)     ;; 'h'
					       (i32.const 97)      ;; 'a'
					       (i32.const 118)     ;; 'v'
					       (i32.const 105)     ;; 'i'
					       (i32.const 111)     ;; 'o'
					       (i32.const 114))))) ;; 'r'

       (local.set $classClassDescription
		  (call $newSubclassOfWithName
			(local.get $vm)
			(local.get $classBehavior) ;; $superclass
			(call $newSymbolFromBytes  ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 16
					       (i32.const 67)      ;; 'C'
					       (i32.const 108)     ;; 'l'
					       (i32.const 97)      ;; 'a'
					       (i32.const 115)     ;; 's'
					       (i32.const 115)     ;; 's'
					       (i32.const 68)      ;; 'D'
					       (i32.const 101)     ;; 'e'
					       (i32.const 115)     ;; 's'
					       (i32.const 99)      ;; 'c'
					       (i32.const 114)     ;; 'r'
					       (i32.const 105)     ;; 'i'
					       (i32.const 112)     ;; 'p'
					       (i32.const 116)     ;; 't'
					       (i32.const 105)     ;; 'i'
					       (i32.const 111)     ;; 'o'
					       (i32.const 110))))) ;; 'n'

       ;; Create class Class.
       (struct.set $VirtualMachine $classClass
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (local.get $classClassDescription) ;; $superclass
			 (call $newSymbolFromBytes          ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 5
						(i32.const 67)      ;; 'C'
						(i32.const 108)     ;; 'l'
						(i32.const 97)      ;; 'a'
						(i32.const 115)     ;; 's'
						(i32.const 115))))) ;; 's'

       ;; Now that class Class exists, set the $superclass of (Object class).
       (struct.set $Metaclass $superclass
		   (ref.cast (ref $Metaclass)
			     (struct.get $Class $class
					 (struct.get $VirtualMachine $classObject
						     (local.get $vm))))
		   (ref.cast (ref eq)
			     (struct.get $VirtualMachine $classClass
					 (local.get $vm))))

       ;; Create class Metaclass.
       (struct.set $VirtualMachine $classMetaclass
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (local.get $classClassDescription) ;; $superclass
			 (call $newSymbolFromBytes          ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 9
						(i32.const 77)      ;; 'M'
						(i32.const 101)     ;; 'e'
						(i32.const 116)     ;; 't'
						(i32.const 97)      ;; 'a'
						(i32.const 99)      ;; 'c'
						(i32.const 108)     ;; 'l'
						(i32.const 97)      ;; 'a'
						(i32.const 115)     ;; 's'
						(i32.const 115))))) ;; 's'

       ;; Create what we need of the Collection hierarchy.
       (local.set $classArrayedCollection
		  (call $newSubclassOfWithName ;; ArrayedCollection
			(local.get $vm)
			(call $newSubclassOfWithName ;; SequenceableCollection
			      (local.get $vm)
			      (call $newSubclassOfWithName ;; Collection
				    (local.get $vm)
				    (struct.get $VirtualMachine $classObject ;; superclass
						(local.get $vm))
				    (call $newSymbolFromBytes                ;; $name
					  (local.get $vm)
					  (array.new_fixed $byteArray 10
							   (i32.const 67)     ;; 'C'
							   (i32.const 111)    ;; 'o'
							   (i32.const 108)    ;; 'l'
							   (i32.const 108)    ;; 'l'
							   (i32.const 101)    ;; 'e'
							   (i32.const 99)     ;; 'c'
							   (i32.const 116)    ;; 't'
							   (i32.const 105)    ;; 'i'
							   (i32.const 111)    ;; 'o'
							   (i32.const 110)))) ;; 'n'
			      (call $newSymbolFromBytes   ;; $name
				    (local.get $vm)
				    (array.new_fixed $byteArray 22
						     (i32.const 83)     ;; 'S'
						     (i32.const 101)    ;; 'e'
						     (i32.const 113)    ;; 'q'
						     (i32.const 117)    ;; 'u'
						     (i32.const 101)    ;; 'e'
						     (i32.const 110)    ;; 'n'
						     (i32.const 99)     ;; 'c'
						     (i32.const 101)    ;; 'e'
						     (i32.const 97)     ;; 'a'
						     (i32.const 98)     ;; 'b'
						     (i32.const 108)    ;; 'l'
						     (i32.const 101)    ;; 'e'
						     (i32.const 67)     ;; 'C'
						     (i32.const 111)    ;; 'o'
						     (i32.const 108)    ;; 'l'
						     (i32.const 108)    ;; 'l'
						     (i32.const 101)    ;; 'e'
						     (i32.const 99)     ;; 'c'
						     (i32.const 116)    ;; 't'
						     (i32.const 105)    ;; 'i'
						     (i32.const 111)    ;; 'o'
						     (i32.const 110)))) ;; 'n'
			(call $newSymbolFromBytes    ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 17
					       (i32.const 65)      ;; 'A'
					       (i32.const 114)     ;; 'r'
					       (i32.const 114)     ;; 'r'
					       (i32.const 97)      ;; 'a'
					       (i32.const 121)     ;; 'y'
					       (i32.const 101)     ;; 'e'
					       (i32.const 100)     ;; 'd'
					       (i32.const 67)      ;; 'C'
					       (i32.const 111)     ;; 'o'
					       (i32.const 108)     ;; 'l'
					       (i32.const 108)     ;; 'l'
					       (i32.const 101)     ;; 'e'
					       (i32.const 99)      ;; 'c'
					       (i32.const 116)     ;; 't'
					       (i32.const 105)     ;; 'i'
					       (i32.const 111)     ;; 'o'
					       (i32.const 110))))) ;; 'n'
       
       (struct.set $VirtualMachine $classArray
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (local.get $classArrayedCollection) ;; $superclass
			 (call $newSymbolFromBytes           ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 5
						(i32.const 65)      ;; 'A'
						(i32.const 114)     ;; 'r'
						(i32.const 114)     ;; 'r'
						(i32.const 97)      ;; 'a'
						(i32.const 121))))) ;; 'y'

       (struct.set $VirtualMachine $classByteArray
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (local.get $classArrayedCollection) ;; superclass
			 (call $newSymbolFromBytes           ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray  9
						(i32.const 66)      ;; 'B'
						(i32.const 121)     ;; 'y'
						(i32.const 116)     ;; 't'
						(i32.const 101)     ;; 'e'
						(i32.const 65)      ;; 'A'
						(i32.const 114)     ;; 'r'
						(i32.const 114)     ;; 'r'
						(i32.const 97)      ;; 'a'
						(i32.const 121))))) ;; 'y'

       (struct.set $VirtualMachine $classWordArray
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (local.get $classArrayedCollection) ;; superclass
			 (call $newSymbolFromBytes           ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 9
						(i32.const 87)      ;; 'W'
						(i32.const 111)     ;; 'o'
						(i32.const 114)     ;; 'r'
						(i32.const 100)     ;; 'd'
						(i32.const 65)      ;; 'A'
						(i32.const 114)     ;; 'r'
						(i32.const 114)     ;; 'r'
						(i32.const 97)      ;; 'a'
						(i32.const 121))))) ;; 'y'

       ;; Create class Symbol.
       (struct.set $VirtualMachine $classSymbol
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (struct.get $VirtualMachine $classObject ;; $superclass
				     (local.get $vm))
			 (call $newSymbolFromBytes                ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 6
						(i32.const 83)      ;; 'S'
						(i32.const 121)     ;; 'y'
						(i32.const 109)     ;; 'm'
						(i32.const 98)      ;; 'b'
						(i32.const 111)     ;; 'o'
						(i32.const 108))))) ;; 'l'

       ;; Set the $class of the $subclasses, $sharedPools, and $class
       ;; of every $Class created so far, and the $class of every
       ;; $Symbol and $Dictionary created so far.

       (call $fixMetalevelFields
	     (local.get $vm)
	     (ref.cast (ref eq)
		       (struct.get $VirtualMachine $classObject
				   (local.get $vm))))
	     
       (struct.set $VirtualMachine $classCompiledMethod
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (struct.get $VirtualMachine $classByteArray ;; $superclass
				     (local.get $vm))
			 (call $newSymbolFromBytes                   ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 14
						(i32.const 67)      ;; 'C'
						(i32.const 111)     ;; 'o'
						(i32.const 109)     ;; 'm'
						(i32.const 112)     ;; 'p'
						(i32.const 105)     ;; 'i'
						(i32.const 108)     ;; 'l'
						(i32.const 101)     ;; 'e'
						(i32.const 100)     ;; 'd'
						(i32.const 77)      ;; 'M'
						(i32.const 101)     ;; 'e'
						(i32.const 116)     ;; 't'
						(i32.const 104)     ;; 'h'
						(i32.const 111)     ;; 'o'
						(i32.const 100))))) ;; 'd'

       (struct.set $VirtualMachine $classContext
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (struct.get $VirtualMachine $classObject ;; $superclass
				     (local.get $vm))
			 (call $newSymbolFromBytes                ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 7
						(i32.const 67)      ;; 'C'
						(i32.const 111)     ;; 'o'
						(i32.const 110)     ;; 'n'
						(i32.const 116)     ;; 't'
						(i32.const 101)     ;; 'e'
						(i32.const 120)     ;; 'x'
						(i32.const 116))))) ;; 't'
       
       (struct.set $VirtualMachine $classSmallInteger
		   (local.get $vm)
		   (call $newSubclassOfWithName
			 (local.get $vm)
			 (struct.get $VirtualMachine $classObject ;; $superclass
				     (local.get $vm))
			 (call $newSymbolFromBytes                ;; $name
			       (local.get $vm)
			       (array.new_fixed $byteArray 12
						(i32.const 83)      ;; 'S'
						(i32.const 109)     ;; 'm'
						(i32.const 97)      ;; 'a'
						(i32.const 108)     ;; 'l'
						(i32.const 108)     ;; 'l'
						(i32.const 73)      ;; 'I'
						(i32.const 110)     ;; 'n'
						(i32.const 116)     ;; 't'
						(i32.const 101)     ;; 'e'
						(i32.const 103)     ;; 'g'
						(i32.const 101)     ;; 'e'
						(i32.const 104))))) ;; 'r' 

       (local.get $vm))

 ;; utilities for method translation in JS

 ;; function 18
 
 (func $methodBytecodes
       (param $method (ref eq)) 
       (result (ref $byteArray))

       (struct.get $ByteArray $array
		   (ref.cast (ref $ByteArray)
			     (struct.get $CompiledMethod $slots
					 (ref.cast (ref $CompiledMethod)
						   (local.get $method))))))

 ;; function 19
 
 (func $getMethodFunctionIndex
       (param $method (ref eq)) 
       (result i32)
       
       (struct.get $CompiledMethod $functionIndex
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))))

 ;; function 20
 
 (func $setMethodFunctionIndex
       (param $method (ref eq)) 
       (param $index i32)
       
       (struct.set $CompiledMethod $functionIndex
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))
		   (local.get $index)))

 ;; function 21
 
 (func $onContextPush
       (param $context (ref eq)) 
       (param $pushedObject (ref eq))
       
       (call $pushOnStack
	     (ref.cast (ref $Context)
		       (local.get $context))
	     (local.get $pushedObject)))

 ;; function 22
 
 (func $popFromContext
       (param $context (ref eq)) 
       (result (ref eq))
       
       (call $popFromStack
	     (ref.cast (ref $Context)
		       (local.get $context))))

 ;; function 23
 
 (func $contextReceiver
       (param $context (ref eq)) 
       (result (ref eq))
       
       (struct.get $Context $receiver
		   (ref.cast (ref $Context)
			     (local.get $context))))

 ;; function 24
 
 (func $methodLiterals
       (param $method (ref eq)) 
       (result (ref eq))
       
       (struct.get $CompiledMethod $literals
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))))

 ;; function 25
 
 (func $contextLiteralAt
       (param $context (ref eq)) 
       (param $index i32) 
       (result (ref eq))

       (ref.as_non_null
	(call $arrayAt
	      (struct.get $CompiledMethod $literals
			  (struct.get $Context $method
				      (ref.cast (ref $Context)
						(local.get $context))))
	      (local.get $index))))

 ;; function 26
 
 (func $contextMethod
       (param $context (ref eq)) 
       (result (ref eq))
       
       (struct.get $Context $method
		   (ref.cast (ref $Context)
			     (local.get $context))))

 ;; function 27
 
 (func $arrayOkayAt
       (param $array (ref eq)) 
       (param $index i32) 
       (result i32)
       
       (local $length i32)
       
       (local.set $length
		  (array.len
		   (ref.cast (ref array)
			     (local.get $array))))

       ;; Check bounds.
       (if
	(i32.lt_s
	 (local.get $index)
	 (i32.const 0))
	(then
	 (return
	   (i32.const 0))))
       
       (if
	(i32.ge_u
	 (local.get $index)
	 (local.get $length))
	(then
	 (return
	   (i32.const 0))))
       
       (i32.const 1))

 ;; function 28
 
 (func $arrayAt
       (param $array (ref $Array)) 
       (param $index i32) 
       (result (ref null eq))

       (local $objectArray (ref $objectArray))

       (local.set $objectArray
		  (struct.get $Array $array
			      (local.get $array)))

       (if (result (ref null eq))
	(i32.eqz
	 (call $arrayOkayAt
	       (ref.cast (ref $objectArray)
			 (local.get $objectArray))
	       (local.get $index)))
	(then
	 (local.get $index)
	 (throw $outOfBounds))
	(else
	 ;; Safe to access array.
	 (array.get $objectArray
		    (local.get $objectArray)
		    (local.get $index)))))

 ;; function 29
 
 (func $byteArrayAt
       (param $array (ref $byteArray)) 
       (param $index i32) 
       (result i32)
       
       (if
	(i32.eqz
	 (call $arrayOkayAt
	       (local.get $array)
	       (local.get $index)))
	(then
	 (return
	   (i32.const -1))))

       ;; Safe to access array.
       (array.get_s $byteArray
		    (local.get $array)
		    (local.get $index)))

 ;; function 30
 
 (func $byteArrayLength
       (param $array (ref eq)) 
       (result i32)
       
       (array.len
	(ref.cast (ref $byteArray)
		  (local.get $array))))

 ;; function 31
 
 (func $copyByteArrayToMemory
       (param $bytes (ref $byteArray)) 
       (result i32)
       
       (local $length i32)
       (local $index i32)
       
       (local.set $length
		  (array.len
		   (local.get $bytes)))
       
       (local.set $index
		  (i32.const 0))
       
       (loop $copy
	     (if
	      (i32.eq
	       (local.get $index)
	       (local.get $length))
	      (then
	       (return
		 (global.get $byteArrayCopyPointer))))
	     
	     (i32.store8
	      (i32.add
	       (global.get $byteArrayCopyPointer)
	       (local.get $index))
	      (array.get_u $byteArray
			   (local.get $bytes)
			   (local.get $index)))
	     
	     (local.set $index
			(i32.add
			 (local.get $index)
			 (i32.const 1)))
	     
	     (br $copy))

       (unreachable))

 ;; function 32
 
 (func $nextIdentityHash
       (param $vm (ref $VirtualMachine)) 
       (result i32)
       
       (struct.set $VirtualMachine $nextIdentityHash
		   (local.get $vm)
		   (i32.add
		    (struct.get $VirtualMachine $nextIdentityHash
				(local.get $vm))
		    (i32.const 1)))
       
       (struct.get $VirtualMachine $nextIdentityHash
		   (local.get $vm)))

 ;; function 33
 
 (func $pushOnStack
       (param $context (ref $Context)) 
       (param $value (ref eq))
       
       (local $stack (ref $Array))
       (local $sp i32)
       
       (local.set $stack
		  (struct.get $Context $stack
			      (local.get $context)))

       (local.set $sp
		  (struct.get $Context $sp
			      (local.get $context)))

       (if
	(i32.ge_u
	 (local.get $sp)
	 (array.len
	  (struct.get $Array $array
		      (local.get $stack))))
	(then
	 (return)))

       (array.set $objectArray
		  (struct.get $Array $array
			      (local.get $stack))
		  (local.get $sp)
		  (local.get $value))
       
       (struct.set $Context $sp
		   (local.get $context)
		   (i32.add
		    (local.get $sp)
		    (i32.const 1))))

 ;; function 34
 
 (func $popFromStack
       (param $context (ref null $Context)) 
       (result (ref eq))

       (local $stack (ref $Array))
       (local $sp i32)

       ;; Get stack and stack pointer.
       (local.set $stack
		  (struct.get $Context $stack
			      (local.get $context)))
       (local.set $sp
		  (struct.get $Context $sp
			      (local.get $context)))

       ;; Check empty stack.
       (if
	(i32.eq
	 (local.get $sp)
	 (i32.const 0))
	(then
	 throw $emptyStack))

       ;; Decrement stack pointer.
       (struct.set $Context $sp
		   (local.get $context)
		   (i32.sub
		    (local.get $sp)
		    (i32.const 1)))

       ;; Return top value.
       (return
	 (ref.as_non_null
	  (array.get $objectArray
		     (struct.get $Array $array
				 (local.get $stack))
		     (i32.sub
		      (local.get $sp)
		      (i32.const 1))))))

 ;; function 35
 
 (func $topOfStack
       (param $context (ref null $Context)) 
       (result (ref eq))
       
       (local $stack (ref $Array))
       (local $sp i32)

       ;; Get stack and stack pointer.
       (local.set $stack
		  (struct.get $Context $stack
			      (local.get $context)))
       (local.set $sp
		  (struct.get $Context $sp
			      (local.get $context)))

       ;; Check empty stack.
       (if
	(i32.eq
	 (local.get $sp)
	 (i32.const 0))
	(then
	 (throw $emptyStack)))

       ;; Return top value without popping.
       (return
	 (ref.as_non_null
	  (array.get $objectArray
		     (struct.get $Array $array
				 (local.get $stack))
		     (i32.sub
		      (local.get $sp)
		      (i32.const 1))))))

 ;; function 36
 
 (func $classOfObject
       (param $vm (ref $VirtualMachine)) 
       (param $obj (ref eq)) 
       (result (ref eq))

       (if (result (ref eq))
	   (ref.test (ref i31)
		     (local.get $obj))
	   (then
	    (ref.cast (ref eq)
		      (struct.get $VirtualMachine $classSmallInteger
				  (local.get $vm))))
	   (else
	    ;; TODO: For all nulls, return class UndefinedObject.
	    (struct.get $Object $class
			(ref.cast (ref $Object)
				  (local.get $obj))))))

 ;; function 37
 
 (func $lookupMethod
       (param $vm (ref $VirtualMachine)) 
       (param $receiver (ref eq)) 
       (param $selector (ref eq)) 
       (result (ref null $CompiledMethod))
       
       (local $class (ref eq))
       (local $currentClass (ref null eq))
       (local $methodDictionary (ref $Dictionary))
       (local $keys (ref $Array))
       (local $values (ref $Array))
       (local $count i32)
       (local $index i32)
       (local $key (ref eq))

       ;; Get receiver's class.
       (local.set $currentClass
		  (call $classOfObject
			(local.get $vm)
			(local.get $receiver)))

       ;; Walk up the class hierarchy.
       (loop $hierarchy_loop
	     (if
	      (ref.is_null
	       (local.get $currentClass))
	      (then
	       ;; Reached top of hierarchy: method not found.
	       (return
		 (ref.null none))))

	     
	     ;; Get method dictionary from current class.
	     (local.set $methodDictionary
			(struct.get $Class $methodDictionary
				    (ref.cast (ref $Class)
					      (local.get $currentClass))))
	     
	     ;; Search in current class's method dictionary.
	     (local.set $keys
			(struct.get $Dictionary $keys
				    (ref.as_non_null
				     (local.get $methodDictionary))))

	     (local.set $values
			(struct.get $Dictionary $values
				    (ref.as_non_null
				     (local.get $methodDictionary))))

	     (local.set $count
			(struct.get $Dictionary $count
				    (ref.as_non_null
				     (local.get $methodDictionary))))

	     ;; Linear search for selector in current class.
	     (local.set $index
			(i32.const 0))
	     
	     (loop $search_loop
		   (if
		    (i32.ge_u
		     (local.get $index)
		     (local.get $count))
		    (then
		     ;; Not found in this class; try superclass.
		     (local.set $currentClass
				(struct.get $Class $superclass
					    (ref.cast (ref $Class)
						      (local.get $currentClass))))
		     (br $hierarchy_loop)))

		   ;; Get key at index.
		   (local.set $key
			      (ref.as_non_null
			       (array.get $objectArray
					  (struct.get $Array $array
						      (local.get $keys))
					  (local.get $index))))

		   ;; Compare with selector.
		   (if
		    (ref.eq
		     (local.get $key)
		     (local.get $selector))
		    (then
		     ;; Found! Get the method.
		     (return
		       (ref.cast (ref null $CompiledMethod)
				 (array.get $objectArray
					    
					    (struct.get $Array $array
							(local.get $values))
					    (local.get $index))))))

		   ;; Increment and continue.
		   (local.set $index
			      (i32.add
			       (local.get $index)
			       (i32.const 1)))
		   
		   (br $search_loop)))

       (unreachable))

 ;; function 38
 
 (func $lookupInMethodCache
       (param $vm (ref $VirtualMachine)) 
       (param $selector (ref eq)) 
       (param $receiverClass (ref $Class)) 
       (result (ref null $CompiledMethod))

       (local $cache (ref null $objectArray))
       (local $cacheSize i32)
       (local $hash i32)
       (local $index i32)
       (local $entry (ref null $PICEntry))
       (local $probeLimit i32)

       ;; Get method cache.
       (if
	(ref.is_null
	 (local.tee $cache
		    (struct.get $VirtualMachine $methodCache
				(local.get $vm))))
	(then
	 (return
	   (ref.null none)))
	(else
	 (local.set $cacheSize
		    (array.len (local.get $cache)))))

       (local.set $index
		  (i32.rem_u
		   (i32.add
		    ;; simple hash function (identity hash of selector + class)
		    (struct.get $Object $identityHash
				(ref.cast (ref $Object)
					  (local.get $selector)))
		    (struct.get $Class $identityHash
				(local.get $receiverClass)))
		   (array.len
		    (local.get $cache))))

       ;; linear probing with limit
       (local.set $probeLimit
		  (i32.const 8)) ;; max probe distance

       (loop $probe_loop
	     (if
	      (i32.le_s
	       (local.get $probeLimit)
	       (i32.const 0))
	      (then
	       ;; probe limit exceeded
	       (return
		 (ref.null none))))
	     
	     (if
	      (ref.is_null
	       ;; Get cache entry.
	       (local.tee $entry
			  (ref.cast (ref null $PICEntry)
				    (array.get $objectArray
					       (ref.as_non_null
						(local.get $cache))
					       (local.get $index)))))
	      (then
	       ;; empty slot; cache miss
	       (return
		 (ref.null none))))

	     ;; Check if entry matches.
	     (if
	      (i32.and
	       (ref.eq
		(struct.get $PICEntry $selector
			    (local.tee $entry
				       (ref.cast (ref $PICEntry)
						 (local.get $entry))))
		(local.get $selector))
	       (ref.eq
		(struct.get $PICEntry $receiverClass
			    (local.get $entry))
		(local.get $receiverClass)))
	      (then
	       ;; Cache hit; increment hit count and return method.
	       (struct.set $PICEntry $hitCount
			   (local.get $entry)
			   (i32.add
			    (struct.get $PICEntry $hitCount
					(local.get $entry))
			    (i32.const 1)))
	       (return
		 (ref.cast (ref null $CompiledMethod)
			   (struct.get $PICEntry $method
				       (local.get $entry))))))

	     ;; Try next slot.
	     (local.set $index
			(i32.rem_u
			 (i32.add
			  (local.get $index)
			  (i32.const 1))
			 (local.get $cacheSize)))

	     (local.set $probeLimit
			(i32.sub
			 (local.get $probeLimit)
			 (i32.const 1)))

	     (br $probe_loop))

       (unreachable))

 ;; function 39
 
 (func $storeInMethodCache
       (param $vm (ref $VirtualMachine)) 
       (param $selector (ref $Symbol)) 
       (param $receiverClass (ref eq)) 
       (param $method (ref $CompiledMethod))
       
       (local $cache (ref $objectArray))
       (local $index i32)
       (local $entry (ref $PICEntry))

       ;; Get method cache.
       (local.set $cache
		  (struct.get $VirtualMachine $methodCache
			      (local.get $vm)))

       ;; simple hash function
       (local.set $index
		  (i32.rem_u
		   (i32.add
		    (struct.get $Symbol $identityHash
				(ref.cast (ref $Symbol)
					  (local.get $selector)))
		    (struct.get $ClassDescription $identityHash
				(ref.cast (ref $ClassDescription)
					  (local.get $receiverClass))))
		   (array.len (local.get $cache))))

       ;; Create new cache entry.
       (local.set $entry
		  (struct.new $PICEntry
			      (local.get $selector)
			      (local.get $receiverClass)
			      (local.get $method)
			      (i32.const 1))) ;; initial hit count

       ;; Store in cache.
       (array.set $objectArray
		  (local.get $cache)
		  (local.get $index)
		  (local.get $entry)))

 ;; function 40
 
 (func $newContext
       (param $vm (ref $VirtualMachine)) 
       (param $receiver (ref eq)) 
       (param $method (ref $CompiledMethod))
       (param $selector (ref eq)) 
       (result (ref $Context))
       
       (struct.new $Context
		   ;; $class
		   (ref.cast (ref eq)
			     (struct.get $VirtualMachine $classContext  
					 (local.get $vm)))

		   (call $nextIdentityHash                    ;; $identityHash
			 (local.get $vm))
		   (ref.null none)                            ;; $nextObject to be set later
		   (struct.get $VirtualMachine $activeContext ;; $sender
			       (local.get $vm))
		   (i32.const 0)                              ;; $pc
		   (i32.const 0)                              ;; $sp
		   (local.get $method)                        ;; $method
		   (local.get $receiver)                      ;; $receiver
		   (call $newArray                            ;; $args
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 0)))
		   (call $newArray                            ;; $temps
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 0)))
		   (call $newArray                            ;; $stack
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 20)))))

 ;; function 41
 
 (func $smallIntegerForValue
       (param $value i32) 
       (result (ref eq))
       
       (ref.i31
	(local.get $value)))

 ;; function 42
 
 (func $isSmallInteger
       (param $obj (ref eq))
       (result i32)

       (if (result i32)
	   (ref.test (ref i31)
		     (local.get $obj))
	   (then
	    (return
	      (i32.const 1)))
	   (else
	    (return
	      (i32.const 0)))))

 ;; function 43
 
 (func $valueOfSmallInteger
       (param $obj (ref eq)) 
       (result i32)
       
       (if (result i32)
	   (call $isSmallInteger
		 (local.get $obj))
	   (then
	    (i31.get_s
	     (ref.cast (ref i31)
		       (local.get $obj))))
	   (else
	    ;; Not a SmallInteger; return 0 for safety.
	    (i32.const 0))))

 ;; function 44
 
 (func $isTranslated
       (param $method (ref null $CompiledMethod)) 
       (result i32)

       (i32.gt_u ;; We start at index 1, to make the value easier to discern in debuggers.
	(struct.get $CompiledMethod $functionIndex
		    (local.get $method))
	(i32.const 0)))

 ;; function 45
 
 (func $executeTranslatedMethod
       (param $context (ref $Context)) 
       (param $functionIndex i32)
       ;; Translation function returns 0 for success.
       (result i32)

       (call_indirect $functionTable (param (ref eq)) (result i32)
		      (local.get $context)
		      (local.get $functionIndex)))

 ;; function 46
 
 (func $handleMethodReturn
       (param $vm (ref $VirtualMachine)) 
       (param $context (ref null $Context)) 
       (result (ref eq))
       
       (local $sender (ref null $Context))
       (local $result (ref eq))
       
       (local.set $result
		  (call $topOfStack
			(local.get $context)))

       (if
	(i32.eqz
	 (ref.is_null
	  (local.tee $sender
		     (struct.get $Context $sender
				 (local.get $context)))))
	(then
	 ;; If the sending context isn't nil, push the result onto it.
	 (call $pushOnStack
	       (ref.as_non_null
		(local.get $sender))
	       (local.get $result))
	 
	 (struct.set $Context $pc
		     (ref.as_non_null
		      (local.get $sender))
		     (i32.add
		      (struct.get $Context $pc
				  (ref.as_non_null
				   (local.get $sender)))
		      (i32.const 1)))))

       (struct.set $VirtualMachine $activeContext
		   (local.get $vm)
		   (local.get $sender))
       
       (local.get $result))

 ;; function 47: Create minimal object memory for running (100
 ;; benchmark).
 
 (func $createMinimalObjectMemory
       (param $vm (ref $VirtualMachine)) 
       (result i32)
       
       (local $benchmarkMethod (ref $CompiledMethod))
       (local $methodDictionary (ref $Dictionary))
       (local $benchmarkLiterals (ref $objectArray))
       
       (global.set $benchmarkSelector
		   (call $newSymbolFromBytes
			 (local.get $vm)
			 (array.new_fixed $byteArray 9
					  (i32.const 98)     ;; 'b'
					  (i32.const 101)    ;; 'e'
					  (i32.const 110)    ;; 'n'
					  (i32.const 99)     ;; 'c'
					  (i32.const 104)    ;; 'h'
					  (i32.const 109)    ;; 'm'
					  (i32.const 97)     ;; 'a'
					  (i32.const 114)    ;; 'r'
					  (i32.const 107)))) ;; 'k'

       ;; Create the benchmark method.
       
       (local.set $benchmarkLiterals
		  (array.new $objectArray
			     (ref.null none)
			     (i32.const 4)))
       
       (array.set $objectArray
		  (local.get $benchmarkLiterals)
		  (i32.const 0)
		  (call $smallIntegerForValue
			(i32.const 0)))
       
       (array.set $objectArray
		  (local.get $benchmarkLiterals)
		  (i32.const 1)
		  (call $smallIntegerForValue
			(i32.const 1)))
       
       (array.set $objectArray
		  (local.get $benchmarkLiterals)
		  (i32.const 2)
		  (call $smallIntegerForValue
			(i32.const 2)))
       
       (array.set $objectArray
		  
		  (local.get $benchmarkLiterals)
		  (i32.const 3)
		  (call $smallIntegerForValue
			(i32.const 3)))

       ;; Create a simple repetitive benchmark computation: iterative
       ;; arithmetic progression (~100μs runtime)
       ;;
       ;; This benchmark method performs a simple iterative arithmetic
       ;; progression that's easy for LLMs to understand and optimize.
       ;; 
       ;; Pattern (repeated 5 times):
       ;; 1. result = (receiver + 1) * 2
       ;; 2. result = (result + 2) * 3  
       ;; 3. result = (result + 3) * 2
       ;;
       ;; This creates a simple, predictable pattern that:
       ;; 
       ;; - is easy for an LLM to analyze and understand.
       ;; 
       ;; - has clear optimization opportunities (can be reduced to a
       ;;   mathematical formula).
       ;; 
       ;; - takes sufficient time when interpreted (~45 operations ×
       ;;   15 iterations = ~100μs).
       ;; 
       ;; - has predictable, testable results.
       ;;
       ;; This performs 45 arithmetic operations in a simple pattern
       ;; that an LLM can easily translate to optimized WAT code.
       ;;
       ;; Simple repetitive pattern (15 iterations of 3-operation sequence).
       
       (local.set $benchmarkMethod
		  (struct.new $CompiledMethod
			      ;; $class
			      (ref.cast (ref eq)
					(struct.get $VirtualMachine $classCompiledMethod 
						    (local.get $vm)))
			      (call $nextIdentityHash ;; $identityHash
				    (local.get $vm))
			      (ref.null none)         ;; $nextObject
			      (call $newByteArray     ;; $slots
				    (local.get $vm)                    
				    (array.new_fixed $byteArray 62           
						     (i32.const 0x70)   ;; push receiver

						     (i32.const 0x21)   ;; push literal 1 (0-based)
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply

						     ;; sequence repeats five times in total
						     (i32.const 0x21)   ;; push literal 1
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     
						     (i32.const 0x21)   ;; push literal 1
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     
						     (i32.const 0x21)   ;; push literal 1
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     
						     (i32.const 0x21)   ;; push literal 1
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB8)   ;; multiply
						     (i32.const 0x23)   ;; push literal 3
						     (i32.const 0xB0)   ;; add
						     (i32.const 0x22)   ;; push literal 2
						     (i32.const 0xB8)   ;; multiply

						     (i32.const 0x7C))) ;; return top of stack
			      (call $newArray         ;; $literals
				    (local.get $vm)
				    (local.get $benchmarkLiterals))
			      (i32.const 0)           ;; $header
			      (i32.const 0)           ;; $invocationCount
			      (i32.const 0)           ;; $functionIndex

			      ;; $translationThreshold
			      (struct.get $VirtualMachine $translationThreshold
					  (local.get $vm))

			      (i32.const 0)))         ;; $isInstalled

       ;; Add the key/value pair of ($benchmarkSelector ->
       ;; $benchmarkMethod) to $vm$classSmallInteger$methodDictionary.
       (local.set $methodDictionary
		  (call $newDictionary
			(local.get $vm)))
       
       (struct.set $Class $methodDictionary
		   (struct.get $VirtualMachine $classSmallInteger
			       (local.get $vm))
		   (local.get $methodDictionary))

       (call $dictionaryAdd
	     (local.get $vm)
	     (local.get $methodDictionary)
	     (ref.cast (ref eq)
		       (global.get $benchmarkSelector))
	     (local.get $benchmarkMethod))
       
       (struct.set $CompiledMethod $isInstalled
		   (local.get $benchmarkMethod)
		   (i32.const 1))

       ;; success
       (i32.const 1))

 ;; function 48
 
 (func $resetMinimalMemory
       (param $vm (ref $VirtualMachine))
       
       ;; Set $vm's $activeContext to run an unbound method which runs (100 benchmark).
       (struct.set $VirtualMachine $activeContext
		   (local.get $vm)
		   (call $newContext
			 (local.get $vm)                               ;; $vm
			 (ref.i31                                      ;; $receiver
			  (i32.const 100))           
			 (struct.new $CompiledMethod                   ;; $method
				     ;; $class
				     (ref.cast (ref eq)
					       (struct.get $VirtualMachine $classCompiledMethod
							   (local.get $vm)))

				     (call $nextIdentityHash ;; $identityHash
					   (local.get $vm))
				     (ref.null none)         ;; $nextObject
				     (call $newByteArray     ;; $slots
					   (local.get $vm)
					   (array.new_fixed $byteArray 3            
							    (i32.const 0x70)   ;; push receiver

							    ;; send first literal
							    (i32.const 0xD0)   

							    (i32.const 0x7C))) ;; return top
				     ;; $literals
				     (call $newArray
					   (local.get $vm)
					   (array.new_fixed $objectArray 1
							    (global.get $benchmarkSelector)))

				     (i32.const 0)           ;; $header
				     (i32.const 0)           ;; $invocationCount
				     (i32.const 0)           ;; $functionIndex

                                     ;; $translationThreshold
				     (struct.get $VirtualMachine $translationThreshold
						 (local.get $vm))

				     (i32.const 0))          ;; $isInstalled
			 (ref.cast (ref eq)                            ;; $selector
				   (global.get $benchmarkSelector))))) 

 ;; function 49: Interpret single bytecode; return 1 if method should
 ;; return, 0 to continue.
 (func $interpretBytecode
       (param $vm (ref $VirtualMachine)) 
       (param $context (ref $Context)) 
       (param $bytecode i32) 
       (result i32)
       
       (local $receiver (ref eq))
       (local $value1 (ref eq))
       (local $value2 (ref eq))
       (local $int1 i32)
       (local $int2 i32)
       (local $result i32)
       (local $newContext (ref $Context))
       (local $selector (ref $Symbol))
       (local $method (ref null $CompiledMethod))
       (local $receiverClass (ref $Class))
       (local $index i32)
       (local $literals (ref $objectArray))
       
       (local.set $receiver
		  (struct.get $Context $receiver
			      (local.get $context)))

       (local.set $literals
		  (struct.get $Array $array
			      (struct.get $CompiledMethod $literals
					  (struct.get $Context $method
						      (local.get $context)))))

       (if
	(i32.and
	 (i32.ge_u
	  (local.get $bytecode)
	  (i32.const 0x20))  ;; literal base
	 (i32.le_u
	  (local.get $bytecode)
	  (i32.const 0x2F))) ;; literal end
	(then
	 ;; push literal
	 (local.set $index
		    (i32.sub
		     (local.get $bytecode)
		     (i32.const 0x20)))
	 (call $pushOnStack
	       (local.get $context)
	       (ref.as_non_null
		(array.get $objectArray
			   (local.get $literals)
			   (local.get $index))))
	 (return
	   (i32.const 0))))
       
       (if
	(i32.eq
	 (local.get $bytecode)
	 (i32.const 0x70))
	(then
	 ;; push receiver
	 (call $pushOnStack
	       (local.get $context)
	       (local.get $receiver))
	 (return
	   (i32.const 0))))
       
       (if
	(i32.eq
	 (local.get $bytecode)
	 (i32.const 184))
	(then
	 ;; multiply
	 (call $pushOnStack
	       (local.get $context)
	       (call $smallIntegerForValue
		     (i32.mul
		      (call $valueOfSmallInteger
			    (call $popFromStack
				  (local.get $context)))
		      (call $valueOfSmallInteger
			    (call $popFromStack
				  (local.get $context))))))
	 (return
	   (i32.const 0))))

       (if
	(i32.eq
	 (local.get $bytecode)
	 (i32.const 0xB0))
	(then
	 ;; add
	 (call $pushOnStack
	       (local.get $context)
	       (call $smallIntegerForValue
		     (i32.add
		      (call $valueOfSmallInteger
			    (call $popFromStack
				  (local.get $context)))
		      (call $valueOfSmallInteger
			    (call $popFromStack
				  (local.get $context))))))
	 (return
	   (i32.const 0))))
       
       (if
	(i32.eq
	 (local.get $bytecode)
	 (i32.const 0x7C))
	(then
	 ;; return top of stack
	 (return
	   (i32.const 1))))
       
       (if
	(i32.eq
	 (local.get $bytecode)
	 (i32.const 0xD0))
	(then
	 ;; send message
	 (local.set $receiver
		    (call $popFromStack
			  (local.get $context)))
	 (local.set $index
		    (i32.and
		     (local.get $bytecode)
		     (i32.const 0x0F)))

	 (local.set $selector
		    (ref.cast (ref $Symbol)
			      (array.get $objectArray
					 (local.get $literals)
					 (local.get $index))))
	 (local.set $receiverClass
		    (ref.cast (ref $Class)
			      (call $classOfObject
				    (local.get $vm)
				    (local.get $receiver))))

	 (if
	  (ref.is_null
	   (local.tee $method
		      (call $lookupInMethodCache
			    (local.get $vm)
			    (local.get $selector)
			    (local.get $receiverClass))))
	  (then
	   ;; method cache miss
	   (if
	    (ref.is_null
             (local.tee $method
			(call $lookupMethod
			      (local.get $vm)
			      (local.get $receiver)
			      (local.get $selector))))
	    (then
	     ;; message not understood
	     (local.get $selector)
	     (throw $messageNotUnderstood)))
	   (call $storeInMethodCache
		 (local.get $vm)
		 (local.get $selector)
		 (local.get $receiverClass)
		 (ref.cast (ref $CompiledMethod)
			   (local.get $method)))))

	 (struct.set $VirtualMachine $activeContext
		     (local.get $vm)
		     (call $newContext
			   (local.get $vm)
			   (local.get $receiver)
			   (ref.as_non_null
			    (local.get $method))
			   (local.get $selector)))

	 (return
	   (i32.const 0))))

       ;; unimplemented bytecode
       (unreachable))

 ;; function 50
 
 (func $interpret
       (param $vm (ref $VirtualMachine)) 
       (result i32)

       (local $context (ref null $Context))
       (local $method (ref null $CompiledMethod))
       (local $bytecode i32)
       (local $pc i32)
       (local $receiver (ref eq))
       (local $resultValue (ref eq))
       (local $invocationCount i32)
       (local $bytecodes (ref $byteArray))
       (local $functionIndex i32)

       ;; There are no paths through this function that don't set
       ;; $resultValue, but the validator is too cheap to calculate
       ;; this.
       (local.set $resultValue
		  (ref.i31
		   (i32.const -1337)))
       
       (block $finished
	 (loop $execution_loop
	       (if
		(ref.is_null
		 (local.tee $context
			    (struct.get $VirtualMachine $activeContext
					(local.get $vm))))
		(then
		 ;; We were running an object memory with an initial
		 ;; $activeContext with an unbound method. Return
		 ;; result to JS.
		 (br $finished)))
	       (local.set $receiver
			  (struct.get $Context $receiver
				      (ref.as_non_null
				       (local.get $context))))
	       
	       (local.set $invocationCount
			  (i32.add
			   (struct.get $CompiledMethod $invocationCount
				       (local.tee $method
						  (struct.get $Context $method
							      (ref.as_non_null
							       (local.get $context)))))
			   (i32.const 1)))
	       
	       (struct.set $CompiledMethod $invocationCount
			   (local.get $method)
			   (local.get $invocationCount))

	       (if
		(i32.and
		 (i32.eq
		  (local.get $invocationCount)
		  (struct.get $CompiledMethod $translationThreshold
			      (local.get $method)))
		 (struct.get $VirtualMachine $translationEnabled
			     (local.get $vm)))
		(then
		 (if
		  (struct.get $CompiledMethod $isInstalled
			      (local.get $method))
		  (then
		   (if
		    (i32.eqz
		     (call $isTranslated
			   (local.get $method)))
		    (then
		     (call $translateMethod
			   (ref.as_non_null
			    (local.get $method))
			   (if (result i32)
			       (call $isSmallInteger
				     (local.get $receiver))
			       (then
				(call $valueOfSmallInteger
				      (local.get $receiver)))
			       (else
				(struct.get $Object $identityHash
					    (ref.cast (ref $Object)
						      (local.get $receiver))))))))))))
	       (if
		(call $isTranslated
		      (ref.as_non_null
		       (local.get $method)))
		(then
		 (local.set $functionIndex
			    (struct.get $CompiledMethod $functionIndex
					(local.get $method)))
		 (if
		  (call $executeTranslatedMethod
			(ref.as_non_null
			 (local.get $context))
			(local.get $functionIndex))
		  (then
		   ;; Translated method failed; deoptimize.
		   (struct.set $CompiledMethod $functionIndex
			       (local.get $method)
			       (i32.const 0))
		   (br $execution_loop))
		  (else
		   (local.set $resultValue
			      (call $handleMethodReturn
				    (local.get $vm)
				    (ref.as_non_null
				     (local.get $context))))))
		 (br $execution_loop)))

	       ;; $method has no translation; interpret its bytecodes.
	       (local.set $bytecodes
			  (struct.get $ByteArray $array
				      (ref.cast (ref $ByteArray)
						(struct.get $CompiledMethod $slots
							    (local.get $method)))))

	       (loop $interpreter_loop
		     (br_if $execution_loop
			    (ref.is_null
			     ;; We've returned to a nil context
			     ;; sender; execution is finished.
			     (local.tee $context
					(struct.get $VirtualMachine $activeContext
						    (local.get $vm)))))

		     (local.set $pc
				(struct.get $Context $pc
					    (ref.as_non_null
					     (local.get $context))))

		     ;; Check if we've reached the end of the current
		     ;; $method's bytecodes.
		     (if
		      (i32.le_u
		       (array.len
			(local.tee $bytecodes
				   (struct.get $ByteArray $array
					       (ref.cast (ref $ByteArray)
							 (struct.get $CompiledMethod $slots
								     (local.tee $method
										(struct.get $Context $method
											    (ref.as_non_null
											     (local.get $context)))))))))
		       (local.get $pc))
		      (then
		       ;; We've reached the end of the current
		       ;; $method's bytecodes; return from the method.
		       (local.set $resultValue
				  (call $handleMethodReturn
					(local.get $vm)
					(ref.as_non_null
					 (local.get $context))))
		       (br $interpreter_loop)))

		     ;; Interpret the next $bytecode.
		     (local.set $bytecode
				(array.get_u $byteArray
					     (local.get $bytecodes)
					     (local.get $pc)))

		     (if
		      (call $interpretBytecode
			    (local.get $vm)
			    (ref.as_non_null
			     (local.get $context))
			    (local.get $bytecode))
		      (then
		       ;; That $bytecode makes $method return.
		       (local.set $resultValue
				  (call $handleMethodReturn
					(local.get $vm)
					(ref.as_non_null
					 (local.get $context))))
		       (br $interpreter_loop)))
		     ;; Check if $context switched via message-send.
		     (if
		      (ref.eq
		       (struct.get $VirtualMachine $activeContext
				   (local.get $vm))
		       (local.get $context))
		      (then
		       ;; Same $context; increment the $pc and continue.
		       (struct.set $Context $pc
				   (ref.as_non_null
				    (local.get $context))
				   (i32.add
				    (local.get $pc)
				    (i32.const 1))))
		      (else
		       ;; We have either entered a new $context via
		       ;; message-send, or returned to a sending
		       ;; $context.
		       (if
			(i32.eqz
			 (struct.get $Context $pc
				     (ref.as_non_null
				      (struct.get $VirtualMachine $activeContext
						  (local.get $vm)))))
			(then
			 ;; $pc is zero, meaning we have a new
			 ;; $method, rather than returning to a
			 ;; sending $context.
			 (br $execution_loop)))))

		     ;; Continue interpretation.
		     (br $interpreter_loop))))

       (call $reportResult                    ;; Report result to JS.
	     (call $valueOfSmallInteger
		   (local.get $resultValue)))

       (i32.const 1)))                        ;; function is successful

