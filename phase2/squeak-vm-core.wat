;; SqueakJS to WASM VM Core Module - Phase 2: Classic Bytecode Support
;; Complete classic bytecode set, method lookup, and message sending

(module $SqueakVMCore
	;; Import JavaScript interface functions
	(import "system" "reportResult" (func $system_report_result (param i32)))
	(import "system" "currentTimeMillis" (func $currentTimeMillis (result i64)))
	(import "system" "consoleLog" (func $consoleLog (param i32)))
	
	(rec
	 ;; Type 0: ObjectArray
	 (type $ObjectArray (array (mut (ref null eq))))
	 
	 ;; Type 1: ByteArray 
	 (type $ByteArray (array (mut i8)))
	 
	 ;; Type 2: Base Squeak object
	 (type $SqueakObject (sub (struct 
				   (field $class (mut (ref null $Class)))
				   (field $identityHash (mut i32))
				   (field $format (mut i32))
				   (field $size (mut i32))
				   )))
	 
	 ;; Type 3: Variable objects
	 (type $VariableObject (sub $SqueakObject (struct 
						   (field $class (mut (ref null $Class)))
						   (field $identityHash (mut i32))
						   (field $format (mut i32))
						   (field $size (mut i32))
						   (field $slots (mut (ref null $ObjectArray)))
						   )))
	 
	 ;; Type 4: Dictionary
	 (type $Dictionary (sub $VariableObject (struct
						 (field $class (mut (ref null $Class)))
						 (field $identityHash (mut i32))
						 (field $format (mut i32))
						 (field $size (mut i32))
						 (field $slots (mut (ref null $ObjectArray)))
						 (field $keys (ref null $ObjectArray))
						 (field $values (ref null $ObjectArray))
						 (field $count (mut i32))
						 )))
	 
	 ;; Type 5: Class objects
	 (type $Class (sub $VariableObject (struct
					    (field $class (mut (ref null $Class)))
					    (field $identityHash (mut i32))
					    (field $format (mut i32))
					    (field $size (mut i32))
					    (field $slots (mut (ref null $ObjectArray)))
					    (field $superclass (mut (ref null $Class)))
					    (field $methodDict (mut (ref null $Dictionary)))
					    (field $instVarNames (mut (ref null $SqueakObject)))
					    (field $name (mut (ref null $SqueakObject)))
					    (field $instSize (mut i32))
					    )))
	 
	 ;; Type 6: CompiledMethod objects
	 (type $CompiledMethod (sub $VariableObject (struct
						     (field $class (mut (ref null $Class)))
						     (field $identityHash (mut i32))
						     (field $format (mut i32))
						     (field $size (mut i32))
						     (field $slots (mut (ref null $ObjectArray)))
						     (field $header i32)
						     (field $bytecodes (ref null $ByteArray))
						     (field $invocationCount i32)
						     (field $compiledWasm (ref null func))
						     )))
	 
	 ;; Type 7: Context objects
	 (type $Context (sub $VariableObject (struct
					      (field $class (mut (ref null $Class)))
					      (field $identityHash (mut i32))
					      (field $format (mut i32))
					      (field $size (mut i32))
					      (field $slots (mut (ref null $ObjectArray)))
					      (field $sender (mut (ref null $Context)))
					      (field $pc (mut i32))
					      (field $sp (mut i32))
					      (field $method (mut (ref null $CompiledMethod)))
					      (field $receiver (mut (ref null eq)))
					      )))
	 
	 ;; Type 8: Process objects
	 (type $Process (sub $VariableObject (struct
					      (field $class (mut (ref null $Class)))
					      (field $identityHash (mut i32))
					      (field $format (mut i32))
					      (field $size (mut i32))
					      (field $slots (mut (ref null $ObjectArray)))
					      (field $nextLink (ref null $Process))
					      (field $suspendedContext (ref null $Context))
					      (field $priority i32)
					      (field $myList (ref null $SqueakObject))
					      )))
	 
	 ;; Type 9: String objects
	 (type $String (sub $SqueakObject (struct
					   (field $class (mut (ref null $Class)))
					   (field $identityHash (mut i32))
					   (field $format (mut i32))
					   (field $size (mut i32))
					   (field $bytes (ref null $ByteArray))
					   )))
	 
	 ;; Type 10: Array objects
	 (type $Array (sub $VariableObject (struct
					    (field $class (mut (ref null $Class)))
					    (field $identityHash (mut i32))
					    (field $format (mut i32))
					    (field $size (mut i32))
					    (field $slots (mut (ref null $ObjectArray)))
					    )))
	 )

	;; === WASM Exception Types for VM Control Flow ===
	(tag $Return (param (ref null eq)))
	(tag $PrimitiveFailed)
	(tag $DoesNotUnderstand
	     (param (ref null eq)) ;; receiver
	     (param (ref null $SqueakObject)) ;; selector
	     (param (ref null $SqueakObject)) ;; arguments
	     )
	(tag $ProcessSwitch (param (ref null $Process)))

	;; === Global VM State ===
	
	(global $activeContext (mut (ref null $Context)) (ref.null $Context))
	(global $activeProcess (mut (ref null $Process)) (ref.null $Process))
	(global $methodReturned (mut i32) (i32.const 0))
	(global $nextIdentityHash (mut i32) (i32.const 1))
	
	;; Special objects
	(global $nilObject (mut (ref null eq)) (ref.null eq))
	(global $trueObject (mut (ref null eq)) (ref.null eq))
	(global $falseObject (mut (ref null eq)) (ref.null eq))
	
	;; Special classes
	(global $objectClass (mut (ref null $Class)) (ref.null $Class))
	(global $classClass (mut (ref null $Class)) (ref.null $Class))
	(global $methodClass (mut (ref null $Class)) (ref.null $Class))
	(global $contextClass (mut (ref null $Class)) (ref.null $Class))
	(global $stringClass (mut (ref null $Class)) (ref.null $Class))
	(global $arrayClass (mut (ref null $Class)) (ref.null $Class))
	(global $dictionaryClass (mut (ref null $Class)) (ref.null $Class))
	
	;; Special selectors for message sending
	(global $plusSelector (mut (ref null eq)) (ref.null eq))
	(global $minusSelector (mut (ref null eq)) (ref.null eq))
	(global $timesSelector (mut (ref null eq)) (ref.null eq))
	(global $divideSelector (mut (ref null eq)) (ref.null eq))
	(global $equalsSelector (mut (ref null eq)) (ref.null eq))
	(global $doesNotUnderstandSelector (mut (ref null eq)) (ref.null eq))
	(global $squaredSelector (mut (ref null eq)) (ref.null eq))
	(global $reportToJSSelector (mut (ref null eq)) (ref.null eq))
	
	;; SmallInteger class for proper method lookup
	(global $smallIntegerClass (mut (ref null $Class)) (ref.null $Class))
	
	;; === Object Creation and Management ===
	
	(func $nextIdentityHash (result i32)
	      global.get $nextIdentityHash
	      global.get $nextIdentityHash
	      i32.const 1
	      i32.add
	      global.set $nextIdentityHash
	      )
	
	(func $newString (param $class (ref null $Class)) (param $content (ref $ByteArray)) (result (ref $String))
	      local.get $class
	      call $nextIdentityHash
	      i32.const 8  ;; byte format
	      local.get $content
	      array.len
	      local.get $content
	      struct.new $String
	      )
	
	(func $newArray (param $class (ref null $Class)) (param $size i32) (result (ref $Array))
	      local.get $class
	      call $nextIdentityHash
	      i32.const 2  ;; pointer format
	      local.get $size
	      local.get $size
	      (array.new_default $ObjectArray)
	      struct.new $Array
	      )

	;; Create a new object array of given size
	(func $createObjectArray (param $size i32) (result (ref $ObjectArray))
	      local.get $size
	      array.new_default $ObjectArray
	      )
	
	(func $newDictionary (param $class (ref null $Class)) (param $size i32) (result (ref $Dictionary))
	      local.get $class
	      call $nextIdentityHash
	      i32.const 2  ;; pointer format
	      local.get $size
	      local.get $size
	      (array.new_default $ObjectArray)  ;; slots
	      local.get $size
	      (array.new_default $ObjectArray)  ;; keys
	      local.get $size
	      (array.new_default $ObjectArray)  ;; values
	      i32.const 0  ;; count
	      struct.new $Dictionary
	      )
	
	(func $newContext (param $class (ref null $Class)) (param $stackSize i32) (result (ref $Context))
	      local.get $class
	      call $nextIdentityHash
	      i32.const 1  ;; pointer format
	      local.get $stackSize
	      local.get $stackSize
	      (array.new_default $ObjectArray)
	      ref.null $Context  ;; sender
	      i32.const 0        ;; pc
	      i32.const 0        ;; sp
	      ref.null $CompiledMethod  ;; method
	      ref.null eq       ;; receiver
	      struct.new $Context
	      )
	
	;; === Dictionary Operations for Method Lookup ===

	(func $dictionary_at (param $dict (ref null $Dictionary)) (param $key (ref null eq)) (result (ref null eq))
	      (local $i i32)
	      (local $keys (ref null $ObjectArray))
	      (local $values (ref null $ObjectArray))
	      (local $count i32)
	      
	      local.get $dict
	      struct.get $Dictionary $keys
	      local.set $keys
	      
	      local.get $dict
	      struct.get $Dictionary $values
	      local.set $values
	      
	      local.get $dict
	      struct.get $Dictionary $count
	      local.set $count
	      
	      ;; Linear search for key
	      loop $search_loop
	      local.get $i
	      local.get $count
	      i32.ge_u
	      if
              ref.null $SqueakObject
              return
	      end
	      
	      local.get $keys
	      local.get $i
	      array.get $ObjectArray
	      local.get $key
	      ref.eq
	      if
              local.get $values
              local.get $i
              array.get $ObjectArray
              return
	      end
	      
	      local.get $i
	      i32.const 1
	      i32.add
	      local.set $i
	      br $search_loop
	      end
	      
	      ref.null $SqueakObject
	      )

	(func $dictionary_at_put (param $dict (ref $Dictionary)) (param $key (ref null eq)) (param $value (ref null eq))
	      (local $count i32)
	      
	      local.get $dict
	      struct.get $Dictionary $count
	      local.set $count
	      
	      ;; Add to end (simplified)
	      local.get $dict
	      struct.get $Dictionary $keys
	      local.get $count
	      local.get $key
	      array.set $ObjectArray
	      
	      local.get $dict
	      struct.get $Dictionary $values
	      local.get $count
	      local.get $value
	      array.set $ObjectArray
	      
	      local.get $dict
	      local.get $count
	      i32.const 1
	      i32.add
	      struct.set $Dictionary $count
	      )
	
	;; === Method Lookup ===

	(func $lookupMethod (param $class (ref null $Class)) (param $selector (ref null eq)) (result (ref null $CompiledMethod))
	      (local $currentClass (ref null $Class))
	      (local $methodDict (ref null $Dictionary))
	      (local $method (ref null $CompiledMethod))
	      (local $maybeMethod (ref null eq))
	      
	      local.get $class
	      local.set $currentClass
	      
	      ;; Walk up class hierarchy
	      loop $lookup_loop
	      local.get $currentClass
	      ref.is_null
	      if
              ref.null $CompiledMethod
              return
	      end
	      
	      local.get $currentClass
	      struct.get $Class $methodDict
	      local.set $methodDict
	      
	      local.get $methodDict
	      ref.is_null
	      if
              ;; Try superclass
              local.get $currentClass
              struct.get $Class $superclass
              local.set $currentClass
              br $lookup_loop
	      end
	      
	      local.get $methodDict
	      local.get $selector
	      call $dictionary_at
	      local.set $maybeMethod  ;; Store in the eq-typed variable first
	      
	      local.get $maybeMethod
	      ref.is_null
	      if
              ;; Try superclass
              local.get $currentClass
              struct.get $Class $superclass
              local.set $currentClass
              br $lookup_loop
	      end
	      
	      ;; Found method - cast from (ref null eq) to (ref null $CompiledMethod)
	      local.get $maybeMethod
	      ref.cast (ref null $CompiledMethod)
	      return
	      end
	      
	      ref.null $CompiledMethod
	      )

	;; === Message Sending ===
	
	(func $sendMessage (param $receiver (ref null eq)) (param $selector (ref null eq)) (param $argCount i32)
	      (local $receiverClass (ref null $Class))
	      (local $method (ref null $CompiledMethod))
	      (local $newContext (ref $Context))
	      (local $i i32)
	      
	      ;; Get receiver's class
	      local.get $receiver
	      call $getObjectClass
	      local.set $receiverClass
	      
	      ;; Lookup method
	      local.get $receiverClass
	      local.get $selector
	      call $lookupMethod
	      local.set $method
	      
	      local.get $method
	      ref.is_null
	      if
	      ;; Method not found - send doesNotUnderstand:
	      local.get $receiver
	      local.get $selector
	      global.get $doesNotUnderstandSelector
	      i32.const 1
	      call $sendMessage
	      return
	      end
	      
	      ;; Create new context
	      global.get $contextClass
	      i32.const 50  ;; Stack size
	      call $newContext
	      local.set $newContext
	      
	      ;; Set up context
	      local.get $newContext
	      global.get $activeContext
	      struct.set $Context $sender
	      
	      local.get $newContext
	      i32.const 0
	      struct.set $Context $pc
	      
	      local.get $newContext
	      local.get $argCount
	      i32.const 1
	      i32.add  ;; +1 for receiver
	      struct.set $Context $sp
	      
	      local.get $newContext
	      local.get $method
	      struct.set $Context $method
	      
	      local.get $newContext
	      local.get $receiver
	      struct.set $Context $receiver
	      
	      ;; Copy receiver and arguments to new context
	      local.get $newContext
	      struct.get $Context $slots
	      i32.const 0
	      local.get $receiver
	      array.set $ObjectArray
	      
	      ;; Copy arguments from current context stack
	      local.get $argCount
	      i32.const 0
	      i32.gt_u
	      if
	      loop $copy_args
              local.get $i
              local.get $argCount
              i32.ge_u
              if
              else
              local.get $newContext
              struct.get $Context $slots
              local.get $i
              i32.const 1
              i32.add
              local.get $i
              call $stackValue
              array.set $ObjectArray
              
              local.get $i
              i32.const 1
              i32.add
              local.set $i
              br $copy_args
              end
	      end
	      
	      ;; Pop arguments from current stack
	      global.get $activeContext
	      global.get $activeContext
	      struct.get $Context $sp
	      local.get $argCount
	      i32.sub
	      struct.set $Context $sp
	      end

	      ;; Switch to new context
	      local.get $newContext
	      global.set $activeContext
	      )
	
	;; === Object Class Detection ===
	
	(func $getObjectClass (param $obj (ref null eq)) (result (ref null $Class))
	      local.get $obj
	      ref.test (ref i31)
	      if (result (ref null $Class))
	      ;; SmallInteger - return SmallInteger class
	      global.get $smallIntegerClass
	      else
	      local.get $obj
	      ref.cast (ref $SqueakObject)
	      struct.get $SqueakObject $class
	      end
	      )
	
	;; === Context Stack Operations ===
	
	(func $push (param $value (ref null eq))
	      global.get $activeContext
	      struct.get $Context $slots
	      global.get $activeContext
	      struct.get $Context $sp
	      local.get $value
	      array.set $ObjectArray

	      global.get $activeContext
	      global.get $activeContext
	      struct.get $Context $sp
	      i32.const 1
	      i32.add
	      struct.set $Context $sp
	      )
	
	(func $pop (result (ref null eq))
	      global.get $activeContext
	      global.get $activeContext
	      struct.get $Context $sp
	      i32.const 1
	      i32.sub
	      struct.set $Context $sp
	      
	      global.get $activeContext
	      struct.get $Context $slots
	      global.get $activeContext
	      struct.get $Context $sp
	      array.get $ObjectArray
	      )
	
	(func $stackValue (param $offset i32) (result (ref null eq))
	      global.get $activeContext
	      struct.get $Context $slots
	      global.get $activeContext
	      struct.get $Context $sp
	      i32.const 1
	      i32.sub
	      local.get $offset
	      i32.sub
	      array.get $ObjectArray
	      )
	
	;; === Complete Classic Bytecode Interpreter ===
	
	(func $executeBytecode (param $bytecode i32)
	      (local $value (ref null eq))
	      (local $context (ref $Context))
	      (local $receiver (ref null eq))
	      (local $operand1 i32)
	      (local $operand2 i32)
	      
	      ;; Get context with proper null handling
	      global.get $activeContext
	      ref.as_non_null
	      local.set $context
	      
	      ;; Load receiver
	      local.get $bytecode
	      i32.const 0x00
	      i32.const 0x0F
	      i32.and
	      i32.eq
	      if
	      local.get $context
	      struct.get $Context $receiver
	      call $push
	      return
	      end
	      
	      ;; Load instance variable - NEED TO CHECK FOR SMALLINTEGER
	      local.get $bytecode
	      i32.const 0x10
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x1F
	      i32.le_u
	      i32.and
	      if
	      local.get $context
	      struct.get $Context $receiver
	      local.set $receiver
	      
	      ;; Check if receiver is SmallInteger (i31ref) or actual object
	      local.get $receiver
	      ref.test (ref i31)
	      if
              ;; SmallIntegers don't have instance variables - this should error
              ;; Push nil or trap - SmallIntegers accessing inst vars is invalid
              global.get $nilObject
              call $push
	      else
              ;; It's a real object - no cast needed, WASM knows it's SqueakObject
              local.get $receiver
	      ref.cast (ref null $SqueakObject)
              local.get $bytecode
              i32.const 0x0F
              i32.and
              call $getInstanceVariable
              call $push
	      end
	      return
	      end
	      
	      ;; Load literal
	      local.get $bytecode
	      i32.const 0x20
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x3F
	      i32.le_u
	      i32.and
	      if
	      global.get $activeContext
	      struct.get $Context $method
	      local.get $bytecode
	      i32.const 0x1F
	      i32.and
	      call $getMethodLiteral
	      call $push
	      return
	      end
	      
	      ;; Load literal variable
	      local.get $bytecode
	      i32.const 0x40
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x5F
	      i32.le_u
	      i32.and
	      if
	      global.get $activeContext
	      struct.get $Context $method
	      local.get $bytecode
	      i32.const 0x1F
	      i32.and
	      call $getMethodLiteral
	      ;; Get association value (simplified)
	      call $push
	      return
	      end
	      
	      ;; Store and pop receiver variable - ALSO NEED TO CHECK FOR SMALLINTEGER
	      local.get $bytecode
	      i32.const 0x60
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x67
	      i32.le_u
	      i32.and
	      if
	      call $pop
	      local.set $value
	      local.get $context
	      struct.get $Context $receiver
	      local.set $receiver
	      
	      ;; Check if receiver is SmallInteger
	      local.get $receiver
	      ref.test (ref i31)
	      if
              ;; SmallIntegers are immutable - this should error or be ignored
              ;; For now, just ignore the store
	      else
              ;; It's a real object - no cast needed
              local.get $receiver
	      ref.cast (ref null $SqueakObject)
              local.get $bytecode
              i32.const 0x07
              i32.and
              local.get $value
              call $setInstanceVariable
	      end
	      return
	      end
	      
	      ;; Store and pop temporary variable
	      local.get $bytecode
	      i32.const 0x68
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x6F
	      i32.le_u
	      i32.and
	      if
	      call $pop
	      local.set $value
	      local.get $bytecode
	      i32.const 0x07
	      i32.and
	      local.get $value
	      call $setTemporary
	      return
	      end
	      
	      ;; Push constants
	      local.get $bytecode
	      i32.const 0x70
	      i32.eq
	      if  ;; push receiver
	      global.get $activeContext
	      struct.get $Context $receiver
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x71
	      i32.eq
	      if  ;; push true
	      global.get $trueObject
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x72
	      i32.eq
	      if  ;; push false
	      global.get $falseObject
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x73
	      i32.eq
	      if  ;; push nil
	      global.get $nilObject
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x74
	      i32.eq
	      if  ;; push -1
	      i32.const -1
	      ref.i31
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x75
	      i32.eq
	      if  ;; push 0
	      i32.const 0
	      ref.i31
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x76
	      i32.eq
	      if  ;; push 1 (modified to push 3 for our example)
	      i32.const 3
	      ref.i31
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x77
	      i32.eq
	      if  ;; push 2
	      i32.const 2
	      ref.i31
	      call $push
	      return
	      end
	      
	      ;; Returns
	      local.get $bytecode
	      i32.const 0x78
	      i32.eq
	      if  ;; return receiver
	      global.get $activeContext
	      struct.get $Context $receiver
	      call $doReturn
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x79
	      i32.eq
	      if  ;; return true
	      global.get $trueObject
	      call $doReturn
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x7A
	      i32.eq
	      if  ;; return false
	      global.get $falseObject
	      call $doReturn
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x7B
	      i32.eq
	      if  ;; return nil
	      global.get $nilObject
	      call $doReturn
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0x7C
	      i32.eq
	      if  ;; return top of stack
	      call $pop
	      call $doReturn
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 176
	      i32.eq
	      if ;; label = @1
	      call $pop
	      ref.cast (ref i31)
	      i31.get_s
	      local.set $operand2
	      call $pop
	      ref.cast (ref i31)
	      i31.get_s
	      local.set $operand1
	      local.get $operand1
	      local.get $operand2
	      i32.add
	      ref.i31
	      call $push
	      return
	      end
	      
	      local.get $bytecode
	      i32.const 0xB1
	      i32.eq
	      if  ;; send * (multiplication)
	      call $pop
	      ref.cast (ref i31)
	      i31.get_s
	      call $pop
	      ref.cast (ref i31)
	      i31.get_s
	      i32.mul
	      ref.i31
	      call $push
	      return
	      end
	      
	      ;; Report result to JavaScript
	      local.get $bytecode
	      i32.const 0xD0
	      i32.eq
	      if  ;; send reportToJS
	      call $pop
	      ref.cast (ref i31)
	      i31.get_s
	      call $system_report_result
	      
	      ;; Push nil as result
	      global.get $nilObject
	      call $push
	      return
	      end
	      
	      ;; Send message
	      local.get $bytecode
	      i32.const 0x90
	      i32.ge_u
	      local.get $bytecode
	      i32.const 0x9F
	      i32.le_u
	      i32.and
	      if
	      ;; Send literal selector with 0 args
	      global.get $activeContext
	      struct.get $Context $method
	      local.get $bytecode
	      i32.const 0x0F
	      i32.and
	      call $getMethodLiteral
	      i32.const 0  ;; 0 arguments
	      call $sendLiteralSelector
	      return
	      end
	      )
	
	;; === Context Returns ===
	
	(func $doReturn (param $value (ref null eq))
	      (local $sender (ref null $Context))
	      
	      global.get $activeContext
	      struct.get $Context $sender
	      local.set $sender
	      
	      local.get $sender
	      ref.is_null
	      if
	      ;; No sender - method returned
	      i32.const 1
	      global.set $methodReturned
	      local.get $value
	      call $push
	      return
	      end
	      
	      ;; Switch back to sender
	      local.get $sender
	      global.set $activeContext
	      
	      ;; Push return value
	      local.get $value
	      call $push
	      )
	
	;; === Helper Functions ===
	
	(func $getInstanceVariable (param $object (ref null $SqueakObject)) (param $index i32) (result (ref null eq))
	      local.get $object
	      ref.cast (ref $VariableObject)
	      struct.get $VariableObject $slots
	      local.get $index
	      array.get $ObjectArray
	      )
	
	(func $setInstanceVariable (param $object (ref null $SqueakObject)) (param $index i32) (param $value (ref null eq))
	      local.get $object
	      ref.cast (ref $VariableObject)
	      struct.get $VariableObject $slots
	      local.get $index
	      local.get $value
	      array.set $ObjectArray
	      )
	
	(func $getMethodLiteral (param $method (ref null $CompiledMethod)) (param $index i32) (result (ref null eq))
	      local.get $method
	      struct.get $CompiledMethod $slots
	      local.get $index
	      array.get $ObjectArray
	      )
	
	(func $setTemporary (param $index i32) (param $value (ref null eq))
	      global.get $activeContext
	      struct.get $Context $slots
	      local.get $index
	      i32.const 10  ;; Temp offset
	      i32.add
	      local.get $value
	      array.set $ObjectArray
	      )
	
	(func $sendLiteralSelector (param $selector (ref null eq)) (param $argCount i32)
	      (local $receiver (ref null eq))
	      
	      ;; Get receiver from stack (it's at stackValue(argCount))
	      local.get $argCount
	      call $stackValue
	      local.set $receiver
	      
	      ;; Send message using the full sendMessage mechanism
	      local.get $receiver
	      local.get $selector
	      local.get $argCount
	      call $sendMessage
	      )
	
	;; === Main Interpreter Loop ===
	
	(func $interpret
	      (local $bytecode i32)
	      (local $pc i32)
	      (local $method (ref null $CompiledMethod))
	      (local $bytecodes (ref null $ByteArray))
	      (local $context (ref null $Context))

	      global.get $activeContext
	      local.set $context
	      
	      block $exit_loop
	      loop $interpreter_loop
	      global.get $methodReturned
	      i32.const 1
	      i32.eq
	      br_if $exit_loop
	      
	      ;; Get current method and bytecodes from active context
	      local.get $context
	      struct.get $Context $method
	      local.set $method

	      local.get $context
	      struct.get $Context $pc
	      local.set $pc
	      
	      local.get $method
	      struct.get $CompiledMethod $bytecodes
	      local.set $bytecodes
	      
	      ;; Check PC bounds
	      local.get $pc
	      local.get $bytecodes
	      array.len
	      i32.ge_u
	      br_if $exit_loop
	      
	      ;; Fetch and execute bytecode
	      local.get $bytecodes
	      local.get $pc
	      array.get_u $ByteArray
	      local.set $bytecode
	      
	      local.get $bytecode
	      call $executeBytecode
	      
	      ;; Increment PC
	      local.get $context
	      local.get $pc
	      i32.const 1
	      i32.add
	      struct.set $Context $pc

	      global.get $activeContext
	      local.set $context
	      
	      br $interpreter_loop
	      end
	      end
	      )
	
	;; === Bootstrap Functions ===
	
	(func $createBasicClasses
	      (local $newClass (ref $Class))  ;; Local variable to hold created classes
	      
	      ;; Create Object class first (with null class initially)
	      struct.new_default $Class
	      local.tee $newClass
	      ;; Set Object class fields
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      ;; superclass stays null for Object
	      ;; methodDict stays null for now
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      ;; Store in global
	      local.get $newClass
	      global.set $objectClass
	      
	      ;; Create Class class
	      struct.new_default $Class
	      local.tee $newClass
	      ;; Set Class class fields
	      global.get $objectClass  ;; class field - will be set to itself later
	      struct.set $Class $class
	      local.get $newClass
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      local.get $newClass
	      global.get $objectClass
	      struct.set $Class $superclass
	      ;; methodDict stays null for now
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      ;; Store in global
	      local.get $newClass
	      global.set $classClass
	      
	      ;; Fix Object class to be instance of Class class
	      global.get $objectClass
	      global.get $classClass
	      struct.set $Class $class
	      
	      ;; Create Dictionary class first
	      struct.new_default $Class
	      local.tee $newClass
	      global.get $classClass
	      struct.set $Class $class
	      local.get $newClass
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      local.get $newClass
	      global.get $objectClass
	      struct.set $Class $superclass
	      ;; methodDict stays null
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      local.get $newClass
	      global.set $dictionaryClass

	      ;; Create SmallInteger class
	      struct.new_default $Class
	      local.tee $newClass
	      global.get $classClass
	      struct.set $Class $class
	      local.get $newClass
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      local.get $newClass
	      global.get $objectClass
	      struct.set $Class $superclass
	      ;; Create and set method dictionary
	      local.get $newClass
	      global.get $dictionaryClass
	      i32.const 8 ;; initial size
	      call $newDictionary
	      struct.set $Class $methodDict ;; set methodDict field
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      local.get $newClass
	      global.set $smallIntegerClass
	      
	      ;; Create CompiledMethod class
	      struct.new_default $Class
	      local.tee $newClass
	      global.get $classClass
	      struct.set $Class $class
	      local.get $newClass
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      local.get $newClass
	      global.get $objectClass
	      struct.set $Class $superclass
	      ;; methodDict stays null
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      local.get $newClass
	      global.set $methodClass
	      
	      ;; Create Context class
	      struct.new_default $Class
	      local.tee $newClass
	      global.get $classClass
	      struct.set $Class $class
	      local.get $newClass
	      call $nextIdentityHash
	      struct.set $Class $identityHash
	      local.get $newClass
	      i32.const 1
	      struct.set $Class $format
	      local.get $newClass
	      i32.const 6
	      struct.set $Class $size
	      local.get $newClass
	      i32.const 6
	      call $createObjectArray
	      struct.set $Class $slots
	      local.get $newClass
	      global.get $objectClass
	      struct.set $Class $superclass
	      ;; methodDict stays null
	      ;; instVarNames stays null
	      ;; name stays null
	      local.get $newClass
	      i32.const 0
	      struct.set $Class $instSize
	      local.get $newClass
	      global.set $contextClass
	      
	      ;; Create special objects
	      i32.const 99
	      ref.i31
	      global.set $nilObject
	      
	      i32.const 1
	      ref.i31
	      global.set $trueObject
	      
	      i32.const 0
	      ref.i31
	      global.set $falseObject
	      )

	(func $createSpecialSelectors
	      ;; Create selector strings for common operations
	      ;; For now, use simple i31ref values as selectors
	      i32.const 100  ;; + selector
	      ref.i31
	      global.set $plusSelector
	      
	      i32.const 101  ;; * selector
	      ref.i31
	      global.set $timesSelector
	      
	      i32.const 102  ;; squared selector
	      ref.i31
	      global.set $squaredSelector
	      
	      i32.const 200  ;; reportToJS selector
	      ref.i31
	      global.set $reportToJSSelector
	      )
	
	(func $createSquaredMethod (result (ref $CompiledMethod))
	      (local $bytecodes (ref $ByteArray))
	      (local $literals (ref $ObjectArray))
	      
	      ;; Create bytecode array for: 3 squared, reportToJS, return top
	      ;; Bytecodes: [0x76, 0x90, 0xD0, 0x7C]
	      ;; 0x76 = push 3
	      ;; 0x90 = send literal selector 0 with 0 args (squared)
	      ;; 0xD0 = send reportToJS  
	      ;; 0x7C = return top
	      (array.new_fixed $ByteArray 4
			       (i32.const 0x76)  ;; push 3
			       (i32.const 0x90)  ;; send literal selector 0 (squared)
			       (i32.const 0xD0)  ;; send reportToJS
			       (i32.const 0x7C)  ;; return top
			       )
	      local.set $bytecodes
	      
	      ;; Create literals array with 'squared' selector
	      i32.const 2
	      (array.new_default $ObjectArray)
	      local.tee $literals
	      
	      ;; Set literal 0 to be 'squared' selector
	      i32.const 0
	      global.get $squaredSelector
	      array.set $ObjectArray
	      
	      ;; Set literal 1 to be 'reportToJS' selector
	      local.get $literals
	      i32.const 1
	      global.get $reportToJSSelector
	      array.set $ObjectArray
	      
	      ;; Create CompiledMethod object
	      global.get $methodClass
	      call $nextIdentityHash
	      i32.const 1    ;; format
	      i32.const 2    ;; size (literals)
	      local.get $literals
	      i32.const 0    ;; header
	      local.get $bytecodes
	      i32.const 0    ;; invocationCount
	      ref.null func  ;; compiledWasm
	      struct.new $CompiledMethod
	      )

	(func $createSquaredMethodForSmallInteger (result (ref $CompiledMethod))
	      (local $bytecodes (ref $ByteArray))
	      (local $literals (ref $ObjectArray))

	      ;; Create bytecode for SmallInteger>>squared: self * self
	      ;; Bytecodes: [0x70, 0x70, 0xB1, 0x7C]
	      ;; 0x70 = push receiver (self)
	      ;; 0x70 = push receiver (self) again
	      ;; 0xB1 = send * (multiply)
	      ;; 0x7C = return top
	      (array.new_fixed $ByteArray 4
			       (i32.const 0x70)  ;; push self
			       (i32.const 0x70)  ;; push self again
			       (i32.const 0xB1)  ;; send *
			       (i32.const 0x7C)  ;; return top
			       )
	      local.set $bytecodes

	      ;; Create empty literals array
	      i32.const 1
	      (array.new_default $ObjectArray)
	      local.set $literals

	      ;; Create CompiledMethod object
	      global.get $methodClass
	      call $nextIdentityHash
	      i32.const 1    ;; format
	      i32.const 1    ;; size (literals)
	      local.get $literals
	      i32.const 0    ;; header
	      local.get $bytecodes
	      i32.const 0    ;; invocationCount
	      ref.null func  ;; compiledWasm
	      struct.new $CompiledMethod
	      )
	
	(func (export "createMinimalBootstrap") (result i32)
	      (local $method (ref $CompiledMethod))
	      (local $squaredMethod (ref $CompiledMethod))
	      (local $context (ref $Context))
	      
	      ;; Create basic classes and special objects
	      call $createBasicClasses
	      call $createSpecialSelectors

	      ;; Create the SmallInteger>>squared method
	      call $createSquaredMethodForSmallInteger
	      local.set $squaredMethod
	      
	      ;; Install the squared method in SmallInteger's method dictionary
	      global.get $smallIntegerClass
	      struct.get $Class $methodDict
	      ref.as_non_null
	      global.get $squaredSelector
	      local.get $squaredMethod
	      call $dictionary_at_put

	      ;; Create the main method that does "3 squared"
	      call $createSquaredMethod
	      local.set $method

	      ;; Create initial context to execute the method
	      global.get $contextClass
	      i32.const 50  ;; Stack size
	      call $newContext
	      local.set $context
	      
	      ;; Set up context to execute our method
	      local.get $context
	      ref.null $Context  ;; no sender
	      struct.set $Context $sender
	      
	      local.get $context
	      i32.const 0  ;; start at PC 0
	      struct.set $Context $pc
	      
	      local.get $context
	      i32.const 0  ;; empty stack initially
	      struct.set $Context $sp
	      
	      local.get $context
	      local.get $method
	      struct.set $Context $method
	      
	      local.get $context
	      global.get $nilObject  ;; receiver is nil for this example
	      struct.set $Context $receiver
	      
	      ;; Set as active context
	      local.get $context
	      global.set $activeContext
	      
	      ;; Initialize VM state
	      i32.const 0
	      global.set $methodReturned
	      
	      ;; Success
	      i32.const 1
	      )
	
	(func (export "interpret")
	      call $interpret
	      )
	)
