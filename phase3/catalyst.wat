;; catalyst.wat: multiple simultaneous Catalyst Smalltalk virtual
;; machines, with method translation

(module
 ;; imported external functions from JS
 
 (import "env" "reportResult" (
			       func $reportResult
			       (param i32)))

 ;; JS translates method and installs translation function
 (import "env" "translateMethod" (
				  func $translateMethod
				  (param eqref)  ;; method
				  (param i32)))   ;; method identity hash

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
 ;; The nullable fields are only nullable because their initial values
 ;; aren't always knowable at creation time.
 ;; 
 ;; Behind the scenes here in the virtual machine, null references in
 ;; fields of Smalltalk objects are given as the nil Smalltalk object
 ;; when anything at the Smalltalk level asks about them. This saves
 ;; us the effort of fixing up them up to be nil.
 
 (rec ;; recursive (mutually referential) type definitionsox

  ;; Arrays created with these three array types are not Smalltalk
  ;; objects unto themselves. A $VirtualMachine uses them for things
  ;; that aren't objects (like $methodCache), $Array and $ByteArray
  ;; use them to define objects that wrap them (e.g.,
  ;; $Context$methodCache and $Symbol$bytes)

  (type $objectArray (array (mut (ref null eq))))
  (type $byteArray (array (mut i8)))
  (type $wordArray (array (mut i32)))

  (type $Object (sub (struct
		      ;; $Class or $Metaclass
		      (field $class (mut (ref null eq)))

		      (field $identityHash (mut i32))
		      (field $nextObject (mut (ref null eq)))
		      )))

  ;; (A proper Collection hierarchy connected to class Object is coming later.)

  (type $Array (sub $Object (struct
			     ;; $Class or $Metaclass
			     (field $class (mut (ref null eq)))

			     (field $identityHash (mut i32))
			     (field $nextObject (mut (ref null eq)))
			     (field $array (ref $objectArray))
			     )))

  (type $ByteArray (sub $Object (struct
				 ;; $Class or $Metaclass
				 (field $class (mut (ref null eq)))

				 (field $identityHash (mut i32))
				 (field $nextObject (mut (ref null eq)))
				 (field $array (ref $byteArray))
				 )))

  (type $WordArray (sub $Object (struct
				 ;; $Class or $Metaclass
				 (field $class (mut (ref null eq)))

				 (field $identityHash (mut i32))
				 (field $nextObject (mut (ref null eq)))
				 (field $array (ref $wordArray))
				 )))

  (type $VariableObject (sub $Object (struct
				      ;; $Class or $Metaclass
				      (field $class (mut (ref null eq)))

				      (field $identityHash (mut i32))
				      (field $nextObject (mut (ref null eq)))
				      
				      ;; $Array, $ByteArray, or $WordArray
				      (field $slots (mut (ref eq)))
				      )))
  
  (type $Symbol (sub $VariableObject (struct
  				      ;; $Class or $Metaclass
				      (field $class (mut (ref null eq)))

				      (field $identityHash (mut i32))
				      (field $nextObject (mut (ref null eq)))
				      
				      ;; $Array, $ByteArray, or $WordArray
				      (field $slots (mut (ref eq)))
				      )))

  (type $Dictionary (sub $Object (struct
				  ;; $Class or $Metaclass
				  (field $class (mut (ref null eq)))

				  (field $identityHash (mut i32))
				  (field $nextObject (mut (ref null eq)))
				  (field $keys (ref null $Array))
				  (field $values (ref null $Array))
				  (field $count (mut i32))
				  )))
  
  (type $Behavior (sub $Object (struct
				;; $Class or $Metaclass
				(field $class (mut (ref null eq)))

				(field $identityHash (mut i32))
				(field $nextObject (mut (ref null eq)))
				
				;; a $Class or $Metaclass
				(field $superclass (mut (ref null eq)))

				(field $methodDictionary (mut (ref $Dictionary)))
				(field $format (mut i32))
				)))

  (type $ClassDescription (sub $Behavior (struct
					  ;; $Class or $Metaclass
					  (field $class (mut (ref null eq)))

					  (field $identityHash (mut i32))
					  (field $nextObject (mut (ref null eq)))
					  
					  ;; a $Class or $Metaclass
					  (field $superclass (mut (ref null eq)))

					  (field $methodDictionary (mut (ref $Dictionary)))
					  (field $format (mut i32))
					  (field $instanceVariableNames (mut (ref $Array)))
					  (field $baseID (mut (ref null $ByteArray)))
					  )))

  (type $Class (sub $ClassDescription (struct
				       ;; $Class or $Metaclass
				       (field $class (mut (ref null eq)))

				       (field $identityHash (mut i32))
				       (field $nextObject (mut (ref null eq)))
				       
				       ;; a $Class or $Metaclass
				       (field $superclass (mut (ref null eq)))

				       (field $methodDictionary (mut (ref $Dictionary)))
				       (field $format (mut i32))
				       (field $instanceVariableNames (mut (ref $Array)))
				       (field $baseID (mut (ref null $ByteArray)))
				       (field $subclasses (mut (ref $Array)))
				       (field $name (mut (ref $Symbol)))
				       (field $classPool (mut (ref $Dictionary)))
				       (field $sharedPools (mut (ref $Array)))
				       )))

  (type $Metaclass (sub $ClassDescription (struct
					   ;; $Class or $Metaclass
					   (field $class (mut (ref null eq)))

					   (field $identityHash (mut i32))
					   (field $nextObject (mut (ref null eq)))
					   
					   ;; a $Class or $Metaclass
					   (field $superclass (mut (ref null eq)))

					   (field $methodDictionary (mut (ref $Dictionary)))
					   (field $format (mut i32))
					   (field $instanceVariableNames (mut (ref $Array)))
					   (field $baseID (mut (ref null $ByteArray)))
					   (field $thisClass (mut (ref $Class)))
					   )))

  (type $CompiledMethod (sub $VariableObject (struct
					      ;; $Class or $Metaclass
					      (field $class (mut (ref null eq)))

					      (field $identityHash (mut i32))
					      (field $nextObject (mut (ref null eq)))
					      
					      ;; $Array, $ByteArray, or $WordArray
					      (field $slots (mut (ref eq)))
					      (field $literals (ref $Array))
					      (field $header i32)
					      (field $invocationCount (mut i32))

					      ;; Index into function table
					      (field $functionIndex (mut i32))  

					      (field $translationThreshold i32)

					      ;; 0 = not installed, 1 = installed
					      (field $isInstalled (mut i32))   
					      )))
  
  (type $Context (sub $Object (struct
			       ;; $Class or $Metaclass
			       (field $class (mut (ref null eq)))

			       (field $identityHash (mut i32))
			       (field $nextObject (mut (ref null eq)))
			       (field $sender (mut (ref null $Context)))
			       (field $pc (mut i32))
			       (field $sp (mut i32))
			       (field $method (mut (ref null $CompiledMethod))) ;; for cache misses
			       (field $receiver (mut eqref))
			       (field $args (mut (ref $Array)))
			       (field $temps (mut (ref $Array)))
			       (field $stack (mut (ref $Array)))
			       )))
  
  (type $PICEntry (struct
                   (field $selector (mut eqref))
                   (field $receiverClass (mut (ref eq)))
                   (field $method (mut (ref null $CompiledMethod))) ;; for cache misses
                   (field $hitCount (mut i32))
                   ))
  
  (type $VirtualMachine (struct
			 ;; created with a null $activeContext; it's set later
			 (field $activeContext (mut (ref null $Context)))

			 (field $translationEnabled (mut i32))
			 (field $methodCache (mut (ref null $objectArray)))
			 (field $functionTableBaseIndex (mut i32))
			 (field $translationThreshold (mut i32))
			 (field $methodCacheSize (mut i32))

			 ;; object memory management
			 (field $nextIdentityHash (mut i32))

			 ;; created with null $firstObject and
			 ;; $lastObject; they're set later
			 (field $firstObject (mut (ref null eq)))
			 (field $lastObject (mut (ref null eq)))

			 (field $classSmallInteger (mut (ref null $Class)))
			 (field $classObject (mut (ref null $Class)))
			 (field $classContext (mut (ref null $Class)))
			 (field $classMetaclass (mut (ref null $Class)))
			 (field $classClassDescription (mut (ref null $Class)))
			 )))

 ;; global state for all virtual machines
 ;;
 ;; NOTE: Reference-type globals are nullable due to current WASM
 ;; limitations, but are enforced to be non-null after object memory
 ;; creation.

 ;; special selectors for quick sends
 (global $workloadSelector (mut (ref null eq)) (ref.null eq))
 
 ;; start of staging bytes
 (global $byteArrayCopyPointer (mut i32) (i32.const 1024))

 ;; linear memory for staging byte arrays visible to JS. See $copyByteArrayToMemory.
 (memory (export "bytes") 1)
 
 ;; translated methods function table (the only table in this module)
 (table $functionTable (export "functionTable") 100 funcref)

 (func $newArray
       (param $vm (ref $VirtualMachine))
       (param $array (ref $objectArray))
       (result (ref $Array))

       ref.null eq            ;; $class to be set later, to class Array
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object       ;; $nextObject to be set later
       local.get $array       ;; $array
       struct.new $Array
       )

 (func $newByteArray
       (param $vm (ref $VirtualMachine))
       (param $array (ref $byteArray))
       (result (ref $ByteArray))

       ref.null eq            ;; $class to be set later, to class ByteArray
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object       ;; $nextObject to be set later
       local.get $array       ;; $array
       struct.new $ByteArray
       )

 (func $newWordArray
       (param $vm (ref $VirtualMachine))
       (param $array (ref $wordArray))
       (result (ref $WordArray))

       ref.null eq            ;; $class to be set later, to class Array
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object       ;; $nextObject to be set later
       local.get $array       ;; $array
       struct.new $WordArray
       )

 (func $newDictionary
       (param $vm (ref $VirtualMachine))
       (result (ref $Dictionary))

       ref.null eq            ;; $class to be set later, to class Dictionary
       local.get $vm
       call $nextIdentityHash ;; $identityHash
       ref.null $Object       ;; $nextObject to be set later
       ref.null $Array            ;; $keys
       ref.null $Array            ;; $values
       i32.const 0            ;; $count
       struct.new $Dictionary
       )

 ;; Link $objects via their $nextObject fields.

 (func $linkObjects
       (param $vm (ref $VirtualMachine))
       (param $objects (ref $objectArray))
       
       (local $previousObject (ref null eq))
       (local $nextObject (ref null eq))
       (local $limit i32)
       (local $index i32)

       local.get $objects
       array.len
       i32.const 1
       i32.sub
       local.set $limit
       
       i32.const 0
       local.set $index

       local.get $vm
       struct.get $VirtualMachine $lastObject
       local.set $previousObject

       loop $link
       local.get $index
       local.get $limit
       i32.eq
       if
       return
       end

       local.get $objects
       local.get $index
       array.get $objectArray
       local.set $nextObject

       local.get $vm
       local.get $previousObject
       ref.cast (ref $Object)
       local.get $nextObject
       struct.set $Object $nextObject
       local.get $nextObject
       struct.set $VirtualMachine $lastObject
       
       local.get $index
       i32.const 1
       i32.add
       local.set $index

       local.get $nextObject
       local.set $previousObject
       i32.const 1
       br_if $link
       end)

 ;; Link the objects of a $Class.
 
 (func $linkClassObjects
       (param $vm (ref $VirtualMachine))
       (param $class (ref $Class))

       local.get $vm

       local.get $class
       struct.get $Class $class
       local.get $class
       struct.get $Class $superclass
       local.get $class
       struct.get $Class $methodDictionary
       local.get $class
       struct.get $Class $instanceVariableNames
       local.get $class
       struct.get $Class $baseID
       local.get $class
       struct.get $Class $subclasses
       local.get $class
       struct.get $Class $name
       local.get $class
       struct.get $Class $classPool
       local.get $class
       struct.get $Class $sharedPools
       array.new_fixed $objectArray 9
       call $linkObjects
       )       

 ;; Link the objects of a $Metaclass.
 
 (func $linkMetaclassObjects
       (param $vm (ref $VirtualMachine))
       (param $metaclass (ref $Metaclass))

       local.get $vm

       local.get $metaclass
       struct.get $Metaclass $class
       local.get $metaclass
       struct.get $Metaclass $superclass
       local.get $metaclass
       struct.get $Metaclass $methodDictionary
       local.get $metaclass
       struct.get $Metaclass $instanceVariableNames
       local.get $metaclass
       struct.get $Metaclass $baseID
       local.get $metaclass
       struct.get $Metaclass $thisClass
       array.new_fixed $objectArray 6
       call $linkObjects

       local.get $vm
       local.get $metaclass
       struct.get $Metaclass $thisClass
       call $linkClassObjects
       )

 (func $newEmptyArray
       (param $vm (ref $VirtualMachine))
       (result (ref $Array))

       local.get $vm

       ref.null eq                   ;; default array element type
       i32.const 0                   ;; empty
       array.new $objectArray

       call $newArray                ;; $instanceVariableNames
       )
 
 (func $newClassOfFormatWithName
       (param $vm (ref $VirtualMachine))
       (param $format i32)
       (param $name (ref $Symbol))
       (result (ref $Class))
       
       ref.null eq                   ;; $class to be set later, to (Object class)
       local.get $vm
       call $nextIdentityHash        ;; $identityHash
       ref.null eq                   ;; $nextObject, to be set later
       ref.null eq                   ;; $superclass is nil
       local.get $vm
       call $newDictionary           ;; $methodDictionary

       local.get $format             ;; $format

       ;; set instance variable names array
       local.get $vm
       call $newEmptyArray

       ref.null $ByteArray           ;; $baseID to be set later (should be a $UUID)

       ;; set subclasses array
       local.get $vm
       call $newEmptyArray

       ;; set name symbol
       local.get $name               ;; $name
       local.get $vm
       call $newDictionary           ;; $classPool

       ;; set shared pools array
       local.get $vm
       call $newEmptyArray

       struct.new $Class
       )

 (func $newMetaclassForClass
       (param $vm (ref $VirtualMachine))
       (param $class (ref $Class))
       (result (ref eq))

       local.get $vm
       struct.get $VirtualMachine $classMetaclass        ;; $class
       
       local.get $vm       
       call $nextIdentityHash           ;; $identityHash

       ref.null eq                 ;; $nextObject to be set later

       local.get $vm
       struct.get $VirtualMachine $classClassDescription ;; $superclass

       local.get $vm
       call $newDictionary              ;; $methodDictionary

       i32.const 152                    ;; $format
       
       ;; set instance variable names array
       local.get $vm
       call $newEmptyArray

       ref.null $ByteArray           ;; $baseID to be set later (should be a $UUID)
       local.get $class              ;; $thisClass
       struct.new $Metaclass
       )

 (func $newSymbolFromBytes
       (param $vm (ref $VirtualMachine))
       (param $bytes (ref $byteArray))
       (result (ref $Symbol))

       ref.null eq                   ;; $class to be set later, to class Symbol

       local.get $vm
       call $nextIdentityHash        ;; $identityHash

       ref.null eq                   ;; $nextObject
       local.get $bytes              ;; $slots
       struct.new $Symbol            ;; $name
)
 
 ;; Create and answer a virtual machine with an object memory, ready
 ;; to create an active context and run it.

 (func (export "initialize")
       (result (ref $VirtualMachine))
       
       (local $methodCacheSize i32)
       (local $firstObject (ref null eq))
       (local $vm (ref $VirtualMachine))
       (local $classObject (ref $Class))
       (local $classBehavior (ref $Class))
       (local $classClassDescription (ref $Class))
       (local $classClass (ref $Class))
       (local $classMetaclass (ref $Class))
       (local $classSymbol (ref $Class))
       (local $classSmallInteger (ref $Class))

       i32.const 256
       local.set $methodCacheSize

       ref.null $Class               ;; $class
       i32.const 1                   ;; $identityHash
       ref.null eq                   ;; $nextObject
       struct.new $Object
       local.set $firstObject
       
       ;; create virtual machine

       ref.null $Context             ;; $activeContext to be set later
       i32.const 1                   ;; translationEnabled

       ;; initialize method cache
       ref.null $objectArray         ;; $methodCache
       i32.const 0                   ;; $functionTableBaseIndex
       i32.const 1000                ;; $translationThreshold
       local.get $methodCacheSize    ;; $methodCacheSize
       i32.const 1001                ;; $nextIdentityHash
       local.get $firstObject        ;; $firstObject
       local.get $firstObject        ;; $lastObject
       ref.null $Class               ;; $classSmallInteger to be set later
       ref.null $Class               ;; $classObject to be set later
       ref.null $Class               ;; $classContext to be set later
       ref.null $Class               ;; $classMetaclass to be set later
       ref.null $Class               ;; $classClassDescription to be set later
       struct.new $VirtualMachine
       local.set $vm

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
       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol

       local.get $vm
       
       ;; Create byte array and ByteArray object
       i32.const 79                  ;; 'O'
       i32.const 98                  ;; 'b'
       i32.const 106                 ;; 'j'
       i32.const 101                 ;; 'e'
       i32.const 99                  ;; 'c'
       i32.const 116                 ;; 't'
       array.new_fixed $byteArray 6
       
       call $newSymbolFromBytes            ;; $name
       call $newClassOfFormatWithName
       local.set $classObject

       local.get $vm
       local.get $classObject
       struct.set $VirtualMachine $classObject

       ;; Create class Behavior.

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       local.get $vm       
              
       ;; Create byte array and ByteArray object  
       i32.const 66                  ;; 'B'
       i32.const 101                 ;; 'e'
       i32.const 104                 ;; 'h'
       i32.const 97                  ;; 'a'
       i32.const 118                 ;; 'v'
       i32.const 105                 ;; 'i'
       i32.const 111                 ;; 'o'
       i32.const 114                 ;; 'r'
       array.new_fixed $byteArray 8
       
       call $newSymbolFromBytes            ;; $name
       call $newClassOfFormatWithName
       local.set $classBehavior

       ;; Create class ClassDescription.

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       local.get $vm       
       
       ;; Create byte array and ByteArray object
       i32.const 67                  ;; 'C'
       i32.const 108                 ;; 'l'
       i32.const 97                  ;; 'a'
       i32.const 115                 ;; 's'
       i32.const 115                 ;; 's'
       i32.const 68                  ;; 'D'
       i32.const 101                 ;; 'e'
       i32.const 115                 ;; 's'
       i32.const 99                  ;; 'c'
       i32.const 114                 ;; 'r'
       i32.const 105                 ;; 'i'
       i32.const 112                 ;; 'p'
       i32.const 116                 ;; 't'
       i32.const 105                 ;; 'i'
       i32.const 111                 ;; 'o'
       i32.const 110                 ;; 'n'
       array.new_fixed $byteArray 16
       
       call $newSymbolFromBytes            ;; $name
       call $newClassOfFormatWithName
       local.set $classClassDescription

       local.get $vm
       local.get $classClassDescription
       struct.set $VirtualMachine $classClassDescription
       
       ;; Create class Metaclass.

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       
       ;; Create byte array and ByteArray object
       local.get $vm
       i32.const 77                  ;; 'M'
       i32.const 101                 ;; 'e'
       i32.const 116                 ;; 't'
       i32.const 97                  ;; 'a'
       i32.const 99                  ;; 'c'
       i32.const 108                 ;; 'l'
       i32.const 97                  ;; 'a'
       i32.const 115                 ;; 's'
       i32.const 115                 ;; 's'
       array.new_fixed $byteArray 9
       
       call $newSymbolFromBytes            ;; $name
       call $newClassOfFormatWithName
       local.set $classMetaclass

       local.get $vm
       local.get $classMetaclass
       struct.set $VirtualMachine $classMetaclass
       
       ;; Create class Class.

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       
       ;; Create byte array and ByteArray object
       local.get $vm
       i32.const 67                  ;; 'C'
       i32.const 108                 ;; 'l'
       i32.const 97                  ;; 'a'
       i32.const 115                 ;; 's'
       i32.const 115                 ;; 's'
       array.new_fixed $byteArray 5
       call $newSymbolFromBytes            ;; $name
       
       call $newClassOfFormatWithName
       local.set $classClass

       ;; Create class Symbol.

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       local.get $vm       
       
       ;; Create byte array and ByteArray object
       i32.const 83                  ;; 'S'
       i32.const 121                 ;; 'y'
       i32.const 109                 ;; 'm'
       i32.const 98                  ;; 'b'
       i32.const 111                 ;; 'o'
       i32.const 108                 ;; 'l'
       array.new_fixed $byteArray 6
       call $newSymbolFromBytes            ;; $name
       
       call $newClassOfFormatWithName
       local.set $classSymbol

       ;; Create class SmallInteger

       local.get $vm       
       i32.const 2                   ;; $format

       ;; set name symbol
       
       ;; Create byte array and ByteArray object
       local.get $vm
       i32.const 83                  ;; 'S'
       i32.const 109                 ;; 'm'
       i32.const 97                  ;; 'a'
       i32.const 108                 ;; 'l'
       i32.const 108                 ;; 'l'
       i32.const 73                  ;; 'I'
       i32.const 110                 ;; 'n'
       i32.const 116                 ;; 't'
       i32.const 101                 ;; 'e'
       i32.const 103                 ;; 'g'
       i32.const 101                 ;; 'e'
       i32.const 104                 ;; 'r'
       array.new_fixed $byteArray 12
       
       call $newSymbolFromBytes            ;; $name
       call $newClassOfFormatWithName
       local.set $classSmallInteger

       local.get $vm
       local.get $classSmallInteger
       struct.set $VirtualMachine $classSmallInteger

       ;; Fix up all the fields that were to be set later.

       ;; Set the class of class Object to (Object class).

       local.get $classObject

       local.get $vm
       local.get $classObject
       call $newMetaclassForClass
       
       struct.set $Class $class

       ;; Set the class of class Object's name symbol.

       local.get $classObject
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class Behavior.

       local.get $classBehavior
       
       ;; create metaclass (Behavior class)

       local.get $vm
       local.get $classBehavior
       call $newMetaclassForClass
       struct.set $Class $class

       ;; Set the superclass of class Behavior.
       
       local.get $classBehavior
       local.get $classObject
       struct.set $Class $superclass

       ;; Set the class of class Behavior's name symbol.

       local.get $classBehavior
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class ClassDescription.

       local.get $classClassDescription

       ;; create metaclass (ClassDescription class)

       local.get $vm
       local.get $classClassDescription
       call $newMetaclassForClass
       
       struct.set $Class $class

       ;; Set the superclass of class ClassDescription.
       
       local.get $classClassDescription
       local.get $classBehavior
       struct.set $Class $superclass

       ;; Set the class of class ClassDescription's name symbol.

       local.get $classClassDescription
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class Class.

       local.get $classClass
       
       ;; create metaclass (Class class)
       
       local.get $vm
       local.get $classClass
       call $newMetaclassForClass
       
       struct.set $Class $class

       ;; Set the superclass of class Class.
       local.get $classClass
       local.get $classClassDescription
       struct.set $Class $superclass

       ;; Set the class of class Class's name symbol.

       local.get $classBehavior
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class Metaclass

       local.get $classMetaclass
       
       ;; create metaclass (Metaclass class)
       
       local.get $vm
       local.get $classMetaclass
       call $newMetaclassForClass

       struct.set $Class $class

       ;; Set the superclass of class Metaclass
       local.get $classMetaclass
       local.get $classObject
       struct.set $Class $superclass

       ;; Set the class of class Metaclass's name symbol.

       local.get $classMetaclass
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class Symbol

       local.get $classSymbol
       
       ;; create metaclass (Symbol class)
       
       local.get $vm
       local.get $classSymbol
       call $newMetaclassForClass

       struct.set $Class $class

       ;; Set the superclass of class Symbol
       local.get $classSymbol
       local.get $classObject
       struct.set $Class $superclass

       ;; Set the class of class Symbol's name symbol.

       local.get $classSymbol
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Set the class of class SmallInteger.

       local.get $classSmallInteger

       ;; create metaclass (SmallInteger class)
       
       local.get $vm
       local.get $classSmallInteger
       call $newMetaclassForClass

       struct.set $Class $class

       ;; Set the superclass of class Symbol.
       local.get $classSmallInteger
       local.get $classObject
       struct.set $Class $superclass

       ;; Set the class of class SmallInteger's name symbol.

       local.get $classSmallInteger
       struct.get $Class $name
       local.get $classSymbol
       struct.set $Symbol $class

       ;; Link objects' $nextObject fields.
       local.get $vm                
       local.get $classObject
       struct.get $Class $class
       ref.cast (ref $Metaclass)  
       call $linkMetaclassObjects

       local.get $vm
       local.get $classBehavior
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects

       local.get $vm
       local.get $classClassDescription
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects

       local.get $vm
       local.get $classClass
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects

       local.get $vm
       local.get $classMetaclass
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects

       local.get $vm
       local.get $classSymbol
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects

       local.get $vm
       local.get $classSmallInteger
       struct.get $Class $class
       ref.cast (ref $Metaclass)
       call $linkMetaclassObjects
       
       local.get $vm
       )

 ;; utilities for method translation in JS
 (func (export "methodBytecodes")
       (param $method eqref)
       (result (ref eq))
       
       local.get $method
       ref.cast (ref $CompiledMethod)
       struct.get $CompiledMethod $slots)

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
 
 (func (export "contextReceiver")
       (param $context eqref)
       (result eqref)
       
       local.get $context
       ref.cast (ref $Context)
       struct.get $Context $receiver)

 (func (export "methodLiterals")
       (param $method eqref)
       (result eqref)
       
       local.get $method
       ref.cast (ref $CompiledMethod)
       struct.get $CompiledMethod $literals)

 (func (export "contextLiteralAt")
       (param $context eqref)
       (param $index i32)
       (result eqref)

       local.get $context
       ref.cast (ref $Context)
       struct.get $Context $method
       struct.get $CompiledMethod $literals
       ref.cast (ref $objectArray)
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
       ref.cast (ref array)
       array.len
       local.set $length
       
       ;; Check bounds.
       local.get $index
       i32.const 0
       i32.lt_s
       if
       i32.const 0
       return
       end

       local.get $index
       local.get $length
       i32.ge_u
       if
       i32.const 0
       return
       end

       i32.const 1
       )

 (func $objectArrayAt
       (param $array (ref $objectArray))
       (param $index i32)
       (result (ref null eq))

       local.get $array
       ref.cast (ref eq)
       local.get $index
       call $arrayOkayAt
       i32.eqz
       if
       i32.const -1
       ref.i31
       return
       end
       
       ;; Safe to access array
       local.get $array
       local.get $index
       array.get $objectArray
       )
 
 (func (export "byteArrayAt")
       (param $array (ref $byteArray))
       (param $index i32)
       (result i32)

       local.get $array
       local.get $index
       call $arrayOkayAt
       i32.eqz
       if
       i32.const -1
       return
       end
       
       ;; Safe to access array
       local.get $array
       local.get $index
       array.get_s $byteArray
       )

 (func (export "byteArrayLength")
       (param $array eqref)
       (result i32)

       local.get $array
       ref.cast (ref $byteArray)
       array.len
       )

 (func (export "copyByteArrayToMemory")
       (param (ref $byteArray))
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
       array.get_u $byteArray
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
       )

 ;; Stack operations
 (func $pushOnStack
       (param $context (ref $Context))
       (param $value eqref)

       (local $stack (ref $Array))
       (local $sp i32)

       local.get $context
       struct.get $Context $stack
       local.set $stack

       local.get $context
       struct.get $Context $sp
       local.set $sp

       local.get $sp
       local.get $stack
       struct.get $Array $array
       array.len
       i32.ge_u
       if
       return
       end

       local.get $stack
       struct.get $Array $array
       local.get $sp
       local.get $value
       array.set $objectArray

       local.get $context
       local.get $sp
       i32.const 1
       i32.add
       struct.set $Context $sp
       return
       )
 
 (func $popFromStack
       (param $context (ref null $Context))
       (result (ref null eq))

       (local $stack (ref $Array))
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
       end 
       
       ;; Decrement stack pointer
       local.get $context
       local.get $sp
       i32.const 1
       i32.sub
       struct.set $Context $sp
       
       ;; Return top value
       local.get $stack
       struct.get $Array $array
       local.get $sp
       i32.const 1
       i32.sub
       array.get $objectArray
       return
       )
 
 (func $topOfStack
       (param $context (ref null $Context))
       (result (ref null eq))

       (local $stack (ref $Array))
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
       end 
       
       ;; Return top value without popping
       local.get $stack
       struct.get $Array $array
       local.get $sp
       i32.const 1
       i32.sub
       array.get $objectArray
       return
       )

 ;; Get class of any object (including SmallIntegers)
 (func $classOfObject
       (param $vm (ref $VirtualMachine))
       (param $obj (ref null eq))
       (result (ref null eq))
       
       local.get $obj
       ref.test (ref i31)
       if (result (ref null eq))
       ;; SmallInteger
       local.get $vm
       struct.get $VirtualMachine $classSmallInteger
       else
       ;; Regular object
       local.get $obj
       ref.cast (ref $Object)
       struct.get $Object $class
       end ;; else
       )

 (func $lookupMethod 
       (param $vm (ref $VirtualMachine))
       (param $receiver (ref null eq))
       (param $selector (ref null eq))
       (result (ref null $CompiledMethod))

       (local $class (ref null eq))
       (local $currentClass (ref null eq))
       (local $methodDictionary (ref null $Dictionary))
       (local $keys (ref null $Array))
       (local $values (ref null $Array))
       (local $count i32)
       (local $i i32)
       (local $key (ref null eq))
       
       ;; Get receiver's class
       local.get $vm
       local.get $receiver
       call $classOfObject
       ref.cast (ref null $Class)
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
       ref.cast (ref $Class)
       struct.get $Class $methodDictionary
       local.tee $methodDictionary
       ref.is_null
       if
       ;; No method dictionary - try superclass
       local.get $currentClass
       ref.cast (ref $Class)
       struct.get $Class $superclass
       local.set $currentClass
       br $hierarchy_loop
       end 
       
       ;; Search in current class's method dictionary
       local.get $methodDictionary
       ref.as_non_null
       struct.get $Dictionary $keys
       local.tee $keys
       ref.is_null
       if
       ;; No keys - try superclass
       local.get $currentClass
       ref.cast (ref $Class)
       struct.get $Class $superclass
       local.set $currentClass
       br $hierarchy_loop
       end 
       
       local.get $methodDictionary
       ref.as_non_null
       struct.get $Dictionary $values
       local.tee $values
       ref.is_null
       if
       ;; No values - try superclass
       local.get $currentClass
       ref.cast (ref $Class)
       struct.get $Class $superclass
       local.set $currentClass
       br $hierarchy_loop
       end 
       
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
       ref.cast (ref $Class)
       struct.get $Class $superclass
       local.set $currentClass
       br $hierarchy_loop
       end 
       
       ;; Get key at index i
       local.get $keys
       struct.get $Array $array
       local.get $i
       array.get $objectArray
       local.set $key
       
       ;; Compare with selector
       local.get $key
       local.get $selector
       ref.eq
       if
       ;; Found! Get the method
       local.get $values
       struct.get $Array $array
       local.get $i
       array.get $objectArray
       ref.cast (ref $CompiledMethod)
       return
       end 
       
       ;; Increment and continue
       local.get $i
       i32.const 1
       i32.add
       local.set $i
       br $search_loop
       end ;; loop $search_loop
       end ;; loop $hierarchy_loop
       
       unreachable
       )

 ;; Polymorphic Inline Cache lookup
 (func $lookupInCache
       (param $vm (ref $VirtualMachine))
       (param $selector (ref null eq))
       (param $receiverClass (ref $Class))
       (result (ref null $CompiledMethod))

       (local $cache (ref null $objectArray))
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
       end 
       
       ;; Simple hash function (identity hash of selector + class)
       local.get $selector
       ref.cast (ref $Object)
       struct.get $Object $identityHash
       
       local.get $receiverClass
       ref.as_non_null
       struct.get $Class $identityHash
       i32.add

       local.get $vm
       struct.get $VirtualMachine $methodCacheSize
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
       array.get $objectArray
       ref.cast (ref null $PICEntry)
       local.tee $entry
       ref.is_null
       if
       ;; Empty slot - cache miss
       ref.null $CompiledMethod
       return
       end 
       
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
       end 
       
       ;; Try next slot
       local.get $index
       i32.const 1
       i32.add
       local.get $vm
       struct.get $VirtualMachine $methodCacheSize
       i32.rem_u
       local.set $index
       
       local.get $probeLimit
       i32.const 1
       i32.sub
       local.set $probeLimit
       
       br $probe_loop
       end ;; loop $probe_loop

       unreachable
       )

 ;; Store method in cache
 (func $storeInCache
       (param $vm (ref $VirtualMachine))
       (param $selector (ref $Symbol))
       (param $receiverClass (ref eq))
       (param $method (ref null $CompiledMethod)) ;; for cache misses

       (local $cache (ref null $objectArray))
       (local $index i32)
       (local $entry (ref $PICEntry))
       
       ;; Get method cache
       local.get $vm
       struct.get $VirtualMachine $methodCache
       local.tee $cache
       ref.is_null
       if
       return
       end 
       
       ;; Simple hash function
       local.get $selector
       ref.cast (ref $Object)
       struct.get $Object $identityHash
       
       local.get $receiverClass
       ref.cast (ref $ClassDescription)
       struct.get $ClassDescription $identityHash
       i32.add
       
       local.get $vm
       struct.get $VirtualMachine $methodCacheSize
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
       array.set $objectArray
       )

 ;; Create context for method call
 (func $newContext
       (param $vm (ref $VirtualMachine))
       (param $receiver eqref)
       (param $method (ref null $CompiledMethod)) ;; to support cache misses
       (param $selector eqref)
       (result (ref $Context))

       (local $stack (ref $objectArray))
       (local $slots (ref $objectArray))
       (local $args (ref $objectArray))
       (local $temps (ref $objectArray))

       ;; Create new stack for the method
       ref.null eq
       i32.const 20
       array.new $objectArray
       local.set $stack

       ;; Create empty arrays for slots, args, temps
       ref.null eq
       i32.const 0
       array.new $objectArray
       local.set $slots
       ref.null eq
       i32.const 0
       array.new $objectArray
       local.set $args
       ref.null eq
       i32.const 0
       array.new $objectArray
       local.set $temps

       ;; Create context for method
       local.get $vm
       struct.get $VirtualMachine $classContext

       local.get $vm
       call $nextIdentityHash

       ref.null $Object ;; nextObject

       local.get $vm
       struct.get $VirtualMachine $activeContext  ;; sender

       i32.const 0          ;; pc
       i32.const 0          ;; sp
       local.get $method    ;; method
       local.get $receiver  ;; receiver
       local.get $vm
       local.get $args      ;; args
       call $newArray
       local.get $vm
       local.get $temps     ;; temps
       call $newArray
       local.get $vm
       local.get $stack     ;; stack
       call $newArray
       struct.new $Context
       )

 ;; SmallInteger operations
 (func $smallIntegerForValue
       (param $value i32)
       (result (ref i31))
       
       local.get $value
       ref.i31
       )
 
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
       )

 ;; Check if method has compiled function
 (func $isTranslated
       (param $method (ref null $CompiledMethod))
       (result i32)
       
       local.get $method
       struct.get $CompiledMethod $functionIndex
       i32.const 0
       i32.gt_u  ;; Check if > 0 (since we start at index 1)
       )

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
       )

 ;; Trigger JIT compilation for hot method
 (func $triggerMethodTranslation
       (param $method (ref null $CompiledMethod))
       (param $identityHash i32)
       
       (local $slots (ref null eq))
       (local $bytecodeLen i32)
       (local $functionIndexIndex i32)
       (local $memoryOffset i32)
       
       ;; Get bytecode array
       local.get $method
       struct.get $CompiledMethod $slots
       local.tee $slots
       ref.is_null
       if
       return  ;; No bytecodes to compile
       end 
       
       ;; Get bytecode length
       local.get $slots
       ref.cast (ref $byteArray)
       array.len
       local.set $bytecodeLen
       
       ;; Call JS method translator with method info
       local.get $method
       local.get $identityHash
       call $translateMethod
       )

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
       end 
       
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
       ) 

 ;; Create minimal bootstrap environment for 3 workload
 (func (export "createMinimalBootstrap")
       (param $vm (ref $VirtualMachine))
       (result i32)
       
       (local $workloadMethod (ref $CompiledMethod))
       (local $mainBytecodes (ref $byteArray))
       (local $mainMethod (ref $CompiledMethod))
       (local $workloadBytecodes (ref $byteArray))
       (local $workloadSelector (ref $Symbol))
       (local $methodDictionary (ref $Dictionary))
       (local $newObject (ref $Object))
       (local $literals (ref $Array))
       (local $keys (ref $Array))
       (local $values (ref $Array))
       (local $emptySymbol (ref $Symbol))
       (local $emptyInstVarNames (ref $Array))
       (local $workloadLiterals (ref $objectArray))
       
       ;; Create bytecodes for main method: [push_receiver, send_workload, return]
       i32.const 0x70      ;; push_receiver 
       i32.const 0xD0      ;; send_workload
       i32.const 0x7C      ;; return_top
       array.new_fixed $byteArray 3
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
       array.new_fixed $byteArray 62
       local.set $workloadBytecodes

       ;; set name symbol
       local.get $vm
       
       ;; Create byte array and ByteArray object
       i32.const 119       ;; 'w'
       i32.const 111       ;; 'o'
       i32.const 114       ;; 'r'
       i32.const 107       ;; 'k'
       i32.const 108       ;; 'l'
       i32.const 111       ;; 'o'
       i32.const 97        ;; 'a'
       i32.const 100       ;; 'd'
       array.new_fixed $byteArray 8  ;; $slots
       call $newSymbolFromBytes
       local.set $workloadSelector
       
       ;; Create literals array with workload selector at index 0
       local.get $vm
       ref.null eq
       i32.const 1
       array.new $objectArray
       call $newArray
       
       local.set $literals
       local.get $literals
       struct.get $Array $array
       i32.const 0  ;; index 0
       local.get $workloadSelector
       array.set $objectArray

       ;; Create main method (sends >>workload message)
       local.get $vm
       struct.get $VirtualMachine $classObject ;; $class

       local.get $vm
       call $nextIdentityHash  ;; identityHash

       ref.null eq ;; $nextObject to be set later
       local.get $mainBytecodes ;; $slots
       local.get $literals      ;; $literals
       i32.const 0         ;; $header
       i32.const 0         ;; $invocationCount
       i32.const 0         ;; $functionIndex

       local.get $vm
       struct.get $VirtualMachine $translationThreshold ;; $translationThreshold

       i32.const 0         ;; $isInstalled
       struct.new $CompiledMethod

       local.tee $newObject
       ref.cast (ref $CompiledMethod)
       local.set $mainMethod

       local.get $vm

       ;; Create initial context for main method
       local.get $vm        ;; $vm
       i32.const 100
       ref.i31              ;; $receiver
       local.get $mainMethod ;; $method
       local.get $workloadSelector
       call $newContext

       struct.set $VirtualMachine $activeContext

       ;; Create workload method (does the intensive computation)
       ;; First create the literals array that the workload method needs
       ref.null eq
       i32.const 4          ;; Need 4 literal slots (0-3, but we only use 1-3)
       array.new $objectArray
       local.set $workloadLiterals
       
       ;; Fill the slots with SmallInteger literals we actually use
       local.get $workloadLiterals
       i32.const 0  ;; literal[0] = 0 (unused but keep for consistency)
       i32.const 0
       call $smallIntegerForValue
       ref.as_non_null
       array.set $objectArray
       
       local.get $workloadLiterals
       i32.const 1  ;; literal[1] = 1
       i32.const 1
       call $smallIntegerForValue
       array.set $objectArray
       
       local.get $workloadLiterals
       i32.const 2  ;; literal[2] = 2
       i32.const 2
       call $smallIntegerForValue
       array.set $objectArray
       
       local.get $workloadLiterals
       i32.const 3  ;; literal[3] = 3
       i32.const 3
       call $smallIntegerForValue
       array.set $objectArray
       
       ;; Now create the workload method with proper slots
       local.get $vm
       struct.get $VirtualMachine $classObject ;; $class

       local.get $vm
       call $nextIdentityHash  ;; $identityHash
       
       ref.null eq ;; $nextObject

       local.get $workloadBytecodes ;; $slots

       local.get $vm
       local.get $workloadLiterals 
       call $newArray               ;; $literals

       i32.const 0         ;; $header (i32)
       i32.const 0         ;; $invocationCount (i32)
       i32.const 0         ;; $functionIndex (i32)

       local.get $vm
       struct.get $VirtualMachine $translationThreshold

       i32.const 0         ;; $isInstalled (i32)
       struct.new $CompiledMethod

       local.set $workloadMethod

       local.get $vm
       call $newDictionary
       local.set $methodDictionary
       
       ;; Install method dictionary in SmallInteger class
       local.get $vm
       struct.get $VirtualMachine $classSmallInteger
       local.get $methodDictionary
       struct.set $Class $methodDictionary
       
       ;; Install workload selector in dictionary keys array
       local.get $methodDictionary
       struct.get $Dictionary $keys
       struct.get $Array $array
       i32.const 0  ;; index 0
       local.get $workloadSelector
       array.set $objectArray
       
       ;; Install workload method in dictionary values array
       local.get $methodDictionary
       struct.get $Dictionary $values
       struct.get $Array $array
       i32.const 0  ;; index 0
       local.get $workloadMethod
       array.set $objectArray
       
       ;; Set method dictionary count
       local.get $methodDictionary
       i32.const 1
       struct.set $Dictionary $count
       
       ;; Mark method as installed
       local.get $workloadMethod
       i32.const 1
       struct.set $CompiledMethod $isInstalled
       
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
       (local $selector (ref $Symbol))
       (local $method (ref null $CompiledMethod))
       (local $receiverClass (ref $Class))
       (local $selectorIndex i32)
       (local $literals (ref $objectArray))
       
       ;; Execute bytecode based on opcode

       local.get $context
       struct.get $Context $receiver
       local.set $receiver

       ;; Get method's literal array
       local.get $context
       struct.get $Context $method
       struct.get $CompiledMethod $literals
       struct.get $Array $array
       local.set $literals

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
       
       ;; Check bounds
       local.get $selectorIndex

       local.get $literals
       array.len

       i32.ge_u
       if

       ;; Index out of bounds - push 0 as fallback
       local.get $context
       i32.const 0
       call $smallIntegerForValue
       call $pushOnStack
       else
       ;; Get literal at index and push
       local.get $context
       local.get $literals
       local.get $selectorIndex
       array.get $objectArray
       call $pushOnStack
       end
       
       i32.const 0  ;; Continue execution
       return
       end 
       
       local.get $bytecode
       i32.const 0x70  ;; Push receiver
       i32.eq
       if
       ;; Push receiver onto stack
       local.get $context
       local.get $receiver
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
       end 
       
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
       i32.const 0xD0  ;; Send message
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
       
       ;; Extract selector index from low 4 bits of bytecode
       local.get $bytecode
       i32.const 0x0F  ;; Mask for low 4 bits
       i32.and
       local.set $selectorIndex  ;; Use meaningful name instead of reusing $int1
       
       ;; Get selector from method's literal array at index
       ;; Check bounds before accessing
       local.get $selectorIndex
       local.get $literals
       array.len
       i32.ge_u
       if
       ;; Index out of bounds - push receiver back and continue
       local.get $context
       local.get $receiver
       call $pushOnStack
       i32.const 0
       return
       end 
       
       ;; Get selector at index
       local.get $literals
       local.get $selectorIndex
       array.get $objectArray
       ref.cast (ref $Symbol)
       local.set $selector
       
       ;; No need to increment PC since we're not reading next byte
       
       ;; Get receiver's class
       local.get $vm
       local.get $receiver
       call $classOfObject
       ref.cast (ref $Class)
       local.set $receiverClass
       
       ;; Try polymorphic inline cache first
       local.get $vm
       local.get $selector
       local.get $receiverClass
       call $lookupInCache
       local.tee $method
       ref.is_null
       if
       ;; Cache miss - do full method lookup
       local.get $vm
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
       local.get $vm
       local.get $selector
       local.get $receiverClass
       local.get $method
       call $storeInCache
       end 
       
       ;; Create new context for method
       local.get $vm
       local.get $receiver
       local.get $method
       local.get $selector
       call $newContext
       local.set $newContext
       
       ;; Switch to new context
       local.get $vm
       local.get $newContext
       struct.set $VirtualMachine $activeContext
       
       i32.const 0 ;; Continue execution in new context
       return
       end 
       
       ;; Unknown bytecode - continue execution
       i32.const 0
       )
 
 ;; Main interpreter loop
 (func (export "interpret")
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
       (local $funcIndex i32)

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
       end 

       local.get $context
       ref.as_non_null
       struct.get $Context $receiver
       local.set $receiver
       
       ;; Cast to non-null and get method
       local.get $context
       ref.as_non_null
       struct.get $Context $method
       local.tee $method
       
       ;; Increment invocation count
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
       struct.get $VirtualMachine $translationEnabled
       i32.and
       if
       ;; Check if method is installed in a method dictionary
       local.get $method
       struct.get $CompiledMethod $isInstalled
       i32.const 1
       i32.eq
       if
       ;; Check if method already has translated function
       local.get $method
       call $isTranslated
       i32.eqz ;; Only translate if not already translated.
       if
       ;; Trigger method translation.
       local.get $method
       local.get $receiver
       ref.cast (ref $Object)
       struct.get $Object $identityHash
       call $triggerMethodTranslation
       end ;; trigger method translation
       end ;; check if method already has translated function
       end ;; Check if method is installed in a method dictionary
       
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
       local.get $vm
       local.get $context
       ref.as_non_null
       call $handleMethodReturn
       local.set $resultValue
       
       br $execution_loop
       end

       ;; Method isn't translated; run the bytecode interpreter loop,
       local.get $method
       struct.get $CompiledMethod $slots
       ref.cast (ref $ByteArray)
       struct.get $ByteArray $array
       local.set $slots
       
       ;; Bytecode interpreter loop
       loop $interpreter_loop
       ;; Get current PC
       local.get $vm
       struct.get $VirtualMachine $activeContext
       local.tee $context
       ref.is_null
       br_if $execution_loop
       
       local.get $context
       ref.as_non_null
       struct.get $Context $pc
       local.set $pc

       local.get $context
       ref.as_non_null
       struct.get $Context $method
       local.tee $method
       struct.get $CompiledMethod $slots
       ref.cast (ref $ByteArray)
       struct.get $ByteArray $array
       local.tee $slots
       array.len
       
       ;; Check if we've reached end of bytecodes
       local.get $pc
       i32.le_u
       if
       ;; End of method - handle return
       local.get $vm
       local.get $context
       ref.as_non_null
       call $handleMethodReturn
       local.set $resultValue
       br $interpreter_loop
       end 
       
       ;; Fetch next bytecode
       local.get $slots
       local.get $pc
       array.get_u $byteArray
       local.set $bytecode
       
       ;; Interpret single bytecode
       local.get $vm
       local.get $context
       ref.as_non_null
       local.get $bytecode
       call $interpretBytecode
       
       if ;; Check if method should return

       ;; Method returned - handle return and switch contexts
       local.get $vm
       local.get $context
       ref.as_non_null
       call $handleMethodReturn
       local.set $resultValue
       br $interpreter_loop
       end 
       
       local.get $vm
       struct.get $VirtualMachine $activeContext
       local.get $context
       ref.eq

       if ;; Check if context switched (for message sends)

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

       if ;; Check to see if the context has changed.

       ;; The context has changed; check to see if we should translate
       ;; the new context's method, by restarting the execution loop.

       br $execution_loop
       end

       ;; Otherwise, continue interpreting (fall through)
       end ;; end of the "has the context switched?" block
       
       br $interpreter_loop ;; default - restart interpreter loop
       end ;; loop $interpreter_loop
       end ;; loop $execution_loop
       end ;; block $finished
       
       ;; Extract integer result for reporting
       local.get $resultValue
       call $valueOfSmallInteger
       
       ;; Report result to JS
       call $reportResult
       
       i32.const 1 ;; success
       return
       )
 )
