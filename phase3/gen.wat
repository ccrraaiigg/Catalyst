(module
  ;; Import required functions from the main VM using eqref for all reference types
  (import "env" "pushOnStack" (func $pushOnStack (param eqref)))
  (import "env" "popFromStack" (func $popFromStack (param eqref) (result eqref)))
  (import "env" "extractIntegerValue" (func $extractIntegerValue (param eqref) (result i32)))
  (import "env" "createSmallInteger" (func $createSmallInteger (param i32) (result eqref)))
  (import "env" "getClass" (func $getClass (param eqref) (result eqref)))
  (import "env" "lookupInCache" (func $lookupInCache (param eqref) (result eqref)))
  (import "env" "lookupMethod" (func $lookupMethod (param eqref) (result eqref)))
  (import "env" "storeInCache" (func $storeInCache (param eqref eqref)))
  (import "env" "createMethodContext" (func $createMethodContext (param eqref) (result eqref)))
  (import "env" "interpretBytecode" (func $interpretBytecode (param eqref i32) (result i32)))
  (import "env" "setActiveContext" (func $setActiveContext (param eqref)))
  (import "env" "getContextReceiver" (func $getContextReceiver (param eqref) (result eqref)))
  (import "env" "getContextMethod" (func $getContextMethod (param eqref) (result eqref)))
  (import "env" "getCompiledMethodSlots" (func $getCompiledMethodSlots (param eqref) (result eqref)))
  (import "env" "getObjectArrayElement" (func $getObjectArrayElement (param eqref i32) (result eqref)))
  (import "env" "debugLog" (func $debugLog (param i32 i32 i32)))

  ;; JIT function with EXPLICIT signature - no type references
  (func $jit_method_0 (param $ctx eqref) (result i32)
  (local $receiver_value i32)
  (local $result i32)
  
  (local.set $receiver_value 
    (call $extractIntegerValue 
      (call $getContextReceiver (local.get $ctx))))
  
  (local.set $result 
    (i32.add (local.get $receiver_value) (i32.const 1)))
    
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  (local.set $result (i32.add (local.get $result) (i32.const 2)))
  (local.set $result (i32.mul (local.get $result) (i32.const 3)))
  (local.set $result (i32.add (local.get $result) (i32.const 3)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  
  (local.set $result (i32.add (local.get $result) (i32.const 1)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  (local.set $result (i32.add (local.get $result) (i32.const 2)))
  (local.set $result (i32.mul (local.get $result) (i32.const 3)))
  (local.set $result (i32.add (local.get $result) (i32.const 3)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  
  (local.set $result (i32.add (local.get $result) (i32.const 1)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  (local.set $result (i32.add (local.get $result) (i32.const 2)))
  (local.set $result (i32.mul (local.get $result) (i32.const 3)))
  (local.set $result (i32.add (local.get $result) (i32.const 3)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  
  (local.set $result (i32.add (local.get $result) (i32.const 1)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  (local.set $result (i32.add (local.get $result) (i32.const 2)))
  (local.set $result (i32.mul (local.get $result) (i32.const 3)))
  (local.set $result (i32.add (local.get $result) (i32.const 3)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  
  (local.set $result (i32.add (local.get $result) (i32.const 1)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  (local.set $result (i32.add (local.get $result) (i32.const 2)))
  (local.set $result (i32.mul (local.get $result) (i32.const 3)))
  (local.set $result (i32.add (local.get $result) (i32.const 3)))
  (local.set $result (i32.mul (local.get $result) (i32.const 2)))
  
  (call $pushOnStack 
    (call $createSmallInteger (local.get $result)))
  
  ;; Return success status
  (i32.const 0))
(export "jit_method_0" (func $jit_method_0))
)
