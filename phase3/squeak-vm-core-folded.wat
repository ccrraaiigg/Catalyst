(module
  (rec
    (type $ObjectArray (;0;) (array (mut eqref)))
    (type $ByteArray (;1;) (array (mut i8)))
    (type $SqueakObject (;2;) (sub (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))))))
    (type $VariableObject (;3;) (sub $SqueakObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))))))
    (type $Symbol (;4;) (sub $VariableObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))) (field (ref null $ByteArray)))))
    (type $Class (;5;) (sub $VariableObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))) (field (mut (ref null $Class))) (field (mut (ref $Dictionary))) (field (mut (ref $ObjectArray))) (field (mut (ref $Symbol))) (field (mut i32)))))
    (type $Dictionary (;6;) (sub $VariableObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))) (field (ref $ObjectArray)) (field (ref $ObjectArray)) (field (mut i32)))))
    (type $CompiledMethod (;7;) (sub $VariableObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))) (field i32) (field (ref null $ByteArray)) (field (mut i32)) (field (mut i32)) (field i32) (field (mut i32)))))
    (type $Context (;8;) (sub $VariableObject (struct (field (mut (ref null $Class))) (field (mut i32)) (field (mut i32)) (field (mut i32)) (field (mut (ref null $SqueakObject))) (field (mut (ref $ObjectArray))) (field (mut (ref null $Context))) (field (mut i32)) (field (mut i32)) (field (mut (ref null $CompiledMethod))) (field (mut eqref)) (field (mut (ref $ObjectArray))) (field (mut (ref $ObjectArray))) (field (mut (ref $ObjectArray))))))
    (type $PICEntry (;9;) (struct (field (mut eqref)) (field (mut (ref null $Class))) (field (mut (ref null $CompiledMethod))) (field (mut i32))))
    (type $jit_func_type (;10;) (func (param eqref) (result i32)))
    (type $VirtualMachine (;11;) (struct (field (mut (ref $Context))) (field (mut i32)) (field (mut (ref $ObjectArray))) (field (mut i32)) (field (mut i32)) (field (mut (ref $SqueakObject))) (field (mut (ref $SqueakObject)))))
  )
  (type (;12;) (func (param i32)))
  (type (;13;) (func (param eqref eqref eqref)))
  (type (;14;) (func (param i32 i32 i32)))
  (type (;15;) (func (param (ref $VirtualMachine) (ref null $CompiledMethod)) (result (ref null $ByteArray))))
  (type (;16;) (func (param (ref $VirtualMachine) i32) (result (ref null $CompiledMethod))))
  (type (;17;) (func (param (ref null $CompiledMethod) i32)))
  (type (;18;) (func (param eqref eqref)))
  (type (;19;) (func (param eqref) (result eqref)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param i32) (result eqref)))
  (type (;22;) (func (param eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref eqref) (result eqref)))
  (type (;24;) (func (param eqref i32) (result i32)))
  (type (;25;) (func (param (ref $Context) i32) (result eqref)))
  (type (;26;) (func (param eqref i32) (result eqref)))
  (type (;27;) (func (param (ref null $ByteArray)) (result i32)))
  (type (;28;) (func (param (ref null $ByteArray) i32) (result i32)))
  (type (;29;) (func (param (ref null $ObjectArray)) (result i32)))
  (type (;30;) (func (param (ref null $ObjectArray) i32) (result eqref)))
  (type (;31;) (func (param (ref $VirtualMachine)) (result i32)))
  (type (;32;) (func (param (ref null $Context) eqref)))
  (type (;33;) (func (param (ref null $Context)) (result eqref)))
  (type (;34;) (func (param eqref) (result (ref null $Class))))
  (type (;35;) (func (param eqref eqref) (result (ref null $CompiledMethod))))
  (type (;36;) (func (param (ref $VirtualMachine) eqref (ref null $Class)) (result (ref null $CompiledMethod))))
  (type (;37;) (func (param (ref $VirtualMachine) eqref (ref null $Class) (ref $CompiledMethod))))
  (type (;38;) (func (param (ref $VirtualMachine) eqref (ref $CompiledMethod) eqref) (result (ref null $Context))))
  (type (;39;) (func (param i32) (result (ref i31))))
  (type (;40;) (func (param (ref $CompiledMethod)) (result i32)))
  (type (;41;) (func (param (ref null $Context) i32) (result i32)))
  (type (;42;) (func (param (ref $CompiledMethod))))
  (type (;43;) (func (param (ref $VirtualMachine) (ref null $Context)) (result eqref)))
  (type (;44;) (func (result (ref $VirtualMachine))))
  (type (;45;) (func (result i32)))
  (type (;46;) (func (param (ref $VirtualMachine) (ref $Context) i32) (result i32)))
  (import "env" "reportResult" (func $reportResult (;0;) (type 12)))
  (import "env" "translateMethod" (func $translateMethod (;1;) (type 13)))
  (import "env" "debugLog" (func $debugLog (;2;) (type 14)))
  (table $functionTable (;0;) 100 funcref)
  (memory (;0;) 1)
  (global $objectClass (;0;) (mut (ref null $Class)) ref.null $Class)
  (global $classClass (;1;) (mut (ref null $Class)) ref.null $Class)
  (global $methodClass (;2;) (mut (ref null $Class)) ref.null $Class)
  (global $contextClass (;3;) (mut (ref null $Class)) ref.null $Class)
  (global $symbolClass (;4;) (mut (ref null $Class)) ref.null $Class)
  (global $smallIntegerClass (;5;) (mut (ref null $Class)) ref.null $Class)
  (global $mainMethod (;6;) (mut (ref null $CompiledMethod)) ref.null $CompiledMethod)
  (global $nilObject (;7;) (mut eqref) ref.null eq)
  (global $trueObject (;8;) (mut eqref) ref.null eq)
  (global $falseObject (;9;) (mut eqref) ref.null eq)
  (global $workloadSelector (;10;) (mut eqref) ref.null eq)
  (global $translationThreshold (;11;) (mut i32) i32.const 1000)
  (global $methodCacheSize (;12;) (mut i32) i32.const 256)
  (global $byteArrayCopyPtr (;13;) (mut i32) i32.const 1024)
  (export "functionTable" (table $functionTable))
  (export "memory" (memory 0))
  (export "compiledMethodBytecodes" (func 3))
  (export "methodWithID" (func 4))
  (export "setMethodFunctionIndex" (func 5))
  (export "onContextPush" (func 6))
  (export "popFromContext" (func 7))
  (export "valueOfSmallInteger" (func 8))
  (export "smallIntegerForValue" (func 9))
  (export "classOfObject" (func 10))
  (export "lookupInCache" (func 11))
  (export "lookupMethod" (func 12))
  (export "storeInCache" (func 13))
  (export "createMethodContext" (func 14))
  (export "interpretBytecode" (func 15))
  (export "getActiveContext" (func 16))
  (export "getContextReceiver" (func 17))
  (export "getCompiledMethodSlots" (func 18))
  (export "getContextLiteral" (func 20))
  (export "getContextMethod" (func 21))
  (export "objectArrayAt" (func 22))
  (export "getObjectArrayLength" (func 23))
  (export "copyByteArrayToMemory" (func 24))
  (export "getByteArrayLen" (func 25))
  (export "initialize" (func $initialize))
  (export "interpret" (func $interpret))
  (func (;3;) (type 15) (param $vm (ref $VirtualMachine)) (param (ref null $CompiledMethod)) (result (ref null $ByteArray))
    local.get $vm
    struct.get $CompiledMethod 7
  )
  (func (;4;) (type 16) (param $vm (ref $VirtualMachine)) (param i32) (result (ref null $CompiledMethod))
    (local $targetHash i32) (local $currentObject (ref null $SqueakObject)) (local $currentHash i32)
    local.get $vm
    local.set $targetHash
    local.get $vm
    struct.get $VirtualMachine 5
    local.set $currentObject
    loop $search_loop
      local.get $currentObject
      ref.is_null
      if ;; label = @2
        ref.null $CompiledMethod
        return
      end
      local.get $currentObject
      ref.as_non_null
      struct.get $SqueakObject 1
      local.set $currentHash
      local.get $currentHash
      local.get $targetHash
      i32.eq
      if ;; label = @2
        local.get $currentObject
        ref.cast (ref $CompiledMethod)
        return
      end
      local.get $currentObject
      ref.as_non_null
      struct.get $SqueakObject 4
      local.set $currentObject
      br $search_loop
    end
    ref.null $CompiledMethod
  )
  (func (;5;) (type 17) (param (ref null $CompiledMethod) i32)
    local.get 0
    local.get 1
    struct.set $CompiledMethod 9
  )
  (func (;6;) (type 18) (param $context eqref) (param $value eqref)
    local.get $context
    ref.cast (ref null $Context)
    local.get $value
    call $pushOnStack
  )
  (func (;7;) (type 19) (param $context eqref) (result eqref)
    local.get $context
    ref.cast (ref null $Context)
    call $popFromStack
  )
  (func (;8;) (type 20) (param $obj eqref) (result i32)
    local.get $obj
    call $valueOfSmallInteger
  )
  (func (;9;) (type 21) (param $value i32) (result eqref)
    local.get $value
    call $smallIntegerForValue
  )
  (func (;10;) (type 19) (param $obj eqref) (result eqref)
    local.get $obj
    call $classOfObject
  )
  (func (;11;) (type 22) (param $selector eqref) (param $receiverClass eqref) (result eqref)
    local.get $selector
    local.get $receiverClass
    ref.cast (ref null $Class)
    call $lookupInCache
  )
  (func (;12;) (type 22) (param $receiver eqref) (param $selector eqref) (result eqref)
    local.get $receiver
    local.get $selector
    call $lookupMethod
  )
  (func (;13;) (type 13) (param $selector eqref) (param $receiverClass eqref) (param $method eqref)
    local.get $method
    ref.cast (ref null $CompiledMethod)
    ref.is_null
    if ;; label = @1
      return
    end
    local.get $selector
    local.get $receiverClass
    ref.cast (ref null $Class)
    local.get $method
    ref.cast (ref null $CompiledMethod)
    ref.as_non_null
    call $storeInCache
  )
  (func (;14;) (type 23) (param $receiver eqref) (param $method eqref) (param $selector eqref) (result eqref)
    local.get $method
    ref.cast (ref null $CompiledMethod)
    ref.is_null
    if ;; label = @1
      ref.null $Context
      return
    end
    local.get $receiver
    local.get $method
    ref.cast (ref null $CompiledMethod)
    ref.as_non_null
    local.get $selector
    call $createMethodContext
  )
  (func (;15;) (type 24) (param $context eqref) (param $bytecode i32) (result i32)
    local.get $context
    ref.cast (ref null $Context)
    local.get $bytecode
    call $interpretBytecode
  )
  (func (;16;) (type 19) (param $vm eqref) (result eqref)
    local.get $vm
    struct.get $VirtualMachine 0
  )
  (func (;17;) (type 19) (param $context eqref) (result eqref)
    local.get $context
    ref.cast (ref null $Context)
    struct.get $Context 10
  )
  (func (;18;) (type 19) (param $method eqref) (result eqref)
    local.get $method
    ref.cast (ref $CompiledMethod)
    struct.get $CompiledMethod 5
  )
  (func $contextLiteralAt (;19;) (type 25) (param $context (ref $Context)) (param $index i32) (result eqref)
    local.get $context
    ref.cast (ref null $Context)
    struct.get $Context 9
    struct.get $CompiledMethod 5
    ref.cast (ref null $ObjectArray)
    local.get $index
    call $objectArrayAt
  )
  (func (;20;) (type 26) (param $context eqref) (param $index i32) (result eqref)
    local.get $context
    ref.cast (ref $Context)
    local.get $index
    call $contextLiteralAt
  )
  (func (;21;) (type 19) (param $context eqref) (result eqref)
    local.get $context
    ref.cast (ref null $Context)
    struct.get $Context 9
  )
  (func (;22;) (type 26) (param $array eqref) (param $index i32) (result eqref)
    local.get $array
    ref.cast (ref null $ObjectArray)
    local.get $index
    call $objectArrayAt
  )
  (func (;23;) (type 20) (param $array eqref) (result i32)
    local.get $array
    ref.cast (ref null $ObjectArray)
    call $array_len_object
  )
  (func (;24;) (type 27) (param (ref null $ByteArray)) (result i32)
    (local $len i32) (local $i i32)
    local.get 0
    ref.is_null
    if ;; label = @1
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
      if ;; label = @2
        global.get $byteArrayCopyPtr
        return
      end
      global.get $byteArrayCopyPtr
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
  (func (;25;) (type 27) (param (ref null $ByteArray)) (result i32)
    local.get 0
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 0
    ref.as_non_null
    array.len
  )
  (func $array_len_byte (;26;) (type 27) (param $array (ref null $ByteArray)) (result i32)
    local.get $array
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $array
    ref.as_non_null
    array.len
  )
  (func $array_get_byte (;27;) (type 28) (param $array (ref null $ByteArray)) (param $index i32) (result i32)
    (local $length i32)
    local.get $array
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $array
    ref.as_non_null
    array.len
    local.set $length
    local.get $index
    i32.const 0
    i32.lt_s
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $index
    local.get $length
    i32.ge_u
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $array
    local.get $index
    array.get_u $ByteArray
  )
  (func $array_len_object (;28;) (type 29) (param $array (ref null $ObjectArray)) (result i32)
    local.get $array
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $array
    ref.as_non_null
    array.len
  )
  (func $objectArrayAt (;29;) (type 30) (param $array (ref null $ObjectArray)) (param $index i32) (result eqref)
    (local $length i32)
    local.get $array
    ref.is_null
    if ;; label = @1
      ref.null eq
      return
    end
    local.get $array
    ref.as_non_null
    array.len
    local.set $length
    local.get $index
    i32.const 0
    i32.lt_s
    if ;; label = @1
      ref.null eq
      return
    end
    local.get $index
    local.get $length
    i32.ge_u
    if ;; label = @1
      ref.null eq
      return
    end
    local.get $array
    local.get $index
    array.get $ObjectArray
  )
  (func $isSmallInteger (;30;) (type 20) (param $obj eqref) (result i32)
    local.get $obj
    ref.test (ref i31)
  )
  (func $smallIntegerValue (;31;) (type 20) (param $obj eqref) (result i32)
    local.get $obj
    ref.cast (ref i31)
    i31.get_s
  )
  (func $nextIdentityHash (;32;) (type 31) (param $vm (ref $VirtualMachine)) (result i32)
    local.get $vm
    struct.get $VirtualMachine 4
    i32.const 1
    i32.add
    local.get $vm
    struct.set $VirtualMachine 4
    local.get $vm
    struct.get $VirtualMachine 4
  )
  (func $pushOnStack (;33;) (type 32) (param $context (ref null $Context)) (param $value eqref)
    (local $stack (ref $ObjectArray)) (local $sp i32)
    local.get $context
    struct.get $Context 13
    local.set $stack
    local.get $context
    struct.get $Context 8
    local.set $sp
    local.get $sp
    local.get $stack
    array.len
    i32.ge_u
    if ;; label = @1
      return
    end
    local.get $stack
    local.get $sp
    local.get $value
    array.set $ObjectArray
    local.get $context
    local.get $sp
    i32.const 1
    i32.add
    struct.set $Context 8
    return
  )
  (func $popFromStack (;34;) (type 33) (param $context (ref null $Context)) (result eqref)
    (local $stack (ref $ObjectArray)) (local $sp i32)
    local.get $context
    struct.get $Context 13
    local.set $stack
    local.get $context
    struct.get $Context 8
    local.set $sp
    local.get $sp
    i32.const 0
    i32.le_u
    if ;; label = @1
      ref.null eq
      return
    end
    local.get $context
    local.get $sp
    i32.const 1
    i32.sub
    struct.set $Context 8
    local.get $stack
    local.get $sp
    i32.const 1
    i32.sub
    array.get $ObjectArray
    return
  )
  (func $topOfStack (;35;) (type 33) (param $context (ref null $Context)) (result eqref)
    (local $stack (ref $ObjectArray)) (local $sp i32)
    local.get $context
    struct.get $Context 13
    local.set $stack
    local.get $context
    struct.get $Context 8
    local.set $sp
    local.get $sp
    i32.const 0
    i32.le_u
    if ;; label = @1
      ref.null eq
      return
    end
    local.get $stack
    local.get $sp
    i32.const 1
    i32.sub
    array.get $ObjectArray
    return
  )
  (func $classOfObject (;36;) (type 34) (param $obj eqref) (result (ref null $Class))
    local.get $obj
    ref.test (ref i31)
    if (result (ref null $Class)) ;; label = @1
      global.get $smallIntegerClass
    else
      local.get $obj
      ref.cast (ref $SqueakObject)
      struct.get $SqueakObject 0
    end
  )
  (func $lookupMethod (;37;) (type 35) (param $receiver eqref) (param $selector eqref) (result (ref null $CompiledMethod))
    (local $class (ref null $Class)) (local $currentClass (ref null $Class)) (local $methodDictionary (ref null $Dictionary)) (local $keys (ref null $ObjectArray)) (local $values (ref null $ObjectArray)) (local $count i32) (local $i i32) (local $key eqref)
    local.get $receiver
    call $classOfObject
    local.set $currentClass
    loop $hierarchy_loop
      local.get $currentClass
      ref.is_null
      if ;; label = @2
        ref.null $CompiledMethod
        return
      end
      local.get $currentClass
      ref.as_non_null
      struct.get $Class 7
      local.tee $methodDictionary
      ref.is_null
      if ;; label = @2
        local.get $currentClass
        ref.as_non_null
        struct.get $Class 6
        local.set $currentClass
        br $hierarchy_loop
      end
      local.get $methodDictionary
      ref.as_non_null
      struct.get $Dictionary 6
      local.tee $keys
      ref.is_null
      if ;; label = @2
        local.get $currentClass
        ref.as_non_null
        struct.get $Class 6
        local.set $currentClass
        br $hierarchy_loop
      end
      local.get $methodDictionary
      ref.as_non_null
      struct.get $Dictionary 7
      local.tee $values
      ref.is_null
      if ;; label = @2
        local.get $currentClass
        ref.as_non_null
        struct.get $Class 6
        local.set $currentClass
        br $hierarchy_loop
      end
      local.get $methodDictionary
      ref.as_non_null
      struct.get $Dictionary 8
      local.set $count
      i32.const 0
      local.set $i
      loop $search_loop
        local.get $i
        local.get $count
        i32.ge_u
        if ;; label = @3
          local.get $currentClass
          ref.as_non_null
          struct.get $Class 6
          local.set $currentClass
          br $hierarchy_loop
        end
        local.get $keys
        ref.as_non_null
        local.get $i
        array.get $ObjectArray
        local.set $key
        local.get $key
        local.get $selector
        ref.eq
        if ;; label = @3
          local.get $values
          ref.as_non_null
          local.get $i
          array.get $ObjectArray
          ref.cast (ref $CompiledMethod)
          return
        end
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $search_loop
      end
    end
    ref.null $CompiledMethod
    return
  )
  (func $lookupInCache (;38;) (type 36) (param $vm (ref $VirtualMachine)) (param $selector eqref) (param $receiverClass (ref null $Class)) (result (ref null $CompiledMethod))
    (local $cache (ref null $ObjectArray)) (local $cacheSize i32) (local $hash i32) (local $index i32) (local $entry (ref null $PICEntry)) (local $probeLimit i32)
    local.get $vm
    struct.get $VirtualMachine 2
    local.tee $cache
    ref.is_null
    if ;; label = @1
      ref.null $CompiledMethod
      return
    end
    local.get $selector
    ref.cast (ref $SqueakObject)
    struct.get $SqueakObject 1
    local.get $receiverClass
    ref.as_non_null
    struct.get $Class 1
    i32.add
    global.get $methodCacheSize
    i32.rem_u
    local.set $index
    i32.const 8
    local.set $probeLimit
    loop $probe_loop
      local.get $probeLimit
      i32.const 0
      i32.le_s
      if ;; label = @2
        ref.null $CompiledMethod
        return
      end
      local.get $cache
      ref.as_non_null
      local.get $index
      array.get $ObjectArray
      ref.cast (ref null $PICEntry)
      local.tee $entry
      ref.is_null
      if ;; label = @2
        ref.null $CompiledMethod
        return
      end
      local.get $entry
      ref.cast (ref $PICEntry)
      local.tee $entry
      struct.get $PICEntry 0
      local.get $selector
      ref.eq
      local.get $entry
      struct.get $PICEntry 1
      local.get $receiverClass
      ref.eq
      i32.and
      if ;; label = @2
        local.get $entry
        local.get $entry
        struct.get $PICEntry 3
        i32.const 1
        i32.add
        struct.set $PICEntry 3
        local.get $entry
        struct.get $PICEntry 2
        return
      end
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
    ref.null $CompiledMethod
    return
  )
  (func $storeInCache (;39;) (type 37) (param $vm (ref $VirtualMachine)) (param $selector eqref) (param $receiverClass (ref null $Class)) (param $method (ref $CompiledMethod))
    (local $cache (ref null $ObjectArray)) (local $index i32) (local $entry (ref $PICEntry))
    local.get $vm
    struct.get $VirtualMachine 2
    local.tee $cache
    ref.is_null
    if ;; label = @1
      return
    end
    local.get $selector
    ref.cast (ref $SqueakObject)
    struct.get $SqueakObject 1
    local.get $receiverClass
    ref.as_non_null
    struct.get $Class 1
    i32.add
    global.get $methodCacheSize
    i32.rem_u
    local.set $index
    local.get $selector
    local.get $receiverClass
    local.get $method
    i32.const 1
    struct.new $PICEntry
    local.set $entry
    local.get $cache
    ref.as_non_null
    local.get $index
    local.get $entry
    array.set $ObjectArray
  )
  (func $createMethodContext (;40;) (type 38) (param $vm (ref $VirtualMachine)) (param $receiver eqref) (param $method (ref $CompiledMethod)) (param $selector eqref) (result (ref null $Context))
    (local $stack (ref $ObjectArray)) (local $slots (ref $ObjectArray)) (local $args (ref $ObjectArray)) (local $temps (ref $ObjectArray))
    ref.null eq
    i32.const 20
    array.new $ObjectArray
    local.set $stack
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
    global.get $objectClass
    call $nextIdentityHash
    i32.const 14
    i32.const 14
    ref.null $SqueakObject
    local.get $slots
    local.get $vm
    struct.get $VirtualMachine 0
    i32.const 0
    i32.const 0
    local.get $method
    local.get $receiver
    local.get $args
    local.get $temps
    local.get $stack
    struct.new $Context
  )
  (func $smallIntegerForValue (;41;) (type 39) (param $value i32) (result (ref i31))
    local.get $value
    ref.i31
  )
  (func $valueOfSmallInteger (;42;) (type 20) (param $obj eqref) (result i32)
    local.get $obj
    ref.test (ref i31)
    if (result i32) ;; label = @1
      local.get $obj
      ref.cast (ref i31)
      i31.get_s
    else
      i32.const 0
    end
  )
  (func $isTranslated (;43;) (type 40) (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod 9
    i32.const 0
    i32.gt_u
  )
  (func $executeTranslatedMethod (;44;) (type 41) (param $context (ref null $Context)) (param $funcIndex i32) (result i32)
    local.get $context
    local.get $funcIndex
    call_indirect (type 20)
  )
  (func $triggerMethodTranslation (;45;) (type 42) (param $method (ref $CompiledMethod))
    (local $bytecodes (ref null $ByteArray)) (local $bytecodeLen i32) (local $functionIndexIndex i32) (local $memoryOffset i32)
    local.get $method
    struct.get $CompiledMethod 7
    local.tee $bytecodes
    ref.is_null
    if ;; label = @1
      return
    end
    local.get $bytecodes
    ref.as_non_null
    array.len
    local.set $bytecodeLen
    local.get $method
    call $translateMethod
  )
  (func $handleMethodReturn (;46;) (type 43) (param $vm (ref $VirtualMachine)) (param $context (ref null $Context)) (result eqref)
    (local $sender (ref null $Context)) (local $result eqref)
    local.get $context
    call $topOfStack
    local.set $result
    local.get $context
    struct.get $Context 6
    local.tee $sender
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get $sender
      ref.as_non_null
      local.get $result
      ref.as_non_null
      call $pushOnStack
      local.get $sender
      ref.as_non_null
      local.get $sender
      ref.as_non_null
      struct.get $Context 7
      i32.const 1
      i32.add
      struct.set $Context 7
    end
    local.get $sender
    ref.is_null
    if ;; label = @1
      ref.null $Context
      local.get $vm
      struct.set $VirtualMachine 0
    else
      local.get $sender
      ref.as_non_null
      local.get $vm
      struct.set $VirtualMachine 0
    end
    local.get $result
  )
  (func $initialize (;47;) (type 44) (result (ref $VirtualMachine))
    (local $vm (ref $VirtualMachine))
    struct.new $VirtualMachine
    local.set $vm
    local.get $vm
    call $createMinimalBootstrap
  )
  (func $createMinimalBootstrap (;48;) (type 45) (result i32)
    (local $vm (ref $VirtualMachine)) (local $workloadMethod (ref null $CompiledMethod)) (local $mainMethod (ref null $CompiledMethod)) (local $mainBytecodes (ref null $ByteArray)) (local $workloadBytecodes (ref null $ByteArray)) (local $workloadSelector (ref null $Symbol)) (local $methodDictionary (ref null $Dictionary)) (local $newObject (ref null $SqueakObject)) (local $slots (ref $ObjectArray)) (local $keys (ref $ObjectArray)) (local $values (ref $ObjectArray)) (local $emptyDict (ref $Dictionary)) (local $emptySymbol (ref $Symbol)) (local $emptyInstVarNames (ref $ObjectArray)) (local $workloadSlots (ref $ObjectArray))
    ref.null eq
    global.get $methodCacheSize
    array.new $ObjectArray
    ref.as_non_null
    local.get $vm
    struct.set $VirtualMachine 2
    global.get $objectClass
    call $nextIdentityHash
    i32.const 2
    i32.const 9
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    i32.const 0
    struct.new $Dictionary
    local.set $emptyDict
    global.get $objectClass
    call $nextIdentityHash
    i32.const 8
    i32.const 7
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    ref.null $ByteArray
    struct.new $Symbol
    local.set $emptySymbol
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    local.set $emptyInstVarNames
    ref.null $Class
    call $nextIdentityHash
    i32.const 1
    i32.const 11
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    ref.null $Class
    local.get $emptyDict
    local.get $emptyInstVarNames
    local.get $emptySymbol
    i32.const 0
    struct.new $Class
    local.set $newObject
    local.get $newObject
    ref.cast (ref null $Class)
    global.set $classClass
    global.get $classClass
    local.get $newObject
    ref.cast (ref null $Class)
    struct.set $Class 0
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 5
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    global.get $classClass
    call $nextIdentityHash
    i32.const 1
    i32.const 11
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    ref.null $Class
    local.get $emptyDict
    local.get $emptyInstVarNames
    local.get $emptySymbol
    i32.const 0
    struct.new $Class
    local.set $newObject
    local.get $vm
    struct.get $VirtualMachine 6
    local.get $newObject
    struct.set $SqueakObject 4
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    local.get $newObject
    ref.cast (ref null $Class)
    global.set $objectClass
    global.get $classClass
    call $nextIdentityHash
    i32.const 1
    i32.const 11
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    global.get $objectClass
    ref.cast (ref null $Class)
    local.get $emptyDict
    local.get $emptyInstVarNames
    local.get $emptySymbol
    i32.const 0
    struct.new $Class
    local.set $newObject
    local.get $vm
    struct.get $VirtualMachine 6
    ref.as_non_null
    local.get $newObject
    struct.set $SqueakObject 4
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    local.get $newObject
    ref.cast (ref null $Class)
    global.set $smallIntegerClass
    global.get $objectClass
    call $nextIdentityHash
    i32.const 2
    i32.const 9
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    ref.null eq
    i32.const 1
    array.new $ObjectArray
    ref.as_non_null
    ref.null eq
    i32.const 1
    array.new $ObjectArray
    ref.as_non_null
    i32.const 0
    struct.new $Dictionary
    local.set $newObject
    local.get $vm
    struct.get $VirtualMachine 6
    ref.as_non_null
    local.get $newObject
    struct.set $SqueakObject 4
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    local.get $newObject
    ref.cast (ref null $Dictionary)
    local.set $methodDictionary
    i32.const 112
    i32.const 208
    i32.const 124
    array.new_fixed $ByteArray 3
    local.set $mainBytecodes
    i32.const 112
    i32.const 33
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 34
    i32.const 176
    i32.const 35
    i32.const 184
    i32.const 35
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 33
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 34
    i32.const 176
    i32.const 35
    i32.const 184
    i32.const 35
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 33
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 34
    i32.const 176
    i32.const 35
    i32.const 184
    i32.const 35
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 33
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 34
    i32.const 176
    i32.const 35
    i32.const 184
    i32.const 35
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 33
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 34
    i32.const 176
    i32.const 35
    i32.const 184
    i32.const 35
    i32.const 176
    i32.const 34
    i32.const 184
    i32.const 124
    array.new_fixed $ByteArray 62
    local.set $workloadBytecodes
    global.get $objectClass
    call $nextIdentityHash
    i32.const 8
    i32.const 7
    ref.null $SqueakObject
    ref.null eq
    i32.const 0
    array.new $ObjectArray
    ref.as_non_null
    i32.const 119
    i32.const 111
    i32.const 114
    i32.const 107
    i32.const 108
    i32.const 111
    i32.const 97
    i32.const 100
    array.new_fixed $ByteArray 8
    struct.new $Symbol
    local.set $workloadSelector
    local.get $vm
    struct.get $VirtualMachine 6
    ref.as_non_null
    local.get $workloadSelector
    ref.as_non_null
    struct.set $SqueakObject 4
    local.get $workloadSelector
    ref.as_non_null
    local.get $vm
    struct.set $VirtualMachine 6
    ref.null eq
    i32.const 1
    array.new $ObjectArray
    local.set $slots
    local.get $slots
    i32.const 0
    local.get $workloadSelector
    ref.as_non_null
    array.set $ObjectArray
    global.get $objectClass
    call $nextIdentityHash
    i32.const 6
    i32.const 14
    ref.null $SqueakObject
    local.get $slots
    i32.const 0
    local.get $mainBytecodes
    i32.const 0
    i32.const 0
    global.get $translationThreshold
    i32.const 0
    struct.new $CompiledMethod
    local.set $newObject
    local.get $newObject
    ref.cast (ref null $CompiledMethod)
    local.set $mainMethod
    local.get $vm
    struct.get $VirtualMachine 6
    ref.as_non_null
    local.get $newObject
    struct.set $SqueakObject 4
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    ref.null eq
    i32.const 4
    array.new $ObjectArray
    ref.as_non_null
    local.set $workloadSlots
    local.get $workloadSlots
    i32.const 0
    i32.const 0
    call $smallIntegerForValue
    ref.as_non_null
    array.set $ObjectArray
    local.get $workloadSlots
    i32.const 1
    i32.const 1
    call $smallIntegerForValue
    ref.as_non_null
    array.set $ObjectArray
    local.get $workloadSlots
    i32.const 2
    i32.const 2
    call $smallIntegerForValue
    ref.as_non_null
    array.set $ObjectArray
    local.get $workloadSlots
    i32.const 3
    i32.const 3
    call $smallIntegerForValue
    ref.as_non_null
    array.set $ObjectArray
    global.get $objectClass
    call $nextIdentityHash
    i32.const 6
    i32.const 14
    ref.null $SqueakObject
    local.get $workloadSlots
    i32.const 0
    local.get $workloadBytecodes
    i32.const 0
    i32.const 0
    global.get $translationThreshold
    i32.const 0
    struct.new $CompiledMethod
    local.set $newObject
    local.get $newObject
    ref.cast (ref null $CompiledMethod)
    local.set $workloadMethod
    local.get $vm
    struct.get $VirtualMachine 6
    ref.as_non_null
    local.get $newObject
    struct.set $SqueakObject 4
    local.get $newObject
    local.get $vm
    struct.set $VirtualMachine 6
    global.get $smallIntegerClass
    ref.as_non_null
    local.get $methodDictionary
    ref.as_non_null
    struct.set $Class 7
    local.get $methodDictionary
    ref.as_non_null
    struct.get $Dictionary 6
    ref.as_non_null
    i32.const 0
    local.get $workloadSelector
    ref.as_non_null
    array.set $ObjectArray
    local.get $methodDictionary
    ref.as_non_null
    struct.get $Dictionary 7
    ref.as_non_null
    i32.const 0
    local.get $workloadMethod
    ref.as_non_null
    array.set $ObjectArray
    local.get $methodDictionary
    ref.as_non_null
    i32.const 1
    struct.set $Dictionary 8
    local.get $workloadMethod
    ref.as_non_null
    i32.const 1
    struct.set $CompiledMethod 11
    local.get $mainMethod
    global.set $mainMethod
    i32.const 1
  )
  (func $interpretBytecode (;49;) (type 46) (param $vm (ref $VirtualMachine)) (param $context (ref $Context)) (param $bytecode i32) (result i32)
    (local $receiver eqref) (local $value1 eqref) (local $value2 eqref) (local $int1 i32) (local $int2 i32) (local $result i32) (local $newContext (ref $Context)) (local $selector eqref) (local $method (ref $CompiledMethod)) (local $receiverClass (ref $Class)) (local $selectorIndex i32) (local $slots (ref $ObjectArray))
    local.get $bytecode
    i32.const 32
    i32.ge_u
    local.get $bytecode
    i32.const 47
    i32.le_u
    i32.and
    if ;; label = @1
      local.get $bytecode
      i32.const 32
      i32.sub
      local.set $selectorIndex
      local.get $context
      struct.get $Context 9
      ref.as_non_null
      struct.get $CompiledMethod 5
      ref.as_non_null
      local.tee $slots
      local.get $selectorIndex
      local.get $slots
      array.len
      i32.ge_u
      if ;; label = @2
        local.get $context
        i32.const 0
        call $smallIntegerForValue
        ref.as_non_null
        call $pushOnStack
      else
        local.get $context
        local.get $slots
        local.get $selectorIndex
        array.get $ObjectArray
        ref.as_non_null
        call $pushOnStack
      end
      i32.const 0
      return
    end
    local.get $bytecode
    i32.const 112
    i32.eq
    if ;; label = @1
      local.get $context
      local.get $context
      struct.get $Context 10
      ref.as_non_null
      call $pushOnStack
      i32.const 0
      return
    end
    local.get $bytecode
    i32.const 184
    i32.eq
    if ;; label = @1
      local.get $context
      call $popFromStack
      local.tee $value2
      ref.is_null
      if ;; label = @2
        i32.const 0
        return
      end
      local.get $context
      call $popFromStack
      local.tee $value1
      ref.is_null
      if ;; label = @2
        local.get $context
        local.get $value2
        ref.as_non_null
        call $pushOnStack
        i32.const 0
        return
      end
      local.get $value1
      call $valueOfSmallInteger
      local.set $int1
      local.get $value2
      call $valueOfSmallInteger
      local.set $int2
      local.get $int1
      local.get $int2
      i32.mul
      local.set $result
      local.get $context
      local.get $result
      call $smallIntegerForValue
      ref.as_non_null
      call $pushOnStack
      i32.const 0
      return
    end
    local.get $bytecode
    i32.const 176
    i32.eq
    if ;; label = @1
      local.get $context
      call $popFromStack
      local.tee $value2
      ref.is_null
      if ;; label = @2
        i32.const 0
        return
      end
      local.get $context
      call $popFromStack
      local.tee $value1
      ref.is_null
      if ;; label = @2
        local.get $context
        local.get $value2
        ref.as_non_null
        call $pushOnStack
        i32.const 0
        return
      end
      local.get $value1
      call $valueOfSmallInteger
      local.set $int1
      local.get $value2
      call $valueOfSmallInteger
      local.set $int2
      local.get $int1
      local.get $int2
      i32.add
      local.set $result
      local.get $context
      local.get $result
      call $smallIntegerForValue
      ref.as_non_null
      call $pushOnStack
      i32.const 0
      return
    end
    local.get $bytecode
    i32.const 124
    i32.eq
    if ;; label = @1
      i32.const 1
      return
    end
    local.get $bytecode
    i32.const 208
    i32.eq
    if ;; label = @1
      local.get $context
      call $popFromStack
      local.tee $receiver
      ref.is_null
      if ;; label = @2
        i32.const 0
        return
      end
      local.get $bytecode
      i32.const 15
      i32.and
      local.set $selectorIndex
      local.get $context
      struct.get $Context 9
      ref.as_non_null
      struct.get $CompiledMethod 5
      ref.as_non_null
      local.tee $slots
      local.get $selectorIndex
      local.get $slots
      array.len
      i32.ge_u
      if ;; label = @2
        local.get $context
        local.get $receiver
        ref.as_non_null
        call $pushOnStack
        i32.const 0
        return
      end
      local.get $slots
      local.get $selectorIndex
      array.get $ObjectArray
      local.set $selector
      local.get $receiver
      call $classOfObject
      local.set $receiverClass
      local.get $selector
      local.get $receiverClass
      call $lookupInCache
      local.tee $method
      ref.is_null
      if ;; label = @2
        local.get $receiver
        local.get $selector
        call $lookupMethod
        local.tee $method
        ref.is_null
        if ;; label = @3
          local.get $context
          local.get $receiver
          ref.as_non_null
          call $pushOnStack
          i32.const 0
          return
        end
        local.get $selector
        local.get $receiverClass
        local.get $method
        ref.as_non_null
        call $storeInCache
      end
      local.get $receiver
      local.get $method
      ref.as_non_null
      local.get $selector
      call $createMethodContext
      local.set $newContext
      local.get $newContext
      local.get $vm
      struct.set $VirtualMachine 0
      i32.const 0
      return
    end
    i32.const 0
  )
  (func $interpret (;50;) (type 45) (result i32)
    (local $vm (ref $VirtualMachine)) (local $context (ref $Context)) (local $method (ref $CompiledMethod)) (local $bytecode i32) (local $pc i32) (local $stack (ref $ObjectArray)) (local $slots (ref $ObjectArray)) (local $args (ref $ObjectArray)) (local $temps (ref $ObjectArray)) (local $receiver (ref eq)) (local $resultValue (ref eq)) (local $invocationCount i32) (local $bytecodes (ref $ByteArray)) (local $funcIndex i32)
    ref.null eq
    i32.const 20
    array.new $ObjectArray
    local.set $stack
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
    i32.const 100
    ref.i31
    local.set $receiver
    global.get $objectClass
    i32.const 2001
    i32.const 14
    i32.const 14
    ref.null $SqueakObject
    local.get $slots
    ref.null $Context
    i32.const 0
    i32.const 0
    global.get $mainMethod
    local.get $receiver
    local.get $args
    local.get $temps
    local.get $stack
    struct.new $Context
    local.get $vm
    struct.set $VirtualMachine 0
    block $finished
      loop $execution_loop
        local.get $vm
        struct.get $VirtualMachine 0
        local.tee $context
        ref.is_null
        if ;; label = @3
          br $finished
        end
        local.get $context
        ref.as_non_null
        struct.get $Context 9
        local.tee $method
        local.get $method
        struct.get $CompiledMethod 8
        i32.const 1
        i32.add
        local.set $invocationCount
        local.get $method
        local.get $invocationCount
        struct.set $CompiledMethod 8
        local.get $invocationCount
        local.get $method
        struct.get $CompiledMethod 10
        i32.eq
        local.get $vm
        struct.get $VirtualMachine 1
        i32.and
        if ;; label = @3
          local.get $method
          struct.get $CompiledMethod 11
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get $method
            ref.as_non_null
            call $isTranslated
            i32.eqz
            if ;; label = @5
              local.get $method
              ref.as_non_null
              call $triggerMethodTranslation
            end
          end
        end
        local.get $method
        ref.as_non_null
        call $isTranslated
        if ;; label = @3
          local.get $method
          struct.get $CompiledMethod 9
          local.set $funcIndex
          local.get $context
          ref.as_non_null
          local.get $funcIndex
          call $executeTranslatedMethod
          drop
          local.get $context
          ref.as_non_null
          call $handleMethodReturn
          local.set $resultValue
          br $execution_loop
        else
          local.get $method
          struct.get $CompiledMethod 7
          local.tee $bytecodes
          ref.is_null
          if ;; label = @4
            br $execution_loop
          end
          loop $interpreter_loop
            local.get $vm
            struct.get $VirtualMachine 0
            local.tee $context
            ref.is_null
            i32.eqz
            if ;; label = @5
              local.get $context
              ref.as_non_null
              struct.get $Context 7
              local.set $pc
              local.get $context
              ref.as_non_null
              struct.get $Context 9
              local.tee $method
              struct.get $CompiledMethod 7
              local.tee $bytecodes
              ref.as_non_null
              array.len
              local.get $pc
              i32.le_u
              if ;; label = @6
                local.get $context
                ref.as_non_null
                call $handleMethodReturn
                local.set $resultValue
                br $interpreter_loop
              end
              local.get $bytecodes
              ref.as_non_null
              local.get $pc
              array.get_u $ByteArray
              local.set $bytecode
              local.get $context
              ref.as_non_null
              local.get $bytecode
              call $interpretBytecode
              if ;; label = @6
                local.get $context
                ref.as_non_null
                call $handleMethodReturn
                local.set $resultValue
                br $interpreter_loop
              end
              local.get $vm
              struct.get $VirtualMachine 0
              local.get $context
              ref.eq
              if ;; label = @6
                local.get $context
                ref.as_non_null
                local.get $pc
                i32.const 1
                i32.add
                struct.set $Context 7
              else
                local.get $vm
                struct.get $VirtualMachine 0
                ref.as_non_null
                struct.get $Context 7
                i32.eqz
                if ;; label = @7
                  br $execution_loop
                end
              end
              br $interpreter_loop
            end
          end
        end
        local.get $resultValue
        call $valueOfSmallInteger
        call $reportResult
      end
    end
    i32.const 1
    return
  )
)
