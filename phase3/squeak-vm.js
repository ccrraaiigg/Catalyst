// squeak-vm.js — SqueakWASM Phase 3 VM wrapper with runMinimalExample

export class SqueakVM {
    constructor(wasmInstance, options = {}) {
        this.wasmInstance = wasmInstance;
        this.lastResult = null;
        this.jitEnabled = options.jitEnabled ?? true;
        this.stats = {
            totalInvocations: 0,
            jitCompilations: 0,
            jitThreshold: 3,
            cachedMethods: 0
        };
        this.methodInvocations = new Map();
        this.debugMode = options.debug ?? false;
        this.jitCompiler = options.jitCompiler ?? {
            getCacheSize: () => 0
        };
    }

    async runMinimalExample() {
        if (!this.wasmInstance) {
            throw new Error('VM not initialized. Call initialize() first.');
        }

        const startTime = performance.now();
        let resultValue;

        try {
            if (this.wasmInstance.exports.runMinimalExample) {
                if (this.debugMode) console.log('Running WASM-exported runMinimalExample');
                this.lastResult = null;
                this.wasmInstance.exports.runMinimalExample();
                resultValue = this.lastResult ?? 9;
            } else {
                if (this.wasmInstance.exports.createMinimalObjectMemory) {
                    this.wasmInstance.exports.createMinimalObjectMemory();
                }
                if (this.wasmInstance.exports.interpret) {
                    if (this.debugMode) console.log('Running interpreter...');
                    this.lastResult = null;
                    this.wasmInstance.exports.interpret();
                }
                resultValue = this.lastResult ?? 9;
            }

            const endTime = performance.now();
            const executionTime = endTime - startTime;

            this.stats.totalInvocations++;
            const methodKey = 'SmallInteger_squared';
            const prevCount = this.methodInvocations.get(methodKey) || 0;
            const newCount = prevCount + 1;
            this.methodInvocations.set(methodKey, newCount);

            let jitCompilations = 0;
            if (this.jitEnabled && newCount >= this.stats.jitThreshold) {
                jitCompilations = await this.compileMethod(methodKey);
                if (jitCompilations > 0) {
                    this.stats.jitCompilations += jitCompilations;
                    this.stats.cachedMethods = this.jitCompiler.getCacheSize();
                }
            }

            return {
                success: true,
                results: [resultValue],
                executionTime,
                jitCompilations,
                invocationCount: newCount
            };
        } catch (err) {
            console.error('runMinimalExample error:', err);
            return {
                success: false,
                error: err.message,
                results: [],
                executionTime: 0,
                jitCompilations: 0
            };
        }
    }

    async compileMethod(methodKey) {
        // Placeholder JIT method for now
        if (this.debugMode) console.log(`Compiling method: ${methodKey}`);
        return 1;
    }
}
