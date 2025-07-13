
import fs from 'fs';
import { Parser } from 'nearley';
import grammar from './wat.cjs';

function formatExpr(expr, indent = 0) {
  if (typeof expr === 'string') return expr;
  if (!Array.isArray(expr)) return expr.value;
  const indentStr = '  '.repeat(indent);
  const inner = expr.map(e => formatExpr(e, indent + 1)).join(' ');
  return `\n${indentStr}(${inner})`;
}

function main(filename) {
  const input = fs.readFileSync(filename, 'utf-8');
  const parser = new Parser(grammar);
  parser.feed(input);
  const [ast] = parser.results;
  const out = ast.map(e => formatExpr(e)).join('\n');
  console.log(out);
}

main(process.argv[2]);
