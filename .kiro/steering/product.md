# Product Overview

Catalyst is a self-hosted Smalltalk virtual machine written in Smalltalk and compiled to WebAssembly GC for web browsers. It implements AI-assisted dynamic method translation to optimize performance by converting frequently-executed Smalltalk bytecode to optimized WASM at runtime.

## Key Capabilities

- **Runtime Bytecode Translation**: Converts Smalltalk bytecode to WebAssembly Text (WAT) format during execution
- **Hot Method Detection**: Automatically identifies and optimizes frequently-executed methods
- **AI-Assisted Optimization**: Uses LLM integration for intelligent method translation and optimization
- **Multi-System Support**: Each Catalyst module can run multiple concurrent Smalltalk systems
- **Open Smalltalk Compatibility**: Maintains compatibility with Open Smalltalk VM architecture

## Current Phase

Phase 3 (Complete): Method Translation Foundation with runtime bytecode-to-WASM translation, hot method detection, and performance comparison between interpretation and translated methods.

## Target Audience

Research project exploring WebAssembly-based virtual machine implementation with AI-assisted optimization for the Smalltalk community and WebAssembly researchers.