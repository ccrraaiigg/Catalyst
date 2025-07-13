
@{%
const moo = require("moo");

const lexer = moo.compile({
  ws:      /[ \t]+/,
  nl:      { match: /[\r\n]+/, lineBreaks: true },
  comment: /;;[^\n\r]*/,
  block_comment: { match: /\(;[^]*?;\)/, lineBreaks: true },
  lparen:  "(",
  rparen:  ")",
  string:  /"(?:\\["\\]|[^\n"\\])*"/,
  number:  /[+-]?(?:0x[\da-fA-F]+|\d+)(?:\.\d+)?/,
  keyword: /[a-zA-Z0-9!#$%&*+./:<=>?@\\^_`|~-]+/,
});

module.exports = { lexer };
%}

@lexer lexer

wat -> _ expr_list _

expr_list -> expr:+ {%
  ([first, rest]) => [first, ...rest]
%}

expr -> atom
     | list

atom -> string
     | number
     | keyword

string -> %string {% d => ({ type: "string", value: d.value }) %}
number -> %number {% d => ({ type: "number", value: d.value }) %}
keyword -> %keyword {% d => ({ type: "keyword", value: d.value }) %}

list -> "(" _ expr_list? _ ")" {% 
  ([, , content]) => content || [] 
%}

_ -> _ws:(_ws_item)* {% () => null %}
_ws_item -> %ws | %nl | %comment | %block_comment
