# Catalyst Smalltalk Virtual Machine

Catalyst is a self-hosted [Open Smalltalk]
(https://github.com/OpenSmalltalk/opensmalltalk-vm) virtual machine
and object memory, written in Smalltalk and decompiled to [WASM
GC](https://github.com/WebAssembly) for operation in web browsers. It
uses AI-assisted dynamic method translation to optimize high-frequency
code paths. Each Catalyst module can run multiple concurrent systems,
and uses this ability to provide continuity of operation across class
type changes. Catalyst leverages JavaScript for finalization and host
device driver access, and uses SqueakJS as an environment for
simulation, debugging, and deployment.

## 🚀 Key Features

- **Runtime Bytecode-to-WASM Translation**: Translates Smalltalk bytecodes to WebAssembly Text (WAT) format at runtime
- **Hot Method Detection**: Automatically identifies frequently-executed methods for translation
- **AI-Assisted Optimization**: Uses LLM integration for intelligent method translation
- **Performance Monitoring**: Tracks method translation activity and performance metrics
- **Debug Support**: Detailed logging and single-step debugging capabilities
- **Open Smalltalk Compatibility**: Maintains compatibility with Open Smalltalk architecture
- **Multi-System Support**: Each Catalyst module can run multiple concurrent systems

## 🏗️ Architecture

Catalyst uses a hybrid approach where methods start as interpreted
bytecode and get translated to optimized WASM when they become "hot"
(frequently executed). This provides the flexibility of interpretation
with the performance of compiled code.

The system is self-hosted - it's an Open Smalltalk virtual machine and
object memory, written in Smalltalk and decompiled to WASM GC for
operation in web browsers. JavaScript is leveraged for finalization
and host device driver access.

## 📋 Prerequisites

- **Node.js 16+**: Build system and development server, to be replaced
  by SqueakJS in the future
- **wasm-tools**: WASM toolchain for analysis (optional)
- **wasm-opt**: WASM optimization (optional)

### Installation

```bash
# Install wasm-tools
cargo install wasm-tools
# OR
brew install wasm-tools

# Install dependencies
npm install
```

## 🛠️ Quick Start

```bash
# Build the project (compiles WAT to WASM)
npm run build

# Start with LLM integration
npm run start-with-llm
```

Open your browser to `http://localhost:8000` and load `test.html` to interact with the VM.

## 📁 Project Structure

```
catalyst/
├── catalyst.wat          # Main WASM source code (WebAssembly Text format)
├── catalyst.js           # JavaScript VM interface and method translation engine
├── catalyst.wasm         # Compiled WASM binary (generated)
├── build.js              # Main build script
├── test.html             # Interactive test page
├── serve-coi.js          # Development server with Cross-Origin-Isolation
├── api-proxy.js          # Proxy server for LLM API integration
└── dist/                 # Build output directory
```

## 🔧 Build System

The build system (`build.js`) performs:

1. Compiles `catalyst.wat` to `catalyst.wasm` using `wasm-tools parse`
2. Copies JavaScript files to `dist/`
3. Generates WASM module analysis dump
4. Updates package metadata with build timestamp

Eventually, SqueakJS will do all of this; catalyst.js already does LLM
prompting, WAT-to-WASM compilation, and caching of WASM functions in
the Catalyst method cache.

## 🎯 Development Phases

### Phase 1 ✅
Handwritten interpreter supporting single method evaluation `(3 + 4)`

### Phase 2 ✅
Message sending support with `(3 squared)` - actual message dispatch instead of just bytecode execution

### Phase 3 ✅ (Current)
**Method Translation Foundation Complete**
- Runtime bytecode-to-WASM translation
- Hot method detection and polymorphic inline caching
- Performance comparison between interpretation, naïve translation, and LLM translation

### Phase 4 (Planned)
Generate interpreter by decompiling equivalent Smalltalk
implementation using
[Epigram](https://thiscontext.com/2022/06/28/epigram-reifying-grammar-production-rules-for-clearer-parsing-compiling-and-searching/)
compilation framework

### Phase 5-9 (Roadmap)
- Object memory snapshots and transfer between VMs
- Sista instruction set support
- Enhanced adaptive optimization
- Naiad module system support
- Compatibility with Squeak, Pharo, and Cuis object memories

## 🧪 Testing

- Manual testing via `test.html` in browser
- Performance benchmarks compare interpretation vs. translated methods

## 🌐 Cross-Origin Isolation

The project requires Cross-Origin-Isolation headers for WASM GC and SharedArrayBuffer support:

- Development server (`serve-coi.js`) automatically sets required headers
- `.htaccess` configuration provided for Apache deployment
- `.well-known/` directory structure for proper COOP/COEP headers

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

This is a research project exploring WebAssembly-based virtual machine implementation with AI-assisted optimization. Contributions and discussions about the architecture and implementation approaches are welcome.

