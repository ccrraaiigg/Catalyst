# AGENT.md

# AGENT INSTRUCTIONS

## Cursor Workflow: Never Fake Anything. Otherwise, Proceed Without Asking, Always Rebuild After Code Changes.

Never fake anything. If you find yourself in a situation where there
is information missing, DO NOT guess, "mock", or simulate (e.g., DO
NOT create Smalltalk method contexts. Only the real VM can do that.)
Instead, STOP and ask the user for clarification. Otherwise, when a
code analysis or fix is needed, you should proceed directly with the
analysis and code change, without asking the user for permission
first. Cursor will always offer the user a chance to accept or reject
changes before they are committed. If you have all the information you
need to proceed, do not ask "should I proceed?"... just do the work.

When you've changed code, always rebuild.

## Testing

After a rebuild, the user will test, via test.html in a web
browser. At the moment, the tests require human interaction; there's
no need for you to test yet.

## Using Python

There are no tasks the user wants you to do that require Python.

## Using JavaScript

If the resultant clause of an if statement is one line, don't put in
curly braces.

## WASM Tools

The only WASM tools you may use are 'wasm-tools' and 'wasm-opt'. You
may not use wat2wasm or any other WASM tools.

## WASM Types

The common supertype of Smalltalk objects here is eqref. We never use
externref in this project.  If you're going to analyze a WASM module,
do it precisely, with wasm-tools (parse, validate, dump).

## Stack-Oriented Analysis Checklist

When asked (and ONLY when asked) to analyze WASM stack usage or
redundant stack patterns (e.g., `local.tee` followed by `local.get`),
always:

1. **Grep all `local.tee $var` in the file.**
2. **For each, extract the snippet up to the next `local.get $var`.**
3. **Simulate the stack for the snippet.**
4. **If the value from `local.tee` is still on the stack at `local.get`, flag as unbalanced.**
5. **Aggregate and report all results at once.**

## Rationale
- Treat the user's algorithm as a strict checklist.
- Automate the process for every variable, not just common ones.
- Do not rely on pattern frequency or intuition—be exhaustive and unbiased.
- Show the checklist, snippets, and reasoning in the report.
- If a user points out a missed case, re-run the algorithm for all items.

**This section should be referenced for all future stack or pattern
analysis tasks in this workspace.**

---

