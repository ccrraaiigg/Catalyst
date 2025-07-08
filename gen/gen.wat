(module
  (import "env" "getContextReceiver" (func $getContextReceiver (param eqref) (result eqref)))
  (import "env" "getContextLiteral" (func $getContextLiteral (param eqref) (param i32) (result eqref)))
  (import "env" "extractIntegerValue" (func $extractIntegerValue (param eqref) (result i32)))
  (import "env" "createSmallInteger" (func $createSmallInteger (param i32) (result eqref)))
  (import "env" "pushOnStack" (func $pushOnStack (param eqref)))
  
  (func $jit_method_0 (param $context eqref) (result i32)
  (local $receiver eqref)
  (local $receiverInt i32)
  (local $temp i32)
  
  ;; Get receiver and convert to int
  local.get $context
  call $getContextReceiver
  local.tee $receiver
  call $extractIntegerValue
  local.set $receiverInt
  
  ;; Calculate ((((receiver + 1) * 2 + 2) * 3 + 3) * 2 + 1) * 2...
  ;; repeated 5 times
  local.get $receiverInt
  i32.const 1
  i32.add
  i32.const 2
  i32.mul
  i32.const 2
  i32.add
  i32.const 3
  i32.mul
  i32.const 3
  i32.add
  i32.const 2
  i32.mul
  i32.const 1
  i32.add
  i32.const 2
  i32.mul
  i32.const 2
  i32.add
  i32.const 3
  i32.mul
  i32.const 3
  i32.add
  i32.const 2
  i32.mul
  i32.const 1
  i32.add
  i32.const 2
  i32.mul
  i32.const 2
  i32.add
  i32.const 3
  i32.mul
  i32.const 3
  i32.add
  i32.const 2
  i32.mul
  i32.const 1
  i32.add
  i32.const 2
  i32.mul
  i32.const 2
  i32.add
  i32.const 3
  i32.mul
  i32.const 3
  i32.add
  i32.const 2
  i32.mul
  i32.const 1
  i32.add
  i32.const 2
  i32.mul
  i32.const 2
  i32.add
  i32.const 3
  i32.mul
  i32.const 3
  i32.add
  i32.const 2
  i32.mul
  
  ;; Convert result back to Smalltalk integer and push to stack
  call $createSmallInteger
  call $pushOnStack

  i32.const 1
)
)
