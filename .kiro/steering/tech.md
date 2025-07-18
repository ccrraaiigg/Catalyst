# Technology Stack

## Core Technologies

- **WebAssembly (WASM)**: Core VM implementation using WASM GC for object memory
- **WebAssembly Text (WAT)**: Hand-written WASM source code in text format
- **JavaScript**: Runtime interface, method translation engine, and browser integration
- **Node.js**: Build system and development server

## Build System

### Required Tools

- **wasm-tools**: Primary WASM toolchain for compilation and analysis
  - Used for WAT to WASM compilation (`wasm-tools parse`)
  - Used for WASM module analysis (`wasm-tools dump`)
- **wasm-opt**: WASM optimization (optional)
- **Node.js 16+**: Build system and development server

### Installation

```bash
# Install wasm-tools
cargo install wasm-tools
# OR
brew install wasm-tools

# Install dependencies
npm install
```

## Common Commands

### Build and Development

```bash
# Build the project (compiles WAT to WASM)
npm run build

# Serve development version
npm run serve

# Build and serve in one command
npm run dev

# Development with LLM proxy support
npm run dev-with-llm

# Start LLM integration
npm run start-llm
```

### Build Process

The build system (`build.js`) performs:
1. Compiles `catalyst.wat` to `catalyst.wasm` using `wasm-tools parse`
2. Copies JavaScript files to `dist/`
3. Generates WASM module analysis dump
4. Updates package metadata with build timestamp

### Testing

- Manual testing via `test.html` in browser
- No automated test suite currently
- Testing requires human interaction with the web interface

## Key Constraints

- **WASM Tools Only**: Use only `wasm-tools` and `wasm-opt` - no `wat2wasm` or other tools
- **WASM GC Types**: Use `eqref` as common supertype, never `externref`
- **No Python**: All tooling is Node.js/JavaScript based
- **JavaScript Style**: Single-line if statements don't need curly braces