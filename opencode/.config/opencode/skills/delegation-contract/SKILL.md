---
name: delegation-contract
description: Delegation rules for pipeline leads: subagent()-only dispatch, subagent_depth=2 cap, pass Research Brief + constraint summary + expected output format, never pass conversation history or raw tool output.
---

# Delegation Contract

## Mechanism
All coordination is via the `subagent()` tool (synchronous — the caller blocks until the subagent returns). Never delegate by spawning separate agents (paseo `create_agent`/`send_agent_prompt`, herdr tab-spawns, or manual Tab-switching between primary agents).

## Depth Cap
Max **2 layers** from `team-lead` (`subagent_depth: 2` in `opencode.json`). Deepest chains are `team-lead → dev-team-lead → worker` and `team-lead → researcher → web-scout`. Do NOT change `subagent_depth` in opencode.json. Keep pipelines within this budget; flatten deeper chains or escalate.

## What to Pass
- The Research Brief file path
- A summary of the key constraints from the brief
- The expected output format

## What NOT to Pass
- Full conversation history
- Raw tool output from prior exploration
- Internal routing logic

## Dispatch Prompt Contract (issue #8)

A dispatch prompt states **WHAT** must be produced and **WHAT CONSTRAINTS** apply. It does **NOT** dictate **HOW** the lead stages the work.

**Never pass an implementation blueprint.** An implementation blueprint includes any of:

- Exact file layout or directory structure to create
- Exact schema definitions (e.g. `values.yaml` field-for-field)
- Exact test commands or verification procedures
- Exact values, counts, or configuration literals
- A step-by-step "do this, then that" work plan

**Pass instead:** the Research Brief + constraint summary + expected output format. The lead decides which pipeline stages to run, in what order, and which agents to dispatch. The caller's job is to specify the destination and the guardrails — not the route.

**Why:** A dispatch prompt that is an implementation spec overrides the lead's "do not implement, coordinate" role. The lead then implements inline (zero `subagent()` calls), the pipeline trace collapses to a single stage, and no gate can recover the missing stages. The dispatch prompt is the first and best defense against trace collapse.

## Context Discipline
Each dispatch gets a fresh `subagent` call. Do NOT chain dispatches in a single call. Wait for the result, evaluate it, then dispatch the next step if needed.

## Work-Tree Audit at Lead Dispatch Start (issue #35)

Before a pipeline lead dispatches any worker, the lead itself inspects the working tree. This is **lead-local** (not a dispatched skill) and runs in **Step 1.5** of both pipelines:

- `dev-team-lead.md` → `## Step 1.5: Work-Tree Audit`
- `devops-team-lead.md` → `## Step 1.5: Work-Tree Audit`

The audit runs `git status --short`, matches changed/added files against the task's expected deliverables (from the Research Brief / tracking issue), and emits `WORK_PRESENT` or `WORK_ABSENT`. On `WORK_PRESENT` the lead skips Design + Implement and proceeds directly to verification stages, avoiding re-implementation of work already in the tree.

**Contract notes:**

- The audit is **read-only** — it precedes `## Consent Check` and requires no approval.
- It **does not block** on unrelated dirty files (local notes, scratch files, other issues' work); only deliverable paths from *this* brief are matched.
- Overhead when work is absent: a single `git status --short` call.
- The signal appears in the lead's handover `PIPELINE STAGE` field (e.g. `audit:WORK_PRESENT → verify → ...`).
- This skill documents the flow; the authoritative procedure lives in the two lead agent `.md` files. If the audit procedure changes, update those files and this cross-reference together.

## Handover Validation
Before accepting a subagent result, mechanically validate that the handover contains all required fields:
- **STATUS** — must be `[SUCCESS]`, `[REWORK]`, `[BLOCK]`, or `[STUCK]`
- **SUMMARY** — plain-language summary of the outcome
- **RATIONALE** — decisions made and why
- **TECHNICAL PAYLOAD** — files changed, test results, or output artifacts
- **TRACE** — full dispatch chain showing the full pipeline path
- **PIPELINE STAGE** — which stages completed and where the pipeline stopped (per `pipeline-visibility`)

Reject incomplete handovers immediately. Do not propagate partial results. If STATUS is missing or fields are empty, request a complete handover before proceeding to verification or synthesis.

### Empty-Result Detection (issue #36)

An empty, aborted, or transport-corrupted `subagent()` result is **not** a valid handover — it must never be silently accepted as a completed stage. Before checking the STATUS field, validate the result is non-empty and structurally complete:

1. **Non-empty check.** The result body must contain at least one non-whitespace character. An empty string, a bare error envelope with no content, or a result that contains only a session-ID wrapper with no handover body is **EMPTY**.
2. **Field-presence check.** The result must contain the required handover fields — **STATUS**, **TRACE**, and **PIPELINE STAGE** — before any STATUS value is read. A result that contains a STATUS field but is missing TRACE or PIPELINE STAGE is **INCOMPLETE**, not empty, and is handled by the incomplete-handover rule above.
3. **Log every empty result.** Record the empty result with:
   - `sessionID` (the `ses_xxx` from the dispatch result envelope)
   - The raw error or transport message (e.g. `"Timed out waiting for response data"`, `aborted`)
   - A UTC timestamp
   This log entry is the post-mortem's primary trace for empty-result events. Surface it in the handover's TECHNICAL PAYLOAD.

**On EMPTY or ABORTED result — diagnostic-before-retry (issue #21 protocol, extended):**

Do NOT count a retry until the provider/transport diagnostic has been run and passed:

1. Run the diagnostic:
   - DNS: `dig +short litellm.labb.site`
   - HTTP: `curl -sSf https://litellm.labb.site/v1/models > /dev/null` (or `opencode models` to verify the live daemon)
2. **If both pass** → the error was likely transient. Auto-retry once with `sessionID="$LAST_TASK_ID"` (per `rework-handling`). This retry counts toward the max-2 budget.
3. **If either fails** → the backend is unavailable. **Do NOT retry.** Escalate to the user with the diagnostic output instead of burning retries. Return `[STUCK]` with the diagnostic payload.
4. **If the diagnostic itself errors** (e.g. `dig`/`curl` not available, or the command times out) → treat as a failed diagnostic: do NOT retry; escalate to the user with the diagnostic error.

This rule extends — not replaces — the existing provider/transport diagnostic in `team-lead.md` (issue #21), which already covers explicit transport errors. Empty results now trigger the same diagnostic gate before any retry is counted.

## Code Simplicity Audit Stage Cross-Reference

The dev pipeline includes a pipeline-internal simplicity audit stage between Implement and Test:

- **Agent:** `code-simplicity-auditor` (`opencode/.config/opencode/agents/code-simplicity-auditor.md`)
- **Position:** Step 3.5 in `dev-team-lead.md` — after engineers return, before `test-engineer`
- **Permissions:** read-only (`edit: deny, write: deny, question: deny, task: deny, todowrite: deny`)
- **Skills loaded:** `kiss`, `ponytail`, `dry`, `yagni`
- **Scope:** diff-only with contextual window (changed files + direct imports)
- **Severity gate:** Critical findings block progression to test; Warning/Nit are advisory
- **Rework:** tracked via separate `SIMPLICITY_REWORK_COUNT` counter, max-2 + escalation independent of global `REWORK_COUNT`
- **Handover:** findings + suggested patch snippets, never full refactored files, never edits

This stage is pipeline-internal to `dev-team-lead` and is not reflected in the `team-lead.md` Post-Dispatch Gate table.

## Tool Usage Guidance (issue #38)

### Quick Reference

| Task | Correct Tool | Wrong Tool |
|------|--------------|------------|
| Run shell command (git, find, ffmpeg, curl, etc.) | `shell` | `execute` |
| Read file contents | `read` | `execute` |
| Write new file | `write` | `execute` |
| Edit existing file | `edit` | `execute` |
| Pure JS computation / tool orchestration / HTTP fetch | `execute` | `shell` |
| List directory / glob patterns | `glob` | `execute` / `shell` |
| Search file contents | `grep` | `execute` / `shell` |

### Rules

1. **NEVER** use `execute` for:
   - Shell commands (`git`, `find`, `ls`, `curl`, `grep`, `awk`, `sed`, etc.)
   - File I/O (reading, writing, editing files)
   - Process spawning (`require('child_process')`, `process`, Node built-ins)
   - CLI tool invocations

2. **ALWAYS** use `shell` for:
   - Any command you would run in a terminal
   - Git operations
   - File system operations via CLI
   - External program execution

3. **ALWAYS** use dedicated file tools (`read`, `write`, `edit`, `glob`, `grep`) for file operations — they are faster, safer, and provide better error handling.

4. **USE `execute` ONLY for:**
   - Pure JavaScript/TypeScript computation
   - Orchestrating multiple tool calls in sequence
   - HTTP requests via `fetch()`
   - Data transformation that doesn't need shell access
   - JSON/JSONC parsing and manipulation

### Anti-Patterns (what causes failures)

```javascript
// ❌ WRONG: require() doesn't exist in execute sandbox
const { execSync } = require('child_process');
execSync('git status');

// ❌ WRONG: process doesn't exist
process.env.MY_VAR;

// ❌ WRONG: shell command in execute
const result = await shell('find . -name "*.ts"');

// ❌ WRONG: file I/O in execute
const fs = require('fs');
fs.readFileSync('file.txt');
```

### Correct Patterns

```javascript
// ✅ CORRECT: pure JS computation
const data = { a: 1, b: 2 };
return Object.keys(data).map(k => data[k] * 2);

// ✅ CORRECT: tool orchestration
const files = await tools.glob({ pattern: "**/*.ts" });
const results = await Promise.all(
  files.map(f => tools.read({ path: f }))
);

// ✅ CORRECT: HTTP request
const resp = await fetch('https://api.example.com/data');
const json = await resp.json();

// ✅ CORRECT: JSONC parsing
const { parse } = await import('jsonc-parser');
const config = parse(await tools.read({ path: 'config.jsonc' }));
```

### Why This Matters

The `execute` tool runs in a **JS sandbox** — no Node.js built-ins (`require`, `process`, `fs`, `path`, `child_process`), no shell access. Attempting to use them throws runtime errors, wasting 3-5 tool calls before the agent falls back to `shell`. This guidance prevents that cycle.