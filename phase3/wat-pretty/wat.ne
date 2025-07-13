
@lexer lexer

@{%
const moo = require("moo");
let lexer = moo.compile({
  ws:      { match: /[ \t]+/, lineBreaks: false },
  nl:      { match: /\r?\n/, lineBreaks: true },
  comment: /;;.*?$/,
  block_comment: { match: /\(;[^]*?;\)/, lineBreaks: true },
  lparen:  "(",
  rparen:  ")",
  word:    /[a-zA-Z0-9_\-\.$]+/,
  number:  /[+-]?\d+/,
  string:  /"[^"]*"/,
});
%}

main -> _ expr_list? _ {% ([, exprs]) => exprs || [] %}

expr_list -> expr+ {% id %}

expr+ -> expr expr* {% ([first, rest]) => [first, ...rest] %}

expr -> atom | list

atom -> %word | %number | %string

list -> %lparen _ expr_list? _ %rparen
      {% ([, , exprs]) => exprs ? ['(', ...exprs, ')'] : ['(', ')'] %}

_ -> _ws_item:* {% () => null %}

_ws_item -> %ws | %nl | %comment | %block_comment
