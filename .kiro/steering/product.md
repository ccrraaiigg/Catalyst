# Catalyst Smalltalk Virtual Machine

Catalyst is a WebAssembly implementation of the SqueakJS Smalltalk virtual machine with integrated runtime method translation from bytecodes to WASM. The project demonstrates hot method detection and translation, converting frequently-executed Smalltalk methods to optimized WebAssembly code at runtime.

## Key Features

- **Runtime Bytecode-to-WASM Translation**: Translates Smalltalk bytecodes to WebAssembly Text (WAT) format at runtime
- **Hot Method Detection**: Automatically identifies frequently-executed methods for translation
- **Performance Monitoring**: Tracks method translation activity and performance metrics
- **Debug Support**: Detailed logging and single-step debugging capabilities
- **SqueakJS Compatibility**: Maintains compatibility with SqueakJS architecture while adding method translation

## Current Phase

Phase 3 - Method Translation Foundation Complete. The VM now demonstrates runtime bytecode-to-WASM translation, establishing the foundation for significant performance improvements.

## Architecture

The system uses a hybrid approach where methods start as interpreted bytecode and get translated to optimized WASM when they become "hot" (frequently executed). This provides the flexibility of interpretation with the performance of compiled code.