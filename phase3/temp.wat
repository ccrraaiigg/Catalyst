(module
 (rec
  (type $objectArray (array (mut eqref)))
  (type $byteArray (array (mut i8)))
  (type $wordArray (array (mut i32)))
  (type $Object (sub (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)))))
  (type $Array (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $array (ref $objectArray)))))
  (type $ByteArray (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $array (ref $byteArray)))))
  (type $WordArray (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $array (ref $wordArray)))))
  (type $VariableObject (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $slots (mut (ref eq))))))
  (type $Symbol (sub $VariableObject (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $slots (mut (ref eq))))))
  (type $Dictionary (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $keys (ref null $Array)) (field $values (ref null $Array)) (field $count (mut i32)))))
  (type $Behavior (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $superclass (mut eqref)) (field $methodDictionary (mut (ref $Dictionary))) (field $format (mut i32)))))
  (type $ClassDescription (sub $Behavior (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $superclass (mut eqref)) (field $methodDictionary (mut (ref $Dictionary))) (field $format (mut i32)) (field $instanceVariableNames (mut (ref $Array))) (field $baseID (mut (ref null $ByteArray))))))
  (type $Class (sub $ClassDescription (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $superclass (mut eqref)) (field $methodDictionary (mut (ref $Dictionary))) (field $format (mut i32)) (field $instanceVariableNames (mut (ref $Array))) (field $baseID (mut (ref null $ByteArray))) (field $subclasses (mut (ref $Array))) (field $name (mut (ref $Symbol))) (field $classPool (mut (ref $Dictionary))) (field $sharedPools (mut (ref $Array))))))
  (type $Metaclass (sub $ClassDescription (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $superclass (mut eqref)) (field $methodDictionary (mut (ref $Dictionary))) (field $format (mut i32)) (field $instanceVariableNames (mut (ref $Array))) (field $baseID (mut (ref null $ByteArray))) (field $thisClass (mut (ref $Class))))))
  (type $CompiledMethod (sub $VariableObject (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $slots (mut (ref eq))) (field $literals (ref $Array)) (field $header i32) (field $invocationCount (mut i32)) (field $functionIndex (mut i32)) (field $translationThreshold i32) (field $isInstalled (mut i32)))))
  (type $Context (sub $Object (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $nextObject (mut eqref)) (field $sender (mut (ref null $Context))) (field $pc (mut i32)) (field $sp (mut i32)) (field $method (mut (ref null $CompiledMethod))) (field $receiver (mut eqref)) (field $args (mut (ref $Array))) (field $temps (mut (ref $Array))) (field $stack (mut (ref $Array))))))
  (type $PICEntry (struct (field $selector (mut eqref)) (field $receiverClass (mut (ref eq))) (field $method (mut (ref null $CompiledMethod))) (field $hitCount (mut i32))))
  (type $VirtualMachine (struct (field $activeContext (mut (ref null $Context))) (field $translationEnabled (mut i32)) (field $methodCache (mut (ref null $objectArray))) (field $functionTableBaseIndex (mut i32)) (field $translationThreshold (mut i32)) (field $methodCacheSize (mut i32)) (field $nextIdentityHash (mut i32)) (field $firstObject (mut eqref)) (field $lastObject (mut eqref)) (field $classSmallInteger (mut (ref null $Class))) (field $classObject (mut (ref null $Class))) (field $classContext (mut (ref null $Class))) (field $classMetaclass (mut (ref null $Class))) (field $classClassDescription (mut (ref null $Class)))))
 )
 (type $18 (func (param eqref) (result eqref)))
 (type $19 (func (param eqref) (result i32)))
 (type $20 (func (param (ref $VirtualMachine)) (result i32)))
 (type $21 (func (param eqref i32)))
 (type $22 (func (param i32) (result (ref i31))))
 (type $23 (func (param (ref null $Context)) (result eqref)))
 (type $24 (func (param i32)))
 (type $25 (func (param i32 i32 i32)))
 (type $26 (func (param (ref $VirtualMachine) (ref $objectArray)) (result (ref $Array))))
 (type $27 (func (param (ref $VirtualMachine) (ref $byteArray)) (result (ref $ByteArray))))
 (type $28 (func (param (ref $VirtualMachine) (ref $wordArray)) (result (ref $WordArray))))
 (type $29 (func (param (ref $VirtualMachine)) (result (ref $Dictionary))))
 (type $30 (func (param (ref $VirtualMachine) (ref $objectArray))))
 (type $31 (func (param (ref $VirtualMachine) (ref $Class))))
 (type $32 (func (param (ref $VirtualMachine) (ref $Metaclass))))
 (type $33 (func (param (ref $VirtualMachine)) (result (ref $Array))))
 (type $34 (func (param (ref $VirtualMachine) i32 (ref $Symbol)) (result (ref $Class))))
 (type $35 (func (param (ref $VirtualMachine) (ref $Class)) (result (ref eq))))
 (type $36 (func (param (ref $VirtualMachine) (ref $byteArray)) (result (ref $Symbol))))
 (type $37 (func (result (ref $VirtualMachine))))
 (type $38 (func (param eqref) (result (ref eq))))
 (type $39 (func (param eqref eqref)))
 (type $40 (func (param (ref i31)) (result i32)))
 (type $41 (func (param eqref i32) (result eqref)))
 (type $42 (func (param eqref i32) (result i32)))
 (type $43 (func (param (ref $objectArray) i32) (result eqref)))
 (type $44 (func (param (ref $byteArray) i32) (result i32)))
 (type $45 (func (param (ref $byteArray)) (result i32)))
 (type $46 (func (param (ref $Context) eqref)))
 (type $47 (func (param (ref $VirtualMachine) eqref) (result eqref)))
 (type $48 (func (param (ref $VirtualMachine) eqref eqref) (result (ref null $CompiledMethod))))
 (type $49 (func (param (ref $VirtualMachine) eqref (ref $Class)) (result (ref null $CompiledMethod))))
 (type $50 (func (param (ref $VirtualMachine) (ref $Symbol) (ref eq) (ref null $CompiledMethod))))
 (type $51 (func (param (ref $VirtualMachine) eqref (ref null $CompiledMethod) eqref) (result (ref $Context))))
 (type $52 (func (param (ref null $CompiledMethod)) (result i32)))
 (type $53 (func (param (ref null $Context) i32) (result i32)))
 (type $54 (func (param (ref null $CompiledMethod) i32)))
 (type $55 (func (param (ref $VirtualMachine) (ref null $Context)) (result eqref)))
 (type $56 (func (param (ref $VirtualMachine) (ref $Context) i32) (result i32)))
 (import "env" "reportResult" (func $reportResult (type $24) (param i32)))
 (import "env" "translateMethod" (func $translateMethod (type $21) (param eqref i32)))
 (import "env" "debugLog" (func $debugLog (type $25) (param i32 i32 i32)))
 (global $workloadSelector (mut eqref) (ref.null none))
 (global $byteArrayCopyPointer (mut i32) (i32.const 1024))
 (memory $0 1)
 (table $functionTable 100 funcref)
 (export "bytes" (memory $0))
 (export "functionTable" (table $functionTable))
 (export "initialize" (func $0))
 (export "methodBytecodes" (func $1))
 (export "setMethodFunctionIndex" (func $2))
 (export "onContextPush" (func $3))
 (export "popFromContext" (func $4))
 (export "valueOfSmallInteger" (func $5))
 (export "smallIntegerForValue" (func $6))
 (export "contextReceiver" (func $7))
 (export "methodLiterals" (func $8))
 (export "contextLiteralAt" (func $9))
 (export "contextMethod" (func $10))
 (export "byteArrayAt" (func $11))
 (export "byteArrayLength" (func $12))
 (export "copyByteArrayToMemory" (func $13))
 (export "createMinimalBootstrap" (func $14))
 (export "interpret" (func $15))
 (func $newArray (type $26) (param $vm (ref $VirtualMachine)) (param $array (ref $objectArray)) (result (ref $Array))
  (struct.new $Array
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (local.get $array)
  )
 )
 (func $newByteArray (type $27) (param $vm (ref $VirtualMachine)) (param $array (ref $byteArray)) (result (ref $ByteArray))
  (struct.new $ByteArray
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (local.get $array)
  )
 )
 (func $newWordArray (type $28) (param $vm (ref $VirtualMachine)) (param $array (ref $wordArray)) (result (ref $WordArray))
  (struct.new $WordArray
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (local.get $array)
  )
 )
 (func $newDictionary (type $29) (param $vm (ref $VirtualMachine)) (result (ref $Dictionary))
  (struct.new $Dictionary
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (ref.null none)
   (ref.null none)
   (i32.const 0)
  )
 )
 (func $linkObjects (type $30) (param $vm (ref $VirtualMachine)) (param $objects (ref $objectArray))
  (local $previousObject eqref)
  (local $nextObject eqref)
  (local $limit i32)
  (local $index i32)
  (local $scratch (ref $VirtualMachine))
  (local.set $limit
   (i32.sub
    (array.len
     (local.get $objects)
    )
    (i32.const 1)
   )
  )
  (local.set $index
   (i32.const 0)
  )
  (local.set $previousObject
   (struct.get $VirtualMachine $lastObject
    (local.get $vm)
   )
  )
  (loop $link
   (if
    (i32.eq
     (local.get $index)
     (local.get $limit)
    )
    (then
     (return)
    )
   )
   (local.set $nextObject
    (array.get $objectArray
     (local.get $objects)
     (local.get $index)
    )
   )
   (struct.set $VirtualMachine $lastObject
    (block (result (ref $VirtualMachine))
     (local.set $scratch
      (local.get $vm)
     )
     (struct.set $Object $nextObject
      (ref.cast (ref $Object)
       (local.get $previousObject)
      )
      (local.get $nextObject)
     )
     (local.get $scratch)
    )
    (local.get $nextObject)
   )
   (local.set $index
    (i32.add
     (local.get $index)
     (i32.const 1)
    )
   )
   (local.set $previousObject
    (local.get $nextObject)
   )
   (br_if $link
    (i32.const 1)
   )
  )
 )
 (func $linkClassObjects (type $31) (param $vm (ref $VirtualMachine)) (param $class (ref $Class))
  (call $linkObjects
   (local.get $vm)
   (array.new_fixed $objectArray 9
    (struct.get $Class $class
     (local.get $class)
    )
    (struct.get $Class $superclass
     (local.get $class)
    )
    (struct.get $Class $methodDictionary
     (local.get $class)
    )
    (struct.get $Class $instanceVariableNames
     (local.get $class)
    )
    (struct.get $Class $baseID
     (local.get $class)
    )
    (struct.get $Class $subclasses
     (local.get $class)
    )
    (struct.get $Class $name
     (local.get $class)
    )
    (struct.get $Class $classPool
     (local.get $class)
    )
    (struct.get $Class $sharedPools
     (local.get $class)
    )
   )
  )
 )
 (func $linkMetaclassObjects (type $32) (param $vm (ref $VirtualMachine)) (param $metaclass (ref $Metaclass))
  (call $linkObjects
   (local.get $vm)
   (array.new_fixed $objectArray 6
    (struct.get $Metaclass $class
     (local.get $metaclass)
    )
    (struct.get $Metaclass $superclass
     (local.get $metaclass)
    )
    (struct.get $Metaclass $methodDictionary
     (local.get $metaclass)
    )
    (struct.get $Metaclass $instanceVariableNames
     (local.get $metaclass)
    )
    (struct.get $Metaclass $baseID
     (local.get $metaclass)
    )
    (struct.get $Metaclass $thisClass
     (local.get $metaclass)
    )
   )
  )
  (call $linkClassObjects
   (local.get $vm)
   (struct.get $Metaclass $thisClass
    (local.get $metaclass)
   )
  )
 )
 (func $newEmptyArray (type $33) (param $vm (ref $VirtualMachine)) (result (ref $Array))
  (call $newArray
   (local.get $vm)
   (array.new $objectArray
    (ref.null none)
    (i32.const 0)
   )
  )
 )
 (func $newClassOfFormatWithName (type $34) (param $vm (ref $VirtualMachine)) (param $format i32) (param $name (ref $Symbol)) (result (ref $Class))
  (struct.new $Class
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (ref.null none)
   (call $newDictionary
    (local.get $vm)
   )
   (local.get $format)
   (call $newEmptyArray
    (local.get $vm)
   )
   (ref.null none)
   (call $newEmptyArray
    (local.get $vm)
   )
   (local.get $name)
   (call $newDictionary
    (local.get $vm)
   )
   (call $newEmptyArray
    (local.get $vm)
   )
  )
 )
 (func $newMetaclassForClass (type $35) (param $vm (ref $VirtualMachine)) (param $class (ref $Class)) (result (ref eq))
  (struct.new $Metaclass
   (struct.get $VirtualMachine $classMetaclass
    (local.get $vm)
   )
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (struct.get $VirtualMachine $classClassDescription
    (local.get $vm)
   )
   (call $newDictionary
    (local.get $vm)
   )
   (i32.const 152)
   (call $newEmptyArray
    (local.get $vm)
   )
   (ref.null none)
   (local.get $class)
  )
 )
 (func $newSymbolFromBytes (type $36) (param $vm (ref $VirtualMachine)) (param $bytes (ref $byteArray)) (result (ref $Symbol))
  (struct.new $Symbol
   (ref.null none)
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (local.get $bytes)
  )
 )
 (func $0 (type $37) (result (ref $VirtualMachine))
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
   (i32.const 256)
  )
  (local.set $firstObject
   (struct.new $Object
    (ref.null none)
    (i32.const 1)
    (ref.null none)
   )
  )
  (local.set $vm
   (struct.new $VirtualMachine
    (ref.null none)
    (i32.const 1)
    (ref.null none)
    (i32.const 0)
    (i32.const 1000)
    (local.get $methodCacheSize)
    (i32.const 1001)
    (local.get $firstObject)
    (local.get $firstObject)
    (ref.null none)
    (ref.null none)
    (ref.null none)
    (ref.null none)
    (ref.null none)
   )
  )
  (local.set $classObject
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 6
      (i32.const 79)
      (i32.const 98)
      (i32.const 106)
      (i32.const 101)
      (i32.const 99)
      (i32.const 116)
     )
    )
   )
  )
  (struct.set $VirtualMachine $classObject
   (local.get $vm)
   (local.get $classObject)
  )
  (local.set $classBehavior
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 8
      (i32.const 66)
      (i32.const 101)
      (i32.const 104)
      (i32.const 97)
      (i32.const 118)
      (i32.const 105)
      (i32.const 111)
      (i32.const 114)
     )
    )
   )
  )
  (local.set $classClassDescription
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 16
      (i32.const 67)
      (i32.const 108)
      (i32.const 97)
      (i32.const 115)
      (i32.const 115)
      (i32.const 68)
      (i32.const 101)
      (i32.const 115)
      (i32.const 99)
      (i32.const 114)
      (i32.const 105)
      (i32.const 112)
      (i32.const 116)
      (i32.const 105)
      (i32.const 111)
      (i32.const 110)
     )
    )
   )
  )
  (struct.set $VirtualMachine $classClassDescription
   (local.get $vm)
   (local.get $classClassDescription)
  )
  (local.set $classMetaclass
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 9
      (i32.const 77)
      (i32.const 101)
      (i32.const 116)
      (i32.const 97)
      (i32.const 99)
      (i32.const 108)
      (i32.const 97)
      (i32.const 115)
      (i32.const 115)
     )
    )
   )
  )
  (struct.set $VirtualMachine $classMetaclass
   (local.get $vm)
   (local.get $classMetaclass)
  )
  (local.set $classClass
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 5
      (i32.const 67)
      (i32.const 108)
      (i32.const 97)
      (i32.const 115)
      (i32.const 115)
     )
    )
   )
  )
  (local.set $classSymbol
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 6
      (i32.const 83)
      (i32.const 121)
      (i32.const 109)
      (i32.const 98)
      (i32.const 111)
      (i32.const 108)
     )
    )
   )
  )
  (local.set $classSmallInteger
   (call $newClassOfFormatWithName
    (local.get $vm)
    (i32.const 2)
    (call $newSymbolFromBytes
     (local.get $vm)
     (array.new_fixed $byteArray 12
      (i32.const 83)
      (i32.const 109)
      (i32.const 97)
      (i32.const 108)
      (i32.const 108)
      (i32.const 73)
      (i32.const 110)
      (i32.const 116)
      (i32.const 101)
      (i32.const 103)
      (i32.const 101)
      (i32.const 104)
     )
    )
   )
  )
  (struct.set $VirtualMachine $classSmallInteger
   (local.get $vm)
   (local.get $classSmallInteger)
  )
  (struct.set $Class $class
   (local.get $classObject)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classObject)
   )
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classObject)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classBehavior)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classBehavior)
   )
  )
  (struct.set $Class $superclass
   (local.get $classBehavior)
   (local.get $classObject)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classBehavior)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classClassDescription)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classClassDescription)
   )
  )
  (struct.set $Class $superclass
   (local.get $classClassDescription)
   (local.get $classBehavior)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classClassDescription)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classClass)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classClass)
   )
  )
  (struct.set $Class $superclass
   (local.get $classClass)
   (local.get $classClassDescription)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classBehavior)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classMetaclass)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classMetaclass)
   )
  )
  (struct.set $Class $superclass
   (local.get $classMetaclass)
   (local.get $classObject)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classMetaclass)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classSymbol)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classSymbol)
   )
  )
  (struct.set $Class $superclass
   (local.get $classSymbol)
   (local.get $classObject)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classSymbol)
   )
   (local.get $classSymbol)
  )
  (struct.set $Class $class
   (local.get $classSmallInteger)
   (call $newMetaclassForClass
    (local.get $vm)
    (local.get $classSmallInteger)
   )
  )
  (struct.set $Class $superclass
   (local.get $classSmallInteger)
   (local.get $classObject)
  )
  (struct.set $Symbol $class
   (struct.get $Class $name
    (local.get $classSmallInteger)
   )
   (local.get $classSymbol)
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classObject)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classBehavior)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classClassDescription)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classClass)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classMetaclass)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classSymbol)
    )
   )
  )
  (call $linkMetaclassObjects
   (local.get $vm)
   (ref.cast (ref $Metaclass)
    (struct.get $Class $class
     (local.get $classSmallInteger)
    )
   )
  )
  (local.get $vm)
 )
 (func $1 (type $38) (param $method eqref) (result (ref eq))
  (struct.get $CompiledMethod $slots
   (ref.cast (ref $CompiledMethod)
    (local.get $method)
   )
  )
 )
 (func $2 (type $21) (param $method eqref) (param $index i32)
  (struct.set $CompiledMethod $functionIndex
   (ref.cast (ref $CompiledMethod)
    (local.get $method)
   )
   (local.get $index)
  )
 )
 (func $3 (type $39) (param $context eqref) (param $pushedObject eqref)
  (call $pushOnStack
   (ref.cast (ref $Context)
    (local.get $context)
   )
   (local.get $pushedObject)
  )
 )
 (func $4 (type $18) (param $context eqref) (result eqref)
  (call $popFromStack
   (ref.cast (ref $Context)
    (local.get $context)
   )
  )
 )
 (func $5 (type $40) (param $smallInteger (ref i31)) (result i32)
  (call $valueOfSmallInteger
   (local.get $smallInteger)
  )
 )
 (func $6 (type $22) (param $value i32) (result (ref i31))
  (call $smallIntegerForValue
   (local.get $value)
  )
 )
 (func $7 (type $18) (param $context eqref) (result eqref)
  (struct.get $Context $receiver
   (ref.cast (ref $Context)
    (local.get $context)
   )
  )
 )
 (func $8 (type $18) (param $method eqref) (result eqref)
  (struct.get $CompiledMethod $literals
   (ref.cast (ref $CompiledMethod)
    (local.get $method)
   )
  )
 )
 (func $9 (type $41) (param $context eqref) (param $index i32) (result eqref)
  (call $objectArrayAt
   (ref.cast (ref none)
    (struct.get $CompiledMethod $literals
     (struct.get $Context $method
      (ref.cast (ref $Context)
       (local.get $context)
      )
     )
    )
   )
   (local.get $index)
  )
 )
 (func $10 (type $18) (param $context eqref) (result eqref)
  (struct.get $Context $method
   (ref.cast (ref $Context)
    (local.get $context)
   )
  )
 )
 (func $arrayOkayAt (type $42) (param $array eqref) (param $index i32) (result i32)
  (local $length i32)
  (local.set $length
   (array.len
    (ref.cast (ref array)
     (local.get $array)
    )
   )
  )
  (if
   (i32.lt_s
    (local.get $index)
    (i32.const 0)
   )
   (then
    (return
     (i32.const 0)
    )
   )
  )
  (if
   (i32.ge_u
    (local.get $index)
    (local.get $length)
   )
   (then
    (return
     (i32.const 0)
    )
   )
  )
  (i32.const 1)
 )
 (func $objectArrayAt (type $43) (param $array (ref $objectArray)) (param $index i32) (result eqref)
  (if
   (i32.eqz
    (call $arrayOkayAt
     (ref.cast (ref $objectArray)
      (local.get $array)
     )
     (local.get $index)
    )
   )
   (then
    (return
     (ref.i31
      (i32.const -1)
     )
    )
   )
  )
  (array.get $objectArray
   (local.get $array)
   (local.get $index)
  )
 )
 (func $11 (type $44) (param $array (ref $byteArray)) (param $index i32) (result i32)
  (if
   (i32.eqz
    (call $arrayOkayAt
     (local.get $array)
     (local.get $index)
    )
   )
   (then
    (return
     (i32.const -1)
    )
   )
  )
  (array.get_s $byteArray
   (local.get $array)
   (local.get $index)
  )
 )
 (func $12 (type $19) (param $array eqref) (result i32)
  (array.len
   (ref.cast (ref $byteArray)
    (local.get $array)
   )
  )
 )
 (func $13 (type $45) (param $0 (ref $byteArray)) (result i32)
  (local $len i32)
  (local $i i32)
  (if
   (ref.is_null
    (local.get $0)
   )
   (then
    (return
     (i32.const 0)
    )
   )
  )
  (local.set $len
   (array.len
    (ref.as_non_null
     (local.get $0)
    )
   )
  )
  (local.set $i
   (i32.const 0)
  )
  (loop $copy
   (if
    (i32.ge_u
     (local.get $i)
     (local.get $len)
    )
    (then
     (return
      (global.get $byteArrayCopyPointer)
     )
    )
   )
   (i32.store8
    (i32.add
     (global.get $byteArrayCopyPointer)
     (local.get $i)
    )
    (array.get_u $byteArray
     (ref.as_non_null
      (local.get $0)
     )
     (local.get $i)
    )
   )
   (local.set $i
    (i32.add
     (local.get $i)
     (i32.const 1)
    )
   )
   (br $copy)
  )
  (i32.const 0)
 )
 (func $nextIdentityHash (type $20) (param $vm (ref $VirtualMachine)) (result i32)
  (struct.set $VirtualMachine $nextIdentityHash
   (local.get $vm)
   (i32.add
    (struct.get $VirtualMachine $nextIdentityHash
     (local.get $vm)
    )
    (i32.const 1)
   )
  )
  (struct.get $VirtualMachine $nextIdentityHash
   (local.get $vm)
  )
 )
 (func $pushOnStack (type $46) (param $context (ref $Context)) (param $value eqref)
  (local $stack (ref $Array))
  (local $sp i32)
  (local.set $stack
   (struct.get $Context $stack
    (local.get $context)
   )
  )
  (local.set $sp
   (struct.get $Context $sp
    (local.get $context)
   )
  )
  (if
   (i32.ge_u
    (local.get $sp)
    (array.len
     (struct.get $Array $array
      (local.get $stack)
     )
    )
   )
   (then
    (return)
   )
  )
  (array.set $objectArray
   (struct.get $Array $array
    (local.get $stack)
   )
   (local.get $sp)
   (local.get $value)
  )
  (struct.set $Context $sp
   (local.get $context)
   (i32.add
    (local.get $sp)
    (i32.const 1)
   )
  )
  (return)
 )
 (func $popFromStack (type $23) (param $context (ref null $Context)) (result eqref)
  (local $stack (ref $Array))
  (local $sp i32)
  (local.set $stack
   (struct.get $Context $stack
    (local.get $context)
   )
  )
  (local.set $sp
   (struct.get $Context $sp
    (local.get $context)
   )
  )
  (if
   (i32.le_u
    (local.get $sp)
    (i32.const 0)
   )
   (then
    (return
     (ref.null none)
    )
   )
  )
  (struct.set $Context $sp
   (local.get $context)
   (i32.sub
    (local.get $sp)
    (i32.const 1)
   )
  )
  (return
   (array.get $objectArray
    (struct.get $Array $array
     (local.get $stack)
    )
    (i32.sub
     (local.get $sp)
     (i32.const 1)
    )
   )
  )
 )
 (func $topOfStack (type $23) (param $context (ref null $Context)) (result eqref)
  (local $stack (ref $Array))
  (local $sp i32)
  (local.set $stack
   (struct.get $Context $stack
    (local.get $context)
   )
  )
  (local.set $sp
   (struct.get $Context $sp
    (local.get $context)
   )
  )
  (if
   (i32.le_u
    (local.get $sp)
    (i32.const 0)
   )
   (then
    (return
     (ref.null none)
    )
   )
  )
  (return
   (array.get $objectArray
    (struct.get $Array $array
     (local.get $stack)
    )
    (i32.sub
     (local.get $sp)
     (i32.const 1)
    )
   )
  )
 )
 (func $classOfObject (type $47) (param $vm (ref $VirtualMachine)) (param $obj eqref) (result eqref)
  (if (result eqref)
   (ref.test (ref i31)
    (local.get $obj)
   )
   (then
    (struct.get $VirtualMachine $classSmallInteger
     (local.get $vm)
    )
   )
   (else
    (struct.get $Object $class
     (ref.cast (ref $Object)
      (local.get $obj)
     )
    )
   )
  )
 )
 (func $lookupMethod (type $48) (param $vm (ref $VirtualMachine)) (param $receiver eqref) (param $selector eqref) (result (ref null $CompiledMethod))
  (local $class eqref)
  (local $currentClass eqref)
  (local $methodDictionary (ref null $Dictionary))
  (local $keys (ref null $Array))
  (local $values (ref null $Array))
  (local $count i32)
  (local $i i32)
  (local $key eqref)
  (local.set $currentClass
   (ref.cast (ref null $Class)
    (call $classOfObject
     (local.get $vm)
     (local.get $receiver)
    )
   )
  )
  (loop $hierarchy_loop
   (if
    (ref.is_null
     (local.get $currentClass)
    )
    (then
     (return
      (ref.null none)
     )
    )
   )
   (if
    (ref.is_null
     (local.tee $methodDictionary
      (struct.get $Class $methodDictionary
       (ref.cast (ref $Class)
        (local.get $currentClass)
       )
      )
     )
    )
    (then
     (local.set $currentClass
      (struct.get $Class $superclass
       (ref.cast (ref $Class)
        (local.get $currentClass)
       )
      )
     )
     (br $hierarchy_loop)
    )
   )
   (if
    (ref.is_null
     (local.tee $keys
      (struct.get $Dictionary $keys
       (ref.as_non_null
        (local.get $methodDictionary)
       )
      )
     )
    )
    (then
     (local.set $currentClass
      (struct.get $Class $superclass
       (ref.cast (ref $Class)
        (local.get $currentClass)
       )
      )
     )
     (br $hierarchy_loop)
    )
   )
   (if
    (ref.is_null
     (local.tee $values
      (struct.get $Dictionary $values
       (ref.as_non_null
        (local.get $methodDictionary)
       )
      )
     )
    )
    (then
     (local.set $currentClass
      (struct.get $Class $superclass
       (ref.cast (ref $Class)
        (local.get $currentClass)
       )
      )
     )
     (br $hierarchy_loop)
    )
   )
   (local.set $count
    (struct.get $Dictionary $count
     (ref.as_non_null
      (local.get $methodDictionary)
     )
    )
   )
   (local.set $i
    (i32.const 0)
   )
   (loop $search_loop
    (if
     (i32.ge_u
      (local.get $i)
      (local.get $count)
     )
     (then
      (local.set $currentClass
       (struct.get $Class $superclass
        (ref.cast (ref $Class)
         (local.get $currentClass)
        )
       )
      )
      (br $hierarchy_loop)
     )
    )
    (local.set $key
     (array.get $objectArray
      (struct.get $Array $array
       (local.get $keys)
      )
      (local.get $i)
     )
    )
    (if
     (ref.eq
      (local.get $key)
      (local.get $selector)
     )
     (then
      (return
       (ref.cast (ref $CompiledMethod)
        (array.get $objectArray
         (struct.get $Array $array
          (local.get $values)
         )
         (local.get $i)
        )
       )
      )
     )
    )
    (local.set $i
     (i32.add
      (local.get $i)
      (i32.const 1)
     )
    )
    (br $search_loop)
   )
  )
  (return
   (ref.null none)
  )
 )
 (func $lookupInCache (type $49) (param $vm (ref $VirtualMachine)) (param $selector eqref) (param $receiverClass (ref $Class)) (result (ref null $CompiledMethod))
  (local $cache (ref null $objectArray))
  (local $cacheSize i32)
  (local $hash i32)
  (local $index i32)
  (local $entry (ref null $PICEntry))
  (local $probeLimit i32)
  (if
   (ref.is_null
    (local.tee $cache
     (struct.get $VirtualMachine $methodCache
      (local.get $vm)
     )
    )
   )
   (then
    (return
     (ref.null none)
    )
   )
  )
  (local.set $index
   (i32.rem_u
    (i32.add
     (struct.get $Object $identityHash
      (ref.cast (ref $Object)
       (local.get $selector)
      )
     )
     (struct.get $Class $identityHash
      (ref.as_non_null
       (local.get $receiverClass)
      )
     )
    )
    (struct.get $VirtualMachine $methodCacheSize
     (local.get $vm)
    )
   )
  )
  (local.set $probeLimit
   (i32.const 8)
  )
  (return
   (block $finished
    (loop $probe_loop
     (if
      (i32.le_s
       (local.get $probeLimit)
       (i32.const 0)
      )
      (then
       (return
        (ref.null none)
       )
      )
     )
     (if
      (ref.is_null
       (local.tee $entry
        (ref.cast (ref null $PICEntry)
         (array.get $objectArray
          (ref.as_non_null
           (local.get $cache)
          )
          (local.get $index)
         )
        )
       )
      )
      (then
       (return
        (ref.null none)
       )
      )
     )
     (if
      (i32.and
       (ref.eq
        (struct.get $PICEntry $selector
         (local.tee $entry
          (ref.cast (ref $PICEntry)
           (local.get $entry)
          )
         )
        )
        (local.get $selector)
       )
       (ref.eq
        (struct.get $PICEntry $receiverClass
         (local.get $entry)
        )
        (local.get $receiverClass)
       )
      )
      (then
       (struct.set $PICEntry $hitCount
        (local.get $entry)
        (i32.add
         (struct.get $PICEntry $hitCount
          (local.get $entry)
         )
         (i32.const 1)
        )
       )
       (return
        (struct.get $PICEntry $method
         (local.get $entry)
        )
       )
      )
     )
     (local.set $index
      (i32.rem_u
       (i32.add
        (local.get $index)
        (i32.const 1)
       )
       (struct.get $VirtualMachine $methodCacheSize
        (local.get $vm)
       )
      )
     )
     (local.set $probeLimit
      (i32.sub
       (local.get $probeLimit)
       (i32.const 1)
      )
     )
     (br $probe_loop)
    )
   )
  )
 )
 (func $storeInCache (type $50) (param $vm (ref $VirtualMachine)) (param $selector (ref $Symbol)) (param $receiverClass (ref eq)) (param $method (ref null $CompiledMethod))
  (local $cache (ref null $objectArray))
  (local $index i32)
  (local $entry (ref $PICEntry))
  (if
   (ref.is_null
    (local.tee $cache
     (struct.get $VirtualMachine $methodCache
      (local.get $vm)
     )
    )
   )
   (then
    (return)
   )
  )
  (local.set $index
   (i32.rem_u
    (i32.add
     (struct.get $Symbol $identityHash
      (ref.cast (ref $Symbol)
       (local.get $selector)
      )
     )
     (struct.get $ClassDescription $identityHash
      (ref.cast (ref $ClassDescription)
       (local.get $receiverClass)
      )
     )
    )
    (struct.get $VirtualMachine $methodCacheSize
     (local.get $vm)
    )
   )
  )
  (local.set $entry
   (struct.new $PICEntry
    (local.get $selector)
    (local.get $receiverClass)
    (local.get $method)
    (i32.const 1)
   )
  )
  (array.set $objectArray
   (ref.as_non_null
    (local.get $cache)
   )
   (local.get $index)
   (local.get $entry)
  )
 )
 (func $newContext (type $51) (param $vm (ref $VirtualMachine)) (param $receiver eqref) (param $method (ref null $CompiledMethod)) (param $selector eqref) (result (ref $Context))
  (local $stack (ref $objectArray))
  (local $slots (ref $objectArray))
  (local $args (ref $objectArray))
  (local $temps (ref $objectArray))
  (local.set $stack
   (array.new $objectArray
    (ref.null none)
    (i32.const 20)
   )
  )
  (local.set $slots
   (array.new $objectArray
    (ref.null none)
    (i32.const 0)
   )
  )
  (local.set $args
   (array.new $objectArray
    (ref.null none)
    (i32.const 0)
   )
  )
  (local.set $temps
   (array.new $objectArray
    (ref.null none)
    (i32.const 0)
   )
  )
  (struct.new $Context
   (struct.get $VirtualMachine $classContext
    (local.get $vm)
   )
   (call $nextIdentityHash
    (local.get $vm)
   )
   (ref.null none)
   (struct.get $VirtualMachine $activeContext
    (local.get $vm)
   )
   (i32.const 0)
   (i32.const 0)
   (local.get $method)
   (local.get $receiver)
   (call $newArray
    (local.get $vm)
    (local.get $args)
   )
   (call $newArray
    (local.get $vm)
    (local.get $temps)
   )
   (call $newArray
    (local.get $vm)
    (local.get $stack)
   )
  )
 )
 (func $smallIntegerForValue (type $22) (param $value i32) (result (ref i31))
  (ref.i31
   (local.get $value)
  )
 )
 (func $valueOfSmallInteger (type $19) (param $obj eqref) (result i32)
  (if (result i32)
   (ref.test (ref i31)
    (local.get $obj)
   )
   (then
    (i31.get_s
     (ref.cast (ref i31)
      (local.get $obj)
     )
    )
   )
   (else
    (i32.const 0)
   )
  )
 )
 (func $isTranslated (type $52) (param $method (ref null $CompiledMethod)) (result i32)
  (i32.gt_u
   (struct.get $CompiledMethod $functionIndex
    (local.get $method)
   )
   (i32.const 0)
  )
 )
 (func $executeTranslatedMethod (type $53) (param $context (ref null $Context)) (param $funcIndex i32) (result i32)
  (call_indirect $functionTable (type $19)
   (local.get $context)
   (local.get $funcIndex)
  )
 )
 (func $triggerMethodTranslation (type $54) (param $method (ref null $CompiledMethod)) (param $identityHash i32)
  (local $slots eqref)
  (local $bytecodeLen i32)
  (local $functionIndexIndex i32)
  (local $memoryOffset i32)
  (if
   (ref.is_null
    (local.tee $slots
     (struct.get $CompiledMethod $slots
      (local.get $method)
     )
    )
   )
   (then
    (return)
   )
  )
  (local.set $bytecodeLen
   (array.len
    (ref.cast (ref $byteArray)
     (local.get $slots)
    )
   )
  )
  (call $translateMethod
   (local.get $method)
   (local.get $identityHash)
  )
 )
 (func $handleMethodReturn (type $55) (param $vm (ref $VirtualMachine)) (param $context (ref null $Context)) (result eqref)
  (local $sender (ref null $Context))
  (local $result eqref)
  (local.set $result
   (call $topOfStack
    (local.get $context)
   )
  )
  (if
   (i32.eqz
    (ref.is_null
     (local.tee $sender
      (struct.get $Context $sender
       (local.get $context)
      )
     )
    )
   )
   (then
    (call $pushOnStack
     (ref.as_non_null
      (local.get $sender)
     )
     (ref.as_non_null
      (local.get $result)
     )
    )
    (struct.set $Context $pc
     (ref.as_non_null
      (local.get $sender)
     )
     (i32.add
      (struct.get $Context $pc
       (ref.as_non_null
        (local.get $sender)
       )
      )
      (i32.const 1)
     )
    )
   )
  )
  (if
   (ref.is_null
    (local.get $sender)
   )
   (then
    (struct.set $VirtualMachine $activeContext
     (local.get $vm)
     (ref.null none)
    )
   )
   (else
    (struct.set $VirtualMachine $activeContext
     (local.get $vm)
     (local.get $sender)
    )
   )
  )
  (local.get $result)
 )
 (func $14 (type $20) (param $vm (ref $VirtualMachine)) (result i32)
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
  (local.set $mainBytecodes
   (array.new_fixed $byteArray 3
    (i32.const 112)
    (i32.const 208)
    (i32.const 124)
   )
  )
  (local.set $workloadBytecodes
   (array.new_fixed $byteArray 62
    (i32.const 112)
    (i32.const 33)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 34)
    (i32.const 176)
    (i32.const 35)
    (i32.const 184)
    (i32.const 35)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 33)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 34)
    (i32.const 176)
    (i32.const 35)
    (i32.const 184)
    (i32.const 35)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 33)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 34)
    (i32.const 176)
    (i32.const 35)
    (i32.const 184)
    (i32.const 35)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 33)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 34)
    (i32.const 176)
    (i32.const 35)
    (i32.const 184)
    (i32.const 35)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 33)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 34)
    (i32.const 176)
    (i32.const 35)
    (i32.const 184)
    (i32.const 35)
    (i32.const 176)
    (i32.const 34)
    (i32.const 184)
    (i32.const 124)
   )
  )
  (local.set $workloadSelector
   (call $newSymbolFromBytes
    (local.get $vm)
    (array.new_fixed $byteArray 8
     (i32.const 119)
     (i32.const 111)
     (i32.const 114)
     (i32.const 107)
     (i32.const 108)
     (i32.const 111)
     (i32.const 97)
     (i32.const 100)
    )
   )
  )
  (local.set $literals
   (call $newArray
    (local.get $vm)
    (array.new $objectArray
     (ref.null none)
     (i32.const 1)
    )
   )
  )
  (array.set $objectArray
   (struct.get $Array $array
    (local.get $literals)
   )
   (i32.const 0)
   (local.get $workloadSelector)
  )
  (local.set $mainMethod
   (ref.cast (ref $CompiledMethod)
    (local.tee $newObject
     (struct.new $CompiledMethod
      (struct.get $VirtualMachine $classObject
       (local.get $vm)
      )
      (call $nextIdentityHash
       (local.get $vm)
      )
      (ref.null none)
      (local.get $mainBytecodes)
      (local.get $literals)
      (i32.const 0)
      (i32.const 0)
      (i32.const 0)
      (struct.get $VirtualMachine $translationThreshold
       (local.get $vm)
      )
      (i32.const 0)
     )
    )
   )
  )
  (struct.set $VirtualMachine $activeContext
   (local.get $vm)
   (call $newContext
    (local.get $vm)
    (ref.i31
     (i32.const 100)
    )
    (local.get $mainMethod)
    (local.get $workloadSelector)
   )
  )
  (local.set $workloadLiterals
   (array.new $objectArray
    (ref.null none)
    (i32.const 4)
   )
  )
  (array.set $objectArray
   (local.get $workloadLiterals)
   (i32.const 0)
   (ref.as_non_null
    (call $smallIntegerForValue
     (i32.const 0)
    )
   )
  )
  (array.set $objectArray
   (local.get $workloadLiterals)
   (i32.const 1)
   (call $smallIntegerForValue
    (i32.const 1)
   )
  )
  (array.set $objectArray
   (local.get $workloadLiterals)
   (i32.const 2)
   (call $smallIntegerForValue
    (i32.const 2)
   )
  )
  (array.set $objectArray
   (local.get $workloadLiterals)
   (i32.const 3)
   (call $smallIntegerForValue
    (i32.const 3)
   )
  )
  (local.set $workloadMethod
   (struct.new $CompiledMethod
    (struct.get $VirtualMachine $classObject
     (local.get $vm)
    )
    (call $nextIdentityHash
     (local.get $vm)
    )
    (ref.null none)
    (local.get $workloadBytecodes)
    (call $newArray
     (local.get $vm)
     (local.get $workloadLiterals)
    )
    (i32.const 0)
    (i32.const 0)
    (i32.const 0)
    (struct.get $VirtualMachine $translationThreshold
     (local.get $vm)
    )
    (i32.const 0)
   )
  )
  (local.set $methodDictionary
   (call $newDictionary
    (local.get $vm)
   )
  )
  (struct.set $Class $methodDictionary
   (struct.get $VirtualMachine $classSmallInteger
    (local.get $vm)
   )
   (local.get $methodDictionary)
  )
  (array.set $objectArray
   (struct.get $Array $array
    (struct.get $Dictionary $keys
     (local.get $methodDictionary)
    )
   )
   (i32.const 0)
   (local.get $workloadSelector)
  )
  (array.set $objectArray
   (struct.get $Array $array
    (struct.get $Dictionary $values
     (local.get $methodDictionary)
    )
   )
   (i32.const 0)
   (local.get $workloadMethod)
  )
  (struct.set $Dictionary $count
   (local.get $methodDictionary)
   (i32.const 1)
  )
  (struct.set $CompiledMethod $isInstalled
   (local.get $workloadMethod)
   (i32.const 1)
  )
  (i32.const 1)
 )
 (func $interpretBytecode (type $56) (param $vm (ref $VirtualMachine)) (param $context (ref $Context)) (param $bytecode i32) (result i32)
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
  (local.set $receiver
   (struct.get $Context $receiver
    (local.get $context)
   )
  )
  (local.set $literals
   (struct.get $Array $array
    (struct.get $CompiledMethod $literals
     (struct.get $Context $method
      (local.get $context)
     )
    )
   )
  )
  (if
   (i32.and
    (i32.ge_u
     (local.get $bytecode)
     (i32.const 32)
    )
    (i32.le_u
     (local.get $bytecode)
     (i32.const 47)
    )
   )
   (then
    (local.set $selectorIndex
     (i32.sub
      (local.get $bytecode)
      (i32.const 32)
     )
    )
    (if
     (i32.ge_u
      (local.get $selectorIndex)
      (array.len
       (local.get $literals)
      )
     )
     (then
      (call $pushOnStack
       (local.get $context)
       (call $smallIntegerForValue
        (i32.const 0)
       )
      )
     )
     (else
      (call $pushOnStack
       (local.get $context)
       (array.get $objectArray
        (local.get $literals)
        (local.get $selectorIndex)
       )
      )
     )
    )
    (return
     (i32.const 0)
    )
   )
  )
  (if
   (i32.eq
    (local.get $bytecode)
    (i32.const 112)
   )
   (then
    (call $pushOnStack
     (local.get $context)
     (local.get $receiver)
    )
    (return
     (i32.const 0)
    )
   )
  )
  (if
   (i32.eq
    (local.get $bytecode)
    (i32.const 184)
   )
   (then
    (if
     (ref.is_null
      (local.tee $value2
       (call $popFromStack
        (local.get $context)
       )
      )
     )
     (then
      (return
       (i32.const 0)
      )
     )
    )
    (if
     (ref.is_null
      (local.tee $value1
       (call $popFromStack
        (local.get $context)
       )
      )
     )
     (then
      (call $pushOnStack
       (local.get $context)
       (local.get $value2)
      )
      (return
       (i32.const 0)
      )
     )
    )
    (local.set $int1
     (call $valueOfSmallInteger
      (local.get $value1)
     )
    )
    (local.set $int2
     (call $valueOfSmallInteger
      (local.get $value2)
     )
    )
    (local.set $result
     (i32.mul
      (local.get $int1)
      (local.get $int2)
     )
    )
    (call $pushOnStack
     (local.get $context)
     (ref.as_non_null
      (call $smallIntegerForValue
       (local.get $result)
      )
     )
    )
    (return
     (i32.const 0)
    )
   )
  )
  (if
   (i32.eq
    (local.get $bytecode)
    (i32.const 176)
   )
   (then
    (if
     (ref.is_null
      (local.tee $value2
       (call $popFromStack
        (local.get $context)
       )
      )
     )
     (then
      (return
       (i32.const 0)
      )
     )
    )
    (if
     (ref.is_null
      (local.tee $value1
       (call $popFromStack
        (local.get $context)
       )
      )
     )
     (then
      (call $pushOnStack
       (local.get $context)
       (local.get $value2)
      )
      (return
       (i32.const 0)
      )
     )
    )
    (local.set $int1
     (call $valueOfSmallInteger
      (local.get $value1)
     )
    )
    (local.set $int2
     (call $valueOfSmallInteger
      (local.get $value2)
     )
    )
    (local.set $result
     (i32.add
      (local.get $int1)
      (local.get $int2)
     )
    )
    (call $pushOnStack
     (local.get $context)
     (call $smallIntegerForValue
      (local.get $result)
     )
    )
    (return
     (i32.const 0)
    )
   )
  )
  (if
   (i32.eq
    (local.get $bytecode)
    (i32.const 124)
   )
   (then
    (return
     (i32.const 1)
    )
   )
  )
  (if
   (i32.eq
    (local.get $bytecode)
    (i32.const 208)
   )
   (then
    (if
     (ref.is_null
      (local.tee $receiver
       (call $popFromStack
        (local.get $context)
       )
      )
     )
     (then
      (return
       (i32.const 0)
      )
     )
    )
    (local.set $selectorIndex
     (i32.and
      (local.get $bytecode)
      (i32.const 15)
     )
    )
    (if
     (i32.ge_u
      (local.get $selectorIndex)
      (array.len
       (local.get $literals)
      )
     )
     (then
      (call $pushOnStack
       (local.get $context)
       (local.get $receiver)
      )
      (return
       (i32.const 0)
      )
     )
    )
    (local.set $selector
     (ref.cast (ref $Symbol)
      (array.get $objectArray
       (local.get $literals)
       (local.get $selectorIndex)
      )
     )
    )
    (local.set $receiverClass
     (ref.cast (ref $Class)
      (call $classOfObject
       (local.get $vm)
       (local.get $receiver)
      )
     )
    )
    (if
     (ref.is_null
      (local.tee $method
       (call $lookupInCache
        (local.get $vm)
        (local.get $selector)
        (local.get $receiverClass)
       )
      )
     )
     (then
      (if
       (ref.is_null
        (local.tee $method
         (call $lookupMethod
          (local.get $vm)
          (local.get $receiver)
          (local.get $selector)
         )
        )
       )
       (then
        (call $pushOnStack
         (local.get $context)
         (local.get $receiver)
        )
        (return
         (i32.const 0)
        )
       )
      )
      (call $storeInCache
       (local.get $vm)
       (local.get $selector)
       (local.get $receiverClass)
       (local.get $method)
      )
     )
    )
    (local.set $newContext
     (call $newContext
      (local.get $vm)
      (local.get $receiver)
      (local.get $method)
      (local.get $selector)
     )
    )
    (struct.set $VirtualMachine $activeContext
     (local.get $vm)
     (local.get $newContext)
    )
    (return
     (i32.const 0)
    )
   )
  )
  (i32.const 0)
 )
 (func $15 (type $20) (param $vm (ref $VirtualMachine)) (result i32)
  (local $context (ref null $Context))
  (local $method (ref null $CompiledMethod))
  (local $bytecode i32)
  (local $pc i32)
  (local $receiver eqref)
  (local $resultValue eqref)
  (local $invocationCount i32)
  (local $slots (ref $byteArray))
  (local $funcIndex i32)
  (block $finished
   (loop $execution_loop
    (if
     (ref.is_null
      (local.tee $context
       (struct.get $VirtualMachine $activeContext
        (local.get $vm)
       )
      )
     )
     (then
      (br $finished)
     )
    )
    (local.set $receiver
     (struct.get $Context $receiver
      (ref.as_non_null
       (local.get $context)
      )
     )
    )
    (local.set $invocationCount
     (i32.add
      (struct.get $CompiledMethod $invocationCount
       (local.tee $method
        (struct.get $Context $method
         (ref.as_non_null
          (local.get $context)
         )
        )
       )
      )
      (i32.const 1)
     )
    )
    (struct.set $CompiledMethod $invocationCount
     (local.get $method)
     (local.get $invocationCount)
    )
    (if
     (i32.and
      (i32.eq
       (local.get $invocationCount)
       (struct.get $CompiledMethod $translationThreshold
        (local.get $method)
       )
      )
      (struct.get $VirtualMachine $translationEnabled
       (local.get $vm)
      )
     )
     (then
      (if
       (i32.eq
        (struct.get $CompiledMethod $isInstalled
         (local.get $method)
        )
        (i32.const 1)
       )
       (then
        (if
         (i32.eqz
          (call $isTranslated
           (local.get $method)
          )
         )
         (then
          (call $triggerMethodTranslation
           (local.get $method)
           (struct.get $Object $identityHash
            (ref.cast (ref $Object)
             (local.get $receiver)
            )
           )
          )
         )
        )
       )
      )
     )
    )
    (if
     (call $isTranslated
      (ref.as_non_null
       (local.get $method)
      )
     )
     (then
      (local.set $funcIndex
       (struct.get $CompiledMethod $functionIndex
        (local.get $method)
       )
      )
      (drop
       (call $executeTranslatedMethod
        (ref.as_non_null
         (local.get $context)
        )
        (local.get $funcIndex)
       )
      )
      (local.set $resultValue
       (call $handleMethodReturn
        (local.get $vm)
        (ref.as_non_null
         (local.get $context)
        )
       )
      )
      (br $execution_loop)
     )
    )
    (local.set $slots
     (struct.get $ByteArray $array
      (ref.cast (ref $ByteArray)
       (struct.get $CompiledMethod $slots
        (local.get $method)
       )
      )
     )
    )
    (loop $interpreter_loop
     (br_if $execution_loop
      (ref.is_null
       (local.tee $context
        (struct.get $VirtualMachine $activeContext
         (local.get $vm)
        )
       )
      )
     )
     (local.set $pc
      (struct.get $Context $pc
       (ref.as_non_null
        (local.get $context)
       )
      )
     )
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
               (local.get $context)
              )
             )
            )
           )
          )
         )
        )
       )
       (local.get $pc)
      )
      (then
       (local.set $resultValue
        (call $handleMethodReturn
         (local.get $vm)
         (ref.as_non_null
          (local.get $context)
         )
        )
       )
       (br $interpreter_loop)
      )
     )
     (local.set $bytecode
      (array.get_u $byteArray
       (local.get $slots)
       (local.get $pc)
      )
     )
     (if
      (call $interpretBytecode
       (local.get $vm)
       (ref.as_non_null
        (local.get $context)
       )
       (local.get $bytecode)
      )
      (then
       (local.set $resultValue
        (call $handleMethodReturn
         (local.get $vm)
         (ref.as_non_null
          (local.get $context)
         )
        )
       )
       (br $interpreter_loop)
      )
     )
     (if
      (ref.eq
       (struct.get $VirtualMachine $activeContext
        (local.get $vm)
       )
       (local.get $context)
      )
      (then
       (struct.set $Context $pc
        (ref.as_non_null
         (local.get $context)
        )
        (i32.add
         (local.get $pc)
         (i32.const 1)
        )
       )
      )
      (else
       (if
        (i32.eqz
         (struct.get $Context $pc
          (ref.as_non_null
           (struct.get $VirtualMachine $activeContext
            (local.get $vm)
           )
          )
         )
        )
        (then
         (br $execution_loop)
        )
       )
      )
     )
     (br $interpreter_loop)
    )
   )
  )
  (call $reportResult
   (call $valueOfSmallInteger
    (local.get $resultValue)
   )
  )
  (return
   (i32.const 1)
  )
 )
)
