# SqueakJS WASM VM - Phase 3: JIT Compilation

## Overview

Phase 3 introduces Just-In-Time (JIT) compilation to the SqueakJS WASM virtual machine, providing significant performance improvements for hot Smalltalk methods. This implementation leverages WebAssembly's function references and garbage collection features to create a dynamic compilation system.

The demonstration uses **"3 squared"** which exercises proper method context creation and message sending - when `3` sends the `squared` message, it creates a new context to execute the `SmallInteger>>squared` method that performs `self * self`.

## 🚀 Key Features

### JIT Compilation Engine
- **Hot Method Detection**: Tracks method invocation counts to identify frequently executed code
- **Bytecode Analysis**: Analyzes Smalltalk bytecode patterns for optimization opportunities  
- **Dynamic WASM Generation**: Translates hot bytecodes to optimized WASM instructions
- **Function Caching**: Maintains a cache of compiled methods with LRU eviction

### Performance Optimizations
- **Fast Path Arithmetic**: Optimized i31ref SmallInteger operations bypass message sending
- **Polymorphic Inline Caching**: Caches method lookups for common receiver types
- **Stack Management**: Efficient WASM-based execution stack for compiled methods
- **Type Specialization**: Specialized code paths for common Smalltalk patterns

### Monitoring and Analysis
- **Real-time Statistics**: Tracks compilation rates, cache efficiency, and execution patterns
- **Performance Counters**: Detailed metrics for JIT effectiveness analysis
- **Adaptive Thresholds**: Configurable compilation triggers based on method hotness

## 🏗️ Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Bytecode      │───▶│  JIT Compiler    │───▶│  Compiled WASM  │
│   Interpreter   │    │                  │    │  Functions      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Method Cache   │    │  Hotness Tracker │    │  Function Cache │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### JIT Compilation Pipeline

1. **Invocation Counting**: Each method tracks its call frequency
2. **Hotness Analysis**: Methods exceeding threshold trigger compilation
3. **Bytecode Translation**: Smalltalk bytecodes convert to WASM instructions
4. **Optimization**: Apply fast-path optimizations for common patterns
5. **Caching**: Store compiled functions for future invocations
6. **Execution**: Hot methods execute via compiled WASM instead of interpreter

## 📊 Performance Characteristics

### JIT Compilation Triggers
- **Basic Compilation**: 100+ method invocations
- **Optimization**: 1000+ invocations (future phase)
- **Cache Size**: 512 compiled methods maximum
- **Eviction**: Least Recently Used (LRU) policy

### Expected Performance Gains
- **SmallInteger Multiplication**: 5-10x faster than interpreted (critical for `squared` method)
- **Method Context Creation**: 2-3x reduction in overhead for message sends
- **Memory Efficiency**: Compiled methods use ~50% less stack space
- **Cache Hit Rate**: 85-95% for typical Smalltalk workloads
- **Message Send Optimization**: Direct WASM calls instead of method lookup for hot methods

## 🛠️ Implementation Details

### WASM GC Integration

The JIT compiler leverages WASM GC features for efficient object management:

```wat
;; Compiled method caching using WASM GC
(type $JITEntry (struct 
  (field $method (ref $CompiledMethod))
  (field $compiledFunc (ref null func))
  (field $compilationLevel i32)
  (field $lastUsed i64)
))

;; JIT compiled version of SmallInteger>>squared method
;; Original bytecodes: [0x70, 0x70, 0xB1, 0x7C] (push self, push self, send *, returnTop)
(func $compiled_squared (param $context (ref $Context)) (result (ref eq))
  (local $receiver (ref eq))
  
  ;; Get receiver (self) from context
  local.get $context
  struct.get $Context $receiver
  local.tee $receiver
  
  ;; Fast path for SmallInteger multiplication: self * self
  local.get $receiver
  ref.test i31
  if (result (ref eq))
    ;; Both operands are the same i31ref SmallInteger
    local.get $receiver
    ref.cast i31
    i31.get_s
    
    ;; self * self
    local.get $receiver
    ref.cast i31
    i31.get_s
    
    i32.mul
    
    ;; Check for overflow (simplified)
    local.tee $result
    i32.const -1073741824  ;; SmallInteger min
    i32.ge_s
    local.get $result
    i32.const 1073741823   ;; SmallInteger max
    i32.le_s
    i32.and
    if (result (ref eq))
      ;; No overflow - return result as SmallInteger
      local.get $result
      ref.i31
    else
      ;; Overflow - fall back to message send
      local.get $receiver
      local.get $receiver
      call $sendMultiplyMessage
    end
  else
    ;; Slow path: not a SmallInteger, use message sending
    local.get $receiver
    local.get $receiver
    call $sendMultiplyMessage
  end
)

;; Fast path for SmallInteger multiplication
(func $optimizedMultiply (param $a (ref eq)) (param $b (ref eq)) (result (ref eq))
  ;; Type check: both i31ref?
  local.get $a
  ref.test i31
  local.get $b  
  ref.test i31
  i32.and
  if (result (ref eq))
    ;; Fast path: direct i31 arithmetic
    local.get $a
    ref.cast i31
    i31.get_s
    local.get $b
    ref.cast i31
    i31.get_s
    i32.mul
    ref.i31
  else
    ;; Slow path: message sending
    local.get $a
    local.get $b
    call $sendMultiplyMessage
  end
)
```

### Bytecode Translation Examples

The "3 squared" demonstration exercises these key bytecode translations:

| Smalltalk Bytecode | WASM Translation | Optimization | Usage in Demo |
|-------------------|------------------|--------------|---------------|
| `0x76` (push 3) | `i32.const 3; ref.i31` | Immediate i31ref | Main method pushes 3 |
| `0x90` (send literal 0) | `call $messageSemd` | Method lookup | Sends `squared` message |
| `0x70` (push self) | `local.get $receiver` | Direct local access | SmallInteger>>squared pushes self twice |
| `0xB1` (send *)  | `call $optimizedMultiply` | Fast i31ref multiplication | Core computation in squared method |
| `0x7C` (returnTop) | `return` | Direct WASM return | Both methods return their results |
| `0xD0` (send reportToJS) | `call $system_report_result` | Direct JS interface | Reports final result (9) |

## 🧪 Testing and Validation

### JIT Test Suite

The implementation includes comprehensive testing focused on the "3 squared" computation:

```javascript
// Basic JIT functionality - runs "3 squared" 150 times
await vm.runJITDemo();           // Triggers compilation of SmallInteger>>squared

// Advanced testing
await vm.runAdvancedJITTest();   // Various hotness patterns for squared method
await vm.testCacheEviction();    // Cache management validation
await vm.runBenchmark(1000);     // Performance measurement of 3² computation
```

### Performance Metrics for "3 Squared"

```javascript
const stats = vm.getPerformanceStats();
// Returns: [methodInvocations, interpreterCalls, jitCalls, 
//           compilations, cacheHits, cacheMisses, cacheSize]

// Expected after 150 iterations of "3 squared":
// - SmallInteger>>squared method becomes hot (100+ invocations)
// - JIT compiles squared method to optimized WASM
// - Subsequent calls use compiled multiplication instead of interpretation

const efficiency = {
  jitRatio: jitCalls / methodInvocations,        // ~60-70% after warmup
  cacheHitRate: cacheHits / (cacheHits + cacheMisses), // ~90%+
  compilationRate: compilations / methodInvocations,   // ~1% (1-2 methods compiled)
  expectedResult: 9  // 3 squared = 9
};
```

## 🚀 Quick Start

### Prerequisites

```bash
# Install WebAssembly Binary Toolkit
npm install -g wabt
# or
brew install wabt
```

### Build and Run

```bash
# Build Phase 3 VM with JIT
node build-phase3.js

# Start demo server
cd dist
node serve-demo.js

# Open browser to http://localhost:8080
```

### Usage Example

```javascript
import { SqueakJITVM } from './js/squeak-vm-jit.js';

const vm = new SqueakJITVM();
await vm.initialize();

// Run computation that triggers JIT compilation
vm.onResult = (result) => console.log(`Result: ${result}`); // Expected: 9
await vm.runJITDemo();

// Check performance statistics
const stats = vm.getVisualizationData();
console.log(`JIT efficiency: ${(stats.jitEfficiency * 100).toFixed(1)}%`);
```

## 📈 Performance Analysis

### JIT Compilation Metrics

The system provides detailed performance analytics:

- **Method Hotness Distribution**: Track which methods become hot
- **Compilation Success Rate**: Percentage of methods successfully compiled
- **Cache Efficiency**: Hit/miss ratios and eviction patterns
- **Execution Speed**: Before/after JIT compilation performance
- **Memory Usage**: Compiled vs interpreted method memory footprint

### Real-time Monitoring

```javascript
const monitor = new JITPerformanceMonitor(vm);
monitor.startMonitoring(1000); // Update every second

// View performance trends
monitor.generateReport();
const history = monitor.getHistory();
```

## 🔬 Debugging and Analysis

### Debug Features

- **Compilation Logging**: Detailed traces of JIT compilation decisions
- **Bytecode Dumps**: View original and translated instruction sequences  
- **Cache Inspection**: Examine cached method state and statistics
- **Performance Profiling**: Identify bottlenecks and optimization opportunities

### Diagnostic Tools

```javascript
// Export detailed performance data
const data = vm.exportPerformanceData();

// Clear JIT cache for testing
vm.clearJITCache();

// Reset performance counters
vm.resetPerformanceStats();
```

## 🛣️ Development Roadmap

### Phase 3 Complete ✅
- Hot method detection and compilation (SmallInteger>>squared becomes hot)
- Bytecode-to-WASM translation for multiplication operations
- Method caching with LRU eviction for compiled functions
- Performance monitoring infrastructure with "3 squared" metrics
- SmallInteger multiplication optimization using i31ref arithmetic
- Complete method context creation and message sending demonstration

### Phase 4: Snapshot Loading (Next)
- Squeak image format parsing
- Object memory reconstruction  
- Reference fixing and finalization
- Multi-process resume capability
- **Benefits from JIT**: Faster snapshot loading with compiled methods

### Phase 5: Sista Bytecode Support
- Extended Sista instruction set
- Full closure support with JIT compilation
- Advanced control flow optimizations
- Modern Smalltalk feature support

## 🤝 Contributing

### JIT Compiler Development

When extending the JIT compiler:

1. **Add Bytecode Translations**: Extend `translateBytecode()` with new patterns
2. **Implement Optimizations**: Add fast paths for common Smalltalk idioms
3. **Update Tests**: Include validation for new compilation features
4. **Monitor Performance**: Ensure optimizations provide measurable benefits

### Testing Guidelines

- All JIT optimizations must have fallback to interpreter
- Performance tests should show consistent improvement
- Cache eviction must not cause correctness issues
- Memory usage should remain reasonable under all conditions

## 📚 References

- [WASM GC Specification](https://github.com/WebAssembly/gc) - WebAssembly Garbage Collection
- [Function References](https://github.com/WebAssembly/function-references) - WASM Function Reference Types
- [Squeak Bytecode Sets](http://wiki.squeak.org/squeak/2105) - Original Smalltalk bytecode documentation
- [VM Performance Analysis](https://bibliography.selflanguage.org/performance.html) - Classic VM optimization techniques

---

**Phase 3 Status**: ✅ **Complete** - JIT compilation engine implemented with hot method detection, bytecode translation, and performance monitoring.

**Next Phase**: 🚧 **Phase 4: Snapshot Loading** - Enable loading and resuming existing Squeak snapshots with JIT-accelerated execution.