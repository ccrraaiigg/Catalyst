# SqueakJS to WASM with Bytecode JIT and Minimal Object Memory

## Squeak Snapshot Compatibility and Minimal Bootstrap

### Snapshot Resume Architecture

The VM must be able to resume any existing Squeak snapshot, including:
- **Classic bytecode sets** (Blue Book, Closure, etc.)
- **Sista instruction set** from Cog VM
- **Multi-process environments** with scheduler state
- **Mid-snapshot processes** that were creating/resuming snapshots

### WASM GC Object Memory Compatible with Squeak Format

```wat
;; Squeak-compatible object header using WASM GC
(type $SqueakObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)    ;; Squeak object format (0-31)
  (field $size i32)      ;; Object size for GC coordination
))

;; Variable objects (most Squeak objects) - can contain SmallIntegers as i31refs
(type $VariableObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $slots (ref array (ref null anyref)))  ;; Both inst vars and indexable fields
))

;; Byte objects (Strings, ByteArrays, etc.)
(type $ByteObject (struct
  (field $class (ref $Class))
  (field $identityHash i32) 
  (field $format i32)
  (field $size i32)
  (field $bytes (ref array i8))
))

;; Word objects (Bitmaps, etc.)
(type $WordObject (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32) 
  (field $size i32)
  (field $words (ref array i32))
))

;; CompiledMethod with support for both classic and Sista bytecodes
(type $CompiledMethod (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $header i32)           ;; Method header with primitive, args, temps
  (field $literals (ref array (ref null anyref)))  ;; Can contain objects or i31refs
  (field $bytecodes (ref array i8))
  (field $sistaFlag i32)        ;; 0 = classic, 1 = Sista
  (field $compiledWasm (ref null func))  ;; JIT compiled version
  (field $invocationCount i32)  ;; For JIT heuristics
))

;; SmallInteger object type for immediate integers
(type $SmallIntegerObject (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $value i32)  ;; The actual integer value
))
(type $Process (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $nextLink (ref null $Process))
  (field $suspendedContext (ref null $Context))
  (field $priority i32)
  (field $myList (ref null $SqueakObject))  ;; Semaphore or ProcessorScheduler
  (field $threadId i32)         ;; For future threading support
))

;; Context object matching Squeak format exactly
(type $Context (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $format i32)
  (field $size i32)
  (field $sender (ref null $Context))
  (field $pc i32)
  (field $stackp i32)
  (field $method (ref $CompiledMethod))
  (field $closureOrNil (ref null anyref))  ;; Can be object or i31ref
  (field $receiver (ref null anyref))     ;; Can be object or i31ref (SmallInteger)
  ;; Stack and temps stored in variable part - can contain objects or i31refs
  (field $stackAndTemps (ref array (ref null anyref)))
))
```

### Snapshot Loading and Object Memory Reconstruction

```wat
;; Load and resume existing Squeak snapshot
(func (export "loadSnapshot") (param $snapshotData (ref array i8)) (result i32)
  (local $objectMemory (ref array (ref null $SqueakObject)))
  (local $specialObjects (ref array (ref null $SqueakObject)))
  (local $activeProcess (ref null $Process))
  (local $scheduler (ref null $SqueakObject))
  
  ;; Parse snapshot header
  local.get $snapshotData
  call $parse_snapshot_header
  
  ;; Reconstruct object memory from snapshot data
  ;; Squeak snapshots contain objects with OOPs (Object-Oriented Pointers)
  ;; that reference other objects by index
  local.get $snapshotData
  call $reconstruct_objects_from_snapshot
  local.set $objectMemory
  
  ;; Extract special objects array (first special object)
  local.get $objectMemory
  call $get_special_objects_array
  local.tee $specialObjects
  global.set $specialObjects
  
  ;; Find processor scheduler from special objects
  local.get $specialObjects
  call $get_processor_scheduler
  local.set $scheduler
  
  ;; Find active process
  local.get $scheduler
  call $get_active_process
  local.tee $activeProcess
  global.set $activeProcess
  
  ;; Restore active context
  local.get $activeProcess
  struct.get $Process 5  ;; suspendedContext field
  global.set $activeContext
  
  ;; Initialize method cache for this image
  call $initialize_method_cache
  
  ;; Initialize JIT cache
  call $initialize_jit_cache
  
  i32.const 1  ;; success
)

;; Reconstruct objects from Squeak snapshot format
(func $reconstruct_objects_from_snapshot (param $snapshotData (ref array i8)) (result (ref array (ref null $SqueakObject)))
  (local $objectCount i32)
  (local $objects (ref array (ref null $SqueakObject)))
  (local $i i32)
  (local $oop i32)
  (local $objectData (ref array i8))
  
  ;; Read object count from snapshot
  local.get $snapshotData
  call $read_object_count
  local.set $objectCount
  
  ;; Allocate object array
  local.get $objectCount
  ref.null $SqueakObject
  array.new
  local.set $objects
  
  ;; First pass: create all objects with headers
  i32.const 0
  local.set $i
  loop $create_objects
    local.get $snapshotData
    local.get $i
    call $read_object_data
    local.get $objects
    local.get $i
    call $create_object_from_data
    
    local.get $i
    i32.const 1
    i32.add
    local.tee $i
    local.get $objectCount
    i32.lt_u
    br_if $create_objects
  end
  
  ;; Second pass: resolve OOP references between objects
  i32.const 0
  local.set $i
  loop $resolve_references
    local.get $objects
    local.get $i
    call $resolve_object_references
    
    local.get $i
    i32.const 1
    i32.add
    local.tee $i
    local.get $objectCount
    i32.lt_u
    br_if $resolve_references
  end
  
  local.get $objects
)
```

### Simple Method Return - No Exceptions Needed

```wat
;; Method execution with simple return semantics
(func $execute_method (param $method (ref $CompiledMethod)) (param $receiver (ref null $SqueakObject))
  (local $context (ref $Context))
  (local $result (ref null $SqueakObject))
  
  ;; Create new context for method
  local.get $method
  local.get $receiver
  call $create_method_context
  local.set $context
  
  ;; Set as active context
  local.get $context
  global.set $activeContext
  
  ;; Execute bytecodes until method returns
  loop $execution_loop
    call $interpret_one_bytecode
    
    ;; Check if method returned (pc beyond method end or explicit return)
    call $method_has_returned
    br_if $execution_loop
  end
  
  ;; Method completed - result is on stack top
  ;; Calling context will find return value on stack
)

;; Simple bytecode execution without exceptions
(func $execute_classic_bytecode (param $bytecode i32)
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... all classic bytecodes
    block $case120  ;; returnTop
    block $case118  ;; pushConstant 4
    block $case117  ;; pushConstant 3
    block $case176  ;; send +
    ;; ... more cases
    block $case1
    block $case0
      br_table $case0 $case1 ... $case176 $case117 $case118 $case120 ... $case255 $end
    end $case0
    ;; pushInstVar 0
    call $push_instance_variable_0
    br $end
    
    end $case0x20
    ;; pushConstant 0 - push literal 1 (3)
    call $get_method
    i32.const 1  ;; literal index 1
    call $push_literal
    br $end
    
    end $case0x21
    ;; pushConstant 1 - push literal 2 (4)
    call $get_method
    i32.const 2  ;; literal index 2
    call $push_literal
    br $end
    
    end $case0x7C
    ;; returnTop - just mark method as returned
    call $mark_method_returned
    br $end
    
    end $case0xB0
    ;; send + (special arithmetic selector) - directly perform addition
    ;; Pop two arguments and add them
    call $pop  ;; second operand (4)
    call $pop  ;; first operand (3)
    
    ;; For now, assume they are SmallIntegers and add them directly
    ;; TODO: Add proper type checking and overflow handling
    local.get 0  ;; first operand
    call $small_int_value
    local.get 1  ;; second operand  
    call $small_int_value
    i32.add
    
    ;; Convert result back to SmallInteger and push
    call $make_small_integer
    call $push
    br $end
    
    end $case0xD0
    ;; send literal 0 (#reportToJS)
    ;; This needs to call out to JavaScript to report the result
    call $pop  ;; get the result (7)
    call $report_to_javascript
    
    ;; Push nil as the return value
    call $get_nil_object
    call $push
    br $end
    
    ;; ... more bytecode implementations
  end
)

;; Mark method as returned (simple flag)
(func $mark_method_returned
  global.get $activeContext
  i32.const 1
  call $set_context_returned_flag
)

;; Check if current method has returned
(func $method_has_returned (result i32)
  global.get $activeContext
  call $get_context_returned_flag
)
```

### JIT Compilation Based on Method Invocation Count

```wat
;; Method invocation with JIT compilation tracking
(func $invoke_method (param $method (ref $CompiledMethod)) (param $receiver (ref null $SqueakObject))
  (local $invocationCount i32)
  
  ;; Increment method invocation count
  local.get $method
  local.get $method
  struct.get $CompiledMethod 9  ;; invocationCount field
  i32.const 1
  i32.add
  local.tee $invocationCount
  struct.set $CompiledMethod 9
  
  ;; Check if method should be JIT compiled
  local.get $invocationCount
  i32.const 50  ;; JIT threshold: method called 50 times
  i32.eq
  if
    local.get $method
    call $jit_compile_method
  end
  
  ;; Check if method has JIT compiled version
  local.get $method
  struct.get $CompiledMethod 8  ;; compiledWasm field
  ref.is_null
  if
    ;; Interpret bytecodes
    local.get $method
    local.get $receiver
    call $execute_method
  else
    ;; Call JIT compiled version
    local.get $method
    struct.get $CompiledMethod 8
    local.get $receiver
    call_ref
  end
)

;; JIT compilation decision based purely on invocation count
(func $should_jit_compile (param $method (ref $CompiledMethod)) (result i32)
  (local $invocationCount i32)
  (local $bytecodeLength i32)
  
  local.get $method
  struct.get $CompiledMethod 9  ;; invocationCount field
  local.set $invocationCount
  
  local.get $method
  struct.get $CompiledMethod 6  ;; bytecodes field
  array.len
  local.set $bytecodeLength
  
  ;; JIT compile if called enough times and not too large
  local.get $invocationCount
  i32.const 50  ;; threshold: 50 method invocations
  i32.ge_u
  
  local.get $bytecodeLength
  i32.const 200  ;; max bytecode length for JIT
  i32.le_u
  
  i32.and
)
```

### Class Hierarchy Through Superclass Links - No Global Table

```wat
;; Find class in hierarchy starting from Object class
(func $find_class_by_name (param $className (ref string)) (result (ref null $Class))
  (local $objectClass (ref $Class))
  (local $result (ref null $Class))
  
  ;; Get Object class from special objects
  global.get $specialObjects
  call $get_object_class
  local.set $objectClass
  
  ;; Search class hierarchy starting from Object
  local.get $objectClass
  local.get $className
  call $search_class_hierarchy
)

;; Recursively search class hierarchy through subclasses
(func $search_class_hierarchy (param $class (ref $Class)) (param $className (ref string)) (result (ref null $Class))
  (local $subclasses (ref null $SqueakObject))
  (local $i i32)
  (local $subclass (ref null $Class))
  (local $result (ref null $Class))
  
  ;; Check if this class matches
  local.get $class
  struct.get $Class 6  ;; name field
  local.get $className
  call $string_equals
  if (result (ref null $Class))
    local.get $class
  else
    ;; Search subclasses
    local.get $class
    call $get_subclasses_array
    local.tee $subclasses
    ref.is_null
    if (result (ref null $Class))
      ref.null $Class
    else
      ;; Iterate through subclasses
      i32.const 0
      local.set $i
      loop $search_subclasses
        local.get $subclasses
        ref.cast $VariableObject
        struct.get $VariableObject 4  ;; slots field
        local.get $i
        array.get
        local.tee $subclass
        ref.is_null
        if
          ;; Continue to next subclass
        else
          ;; Recursively search this subclass
          local.get $subclass
          ref.cast $Class
          local.get $className
          call $search_class_hierarchy
          local.tee $result
          ref.is_null
          if
            ;; Not found in this branch, continue
          else
            ;; Found it!
            local.get $result
            return
          end
        end
        
        local.get $i
        i32.const 1
        i32.add
        local.tee $i
        
        local.get $subclasses
        ref.cast $VariableObject
        struct.get $VariableObject 4
        array.len
        i32.lt_u
        br_if $search_subclasses
      end
      
      ;; Not found in any subclass
      ref.null $Class
    end
  end
)

;; Get subclasses array from a class object
(func $get_subclasses_array (param $class (ref $Class)) (result (ref null $SqueakObject))
  ;; In Squeak, subclasses are typically stored in a class variable
  ;; The exact location depends on the class format, but it's usually
  ;; accessible through the class's instance variables
  local.get $class
  i32.const 2  ;; typical index for subclasses inst var
  call $get_instance_variable
)

;; Create minimal class hierarchy without global table
(func $create_minimal_class_hierarchy
  (local $objectClass (ref $Class))
  (local $classClass (ref $Class))
  (local $methodClass (ref $Class))
  (local $contextClass (ref $Class))
  (local $processClass (ref $Class))
  (local $integerClass (ref $Class))
  
  ;; Object class (root of hierarchy)
  call $create_object_class
  local.set $objectClass
  
  ;; Create subclasses and link them to Object
  local.get $objectClass
  call $create_class_class
  local.tee $classClass
  local.get $objectClass
  call $add_subclass
  
  local.get $objectClass
  call $create_method_class
  local.tee $methodClass
  local.get $objectClass
  call $add_subclass
  
  local.get $objectClass
  call $create_context_class
  local.tee $contextClass
  local.get $objectClass
  call $add_subclass
  
  local.get $objectClass
  call $create_process_class
  local.tee $processClass
  local.get $objectClass
  call $add_subclass
  
  local.get $objectClass
  call $create_integer_class
  local.tee $integerClass
  local.get $objectClass
  call $add_subclass
  
  ;; Store essential classes in special objects
  local.get $objectClass
  call $set_object_class_in_special_objects
  local.get $integerClass
  call $set_integer_class_in_special_objects
)

;; Add subclass to superclass's subclasses collection
(func $add_subclass (param $subclass (ref $Class)) (param $superclass (ref $Class))
  (local $subclasses (ref null $SqueakObject))
  
  local.get $superclass
  call $get_subclasses_array
  local.tee $subclasses
  ref.is_null
  if
    ;; Create new subclasses array
    i32.const 4  ;; initial size
    ref.null $SqueakObject
    array.new
    call $create_variable_object
    local.set $subclasses
    
    local.get $superclass
    local.get $subclasses
    call $set_subclasses_array
  end
  
  ;; Add subclass to array
  local.get $subclasses
  local.get $subclass
  call $add_to_object_array
)
```

### Minimal Bootstrap: 3 + 4 = 7 Example

```wat
;; Create minimal object memory for 3 + 4 = 7 example
(func (export "createMinimalBootstrap") (result i32)
  ;; Create essential classes first
  call $create_minimal_class_hierarchy
  
  ;; Create the computation: 3 + 4
  call $create_addition_method
  call $create_initial_process
  call $create_minimal_scheduler
  
  ;; Set up for execution
  call $setup_initial_context
  
  i32.const 1  ;; success
)

;; Create the simplest possible class hierarchy
(func $create_minimal_class_hierarchy
  (local $objectClass (ref $Class))
  (local $classClass (ref $Class))
  (local $methodClass (ref $Class))
  (local $contextClass (ref $Class))
  (local $processClass (ref $Class))
  (local $integerClass (ref $Class))
  
  ;; Object class (root of hierarchy)
  call $create_object_class
  local.set $objectClass
  
  ;; Class class
  local.get $objectClass
  call $create_class_class
  local.set $classClass
  
  ;; Fix bootstrap circularity
  local.get $objectClass
  local.get $classClass
  struct.set $SqueakObject 0  ;; class field
  
  ;; Method class for compiled methods
  local.get $objectClass
  call $create_method_class
  local.set $methodClass
  
  ;; Context class for execution contexts
  local.get $objectClass
  call $create_context_class
  local.set $contextClass
  
  ;; Process class
  local.get $objectClass
  call $create_process_class
  local.set $processClass
  
  ;; SmallInteger class
  local.get $objectClass
  call $create_integer_class
  local.set $integerClass
  
  ;; Store in globals
  local.get $objectClass
  global.set $object_class
  local.get $integerClass
  global.set $integer_class
)

;; Create method that computes 3 + 4 and reports result
(func $create_addition_method (result (ref $CompiledMethod))
  (local $bytecodes (ref array i8))
  (local $literals (ref array (ref null $SqueakObject)))
  (local $method (ref $CompiledMethod))
  
;; Create method that computes 3 + 4 and reports result
(func $create_addition_method (result (ref $CompiledMethod))
  (local $bytecodes (ref array i8))
  (local $literals (ref array (ref null $SqueakObject)))
  (local $method (ref $CompiledMethod))
  
  ;; Bytecodes for: 3 + 4. result reportToJS
  ;; pushConstant: 3    -> 0x20 (pushConstant 0)  
  ;; pushConstant: 4    -> 0x21 (pushConstant 1)
  ;; send: #+           -> 0xB0 (send + - arithmetic special selector)
  ;; send: #reportToJS  -> 0xD0 (send literal 0)
  ;; returnTop          -> 0x7C (return top)
  i32.const 5
  array.new $i8
  local.set $bytecodes
  
  local.get $bytecodes
  i32.const 0
  i32.const 0x20  ;; pushConstant 0 (3)
  array.set
  
  local.get $bytecodes
  i32.const 1
  i32.const 0x21  ;; pushConstant 1 (4)
  array.set
  
  local.get $bytecodes
  i32.const 2
  i32.const 0xB0  ;; send + (special arithmetic selector)
  array.set
  
  local.get $bytecodes
  i32.const 3
  i32.const 0xD0  ;; send literal 0 (#reportToJS)
  array.set
  
  local.get $bytecodes
  i32.const 4
  i32.const 0x7C  ;; returnTop
  array.set
  
  ;; Create literals array: [#reportToJS, 3, 4] with i31ref integers
  i32.const 3
  ref.null anyref
  array.new
  local.set $literals
  
  local.get $literals
  i32.const 0
  call $create_symbol "reportToJS"
  array.set
  
  local.get $literals
  i32.const 1
  i32.const 3
  ref.i31  ;; Create i31ref for SmallInteger 3
  array.set
  
  local.get $literals
  i32.const 2
  i32.const 4
  ref.i31  ;; Create i31ref for SmallInteger 4
  array.set
  
  ;; Create method object
  global.get $method_class
  call $next_identity_hash
  i32.const 12  ;; CompiledMethod format
  i32.const 0   ;; size (will be calculated)
  i32.const 0   ;; no primitive (bits 0-10 = 0)
  local.get $literals
  local.get $bytecodes
  i32.const 0   ;; classic bytecodes, not Sista
  ref.null func ;; no compiled version yet
  i32.const 0   ;; invocation count
  struct.new $CompiledMethod
  local.set $method
  
  local.get $method
)

;; Classic bytecode execution with correct opcodes
(func $execute_classic_bytecode (param $bytecode i32)
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... all classic bytecodes
    block $case0xD0  ;; send literal 0
    block $case0x7C  ;; returnTop
    block $case0x21  ;; pushConstant 1
    block $case0x20  ;; pushConstant 0
    block $case0xB0  ;; send +
    ;; ... more cases
    block $case1
    block $case0
      br_table $case0 $case1 ... $case0x20 $case0x21 ... $case0x7C ... $case0xB0 ... $case0xD0 ... $case255 $end
    end $case0
    ;; pushInstVar 0
    call $push_instance_variable_0
    br $end
    
    end $case0x20
    ;; pushConstant 0 - push literal 1 (3)
    call $get_method
    i32.const 1  ;; literal index 1
    call $push_literal
    br $end
    
    end $case0x21
    ;; pushConstant 1 - push literal 2 (4)
    call $get_method
    i32.const 2  ;; literal index 2
    call $push_literal
    br $end
    
    end $case0x7C
    ;; returnTop - just mark method as returned
    call $mark_method_returned
    br $end
    
    end $case0xB0
    ;; send + (special arithmetic selector)
    call $get_plus_selector
    i32.const 1  ;; arg count
    call $send_message
    br $end
    
    end $case0xE0
    ;; send literal 0 (#reportToJS)
    call $get_method
    i32.const 0  ;; literal index 0
    call $get_literal_selector
    i32.const 0  ;; arg count
    call $send_message
    br $end
    
    ;; ... more bytecode implementations
  end
)
  
  ;; Create method object
  global.get $method_class
  call $next_identity_hash
  i32.const 12  ;; CompiledMethod format
  i32.const 0   ;; size (will be calculated)
  i32.const 0   ;; no primitive (bits 0-10 = 0)
  local.get $literals
  local.get $bytecodes
  i32.const 0   ;; classic bytecodes, not Sista
  ref.null func ;; no compiled version yet
  i32.const 0   ;; invocation count
  struct.new $CompiledMethod
  local.set $method
  
  local.get $method
)

;; Create initial process that will execute 3 + 4
(func $create_initial_process (result (ref $Process))
  (local $process (ref $Process))
  (local $context (ref $Context))
  (local $method (ref $CompiledMethod))
  
  ;; Get the method
  call $create_addition_method
  local.set $method
  
  ;; Create initial context
  global.get $context_class
  call $next_identity_hash
  i32.const 3   ;; MethodContext format
  i32.const 32  ;; size (fixed part + stack)
  ref.null $Context  ;; no sender
  i32.const 0   ;; pc = 0 (start of method)
  i32.const 6   ;; stackp (after receiver + temps)
  local.get $method
  ref.null $SqueakObject  ;; no closure
  call $create_nil_object  ;; receiver (nil for DoIt)
  i32.const 32
  ref.null $SqueakObject
  array.new  ;; stack and temps
  struct.new $Context
  local.set $context
  
  ;; Create process
  global.get $process_class
  call $next_identity_hash
  i32.const 4   ;; Process format
  i32.const 5   ;; size
  ref.null $Process  ;; no next link
  local.get $context ;; suspended context
  i32.const 50       ;; priority
  ref.null $SqueakObject  ;; no list
  i32.const 0        ;; thread id
  struct.new $Process
  local.set $process
  
  ;; Set as active
  local.get $process
  global.set $activeProcess
  local.get $context
  global.set $activeContext
  
  local.get $process
)
```

### Bytecode Interpreter Supporting Both Classic and Sista

```wat
;; Bytecode interpreter with classic and Sista support
(func $interpret_bytecode
  (local $context (ref $Context))
  (local $method (ref $CompiledMethod))
  (local $bytecode i32)
  (local $pc i32)
  (local $isSista i32)
  
  global.get $activeContext
  ref.cast $Context
  local.tee $context
  
  struct.get $Context 7  ;; method field
  local.tee $method
  
  ;; Check if Sista bytecodes
  struct.get $CompiledMethod 7  ;; sistaFlag field
  local.set $isSista
  
  ;; Get current PC and bytecode
  local.get $context
  struct.get $Context 5  ;; pc field
  local.tee $pc
  
  local.get $method
  struct.get $CompiledMethod 6  ;; bytecodes field
  local.get $pc
  array.get_u
  local.set $bytecode
  
  ;; Dispatch to appropriate interpreter
  local.get $isSista
  if
    local.get $bytecode
    call $execute_sista_bytecode
  else
    local.get $bytecode
    call $execute_classic_bytecode
  end
  
  ;; Increment PC
  local.get $context
  local.get $pc
  i32.const 1
  i32.add
  struct.set $Context 5
)

;; Classic bytecode execution (Blue Book / Closure)
(func $execute_classic_bytecode (param $bytecode i32)
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... all classic bytecodes
    block $case118  ;; pushConstant 4
    block $case117  ;; pushConstant 3
    block $case120  ;; returnTop
    block $case176  ;; send +
    ;; ... more cases
    block $case1
    block $case0
      br_table $case0 $case1 ... $case176 $case117 $case118 $case120 ... $case255 $end
    end $case0
    ;; pushInstVar 0
    call $push_instance_variable_0
    br $end
    
    end $case117
    ;; pushConstant 3
    i32.const 3
    call $make_small_integer
    call $push
    br $end
    
    end $case118
    ;; pushConstant 4
    i32.const 4
    call $make_small_integer
    call $push
    br $end
    
    end $case120
    ;; returnTop
    call $pop
    throw $Return
    
    end $case176
    ;; send + (special selector)
    call $get_plus_selector
    i32.const 1  ;; arg count
    call $send_message
    br $end
    
    ;; ... more bytecode implementations
  end
)

;; Sista bytecode execution (Cog VM extended set)
(func $execute_sista_bytecode (param $bytecode i32)
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... Sista-specific bytecodes
    block $case248  ;; callPrimitive
    block $case247  ;; pushFullClosure  
    ;; ... Sista extensions
    block $case0
      br_table $case0 ... $case247 $case248 ... $case255 $end
    end $case0
    ;; Same as classic for basic bytecodes
    call $execute_classic_bytecode
    br $end
    
    end $case247
    ;; pushFullClosure (Sista extension)
    call $push_full_closure_sista
    br $end
    
    end $case248
    ;; callPrimitive (Sista extension)
    call $call_primitive_sista
    br $end
    
    ;; ... more Sista implementations
  end
)
```

### JavaScript Interface for Reporting Result

```javascript
// VM interface for minimal bootstrap
class MinimalSqueakVM {
    constructor() {
        this.vmModule = null;
    }

    async initialize() {
        const imports = {
            system: {
                reportResult: (value) => {
                    console.log(`Smalltalk computation result: ${value}`);
                    this.onResult?.(value);
                },
                currentTimeMillis: () => Date.now()
            }
        };

        this.vmModule = await WebAssembly.instantiateStreaming(
            fetch('squeak-vm.wasm'),
            imports
        );
    }

    async runMinimalExample() {
        // Create minimal 3 + 4 example
        const success = this.vmModule.exports.createMinimalBootstrap();
        if (!success) {
            throw new Error('Failed to create minimal bootstrap');
        }

        // Run until completion
        this.vmModule.exports.interpret();
    }

    async loadSnapshot(snapshotData) {
        // Load existing Squeak snapshot
        const gcArray = this.vmModule.exports.createByteArray(snapshotData.length);
        for (let i = 0; i < snapshotData.length; i++) {
            this.vmModule.exports.setByteAt(gcArray, i, snapshotData[i]);
        }

        const success = this.vmModule.exports.loadSnapshot(gcArray);
        if (!success) {
            throw new Error('Failed to load snapshot');
        }

        // Resume execution
        this.vmModule.exports.interpret();
    }
}

// Usage
async function main() {
    const vm = new MinimalSqueakVM();
    await vm.initialize();
    
    // Start with minimal example
    vm.onResult = (result) => {
        console.log(`Got result: ${result}`);
        // Expected output: "Got result: 7"
    };
    
    await vm.runMinimalExample();
    
    // Later: load full Squeak snapshot
    // const snapshotData = await fetch('squeak6.2.image');
    // await vm.loadSnapshot(new Uint8Array(await snapshotData.arrayBuffer()));
}
```

## Development Path

### Phase 1: Minimal Bootstrap (1-2 weeks)
- Implement minimal class hierarchy
- Create 3 + 4 = 7 example
- Basic bytecode interpreter for essential opcodes
- JavaScript result reporting

### Phase 2: Classic Bytecode Support (2-3 weeks)  
- Complete classic bytecode set implementation
- Method lookup and message sending
- Context creation and stack management
- Process scheduling basics

### Phase 3: JIT Compilation (3-4 weeks)
- Bytecode to WASM translation engine
- Hot method detection and invocation counting
- Compiled method caching and invalidation
- Performance optimization for arithmetic and control flow
- **Critical for performance**: JIT enables the VM to run efficiently before handling complex snapshots

### Phase 4: Slang for WASM
- Like Squeak and SqueakJS before it, SqueakWASM should generate all
  of its virtual machine sources from Smalltalk. This will make
  maintenance and modification easier, through the use of familiar
  Smalltalk tools. In this phase, we want to develop facilities for
  generating all the WAT files of the virtual machine from a working
  Smalltalk version of the same logic. After this phase, we shouldn't
  need to write WAT by hand. This subsystem is traditionally called
  "Slang".

### Phase 5: Snapshot Loading (2-3 weeks)
- Squeak image format parser
- Object memory reconstruction with JIT-compiled methods
- Reference fixing and finalization
- Multi-process resume capability
- **Benefits from JIT**: Loading large snapshots runs much faster with compiled methods

### Phase 6: Sista Bytecode Support (1-2 weeks)
- Extended Sista instruction set
- Full closure support with JIT compilation
- Advanced control flow optimizations
- JIT compilation of Sista-specific bytecodes

### Phase 7: Adaptive Optimization (2-3 weeks)
- **Performance Profiling Infrastructure**: Instrument VM with automated profiling hooks for method execution time, memory usage, and call frequency
- **Usage Metrics Collection**: Track method invocation patterns, object allocation rates, and memory pressure indicators
- **Dynamic JIT Threshold Adjustment**: Automatically adjust compilation thresholds based on runtime performance characteristics and memory constraints
- **Profile-Guided Optimization**: Use collected metrics to optimize method translation strategies (inlining decisions, register allocation, loop optimizations)
- **Adaptive Memory Management**: Adjust GC frequency and object allocation strategies based on observed memory usage patterns
- **Hot Path Detection**: Identify and optimize frequently executed code paths across method boundaries
- **Performance Regression Detection**: Monitor for performance degradations and automatically trigger re-optimization
- **Machine Learning Integration**: Use collected metrics to predict optimal compilation strategies for similar method patterns
- **Real-time Optimization Feedback**: Provide live performance insights to developers through Smalltalk tools and browser console

## Rationale for JIT-First Approach

**Performance Foundation**: JIT compilation provides the performance foundation needed for the VM to be practical. Without it, even basic operations would be too slow for real development work.

**Snapshot Loading Efficiency**: Loading and initializing large Squeak snapshots involves executing many methods. Having JIT compilation available makes this process much faster and more responsive.

**Early Optimization Validation**: Implementing JIT early allows us to validate and tune the performance characteristics before dealing with the complexity of full snapshot compatibility.

**Development Workflow**: Once JIT is working, the development experience becomes much more pleasant, making subsequent phases more productive.

This approach ensures we build performance into the foundation rather than trying to add it later, and gives us a fast, responsive VM for loading and working with complex Squeak environments.

## WASM GC Object Memory Structure

### Core Object Types

```wat
;; Base Smalltalk object using WASM GC
(type $Object (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
))

;; Objects with pointer fields
(type $PointersObject (struct 
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $fields (ref array (ref null $Object)))
))

;; Objects with byte data  
(type $BytesObject (struct
  (field $class (ref $Class))
  (field $identityHash i32) 
  (field $bytes (ref array i8))
))

;; Method objects containing bytecodes
(type $Method (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $bytecodes (ref array i8))
  (field $literals (ref array (ref null $Object)))
  (field $header i32)  ;; encoded: primitive index, arg count, temp count
  (field $compiledWasm (ref null func))  ;; JIT compiled version
))

;; Class objects
(type $Class (struct
  (field $class (ref $Class))  ;; metaclass
  (field $identityHash i32)
  (field $superclass (ref null $Class))
  (field $methodDict (ref $Dictionary))
  (field $format i32)
  (field $instVarNames (ref array (ref string)))
  (field $name (ref string))
))

;; Process execution context
(type $Context (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $sender (ref null $Context))
  (field $pc i32)
  (field $sp i32)
  (field $method (ref $Method))
  (field $receiver (ref null $Object))
  (field $stack (ref array (ref null $Object)))
))

;; Process object
(type $Process (struct
  (field $class (ref $Class))
  (field $identityHash i32)
  (field $suspendedContext (ref null $Context))
  (field $priority i32)
  (field $nextLink (ref null $Process))
))
```

## Bytecode Interpreter with JIT Compilation

### Core VM Module

```wat
(module $VMCore
  ;; Import JavaScript I/O services
  (import "io" "readFile" (func $readFile (param (ref string)) (result (ref extern))))
  (import "display" "updateDisplay" (func $updateDisplay (param i32 i32 i32 i32)))
  (import "events" "getNextEvent" (func $getNextEvent (result i32)))
  (import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
  (import "system" "reportResult" (func $system_report_result (param i32)))
  
  ;; WASM exception types for VM control flow
  (tag $Return (param (ref null $Object)))
  (tag $NonLocalReturn (param (ref null $Object) (ref $Context)))
  (tag $ProcessSwitch (param (ref $Process)))
  (tag $PrimitiveFailed)
  (tag $DoesNotUnderstand (param (ref string) (ref array (ref null $Object))))
  
  ;; Global VM state
  (global $activeProcess (mut (ref null $Process)) (ref.null $Process))
  (global $activeContext (mut (ref null $Context)) (ref.null $Context))
  (global $specialObjects (mut (ref null array)) (ref.null array))
  (global $methodCache (mut (ref null array)) (ref.null array))
  (global $jitCache (mut (ref null array)) (ref.null array))
  
  ;; Bytecode interpreter main loop
  (func (export "interpret")
    (local $bytecode i32)
    (local $context (ref $Context))
    (local $method (ref $Method))
    
    try $main_loop
      loop $bytecode_loop
        ;; Get current context and method
        global.get $activeContext
        ref.cast $Context
        local.tee $context
        struct.get $Context 5  ;; method field
        local.set $method
        
        ;; Check if method has JIT compiled version
        local.get $method
        struct.get $Method 5  ;; compiledWasm field
        ref.is_null
        if
          ;; Interpret bytecode
          call $interpret_bytecode
        else
          ;; Call JIT compiled version
          local.get $method
          struct.get $Method 5
          local.get $context
          call_ref $Context
        end
        
        ;; Continue loop
        br $bytecode_loop
      end
    catch $Return
      ;; Method returned normally
      call $handle_return
    catch $ProcessSwitch
      ;; Process switch requested
      call $handle_process_switch
    catch $PrimitiveFailed
      ;; Primitive failed, continue with Smalltalk method
      br $bytecode_loop
    end
  )
  
  ;; Bytecode interpretation with JIT compilation trigger
  (func $interpret_bytecode
    (local $context (ref $Context))
    (local $method (ref $Method))
    (local $bytecode i32)
    (local $pc i32)
    
    global.get $activeContext
    ref.cast $Context
    local.tee $context
    
    struct.get $Context 5  ;; method field
    local.tee $method
    
    ;; Increment invocation counter for JIT decision
    call $increment_invocation_count
    call $check_jit_threshold
    if
      ;; JIT compile this method
      local.get $method
      call $jit_compile_method
    end
    
    ;; Fetch and execute bytecode
    struct.get $Context 3  ;; pc field
    local.tee $pc
    
    local.get $method
    struct.get $Method 2  ;; bytecodes field
    local.get $pc
    array.get_u
    local.set $bytecode
    
    ;; Increment PC
    local.get $context
    local.get $pc
    i32.const 1
    i32.add
    struct.set $Context 3
    
    ;; Execute bytecode
    local.get $bytecode
    call $execute_bytecode_instruction
  )
  
  ;; Bytecode execution jump table
  (func $execute_bytecode_instruction (param $bytecode i32)
    local.get $bytecode
    
    block $end
      block $case255
      ;; ... blocks for each bytecode 0-255
      block $case17  ;; pushInstVar 1
      block $case16  ;; pushInstVar 0
      block $case15  ;; pushLiteralConstant 15
      ;; ... more cases
      block $case1   ;; pushInstVar 1  
      block $case0   ;; pushInstVar 0
        br_table $case0 $case1 ... $case255 $end
      end $case0
      
      ;; pushInstVar 0
      call $get_receiver
      i32.const 0
      call $push_inst_var
      br $end
      
      end $case1
      ;; pushInstVar 1
      call $get_receiver
      i32.const 1
      call $push_inst_var
      br $end
      
      end $case16
      ;; pushLiteralConstant 0
      call $get_method
      i32.const 0
      call $push_literal
      br $end
      
      end $case17
      ;; pushLiteralConstant 1
      call $get_method
      i32.const 1
      call $push_literal
      br $end
      
      ;; ... continue for all 256 bytecodes
    end
  )
  
  ;; Stack operations using WASM GC
  (func $push (param $object (ref null $Object))
    (local $context (ref $Context))
    (local $sp i32)
    
    global.get $activeContext
    ref.cast $Context
    local.tee $context
    
    struct.get $Context 4  ;; sp field
    local.tee $sp
    
    ;; Store object on stack
    struct.get $Context 7  ;; stack field
    local.get $sp
    local.get $object
    array.set
    
    ;; Increment stack pointer
    local.get $context
    local.get $sp
    i32.const 1
    i32.add
    struct.set $Context 4
  )
  
  (func $pop (result (ref null $Object))
    (local $context (ref $Context))
    (local $sp i32)
    
    global.get $activeContext
    ref.cast $Context
    local.tee $context
    
    ;; Decrement stack pointer
    struct.get $Context 4
    i32.const 1
    i32.sub
    local.tee $sp
    
    local.get $context
    local.get $sp
    struct.set $Context 4
    
    ;; Get object from stack
    struct.get $Context 7  ;; stack field
    local.get $sp
    array.get
  )
)
```

## JIT Compiler: Bytecode to WASM

### JIT Compilation Engine

```wat
;; JIT compiler module
(func $jit_compile_method (param $method (ref $Method))
  (local $bytecodes (ref array i8))
  (local $compiled_func (ref null func))
  
  local.get $method
  struct.get $Method 2  ;; bytecodes field
  local.tee $bytecodes
  
  ;; Analyze bytecode sequence
  call $analyze_bytecodes
  
  ;; Generate WASM function
  call $generate_wasm_function
  local.set $compiled_func
  
  ;; Cache compiled version
  local.get $method
  local.get $compiled_func
  struct.set $Method 5  ;; compiledWasm field
  
  ;; Add to JIT cache
  local.get $method
  local.get $compiled_func
  call $cache_jit_method
)

;; Generate WASM function from bytecode sequence
(func $generate_wasm_function (param $bytecodes (ref array i8)) (result (ref func))
  (local $func_body (ref array i32))  ;; WASM instructions
  (local $i i32)
  (local $bytecode i32)
  
  ;; Create dynamic function body
  local.get $bytecodes
  array.len
  call $create_instruction_array
  local.set $func_body
  
  ;; Translate each bytecode to WASM instructions
  loop $translate_loop
    local.get $bytecodes
    local.get $i
    array.get_u
    local.set $bytecode
    
    ;; Generate WASM instructions for this bytecode
    local.get $bytecode
    call $bytecode_to_wasm
    local.get $func_body
    local.get $i
    call $append_instructions
    
    ;; Next bytecode
    local.get $i
    i32.const 1
    i32.add
    local.tee $i
    
    local.get $bytecodes
    array.len
    i32.lt_u
    br_if $translate_loop
  end
  
  ;; Compile WASM function
  local.get $func_body
  call $compile_wasm_function
)

;; Bytecode to WASM instruction translation
(func $bytecode_to_wasm (param $bytecode i32) (result (ref array i32))
  local.get $bytecode
  
  block $end
    block $case255
    ;; ... cases for each bytecode
    block $case1
    block $case0
      br_table $case0 $case1 ... $case255 $end
    end $case0
    
    ;; pushInstVar 0 -> efficient WASM sequence
    ;; receiver.fields[0] push
    call $gen_get_receiver
    call $gen_const_0
    call $gen_get_field
    call $gen_push
    call $create_instruction_sequence
    return
    
    end $case1
    ;; pushInstVar 1
    call $gen_get_receiver
    call $gen_const_1
    call $gen_get_field
    call $gen_push
    call $create_instruction_sequence
    return
    
    ;; ... more optimized translations
  end
  
  ;; Default: call interpreter
  call $gen_call_interpreter
  call $create_instruction_sequence
)
```

## Method Lookup with JIT Cache

### Optimized Method Dispatch

```wat
;; Method lookup with JIT cache integration
(func $lookup_and_invoke (param $receiver (ref null $Object)) (param $selector (ref string)) (param $argCount i32)
  (local $class (ref $Class))
  (local $method (ref null $Method))
  (local $compiled_func (ref null func))
  
  ;; Get receiver class
  local.get $receiver
  struct.get $Object 0  ;; class field
  local.set $class
  
  ;; Check method cache first
  local.get $class
  local.get $selector
  call $check_method_cache
  local.tee $method
  ref.is_null
  if
    ;; Cache miss - perform lookup
    local.get $class
    local.get $selector
    call $lookup_method_in_class
    local.tee $method
    ref.is_null
    if
      ;; Method not found
      local.get $receiver
      local.get $selector
      local.get $argCount
      call $create_args_array
      throw $DoesNotUnderstand
    end
    
    ;; Cache the lookup result
    local.get $class
    local.get $selector
    local.get $method
    call $cache_method_lookup
  end
  
  ;; Check if method has JIT compiled version
  local.get $method
  struct.get $Method 5  ;; compiledWasm field
  local.tee $compiled_func
  ref.is_null
  if
    ;; No JIT version - create new context and interpret
    local.get $receiver
    local.get $method
    local.get $argCount
    call $create_method_context
    call $set_active_context
  else
    ;; Call JIT compiled version directly
    local.get $receiver
    local.get $compiled_func
    call_ref $Object
  end
)

;; Method lookup in class hierarchy
(func $lookup_method_in_class (param $class (ref $Class)) (param $selector (ref string)) (result (ref null $Method))
  (local $methodDict (ref $Dictionary))
  (local $method (ref null $Method))
  
  ;; Search in this class
  local.get $class
  struct.get $Class 3  ;; methodDict field
  local.tee $methodDict
  local.get $selector
  call $dictionary_at
  local.tee $method
  ref.is_null
  if
    ;; Not found, try superclass
    local.get $class
    struct.get $Class 2  ;; superclass field
    ref.is_null
    if (result (ref null $Method))
      ;; No superclass - method not found
      ref.null $Method
    else
      ;; Recursive lookup in superclass
      local.get $class
      struct.get $Class 2
      ref.cast $Class
      local.get $selector
      call $lookup_method_in_class
    end
  else
    local.get $method
  end
)
```

## Minimal Bootstrap Object Memory

### Essential Objects for VM Bootstrap

```wat
;; Bootstrap minimal object memory with essential structures
(func (export "createMinimalObjectMemory")
  ;; Create special objects array
  call $create_special_objects
  global.set $specialObjects
  
  ;; Create essential classes
  call $create_object_class
  call $create_class_class  
  call $create_metaclass_class
  call $create_method_class
  call $create_context_class
  call $create_process_class
  call $create_semaphore_class
  
  ;; Create essential objects
  call $create_nil_object
  call $create_true_object
  call $create_false_object
  
  ;; Create scheduler and initial process
  call $create_processor_scheduler
  call $create_initial_process
  
  ;; Set up method cache
  call $initialize_method_cache
  
  ;; Set up JIT cache
  call $initialize_jit_cache
)

;; Create essential class hierarchy
(func $create_object_class (result (ref $Class))
  (local $objectClass (ref $Class))
  (local $objectMetaclass (ref $Class))
  
  ;; Object class (self-referential bootstrap)
  ref.null $Class  ;; will be set to metaclass
  call $next_identity_hash
  ref.null $Class  ;; no superclass
  call $create_empty_method_dict
  i32.const 1      ;; variable object format
  call $create_empty_string_array  ;; no instance variables
  call $create_string "Object"
  struct.new $Class
  local.set $objectClass
  
  ;; Object metaclass
  ref.null $Class  ;; will be set to Metaclass
  call $next_identity_hash
  ref.null $Class  ;; Class is superclass
  call $create_empty_method_dict
  i32.const 1      ;; variable object format  
  call $create_empty_string_array
  call $create_string "Object class"
  struct.new $Class
  local.set $objectMetaclass
  
  ;; Connect class and metaclass
  local.get $objectClass
  local.get $objectMetaclass
  struct.set $Class 0  ;; class field
  
  local.get $objectClass
)

;; Create initial Smalltalk process
(func $create_initial_process (result (ref $Process))
  (local $process (ref $Process))
  (local $initialContext (ref $Context))
  
  ;; Create initial method context for DoIt
  call $create_doit_context
  local.set $initialContext
  
  ;; Create process object
  call $get_process_class
  call $next_identity_hash
  local.get $initialContext  ;; suspended context
  i32.const 50               ;; priority
  ref.null $Process          ;; no next link
  struct.new $Process
  local.set $process
  
  ;; Set as active process
  local.get $process
  global.set $activeProcess
  
  local.get $initialContext
  global.set $activeContext
  
  local.get $process
)

;; Create method dictionary for class loading
(func $create_empty_method_dict (result (ref $Dictionary))
  call $get_dictionary_class
  call $next_identity_hash
  call $create_empty_object_array  ;; keys
  call $create_empty_object_array  ;; values
  struct.new $PointersObject
  ref.cast $Dictionary
)
```

## Class Loading and Method Installation

### Dynamic Class Creation

```wat
;; Load new class from object memory
(func (export "loadClass") (param $classData (ref $BytesObject)) (result (ref $Class))
  (local $newClass (ref $Class))
  (local $superclass (ref null $Class))
  (local $methodDict (ref $Dictionary))
  
  ;; Parse class definition from byte data
  local.get $classData
  call $parse_class_definition
  local.set $newClass
  
  ;; Install methods in method dictionary
  local.get $newClass
  call $install_class_methods
  
  ;; Add to global class table
  local.get $newClass
  call $register_global_class
  
  local.get $newClass
)

;; Install compiled method in class
(func $install_method (param $class (ref $Class)) (param $selector (ref string)) (param $method (ref $Method))
  (local $methodDict (ref $Dictionary))
  
  local.get $class
  struct.get $Class 3  ;; methodDict field
  local.tee $methodDict
  
  ;; Add method to dictionary
  local.get $selector
  local.get $method
  call $dictionary_at_put
  
  ;; Invalidate method cache entries for this selector
  local.get $selector
  call $invalidate_method_cache
  
  ;; Clear any JIT compiled versions
  local.get $class
  local.get $selector
  call $invalidate_jit_cache
)

;; Create method from bytecode and literals
(func $create_method (param $bytecodes (ref array i8)) (param $literals (ref array (ref null $Object))) (param $header i32) (result (ref $Method))
  call $get_method_class
  call $next_identity_hash
  local.get $bytecodes
  local.get $literals
  local.get $header
  ref.null func  ;; no compiled version yet
  struct.new $Method
)
```

## Exception-Based Control Flow

### Using WASM Exceptions for VM Control

```wat
;; Exception-based return handling
(func $do_return (param $value (ref null $Object))
  ;; Throw return exception with value
  local.get $value
  throw $Return
)

;; Exception-based primitive failure
(func $primitive_failed
  ;; Signal primitive failure to interpreter
  throw $PrimitiveFailed
)

;; Exception-based message not understood
(func $send_does_not_understand (param $receiver (ref null $Object)) (param $selector (ref string)) (param $args (ref array (ref null $Object)))
  ;; Create message object and send doesNotUnderstand:
  local.get $selector
  local.get $args
  throw $DoesNotUnderstand
)

;; Exception-based process switching
(func $yield_to_process (param $newProcess (ref $Process))
  ;; Switch to different process
  local.get $newProcess
  throw $ProcessSwitch
)

;; Handle exceptions in main interpreter loop
(func $handle_return (param $value (ref null $Object))
  ;; Pop context and continue with returned value
  call $pop_context
  local.get $value
  call $push
)

(func $handle_process_switch (param $newProcess (ref $Process))
  ;; Save current context
  call $save_current_context
  
  ;; Switch to new process
  local.get $newProcess
  global.set $activeProcess
  
  local.get $newProcess
  struct.get $Process 2  ;; suspendedContext field
  global.set $activeContext
)
```

## Performance Optimizations

### 1. Polymorphic Inline Caching

```wat
;; Polymorphic inline cache using WASM GC
(type $PIC (struct
  (field $selector (ref string))
  (field $class0 (ref null $Class))
  (field $method0 (ref null $Method))
  (field $class1 (ref null $Class))
  (field $method1 (ref null $Method))
  (field $class2 (ref null $Class))
  (field $method2 (ref null $Method))
  (field $miss_count i32)
))

(func $pic_lookup (param $pic (ref $PIC)) (param $class (ref $Class)) (result (ref null $Method))
  ;; Check cache entries
  local.get $pic
  struct.get $PIC 1  ;; class0 field
  local.get $class
  ref.eq
  if (result (ref null $Method))
    local.get $pic
    struct.get $PIC 2  ;; method0 field
  else
    local.get $pic
    struct.get $PIC 3  ;; class1 field
    local.get $class
    ref.eq
    if (result (ref null $Method))
      local.get $pic
      struct.get $PIC 4  ;; method1 field
    else
      local.get $pic
      struct.get $PIC 5  ;; class2 field
      local.get $class
      ref.eq
      if (result (ref null $Method))
        local.get $pic
        struct.get $PIC 6  ;; method2 field
      else
        ;; Cache miss
        ref.null $Method
      end
    end
  end
)
```

### 2. JIT Compilation Heuristics

```wat
;; JIT compilation decision logic
(func $check_jit_threshold (param $method (ref $Method)) (result i32)
  (local $invocation_count i32)
  (local $bytecode_length i32)
  
  local.get $method
  call $get_invocation_count
  local.set $invocation_count
  
  local.get $method
  struct.get $Method 2  ;; bytecodes field
  array.len
  local.set $bytecode_length
  
  ;; Compile if hot enough and not too large
  local.get $invocation_count
  i32.const 100  ;; threshold
  i32.ge_u
  
  local.get $bytecode_length
  i32.const 500  ;; max size for JIT
  i32.le_u
  
  i32.and
)
```

## Development Workflow

### 1. Bootstrap Sequence

```javascript
async function bootstrapSmalltalkVM() {
    // Load minimal WASM VM
    const vmModule = await WebAssembly.instantiateStreaming(
        fetch('squeak-vm.wasm'), 
        createVMImports()
    );
    
    // Create minimal object memory
    vmModule.exports.createMinimalObjectMemory();
    
    // Load essential classes
    await loadEssentialClasses(vmModule);
    
    // Start initial process
    vmModule.exports.interpret();
}

async function loadEssentialClasses(vmModule) {
    const classData = await fetch('essential-classes.image');
    const classBytes = new Uint8Array(await classData.arrayBuffer());
    
    // Convert to WASM GC byte array
    const gcBytes = vmModule.exports.createByteArray(classBytes.length);
    for (let i = 0; i < classBytes.length; i++) {
        vmModule.exports.setByteAt(gcBytes, i, classBytes[i]);
    }
    
    // Load classes into object memory
    vmModule.exports.loadClasses(gcBytes);
}
```

### 2. Class Hot-Swapping

```javascript
async function hotSwapClass(className, newClassData) {
    // Invalidate JIT cache for this class
    vmModule.exports.invalidateJITForClass(className);
    
    // Replace class definition
    vmModule.exports.replaceClass(className, newClassData);
    
    // Migrate existing instances
    vmModule.exports.migrateInstances(className);
}
```

## Benefits

**Authentic Smalltalk Semantics**: Bytecode interpretation preserves exact Smalltalk behavior
**JIT Performance**: Hot methods get compiled to efficient WASM for near-native speed  
**Minimal Bootstrap**: Small, focused object memory enables fast startup
**Exception-Based Control**: Clean, efficient VM control flow using WASM exceptions
**Live Development**: Dynamic class loading and method replacement
**Type Safety**: WASM GC prevents memory corruption and enables safe optimizations

This architecture provides an authentic Smalltalk virtual machine that leverages WebAssembly's strengths while maintaining the live, dynamic development experience that makes Smalltalk unique.
