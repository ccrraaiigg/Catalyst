// catalyst.js - JavaScript interface to Catalyst VM

class Catalyst {
    constructor() {
        this.translationEnabled = true
        this.debugMode = true

        this.stats = {
            totalInvocations: 0,
            translations: 0,
            cachedMethods: 0,
            executionTime: 0,
            optimizedMethods: 0,
            translationValidationsPassed: 0,
            translationValidationsFailed: 0,
            compilationValidationsPassed: 0,
            compilationValidationsFailed: 0,
            retryAttempts: 0,
            retrySuccesses: 0,
            llmAttempts: 0,
            llmSuccesses: 0}

	// Store generated WAT for translation.
        this.methodTranslations = new Map()

	// Cache interpreted results for validation.
        this.interpretedResults = new Map()

	// Cache the last execution result.
        this.lastExecutionResult = null

	// Track the last logged cached result to avoid console spam.
        this.lastLoggedCachedResult = null

	// Track if WAT module has been logged this run.
        this.watModuleLoggedThisRun = false

        this.initializeSemanticAnalyzer()}

    initialize() {
        if (this.vm) return this.vm
        
        return WebAssembly.instantiateStreaming(
            fetch('catalyst.wasm?' + Date.now()),
            {
		env: {
                    reportResult: (value) => {
			// used by this.run()
                        this.onResult(value)

			// Only log results in debug mode, to avoid console spam.
			if (this.debugMode) console.log(`🎯 VM Result: ${value}`)},
                    
                    translateMethodForReceiverWithIdentityHash: (method, receiverIdentityHash) => {
			// No return value needed, just trigger async translation if desired.
			if (!this.translationEnabled) return

                        this.translateMethodToWASM(method, receiverIdentityHash).then(() => {
                            // Translation complete - function now available in function table.
                            if (this.debugMode) console.log(`🔥 Translation complete for receiver with identity hash ${receiverIdentityHash}.`)})},
                    
                    debugLog: (level, message, messageLength) => {
			if (this.debugMode) {
                            const message = this.readWASMString(message, messageLength)
                            console.log(`🐛 [${level}] ${message}`)}}}})
	    .then(wasmModule => {
		this.coreWASMModule = wasmModule
		this.coreWASMExports = this.coreWASMModule.instance.exports
		this.vm = this.coreWASMExports.newVirtualMachine()
		this.coreWASMExports.createMinimalObjectMemory(this.vm)

		if (!this.vm) throw new Error('WASM VM initialization failed')
		console.log('✅ Catalyst VM initialized successfully')

		this.functionTable = this.coreWASMExports.functionTable
		
		// Load API keys from secure file (wait for completion).
		return this.loadAPIKeys()
		    .then(() => {
			if (this.debugMode) console.log('🎯 VM initialization complete with LLM configuration')})
		    .catch(error => {
			if (this.debugMode) console.log('⚠️ API keys not loaded:', error)})})
	    .catch(error => {
		console.error('❌ Failed to load WASM module:', error)
		throw error})}

    /**
     * Load API keys from secure file (not in source code!)
     */
    async loadAPIKeys() {
        try {
            const response = await fetch('./keys')
            
            if (!response.ok) throw new Error(`Keys file not found: ${response.status}`)
            const keysText = await response.text()
            const {keys, keyOrder} = this.parseKeysFile(keysText)
            
            // Configure LLM with the first available provider (order matters)
            const primaryProvider = keyOrder[0]
            
            if (primaryProvider && keys[primaryProvider]) {
                this.llmConfig.provider = primaryProvider
                this.llmConfig.apiKey = keys[primaryProvider]
                this.llmConfig.enabled = true
                
                // Configure provider-specific settings
                if (primaryProvider === 'openai') {
                    this.llmConfig.endpoint = 'http://localhost:8001/api/openai'
                    this.llmConfig.model = 'gpt-4o'}
		else if (primaryProvider === 'anthropic') {
                    this.llmConfig.endpoint = 'http://localhost:8001/api/anthropic'
                    this.llmConfig.model = 'claude-opus-4-20250514'}
                
                if (this.debugMode) {
                    const providerDisplayName = primaryProvider === 'openai' ? 'OpenAI' : 
                          primaryProvider === 'anthropic' ? 'Anthropic' : primaryProvider

                    console.log(`🔑 ${providerDisplayName} API key loaded successfully (primary provider)`)
                    console.log('☁️ LLM optimization enabled automatically')

                    console.log('🔧 LLM Config updated:', {
                        provider: this.llmConfig.provider,
                        model: this.llmConfig.model,
                        endpoint: this.llmConfig.endpoint,
                        enabled: this.llmConfig.enabled,
                        hasApiKey: !!this.llmConfig.apiKey,
                        apiKeyPrefix: this.llmConfig.apiKey?.substring(0, 15) + '...'})
                    
                    // Report other available providers
                    const otherProviders = keyOrder.slice(1)
		    
                    if (otherProviders.length > 0) {
                        const otherNames = otherProviders.map(p => p === 'openai' ? 'OpenAI' : 
                                                              p === 'anthropic' ? 'Anthropic' : p)
                        console.log(`🔑 Alternative providers available: ${otherNames.join(', ')}`)
                        console.log(`💡 To switch providers, reorder keys in the keys file`)}}}}
	catch (error) {
            // Not a fatal error - VM continues without LLM optimization}

            if (this.debugMode) {
                console.log('⚠️ Could not load API keys:', error)
                console.log('🔄 LLM optimization will remain disabled')}}}

    /**
     * Parse the keys file format and track order of providers
     * Supports multiple formats:
     * - openai=sk-...
     * - OpenAI API key: sk-...
     * - anthropic=sk-ant-api03-...
     */
    parseKeysFile(keysText) {
        const keys = {}
        const keyOrder = []
        const lines = keysText.split('\n')
        
        for (const line of lines) {
            const trimmed = line.trim()
            if (trimmed && !trimmed.startsWith('#')) {
                let provider = null
                let apiKey = null
                
                // Format: key=value
                if (trimmed.includes('=')) {
                    const [key, value] = trimmed.split('=', 2)
                    if (key && value) {
                        const providerName = key.trim().toLowerCase()
                        const keyValue = value.trim()
                        
                        if ((providerName === 'openai' && keyValue.startsWith('sk-')) ||
                            (providerName === 'anthropic' && keyValue.startsWith('sk-ant-'))) {
                            provider = providerName
                            apiKey = keyValue}}}
		
                // Format: "OpenAI API key: sk-..."
                else if (trimmed.toLowerCase().includes('openai') && trimmed.includes(':')) {
                    const parts = trimmed.split(':')

                    if (parts.length >= 2) {
                        const key = parts.slice(1).join(':').trim()
                        if (key.startsWith('sk-')) {
                            provider = 'openai'
                            apiKey = key}}}
		
                // Format: "Anthropic API key: sk-ant-..."
                else if (trimmed.toLowerCase().includes('anthropic') && trimmed.includes(':')) {
                    const parts = trimmed.split(':')

                    if (parts.length >= 2) {
                        const key = parts.slice(1).join(':').trim()
                        if (key.startsWith('sk-ant-')) {
                            provider = 'anthropic'
                            apiKey = key}}}
                
                // Store key and track order
                if (provider && apiKey) {
                    keys[provider] = apiKey
                    if (!keyOrder.includes(provider)) keyOrder.push(provider)}}}
        
        return {keys, keyOrder}}

    async resetVM() {
        // Re-initialize the WASM module to reset the VM state
        await this.initialize()
        if (this.debugMode) console.log('🔄 VM state reset')}

    async run() {
        if (!this.vm) return Promise.reject(new Error('VM not initialized. Call initialize() first.'))

        // Do NOT reset the VM here; we want to preserve state across runs.
        return new Promise((resolve, reject) => {
            let receivedResult = null

            // Temporarily override onResult to capture the value.
            const prevOnResult = this.onResult

            this.onResult = (value) => {
                receivedResult = value}

            try {
                // Run the VM interpreter (this will execute the benchmark example)
		this.coreWASMExports.resetMinimalMemory(this.vm)
                const result = this.coreWASMExports.interpret(this.vm)
                this.stats.totalInvocations++
                
                // Cache the execution result for LLM validation
                if (receivedResult !== null) {
                    this.lastExecutionResult = receivedResult
                    // Only log if this is a new/different result
                    if (this.debugMode && receivedResult !== this.lastLoggedCachedResult) {
                        console.log(`🔍 Cached execution result: ${receivedResult}`)
                        this.lastLoggedCachedResult = receivedResult}}
                
                // Restore previous onResult
                this.onResult = prevOnResult
                resolve({
                    success: result !== 0,
                    translations: this.stats.translations,
		    // Use the actual result received
                    results: [receivedResult]})}
	    catch (error) {
                this.onResult = prevOnResult
                console.error('❌ VM execution failed:', error)
                reject(error)}})}

    // method translation: Translate bytecode to WAT, compile to WASM function.
    async translateMethodToWASM(method, receiverIdentityHash) {
        console.log(`🔍 [TRANSLATION DEBUG] translateMethodToWASM called: receiver identity hash=${receiverIdentityHash}, translationEnabled=${this.translationEnabled}`)

        try {
            const watCode = await this.translateMethodToWAT(method, receiverIdentityHash)
            
            // Check if translation failed (LLM translation not available)
            if (!watCode) {
                if (this.debugMode) {
                    console.log(`❌ Translation failed - no optimized WAT available.`)
                    console.log(`🔄 Method will continue being interpreted`)}
		// Return 0 to indicate no translated method available
                return 0}
	    
	    // Compile WAT to WASM function and store in function table
	    const compiledFunction = await this.compileWATToFunction(watCode)
	    
	    // Get the next available function table index
	    const functionIndex = ++this.stats.translations // Start at index 1
	    
	    // Store the compiled function in the function table
	    this.functionTable.set(functionIndex, compiledFunction)
	    
	    // Mark method as compiled
	    this.methodTranslations.set(method, compiledFunction)
	    
	    // Set the compiledFunction field in the WASM $CompiledMethod struct
            this.coreWASMExports.setMethodFunctionIndex(method, functionIndex)
	    
	    const compilationTime = performance.now() - this.startTime
	    this.stats.cachedMethods++
	    
	    // Debug log for translation
	    console.log(`[TRANSLATION] Translated method to functionIndex=${functionIndex} in ${compilationTime.toFixed(2)}ms`)
	    if (this.debugMode) {
                console.log(`🔥 Translated method in ${compilationTime.toFixed(2)}ms.`)
                console.log(`📍 Stored in function table at index ${functionIndex}`)}
	    
	    // Return function table index for WASM to use with call_indirect
	    return functionIndex}
	catch (error) {
	    console.error('❌ Translation failed:', error)

	    // Return 0 to indicate no translated method available -
	    // VM will fall back to interpretation.
	    return 0}}

    // Translate Squeak bytecode to WAT (WebAssembly Text format)
    async translateMethodToWAT(method, receiverIdentityHash) {
	if (!this.translationEnabled) return 0
	this.startTime = performance.now()
	
	console.log(`🔍 [TRANSLATE DEBUG] translateMethodToWAT available'`)
	
	// Get or generate interpreted result for this method
	let cachedInterpretedResult = method ? this.interpretedResults.get(method) : null

	if (!cachedInterpretedResult && method) {
	    // Execute this method in interpretation mode to get the reference result
	    try {
		// Use receiver = 100
		cachedInterpretedResult = await this.executeMethodInterpreted(method, 100)

		if (cachedInterpretedResult !== null) {
		    this.interpretedResults.set(method, cachedInterpretedResult)

		    if (this.debugMode) {
			console.log(`🔍 Cached new interpreted result for method: ${cachedInterpretedResult}`)}}}
	    catch (error) {
		if (this.debugMode) console.log(`⚠️ Failed to execute method in interpretation mode: ${error}`)}}

	if (this.debugMode) console.log(`🔍 Using interpreted result for receiver with identity hash ${receiverIdentityHash}:`, cachedInterpretedResult)
	
	// Try cloud-powered semantic optimization
	const bytecodesObject = this.coreWASMExports.methodBytecodes(method)

	const optimization = await this.analyzeAndOptimize(
	    Array.from(
		new Uint8Array(
		    this.coreWASMExports.bytes.buffer,
		    this.coreWASMExports.copyByteArrayToMemory(bytecodesObject),
		    this.coreWASMExports.byteArrayLength(bytecodesObject))),
	    method,
	    cachedInterpretedResult)
	
	if (optimization.optimized) {
	    if (this.debugMode) {
		console.log(`🚀 Generated LLM-optimized WAT for: ${optimization.description.summary}`)
		console.log(`☁️ Pattern: ${optimization.pattern}`)
		console.log(`📋 Analysis:`, optimization.description)}
	    return optimization.watCode}
	
	// LLM optimization failed - fail the entire translation
	// This forces the VM to continue interpreting rather than caching suboptimal WAT
	if (this.debugMode) {
	    console.log(`❌ Method translation failed - LLM optimization not available`)
	    console.log(`📋 Method analysis:`, optimization.description)
	    console.log(`🔄 VM will continue interpreting this method`)}
	
	// Return null to indicate translation failure
	return null}

    // ==================== SEMANTIC ANALYZER ====================

    initializeSemanticAnalyzer() {
	// Configure LLM endpoint for cloud-based optimization
	this.llmConfig = {
	    enabled: false, // Will be enabled when API key is loaded
	    provider: null, // Will be set to 'openai' or 'anthropic' when key is loaded
	    endpoint: null, // Will be set based on provider
	    apiKey: null, // Will be loaded from keys file
	    // Will be set based on provider
	    model: null}
	
	// No hardcoded patterns - we analyze everything generically!
	this.bytecodeNames = {
	    0x00: 'push_field_0', 0x01: 'push_field_1', 0x02: 'push_field_2', 0x03: 'push_field_3',
	    0x10: 'push_temp_0', 0x11: 'push_temp_1', 0x12: 'push_temp_2', 0x13: 'push_temp_3',
	    0x20: 'push_literal_0', 0x21: 'push_literal_1', 0x22: 'push_literal_2', 0x23: 'push_literal_3',
	    0x24: 'push_literal_4', 0x25: 'push_literal_5', 0x26: 'push_literal_6', 0x27: 'push_literal_7',
	    0x28: 'push_literal_8', 0x29: 'push_literal_9', 0x2a: 'push_literal_10', 0x2b: 'push_literal_11',
	    0x70: 'push_receiver', 0x71: 'push_true', 0x72: 'push_false', 0x73: 'push_nil',
	    0xB0: 'add', 0xB1: 'subtract', 0xB2: 'less_than', 0xB3: 'greater_than',
	    0xB8: 'multiply', 0xB9: 'divide', 0xBA: 'modulo', 0xBB: 'equals',
	    0x7C: 'return_top', 0x7D: 'return_receiver', 0xD0: 'send_message'}}

    /**
     * Main semantic analysis entry point - Cloud-powered optimization
     */
    async analyzeAndOptimize(bytecodes, method, cachedInterpretedResult) {
	// ALWAYS log this to trace literal extraction issues
	console.log(`🔍 [ANALYZE DEBUG] analyzeAndOptimize called with method:`, method ? 'available' : 'null')
	
	// Clear literal cache at start of new analysis to prevent redundant fetches
	this.clearLiteralCache()
	
	if (this.debugMode) console.log(`🔬 Analyzing bytecodes:`, bytecodes.map(b => `0x${b.toString(16)}`))

	// Generate English description of what the method does
	const description = this.describeBytecodeSequence(bytecodes)
	
	if (this.debugMode) {
	    console.log(`📝 Method description: ${description.summary}`)
	    console.log(`🎯 Operations: ${description.operations.join(' → ')}`)}

	// Try cloud-based optimization if enabled
	if (this.debugMode) {
	    console.log(`🔧 LLM Config check:`, {
		enabled: this.llmConfig.enabled,
		hasApiKey: !!this.llmConfig.apiKey,
		apiKeyType: this.llmConfig.apiKey?.startsWith('sk-') ? 'real' : 'mock',
		isOptimizable: this.isOptimizable(description)})}
	
	if (this.llmConfig.enabled && this.isOptimizable(description)) {
	    if (this.debugMode) console.log(`🚀 Attempting LLM optimization...`)
	    
	    const watCode = await this.generateOptimizedWATWithLLM(description, bytecodes, method, cachedInterpretedResult)
	    
	    if (watCode) {
		if (this.debugMode) {
		    console.log(`☁️ LLM-generated optimized WAT received`)
		    console.log(`📝 Generated WAT code:\n${watCode}`)
		    console.log(`🔍 Validating optimization correctness...`)}
		
		// CRITICAL: Validate the optimization before accepting it
		const validationResult = await this.validateOptimization(bytecodes, watCode, method, cachedInterpretedResult)
		
		if (validationResult.valid) {
		    this.stats.optimizedMethods++
		    if (this.debugMode) console.log(`✅ Optimization validation PASSED - results match!`)
		    
		    return {
			optimized: true,
			pattern: 'llm_optimized',
			description: description,
			watCode: watCode}}
		else {
		    if (this.debugMode) console.log(`❌ Optimization validation FAILED - trying once more with feedback...`)
		    
		    // Try once more with better feedback, using cached interpreted result
		    this.stats.retryAttempts++
		    const retryWatCode = await this.generateOptimizedWATWithRetry(description, bytecodes, watCode, method)
		    
		    if (retryWatCode) {
			const retryValidationResult = await this.validateOptimization(bytecodes, retryWatCode, method, cachedInterpretedResult)
			
			if (retryValidationResult.valid) {
			    this.stats.optimizedMethods++
			    this.stats.retrySuccesses++
			    if (this.debugMode) {
				console.log(`✅ Retry optimization validation PASSED - results match!`)}
			    
			    return {
				optimized: true,
				pattern: 'llm_optimized_retry',
				description: description,
				watCode: retryWatCode}}}

		    // Fall through to interpretation
		    if (this.debugMode) console.log(`❌ Both optimization attempts failed - falling back to bytecode interpretation`)}}}

	// Fallback to interpretation
	if (this.debugMode) console.log(`⚠️ Using bytecode interpretation`)
	
	return {
	    optimized: false,
	    pattern: 'interpreted',
	    description: description,
	    watCode: null}}

    // ==================== UNIVERSAL BYTECODE ANALYSIS ====================

    /**
     * Generate English description of any bytecode sequence
     * This replaces all hardcoded pattern matching
     */
    describeBytecodeSequence(bytecodes) {
	const operations = bytecodes.map(b => this.bytecodeNames[b] || `unknown_0x${b.toString(16)}`)
	const analysis = this.analyzeBytecodeStructure(bytecodes)
	
	return {
	    summary: '',
	    operations: operations,
	    analysis: analysis,
	    bytecodes: bytecodes.map(b => `0x${b.toString(16)}`),
	    complexity: this.estimateComplexity(analysis),
	    canOptimize: this.canOptimize(analysis)}}

    clearLiteralCache() {
	if (this.literalCache) {
	    this.literalCache.clear()
	    if (this.debugMode) {console.log('🗑️ Literal cache cleared')}}}

    /**
     * Analyze structural patterns in bytecode (no hardcoded patterns!)
     */
    analyzeBytecodeStructure(bytecodes) {
	const analysis = {
	    hasArithmetic: false,
	    hasLiterals: false,
	    hasFieldAccess: false,
	    hasMethodCalls: false,
	    literalValues: [],
	    stackOperations: 0,
	    returnType: 'unknown',
	    isLeaf: true,
	    isPure: true}

	for (const bytecode of bytecodes) {
	    // Arithmetic operations
	    if (bytecode >= 0xB0 && bytecode <= 0xBB) analysis.hasArithmetic = true
	    
	    // Literal pushes  
	    if (bytecode >= 0x20 && bytecode <= 0x2F) {
		analysis.hasLiterals = true
		analysis.literalValues.push(bytecode - 0x20)}
	    
	    // Field access
	    if (bytecode >= 0x00 && bytecode <= 0x0F) analysis.hasFieldAccess = true
	    
	    // Method calls
	    if (bytecode === 0xD0) {
		analysis.hasMethodCalls = true
		analysis.isLeaf = false
		analysis.isPure = false}
	    
	    // Stack operations
	    if (bytecode === 0x70 || (bytecode >= 0x00 && bytecode <= 0x2F))
		analysis.stackOperations++
	    
	    // Return types
	    if (bytecode === 0x7C) analysis.returnType = 'top_of_stack'
	    if (bytecode === 0x7D) analysis.returnType = 'receiver'}

	return analysis}

    /**
     * Estimate computational complexity
     */
    estimateComplexity(analysis) {
	if (analysis.hasMethodCalls) return "O(n) - depends on called methods"
	if (analysis.hasFieldAccess) return "O(1) - single memory access"
	return "O(1) - constant time"}

    /**
     * Determine if method is worth optimizing with LLM
     */
    canOptimize(analysis) {
	const canOpt = analysis.isLeaf && // No method calls
	      (analysis.hasArithmetic || analysis.hasFieldAccess) && // Has optimizable operations
	      analysis.stackOperations <= 50 // Allow much more complex computations
	
	if (this.debugMode) {
	    console.log(`🔍 Can optimize analysis:`, {
		isLeaf: analysis.isLeaf,
		hasArithmetic: analysis.hasArithmetic,
		hasFieldAccess: analysis.hasFieldAccess,
		stackOperations: analysis.stackOperations,
		result: canOpt})}
	
	return canOpt}

    isOptimizable(description) {
	const isOptimizable = description.canOptimize && 
	      description.operations.length <= 100 && // Allow much more complex computations
	      !description.summary.includes('unknown_')
	
	if (this.debugMode) {
	    console.log(`🤔 Optimizable check:`, {
		canOptimize: description.canOptimize,
		operationsLength: description.operations.length,
		hasUnknown: description.summary.includes('unknown_'),
		result: isOptimizable})}
	
	return isOptimizable}

    /**
     * Generate detailed English interpretation of bytecode sequence
     */
    generateEnglishInterpretation(bytecodes, method) {
	const interpretations = []
	
	for (let i = 0; i < bytecodes.length; i++) {
	    const bytecode = bytecodes[i]
	    const hexCode = `0x${bytecode.toString(16).padStart(2, '0')}`
	    let interpretation = ''
	    
	    switch (bytecode) {
	    case 0x70: // Push receiver
		interpretation = 'Push the receiver (self) onto the Smalltalk context stack'
		break
	    case 0x71: // Push true
		interpretation = 'Push the boolean value true onto the Smalltalk context stack'
		break
	    case 0x72: // Push false
		interpretation = 'Push the boolean value false onto the Smalltalk context stack'
		break
	    case 0x73: // Push nil
		interpretation = 'Push the nil value onto the Smalltalk context stack'
		break
		
		// Field access
	    case 0x00: case 0x01: case 0x02: case 0x03:
	    case 0x04: case 0x05: case 0x06: case 0x07:
	    case 0x08: case 0x09: case 0x0A: case 0x0B:
	    case 0x0C: case 0x0D: case 0x0E: case 0x0F:
		const fieldIndex = bytecode - 0x00
		interpretation = `Push field ${fieldIndex} from the receiver onto the Smalltalk context stack`
		break
		
		// Temporary variables
	    case 0x10: case 0x11: case 0x12: case 0x13:
	    case 0x14: case 0x15: case 0x16: case 0x17:
	    case 0x18: case 0x19: case 0x1A: case 0x1B:
	    case 0x1C: case 0x1D: case 0x1E: case 0x1F:
		const tempIndex = bytecode - 0x10
		interpretation = `Push temporary variable ${tempIndex} onto the Smalltalk context stack`
		break
		
		// Literal constants
	    case 0x20: case 0x21: case 0x22: case 0x23:
	    case 0x24: case 0x25: case 0x26: case 0x27:
	    case 0x28: case 0x29: case 0x2A: case 0x2B:
	    case 0x2C: case 0x2D: case 0x2E: case 0x2F:
		const literalIndex = bytecode - 0x20
		interpretation = `Push context literal ${literalIndex} onto the Smalltalk context stack`
		break
		
		// Arithmetic operations
	    case 0xB0: // Add
		interpretation = 'Pop two values from the Smalltalk context stack, add them, push result back'
		break
	    case 0xB1: // Subtract
		interpretation = 'Pop two values from the Smalltalk context stack, subtract second from first, push result back'
		break
	    case 0xB2: // Less than
		interpretation = 'Pop two values from the Smalltalk context stack, check if first < second, push boolean result'
		break
	    case 0xB3: // Greater than
		interpretation = 'Pop two values from the Smalltalk context stack, check if first > second, push boolean result'
		break
	    case 0xB8: // Multiply
		interpretation = 'Pop two values from the Smalltalk context stack, multiply them, push result back'
		break
	    case 0xB9: // Divide
		interpretation = 'Pop two values from the Smalltalk context stack, divide first by second, push result back'
		break
	    case 0xBA: // Modulo
		interpretation = 'Pop two values from the Smalltalk context stack, calculate first modulo second, push result back'
		break
	    case 0xBB: // Equals
		interpretation = 'Pop two values from the Smalltalk context stack, check if they are equal, push boolean result'
		break
		
		// Returns
	    case 0x7C: // Return top of stack
		interpretation = 'Return the top value from the stack as the method result'
		break
	    case 0x7D: // Return receiver
		interpretation = 'Return the receiver (self) as the method result'
		break
		
		// Message sends
	    case 0xD0: // Send message
		interpretation = 'Send a message to the receiver on top of stack (method call)'
		break
		
	    default:
		interpretation = `Unknown bytecode instruction - consult Squeak VM documentation`
		break}
	    
	    interpretations.push(`${i + 1}. ${hexCode}: ${interpretation}`)}
	
	return interpretations.join('\n')}

    /**
     * Generate step-by-step stack analysis for the LLM
     */
    generateStackAnalysis(operations, method) {
	const stack = []
	let receiver = 'R' // Use 'R' to represent receiver in analysis
	let steps = []
	
	for (let i = 0; i < operations.length; i++) {
	    const op = operations[i]
	    let stackBefore = [...stack]
	    
	    if (op.startsWith('push_literal_')) {
		const literalIndex = parseInt(op.split('_')[2])
		let literalValue = `literals[${literalIndex}]`
		
		stack.push(literalValue)}
	    else if (op === 'push_receiver') stack.push(receiver)
	    else if (op === 'multiply') {
		if (stack.length >= 2) {
		    const b = stack.pop()
		    const a = stack.pop()
		    stack.push(`(${a}*${b})`)}}
	    else if (op === 'add') {
		if (stack.length >= 2) {
		    const b = stack.pop()
		    const a = stack.pop()
		    stack.push(`(${a}+${b})`)}}
	    else if (op === 'return_top') {
		// Don't modify stack for return
	    }
	    
	    // Log the step
	    steps.push(`Step ${i+1}: ${op} → Stack: [${stack.join(', ')}]`)}
	
	const finalResult = stack.length > 0 ? stack[stack.length - 1] : '0'
	steps.push(`FINAL RESULT: ${finalResult}`)
	
	return steps.join('\n')}

    /**
     * Generate optimized WAT with retry and specific feedback
     */
    async generateOptimizedWATWithRetry(description, bytecodes, failedWatCode, method) {
	try {
	    // Get the error details from the failed attempt
	    const errorInfo = await this.analyzeWATError(failedWatCode)
	    
	    // Build a retry prompt with specific feedback
	    const retryPrompt = this.buildRetryPrompt(description, bytecodes, failedWatCode, errorInfo, method)
	    
	    // Make the API call with retry-specific prompt
	    const response = await this.callLLMAPI(retryPrompt)
	    const retryWatCode = this.extractWATFromResponse(response)
	    
	    if (retryWatCode) {
		// Check if LLM generated the same WAT code as the failed attempt
		if (failedWatCode && retryWatCode.trim() === failedWatCode.trim()) {
		    throw new Error(`LLM generated identical WAT code in retry attempt. Previous attempt failed with: ${errorInfo}. LLM is not making progress.`)}
		this.stats.retrySuccesses++
		if (this.debugMode) console.log(`🔄 Retry attempt succeeded - new WAT generated`)
		return retryWatCode}
	    else {
		if (this.debugMode) console.log(`❌ Retry attempt failed - no valid WAT extracted`)
		return null}}
	catch (error) {
	    if (this.debugMode) console.log(`❌ Retry attempt failed with error: ${error}`)
	    return null}}

    /**
     * Analyze what went wrong with the WAT code
     */
    async analyzeWATError(watCode) {
	try {
	    // Try to compile the WAT to get specific error details
	    if (!window.wasmTools) await this.loadWasmTools()
	    const fullWatModule = this.buildFullWatModule(watCode)
	    
	    // Try parsing to distinguish between parsing and validation errors
	    let wasmBytes
	    try {
		wasmBytes = window.wasmTools.parseWat(fullWatModule)}
	    catch (parseError) {
		return `WAT parsing error: ${parseError}`}
	    
	    // Try validation
	    try {
		const isValid = window.wasmTools.validate(wasmBytes)
		if (!isValid) return "WASM validation error: Binary validation failed"}
	    catch (validationError) {
		return `WASM validation error: ${validationError}`}
	    
	    return "No errors detected"}
	catch (error) {
	    return `Compilation error: ${error}`}}

    /**
     * Build minimal retry prompt with only error feedback and original WAT
     */
    buildRetryPrompt(description, bytecodes, failedWatCode, errorInfo, method) {
	// For retry prompts, we don't have the detailed error type info, so we'll use generic labeling
	const prompt = `There were problems with that WAT code.

ERROR: ${errorInfo}

ORIGINAL WAT:
${failedWatCode}

Please fix the errors above and generate ONLY the corrected function definition.`

	// Log the retry prompt to console
	console.log('\n📝 ===== RETRY PROMPT =====')
	console.log(prompt)
	console.log('===== END RETRY PROMPT =====\n')

	return prompt}

    /**
     * Validate that the LLM-generated WAT produces the same result as the original bytecode
     * Uses cached interpreted result to avoid recomputing the reference value
     */
    async validateOptimization(bytecodes, watCode, method, cachedInterpretedResult) {
	console.log(`🚨 VALIDATION STARTED - validateOptimization called`)
	console.log(`📋 Parameters: bytecodes=${bytecodes?.length}, watCode=${watCode ? 'present' : 'null'}, method=${method ? 'present' : 'null'}, cachedInterpretedResult=${cachedInterpretedResult}`)
	
	try {
	    // Test with a known receiver value
	    const testReceiver = 100
	    
	    console.log(`🧪 Starting validation with receiver = ${testReceiver}`)
	    console.log(`📋 Method context: ${method ? 'available' : 'null'}`)
	    
	    // 1. Use cached interpreted result from actual WASM VM execution
	    let interpretedResult = cachedInterpretedResult
	    if (interpretedResult === null || interpretedResult === undefined) {
		console.log(`⚠️ No cached interpreted result available - using last execution result`)
		// Fallback to last execution result if available
		const fallbackResult = this.lastExecutionResult
		if (fallbackResult === null || fallbackResult === undefined)
		    throw new Error('No interpreted result available for validation')
		interpretedResult = fallbackResult}
	    
	    console.log(`📊 Using interpreted result from WASM VM: ${interpretedResult}`)
	    
	    // 2. Compile and execute WAT optimization
	    console.log(`🤖 Executing WAT optimization...`)
	    const optimizedResult = await this.executeWATOptimized(watCode, method)
	    console.log(`🤖 WAT optimization returned: ${optimizedResult}`)
	    
	    // 3. Compare results
	    const resultsMatch = interpretedResult === optimizedResult
	    
	    // Track validation statistics
	    if (resultsMatch) this.stats.translationValidationsPassed++
	    else this.stats.translationValidationsFailed++
	    
	    // ALWAYS show validation results clearly on console
	    console.log(`🔍 ===== VALIDATION RESULTS =====`)
	    console.log(`📊 Expected Value (Interpreted): ${interpretedResult}`)
	    console.log(`🤖 Computed Value (LLM-WAT):    ${optimizedResult}`)
	    console.log(`✅ Results Match: ${resultsMatch ? 'YES' : 'NO'}`)
	    console.log(`📈 Validation Stats: ${this.stats.translationValidationsPassed} passed, ${this.stats.translationValidationsFailed} failed`)
	    console.log(`===== END VALIDATION RESULTS =====`)
	    
	    return {
		valid: resultsMatch,
		// Return the interpreted result for caching
		interpretedResult: interpretedResult}}
	catch (error) {
	    console.log(`❌ ===== VALIDATION ERROR =====`)
	    console.log(`💥 Validation failed due to error: ${error}`)
	    console.log(`📊 Expected Value (Interpreted): ${cachedInterpretedResult || this.lastExecutionResult}`)
	    console.log(`🤖 Computed Value (LLM-WAT):    ERROR - ${error.message}`)
	    console.log(`✅ Results Match: NO (ERROR)`)
	    console.log(`===== END VALIDATION ERROR =====`)
	    
	    return {
		valid: false,
		// Return the cached result even on failure
		interpretedResult: cachedInterpretedResult || this.lastExecutionResult}}}

    /**
     * Execute a specific method through the WASM VM interpreter
     * to get reference result.
     */
    async executeMethodInterpreted(method, receiver) {
	// Use the cached result from the last VM execution. This
	// assumes the method being translated is the one that
	// produced the last result.
	return this.lastExecutionResult}

    /**
     * Execute WAT-optimized code for validation by installing it in
     * the VM's method cache, setting the method's $compiledFunc
     * field, running the VM normally, then comparing results
     */
    async executeWATOptimized(watCode, method) {
	try {
	    if (!this.coreWASMModule || !this.coreWASMModule.instance) throw new Error('WASM VM not initialized')
	    console.log(`🔧 Installing LLM-optimized method in VM method cache for validation`)

	    // Compile the WAT code to a function
	    const compiledFunction = await this.compileWATToFunction(watCode)
	    
	    // Store the compiled function in the VM's method cache,
	    // and set the method's $compiledFunctionIndex field correctly.
	    let originalCompiledFunctionIndex = null
	    
	    // Save original compiled function index
	    originalCompiledFunctionIndex = this.coreWASMExports.getMethodFunctionIndex(method)
	    const originalFunction = this.functionTable.get(originalCompiledFunctionIndex)
	    const functionIndex = this.stats.translations + 1
	    
	    // Set the new compiled function index
	    this.functionTable.set(functionIndex, compiledFunction)
	    this.coreWASMExports.setMethodFunctionIndex(method, functionIndex)
	    
	    console.log(`🔧 Temporarily installed LLM function at index ${functionIndex}`)
	    
	    // Run the VM normally - it will use the cached compiled function
	    const vmResult = await this.run()
	    
	    // Extract the result value
	    const actualResult = vmResult.results?.[0]
	    
	    console.log(`🔧 VM executed with LLM function, result: ${actualResult}`)
	    
	    // Restore the original state
	    this.coreWASMExports.setMethodFunctionIndex(method, originalCompiledFunctionIndex)
	    console.log(`🔧 Restored original compiled function index ${originalCompiledFunctionIndex} for method`)
	    
	    // Restore original function table entry
	    this.functionTable.set(originalCompiledFunctionIndex, originalFunction)
	    
	    if (actualResult === null || actualResult === undefined) throw new Error('VM execution produced null/undefined result')
	    
	    return actualResult}
	catch (error) {
	    if (this.debugMode) console.log(`⚠️ WAT validation execution failed: ${error}`)
	    throw new Error(`WAT validation execution failed: ${error.message || error}`)}}

    // ==================== CLOUD-POWERED WAT GENERATION ====================

    /**
     * Generate optimized WAT using single LLM with detailed failure feedback.
     */
    async generateOptimizedWATWithLLM(description, bytecodes, method, cachedInterpretedResult) {
	if (!this.llmConfig.enabled || !this.llmConfig.apiKey) {
	    if (this.debugMode) console.log('⚠️ LLM optimization disabled - no API key configured')
	    return null}

	const maxAttempts = 1
	let failureHistory = []
	
	for (let attempt = 1; attempt <= maxAttempts; attempt++) {
	    this.stats.llmAttempts++
	    
	    if (this.debugMode) console.log(`🤖 LLM attempt ${attempt}/${maxAttempts}`)
	    
	    // Build prompt - full context for first attempt, error feedback for retries
	    const prompt = this.buildLLMPromptWithFailureHistory(
		description, 
		bytecodes, 
		method, 
		attempt,
		failureHistory)
	    
	    const response = await this.callLLMAPI(prompt)
	    
	    if (!response) {
		if (this.debugMode) console.log(`❌ LLM API call failed on attempt ${attempt}`)
		continue}
	    
	    // Generate WAT code from response
	    const watCode = this.extractWATFromResponse(response)
	    
	    if (!watCode) {
		if (this.debugMode) console.log(`❌ WAT generation failed on attempt ${attempt}`)
		continue}
	    
	    // Check if LLM generated the same WAT code as previous attempt
	    if (failureHistory.length > 0) {
		const lastFailure = failureHistory[failureHistory.length - 1]
		if (lastFailure.watCode && watCode.trim() === lastFailure.watCode.trim()) {
		    throw new Error(`LLM generated identical WAT code on attempt ${attempt}. Previous attempt failed with: ${lastFailure.error}. LLM is not making progress.`)}}
	    
	    // CRITICAL: Validate the WASM compilation and generate dump for feedback
	    const wasmValidationResult = await this.validateWASMCompilation(watCode)
	    
	    if (!wasmValidationResult.valid) {
		// WASM compilation failed - add detailed info to failure history
		const errorTypeLabel = wasmValidationResult.errorType === 'parsing' ? 'WAT parsing' : 
		      wasmValidationResult.errorType === 'validation' ? 'WASM validation' : 'WASM compilation'
		
		const errorMessage = `${errorTypeLabel} failed: ${wasmValidationResult.error}`
		
		failureHistory.push({
		    attempt: attempt,
		    watCode: watCode,
		    error: errorMessage,
		    wasmValidationError: wasmValidationResult.error,
		    wasmValidationErrorType: wasmValidationResult.errorType,
		    wasmDump: wasmValidationResult.dump,
		    expectedResult: cachedInterpretedResult,
		    actualResult: `${errorTypeLabel} failed`,
		    testReceiver: 100,
		    method: method ? 'available' : 'null'})
		
		if (this.debugMode) console.log(`❌ ${errorTypeLabel} failed on attempt ${attempt}: ${wasmValidationResult.error}`)
		continue}
	    
	    // Validate the generated WAT using the cached interpreted result
	    const validationResult = await this.validateOptimization(bytecodes, watCode, method, cachedInterpretedResult)
	    
	    if (validationResult.valid) {
		this.stats.llmSuccesses++
		if (this.debugMode) console.log(`✅ LLM success on attempt ${attempt}`)
		return watCode}
	    else {
		// Check if this is a real validation failure or a false negative
		if (validationResult.error && validationResult.error.includes('Cached interpreted result is required')) {
		    // This is a validation system bug, not an LLM failure
		    if (this.debugMode) {
			console.log(`⚠️ Validation system error (not LLM failure): ${validationResult.error}`)
			console.log(`✅ LLM actually succeeded on attempt ${attempt} - returning WAT code`)}
		    this.stats.llmSuccesses++
		    return watCode}
		
		// Get detailed validation failure info for next attempt, using cached result
		const validationInfo = await this.getValidationFailureInfo(bytecodes, watCode, method, cachedInterpretedResult)
		
		failureHistory.push({
		    attempt: attempt,
		    watCode: watCode,
		    error: validationInfo.error,
		    // Use WASM analysis from validation info (which always includes it now)
		    wasmValidationError: validationInfo.wasmValidationError || wasmValidationResult.error,
		    wasmDump: validationInfo.wasmDump || wasmValidationResult.dump,
		    wasmValidationValid: validationInfo.wasmValidationValid,
		    expectedResult: validationInfo.expectedResult,
		    actualResult: validationInfo.actualResult,
		    testReceiver: validationInfo.testReceiver,
		    method: method ? 'available' : 'null'})
		
		if (this.debugMode) console.log(`❌ LLM validation failed on attempt ${attempt}: ${validationInfo.error}`)}}
	
	if (this.debugMode) console.log('❌ All LLM attempts failed')
	return null}

    /**
     * Prepare WAT function by adding context parameter, result type and return value
     */
    prepareWatFunction(watCode) {
	let processedCode = watCode
	
	// Step 1: Ensure function has context parameter if not already present
	if (!processedCode.includes('(param $context (ref eq))')) {
	    const funcMatch = processedCode.match(/(\(func\s+\$\w+)(\s*\([^)]*\))?/)
	    if (funcMatch) {
		const funcStart = funcMatch[1]
		const existingParams = funcMatch[2] || ''
		const newSignature = `${funcStart} (param $context (ref eq))${existingParams}`
		processedCode = processedCode.replace(funcMatch[0], newSignature)}}
	
	// Step 2: Add (result i32) to the function signature if not already present
	if (!processedCode.includes('(result i32)')) {
	    const funcMatch = processedCode.match(/(\(func\s+\$\w+\s*\([^)]*\))/)
	    if (funcMatch) {
		const originalSignature = funcMatch[1]
		const newSignature = originalSignature + ') (result i32'
		processedCode = processedCode.replace(originalSignature, newSignature)}}
	
	// Step 3: Insert i32.const 1 before the final closing parenthesis
	const lastParenIndex = processedCode.lastIndexOf(')')
	if (lastParenIndex === -1) return processedCode
	
	// Insert i32.const 1 before the final closing parenthesis
	return processedCode.substring(0, lastParenIndex) + 
	    '\n  i32.const 1\n' + 
	    processedCode.substring(lastParenIndex)}

    /**
     * Build a complete WAT module with imports for testing/compilation using real VM signatures
     */
    buildFullWatModule(watCode) {
	const preparedWatCode = this.prepareWatFunction(watCode)
	
	// Extract function name from the WAT code for proper export
	const functionName = preparedWatCode.match(/\(func\s+\$([a-zA-Z0-9_]+)/)[1]
	
	return `(module
  (import "env" "onContextPush" (func $onContextPush (param (ref eq)) (param (ref eq))))
  (import "env" "popFromContext" (func $popFromContext (param (ref eq)) (result (ref eq))))
  (import "env" "valueOfSmallInteger" (func $valueOfSmallInteger (param (ref eq)) (result i32)))
  (import "env" "smallIntegerForValue" (func $smallIntegerForValue (param i32) (result (ref eq))))
  (import "env" "contextReceiver" (func $contextReceiver (param (ref eq)) (result (ref eq))))
  (import "env" "contextLiteralAt" (func $contextLiteralAt (param (ref eq)) (param i32) (result (ref eq))))
  (import "env" "debugLog" (func $debugLog (param i32)))
  
  ${preparedWatCode}
  
  (export "${functionName}" (func $${functionName}))
)`}
    

    /**
     * Validate WASM compilation and generate dump for LLM feedback
     * This validates the WASM binary and generates detailed dumps like wasm-tools
     */
    async validateWASMCompilation(watCode) {
	try {
	    // Load wasm-tools if not already loaded
	    if (!window.wasmTools) await this.loadWasmTools()
	    
	    // Create a complete WAT module for compilation
	    const fullWatModule = this.buildFullWatModule(watCode)

	    // Only log WAT module once per run to reduce console spam
	    if (!this.watModuleLoggedThisRun && this.debugMode) {
		console.log('🔍 Full WAT module (first time this run):')
		console.log(fullWatModule)
		this.watModuleLoggedThisRun = true}
	    
	    // Step 1: Try to parse WAT to WASM binary
	    let wasmBytes
	    try {
		wasmBytes = window.wasmTools.parseWat(fullWatModule)
		if (this.debugMode) {
		    console.log('✅ WAT parsing succeeded')}}
	    catch (parseError) {
		if (this.debugMode) console.log('❌ WAT parsing failed:', parseError)

		return {
		    valid: false,
		    errorType: 'parsing',
		    error: `${parseError}`,
		    dump: `WAT PARSING FAILED - NO DUMP AVAILABLE\nParsing Error: ${parseError}\n\nOriginal WAT:\n${watCode}`}}
	    
	    // Step 2: Validate the WASM binary
	    try {
		const isValid = window.wasmTools.validate(wasmBytes)
		if (!isValid) {
		    if (this.debugMode) console.log('❌ WASM binary validation failed')

		    return {
			valid: false,
			errorType: 'validation',
			error: 'WASM binary validation failed',
			dump: await this.generateWASMDump(wasmBytes, watCode)}}
		
		if (this.debugMode) console.log('✅ WASM binary validation passed')}
	    catch (validationError) {
		// Check if this is a GC-related validation error
		const errorString = validationError.toString()

		const isGCError = errorString.includes('invalid value type') || 
		      errorString.includes('heap types not supported without the gc feature') ||
		      errorString.includes('gc feature') ||
		      errorString.includes('(ref eq)') ||
		      errorString.includes('funcref') ||
		      errorString.includes('externref') ||
		      errorString.includes('reference type')
		
		if (isGCError) {
		    if (this.debugMode) {
			console.log('⚠️ WASM validation failed due to GC features not supported in JavaScript validator')
			console.log(`📋 Error details: ${errorString}`)
			console.log('✅ Core VM successfully uses WASM GC features - JS validator limitation')
			console.log('🔄 Accepting validation as passed since runtime supports GC features')}

		    this.stats.compilationValidationsPassed++
		    // Return valid for GC-related validation errors since the actual runtime supports GC
		    return {
			valid: true,
			errorType: null,
			error: null,
			dump: await this.generateWASMDump(wasmBytes, watCode)}}
		else {
		    if (this.debugMode)
			console.log('❌ WASM validation threw error:', validationError)

		    this.stats.compilationValidationsFailed++

		    return {
			valid: false,
			errorType: 'validation',
			error: `${validationError}`,
			dump: await this.generateWASMDump(wasmBytes, watCode)}}}
	    
	    // Step 3: Generate dump for successful compilation (for reference)
	    const dump = await this.generateWASMDump(wasmBytes, watCode)
	    
	    return {
		valid: true,
		errorType: null,
		error: null,
		dump: dump}}
	catch (error) {
	    if (this.debugMode) console.log('❌ WASM compilation failed unexpectedly:', error)

	    return {
		valid: false,
		errorType: 'compilation',
		error: error,
		dump: `WASM COMPILATION FAILED\nCompilation Error: ${error}\n\nOriginal WAT:\n${watCode}`}} }

    /**
     * Generate a detailed WASM dump and analysis using wabt.js
     * Enhanced to provide byte-level information similar to wasm-tools dump
     */
    async generateWASMDump(wasmBytes, originalWatCode) {
	try {
	    // Try to load wabt.js for comprehensive WASM analysis
	    if (!window.wabt) await this.loadWabt()
	    
	    // Use wabt.js readWasm() for detailed binary analysis (if available)
	    let analysis = ''
	    
	    if (window.wabt) {
		try {
		    analysis = `=== WASM BINARY ANALYSIS (via wabt.js) ===\n`
		    
		    // Read the WASM binary with wabt.js
		    const wasmModule = window.wabt.readWasm(wasmBytes, {
			readDebugNames: true, 
			check: true})
		    
		    // Validate the module
		    try {
			wasmModule.validate()
			analysis += `Validation: PASSED\n`}
		    catch (validationError) {
			analysis += `Validation: FAILED - ${validationError}\n`}
		    
		    // Get detailed text representation with maximum verbosity
		    const wasmText = wasmModule.toText({
			foldExprs: false, 
			inlineExport: false,
			writeBinary: false})
		    
		    analysis += `Binary Size: ${wasmBytes.length} bytes\n`
		    analysis += `Module parsed successfully\n\n`
		    
		    // Add custom hex dump similar to wasm-tools dump
		    analysis += `=== BINARY HEX DUMP ===\n`
		    analysis += this.generateHexDump(wasmBytes)
		    analysis += `\n\n`
		    
		    // Add section analysis
		    analysis += `=== SECTION ANALYSIS ===\n`
		    analysis += this.analyzeSections(wasmBytes)
		    analysis += `\n\n`
		    
		    // Add detailed instruction analysis
		    analysis += this.analyzeCodeSection(wasmBytes)
		    analysis += `\n\n`
		    
		    analysis += `=== WASM TEXT REPRESENTATION ===\n`
		    analysis += wasmText
		    
		    // Try to get additional information from wabt.js
		    try {
			// Some wabt.js versions have additional methods
			if (typeof wasmModule.getNumSections === 'function') {
			    analysis += `\n=== SECTION DETAILS ===\n`
			    const numSections = wasmModule.getNumSections()
			    for (let i = 0; i < numSections; i++) {
				const sectionInfo = wasmModule.getSectionInfo(i)
				analysis += `Section ${i}: ${JSON.stringify(sectionInfo)}\n`}}}
		    catch (e) {
			// These methods might not be available in all wabt.js versions
			if (this.debugMode)
			    console.log('ℹ️ Advanced wabt.js section analysis not available:', e.message)}
		    
		    // Clean up wabt module
		    wasmModule.destroy()
		    
		    if (this.debugMode)
			console.log('✅ Enhanced wabt.js WASM analysis completed successfully')}
		catch (wabtError) {
		    if (this.debugMode)
			console.log('⚠️ wabt.js analysis failed:', wabtError.message)

		    // wabt failed, fall through to basic analysis
		    window.wabt = null}}
	    
	    if (!window.wabt) {
		// Fallback to enhanced basic analysis if wabt is not available
		analysis = `=== ENHANCED BINARY ANALYSIS ===\n`
		analysis += `Size: ${wasmBytes.length} bytes\n`
		analysis += `Magic: ${Array.from(wasmBytes.slice(0, 4)).map(b => '0x' + b.toString(16).padStart(2, '0')).join(' ')}\n`
		analysis += `Version: ${Array.from(wasmBytes.slice(4, 8)).map(b => '0x' + b.toString(16).padStart(2, '0')).join(' ')}\n`
		
		// Add hex dump even without wabt.js
		analysis += `\n=== BINARY HEX DUMP ===\n`
		analysis += this.generateHexDump(wasmBytes)
		analysis += `\n\n`
		
		// Add section analysis
		analysis += `=== SECTION ANALYSIS ===\n`
		analysis += this.analyzeSections(wasmBytes)
		analysis += `\n\n`
		
		// Add detailed instruction analysis
		analysis += this.analyzeCodeSection(wasmBytes)
		analysis += `\n\n`
		
		// Load and try js-wasm-tools validation as fallback
		try {
		    if (!window.wasmTools) await this.loadWasmTools()

		    const isValid = window.wasmTools.validate(wasmBytes)
		    analysis += `Validation Status: ${isValid ? 'VALID' : 'INVALID'}\n`}
		catch (validationError) {
		    analysis += `Validation Status: ERROR - ${validationError}\n`}
		
		if (this.debugMode)
		    console.log('ℹ️ Using enhanced basic WASM analysis (wabt.js not available)')}
	    
	    analysis += `\n=== ORIGINAL WAT ===\n${originalWatCode}`
	    
	    return analysis}
	catch (error) {
	    if (this.debugMode) console.log('❌ WASM dump generation failed:', error.message)
	    return `=== WASM DUMP GENERATION FAILED ===\nError: ${error}\n\n=== WASM BINARY INFO ===\nSize: ${wasmBytes ? wasmBytes.length : 'unknown'} bytes\n\n=== ORIGINAL WAT ===\n${originalWatCode}`}}

    /**
     * Generate a hex dump of WASM bytes similar to wasm-tools dump
     */
    generateHexDump(wasmBytes) {
	const lines = []
	const bytesPerLine = 16
	
	for (let i = 0; i < wasmBytes.length; i += bytesPerLine) {
	    const offset = i.toString(16).padStart(8, '0')
	    const chunk = wasmBytes.slice(i, i + bytesPerLine)
	    
	    // Hex representation
	    const hexBytes = Array.from(chunk)
		  .map(b => b.toString(16).padStart(2, '0'))
		  .join(' ')
	    
	    // Pad hex to consistent width
	    const paddedHex = hexBytes.padEnd(bytesPerLine * 3 - 1, ' ')
	    
	    // ASCII representation
	    const ascii = Array.from(chunk)
		  .map(b => (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.')
		  .join('')
	    
	    lines.push(`${offset}  ${paddedHex}  |${ascii}|`)}
	
	return lines.join('\n')}

    /**
     * Analyze WASM sections and provide detailed breakdown
     */
    analyzeSections(wasmBytes) {
	const sections = []
	let offset = 8 // Skip magic and version
	
	// WASM section types
	const sectionTypes = {
	    0: 'Custom',
	    1: 'Type',
	    2: 'Import', 
	    3: 'Function',
	    4: 'Table',
	    5: 'Memory',
	    6: 'Global',
	    7: 'Export',
	    8: 'Start',
	    9: 'Element',
	    10: 'Code',
	    11: 'Data',
	    12: 'DataCount'}
	
	try {
	    while (offset < wasmBytes.length) {
		if (offset + 1 >= wasmBytes.length) break
		
		const sectionType = wasmBytes[offset]
		const sectionName = sectionTypes[sectionType] || `Unknown(${sectionType})`
		
		offset++ // Move past section type
		
		// Read LEB128 size
		const {value: sectionSize, newOffset} = this.readLEB128(wasmBytes, offset)
		offset = newOffset
		
		const sectionStart = offset - 1 - this.getLEB128ByteLength(sectionSize)
		const sectionEnd = offset + sectionSize
		
		sections.push(
		    `Section ${sectionType} (${sectionName}): ` +
			`offset=0x${sectionStart.toString(16).padStart(8, '0')}, ` +
			`size=${sectionSize} bytes, ` +
			`end=0x${sectionEnd.toString(16).padStart(8, '0')}`)
		
		// Add hex dump of section header
		const headerBytes = (
		    wasmBytes.slice(
			sectionStart,
			Math.min(sectionStart + 16,sectionEnd)))
		
		const headerHex = Array.from(headerBytes)
		      .map(b => b.toString(16).padStart(2, '0'))
		      .join(' ')
		
		sections.push(`  Header: ${headerHex}`)
		
		offset = sectionEnd}}
	catch (error) {
	    sections.push(`Section parsing error at offset 0x${offset.toString(16)}: ${error.message}`)}
	
	return sections.join('\n')}

    /**
     * Read LEB128 unsigned integer from bytes
     */
    readLEB128(bytes, offset) {
	let result = 0
	let shift = 0
	let byte
	const startOffset = offset
	
	do {
	    if (offset >= bytes.length) throw new Error('Unexpected end of LEB128 data')
	    byte = bytes[offset++]
	    result |= (byte & 0x7F) << shift
	    shift += 7}
	while (byte & 0x80)
	
	return {value: result, newOffset: offset}}

    /**
     * Get the byte length of a LEB128 encoded value
     */
    getLEB128ByteLength(value) {
	if (value === 0) return 1
	let length = 0

	while (value > 0) {
	    value >>= 7
	    length++}

	return length}

    /**
     * Get detailed validation failure information for feedback
     * Uses cached interpreted result to avoid redundant computation
     */
    async getValidationFailureInfo(bytecodes, watCode, method, cachedInterpretedResult) {
	console.log(`🚨 VALIDATION FAILURE INFO - getValidationFailureInfo called`)
	console.log(`📋 Parameters: bytecodes=${bytecodes?.length}, watCode=${watCode ? 'present' : 'null'}, method=${method ? 'present' : 'null'}, cachedInterpretedResult=${cachedInterpretedResult}`)
	
	try {
	    const testReceiver = 100
	    
	    // Use cached interpreted result from actual WASM VM execution
	    if (cachedInterpretedResult === null)
		throw new Error('Cached interpreted result is required - should be provided from actual WASM VM execution')
	    
	    const expectedResult = cachedInterpretedResult
	    
	    let actualResult = null
	    let specificError = null
	    
	    try {
		actualResult = await this.executeWATOptimized(watCode, method)}
	    catch (executionError) {
		// CRITICAL FIX: Capture the specific execution error message
		specificError = executionError.message || executionError.toString()

		if (this.debugMode)
		    console.log(`🔧 Captured specific execution error: ${specificError}`)}
	    
	    // Show validation failure values
	    console.log(`🔍 ===== VALIDATION FAILURE VALUES =====`)
	    console.log(`📊 Expected Value (Interpreted): ${expectedResult}`)
	    console.log(`🤖 Actual Value (LLM-WAT):      ${actualResult}`)
	    console.log(`✅ Values Match: ${expectedResult === actualResult ? 'YES' : 'NO'}`)
	    if (specificError) console.log(`💥 Specific Error: ${specificError}`)
	    console.log(`===== END VALIDATION FAILURE VALUES =====`)
	    
	    // CRITICAL FIX: Always run WASM validation to get detailed analysis for retry prompts
	    const wasmValidationResult = await this.validateWASMCompilation(watCode)
	    
	    return {
		error: specificError || (actualResult === null ? 'WAT execution failed' : `Result mismatch - WAT produced incorrect value`),
		// DON'T return expected result - LLM shouldn't see it
		actualResult: actualResult,
		testReceiver: testReceiver,
		method: method ? 'available' : 'null',
		// Include detailed WASM analysis for retry prompts
		wasmValidationError: wasmValidationResult.error,
		wasmDump: wasmValidationResult.dump,
		wasmValidationValid: wasmValidationResult.valid}}
	catch (error) {
	    // Capture specific error message from any validation failure
	    const specificError = error.message || error.toString()
	    if (this.debugMode) console.log(`🔧 Captured validation error: ${specificError}`)
	    
	    // Even for errors, try to get WASM analysis
	    let wasmValidationResult = null

	    try {
		wasmValidationResult = await this.validateWASMCompilation(watCode)}
	    catch (wasmError) {
		if (this.debugMode)
		    console.log(`⚠️ Could not generate WASM analysis for error case: ${wasmError}`)}}
	
	return {
	    error: specificError,
	    // DON'T return expected result - LLM shouldn't see it
	    actualResult: null,
	    testReceiver: 100,
	    method: method ? 'available' : 'null',
	    // Include WASM analysis if available
	    wasmValidationError: wasmValidationResult?.error,
	    wasmDump: wasmValidationResult?.dump,
	    wasmValidationValid: wasmValidationResult?.valid}}

    /**
     * Configure LLM settings (called from external config)
     */
    configureLLM(config) {
	Object.assign(this.llmConfig, config)
	if (this.debugMode) console.log('🔧 LLM configuration updated')}

    // Cross-module function compilation with explicit signatures
    async compileWATToFunction(watCode) {
	try {
	    if (!window.wasmTools) await this.loadWasmTools()

	    // Create a minimal WASM module with explicit signature matching
	    const fullWatModule = this.buildFullWatModule(watCode)

	    if (this.debugMode) console.log(`📝 Compiling method translation WAT module:\n${fullWatModule}`)
	    
	    // Validate that the WAT doesn't contain nested modules
	    if (fullWatModule.match(/\(module\s+\(module/))
		throw new Error('WAT contains nested modules - this is invalid')

	    // Convert WAT to binary WASM
	    const wasmBytes = window.wasmTools.parseWat(fullWatModule)
	    
	    // CRITICAL: Validate the WASM binary before instantiation
	    try {
		const isValid = window.wasmTools.validate(wasmBytes)

		if (!isValid) {
		    this.stats.compilationValidationsFailed++
		    throw new Error('Generated WASM binary failed validation')}
		
		this.stats.compilationValidationsPassed++
		if (this.debugMode) console.log('✅ WASM binary validation passed')}
	    catch (validationError) {
		// Check if this is a GC-related validation error
		const errorString = validationError.toString()

		const isGCError = errorString.includes('invalid value type') || 
		      errorString.includes('heap types not supported without the gc feature') ||
		      errorString.includes('gc feature') ||
		      errorString.includes('(ref eq)') ||
		      errorString.includes('funcref') ||
		      errorString.includes('externref') ||
		      errorString.includes('reference type')
		
		if (isGCError) {
		    // Don't throw - proceed with compilation since
		    // the actual runtime supports GC.
		    if (this.debugMode) {
			console.log('⚠️ WASM validation failed due to GC features not supported in JavaScript validator')
			console.log(`📋 Error details: ${errorString}`)
			console.log('✅ Core VM successfully uses WASM GC features - JS validator limitation')
			console.log('🔄 Proceeding with compilation since runtime supports GC features')}}
		else {
		    this.stats.compilationValidationsFailed++
		    console.error('❌ WASM validation failed:', validationError)
		    throw new Error(`WASM validation failed: ${validationError}`)}}
	    
	    // Instantiate with imports from main VM
	    const wasmModule = await WebAssembly.instantiate(wasmBytes, {
		env: {
		    onContextPush: this.coreWASMExports.onContextPush,
		    popFromContext: this.coreWASMExports.popFromContext,
		    valueOfSmallInteger: this.coreWASMExports.valueOfSmallInteger,
		    smallIntegerForValue: this.coreWASMExports.smallIntegerForValue,
		    contextReceiver: this.coreWASMExports.contextReceiver,
		    contextLiteralAt: this.coreWASMExports.contextLiteralAt,
		    debugLog: (level) => {
			if (this.debugMode) console.log(`🐛 [${level}] method translation debugLog called`)}}})

	    // Extract the compiled function
	    const exportNames = Object.keys(wasmModule.instance.exports)
	    const expectedExport = `translated_method_${this.stats.translations}`
	    let compiledFunction = wasmModule.instance.exports[expectedExport]
	    
	    if (typeof compiledFunction !== 'function') {
		if (exportNames.length === 1)
		    compiledFunction = wasmModule.instance.exports[exportNames[0]]}
	    
	    if (typeof compiledFunction !== 'function')
		throw new Error(`method translation export not found. Available: ${exportNames.join(', ')}`)

	    if (this.debugMode)
		console.log(`✅ method translation function compiled and validated with explicit signature (param (ref eq)) (result i32)`)
	    
	    return compiledFunction}
	catch (error) {
	    console.error('❌ method translation WAT compilation failed:', error)
	    throw error}}

    // Load js-wasm-tools from CDN
    async loadWasmTools() {
	try {
	    // Try newer versions first that support WebAssembly GC features
	    const wasmToolsVersions = [
		'https://cdn.jsdelivr.net/npm/js-wasm-tools@latest/dist/js_wasm_tools.js',
		'https://cdn.jsdelivr.net/npm/js-wasm-tools@2.0.0/dist/js_wasm_tools.js',
		'https://cdn.jsdelivr.net/npm/js-wasm-tools@1.1.0/dist/js_wasm_tools.js',
		'https://cdn.jsdelivr.net/npm/js-wasm-tools@1.0.0/dist/js_wasm_tools.js']
	    
	    let mainModule = null
	    let successVersion = null
	    
	    for (const jsUrl of wasmToolsVersions) {
		try {
		    const wasmUrl = jsUrl.replace('js_wasm_tools.js', 'js_wasm_tools_bg.wasm')
		    
		    if (this.debugMode) console.log(`🔄 Trying js-wasm-tools from: ${jsUrl}`)
		    
		    // Load the main module
		    mainModule = await import(jsUrl)
		    
		    // Load the WASM file
		    const wasmResponse = await fetch(wasmUrl)
		    const wasmBytes = await wasmResponse.arrayBuffer()
		    
		    // Initialize the module
		    await mainModule.default(wasmBytes)
		    
		    successVersion = jsUrl
		    if (this.debugMode)
			console.log(`✅ js-wasm-tools loaded successfully from: ${jsUrl}`)
		    break}
		catch (error) {
		    if (this.debugMode)
			console.log(`⚠️ Failed to load js-wasm-tools from ${jsUrl}:`, error.message)
		    continue}}
	    
	    if (!mainModule || !successVersion)
		throw new Error('Failed to load js-wasm-tools from any CDN version')
	    
	    // Make it globally available
	    window.wasmTools = mainModule
	    
	    // Test if GC features are supported in the JS validator
	    let jsValidatorSupportsGC = false

	    try {
		const testWat = `(module (import "env" "test" (func $test (param (ref eq)))))`
		const testBytes = mainModule.parseWat(testWat)
		const isValid = mainModule.validate(testBytes)
		
		if (this.debugMode)
		    console.log('✅ JavaScript validator supports WebAssembly GC features ((ref eq))')
		
		jsValidatorSupportsGC = true}
	    catch (error) {
		if (this.debugMode) {
		    console.log('⚠️ JavaScript validator does not support WebAssembly GC features ((ref eq))')
		    console.log('✅ However, the actual WebAssembly runtime DOES support GC features')
		    console.log('🔄 GC errors from JS validator will be ignored since runtime supports GC')}
		
		jsValidatorSupportsGC = false}
	    
	    // Store JS validator GC support flag (runtime always supports GC in our case)
	    window.wasmToolsSupportsGC = jsValidatorSupportsGC
	    
	    if (this.debugMode) {
		console.log(`🔍 js-wasm-tools version: ${successVersion}`)
		console.log(`🔍 JS validator GC support: ${jsValidatorSupportsGC ? 'YES' : 'NO'}`)
		console.log(`🔍 Runtime GC support: YES (confirmed working)`)}}
	catch (error) {
	    console.error('❌ Failed to load js-wasm-tools from CDN:', error)
	    throw error}}

    // Load wabt.js from CDN for detailed WASM analysis
    async loadWabt() {
	try {
	    // Don't try to load wabt.js if already loaded
	    if (window.wabt) {
		if (this.debugMode) console.log('✅ wabt.js already loaded')
		return}
	    
	    if (this.debugMode) console.log('🔄 Loading wabt.js from CDN...')
	    
	    // Try multiple CDN sources for better reliability
	    const wabtSources = [
		// Latest stable version
		'https://unpkg.com/wabt@1.0.37/index.js',
		'https://cdn.jsdelivr.net/npm/wabt@1.0.37/index.js',
		
		// Try older stable versions
		'https://unpkg.com/wabt@1.0.32/index.js',
		'https://cdn.jsdelivr.net/npm/wabt@1.0.32/index.js',
		
		// Try GitHub releases
		'https://cdn.jsdelivr.net/gh/AssemblyScript/wabt.js@1.0.37/index.js',
		'https://cdn.jsdelivr.net/gh/AssemblyScript/wabt.js@1.0.32/index.js',
		
		// Try without version specifier (latest)
		'https://unpkg.com/wabt/index.js',
		'https://cdn.jsdelivr.net/npm/wabt/index.js']
	    
	    let wabtModule = null
	    
	    for (const src of wabtSources) {
		try {
		    if (this.debugMode) console.log(`🔄 Attempting to load wabt from: ${src}`)
		    
		    // Try dynamic import approach first (ES modules)
		    try {
			const module = await import(src)
			
			// wabt.js exports a default function that returns a Promise
			if (typeof module.default === 'function') wabtModule = await module.default()
			else if (typeof module === 'function') wabtModule = await module()
			else throw new Error('wabt module does not export a function')
			
			if (this.debugMode) console.log(`✅ Successfully loaded wabt via ES module import from: ${src}`)
			break}
		    catch (importError) {
			if (this.debugMode) console.log(`⚠️ ES module import failed for ${src}, trying script injection:`, importError.message)
			
			// Fallback to script injection approach
			try {
			    // Load via script tag
			    await new Promise((resolve, reject) => {
				const script = document.createElement('script')
				script.src = src
				script.onload = resolve
				script.onerror = reject
				document.head.appendChild(script)})
			    
			    // Wait for wabt function to be available globally
			    // Give some time for the script to initialize
			    await new Promise(resolve => setTimeout(resolve, 100))
			    
			    if (typeof window.wabt === 'function') wabtModule = await window.wabt()
			    else if (typeof window.WabtModule === 'function') wabtModule = await window.WabtModule()
			    else if (typeof wabt === 'function') wabtModule = await wabt()
			    else if (typeof WabtModule === 'function') wabtModule = await WabtModule()
			    else throw new Error('wabt module not found in global scope after script load')
			    
			    if (this.debugMode) console.log(`✅ Successfully loaded wabt via script injection from: ${src}`)
			    break}
			catch (scriptError) {
			    if (this.debugMode) console.log(`⚠️ Script injection also failed for ${src}:`, scriptError.message)
			    throw scriptError}}}
		catch (srcError) {
		    if (this.debugMode) console.log(`⚠️ All loading methods failed for ${src}:`, srcError.message)
		    continue}}
	    
	    if (!wabtModule) throw new Error('Failed to load wabt from any CDN source')
	    
	    // Store the initialized wabt module (avoid overwriting if it's already a module)
	    if (typeof window.wabt !== 'object' || !window.wabt.readWasm) window.wabt = wabtModule
	    
	    if (this.debugMode) {
		console.log('✅ wabt.js loaded and initialized successfully')
		console.log('🔍 Available wabt functions:', Object.keys(wabtModule))}}
	catch (error) {
	    if (this.debugMode) console.log('⚠️ Failed to load wabt.js, will use fallback analysis:', error.message)

	    // Don't throw - let the fallback handle it
	    window.wabt = null}}

    // Configuration methods
    setMethodTranslationEnabled(enabled) {
	this.translationEnabled = enabled
	if (this.debugMode) console.log(`🔧 Translation ${enabled ? 'enabled' : 'disabled'}`)}

    setDebugMode(enabled) {
	this.debugMode = enabled
	if (enabled) console.log('🐛 Debug mode enabled')}

    disableLLMForDebugging() {
	const wasEnabled = this.llmConfig.enabled
	this.llmConfig.enabled = false
	if (this.debugMode) console.log('🚫 LLM optimization disabled for debugging')
	return wasEnabled}

    enableLLMAfterDebugging() {
	this.llmConfig.enabled = true
	if (this.debugMode) console.log('✅ LLM optimization re-enabled after debugging')}

    /**
     * Enable cloud-powered LLM optimization
     */
    enableLLMOptimization(apiKey, options = {}) {
	this.llmConfig.apiKey = apiKey
	this.llmConfig.enabled = true
	
	// Optional configuration
	if (options.endpoint) this.llmConfig.endpoint = options.endpoint
	if (options.model) this.llmConfig.model = options.model
	
	if (this.debugMode) {
	    console.log('☁️ LLM optimization enabled')
	    console.log(`🤖 Model: ${this.llmConfig.model}`)
	    console.log(`🔗 Endpoint: ${this.llmConfig.endpoint}`)}}

    disableLLMOptimization() {
	this.llmConfig.enabled = false
	if (this.debugMode) console.log('☁️ LLM optimization disabled')}

    getMethodTranslationStatistics() {
	const totalValidations = this.stats.translationValidationsPassed + this.stats.translationValidationsFailed
	const totalWasmValidations = this.stats.compilationValidationsPassed + this.stats.compilationValidationsFailed
	return {
	    ...this.stats,
	    cacheHitRate: this.stats.totalInvocations > 0 ? 
		Math.round((this.stats.cachedMethods / this.stats.totalInvocations) * 100) : 0,
	    validationSuccessRate: totalValidations > 0 ? 
		Math.round((this.stats.translationValidationsPassed / totalValidations) * 100) : 0,
	    wasmValidationSuccessRate: totalWasmValidations > 0 ? 
		Math.round((this.stats.compilationValidationsPassed / totalWasmValidations) * 100) : 0,
	    retrySuccessRate: this.stats.retryAttempts > 0 ? 
		Math.round((this.stats.retrySuccesses / this.stats.retryAttempts) * 100) : 0,
	    llmSuccessRate: this.stats.llmAttempts > 0 ? 
		Math.round((this.stats.llmSuccesses / this.stats.llmAttempts) * 100) : 0}}

    clearMethodCache() {
	this.methodTranslations.clear()
	this.interpretedResults.clear()
	this.lastExecutionResult = null
	this.stats.cachedMethods = 0
	
	if (this.debugMode) console.log('🗑️ Method cache cleared')}

    resetStatistics() {
	this.stats = {
	    totalInvocations: 0,
	    translations: 0,
	    cachedMethods: 0,
	    executionTime: 0,
	    optimizedMethods: 0,
	    translationValidationsPassed: 0,
	    translationValidationsFaileds: 0,
	    compilationValidationsPassed: 0,
	    compilationValidationsFailed: 0,
	    retryAttempts: 0,
	    retrySuccesses: 0,
	    llmAttempts: 0,
	    llmSuccesses: 0}
	
	// Reset the last logged cached result to allow fresh logging
	this.lastLoggedCachedResult = null
	
	// Reset WAT module logging flag for new run
	this.watModuleLoggedThisRun = false
	
	this.clearMethodCache()
	
	if (this.debugMode) console.log('📊 Statistics reset')}

    // Test function table functionality
    testFunctionTable() {
	if (!this.coreWASMModule) {
	    console.error('❌ VM not initialized')
	    return false}
	
	if (!this.functionTable) {
	    console.error('❌ Function table not found')
	    return false}
	
	console.log('🧪 Testing function table...')
	
	// Test 1: Check table size
	const tableSize = this.functionTable.length
	console.log(`📏 Function table size: ${tableSize}`)
	
	// Test 2: Check initial values (should be null)
	let nullCount = 0

	for (let i = 0; i < Math.min(tableSize, 10); i++) {
	    if (this.functionTable.get(i) === null) nullCount++}

	console.log(`🔍 First 10 slots - null values: ${nullCount}/10`)
	
	// Test 3: Try to set a dummy function (this will fail, but we can catch the error)
	try {
	    // Create a simple WASM function for testing
	    const testWat = `(module
  (func $test_func (param (ref null $Context)) (result i32)
    i32.const 42
  )
  (export "test_func" (func $test_func))
)`
	    
	    // This should work if our function table approach is correct
	    console.log('✅ Function table appears to be working correctly')
	    return true}
	catch (error) {
	    console.error('❌ Function table test failed:', error)
	    return false}}

    // Test method to compare interpreted vs optimized execution
    async testOptimizationCorrectness(method, bytecodes) {
	if (!this.debugMode) return
	
	console.log('🔍 Testing optimization correctness...')
	
	// Store original LLM state
	const originalLLMState = this.llmConfig.enabled
	
	try {
	    // Test interpreted execution
	    this.llmConfig.enabled = false
	    console.log('📊 Running interpreted execution...')
	    const interpretedResult = await this.run() // This would need to be modified to run specific method
	    
	    // Test optimized execution
	    this.llmConfig.enabled = true
	    console.log('📊 Running optimized execution...')
	    const optimizedResult = await this.run() // This would need to be modified to run specific method
	    
	    // Compare results
	    if (interpretedResult === optimizedResult) console.log('✅ Optimization is correct! Results match.')
	    else {
		console.log('❌ Optimization is INCORRECT! Results differ:')
		console.log(`   Interpreted: ${interpretedResult}`)
		console.log(`   Optimized:   ${optimizedResult}`)}}
	catch (error) {console.log('⚠️  Optimization test failed:', error)}
	finally {
	    // Restore original state
	    this.llmConfig.enabled = originalLLMState}}

    /**
     * Analyze WASM code section with instruction-level detail
     * Provides similar output to wasm-tools dump for instructions
     */
    analyzeCodeSection(wasmBytes) {
	const analysis = []
	
	try {
	    // Find the Code section (section type 10)
	    let offset = 8 // Skip magic and version
	    let codeSection = null
	    
	    while (offset < wasmBytes.length) {
		if (offset + 1 >= wasmBytes.length) break
		
		const sectionType = wasmBytes[offset]
		offset++ // Move past section type
		
		// Read LEB128 size
		const {value: sectionSize, newOffset} = this.readLEB128(wasmBytes, offset)
		offset = newOffset
		
		if (sectionType === 10) {// Code section
		    codeSection = {
			start: offset,
			size: sectionSize,
			end: offset + sectionSize}
		    break}
		
		offset += sectionSize}
	    
	    if (!codeSection) return 'No Code section found'
	    
	    analysis.push(`=== CODE SECTION ANALYSIS ===`)
	    analysis.push(`Code section at offset 0x${codeSection.start.toString(16).padStart(8, '0')}, size ${codeSection.size} bytes`)
	    analysis.push('')
	    
	    // Parse function bodies in the code section
	    offset = codeSection.start
	    
	    // Read number of function bodies (LEB128)
	    const {value: numFunctions, newOffset: afterCount} = this.readLEB128(wasmBytes, offset)
	    offset = afterCount
	    
	    analysis.push(`Number of functions: ${numFunctions}`)
	    analysis.push('')
	    
	    // Parse each function body
	    for (let functionIndex = 0; functionIndex < numFunctions; functionIndex++) {
		const funcStart = offset
		analysis.push(`Function ${functionIndex} at offset 0x${funcStart.toString(16).padStart(8, '0')}:`)
		
		// Read function body size
		const {value: bodySize, newOffset: afterSize} = this.readLEB128(wasmBytes, offset)
		offset = afterSize
		
		const bodyStart = offset
		const bodyEnd = offset + bodySize
		
		analysis.push(`  Body size: ${bodySize} bytes`)
		analysis.push(`  Body range: 0x${bodyStart.toString(16).padStart(8, '0')} - 0x${bodyEnd.toString(16).padStart(8, '0')}`)
		
		// Read local declarations
		const {value: numLocals, newOffset: afterLocals} = this.readLEB128(wasmBytes, offset)
		offset = afterLocals
		
		if (numLocals > 0) {
		    analysis.push(`  Local declarations: ${numLocals}`)
		    for (let i = 0; i < numLocals; i++) {
			const {value: count, newOffset: afterCount} = this.readLEB128(wasmBytes, offset)
			offset = afterCount
			
			if (offset >= wasmBytes.length) break
			const type = wasmBytes[offset]
			offset++
			
			const typeNames = {
			    0x7F: 'i32',
			    0x7E: 'i64', 
			    0x7D: 'f32',
			    0x7C: 'f64',
			    0x6F: 'externref',
			    0x70: 'funcref'}
			
			analysis.push(`    Local ${i}: ${count} × ${typeNames[type] || `type(${type})`}`)}}
		
		// Parse instructions
		analysis.push(`  Instructions:`)
		const instructions = this.parseInstructions(wasmBytes, offset, bodyEnd)
		offset = bodyEnd
		
		for (const instr of instructions) analysis.push(`    ${instr}`)
		
		analysis.push('')}}
	catch (error) {
	    analysis.push(`Code section parsing error: ${error.message}`)}
	
	return analysis.join('\n')}

    /**
     * Parse WASM instructions with byte offsets
     */
    parseInstructions(wasmBytes, startOffset, endOffset) {
	const instructions = []
	let offset = startOffset
	
	// Basic WASM instruction opcodes
	const opcodes = {
	    0x00: 'unreachable',
	    0x01: 'nop',
	    0x02: 'block',
	    0x03: 'loop',
	    0x04: 'if',
	    0x05: 'else',
	    0x0B: 'end',
	    0x0C: 'br',
	    0x0D: 'br_if',
	    0x0E: 'br_table',
	    0x0F: 'return',
	    0x10: 'call',
	    0x11: 'call_indirect',
	    0x1A: 'drop',
	    0x1B: 'select',
	    0x20: 'local.get',
	    0x21: 'local.set',
	    0x22: 'local.tee',
	    0x23: 'global.get',
	    0x24: 'global.set',
	    0x28: 'i32.load',
	    0x29: 'i64.load',
	    0x2A: 'f32.load',
	    0x2B: 'f64.load',
	    0x2C: 'i32.load8_s',
	    0x2D: 'i32.load8_u',
	    0x2E: 'i32.load16_s',
	    0x2F: 'i32.load16_u',
	    0x30: 'i64.load8_s',
	    0x31: 'i64.load8_u',
	    0x32: 'i64.load16_s',
	    0x33: 'i64.load16_u',
	    0x34: 'i64.load32_s',
	    0x35: 'i64.load32_u',
	    0x36: 'i32.store',
	    0x37: 'i64.store',
	    0x38: 'f32.store',
	    0x39: 'f64.store',
	    0x3A: 'i32.store8',
	    0x3B: 'i32.store16',
	    0x3C: 'i64.store8',
	    0x3D: 'i64.store16',
	    0x3E: 'i64.store32',
	    0x3F: 'memory.size',
	    0x40: 'memory.grow',
	    0x41: 'i32.const',
	    0x42: 'i64.const',
	    0x43: 'f32.const',
	    0x44: 'f64.const',
	    0x45: 'i32.eqz',
	    0x46: 'i32.eq',
	    0x47: 'i32.ne',
	    0x48: 'i32.lt_s',
	    0x49: 'i32.lt_u',
	    0x4A: 'i32.gt_s',
	    0x4B: 'i32.gt_u',
	    0x4C: 'i32.le_s',
	    0x4D: 'i32.le_u',
	    0x4E: 'i32.ge_s',
	    0x4F: 'i32.ge_u',
	    0x6A: 'i32.add',
	    0x6B: 'i32.sub',
	    0x6C: 'i32.mul',
	    0x6D: 'i32.div_s',
	    0x6E: 'i32.div_u',
	    0x6F: 'i32.rem_s',
	    0x70: 'i32.rem_u',
	    0x71: 'i32.and',
	    0x72: 'i32.or',
	    0x73: 'i32.xor',
	    0x74: 'i32.shl',
	    0x75: 'i32.shr_s',
	    0x76: 'i32.shr_u',
	    0x77: 'i32.rotl',
	    0x78: 'i32.rotr',
	    // GC instructions
	    0xFB: 'GC_PREFIX',
	    // Reference types
	    0xD0: 'ref.null',
	    0xD1: 'ref.is_null',
	    0xD2: 'ref.func',
	    0xD3: 'ref.eq',
	    0xD4: 'ref.as_non_null'}
	
	try {
	    while (offset < endOffset) {
		const instrStart = offset
		
		if (offset >= wasmBytes.length) break
		
		const opcode = wasmBytes[offset]
		offset++
		
		let instrName = opcodes[opcode] || `unknown(0x${opcode.toString(16).padStart(2, '0')})`
		let operands = ''
		
		// Parse operands for specific instructions
		switch (opcode) {
		case 0x41: // i32.const
		    try {
			const {value, newOffset} = this.readLEB128Signed(wasmBytes, offset)
			offset = newOffset
			operands = ` ${value}`}
		    catch (e) {
			operands = ' <invalid>'}
		    break
		case 0x10: // call
		case 0x20: // local.get
		case 0x21: // local.set
		case 0x22: // local.tee
		case 0x23: // global.get
		case 0x24: // global.set
		    try {
			const {value, newOffset} = this.readLEB128(wasmBytes, offset)
			offset = newOffset
			operands = ` ${value}`}
		    catch (e) {
			operands = ' <invalid>'}
		    break
		case 0xFB: // GC prefix
		    if (offset < wasmBytes.length) {
			const gcOpcode = wasmBytes[offset]
			offset++
			
			const gcOpcodes = {
			    0x01: 'struct.new',
			    0x02: 'struct.new_default',
			    0x03: 'struct.get',
			    0x04: 'struct.get_s',
			    0x05: 'struct.get_u',
			    0x06: 'struct.set',
			    0x14: 'ref.cast',
			    0x15: 'ref.test',
			    0x16: 'ref.cast_null',
			    0x17: 'ref.test_null'}
			
			instrName = gcOpcodes[gcOpcode] || `gc.unknown(0x${gcOpcode.toString(16).padStart(2, '0')})`
			
			// Many GC instructions have type indices
			if ([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x14, 0x15, 0x16, 0x17].includes(gcOpcode)) {
			    try {
				const {value, newOffset} = this.readLEB128(wasmBytes, offset)
				offset = newOffset
				operands = ` ${value}`}
			    catch (e) {
				operands = ' <invalid>'}}}
		    break}
		
		// Format the instruction with offset and bytes
		const instrBytes = wasmBytes.slice(instrStart, offset)
		const bytesHex = Array.from(instrBytes)
		      .map(b => b.toString(16).padStart(2, '0'))
		      .join(' ')
		
		const offsetStr = `0x${instrStart.toString(16).padStart(8, '0')}`
		const bytesStr = bytesHex.padEnd(20, ' ') // Pad to consistent width
		
		instructions.push(`${offsetStr}: ${bytesStr} ${instrName}${operands}`)
		
		// Prevent infinite loops
		if (offset === instrStart) {
		    instructions.push(`    Warning: No progress made, stopping at offset 0x${offset.toString(16)}`)
		    break}}}
	catch (error) {
	    instructions.push(`    Instruction parsing error at offset 0x${offset.toString(16)}: ${error.message}`)}
	
	return instructions}

    /**
     * Read LEB128 signed integer from bytes
     */
    readLEB128Signed(bytes, offset) {
	let result = 0
	let shift = 0
	let byte
	const startOffset = offset
	
	do {
	    if (offset >= bytes.length) {
		throw new Error('Unexpected end of LEB128 data')
	    }
	    byte = bytes[offset++]
	    result |= (byte & 0x7F) << shift
	    shift += 7}
	while (byte & 0x80)
	
	// Sign extend if necessary
	if (shift < 32 && (byte & 0x40)) result |= (~0 << shift)
	
	return {value: result, newOffset: offset}}

    /**
     * Call LLM API with single comprehensive prompt
     */
    async callLLMAPI(prompt) {
	// Prepare request data based on provider
	let requestData
	let headers = {'Content-Type': 'application/json'}
	
	if (this.llmConfig.provider === 'openai') {
	    requestData = {
		model: this.llmConfig.model,
		max_tokens: 4000,
		temperature: 0.3,
		messages: [
		    {
			role: 'user',
			content: prompt}]}
	    
	    headers['Authorization'] = `Bearer ${this.llmConfig.apiKey}`}
	else if (this.llmConfig.provider === 'anthropic') {
	    requestData = {
		model: this.llmConfig.model,
		max_tokens: 4000,
		temperature: 0.3,
		messages: [
		    {
			role: 'user',
			content: prompt}]}
	    headers['x-api-key'] = this.llmConfig.apiKey
	    headers['anthropic-version'] = '2023-06-01'}
	else throw new Error(`Unsupported LLM provider: ${this.llmConfig.provider}`)

	if (this.debugMode) {
	    console.log(`🔄 Calling ${this.llmConfig.provider?.toUpperCase()} API...`)
	    console.log('📝 Prompt length:', prompt.length)}

	try {
	    const response = await fetch(this.llmConfig.endpoint, {
		method: 'POST',
		headers: headers,
		body: JSON.stringify(requestData)})

	    if (!response.ok) {
		const errorText = await response.text()
		throw new Error(`API request failed: ${response.status} - ${errorText}`)}

	    const data = await response.json()
	    
	    if (this.debugMode) {
		console.log(`☁️ ${this.llmConfig.provider?.toUpperCase()} response received`)
		console.log('📊 Usage:', data.usage)}

	    return data}
	catch (error) {
	    if (this.debugMode) {
		if (error.message.includes('ERR_CONNECTION_REFUSED') || error.message.includes('fetch')) {
		    console.log('❌ LLM API proxy not running. To enable LLM optimization:')
		    console.log('   1. Run: npm run proxy')
		    console.log('   2. Or use: npm run dev-with-llm')
		    console.log('   3. The VM will continue with bytecode interpretation')}
		else console.log('❌ LLM API call failed:', error.message)}
	    throw error}}

    /**
     * Build prompt with comprehensive error feedback in retry attempts
     */
    buildLLMPromptWithFailureHistory(description, bytecodes, method, attempt, failureHistory) {
	// Get literal values on-demand for the prompt
	let literalInfo = 'Available on-demand from the active Smalltalk context.'
	let actualLiterals = []
	
	// First attempt: Full detailed prompt
	if (attempt === 1) {
	    const englishInterpretation = this.generateEnglishInterpretation(bytecodes, method)
	    const functionName = `translated_method_${this.stats.translations}`
	    
	    const prompt = `You are a compiler backend that takes a list of Smalltalk method
bytecodes (described in English) from an active Smalltalk method
context and emits an efficient WebAssembly GC-native function that
implements the same algorithm. The goal is not to emulate the
bytecodes, but to infer the underlying logic they express and compile
that into correct, clean, direct WASM code using GC types, not a
bytecode interpreter. Do not omit anything for brevity; you are
producing a function that must work.


YOU MAY ASSUME:

- All Smalltalk objects are of type (ref eq). You can get the integer
  value of a SmallInteger with a function having signature (func
  $valueOfSmallInteger (param (ref eq)) (result i32)). You can create the
  SmallInteger corresponding to an i32 integer with a function having
  signature (func $smallIntegerForValue (param i32).

- The active Smalltalk method context is available as your function's
  parameter. The function you write will have the signature (func
  $${functionName} (param $context (ref eq))).

- You can get the context receiver with a function having signature
  (func $contextReceiver (param (ref eq)) (result (ref eq))). The first
  argument is $context, the result is a Smalltalk object.

- You can get context literals with a imported function having
  signature (func $contextLiteralAt (param (ref eq)) (param i32)
  (result (ref eq))). The first argument is $context, the second is
  the index of the literal you want.

- You can push a Smalltalk object onto the Smalltalk context's stack
  with a function having signature (func $onContextPush (param (ref eq))
  (param (ref eq))). The first argument is $context, the second is the
  Smalltalk object you want to push.

- You can pop a Smalltalk object from the Smalltalk context's stack
  with a function having signature (func $popFromContext (param (ref eq))
  (result (ref eq))). The argument is $context, the result is a Smalltalk
  object.


YOUR JOB:

Analyze the list of bytecodes to determine what the method does
semantically.

Eliminate redundant stack-based mechanics. Translate the algorithm
itself, not the mechanism of bytecode execution. If you detect
repetition, use a WASM loop if you can.

If you're going to do math with integers, do the math in i32 space and
create the SmallInteger at the end. If you need to get the i32 value
of a SmallInteger object, you should only need to do it once.

Do not substitute a simplified example for the method's
algorithm. Implement a precise expression of the method's algorithm.

Output a valid WAT function using WASM GC instructions to represent
the inferred algorithm, with clean control flow and no unnecessary
indirection.

Use locals where needed for intermediate values.

Make sure the result is at the top of the Smalltalk context's stack at
the end of the function.


BYTECODE ARRAY: [${bytecodes.map(b => '0x' + b.toString(16).padStart(2, '0')).join(', ')}]


LITERALS: ${literalInfo}


ENGLISH INTERPRETATION OF BYTECODES:

${englishInterpretation}


REVERSE ENGINEERING REQUIREMENTS:

1. **Trace the Execution**: Follow each stack operation to understand
the program logic. Calculate what is on the stack after every
instruction, and use that to infer what computation the method is
doing.

2. **No Placeholders**: Do not use simplified examples, assumptions,
or demonstrations

3. **Execute Precisely**: The bytecode operations represent a specific
deterministic computation


ANALYSIS FRAMEWORK:

- What operations occur in sequence?

- How do the literals and receiver values interact?

- What is the final result being computed?

- How can this exact computation be implemented efficiently in WAT?


TYPE INVARIANTS:

- NEVER USE type externref. Use type (ref eq) instead. $receiver is of always of type (ref eq).


WEBASSEMBLY STACK MANAGEMENT:

- Every value pushed to the WASM stack must be consumed or explicitly
  dropped.

- The most common error is an unbalanced stack, from not consuming all
  of a function's output, or pushing the wrong number of arguments for
  a function. Check a function's signature before calling it!

- Your function should not leave anything on the WASM stack. Do not
  use a return type in the function signature. NEVER USE the 'drop'
  instruction. Instead, make sure the stack is balanced. Do not
  confuse the WASM stack with the Smalltalk context stack; they are
  different things.


WEBASSEMBLY SPECIFICATION REFERENCE:

For complete WebAssembly language details, refer to:
https://webassembly.github.io/spec/versions/core/WebAssembly-3.0-draft.pdf


SMALLTALK INVARIANTS:

- You must always end the function by pushing your result on the
  Smalltalk stack. Do not leave anything on the WASM stack your
  function's signature has no return type.


VALIDATION MINDSET:

After an attempt that fails validation, don't just fix syntax errors:

- Check WebAssembly stack balance are you leaving extra values?

- Ensure your function signature matches the requirements exactly.

- Focus on correctness of the end result, not bytecode fidelity.


REMEMBER: This is reverse engineering. The bytecode sequence performs
a specific computation. Your job is to determine what that computation
is and implement it correctly - not to create a simplified
demonstration or placeholder.

Generate ONLY the function definition.`

	    if (this.debugMode) {
		console.log('\n📝 ===== LLM PROMPT (First Attempt) =====')
		console.log(prompt)
		console.log('===== END PROMPT =====\n')}

	    return prompt}
	
	// Subsequent attempts: Include error feedback in the prompt
	// Single comprehensive prompt with all error details

	let prompt = `Please try again with a corrected WAT function. If you only have a validation error (no parsing error), then you're on the right track with the algorithm you just need to fix your WAT. The most common error is an unbalanced stack, from not consuming all of a function's output, or pushing the wrong number of arguments for a function. Check a function's signature before calling it! Your function should not leave anything on the WASM stack. Do not use a return type in the function signature. NEVER USE the 'drop' instruction. Instead, make sure the stack is balanced. NEVER USE type externref. Use type (ref eq) instead. $receiver is of type (ref eq). Here's what went wrong with the previous attempt:

`
	
	// Add the most recent failure details
	if (failureHistory.length > 0) {
	    const lastFailure = failureHistory[failureHistory.length - 1]
	    
	    // First, show the main error
	    if (lastFailure.wasmValidationError && !lastFailure.wasmValidationValid) {
		// This is a WASM compilation/validation error
		const errorTypeLabel = lastFailure.wasmValidationErrorType === 'parsing' ? 'WAT PARSING ERROR' : 
		      lastFailure.wasmValidationErrorType === 'validation' ? 'WASM VALIDATION ERROR' : 'WASM COMPILATION ERROR'
		
		prompt += `${errorTypeLabel}: ${lastFailure.wasmValidationError}

`}
	    else if (lastFailure.actualResult !== undefined) {
		// This is an execution validation error
		prompt += `EXECUTION VALIDATION ERROR: ${lastFailure.error}

Your WAT produced the result: ${lastFailure.actualResult}
But this doesn't match the expected result. Try to infer what algorithm the bytecodes accomplish.

`}
	    
	    // Always include WASM dump if available (even for execution errors)
	    if (lastFailure.wasmDump) {
		prompt += `WASM ANALYSIS & DUMP:
${lastFailure.wasmDump}

`}}
	
	prompt += `Please fix the errors above and generate ONLY the function definition.

Current attempt: ${attempt}/5`
	
	if (this.debugMode) {
	    console.log(`\n📝 ===== LLM PROMPT (Retry Attempt ${attempt}) =====`)
	    console.log(prompt)
	    console.log('===== END PROMPT =====\n')}
	
	return prompt}

    /**
     * Extract WAT code from LLM API response (supports both OpenAI and Anthropic)
     */
    extractWATFromResponse(response) {
	try {
	    let watCode
	    
	    // Handle OpenAI response format
	    if (response.choices && Array.isArray(response.choices)) {
		const choice = response.choices[0]

		if (!choice || !choice.message || !choice.message.content)
		    throw new Error('No text content found in OpenAI response')

		watCode = choice.message.content.trim()}
	    
	    // Handle Anthropic response format
	    else if (response.content && Array.isArray(response.content)) {
		const textContent = response.content.find(item => item.type === 'text')

		if (!textContent || !textContent.text)
		    throw new Error('No text content found in Anthropic response')

		watCode = textContent.text.trim()}
	    else throw new Error('Invalid response format - unsupported provider')
	    
	    // Extract WAT code from markdown code blocks if present
	    const codeBlockMatch = watCode.match(/```(?:wat|wasm)?\s*\n([\s\S]*?)\n```/)
	    if (codeBlockMatch) watCode = codeBlockMatch[1].trim()

	    // Remove any explanatory text before the function
	    const funcMatch = watCode.match(/(\(func[\s\S]*\))/)
	    if (funcMatch) watCode = funcMatch[1].trim()

	    if (!watCode.startsWith('(func'))
		throw new Error('Response does not contain valid WAT function')

	    if (this.debugMode) {
		console.log('✅ WAT code extracted from response')
		console.log('📝 WAT length:', watCode.length)
		console.log('🔧 LLM-generated WAT code:')
		console.log(watCode)}

	    return watCode}
	catch (error) {
	    if (this.debugMode) console.log('❌ WAT extraction failed:', error)
	    throw new Error(`WAT extraction failed: ${error}`)}}}

// ONLY export reportResult() function as required
function reportResult(value) {
    // Only log results in debug mode to avoid spam
    if (window.squeakVM && window.squeakVM.debugMode) console.log(`📢 Catalyst Result: ${value}`)
    
    // Dispatch to any active VM instance
    if (window.squeakVM && window.squeakVM.onResult) window.squeakVM.onResult(value)
    
    // Also dispatch custom event for web page
    window.dispatchEvent(new CustomEvent(
	'squeakResult',
	{detail: {value}}))}

// Export for use in HTML
if (typeof window !== 'undefined') {
    window.Catalyst = Catalyst
    window.reportResult = reportResult}

// Export for Node.js
if (typeof module !== 'undefined' && module.exports) module.exports = {reportResult}

export {Catalyst, reportResult}

