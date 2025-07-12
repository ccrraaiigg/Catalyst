# LLM Optimization Demo 🤖

This demonstrates the Squeak VM's **LLM-powered bytecode optimization** feature. The VM can automatically generate optimized WebAssembly code using either **OpenAI GPT** or **Anthropic Claude** models instead of traditional manual compilation.

## 🎯 What This Does

The LLM optimizer:
1. **Analyzes** Squeak bytecode sequences 
2. **Understands** what they accomplish at a high level
3. **Generates** optimized WebAssembly (WAT) code
4. **Validates** the optimization produces correct results
5. **Falls back** to interpretation if optimization fails

This is **true AI-assisted compilation** - the LLM acts as an expert WebAssembly programmer.

## 🚀 Quick Start

### Option 1: Use the Full Development Environment
```bash
npm run dev-with-llm
```
This starts both the web server and the API proxy.

### Option 2: Start Components Separately
```bash
# Terminal 1: Start the API proxy
npm run proxy

# Terminal 2: Start the web server  
npm run dev
```

Then visit: http://localhost:8000/test.html

## 🔑 API Key Setup

### Step 1: Choose Your LLM Provider

**Option A: OpenAI (GPT-4o)**
1. Sign up at [OpenAI Platform](https://platform.openai.com/)
2. Go to API Keys section  
3. Create a new API key (starts with `sk-proj-`)

**Option B: Anthropic (Claude 3.5 Sonnet)**
1. Sign up at [Anthropic Console](https://console.anthropic.com/)
2. Go to API Keys section
3. Create a new API key (starts with `sk-ant-`)

### Step 2: Configure the Key
1. **Copy the example**: `cp keys.example keys`
2. **Add your API key(s)** - the first one listed will be used as primary

**Example keys file:**
```
# Put your preferred provider FIRST (this will be primary)
openai=sk-proj-abcdef123456789...
anthropic=sk-ant-api03-your_key_here

# Or use Anthropic as primary:
# anthropic=sk-ant-api03-your_key_here  
# openai=sk-proj-abcdef123456789...
```

**🔄 Switching Providers:** Simply reorder the lines in your `keys` file!

### Step 3: Test the Setup
1. Run `npm run dev-with-llm`
2. Open http://localhost:8000/test.html
3. Click "Run Test" and watch for LLM optimization logs
4. You should see:
   ```
   🔄 Calling LLM API...
   ☁️ LLM response received
   ✅ LLM success on attempt 1
   ```

## 🧪 How It Works

### Traditional Approach
```
Bytecodes → Literal WAT Translation → Basic WASM
```

### LLM-Optimized Approach
```
Bytecodes → English Analysis → LLM Reasoning → Optimized WAT → Advanced WASM
```

### Example Transformation

**Input Bytecodes:**
```
[0x20, 0x21, 0xB8, 0x22, 0xB0, 0x7C]  // push 0, push 1, multiply, push 2, add, return
```

**LLM Analysis:**
"This method computes `(0 * 1) + 2` which simplifies to `2`"

**LLM-Generated WAT:**
```wat
(func $jit_method_0 (param $ctx i32) (result i32)
  (call $pushOnStack (local.get $ctx) (call $createSmallInteger (i32.const 2)))
  (return (i32.const 1)))
```

## 🔧 Advanced Configuration

You can customize the LLM configuration in `catalyst.js`:

```javascript
vm.enableLLMOptimization('your-api-key', {
  endpoint: 'http://localhost:8001/api/openai',
  model: 'gpt-4o'
});
```

## 🐛 Troubleshooting

### No LLM Optimization
1. **Get API Key**: Sign up for OpenAI or Anthropic, get API key
2. **Configure Provider**: Add key to `keys` file (first one listed is used)
3. **Test Connection**: Check proxy server is running

### Common Issues

**"LLM API proxy not running"**
```bash
# Start the proxy
npm run proxy
```

**"No API key found"**
- Check your `keys` file exists and has correct format
- Ensure OpenAI keys start with `sk-proj-` or `sk-`
- Ensure Anthropic keys start with `sk-ant-`

**"API request failed"**
- Verify your API key is valid (OpenAI or Anthropic)
- Check you have sufficient API credits
- Try switching providers by reordering your `keys` file
- Ensure network connectivity

### Testing LLM Integration

```javascript
async callLLMAPI(prompt) {
    const response = await fetch('http://localhost:8001/api/openai', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.llmConfig.apiKey}`,
        },
        body: JSON.stringify({
            model: 'gpt-4o',
            messages: [{ role: 'user', content: prompt }],
            max_tokens: 4000,
            temperature: 0.3
        })
    });
    return await response.json();
}
```

## 📊 Performance Benefits

LLM optimization can provide:
- **10-100x speedup** for mathematical computations
- **Constant-time execution** for compile-time-calculable expressions  
- **Reduced memory allocation** through direct value computation
- **Better instruction-level parallelism** through optimized instruction ordering

## 🔮 Future Directions

- **✅ Multi-provider support**: Now supports OpenAI GPT and Anthropic Claude
- **Advanced optimization patterns**: Loop unrolling, vectorization  
- **Caching**: Store optimized functions for reuse
- **Profile-guided optimization**: Use runtime data to improve generated code
- **Local model support**: Integration with local LLMs for privacy/cost

This represents the **future of dynamic compilation** - AI systems that understand code intent and generate optimal implementations automatically.

## 💡 Tips

- LLM optimization works best on **mathematical** and **computational** bytecode sequences
- **Control flow heavy** code still benefits from traditional compilation
- The system **validates** all optimizations, so incorrect LLM outputs are automatically discarded
- **Cost**: Each optimization costs ~$0.01-0.02 in API credits 
