/**
 * SqueakJS to WASM VM - JavaScript Interface
 * Provides the JavaScript side of the VM implementation
 */

class SqueakWASMVM {
    constructor() {
        this.vmModule = null;
        this.results = [];
    }

    async initialize() {
        const imports = {
            system: {
                reportResult: (value) => {
                    console.log(`Smalltalk result: ${value}`);
                    this.results.push(value);
                    if (this.onResult) {
                        this.onResult(value);
                    }
                },
                currentTimeMillis: () => Date.now(),
                consoleLog: (stringRef) => {
                    // TODO: Extract string from WASM GC string reference
                    console.log('Smalltalk log:', stringRef);
                }
            }
        };

        try {
            // Load the WASM module
            const response = await fetch('squeak-vm-core.wasm');
            const bytes = await response.arrayBuffer();
            const module = await WebAssembly.compile(bytes);
            this.vmModule = await WebAssembly.instantiate(module, imports);
            
            console.log('SqueakWASM VM initialized successfully');
            return true;
        } catch (error) {
            console.error('Failed to initialize SqueakWASM VM:', error);
            return false;
        }
    }

    async runMinimalExample() {
        if (!this.vmModule) {
            throw new Error('VM not initialized. Call initialize() first.');
        }

        try {
            // Create minimal bootstrap
            const success = this.vmModule.exports.createMinimalBootstrap();
            if (!success) {
                throw new Error('Failed to create minimal bootstrap');
            }

            console.log('Running 3 + 4 example...');
            
            // Clear results
            this.results = [];
            
            // Run the interpreter
            this.vmModule.exports.interpret();
            
            console.log('Execution completed');
            return this.results;
        } catch (error) {
            console.error('Error running minimal example:', error);
            throw error;
        }
    }

    getResults() {
        return [...this.results];
    }

    setResultCallback(callback) {
        this.onResult = callback;
    }
}

// Export for use in browsers or Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SqueakWASMVM;
} else if (typeof window !== 'undefined') {
    window.SqueakWASMVM = SqueakWASMVM;
}
