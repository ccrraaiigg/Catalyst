# SqueakJS WASM VM

A WebAssembly implementation of the SqueakJS Smalltalk virtual machine, leveraging WASM GC for efficient object memory management and JIT compilation for performance.

## Overview

This project converts the SqueakJS virtual machine from JavaScript to WebAssembly, providing:

- **WASM GC Object Memory**: Uses WebAssembly's garbage collection for efficient Smalltalk object management
- **i31ref SmallIntegers**: Immediate integer values without object allocation overhead
- **Bytecode Interpreter**: Supports both classic Squeak and Sista instruction sets
- **JIT Compilation**: Hot method compilation to optimized WASM for performance
- **Snapshot Compatibility**: Can load and resume existing Squeak snapshots

## Current Status

🚧 **Early Development** - Currently implements a minimal bootstrap with:
- Basic class hierarchy (Object, Class, Method, Context)
- Simple bytecode interpreter for essential operations
- Example: `3 + 4` computation that reports result to JavaScript

## Quick Start

### Prerequisites

- Node.js 16+ 
- [WebAssembly Binary Toolkit (WABT)](https://github.com/WebAssembly/wabt)

Install WABT:
```bash
# macOS
brew install wabt

# Ubuntu/Debian
apt install wabt

# npm (alternative)
npm install -g wabt
```