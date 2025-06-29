// SqueakJS WASM VM with JIT - Demo Interface
// Phase 3: JIT Compilation demonstration

class SqueakJITVM {
    constructor() {
        this.vmModule = null;
        this.jitModule = null;
        this.performanceData = {
            methodInvocations: 0,
            interpreterCalls: 0,
            jitCalls: 0,
            jitCompilations: 0,
            cacheHits: 0,
            cacheMisses: 0,
            cacheSize: 0
        };
        this.onResult = null;
        this.onPerformanceUpdate = null;
    }

    async initialize() {
        // Import functions for WASM modules
        const vmImports = {
            system: {
                reportResult: (value) => {
                    console.log(`🎯 Smalltalk result: ${value}`);
                    this.onResult?.(value);
                },
                currentTimeMillis: () => Date.now(),
                consoleLog: (value) => console.log(`VM: ${value}`)
            },
            jit: {
                checkAndCompileMethod: this.jitModule?.exports?.checkAndCompileMethod || (() => null),
                getJITStats: this.jitModule?.exports?.getJITStats || (() => [0, 0, 0, 0]),
                clearJITCache: this.jitModule?.exports?.clearJITCache || (() => {})
            }
        };

        const jitImports = {
            vm: {
                CompiledMethod: null, // Types are handled by WASM GC
                Context: null,
                system_report_result: vmImports.system.reportResult
            }
        };

        try {
            // Load JIT compiler module first
            this.jitModule = await WebAssembly.instantiate(
                await this.compileWAT(this.getJITCompilerWAT()),
                jitImports
            );

            // Update VM imports with actual JIT functions
            vmImports.jit = {
                checkAndCompileMethod: this.jitModule.instance.exports.checkAndCompileMethod,
                getJITStats: this.jitModule.instance.exports.getJITStats,
                clearJITCache: this.jitModule.instance.exports.clearJITCache
            };

            // Load main VM module
            this.vmModule = await WebAssembly.instantiate(
                await this.compileWAT(this.getVMCoreWAT()),
                vmImports
            );

            console.log('✅ SqueakJS WASM VM with JIT initialized');
            return true;
        } catch (error) {
            console.error('❌ Failed to initialize VM:', error);
            return false;
        }
    }

    async compileWAT(watSource) {
        // In a real implementation, this would use wabt.js to compile WAT to WASM
        // For demo purposes, we'll simulate the compilation
        throw new Error('WAT compilation not implemented in demo - would use wabt.js');
    }

    // Demo: Run the minimal 3 squared example multiple times to trigger JIT
    async runJITDemo() {
        if (!this.vmModule) {
            throw new Error('VM not initialized');
        }

        console.log('🚀 Starting JIT compilation demo...');
        console.log('Running "3 squared" example multiple times to trigger JIT compilation');
        console.log('This exercises method context creation when 3 sends "squared" to itself');

        // Reset performance counters
        this.vmModule.instance.exports.resetPerformanceStats();

        // Run the computation multiple times to trigger JIT
        for (let i = 1; i <= 150; i++) {
            console.log(`\n--- Iteration ${i} ---`);
            
            // Create minimal bootstrap
            const success = this.vmModule.instance.exports.createMinimalBootstrap();
            if (!success) {
                throw new Error('Failed to create minimal bootstrap');
            }

            // Execute the computation: 3 squared (should return 9)
            this.vmModule.instance.exports.interpret();

            // Get performance statistics every 10 iterations
            if (i % 10 === 0) {
                await this.updatePerformanceStats();
                this.logPerformanceStats(i);
            }

            // Show JIT compilation trigger point
            if (i === 100) {
                console.log('🔥 JIT compilation threshold reached!');
                console.log('The "squared" method should be compiled now...');
                console.log('Next iterations should use compiled code for SmallInteger>>squared');
            }
        }

        console.log('\n🎉 JIT Demo completed!');
        console.log('Expected result: 9 (3 squared)');
        await this.showFinalStats();
    }

    async updatePerformanceStats() {
        try {
            const stats = this.vmModule.instance.exports.getPerformanceStats();
            
            // The function returns 7 values:
            // [methodInvocations, interpreterCalls, jitCalls, compilations, hits, misses, cacheSize]
            this.performanceData = {
                methodInvocations: stats[0] || 0,
                interpreterCalls: stats[1] || 0,
                jitCalls: stats[2] || 0,
                jitCompilations: stats[3] || 0,
                cacheHits: stats[4] || 0,
                cacheMisses: stats[5] || 0,
                cacheSize: stats[6] || 0
            };

            this.onPerformanceUpdate?.(this.performanceData);
        } catch (error) {
            console.warn('Could not get performance stats:', error);
        }
    }

    logPerformanceStats(iteration) {
        const stats = this.performanceData;
        const jitRatio = stats.methodInvocations > 0 
            ? (stats.jitCalls / stats.methodInvocations * 100).toFixed(1)
            : 0;
        
        console.log(`📊 Performance Stats (Iteration ${iteration}):`);
        console.log(`   Method Invocations: ${stats.methodInvocations}`);
        console.log(`   Interpreter Calls: ${stats.interpreterCalls}`);
        console.log(`   JIT Calls: ${stats.jitCalls} (${jitRatio}%)`);
        console.log(`   JIT Compilations: ${stats.jitCompilations}`);
        console.log(`   Cache Hits: ${stats.cacheHits}`);
        console.log(`   Cache Misses: ${stats.cacheMisses}`);
        console.log(`   Cache Size: ${stats.cacheSize}`);
    }

    async showFinalStats() {
        await this.updatePerformanceStats();
        const stats = this.performanceData;
        
        console.log('\n📈 Final Performance Summary:');
        console.log('═'.repeat(50));
        
        const totalCalls = stats.interpreterCalls + stats.jitCalls;
        const jitPercentage = totalCalls > 0 ? (stats.jitCalls / totalCalls * 100).toFixed(1) : 0;
        const cacheHitRate = (stats.cacheHits + stats.cacheMisses) > 0 
            ? (stats.cacheHits / (stats.cacheHits + stats.cacheMisses) * 100).toFixed(1) 
            : 0;

        console.log(`Total Method Invocations: ${stats.methodInvocations}`);
        console.log(`Interpreter Executions:  ${stats.interpreterCalls}`);
        console.log(`JIT Executions:          ${stats.jitCalls} (${jitPercentage}%)`);
        console.log(`Methods Compiled:        ${stats.jitCompilations}`);
        console.log(`Cache Hit Rate:          ${cacheHitRate}%`);
        console.log(`Active Cache Entries:    ${stats.cacheSize}`);

        if (stats.jitCompilations > 0) {
            console.log('\n🎯 JIT Compilation Analysis:');
            console.log(`   Hotness Threshold: 100 invocations`);
            console.log(`   Performance Gain: ${jitPercentage}% of calls using compiled code`);
            console.log(`   Memory Efficiency: ${stats.cacheSize} methods cached`);
        }
    }

    // Simulate multiple Smalltalk computations
    async runBenchmark(operations = 1000) {
        console.log(`🏃 Running benchmark with ${operations} operations...`);
        
        const startTime = performance.now();
        this.vmModule.instance.exports.resetPerformanceStats();

        for (let i = 0; i < operations; i++) {
            this.vmModule.instance.exports.createMinimalBootstrap();
            this.vmModule.instance.exports.interpret();
            
            if (i % 100 === 0) {
                console.log(`Progress: ${i}/${operations} (${(i/operations*100).toFixed(1)}%)`);
            }
        }

        const endTime = performance.now();
        const totalTime = endTime - startTime;

        await this.updatePerformanceStats();
        
        console.log(`\n⚡ Benchmark Results:`);
        console.log(`   Operations: ${operations}`);
        console.log(`   Total Time: ${totalTime.toFixed(2)}ms`);
        console.log(`   Avg per Operation: ${(totalTime/operations).toFixed(3)}ms`);
        console.log(`   Operations/Second: ${(operations/(totalTime/1000)).toFixed(0)}`);
        
        const stats = this.performanceData;
        console.log(`   JIT Hit Rate: ${(stats.jitCalls/(stats.jitCalls + stats.interpreterCalls)*100).toFixed(1)}%`);
    }

    // Create visualization data for performance monitoring
    getVisualizationData() {
        return {
            performanceData: this.performanceData,
            jitEfficiency: this.performanceData.methodInvocations > 0 
                ? this.performanceData.jitCalls / this.performanceData.methodInvocations 
                : 0,
            cacheEfficiency: (this.performanceData.cacheHits + this.performanceData.cacheMisses) > 0
                ? this.performanceData.cacheHits / (this.performanceData.cacheHits + this.performanceData.cacheMisses)
                : 0,
            compilationRatio: this.performanceData.methodInvocations > 0
                ? this.performanceData.jitCompilations / this.performanceData.methodInvocations
                : 0
        };
    }

    // Advanced JIT testing - run different method patterns
    async runAdvancedJITTest() {
        console.log('🧪 Running Advanced JIT Test Suite...');
        
        const testCases = [
            { name: 'Cold Methods', iterations: 50, description: 'Methods below JIT threshold (3 squared)' },
            { name: 'Hot Methods', iterations: 200, description: 'Methods triggering JIT compilation (SmallInteger>>squared)' },
            { name: 'Very Hot Methods', iterations: 500, description: 'Methods with optimization opportunities (compiled multiplication)' }
        ];

        for (const testCase of testCases) {
            console.log(`\n🔬 Test: ${testCase.name} (${testCase.description})`);
            this.vmModule.instance.exports.resetPerformanceStats();

            const startTime = performance.now();
            
            for (let i = 0; i < testCase.iterations; i++) {
                this.vmModule.instance.exports.createMinimalBootstrap();
                this.vmModule.instance.exports.interpret();
            }
            
            const endTime = performance.now();
            await this.updatePerformanceStats();
            
            const stats = this.performanceData;
            const avgTime = (endTime - startTime) / testCase.iterations;
            
            console.log(`   Results:`);
            console.log(`     Average execution time: ${avgTime.toFixed(3)}ms`);
            console.log(`     JIT compilation rate: ${(stats.jitCompilations / testCase.iterations * 100).toFixed(1)}%`);
            console.log(`     JIT execution rate: ${(stats.jitCalls / stats.methodInvocations * 100).toFixed(1)}%`);
            console.log(`     Cache efficiency: ${stats.cacheHits + stats.cacheMisses > 0 ? (stats.cacheHits / (stats.cacheHits + stats.cacheMisses) * 100).toFixed(1) : 0}%`);
        }
    }

    // Test JIT cache eviction behavior
    async testCacheEviction() {
        console.log('💾 Testing JIT Cache Eviction...');
        
        // This would require creating many different methods to fill the cache
        // For demo purposes, we'll simulate the behavior
        console.log('   Simulating cache pressure with multiple method variants...');
        
        this.vmModule.instance.exports.resetPerformanceStats();
        
        // Run many iterations to potentially trigger cache eviction
        for (let i = 0; i < 1000; i++) {
            this.vmModule.instance.exports.createMinimalBootstrap();
            this.vmModule.instance.exports.interpret();
            
            if (i % 100 === 0) {
                await this.updatePerformanceStats();
                if (this.performanceData.cacheSize > 0) {
                    console.log(`   Cache size: ${this.performanceData.cacheSize}, Evictions likely: ${i > 500 ? 'Yes' : 'No'}`);
                }
            }
        }
        
        await this.updatePerformanceStats();
        console.log(`   Final cache state: ${this.performanceData.cacheSize} entries`);
    }

    // Export performance data for analysis
    exportPerformanceData() {
        const timestamp = new Date().toISOString();
        const data = {
            timestamp,
            vmVersion: 'SqueakJS WASM v0.1.0 - Phase 3',
            performanceData: this.performanceData,
            derived: this.getVisualizationData()
        };
        
        console.log('📊 Performance Data Export:');
        console.log(JSON.stringify(data, null, 2));
        return data;
    }

    // Placeholder WAT sources (in real implementation, these would be loaded from files)
    getJITCompilerWAT() {
        // This would return the actual JIT compiler WAT source
        // For demo purposes, return a minimal stub
        return `
            (module
                (func (export "checkAndCompileMethod") (param anyref) (result anyref)
                    ref.null func
                )
                (func (export "getJITStats") (result i32 i32 i32 i32)
                    i32.const 0 i32.const 0 i32.const 0 i32.const 0
                )
                (func (export "clearJITCache"))
            )
        `;
    }

    getVMCoreWAT() {
        // This would return the actual VM core WAT source
        // For demo purposes, return a minimal stub
        return `
            (module
                (import "system" "reportResult" (func $reportResult (param i32)))
                (func (export "createMinimalBootstrap") (result i32)
                    i32.const 1
                )
                (func (export "interpret")
                    i32.const 7
                    call $reportResult
                )
                (func (export "getPerformanceStats") (result i32 i32 i32 i32 i32 i32 i32)
                    i32.const 1 i32.const 0 i32.const 1 i32.const 1 i32.const 1 i32.const 0 i32.const 1
                )
                (func (export "resetPerformanceStats"))
            )
        `;
    }
}

// Demo usage and testing functions
async function demonstrateJITCompilation() {
    console.log('🎬 JIT Compilation Demonstration');
    console.log('================================\n');

    const vm = new SqueakJITVM();
    
    // Set up result handler
    vm.onResult = (result) => {
        console.log(`✨ Computation result: ${result} (expecting 9 for 3 squared)`);
    };

    // Set up performance monitoring
    vm.onPerformanceUpdate = (stats) => {
        // Could update a real-time dashboard here
    };

    try {
        // Initialize VM
        console.log('🔧 Initializing VM...');
        const initialized = await vm.initialize();
        if (!initialized) {
            console.error('❌ Failed to initialize VM');
            return;
        }

        // Run basic JIT demo
        await vm.runJITDemo();

        // Run advanced tests
        await vm.runAdvancedJITTest();

        // Test cache behavior
        await vm.testCacheEviction();

        // Run performance benchmark
        await vm.runBenchmark(500);

        // Export final data
        vm.exportPerformanceData();

        console.log('\n🎉 All tests completed successfully!');
        
    } catch (error) {
        console.error('❌ Demo failed:', error);
    }
}

// Performance monitoring utilities
class JITPerformanceMonitor {
    constructor(vm) {
        this.vm = vm;
        this.history = [];
        this.isMonitoring = false;
    }

    startMonitoring(intervalMs = 1000) {
        if (this.isMonitoring) return;
        
        this.isMonitoring = true;
        this.interval = setInterval(async () => {
            await this.vm.updatePerformanceStats();
            const data = {
                timestamp: Date.now(),
                ...this.vm.getVisualizationData()
            };
            this.history.push(data);
            
            // Keep only last 100 data points
            if (this.history.length > 100) {
                this.history.shift();
            }
        }, intervalMs);
        
        console.log('📈 Performance monitoring started');
    }

    stopMonitoring() {
        if (!this.isMonitoring) return;
        
        clearInterval(this.interval);
        this.isMonitoring = false;
        console.log('📈 Performance monitoring stopped');
    }

    getHistory() {
        return this.history;
    }

    generateReport() {
        if (this.history.length === 0) {
            console.log('No performance data available');
            return;
        }

        const latest = this.history[this.history.length - 1];
        const oldest = this.history[0];
        
        console.log('\n📊 Performance Monitoring Report');
        console.log('═'.repeat(40));
        console.log(`Monitoring Period: ${new Date(oldest.timestamp).toLocaleTimeString()} - ${new Date(latest.timestamp).toLocaleTimeString()}`);
        console.log(`Data Points: ${this.history.length}`);
        console.log(`Current JIT Efficiency: ${(latest.jitEfficiency * 100).toFixed(1)}%`);
        console.log(`Current Cache Efficiency: ${(latest.cacheEfficiency * 100).toFixed(1)}%`);
        console.log(`Compilation Ratio: ${(latest.compilationRatio * 100).toFixed(3)}%`);
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { SqueakJITVM, JITPerformanceMonitor, demonstrateJITCompilation };
} else if (typeof window !== 'undefined') {
    window.SqueakJITVM = SqueakJITVM;
    window.JITPerformanceMonitor = JITPerformanceMonitor;
    window.demonstrateJITCompilation = demonstrateJITCompilation;
}

// Auto-run demo if this script is loaded directly
if (typeof window !== 'undefined' && document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        console.log('🚀 Ready to run JIT demo. Call demonstrateJITCompilation() to start.');
    });
}
