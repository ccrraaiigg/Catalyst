# Project Structure

## Root Directory Layout

```
catalyst/
├── catalyst.wat          # Main WASM source (WebAssembly Text format)
├── catalyst.js           # JavaScript VM interface & translation engine
├── catalyst.wasm         # Compiled WASM binary (generated)
├── build.js              # Main build script
├── test.html             # Interactive test page
├── serve-coi.js          # Development server with Cross-Origin-Isolation
├── api-proxy.js          # Proxy server for LLM API integration
├── start-with-llm.js     # LLM integration startup script
├── package.json          # Node.js dependencies and scripts
├── .htaccess             # Apache config for COOP/COEP headers
└── dist/                 # Build output directory
```

## Key File Purposes

### Core Implementation
- **catalyst.wat**: Hand-written WebAssembly Text source code containing the VM implementation
- **catalyst.js**: JavaScript interface providing method translation, caching, and host integration
- **catalyst.wasm**: Generated binary from WAT compilation

### Build & Development
- **build.js**: Compiles WAT to WASM, copies files to dist/, generates analysis dumps
- **serve-coi.js**: HTTP server with required Cross-Origin-Isolation headers
- **test.html**: Browser-based test interface for manual VM testing

### Configuration
- **package.json**: Defines build scripts, dependencies, and project metadata
- **.htaccess**: Apache configuration for production deployment headers
- **.gitignore**: Standard Git ignore patterns

### Documentation
- **README.md**: Comprehensive project documentation
- **AGENT.md**: AI assistant workflow and coding guidelines
- **LICENSE**: Project license information

## Generated/Build Artifacts

- `catalyst.wasm`: Compiled from catalyst.wat during build
- `catalyst.dump`: WASM module analysis output
- `dist/`: Build output directory containing deployable files

## Development Workflow

1. Edit `catalyst.wat` for VM changes or `catalyst.js` for JavaScript interface
2. Run `npm run build` to compile WAT to WASM
3. Test via `test.html` in browser using development server
4. Use `catalyst.dump` for WASM module analysis and debugging