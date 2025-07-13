#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');
const { promisify } = require('util');
const { pipeline } = require('stream');
const streamPipeline = promisify(pipeline);

/**
 * WasmOptWrapper - A wrapper around wasm-opt for WAT files with dead code elimination
 * that preserves comments in the output.
 */
class WasmOptWrapper {
  constructor(wasmOptPath = 'wasm-opt') {
    this.wasmOptPath = wasmOptPath;
    this.tempDir = path.join(__dirname, 'temp');
    this.ensureTempDir();
  }

  ensureTempDir() {
    if (!fs.existsSync(this.tempDir)) {
      fs.mkdirSync(this.tempDir, { recursive: true });
    }
  }

  /**
   * Extract comments from WAT source code
   * @param {string} watContent - The WAT source code
   * @returns {Map<number, string[]>} Map of line numbers to comments
   */
  extractComments(watContent) {
    const lines = watContent.split('\n');
    const comments = new Map();
    
    lines.forEach((line, index) => {
      const lineNumber = index + 1;
      const commentMatches = line.match(/;;.*$/g);
      if (commentMatches) {
        comments.set(lineNumber, commentMatches);
      }
      
      // Also handle block comments (;; ... ;;)
      const blockCommentMatch = line.match(/\(;.*?;\)/g);
      if (blockCommentMatch) {
        const existing = comments.get(lineNumber) || [];
        comments.set(lineNumber, [...existing, ...blockCommentMatch]);
      }
    });
    
    return comments;
  }

  /**
   * Create a mapping between original and optimized WAT lines
   * This is a heuristic approach since wasm-opt doesn't preserve line mappings
   * @param {string} originalWat - Original WAT content
   * @param {string} optimizedWat - Optimized WAT content
   * @returns {Map<number, number>} Map of optimized line numbers to original line numbers
   */
  createLineMapping(originalWat, optimizedWat) {
    const originalLines = originalWat.split('\n');
    const optimizedLines = optimizedWat.split('\n');
    const mapping = new Map();
    
    // Simple heuristic: match lines by their significant tokens
    optimizedLines.forEach((optimizedLine, optimizedIndex) => {
      const cleanedOptimized = optimizedLine.replace(/;;.*$/, '').trim();
      if (cleanedOptimized) {
        // Find the best matching original line
        let bestMatch = -1;
        let bestScore = 0;
        
        originalLines.forEach((originalLine, originalIndex) => {
          const cleanedOriginal = originalLine.replace(/;;.*$/, '').trim();
          if (cleanedOriginal) {
            const score = this.calculateLineSimilarity(cleanedOptimized, cleanedOriginal);
            if (score > bestScore && score > 0.7) {
              bestScore = score;
              bestMatch = originalIndex + 1;
            }
          }
        });
        
        if (bestMatch !== -1) {
          mapping.set(optimizedIndex + 1, bestMatch);
        }
      }
    });
    
    return mapping;
  }

  /**
   * Calculate similarity between two lines (simple token-based approach)
   * @param {string} line1 
   * @param {string} line2 
   * @returns {number} Similarity score between 0 and 1
   */
  calculateLineSimilarity(line1, line2) {
    if (line1 === line2) return 1.0;
    
    const tokens1 = line1.split(/\s+/).filter(t => t.length > 0);
    const tokens2 = line2.split(/\s+/).filter(t => t.length > 0);
    
    if (tokens1.length === 0 && tokens2.length === 0) return 1.0;
    if (tokens1.length === 0 || tokens2.length === 0) return 0.0;
    
    const intersection = tokens1.filter(t => tokens2.includes(t));
    const union = [...new Set([...tokens1, ...tokens2])];
    
    return intersection.length / union.length;
  }

  /**
   * Reinsert comments into optimized WAT
   * @param {string} optimizedWat - The optimized WAT content
   * @param {Map<number, string[]>} originalComments - Original comments
   * @param {Map<number, number>} lineMapping - Line mapping from optimized to original
   * @returns {string} WAT with comments reinserted
   */
  reinsertComments(optimizedWat, originalComments, lineMapping) {
    const lines = optimizedWat.split('\n');
    
    lines.forEach((line, index) => {
      const lineNumber = index + 1;
      const originalLineNumber = lineMapping.get(lineNumber);
      
      if (originalLineNumber && originalComments.has(originalLineNumber)) {
        const comments = originalComments.get(originalLineNumber);
        // Append comments to the line
        comments.forEach(comment => {
          lines[index] += ` ${comment}`;
        });
      }
    });
    
    return lines.join('\n');
  }

  /**
   * Process WAT file with dead code elimination
   * @param {string} inputWat - Input WAT content or file path
   * @param {Object} options - Processing options
   * @returns {Promise<string>} Optimized WAT with preserved comments
   */
  async processWat(inputWat, options = {}) {
    const {
      outputFile = null,
      additionalPasses = [],
      preserveDebugInfo = true,
      customWasmOptArgs = [],
      enableFeatures = []
    } = options;

    let watContent;
    
    // Determine if input is file path or content
    if (fs.existsSync(inputWat)) {
      watContent = fs.readFileSync(inputWat, 'utf8');
    } else {
      watContent = inputWat;
    }

    // Extract comments before optimization
    const originalComments = this.extractComments(watContent);

    // Create temporary files
    const tempInputWat = path.join(this.tempDir, `input_${Date.now()}.wat`);
    const tempInputWasm = path.join(this.tempDir, `input_${Date.now()}.wasm`);
    const tempOutputWasm = path.join(this.tempDir, `output_${Date.now()}.wasm`);
    const tempOutputWat = path.join(this.tempDir, `output_${Date.now()}.wat`);

    try {
      // Write input WAT to temporary file with explicit UTF-8 encoding
      fs.writeFileSync(tempInputWat, watContent, 'utf8');

      // For WAT input, we can directly optimize and output WAT
      // without the intermediate WASM conversion that was causing issues
      const optimizationArgs = [
        tempInputWat,
        '-o', tempOutputWat,
        '--emit-text', // Ensure text output
        '--dce', // Dead code elimination
        ...enableFeatures,
        ...additionalPasses,
        ...customWasmOptArgs
      ];

      if (preserveDebugInfo) {
        optimizationArgs.push('--debuginfo');
      }

      await this.execWasmOpt(optimizationArgs);

      // Read optimized WAT
      const optimizedWat = fs.readFileSync(tempOutputWat, 'utf8');

      // Create line mapping and reinsert comments
      const lineMapping = this.createLineMapping(watContent, optimizedWat);
      const finalWat = this.reinsertComments(optimizedWat, originalComments, lineMapping);

      // Write output file if specified
      if (outputFile) {
        fs.writeFileSync(outputFile, finalWat);
      }

      return finalWat;

    } finally {
      // Clean up temporary files
      [tempInputWat, tempInputWasm, tempOutputWasm, tempOutputWat].forEach(file => {
        if (fs.existsSync(file)) {
          fs.unlinkSync(file);
        }
      });
    }
  }

  /**
   * Execute wasm-opt with given arguments
   * @param {string[]} args - Arguments for wasm-opt
   * @returns {Promise<void>}
   */
  async execWasmOpt(args) {
    return new Promise((resolve, reject) => {
      const child = spawn(this.wasmOptPath, args, {
        stdio: ['pipe', 'pipe', 'pipe']
      });

      let stdout = '';
      let stderr = '';

      child.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      child.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      child.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`wasm-opt exited with code ${code}\nstderr: ${stderr}\nstdout: ${stdout}`));
        } else {
          resolve();
        }
      });

      child.on('error', (error) => {
        reject(new Error(`Failed to spawn wasm-opt: ${error.message}`));
      });
    });
  }

  /**
   * Clean up temporary directory
   */
  cleanup() {
    if (fs.existsSync(this.tempDir)) {
      fs.rmSync(this.tempDir, { recursive: true, force: true });
    }
  }
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log(`
Usage: node wasm-opt-wrapper.js <input.wat> [options]

Options:
  -o, --output <file>    Output file (default: stdout)
  -p, --passes <passes>  Additional optimization passes (comma-separated)
  --wasm-opt-path <path> Path to wasm-opt executable
  --no-debug             Don't preserve debug info
  --enable-gc            Enable garbage collection proposal
  --enable-reference-types Enable reference types proposal
  --enable-bulk-memory   Enable bulk memory proposal
  --enable-simd          Enable SIMD proposal
  --enable-threads       Enable threads proposal
  --enable-exception-handling Enable exception handling proposal
  --help                 Show this help

Examples:
  node wasm-opt-wrapper.js input.wat -o output.wat
  node wasm-opt-wrapper.js input.wat -p "duplicate-function-elimination,memory-packing"
  echo "(module (func))" | node wasm-opt-wrapper.js /dev/stdin
    `);
    process.exit(1);
  }

  let inputFile = null;
  const options = {};
  const additionalPasses = [];
  const enableFeatures = [];
  let wasmOptPath = 'wasm-opt';
  let preserveDebugInfo = true;

  // Parse command line arguments
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === '-o' || arg === '--output') {
      options.outputFile = args[++i];
    } else if (arg === '-p' || arg === '--passes') {
      const passes = args[++i].split(',');
      additionalPasses.push(...passes.map(p => `--${p.trim()}`));
    } else if (arg === '--wasm-opt-path') {
      wasmOptPath = args[++i];
    } else if (arg === '--no-debug') {
      preserveDebugInfo = false;
    } else if (arg === '--enable-gc') {
      enableFeatures.push('--enable-gc');
    } else if (arg === '--enable-reference-types') {
      enableFeatures.push('--enable-reference-types');
    } else if (arg === '--enable-bulk-memory') {
      enableFeatures.push('--enable-bulk-memory');
    } else if (arg === '--enable-simd') {
      enableFeatures.push('--enable-simd');
    } else if (arg === '--enable-threads') {
      enableFeatures.push('--enable-threads');
    } else if (arg === '--enable-exception-handling') {
      enableFeatures.push('--enable-exception-handling');
    } else if (arg === '--help') {
      console.log('Help already shown above');
      process.exit(0);
    } else if (!arg.startsWith('--') && !inputFile) {
      // This is the input file
      inputFile = arg;
    }
  }

  if (!inputFile) {
    console.error('Error: No input file specified');
    process.exit(1);
  }

  options.additionalPasses = additionalPasses;
  options.preserveDebugInfo = preserveDebugInfo;
  options.enableFeatures = enableFeatures;

  const wrapper = new WasmOptWrapper(wasmOptPath);

  try {
    const result = await wrapper.processWat(inputFile, options);
    
    if (!options.outputFile) {
      console.log(result);
    } else {
      console.log(`Optimized WAT written to: ${options.outputFile}`);
    }
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    wrapper.cleanup();
  }
}

// Export for use as a module
module.exports = WasmOptWrapper;

// Run CLI if this script is executed directly
if (require.main === module) {
  main().catch(console.error);
}