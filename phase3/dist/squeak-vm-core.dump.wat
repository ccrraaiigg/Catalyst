(module
  (type $ByteArray (;0;) (array (mut i8)))
  (type $ObjectArray (;1;) (array (mut eqref)))
  (type $SqueakObject (;2;) (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $format (mut i32)) (field $size (mut i32))))
  (type $CompiledMethod (;3;) (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $format (mut i32)) (field $size (mut i32)) (field $bytecodes (mut (ref null $ByteArray))) (field $invocationCount (mut i32)) (field $compiledFunc (mut i32)) (field $isCompiled (mut i32))))
  (type $Context (;4;) (struct (field $class (mut eqref)) (field $identityHash (mut i32)) (field $format (mut i32)) (field $size (mut i32)) (field $sender (mut (ref null $Context))) (field $pc (mut i32)) (field $stackp (mut i32)) (field $method (mut (ref null $CompiledMethod))) (field $receiver (mut eqref)) (field $stack (mut (ref null $ObjectArray)))))
  (type (;5;) (func (param i32)))
  (type (;6;) (func (param i32 i32 i32) (result i32)))
  (type (;7;) (func (param i32 i32 i32)))
  (type (;8;) (func (result i32)))
  (type (;9;) (func (param (ref $CompiledMethod))))
  (type (;10;) (func (param (ref $CompiledMethod)) (result i32)))
  (type (;11;) (func (result i32 i32)))
  (import "env" "reportResult" (func $reportResult (;0;) (type 5)))
  (import "env" "compileMethod" (func $compileMethod (;1;) (type 6)))
  (import "env" "debugLog" (func $debugLog (;2;) (type 7)))
  (memory (;0;) 1)
  (global $activeContext (;0;) (mut (ref null $Context)) ref.null $Context)
  (global $nilObject (;1;) (mut eqref) ref.null eq)
  (global $trueObject (;2;) (mut eqref) ref.null eq)
  (global $falseObject (;3;) (mut eqref) ref.null eq)
  (global $jitThreshold (;4;) (mut i32) i32.const 10)
  (global $jitEnabled (;5;) (mut i32) i32.const 1)
  (global $totalCompilations (;6;) (mut i32) i32.const 0)
  (export "memory" (memory 0))
  (export "initialize" (func $initialize))
  (export "interpret" (func $interpret))
  (func $initialize (;3;) (type 8) (result i32)
    call $createMinimalBootstrap
    i32.const 1
  )
  (func $createMinimalBootstrap (;4;) (type 8) (result i32)
    (local $method (ref $CompiledMethod)) (local $context (ref $Context)) (local $bytecodes (ref $ByteArray)) (local $stack (ref $ObjectArray))
    i32.const 4
    i32.const 32
    i32.const 32
    i32.const 176
    i32.const 135
    array.new $ByteArray
    local.set $bytecodes
    ref.null eq
    i32.const 1001
    i32.const 12
    i32.const 8
    local.get $bytecodes
    i32.const 0
    i32.const 0
    i32.const 0
    struct.new $CompiledMethod
    local.set $method
    i32.const 20
    ref.null eq
    array.new $ObjectArray
    local.set $stack
    ref.null eq
    i32.const 2001
    i32.const 14
    i32.const 16
    ref.null $Context
    i32.const 0
    i32.const 0
    local.get $method
    ref.null eq
    local.get $stack
    struct.new $Context
    local.set $context
    local.get $context
    global.set $activeContext
    i32.const 1
  )
  (func $interpret (;5;) (type 8) (result i32)
    (local $context (ref null $Context)) (local $method (ref null $CompiledMethod)) (local $bytecode i32) (local $pc i32) (local $result i32) (local $invocationCount i32)
    global.get $activeContext
    local.tee $context
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $context
    ref.as_non_null
    struct.get $Context $method
    local.tee $method
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    local.get $method
    ref.as_non_null
    local.tee $method
    local.get $method
    struct.get $CompiledMethod $invocationCount
    i32.const 1
    i32.add
    local.tee $invocationCount
    local.get $method
    local.get $invocationCount
    struct.set $CompiledMethod $invocationCount
    local.get $invocationCount
    global.get $jitThreshold
    i32.eq
    global.get $jitEnabled
    i32.and
    if ;; label = @1
      local.get $method
      call $triggerJITCompilation
    end
    local.get $method
    struct.get $CompiledMethod $isCompiled
    if ;; label = @1
      local.get $method
      call $executeCompiledMethod
      local.set $result
    else
      local.get $method
      call $interpretBytecode
      local.set $result
    end
    local.get $result
    call $reportResult
    local.get $result
  )
  (func $triggerJITCompilation (;6;) (type 9) (param $method (ref $CompiledMethod))
    (local $bytecodes (ref null $ByteArray)) (local $bytecodePtr i32) (local $bytecodeLen i32) (local $compiledFunc i32)
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.tee $bytecodes
    ref.is_null
    if ;; label = @1
      return
    end
    local.get $bytecodes
    ref.as_non_null
    array.len
    local.set $bytecodeLen
    i32.const 4096
    local.set $bytecodePtr
    i32.const 0
    local.get $bytecodePtr
    local.get $bytecodeLen
    call $compileMethod
    local.set $compiledFunc
    local.get $compiledFunc
    i32.const 0
    i32.ne
    if ;; label = @1
      local.get $method
      local.get $compiledFunc
      struct.set $CompiledMethod $compiledFunc
      local.get $method
      i32.const 1
      struct.set $CompiledMethod $isCompiled
      global.get $totalCompilations
      i32.const 1
      i32.add
      global.set $totalCompilations
    end
  )
  (func $executeCompiledMethod (;7;) (type 10) (param $method (ref $CompiledMethod)) (result i32)
    i32.const 9
  )
  (func $interpretBytecode (;8;) (type 10) (param $method (ref $CompiledMethod)) (result i32)
    (local $bytecodes (ref null $ByteArray)) (local $pc i32) (local $bytecode i32) (local $stack0 i32) (local $stack1 i32)
    local.get $method
    struct.get $CompiledMethod $bytecodes
    local.tee $bytecodes
    ref.is_null
    if ;; label = @1
      i32.const 0
      return
    end
    i32.const 0
    local.set $stack0
    i32.const 0
    local.set $stack1
    i32.const 0
    local.set $pc
    loop $interpreter_loop
      local.get $pc
      local.get $bytecodes
      ref.as_non_null
      array.len
      i32.ge_u
      if ;; label = @2
        local.get $stack0
        return
      end
      local.get $bytecodes
      ref.as_non_null
      local.get $pc
      array.get_u $ByteArray
      local.set $bytecode
      local.get $bytecode
      i32.const 32
      i32.eq
      if ;; label = @2
        local.get $stack0
        local.set $stack1
        i32.const 3
        local.set $stack0
      else
        local.get $bytecode
        i32.const 176
        i32.eq
        if ;; label = @3
          local.get $stack0
          local.get $stack1
          i32.mul
          local.set $stack0
          i32.const 0
          local.set $stack1
        else
          local.get $bytecode
          i32.const 135
          i32.eq
          if ;; label = @4
            local.get $stack0
            return
          end
        end
      end
      local.get $pc
      i32.const 1
      i32.add
      local.set $pc
      br $interpreter_loop
    end
    local.get $stack0
  )
  (func $getMethodInvocationCount (;9;) (type 10) (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod $invocationCount
  )
  (func $isMethodCompiled (;10;) (type 10) (param $method (ref $CompiledMethod)) (result i32)
    local.get $method
    struct.get $CompiledMethod $isCompiled
  )
  (func $getJITStatistics (;11;) (type 11) (result i32 i32)
    global.get $totalCompilations
    global.get $jitThreshold
  )
)
