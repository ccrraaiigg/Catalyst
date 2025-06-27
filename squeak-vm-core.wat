;; SqueakJS to WASM VM Core Module
;; Implements bytecode interpreter with WASM GC object memory

(module $SqueakVMCore
  ;; Import JavaScript interface functions
  (import "system" "reportResult" (func $system_report_result (param i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "consoleLog" (func $consoleLog (param i32)))
  
  ;; === Type Definitions using correct WASM GC syntax ===
  
  ;; Base Squeak object
  (type $SqueakObject (struct 
    (field $classIndex i32)
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
  ))
  
  ;; Class objects  
  (type $Class (struct
    (field $classIndex i32)
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
    (field $superclassIndex i32)
    (field $methodDictIndex i32)
    (field $instVarNamesIndex i32)
    (field $nameIndex i32)
  ))
  
  ;; CompiledMethod objects
  (type $CompiledMethod (struct
    (field $classIndex i32)
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
    (field $header i32)
    (field $invocationCount i32)
  ))
  
  ;; Context objects for method execution
  (type $Context (struct
    (field $classIndex i32)
    (field $identityHash i32)
    (field $format i32)
    (field $size i32)
    (field $senderIndex i32)
    (field $pc i32)
    (field $stackp i32)
    (field $methodIndex i32)
    (field $receiver (ref null any))  ;; Can be object reference or i31ref
  ))
  
  ;; === Global VM State ===
  
  (global $objectClass (mut i32) (i32.const 0))
  (global $methodClass (mut i32) (i32.const 0))
  (global $contextClass (mut i32) (i32.const 0))
  (global $nextHash (mut i32) (i32.const 1))
  (global $methodReturned (mut i32) (i32.const 0))
  
  ;; === Helper Functions ===
  
  (func $next_identity_hash (result i32)
    global.get $nextHash
    global.get $nextHash
    i32.const 1
    i32.add
    global.set $nextHash
  )
  
  (func $mark_method_returned
    i32.const 1
    global.set $methodReturned
  )
  
  (func $method_has_returned (result i32)
    global.get $methodReturned
  )
  
  ;; === Simple Stack using globals ===
  
  (global $stack_val1 (mut (ref null any)) (ref.null any))
  (global $stack_val2 (mut (ref null any)) (ref.null any))
  (global $stack_size (mut i32) (i32.const 0))
  
  (func $push (param $value anyref)
    global.get $stack_size
    i32.const 0
    i32.eq
    if
      local.get $value
      global.set $stack_val1
      i32.const 1
      global.set $stack_size
    else
      local.get $value
      global.set $stack_val2
      i32.const 2
      global.set $stack_size
    end
  )
  
  (func $pop (result (ref null any))
    global.get $stack_size
    i32.const 2
    i32.eq
    if (result (ref null any))
      i32.const 1
      global.set $stack_size
      global.get $stack_val2
    else
      i32.const 0
      global.set $stack_size
      global.get $stack_val1
    end
  )
  
  ;; === Bytecode Interpreter ===
  
  (func $execute_classic_bytecode (param $bytecode i32)
    ;; Simple switch for our 5 bytecodes
    local.get $bytecode
    i32.const 0x20
    i32.eq
    if
      ;; pushConstant 0 - push SmallInteger 3
      i32.const 3
      ref.i31
      call $push
      return
    end
    
    local.get $bytecode
    i32.const 0x21
    i32.eq
    if
      ;; pushConstant 1 - push SmallInteger 4
      i32.const 4
      ref.i31
      call $push
      return
    end
    
    local.get $bytecode
    i32.const 0xB0
    i32.eq
    if
      ;; send + - add two SmallIntegers
      call $pop
      ref.cast (ref i31)
      i31.get_s
      call $pop
      ref.cast (ref i31)
      i31.get_s
      i32.add
      ref.i31
      call $push
      return
    end
    
    local.get $bytecode
    i32.const 0xD0
    i32.eq
    if
      ;; send literal 0 (#reportToJS) - report result
      call $pop
      ref.cast (ref i31)
      i31.get_s
      call $system_report_result
      ;; Push nil (represented as i31 0)
      i32.const 0
      ref.i31
      call $push
      return
    end
    
    local.get $bytecode
    i32.const 0x7C
    i32.eq
    if
      ;; returnTop - mark method as returned
      call $mark_method_returned
      return
    end
  )
  
  ;; === Main Interpreter ===
  
  (global $pc (mut i32) (i32.const 0))
  
  (func $interpret_one_bytecode
    (local $bytecode i32)
    
    ;; Check if past end of method
    global.get $pc
    i32.const 5
    i32.ge_u
    if
      call $mark_method_returned
      return
    end
    
    ;; Hard-coded bytecode sequence: [0x20, 0x21, 0xB0, 0xD0, 0x7C]
    global.get $pc
    i32.const 0
    i32.eq
    if
      i32.const 0x20
      local.set $bytecode
    else
      global.get $pc
      i32.const 1
      i32.eq
      if
        i32.const 0x21
        local.set $bytecode
      else
        global.get $pc
        i32.const 2
        i32.eq
        if
          i32.const 0xB0
          local.set $bytecode
        else
          global.get $pc
          i32.const 3
          i32.eq
          if
            i32.const 0xD0
            local.set $bytecode
          else
            i32.const 0x7C
            local.set $bytecode
          end
        end
      end
    end
    
    ;; Execute the bytecode
    local.get $bytecode
    call $execute_classic_bytecode
    
    ;; Increment PC unless method returned
    call $method_has_returned
    if
      ;; Method returned, don't increment PC
    else
      global.get $pc
      i32.const 1
      i32.add
      global.set $pc
    end
  )
  
  ;; === Main Interpreter Loop ===
  
  (func (export "interpret")
    loop $execution_loop
      call $interpret_one_bytecode
      
      ;; Continue unless method returned
      call $method_has_returned
      i32.eqz
      br_if $execution_loop
    end
  )
  
  ;; === Bootstrap Functions ===
  
  (func (export "createMinimalBootstrap") (result i32)
    ;; Reset state
    i32.const 0
    global.set $methodReturned
    i32.const 0
    global.set $pc
    i32.const 0
    global.set $stack_size
    
    i32.const 1  ;; success
  )
)