# Function Table Approach for Method Translation in WebAssembly

## The Question

> "But you must reserve and wire those table slots at instantiation time." Does the actual function have to exist at that time?

## The Answer

**No, the actual function does not need to exist at instantiation time.** However, the function table slots must be declared and sized in advance.

## How It Works

### 1. Function Table Declaration (At Instantiation Time)

In the WASM module (`catalyst.wat`):
```wat
;; Function table for translated methods
(table $functionTable (export "functionTable") 100 funcref)
```

This reserves 100 slots in a `funcref` table, but the contents can be left null.

### 2. Function Table Initialization (After Instantiation)

In JavaScript (`catalyst.js`):
```javascript
initializeFunctionTable() {
    const functionTable = this.wasmModule.instance.exports.functionTable;
    if (functionTable && typeof functionTable.set === 'function') {
        // Initialize all 100 slots with null (ref.null funcref)
        for (let i = 0; i < 100; i++) {
            functionTable.set(i, null);
        }
    }
}
```

### 3. Dynamic Function Compilation (At Runtime)

When a method becomes "hot" (executed frequently), the method translator:

1. **Translates bytecode to WAT**: Translates Squeak bytecode to WebAssembly Text format
2. **Creates a new WASM module**: Compiles the WAT to a separate WASM module
3. **Extracts the function**: Gets the translated function from the new module
4. **Stores in function table**: Places the function in an available slot

```javascript
async translateMethodToWASM(methodPtr, bytecodePtr, bytecodeLen) {
    // ... translate bytecode to WAT ...
    const watCode = this.translateBytecodeToWAT(bytecodeArray);
    
    // Compile WAT to WASM function that can be stored in function table
    const translatedFunction = await this.compileWATToFunction(watCode);
    
    // Get the next available function table index
    const functionIndex = this.stats.methodTranslations;
    
    // Store the translated function in the WASM function table
    const functionTable = this.wasmModule.instance.exports.functionTable;
    functionTable.set(functionIndex, translatedFunction);
    
    // Return function table index for WASM to use with call_indirect
    return functionIndex;
}
```

### 4. Function Execution (Via call_indirect)

The WASM module can call the translated function using `call_indirect`:

```wat
(func $executeTranslatedFunction
  (param $context (ref null $Context))
  (param $functionIndex i32)
  (result i32)
  ;; Call the translated function directly using call_indirect
  local.get $context
  ref.as_non_null
  local.get $functionIndex
  call_indirect (type $translation_func_type)
)
```

## Key Requirements

### ✅ What Must Be Declared at Instantiation
- **Table declaration**: `(table $functionTable 100 funcref)`
- **Table size**: 100 slots
- **Function type signature**: `(type $translation_func_type (func (param (ref null $Context)) (result i32)))`

### ❌ What Does NOT Need to Exist at Instantiation
- **Actual functions**: Can be null initially
- **Translated code**: Generated dynamically at runtime
- **Function implementations**: Created on-demand

### ✅ What Must Match
- **Function signatures**: All functions in the table must match the declared type
- **Parameter types**: Must be compatible with `call_indirect` expectations
- **Return types**: Must match the expected return type

## Benefits of This Approach

1. **Dynamic Translation**: Functions can be translated and added at runtime
2. **Type Safety**: WebAssembly ensures all functions have the correct signature
3. **Performance**: `call_indirect` is fast and efficient
4. **Memory Management**: Functions are stored in the WASM function table, not JavaScript
5. **Isolation**: Each translated function runs in its own WASM context

## Example Flow

```
1. WASM Module Instantiation
   ├── Function table declared (100 slots)
   ├── All slots initialized to null
   └── Module ready for execution

2. Runtime Execution
   ├── Method executed 10+ times (hot detection)
   ├── method translation triggered
   ├── Bytecode → WAT → WASM function
   └── Function stored in table slot N

3. Optimized Execution
   ├── Method called again
   ├── call_indirect to slot N
   └── Translated function executes directly
```

## Testing

The implementation includes a test function to verify the function table approach:

```javascript
testFunctionTable() {
    const functionTable = this.wasmModule.instance.exports.functionTable;
    
    // Check table size
    console.log(`Function table size: ${functionTable.length}`);
    
    // Check initial values (should be null)
    let nullCount = 0;
    for (let i = 0; i < 10; i++) {
        if (functionTable.get(i) === null) nullCount++;
    }
    console.log(`First 10 slots - null values: ${nullCount}/10`);
}
```

## Conclusion

This approach provides the flexibility needed for method translation while maintaining WebAssembly's type safety and performance characteristics. The function table acts as a bridge between the static WASM module and dynamically translated code, allowing for efficient runtime optimization without compromising the security and performance benefits of WebAssembly. 
