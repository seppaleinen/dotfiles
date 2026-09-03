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

## Cost & Failure Controls

### Rework Budget
- Every agent dispatch tracks a rework count. Maximum **2 reworks** per task before escalating to the user.
- If a task has been re-dispatched more than 2 times with `[REWORK]`, halt and present the error history to the user. Do NOT re-dispatch a 3rd time.

### Dispatch Depth Limit
- Maximum dispatch depth is **3 layers** from `team-lead` (matches `opencode.json` `subagent_depth: 3`). This accommodates the full worker pipeline: `team-lead → dev-team-lead → dev-architect → backend-engineer`.
- `researcher` is a `mode: primary` intake agent; `researcher → web-scout` is depth 1 under a primary and does not count against the team-lead dispatch budget.
- **If a `task()` dispatch fails or errors out** (e.g., depth limit hit, agent unavailable), do NOT silently retry or drop the task. Surface the failure in your response with the step that failed and the error, so the caller can see where the pipeline stalled.
- If a pipeline would require deeper nesting, flatten the chain or escalate.

### Progress Reporting (Visibility)
- Subagents that run multi-step pipelines MUST surface their current step to the caller. When you dispatch a subagent and it will take multiple minutes, do NOT just block silently.
- Prefer dispatching long-running pipeline leads in the **background** (`background: true`) where supported, then poll for completion and report intermediate status to the user as steps complete.
- Before dispatching a pipeline lead, tell the user **which pipeline** is running and **what it will do** (e.g., "Dev pipeline: architect → implement → test → review"). This gives the user a mental model of what's happening while they wait.
- Every pipeline lead MUST include a STATUS marker in its final handover indicating where it got to: `[SUCCESS]`, `[REWORK]`, `[BLOCK]`, or `[STUCK]` (see handover skill).

### Circuit Breaker
- If any agent returns `[BLOCK]`, stop immediately. Do NOT attempt to work around it or re-dispatch to a different agent.
- Surface the block to the user with full context.

### Model Selection for Workers
- Narrow, well-defined worker agents (backend-engineer, frontend-engineer, test-engineer, code-reviewer, devops-engineer, devops-verificator) should use `small_model` when the task is scoped and the contract is clear.
- Use the primary model for orchestrators, architects, and tasks requiring broad reasoning.

### Agent Model Tier Reference

| Tier | Agents | Use |
|------|--------|-----|
| **Reasoning** (main_model) | team-lead, dev-team-lead, devops-team-lead, dev-architect, devops-architect, researcher, ai-security-auditor | Orchestration, architecture, complex decisions |
| **Balanced** (main_model) | web-scout, dev-cleanup, performance-auditor, context-drift-auditor, seo-aeo-auditor, docs | Research, analysis, documentation |
| **Code-specialized** (small_model) | backend-engineer, frontend-engineer, devops-engineer | Implementation with clear specs |
| **Mechanical** (small_model) | test-engineer, code-reviewer, test-auditor, devops-verificator | Checklists, verification, routine checks |