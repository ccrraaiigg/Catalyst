# Technology Stack

## Core Technologies

- **WebAssembly GC**: Core VM implementation using WASM GC features
- **WebAssembly Text (WAT)**: Hand-written VM source code in WAT format
- **JavaScript**: VM interface, method translation engine, and host integration
- **Node.js 16+**: Build system and development tooling
- **Smalltalk**: Original VM implementation language (decompiled to WAT)

## Build Tools

- **wasm-tools**: Primary WASM toolchain for parsing, validation, and analysis
- **wasm-opt**: Optional WASM optimization (not currently used in build)
- **Node.js**: Build scripts and development server

## Key Files

- `catalyst.wat`: Main WASM source code (WebAssembly Text format)
- `catalyst.js`: JavaScript VM interface and method translation engine  
- `catalyst.wasm`: Compiled WASM binary (generated from WAT)
- `build.js`: Main build script
- `test.html`: Interactive test interface

## Build Commands

```bash
# Build the project (compiles WAT to WASM)
npm run build

# Start development server
npm run serve

# Start with LLM integration
npm run start-llm

# Development with auto-rebuild
npm run dev

# Development with LLM proxy
npm run dev-with-llm
```

## Build Process

1. Compiles `catalyst.wat` to `catalyst.wasm` using `wasm-tools parse`
2. Copies JavaScript files to `dist/` directory
3. Generates WASM module analysis dump for debugging
4. Updates package metadata with build timestamp

## Development Server

Uses Cross-Origin-Isolation headers required for WASM GC and SharedArrayBuffer:
- `serve-coi.js`: Development server with proper COOP/COEP headers
- `.htaccess`: Apache configuration for production deployment
- Port 8000 default for development

## Testing

Manual testing via `test.html` in web browser - no automated test suite currently implemented.