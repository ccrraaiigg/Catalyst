#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

if (process.argv.length < 3) {
  console.error('Usage: node wat-folder.js <input.wat> [output.wat]');
  console.error('Converts linear WAT syntax to folded S-expression syntax while preserving comments');
  process.exit(1);
}

const inputPath = process.argv[2];
const outputPath = process.argv[3] || inputPath.replace(/\.wat$/, '.folded.wat');

class WATFolder {
  constructor() {
    this.tokens = [];
    this.position = 0;
    this.indentLevel = 0;
    this.output = [];
    this.debugMode = false; // Set to true for debugging
  }

  tokenize(input) {
    // Enhanced tokenization that preserves comments and whitespace context
    const tokenRegex = /(\s*;;[^\n]*)|(\s*\([^)]*\))|(\s*\()|(\s*\))|(\s*[^\s()]+)|(\s+)/g;
    const tokens = [];
    let match;
    
    while ((match = tokenRegex.exec(input)) !== null) {
      const token = match[0];
      if (token.trim()) {
        if (token.trim().startsWith(';;')) {
          tokens.push({ type: 'comment', value: token.trim(), indent: token.length - token.trimStart().length });
        } else if (token.trim() === '(') {
          tokens.push({ type: 'open_paren', value: '(', indent: token.length - token.trimStart().length });
        } else if (token.trim() === ')') {
          tokens.push({ type: 'close_paren', value: ')', indent: token.length - token.trimStart().length });
        } else if (token.trim().startsWith('(') && token.trim().endsWith(')')) {
          // Handle single-token parenthesized expressions
          tokens.push({ type: 'single_expr', value: token.trim(), indent: token.length - token.trimStart().length });
        } else {
          tokens.push({ type: 'instruction', value: token.trim(), indent: token.length - token.trimStart().length });
        }
      }
    }
    return tokens;
  }

  parseLinearInstructions(input) {
    // Parse linear instruction sequences into expression trees
    const lines = input.split('\n');
    const result = [];
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const trimmed = line.trim();
      
      // Skip empty lines and already folded expressions
      if (!trimmed || trimmed.startsWith('(') || trimmed.startsWith(')') || trimmed.startsWith(';;')) {
        result.push(line);
        continue;
      }
      
      // Check if this is a foldable linear instruction sequence
      if (this.isLinearInstruction(trimmed)) {
        const sequence = this.collectLinearSequence(lines, i);
        if (sequence.instructions.length > 1) {
          const folded = this.foldInstructionSequence(sequence.instructions, line.match(/^(\s*)/)[1]);
          result.push(folded);
          i += sequence.linesConsumed - 1; // Skip the lines we just processed
        } else {
          result.push(line);
        }
      } else {
        result.push(line);
      }
    }
    
    return result.join('\n');
  }

  isLinearInstruction(line) {
    // Instructions that can be folded
    const foldableInstructions = [
      'local.get', 'local.set', 'local.tee',
      'global.get', 'global.set',
      'i32.const', 'i64.const', 'f32.const', 'f64.const',
      'i32.add', 'i32.sub', 'i32.mul', 'i32.div_s', 'i32.div_u',
      'i32.eq', 'i32.ne', 'i32.lt_s', 'i32.gt_s', 'i32.le_s', 'i32.ge_s',
      'call', 'call_indirect',
      'struct.get', 'struct.set', 'struct.new',
      'array.get', 'array.set', 'array.new',
      'ref.null', 'ref.eq', 'ref.as_non_null'
    ];
    
    return foldableInstructions.some(instr => line.startsWith(instr));
  }

  collectLinearSequence(lines, startIndex) {
    const instructions = [];
    let i = startIndex;
    
    while (i < lines.length) {
      const line = lines[i].trim();
      
      // Stop at empty lines, comments, or structural elements
      if (!line || line.startsWith(';;') || line.startsWith('(') || 
          line.startsWith(')') || line.startsWith('end') || 
          line.startsWith('else') || line.startsWith('loop') ||
          line.startsWith('block') || line.startsWith('if')) {
        break;
      }
      
      if (this.isLinearInstruction(line)) {
        instructions.push({
          instruction: line,
          indent: lines[i].match(/^(\s*)/)[1]
        });
        i++;
      } else {
        break;
      }
    }
    
    return {
      instructions: instructions,
      linesConsumed: i - startIndex
    };
  }

  foldInstructionSequence(instructions, baseIndent) {
    if (instructions.length <= 1) {
      return baseIndent + instructions[0]?.instruction || '';
    }

    // Build expression tree from linear instructions
    const stack = [];
    
    for (const instr of instructions) {
      const parts = instr.instruction.split(/\s+/);
      const opcode = parts[0];
      const operands = parts.slice(1);
      
      if (this.isStackProducer(opcode)) {
        // Instructions that produce values
        if (operands.length > 0) {
          stack.push(`(${opcode} ${operands.join(' ')})`);
        } else {
          // This instruction needs operands from the stack
          if (this.getOperandCount(opcode) > 0) {
            const args = [];
            for (let i = 0; i < this.getOperandCount(opcode); i++) {
              if (stack.length > 0) {
                args.unshift(stack.pop());
              }
            }
            stack.push(`(${opcode}${args.length > 0 ? ' ' + args.join(' ') : ''})`);
          } else {
            stack.push(`(${opcode})`);
          }
        }
      } else {
        // Instructions that consume values
        const argCount = this.getOperandCount(opcode);
        const args = [];
        for (let i = 0; i < argCount; i++) {
          if (stack.length > 0) {
            args.unshift(stack.pop());
          }
        }
        
        if (operands.length > 0) {
          stack.push(`(${opcode} ${operands.join(' ')}${args.length > 0 ? ' ' + args.join(' ') : ''})`);
        } else {
          stack.push(`(${opcode}${args.length > 0 ? ' ' + args.join(' ') : ''})`);
        }
      }
    }
    
    // Format the final expression with proper indentation
    if (stack.length === 1) {
      return baseIndent + this.formatExpression(stack[0], baseIndent);
    } else {
      // Multiple expressions - keep them separate
      return stack.map(expr => baseIndent + this.formatExpression(expr, baseIndent)).join('\n');
    }
  }

  formatExpression(expr, baseIndent) {
    // Format complex expressions with proper line breaks and indentation
    if (expr.length < 80 && !expr.includes('(call ') && !expr.includes('(struct.')) {
      return expr; // Keep simple expressions on one line
    }
    
    // Break complex expressions across lines
    let formatted = expr;
    let depth = 0;
    let result = '';
    let i = 0;
    
    while (i < formatted.length) {
      const char = formatted[i];
      
      if (char === '(') {
        if (depth > 0 && i > 0) {
          result += '\n' + baseIndent + '  '.repeat(depth);
        }
        result += char;
        depth++;
      } else if (char === ')') {
        result += char;
        depth--;
      } else {
        result += char;
      }
      i++;
    }
    
    return result;
  }

  isStackProducer(opcode) {
    const producers = [
      'local.get', 'global.get', 'i32.const', 'i64.const', 'f32.const', 'f64.const',
      'struct.get', 'array.get', 'ref.null', 'call'
    ];
    return producers.includes(opcode);
  }

  getOperandCount(opcode) {
    const operandCounts = {
      'local.set': 1, 'local.tee': 1, 'global.set': 1,
      'i32.add': 2, 'i32.sub': 2, 'i32.mul': 2, 'i32.div_s': 2, 'i32.div_u': 2,
      'i32.eq': 2, 'i32.ne': 2, 'i32.lt_s': 2, 'i32.gt_s': 2, 'i32.le_s': 2, 'i32.ge_s': 2,
      'struct.set': 2, 'array.set': 3, 'struct.new': 0, 'array.new': 2,
      'ref.eq': 2, 'ref.as_non_null': 1,
      'call': 0, // Variable based on function signature
      'call_indirect': 0 // Variable based on function signature
    };
    return operandCounts[opcode] || 0;
  }

  fold(input) {
    try {
      // Step 1: Convert structured control flow (if/else/end, loop/end, block/end) to folded syntax
      const structuralFolded = this.foldStructuredInstructions(input);
      
      // Step 2: Handle linear instruction sequences  
      const linearFolded = this.parseLinearInstructions(structuralFolded);
      
      // Step 3: Handle function calls and other complex expressions
      const lines = linearFolded.split('\n');
      const result = [];
      
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        // Look for function call patterns that can be folded
        if (this.isFunctionCallPattern(lines, i)) {
          const folded = this.foldFunctionCall(lines, i);
          result.push(folded.expression);
          i += folded.linesConsumed - 1;
        } else {
          result.push(line);
        }
      }
      
      return result.join('\n');
      
    } catch (error) {
      console.error('Error during folding:', error.message);
      return input; // Return original on error
    }
  }

  foldStructuredInstructions(input) {
    const lines = input.split('\n');
    const result = [];
    let i = 0;
    
    while (i < lines.length) {
      const line = lines[i];
      const trimmed = line.trim();
      const baseIndent = line.match(/^(\s*)/)[1];
      
      // Debug: log what we're examining
      if (this.debugMode) {
        console.log(`Line ${i}: "${trimmed}"`);
      }
      
      // Handle structured control flow - be more flexible with whitespace and patterns
      if (this.isIfStart(trimmed)) {
        const ifBlock = this.foldIfBlock(lines, i);
        result.push(baseIndent + ifBlock.folded);
        i += ifBlock.linesConsumed;
      } else if (this.isLoopStart(trimmed)) {
        const loopBlock = this.foldLoopBlock(lines, i);
        result.push(baseIndent + loopBlock.folded);
        i += loopBlock.linesConsumed;
      } else if (this.isBlockStart(trimmed)) {
        const blockBlock = this.foldBlockBlock(lines, i);
        result.push(baseIndent + blockBlock.folded);
        i += blockBlock.linesConsumed;
      } else {
        result.push(line);
        i++;
      }
    }
    
    return result.join('\n');
  }

  isIfStart(trimmed) {
    // Match: if, if $label, if (result i32), etc., but not (if ...)
    return /^if(\s|$)/.test(trimmed) && !trimmed.startsWith('(if');
  }

  isLoopStart(trimmed) {
    // Match: loop, loop $label, loop (result i32), etc., but not (loop ...)
    return /^loop(\s|$)/.test(trimmed) && !trimmed.startsWith('(loop');
  }

  isBlockStart(trimmed) {
    // Match: block, block $label, block (result i32), etc., but not (block ...)
    return /^block(\s|$)/.test(trimmed) && !trimmed.startsWith('(block');
  }

  foldIfBlock(lines, startIndex) {
    let i = startIndex;
    const ifLine = lines[i].trim();
    const baseIndent = lines[i].match(/^(\s*)/)[1];
    
    // Extract everything after 'if' - could be condition or type signature
    const afterIf = ifLine.substring(2).trim(); // Remove 'if'
    
    i++; // Move past the 'if' line
    
    const thenBody = [];
    const elseBody = [];
    let inElse = false;
    let nestLevel = 0;
    
    // Collect the body until we hit 'else' or 'end'
    while (i < lines.length) {
      const line = lines[i];
      const trimmed = line.trim();
      
      // Track nesting level for nested control structures
      if (this.isIfStart(trimmed) || this.isLoopStart(trimmed) || this.isBlockStart(trimmed)) {
        nestLevel++;
      } else if (trimmed === 'end') {
        if (nestLevel === 0) {
          // This is our closing 'end'
          break;
        } else {
          nestLevel--;
        }
      } else if (trimmed === 'else' && nestLevel === 0) {
        inElse = true;
        i++;
        continue;
      }
      
      if (inElse) {
        elseBody.push(line);
      } else {
        thenBody.push(line);
      }
      i++;
    }
    
    // Build the folded if expression
    let folded = '(if';
    if (afterIf) {
      folded += ` ${afterIf}`;
    }
    
    // Add then clause if there's a body
    if (thenBody.length > 0) {
      folded += '\n' + baseIndent + '  (then';
      for (const bodyLine of thenBody) {
        folded += '\n' + baseIndent + '    ' + bodyLine.trim();
      }
      folded += '\n' + baseIndent + '  )';
    }
    
    // Add else clause if present
    if (elseBody.length > 0) {
      folded += '\n' + baseIndent + '  (else';
      for (const bodyLine of elseBody) {
        folded += '\n' + baseIndent + '    ' + bodyLine.trim();
      }
      folded += '\n' + baseIndent + '  )';
    }
    
    folded += '\n' + baseIndent + ')';
    
    return {
      folded: folded.substring(baseIndent.length), // Remove base indent since it will be added back
      linesConsumed: i - startIndex + 1 // +1 to include the 'end' line
    };
  }

  foldLoopBlock(lines, startIndex) {
    let i = startIndex;
    const loopLine = lines[i].trim();
    const baseIndent = lines[i].match(/^(\s*)/)[1];
    
    // Extract loop label if present
    const labelMatch = loopLine.match(/^loop\s+(.*)$/);
    const label = labelMatch ? labelMatch[1] : '';
    
    i++; // Move past the 'loop' line
    
    const body = [];
    let nestLevel = 0;
    
    // Collect the body until we hit 'end'
    while (i < lines.length) {
      const line = lines[i];
      const trimmed = line.trim();
      
      // Track nesting level
      if (trimmed.startsWith('if ') || trimmed.startsWith('loop ') || trimmed.startsWith('block ')) {
        nestLevel++;
      } else if (trimmed === 'end') {
        if (nestLevel === 0) {
          break;
        } else {
          nestLevel--;
        }
      }
      
      body.push(line);
      i++;
    }
    
    // Build the folded loop expression
    let folded = '(loop';
    if (label) {
      folded += ` ${label}`;
    }
    
    if (body.length > 0) {
      for (const bodyLine of body) {
        folded += '\n' + baseIndent + '  ' + bodyLine.trim();
      }
    }
    
    folded += '\n' + baseIndent + ')';
    
    return {
      folded: folded.substring(baseIndent.length),
      linesConsumed: i - startIndex + 1
    };
  }

  foldBlockBlock(lines, startIndex) {
    let i = startIndex;
    const blockLine = lines[i].trim();
    const baseIndent = lines[i].match(/^(\s*)/)[1];
    
    // Extract block label/type if present
    const labelMatch = blockLine.match(/^block\s+(.*)$/);
    const label = labelMatch ? labelMatch[1] : '';
    
    i++; // Move past the 'block' line
    
    const body = [];
    let nestLevel = 0;
    
    // Collect the body until we hit 'end'
    while (i < lines.length) {
      const line = lines[i];
      const trimmed = line.trim();
      
      // Track nesting level
      if (trimmed.startsWith('if ') || trimmed.startsWith('loop ') || trimmed.startsWith('block ')) {
        nestLevel++;
      } else if (trimmed === 'end') {
        if (nestLevel === 0) {
          break;
        } else {
          nestLevel--;
        }
      }
      
      body.push(line);
      i++;
    }
    
    // Build the folded block expression
    let folded = '(block';
    if (label) {
      folded += ` ${label}`;
    }
    
    if (body.length > 0) {
      for (const bodyLine of body) {
        folded += '\n' + baseIndent + '  ' + bodyLine.trim();
      }
    }
    
    folded += '\n' + baseIndent + ')';
    
    return {
      folded: folded.substring(baseIndent.length),
      linesConsumed: i - startIndex + 1
    };
  }

  isFunctionCallPattern(lines, index) {
    // Look for patterns like:
    // local.get $receiver
    // call $getClass
    // local.get $selector  
    // call $lookupMethod
    // call_indirect
    
    for (let i = index; i < Math.min(index + 5, lines.length); i++) {
      const line = lines[i].trim();
      if (line.startsWith('call ') || line.startsWith('call_indirect')) {
        return true;
      }
    }
    return false;
  }

  foldFunctionCall(lines, startIndex) {
    const sequence = [];
    let i = startIndex;
    
    // Collect the sequence until we hit the function call
    while (i < lines.length) {
      const line = lines[i].trim();
      if (!line || line.startsWith(';;')) {
        i++;
        continue;
      }
      
      sequence.push({
        instruction: line,
        indent: lines[i].match(/^(\s*)/)[1]
      });
      
      if (line.startsWith('call ') || line.startsWith('call_indirect')) {
        break;
      }
      i++;
    }
    
    if (sequence.length <= 1) {
      return { expression: lines[startIndex], linesConsumed: 1 };
    }
    
    // Build folded expression
    const baseIndent = sequence[0].indent;
    const folded = this.foldInstructionSequence(sequence, baseIndent);
    
    return {
      expression: folded,
      linesConsumed: i - startIndex + 1
    };
  }
}

// Main execution
try {
  const input = fs.readFileSync(inputPath, 'utf8');
  const folder = new WATFolder();
  
  // Enable debug mode if --debug flag is passed
  if (process.argv.includes('--debug')) {
    folder.debugMode = true;
    console.log('🐛 Debug mode enabled');
  }
  
  const folded = folder.fold(input);
  
  fs.writeFileSync(outputPath, folded);
  console.log(`✅ Successfully converted ${inputPath} to folded syntax`);
  console.log(`📄 Output written to: ${outputPath}`);
  console.log(`🎯 Folded syntax should make function signature errors more visible with proper indentation`);
  
  // Quick check for remaining 'end' keywords
  const endCount = (folded.match(/\bend\b/g) || []).length;
  if (endCount > 0) {
    console.log(`⚠️ Warning: ${endCount} 'end' keywords still remain - may need manual folding`);
    if (folder.debugMode) {
      console.log('🐛 Remaining end keywords found - check debug output above');
    }
  }
  
} catch (error) {
  console.error('❌ Error:', error.message);
  process.exit(1);
}