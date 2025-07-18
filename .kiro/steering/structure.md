# Project Structure

## Root Directory

### Core Files
- `catalyst.wat` - Main WASM source code (WebAssembly Text format)
- `catalyst.js` - JavaScript VM interface and method translation engine
- `catalyst.wasm` - Compiled WASM binary (generated from .wat)
- `catalyst.dump` - WASM module analysis output (generated)

### Build System
- `build.js` - Main build script (compiles WAT to WASM)
- `package.json` - Node.js project configuration and scripts
- `serve-coi.js` - Development server with Cross-Origin-Isolation headers
- `api-proxy.js` - Proxy server for LLM API integration
- `start-with-llm.js` - LLM integration startup script

### Testing & Demo
- `test.html` - Interactive test page for VM functionality
- `keys` - API keys file (not in source control)

### Documentation
- `README.md` - Main project documentation
- `AGENT.md` - AI assistant instructions and workflow
- `squeakjs_wasm_conversion.md` - Technical roadmap and architecture
- `FUNCTION_TABLE_APPROACH.md` - Implementation details
- `LLM_OPTIMIZATION_DEMO.md` - LLM integration documentation

## Build Output (`dist/`)

Generated directory containing:
- `catalyst.wasm` - Compiled WASM module
- `catalyst.js` - JavaScript runtime
- `test.html` - Test interface
- `package-info.json` - Build metadata
- `.well-known/` - Cross-Origin-Isolation configuration
- `.htaccess` - Web server configuration

## Configuration

### Kiro IDE (`.kiro/`)
- `steering/` - AI assistant guidance documents
  - `product.md` - Product overview
  - `tech.md` - Technology stack and build system
  - `structure.md` - This file

### Web Configuration
- `.htaccess` - Apache configuration for WASM serving
- Cross-Origin-Isolation headers required for SharedArrayBuffer

## File Naming Conventions

- **WASM files**: `catalyst.wat` (source), `catalyst.wasm` (compiled)
- **Documentation**: UPPERCASE.md for major docs, lowercase.md for technical specs
- **Build outputs**: Mirror source names in `dist/` directory
- **Configuration**: Hidden directories (`.kiro/`, `.git/`)

## Development Workflow

1. Edit `catalyst.wat` or `catalyst.js`
2. Run `npm run build` to compile
3. Test via `npm run serve` and browser
4. Build outputs go to `dist/` directory
5. Always rebuild after code changes

## Key Directories to Ignore

- `.git/` - Git version control
- `dist/` - Generated build outputs
- `.DS_Store` - macOS system files