#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

if (process.argv.length < 3) {
  console.error('Usage: node annotate-wat-ends.js <input.wat> [output.wat]');
  process.exit(1);
}

const inputPath = process.argv[2];
const outputPath = process.argv[3] || inputPath.replace(/\.wat$/, '.annotated.wat');

const lines = fs.readFileSync(inputPath, 'utf8').split(/\r?\n/);

// Stack to track block openings
const blockStack = [];
const annotated = [];

for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  const trimmedLine = line.trim();
  
  // Check for block openers - handle WAT syntax with parentheses
  if (/^\s*\(module\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(rec\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(type\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(struct\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(func\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(if\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(else\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(loop\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*\(block\b/.test(line)) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*if\b/.test(line) && !trimmedLine.startsWith('(')) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*else\b/.test(line) && !trimmedLine.startsWith('(')) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*loop\b/.test(line) && !trimmedLine.startsWith('(')) {
    blockStack.push({ line: trimmedLine, index: i });
  } else if (/^\s*block\b/.test(line) && !trimmedLine.startsWith('(')) {
    blockStack.push({ line: trimmedLine, index: i });
  }
  
  // Check for 'end' or function closing ')'
  if (/^\s*end\b/.test(line)) {
    // Only annotate if there is no comment already
    if (!/;/.test(line)) {
      let comment = '';
      if (blockStack.length > 0) {
        const opener = blockStack.pop();
        // Clean up the line for the comment (remove comments, trim)
        const cleanLine = opener.line.replace(/;.*/, '').trim();
        comment = ` ;; ${cleanLine}`;
      }
      annotated.push(line + comment);
    } else {
      annotated.push(line);
    }
  } else if (/^\s*\)\s*$/.test(line) && blockStack.length > 0) {
    // Only annotate if there is no comment already
    if (!/;/.test(line)) {
      let comment = '';
      const opener = blockStack.pop();
      const cleanLine = opener.line.replace(/;.*/, '').trim();
      comment = ` ;; ${cleanLine}`;
      annotated.push(line + comment);
    } else {
      annotated.push(line);
    }
  } else {
    annotated.push(line);
  }
}

fs.writeFileSync(outputPath, annotated.join('\n'), 'utf8');
console.log(`Annotated WAT written to ${outputPath}`); 