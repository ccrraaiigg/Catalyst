(module
  (import "env" "getContextReceiver" (func $getContextReceiver (param eqref) (result eqref)))
  (import "env" "getContextLiteral" (func $getContextLiteral (param eqref) (param i32) (result eqref)))
  (import "env" "extractIntegerValue" (func $extractIntegerValue (param eqref) (result i32)))
  (import "env" "createSmallInteger" (func $createSmallInteger (param i32) (result eqref)))
  (import "env" "pushOnStack" (func $pushOnStack (param eqref)))
  
  (func $jit_method_0 (param $context eqref) (result i32)
  (local $receiver_int i32)
  (local $lit1_int i32)
  (local $lit2_int i32)
  (local $lit3_int i32)
  (local $result i32)
  
  ;; Extract integer values from receiver and literals
  (local.set $receiver_int 
    (call $extractIntegerValue 
      (call $getContextReceiver (local.get $context))))
  
  (local.set $lit1_int
    (call $extractIntegerValue
      (call $getContextLiteral (i32.const 1))))
      
  (local.set $lit2_int
    (call $extractIntegerValue
      (call $getContextLiteral (i32.const 2))))
      
  (local.set $lit3_int
    (call $extractIntegerValue
      (call $getContextLiteral (i32.const 3))))

  ;; Compute ((((receiver + lit1) * lit2 + lit2) * lit3 + lit3) * lit2)
  (local.set $result
    (i32.mul
      (i32.add
        (i32.mul
          (i32.add
            (i32.mul
              (i32.add
                (local.get $receiver_int)
                (local.get $lit1_int))
              (local.get $lit2_int))
            (local.get $lit2_int))
          (local.get $lit3_int))
        (local.get $lit3_int))
      (local.get $lit2_int)))

  ;; Do it 4 more times
  (local.set $result
    (i32.mul
      (i32.add
        (i32.mul
          (i32.add
            (i32.mul
              (i32.add
                (local.get $result)
                (local.get $lit1_int))
              (local.get $lit2_int))
            (local.get $lit2_int))
          (local.get $lit3_int))
        (local.get $lit3_int))
      (local.get $lit2_int)))

  (local.set $result
    (i32.mul
      (i32.add
        (i32.mul
          (i32.add
            (i32.mul
              (i32.add
                (local.get $result)
                (local.get $lit1_int))
              (local.get $lit2_int))
            (local.get $lit2_int))
          (local.get $lit3_int))
        (local.get $lit3_int))
      (local.get $lit2_int)))

  (local.set $result
    (i32.mul
      (i32.add
        (i32.mul
          (i32.add
            (i32.mul
              (i32.add
                (local.get $result)
                (local.get $lit1_int))
              (local.get $lit2_int))
            (local.get $lit2_int))
          (local.get $lit3_int))
        (local.get $lit3_int))
      (local.get $lit2_int)))

  (local.set $result
    (i32.mul
      (i32.add
        (i32.mul
          (i32.add
            (i32.mul
              (i32.add
                (local.get $result)
                (local.get $lit1_int))
              (local.get $lit2_int))
            (local.get $lit2_int))
          (local.get $lit3_int))
        (local.get $lit3_int))
      (local.get $lit2_int)))

  ;; Push final result as a SmallInteger
  (call $pushOnStack
    (call $createSmallInteger
      (local.get $result)))
  i32.const 1
)
  
  (export "jit_method_0" (func $jit_method_0))
)
