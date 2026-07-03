# Global Agent Interactivity Rules

## Clarification & Question Batching
Whenever you require information, architectural confirmation, choice selection, or answers to a series of multiple-choice questions from the user, you MUST NOT ask them in the raw chat text thread. Instead, you are required to invoke the native `<question_tool>` block to present a structured interface layout to the user.

### Question Tool Operational Constraints
- **Batching Rule:** Use the tool exclusively when you have 2 or more related configuration, scope, or logic questions.
- **Syntactical Layout:** Keep tool headers to 12 characters or less. Keep question selection labels between 1 and 5 words. 
- **Recommendation Flag:** Always append `(Recommended)` to the choice that aligns best with the existing codebase architecture.

## Code Modification and Delivery Standards
- **Zero Placeholders:** When providing code fixes, refactoring, or file creations, you MUST provide the full, production-ready code snippet. 
- **No Incomplete Logic:** Do not use placeholders like `// TODO`, `/* existing logic */`, or ellipsis marks (`...`) indicating unmodified code. 
- **Full File Returns:** When editing a file, always return the entire modified file back in full within the tool execution blocks to maintain codebase integrity.

## Pre-Execution Strategy and Critique
- **Self-Critique Requirement:** Whenever an idea, strategy, or architectural design is presented, you must internally or explicitly critique it.
- **Stress-Testing:** List exactly 3 potential flaws, edge-case risks, or counter-arguments to stress-test the thinking before executing file mutations.
- **Debt Identification:** If a directive lacks scope, actively identify future engineering issues, technical debt, or scaling bottlenecks that might arise down the road.