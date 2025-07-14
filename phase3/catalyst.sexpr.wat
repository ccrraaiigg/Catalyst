;; catalyst.wat: multiple simultaneous Catalyst Smalltalk virtual
;; machines, with method translation
;;
;; Craig Latta, July 2025

(module

 ;; imported JS functions

 (import "env" "reportResult"
	 (func $reportResult
	       (param i32)))        ;; result

 ;; JS translates method and installs translation function
 (import "env" "translateMethod"
	 (func $translateMethod
	       (param eqref)        ;; method
	       (param i32)))        ;; method identity hash
 
 (import "env" "debugLog"
	 (func $debugLog
	       (param i32)          ;; level
	       (param i32)          ;; message
	       (param i32)))        ;; length

 ;; functions exported to JS
 
 (export "bytes" (memory $0))
 (export "functionTable" (table $functionTable))
 (export "initialize" (func $interpret))
 (export "methodBytecodes" (func $methodBytecodes))
 (export "setMethodFunctionIndex" (func $setMethodFunctionIndex))
 (export "onContextPush" (func $onContextPush))
 (export "popFromContext" (func $popFromContext))
 (export "valueOfSmallInteger" (func $valueOfSmallInteger))
 (export "smallIntegerForValue" (func $smallIntegerForValue))
 (export "classOfObject" (func $classOfObject))
 (export "contextReceiver" (func $contextReceiver))
 (export "methodLiterals" (func $methodLiterals))
 (export "contextLiteralAt" (func $contextLiteralAt))
 (export "contextMethod" (func $contextMethod))
 (export "byteArrayAt" (func $byteArrayAt))
 (export "byteArrayLength" (func $byteArrayLength))
 (export "copyByteArrayToMemory" (func $copyByteArrayToMemory))
 (export "createMinimalObjectMemory" (func $createMinimalObjectMemory))
 (export "interpret" (func $interpret))

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
 ;; The nullable fields are only nullable because their initial values
 ;; aren't always knowable at creation time.
 ;; 
 ;; Behind the scenes here in the virtual machine, null references in
 ;; fields of Smalltalk objects are given as the nil Smalltalk object
 ;; when anything at the Smalltalk level asks about them. This saves
 ;; us the effort of fixing up them up to be nil.

 (rec ;; recursive (mutually referential) type definitions
  (type $objectArray
	(array (mut eqref)))
  
  (type $byteArray
	(array (mut i8)))
  
  (type $wordArray
	(array (mut i32)))
  
  (type $Object (sub
		 (struct
		  ;; $Class or $Metaclass
		  (field $class (mut eqref))
		  
		  (field $identityHash (mut i32))
		  (field $nextObject (mut eqref)))))

  (type $Array (sub $Object 
		    (struct
		     ;; $Class or $Metaclass
		     (field $class (mut eqref))
		     
		     (field $identityHash (mut i32)) 
		     (field $nextObject (mut eqref)) 
		     (field $array (ref $objectArray)))))

  (type $ByteArray (sub $Object 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut eqref))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut eqref)) 
			 (field $array (ref $byteArray)))))

  (type $WordArray (sub $Object 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut eqref))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut eqref)) 
			 (field $array (ref $wordArray)))))

  (type $VariableObject (sub $Object 
			     (struct
			      ;; $Class or $Metaclass
			      (field $class (mut eqref))
			      
			      (field $identityHash (mut i32)) 
			      (field $nextObject (mut eqref))

			      ;; $Array, $ByteArray, or $WordArray
			      (field $slots (mut (ref eq))))))

  (type $Symbol (sub $VariableObject 
		     (struct
		      ;; $Class or $Metaclass
		      (field $class (mut eqref))
		      
		      (field $identityHash (mut i32)) 
		      (field $nextObject (mut eqref))

		      ;; $Array, $ByteArray, or $WordArray
		      (field $slots (mut (ref eq))))))

  (type $Dictionary (sub $Object 
			 (struct
			  ;; $Class or $Metaclass
			  (field $class (mut eqref))
			  
			  (field $identityHash (mut i32)) 
			  (field $nextObject (mut eqref)) 
			  (field $keys (ref $Array)) 
			  (field $values (ref $Array)) 
			  (field $count (mut i32)))))

  (type $Behavior (sub $Object 
		       (struct
			;; $Class or $Metaclass
			(field $class (mut eqref))
			
			(field $identityHash (mut i32)) 
			(field $nextObject (mut eqref))

			;; a $Class or $Metaclass
			(field $superclass (mut eqref)) 
			(field $methodDictionary (mut (ref $Dictionary))) 
			(field $format (mut i32)))))

  (type $ClassDescription (sub $Behavior 
			       (struct
				;; $Class or $Metaclass
				(field $class (mut eqref))
				
				(field $identityHash (mut i32)) 
				(field $nextObject (mut eqref))

				;; a $Class or $Metaclass
				(field $superclass (mut eqref)) 
				(field $methodDictionary (mut (ref $Dictionary))) 
				(field $format (mut i32)) 
				(field $instanceVariableNames (mut (ref $Array))) 
				(field $baseID (mut (ref null $ByteArray))))))

  (type $Class (sub $ClassDescription 
		    (struct
		     ;; $Class or $Metaclass
		     (field $class (mut eqref))
		     
		     (field $identityHash (mut i32)) 
		     (field $nextObject (mut eqref))

		     ;; a $Class or $Metaclass
		     (field $superclass (mut eqref)) 
		     (field $methodDictionary (mut (ref $Dictionary))) 
		     (field $format (mut i32)) 
		     (field $instanceVariableNames (mut (ref $Array))) 
		     (field $baseID (mut (ref null $ByteArray))) 
		     (field $subclasses (mut (ref $Array))) 
		     (field $name (mut (ref $Symbol))) 
		     (field $classPool (mut (ref $Dictionary))) 
		     (field $sharedPools (mut (ref $Array))))))

  (type $Metaclass (sub $ClassDescription 
			(struct
			 ;; $Class or $Metaclass
			 (field $class (mut eqref))
			 
			 (field $identityHash (mut i32)) 
			 (field $nextObject (mut eqref))

			 ;; a $Class or $Metaclass
			 (field $superclass (mut eqref)) 
			 (field $methodDictionary (mut (ref $Dictionary))) 
			 (field $format (mut i32)) 
			 (field $instanceVariableNames (mut (ref $Array))) 
			 (field $baseID (mut (ref null $ByteArray))) 
			 (field $thisClass (mut (ref $Class))))))

  (type $CompiledMethod (sub $VariableObject 
			     (struct
			      ;; $Class or $Metaclass
			      (field $class (mut eqref))
			      
			      (field $identityHash (mut i32)) 
			      (field $nextObject (mut eqref))

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
		       
		       (field $class (mut eqref)) 
		       (field $identityHash (mut i32)) 
		       (field $nextObject (mut eqref)) 
		       (field $sender (mut (ref null $Context))) 
		       (field $pc (mut i32)) 
		       (field $sp (mut i32))

		       ;; the nullable type is used by method lookup,
		       ;; which can return the null method
		       (field $method (mut (ref null $CompiledMethod)))
		       
		       (field $receiver (mut eqref)) 
		       (field $args (mut (ref $Array))) 
		       (field $temps (mut (ref $Array))) 
		       (field $stack (mut (ref $Array))))))

  (type $PICEntry 
	(struct 
	 (field $selector (mut eqref)) 
	 (field $receiverClass (mut (ref eq))) 

	 ;; the nullable type is used by method lookup,
	 ;; which can return the null method
	 (field $method (mut (ref null $CompiledMethod)))

	 (field $hitCount (mut i32)))) 

  (type $VirtualMachine 
	(struct
	 ;; created with a null $activeContext; it's set later
	 (field $activeContext (mut (ref null $Context)))
	 
	 (field $translationEnabled (mut i32)) 
	 (field $methodCache (mut (ref null $objectArray))) 
	 (field $functionTableBaseIndex (mut i32)) 
	 (field $translationThreshold (mut i32)) 
	 (field $methodCacheSize (mut i32)) 
	 (field $nextIdentityHash (mut i32))

	 ;; created with null $firstObject and $lastObject; they're
	 ;; set later
	 (field $firstObject (mut eqref)) 
	 (field $lastObject (mut eqref))
	 
	 (field $classSmallInteger (mut (ref null $Class))) 
	 (field $classObject (mut (ref null $Class))) 
	 (field $classContext (mut (ref null $Class))) 
	 (field $classMetaclass (mut (ref null $Class))) 
	 (field $classClassDescription (mut (ref null $Class))))))

 ;; exception tags

 (tag $messageNotUnderstood (type $messageNotUnderstood (func (param (ref $Symbol)))))
 
 ;; Reference-type globals are nullable due to current WASM
 ;; limitations, but are enforced to be non-null after object memory
 ;; creation.

 ;; start of staging bytes
 (global $byteArrayCopyPointer (mut i32) (i32.const 1024))

 ;; linear memory for staging byte arrays visible to JS. See $copyByteArrayToMemory.
 (memory $0 1)

 ;; translated methods function table (the only table in this module)
 (table $functionTable 100 funcref)
 
 (func $newArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $objectArray)) 
       (result (ref $Array))
       
       (struct.new $Array
		   (ref.null none)         ;; $class to be set later, to class Array
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array
 
 (func $newByteArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $byteArray)) 
       (result (ref $ByteArray))
       
       (struct.new $ByteArray
		   (ref.null none)         ;; $class to be set later, to class ByteArray
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array
 
 (func $newWordArray
       (param $vm (ref $VirtualMachine)) 
       (param $array (ref $wordArray)) 
       (result (ref $WordArray))
       
       (struct.new $WordArray
		   (ref.null none)         ;; $class to be set later, to class Array
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $array)))    ;; $array
 
 (func $newDictionary
       (param $vm (ref $VirtualMachine)) 
       (result (ref $Dictionary))
       
       (struct.new $Dictionary
		   (ref.null none)         ;; $class to be set later, to class Dictionary
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (ref.null none)         ;; $keys
		   (ref.null none)         ;; $values
		   (i32.const 0)))         ;; $count

 ;; Link $objects via their $nextObject fields.
 
 (func $linkObjects
       (param $vm (ref $VirtualMachine)) 
       (param $objects (ref $objectArray))
       
       (local $previousObject eqref)
       (local $nextObject eqref)
       (local $limit i32)
       (local $index i32)
       (local $scratch (ref $VirtualMachine))
       
       (local.set $limit
		  (i32.sub
		   (array.len
		    (local.get $objects))
		   (i32.const 1)))
       
       (local.set $index
		  (i32.const 0))
       
       (local.set $previousObject
		  (struct.get $VirtualMachine $lastObject
			      (local.get $vm)))
       
       (loop $link
	     (if
	      (i32.eq
	       (local.get $index)
	       (local.get $limit))
	      (then
	       (return)))
	     (local.set $nextObject
			(array.get $objectArray
				   (local.get $objects)
				   (local.get $index)))

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

	     (local.set $previousObject
			(local.get $nextObject))

	     (br_if $link
		    (i32.const 1))))

 ;; Link the objects of a $Class.
 
 (func $linkClassObjects
       (param $vm (ref $VirtualMachine)) 
       (param $class (ref $Class))
       
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
					  (local.get $class)))))

 ;; Link the objects of a $Metaclass.
 
 (func $linkMetaclassObjects
       (param $vm (ref $VirtualMachine)) 
       (param $metaclass (ref $Metaclass))
       
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
       
       (call $linkClassObjects
	     (local.get $vm)
	     (struct.get $Metaclass $thisClass
			 (local.get $metaclass))))
 
 (func $newEmptyArray
       (param $vm (ref $VirtualMachine)) 
       (result (ref $Array))
       
       (call $newArray                   ;; $instanceVariableNames
	     (local.get $vm)
	     (array.new $objectArray
			(ref.null none)  ;; default array element type
			(i32.const 0)))) ;; empty
 
 (func $newClassOfFormatWithName
       (param $vm (ref $VirtualMachine)) 
       (param $format i32) 
       (param $name (ref $Symbol)) 
       (result (ref $Class))
       
       (struct.new $Class
		   (ref.null none)          ;; $class to be set later, to (Object class)
		   (call $nextIdentityHash  ;; $identityHash
			 (local.get $vm))
		   (ref.null none)          ;; $nextObject to be set later
		   (ref.null none)          ;; $superclass is nil
		   (call $newDictionary     ;; $methodDictionary
			 (local.get $vm))
		   (local.get $format)      ;; $format
		   (call $newEmptyArray     ;; $instanceVariableNames
			 (local.get $vm))
		   (ref.null none)          ;; $baseID to be set later (should be a $UUID)
		   (call $newEmptyArray
			 (local.get $vm))
		   (local.get $name)        ;; $name
		   (call $newDictionary     ;; $classPool
			 (local.get $vm))
		   (call $newEmptyArray     ;; $sharedPools
			 (local.get $vm))))
 
 (func $newMetaclassForClass
       (param $vm (ref $VirtualMachine)) 
       (param $class (ref $Class)) 
       (result (ref eq))
       
       (struct.new $Metaclass
		   (struct.get $VirtualMachine $classMetaclass        ;; $class
			       (local.get $vm))
		   (call $nextIdentityHash                            ;; $identityHash
			 (local.get $vm))
		   ;; $nextObject to be set later
		   (ref.null none)                                    
		   (struct.get $VirtualMachine $classClassDescription ;; $superclass
			       (local.get $vm))
		   (call $newDictionary                               ;; $methodDictionary
			 (local.get $vm))
		   (i32.const 152)                                    ;; $format
		   (call $newEmptyArray                               ;; $instanceVariableNames
			 (local.get $vm))
		   ;; $baseID to be set later (should be a $UUID)
		   (ref.null none)                                    
		   (local.get $class)))                               ;; $thisClass
 
 (func $newSymbolFromBytes
       (param $vm (ref $VirtualMachine)) 
       (param $bytes (ref $byteArray)) 
       (result (ref $Symbol))
       
       (struct.new $Symbol
		   (ref.null none)         ;; $class to be set later, to class Symbol
		   (call $nextIdentityHash ;; $identityHash
			 (local.get $vm))
		   (ref.null none)         ;; $nextObject to be set later
		   (local.get $bytes)))    ;; $slots
 
 (func $initialize
       (result (ref $VirtualMachine))
       
       (local $methodCacheSize i32)
       (local $firstObject eqref)
       (local $vm (ref $VirtualMachine))
       (local $classObject (ref $Class))
       (local $classBehavior (ref $Class))
       (local $classClassDescription (ref $Class))
       (local $classClass (ref $Class))
       (local $classMetaclass (ref $Class))
       (local $classSymbol (ref $Class))
       (local $classSmallInteger (ref $Class))
       
       (local.set $methodCacheSize
		  (i32.const 256))
       
       (local.set $firstObject
		  (struct.new $Object
			      (ref.null none)              ;; $class
			      (i32.const 1)                ;; $identityHash
			      (ref.null none)))            ;; $nextObject
       
       (local.set $vm
		  (struct.new $VirtualMachine
			      (ref.null none)              ;; $activeContext to be set later
			      (i32.const 1)                ;; translationEnabled
			      (ref.null none)              ;; $methodCache
			      (i32.const 0)                ;; $functionTableBaseIndex
			      (i32.const 1000)             ;; $translationThreshold
			      (local.get $methodCacheSize) ;; $methodCacheSize
			      (i32.const 1001)             ;; $nextIdentityHash
			      (local.get $firstObject)     ;; $firstObject
			      (local.get $firstObject)     ;; $lastObject
			      (ref.null none)              ;; $classSmallInteger to be set later
			      (ref.null none)              ;; $classObject to be set later
			      (ref.null none)              ;; $classContext to be set later
			      (ref.null none)              ;; $classMetaclass to be set later

			      ;; $classClassDescription to be set later
			      (ref.null none)))            

       ;; The simplest virtual machine runs (3 squared). Create class SmallInteger.
       ;; First create a Metaclass to be the class of class SmallInteger.
       ;; First create class Class to be the superclass of (SmallInteger class).
       ;; First create (Class class) to be the class of class Class.
       ;; First create class Class to be the superclass of (Class class). We've been here before.
       ;; First create class Class with a null class, to be set later.
       ;; First create class Object to be the superclass of class Class.
       ;; First create (Object class) to be the class of class Object. We've been here before.
       ;; First create class Class with a null class and superclass, to be set later.
       ;; First create the superclasses of class Class, with null classes and superclasses.
       ;; 
       ;; This is why $class and $superclass of $Class are nullable
       ;; ($class is also nullable because the class of class
       ;; Metaclass is also an instance of class Metaclass, and
       ;; $superclass is also nullable because the superclass of class
       ;; Object is nil).

       ;; Create class Object.
       (local.set $classObject
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 6
					       (i32.const 79)      ;; 'O'
					       (i32.const 98)      ;; 'b'
					       (i32.const 106)     ;; 'j'
					       (i32.const 101)     ;; 'e'
					       (i32.const 99)      ;; 'c'
					       (i32.const 116))))) ;; 't'
       
       (struct.set $VirtualMachine $classObject
		   (local.get $vm)
		   (local.get $classObject))

       ;; Create class Behavior.
       (local.set $classBehavior
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
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

       ;; Create class ClassDescription.
       (local.set $classClassDescription
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
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
       
       (struct.set $VirtualMachine $classClassDescription
		   (local.get $vm)
		   (local.get $classClassDescription))

       ;; Create class Metaclass.
       (local.set $classMetaclass
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
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
       
       (struct.set $VirtualMachine $classMetaclass
		   (local.get $vm)
		   (local.get $classMetaclass))

       ;; Create class Class.
       (local.set $classClass
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 5
					       (i32.const 67)      ;; 'C'
					       (i32.const 108)     ;; 'l'
					       (i32.const 97)      ;; 'a'
					       (i32.const 115)     ;; 's'
					       (i32.const 115))))) ;; 's'

       ;; Create class Symbol.
       (local.set $classSymbol
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
			      (local.get $vm)
			      (array.new_fixed $byteArray 6
					       (i32.const 83)      ;; 'S'
					       (i32.const 121)     ;; 'y'
					       (i32.const 109)     ;; 'm'
					       (i32.const 98)      ;; 'b'
					       (i32.const 111)     ;; 'o'
					       (i32.const 108))))) ;; 'l'
       
       (local.set $classSmallInteger
		  (call $newClassOfFormatWithName
			(local.get $vm)
			(i32.const 2)                              ;; $format
			(call $newSymbolFromBytes                  ;; $name
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
       
       (struct.set $VirtualMachine $classSmallInteger
		   (local.get $vm)
		   (local.get $classSmallInteger))

       ;; Fix up all the fields that were to be set later.

       ;; Set the class of class Object.
       (struct.set $Class $class
		   (local.get $classObject)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classObject)))

       ;; Set the class of class Object's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classObject))
		   (local.get $classSymbol))

       ;; Set the class of class Behavior.
       (struct.set $Class $class
		   (local.get $classBehavior)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classBehavior)))

       ;; Set the superclass of class Behavior.
       (struct.set $Class $superclass
		   (local.get $classBehavior)
		   (local.get $classObject))

       ;; Set the class of class Behavior's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classBehavior))
		   (local.get $classSymbol))

       ;; Set the class of class ClassDescription.
       (struct.set $Class $class
		   (local.get $classClassDescription)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classClassDescription)))

       ;; Set the superclass of class ClassDescription.
       (struct.set $Class $superclass
		   (local.get $classClassDescription)
		   (local.get $classBehavior))

       ;; Set the class of class ClassDescription's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classClassDescription))
		   (local.get $classSymbol))

       ;; Set the class of class Class.
       (struct.set $Class $class
		   (local.get $classClass)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classClass)))

       ;; Set the superclass of class Class.
       (struct.set $Class $superclass
		   (local.get $classClass)
		   (local.get $classClassDescription))

       ;; Set the class of class Class's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classBehavior))
		   (local.get $classSymbol))

       ;; Set the class of class Metaclass.
       (struct.set $Class $class
		   (local.get $classMetaclass)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classMetaclass)))

       ;; Set the superclass of class Metaclass.
       (struct.set $Class $superclass
		   (local.get $classMetaclass)
		   (local.get $classObject))

       ;; Set the class of class Metaclass's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classMetaclass))
		   (local.get $classSymbol))

       ;; Set the class of class Symbol.
       (struct.set $Class $class
		   (local.get $classSymbol)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classSymbol)))

       ;; Set the superclass of class Symbol.
       (struct.set $Class $superclass
		   (local.get $classSymbol)
		   (local.get $classObject))

       ;; Set the class of class Symbol's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classSymbol))
		   (local.get $classSymbol))

       ;; Set the class of class SmallInteger.
       (struct.set $Class $class
		   (local.get $classSmallInteger)
		   (call $newMetaclassForClass
			 (local.get $vm)
			 (local.get $classSmallInteger)))

       ;; Set the superclass of class Symbol.
       (struct.set $Class $superclass
		   (local.get $classSmallInteger)
		   (local.get $classObject))

       ;; Set the class of class SmallInteger's name symbol.
       (struct.set $Symbol $class
		   (struct.get $Class $name
			       (local.get $classSmallInteger))
		   (local.get $classSymbol))

       ;; Link objects' $nextObject fields.
       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classObject))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classBehavior))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classClassDescription))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classClass))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classMetaclass))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classSymbol))))

       (call $linkMetaclassObjects
	     (local.get $vm)
	     (ref.cast (ref $Metaclass)
		       (struct.get $Class $class
				   (local.get $classSmallInteger))))

       (local.get $vm))

 ;; utilities for method translation in JS
 
 (func $methodBytecodes
       (param $method eqref) 
       (result (ref eq))
       
       (struct.get $CompiledMethod $slots
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))))
 
 (func $setMethodFunctionIndex
       (param $method eqref) 
       (param $index i32)
       
       (struct.set $CompiledMethod $functionIndex
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))
		   (local.get $index)))
 
 (func $onContextPush
       (param $context eqref) 
       (param $pushedObject eqref)
       
       (call $pushOnStack
	     (ref.cast (ref $Context)
		       (local.get $context))
	     (local.get $pushedObject)))
 
 (func $popFromContext
       (param $context eqref) 
       (result eqref)
       
       (call $popFromStack
	     (ref.cast (ref $Context)
		       (local.get $context))))
 
 (func $contextReceiver
       (param $context eqref) 
       (result eqref)
       
       (struct.get $Context $receiver
		   (ref.cast (ref $Context)
			     (local.get $context))))
 
 (func $methodLiterals
       (param $method eqref) 
       (result eqref)
       
       (struct.get $CompiledMethod $literals
		   (ref.cast (ref $CompiledMethod)
			     (local.get $method))))
 
 (func $contextLiteralAt
       (param $context eqref) 
       (param $index i32) 
       (result eqref)
       
       (call $objectArrayAt
	     (ref.cast (ref none)
		       (struct.get $CompiledMethod $literals
				   (struct.get $Context $method
					       (ref.cast (ref $Context)
							 (local.get $context)))))
	     (local.get $index)))
 
 (func $contextMethod
       (param $context eqref) 
       (result eqref)
       
       (struct.get $Context $method
		   (ref.cast (ref $Context)
			     (local.get $context))))
 
 (func $arrayOkayAt
       (param $array eqref) 
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
 
 (func $objectArrayAt
       (param $array (ref $objectArray)) 
       (param $index i32) 
       (result eqref)
       
       (if
	(i32.eqz
	 (call $arrayOkayAt
	       (ref.cast (ref $objectArray)
			 (local.get $array))
	       (local.get $index)))
	(then
	 (return
	   (ref.i31
	    (i32.const -1)))))

       ;; Safe to access array.
       (array.get $objectArray
		  (local.get $array)
		  (local.get $index)))
 
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
 
 (func $byteArrayLength
       (param $array eqref) 
       (result i32)
       
       (array.len
	(ref.cast (ref $byteArray)
		  (local.get $array))))
 
 (func $copyByteArrayToMemory
       (param $0 (ref $byteArray)) 
       (result i32)
       
       (local $len i32)
       (local $i i32)
       
       (if
	(ref.is_null
	 (local.get $0))
	(then
	 (return
	   (i32.const 0))))
       
       (local.set $len
		  (array.len
		   (ref.as_non_null
		    (local.get $0))))
       
       (local.set $i
		  (i32.const 0))
       
       (loop $copy
	     (if
	      (i32.ge_u
	       (local.get $i)
	       (local.get $len))
	      (then
	       (return
		 (global.get $byteArrayCopyPointer))))
	     
	     (i32.store8
	      (i32.add
	       (global.get $byteArrayCopyPointer)
	       (local.get $i))
	      (array.get_u $byteArray
			   (ref.as_non_null
			    (local.get $0))
			   (local.get $i)))
	     
	     (local.set $i
			(i32.add
			 (local.get $i)
			 (i32.const 1)))
	     
	     (br $copy))

       (unreachable))
 
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
 
 (func $pushOnStack
       (param $context (ref $Context)) 
       (param $value eqref)
       
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
 
 (func $popFromStack
       (param $context (ref null $Context)) 
       (result eqref)

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
	(i32.le_u
	 (local.get $sp)
	 (i32.const 0))
	(then
	 (return
	   (ref.null none))))

       ;; Decrement stack pointer.
       (struct.set $Context $sp
		   (local.get $context)
		   (i32.sub
		    (local.get $sp)
		    (i32.const 1)))

       ;; Return top value.
       (return
	 (array.get $objectArray
		    
		    (struct.get $Array $array
				(local.get $stack))
		    (i32.sub
		     (local.get $sp)
		     (i32.const 1)))))
 
 (func $topOfStack
       (param $context (ref null $Context)) 
       (result eqref)
       
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
	(i32.le_u
	 (local.get $sp)
	 (i32.const 0))
	(then
	 (return
	   (ref.null none))))

       ;; Return top value without popping.
       (return
	 (array.get $objectArray
		    (struct.get $Array $array
				(local.get $stack))
		    (i32.sub
		     (local.get $sp)
		     (i32.const 1)))))
 
 (func $classOfObject
       (param $vm (ref $VirtualMachine)) 
       (param $obj eqref) 
       (result eqref)

       (if (result eqref)
	(ref.test (ref i31)
		  (local.get $obj))
	(then
	 (struct.get $VirtualMachine $classSmallInteger
		     (local.get $vm)))
	(else
	 (struct.get $Object $class
		     (ref.cast (ref $Object)
			       (local.get $obj))))))
 
 (func $lookupMethod
       (param $vm (ref $VirtualMachine)) 
       (param $receiver eqref) 
       (param $selector eqref) 
       (result (ref null $CompiledMethod))
       
       (local $class eqref)
       (local $currentClass eqref)
       (local $methodDictionary (ref $Dictionary))
       (local $keys (ref $Array))
       (local $values (ref $Array))
       (local $count i32)
       (local $i i32)
       (local $key eqref)

       ;; Get receiver's class.
       (local.set $currentClass
		  (ref.cast (ref null $Class)
			    (call $classOfObject
				  (local.get $vm)
				  (local.get $receiver))))

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
	     (local.set $i
			(i32.const 0))
	     
	     (loop $search_loop
		   (if
		    (i32.ge_u
		     (local.get $i)
		     (local.get $count))
		    (then
		     ;; Not found in this class; try superclass.
		     (local.set $currentClass
				
				(struct.get $Class $superclass
					    (ref.cast (ref $Class)
						      (local.get $currentClass))))
		     (br $hierarchy_loop)))

		   ;; Get key at index i.
		   (local.set $key
			      (array.get $objectArray
					 (struct.get $Array $array
						     (local.get $keys))
					 (local.get $i)))

		   ;; Compare with selector.
		   (if
		    (ref.eq
		     (local.get $key)
		     (local.get $selector))
		    (then
		     ;; Found! Get the method.
		     (return
		       (ref.cast (ref $CompiledMethod)
				 (array.get $objectArray
					    
					    (struct.get $Array $array
							(local.get $values))
					    (local.get $i))))))

		   ;; Increment and continue.
		   (local.set $i
			      (i32.add
			       (local.get $i)
			       (i32.const 1)))
		   
		   (br $search_loop)))

       (unreachable))
 
 (func $lookupInMethodCache
       (param $vm (ref $VirtualMachine)) 
       (param $selector eqref) 
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
	   (ref.null none))))

       (local.set $index
		  (i32.rem_u
		   (i32.add
		    ;; simple hash function (identity hash of selector + class)
		    (struct.get $Object $identityHash
				(ref.cast (ref $Object)
					  (local.get $selector)))
		    (struct.get $Class $identityHash
				(ref.as_non_null
				 (local.get $receiverClass))))
		   (struct.get $VirtualMachine $methodCacheSize
			       (local.get $vm))))

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
		 (struct.get $PICEntry $method
			     (local.get $entry)))))

	     ;; Try next slot.
	     (local.set $index
			(i32.rem_u
			 (i32.add
			  (local.get $index)
			  (i32.const 1))
			 (struct.get $VirtualMachine $methodCacheSize
				     (local.get $vm))))

	     (local.set $probeLimit
			(i32.sub
			 (local.get $probeLimit)
			 (i32.const 1)))

	     (br $probe_loop))

       (unreachable))
 
 (func $storeInMethodCache
       (param $vm (ref $VirtualMachine)) 
       (param $selector (ref $Symbol)) 
       (param $receiverClass (ref eq)) 
       (param $method (ref null $CompiledMethod)) ;; Nullable: there might be a cache miss.
       
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
		   (struct.get $VirtualMachine $methodCacheSize
			       (local.get $vm))))

       ;; Create new cache entry.
       (local.set $entry
		  (struct.new $PICEntry
			      (local.get $selector)
			      (local.get $receiverClass)
			      (local.get $method)
			      (i32.const 1)))            ;; initial hit count

       ;; Store in cache.
       (array.set $objectArray
		  (ref.as_non_null
		   (local.get $cache))
		  (local.get $index)
		  (local.get $entry)))
 
 (func $newContext
       (param $vm (ref $VirtualMachine)) 
       (param $receiver eqref) 
       (param $method (ref null $CompiledMethod)) ;; $vm was created with null $activeContext
       (param $selector eqref) 
       (result (ref $Context))
        
       (struct.new $Context
		   (struct.get $VirtualMachine $classContext  ;; $class
			       (local.get $vm))
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
			     (i32.const 0))
		   (call $newArray                            ;; $stack
			 (local.get $vm)
			 (array.new $objectArray
				    (ref.null none)
				    (i32.const 20)))
 
 (func $smallIntegerForValue
       (param $value i32) 
       (result (ref i31))
       
       (ref.i31
	(local.get $value)))
 
 (func $valueOfSmallInteger
       (param $obj eqref) 
       (result i32)
       
       (if (result i32)
	(ref.test (ref i31)
		  (local.get $obj))
	(then
	 (i31.get_s
	  (ref.cast (ref i31)
		    (local.get $obj))))
	(else
	 ;; Not a SmallInteger; return 0 for safety.
	 (i32.const 0))))
 
 (func $isTranslated
       (param $method (ref null $CompiledMethod)) 
       (result i32)

       (i32.gt_u ;; We start at index 1, to make the value easier to discern in debuggers.
	(struct.get $CompiledMethod $functionIndex
		    (local.get $method))
	(i32.const 0)))
 
 (func $executeTranslatedMethod
       (param $context (ref null $Context)) 
       (param $functionIndex i32)
       ;; Translation function returns 0 for success.
       (result i32)

       (call_indirect $functionTable (param eqref) (result i32)
		      (local.get $context)
		      (local.get $functionIndex)))
 
 (func $triggerMethodTranslation
       (param $method (ref null $CompiledMethod))
       (param $identityHash i32)
       
       (local $slots eqref)
       (local $bytecodeLength i32)
       (local $functionIndexIndex i32)
       (local $memoryOffset i32)
       
       (local.set $slots
		    (struct.get $CompiledMethod $slots
				(local.get $method)))

       (local.set $bytecodeLength
		  (array.len
		   (ref.cast (ref $byteArray)
			     (local.get $slots))))

       ;; JS does the translation; it's easier to implement and debug
       ;; there, and it doesn't need to be fast.
       (call $translateMethod
	     (local.get $method)
	     (local.get $identityHash)))
 
 (func $handleMethodReturn
       (param $vm (ref $VirtualMachine)) 
       (param $context (ref null $Context)) 
       (result eqref)
       
       (local $sender (ref null $Context))
       (local $result eqref)
       
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

 ;; Create minimal object memory for running (100 benchmark).
 
 (func $createMinimalObjectMemory
       (param $vm (ref $VirtualMachine)) 
       (result i32)
       
       (local $benchmarkMethod (ref $CompiledMethod))
       (local $benchmarkSelector (ref $Symbol))
       (local $methodDictionary (ref $Dictionary))
       (local $literalsOfUnboundMethod (ref $Array))
       (local $benchmarkLiterals (ref $objectArray))
       
       (local.set $benchmarkSelector
		  (call $newSymbolFromBytes
			(local.get $vm)
			(array.new_fixed $byteArray 8
					 (i32.const 98)     ;; 'b'
					 (i32.const 101)    ;; 'e'
					 (i32.const 110)    ;; 'n'
					 (i32.const 99)     ;; 'c'
					 (i32.const 104)    ;; 'h'
					 (i32.const 109)    ;; 'm'
					 (i32.const 97)     ;; 'a'
					 (i32.const 114)    ;; 'r'
					 (i32.const 107)))) ;; 'k'

       (local.set $literalsOfUnboundMethod
		  (call $newArray
			(local.get $vm)
			(array.new $objectArray
				   (local.get $benchmarkSelector)
				   (i32.const 1))))

       ;; Set $vm's $activeContext to run an unbound method which runs (100 benchmark).
       (struct.set $VirtualMachine $activeContext
		   (local.get $vm)
		   (call $newContext
			 (local.get $vm)                  ;; $vm
			 (ref.i31                         ;; $receiver
			  (i32.const 100))           
			 (struct.new $CompiledMethod      ;; $method
				     (struct.get $VirtualMachine $classObject ;; $class
						 (local.get $vm))
				     (call $nextIdentityHash                  ;; $identityHash
					   (local.get $vm))
				     (ref.null none)                          ;; $nextObject
				     (array.new_fixed $byteArray 3            ;; $slots
						      (i32.const 112)
						      (i32.const 208)
						      (i32.const 124))
				     (local.get $literalsOfUnboundMethod)     ;; $literals
				     (i32.const 0)                            ;; $header
				     (i32.const 0)                            ;; $invocationCount
				     (i32.const 0)                            ;; $functionIndex
                                     ;; $translationThreshold
				     (struct.get $VirtualMachine $translationThreshold
						 (local.get $vm))
				     (i32.const 0))                           ;; $isInstalled
			 (local.get $benchmarkSelector))) ;; $selector

       ;; Create the workload method.
       
       (local.set $benchmarkLiterals
		  (array.new $objectArray
			     (ref.null none)
			     (i32.const 4)))
       
       (array.set $objectArray
		  (local.get $benchmarkLiterals)
		  (i32.const 0)
		  (ref.as_non_null
		   (call $smallIntegerForValue
			 (i32.const 0))))
       
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
       ;; This workload method performs a simple iterative arithmetic
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
			      (struct.get $VirtualMachine $classObject ;; $class
					  (local.get $vm))
			      (call $nextIdentityHash                  ;; $identityHash
				    (local.get $vm))
			      (ref.null none)                          ;; $nextObject
			      (array.new_fixed $byteArray 62           ;; $slots
				   (i32.const 0x70)  ;; push receiver

				   (i32.const 0x21)  ;; push literal 1 (0-based)
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply

				   ;; sequence repeats five times in total
				   (i32.const 0x21)  ;; push literal 1
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   
				   (i32.const 0x21)  ;; push literal 1
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   
				   (i32.const 0x21)  ;; push literal 1
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   
				   (i32.const 0x21)  ;; push literal 1
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB8)  ;; multiply
				   (i32.const 0x23)  ;; push literal 3
				   (i32.const 0xB0)  ;; add
				   (i32.const 0x22)  ;; push literal 2
				   (i32.const 0xB8)  ;; multiply

				   (i32.const 0x7C)) ;; return top of stack
			      (call $newArray                       ;; $literals
				    (local.get $vm)
				    (local.get $benchmarkLiterals))
			      (i32.const 0)                         ;; $header
			      (i32.const 0)                         ;; $invocationCount
			      (i32.const 0)                         ;; $functionIndex
			      ;; $translationThreshold
			      (struct.get $VirtualMachine $translationThreshold
					  (local.get $vm))
			      (i32.const 0)))                       ;; $isInstalled
       
       (local.set $methodDictionary
		  (call $newDictionary
			(local.get $vm)))
       
       (struct.set $Class $methodDictionary
		   (struct.get $VirtualMachine $classSmallInteger
			       (local.get $vm))
		   (local.get $methodDictionary))

       (array.set $objectArray
		  (struct.get $Array $array
			      (struct.get $Dictionary $keys
					  (local.get $methodDictionary)))
		  (i32.const 0)
		  (local.get $benchmarkSelector))

       (array.set $objectArray
		  (struct.get $Array $array
			      (struct.get $Dictionary $values
					  (local.get $methodDictionary)))
		  (i32.const 0)
		  (local.get $benchmarkMethod))
       
       (struct.set $Dictionary $count
		   (local.get $methodDictionary)
		   (i32.const 1))
       
       (struct.set $CompiledMethod $isInstalled
		   (local.get $benchmarkMethod)
		   (i32.const 1))

       ;; success
       (i32.const 1))

 ;; Interpret single bytecode; return 1 if method should return, 0 to continue.
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
	       (array.get $objectArray
			  (local.get $literals)
			  (local.get $index)))
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
	       (ref.as_non_null
		(call $smallIntegerForValue
		      (i32.mul
		       (call $valueOfSmallInteger
			     (call $popFromStack
				   (local.get $context)))
		       (call $valueOfSmallInteger
			     (call $popFromStack
				   (local.get $context)))))))
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
		      (call $valuenOfSmallInteger
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
			  (local.get $context))))
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
	     (throw $messageNotUnderstood)))
	  (call $storeInMethodCache
		(local.get $vm)
		(local.get $selector)
		(local.get $receiverClass)
		(local.get $method))))
	(struct.set $VirtualMachine $activeContext
		    (local.get $vm)
		    (call $newContext
			  (local.get $vm)
			  (local.get $receiver)
			  (local.get $method)
			  (local.get $selector)))
	(return
	  (i32.const 0)))

       ;; unimplemented bytecode
       (unreachable))
 
 (func $interpret
       (param $vm (ref $VirtualMachine)) 
       (result i32)

       (local $context (ref null $Context))
       (local $method (ref null $CompiledMethod))
       (local $bytecode i32)
       (local $pc i32)
       (local $receiver eqref)
       (local $resultValue eqref)
       (local $invocationCount i32)
       (local $slots (ref $byteArray))
       (local $functionIndex i32)
       
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
		     (call $triggerMethodTranslation
			   (local.get $method)
			   (struct.get $Object $identityHash
				       (ref.cast (ref $Object)
						 (local.get $receiver))))))))))
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
	       (local.set $slots
			  (struct.get $ByteArray $array
				      (ref.cast (ref $ByteArray)
						(struct.get $CompiledMethod $slots
							    (local.get $method)))))

	       (loop $interpreter_loop
		     (br_if $execution_loop
			    (ref.is_null
			     ;; We've returned to a nil context sender; execution is finished.
			     (local.tee $context
					(struct.get $VirtualMachine $activeContext
						    (local.get $vm)))))

		     (local.set $pc
				(struct.get $Context $pc
					    (ref.as_non_null
					     (local.get $context))))

		     ;; Check if we've reached the end of the current $method's bytecodes.
		     (if
		      (i32.le_u
		       (array.len
			(local.tee $slots
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
					     (local.get $slots)
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

       (unreachable))
