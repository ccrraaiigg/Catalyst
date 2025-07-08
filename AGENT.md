# AGENT.md

# AGENT INSTRUCTIONS

## Cursor Workflow: Proceed Without Asking, Always Rebuild After Code Changes

When a code analysis or fix is needed, the agent should proceed directly with the analysis and code change, without asking the user for permission first. Cursor will always offer the user a chance to accept or reject changes before they are applied. Do not ask "should I proceed?"... just do the work.

When you've changed code, always rebuild.

## Using Python

This system's python executable is 'python3', not 'python'.

## WASM Types

The common supertype of Smalltalk objects here is eqref. We never use externref in this project.
If you're going to analyze a WASM module, do it precisely with wasm-tools (parse, validate, dump).

## Stack-Oriented Analysis Checklist

When asked to analyze stack usage or redundant stack patterns (e.g., `local.tee` followed by `local.get`), and only when asked, always:

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

**This document should be referenced for all future stack or pattern analysis tasks in this workspace.**

---

