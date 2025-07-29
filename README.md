# Catalyst Smalltalk Virtual Machine

Catalyst is a self-hosted [Open Smalltalk](https://github.com/OpenSmalltalk/opensmalltalk-vm) virtual machine
and object memory, written in Smalltalk and decompiled to [WASM
GC](https://github.com/WebAssembly) for operation in web browsers. It
uses AI-assisted dynamic method translation to optimize high-frequency
code paths. Each Catalyst module can run multiple concurrent systems,
and uses this ability to provide continuity of operation across class
type changes. Catalyst leverages JavaScript for finalization and host
device driver access, and uses [SqueakJS](https://squeak.js.org) as an environment for
simulation, debugging, and deployment.

## 🚀 Key Features

- **Runtime Bytecode-to-WASM Translation**: Translates Smalltalk
  bytecodes to WebAssembly Text (WAT) format at runtime
- **Hot Method Detection**: Automatically identifies
  frequently-executed methods for translation
- **AI-Assisted Optimization**: Uses LLM integration for intelligent
  method translation
- **Performance Monitoring**: Tracks method translation activity and
  performance metrics
- **Debug Support**: Detailed logging and single-step debugging
  capabilities
- **Open Smalltalk Compatibility**: Maintains compatibility with Open
  Smalltalk architecture
- **Multi-System Support**: Each Catalyst module can run multiple
  concurrent systems

## 🏗️ Architecture

Catalyst uses a hybrid approach where methods start as interpreted
bytecode and get translated to optimized WASM when they become "hot"
(frequently executed). This provides the flexibility of interpretation
with the performance of compiled code.

Read more at [the thisContext blog](https://thiscontext.com).

## Workflow

I've been experimenting with AI coding assistance to accelerate
Catalyst's development, and found it very productive. I'm currently
using [Kiro](https://kiro.dev), and prefer it to alternatives such as
Cursor, Windsurf, Claude Code, Claude Projects, and CHatGPT projects,
primarily because of its approach to specification-driven
development. This repo has several documents that make AI-assisted
development more productive, including AGENTS.md and the steering
documents in .kiro/.

## 📋 Prerequisites

- **Kiro**: AI-assisted IDE (optional)
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
node build.js

# Start with LLM integration
node start-with-llm.js
```

Open your browser to `http://localhost:8000/test.html` to benchmark the VM.

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

Eventually, SqueakJS will do all of this; catalyst.js currently does
LLM prompting, WAT-to-WASM compilation, and caching of WASM functions
in the Catalyst method cache.

## 🎯 Development Phases

### Phase 1 ✅
Handwritten interpreter supporting single method evaluation `(3 + 4)`

### Phase 2 ✅
Message sending support with `(3 benchmark)` - actual message dispatch
instead of just bytecode execution

### Phase 3 ✅ (Current)
**Method Translation Foundation Complete**
- Runtime bytecode-to-WASM translation
- Hot method detection and polymorphic inline caching
- Performance comparison between interpretation, naïve translation,
  and LLM translation

### Phase 4
Generate interpreter by decompiling equivalent Smalltalk
implementation using
[Epigram](https://thiscontext.com/2022/06/28/epigram-reifying-grammar-production-rules-for-clearer-parsing-compiling-and-searching/)
compilation framework

### Phase 5-9 (Roadmap)
- Object memory snapshots and transfer between VMs
- Sista instruction set support
- Enhanced adaptive optimization
- Naiad module system support
- Compatibility with [Squeak](https://squeak.org),
  [Pharo](https://pharo.org), and [Cuis](https://cuis.st) object
  memories

## 🧪 Testing

- Manual testing via `test.html` in browser
- Performance benchmarks compare interpretation vs. translated methods

## 🌐 Cross-Origin Isolation

The project requires Cross-Origin-Isolation headers for WASM GC and
SharedArrayBuffer support:

- Development server (`serve-coi.js`) automatically sets required headers
- `.htaccess` configuration provided for Apache deployment
- `.well-known/` directory structure for proper COOP/COEP headers

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

This is a research project exploring WebAssembly-based virtual machine
implementation with AI-assisted optimization. Contributions and
discussions about the architecture and implementation approaches are
welcome.

## 🙏 Acknowledgements

Special thanks to...
- [Dan Ingalls](https://en.wikipedia.org/wiki/Dan_Ingalls) for Smalltalk
- [Vanessa Freudenberg](https://github.com/codefrau) for SqueakJS
- [Eliot Miranda](http://www.mirandabanda.org/cogblog/) for Cog
- the WebAssembly community

