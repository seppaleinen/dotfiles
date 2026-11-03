---
name: handover
description: Standardized inter-agent communication protocol for structured handoffs between pipeline agents. Use when returning results from any subagent dispatch.
---

# THE HANDOVER PROTOCOL

## Purpose
Standardize inter-agent communication. Every agent MUST format its final response using this structure to ensure downstream agents receive enough context — but NOT everything.

## Handover Invariants

These invariants MUST hold before any agent returns `[SUCCESS]`:

- **Working tree clean or commit recorded.** `git status --short` must be empty or all changes must be explicitly listed in the deliverables. If changes exist, a commit SHA must be recorded in the handover's Technical Payload. Untracked files must be listed or removed; modified tracked files must be staged and committed.
- **Lint clean.** The project's lint command (`LINT_CMD` from the loaded language skill, e.g. `pnpm lint` / `eslint .` for TypeScript, `ruff check .` for Python) must pass, or its output must be included in the handover and fixed before proceeding.

## Principle: Pass Signal, Drop Noise
Pass forward only what the next agent needs. Do NOT pass:
- Full conversation history
- Raw tool outputs (logs, kubectl dumps, command traces)
- Internal deliberations or discarded alternatives

Pass forward:
- Status and summary of what was done
- Rationale (why decisions were made)
- Technical payload (diffs, configs, contracts)
- Metadata (branch names, commit SHAs, component names)

## Structure

### 1. STATUS
One of:
- `[SUCCESS]` — Task completed as requested
- `[REWORK]` — Task cannot be completed as specified; include errors and context for the fix
- `[BLOCK]` — Critical issue requiring human intervention; include full context
- `[STUCK]` — Task could not be progressed; the agent hit a dispatch failure, empty result, or unexplained stall at a known step. Include WHICH step failed, WHICH agent/dispatch failed, and any error. This is distinct from `[REWORK]` (which needs a content fix) and `[BLOCK]` (which needs a human decision) — `[STUCK]` means the machinery itself failed and the caller should decide whether to re-dispatch, escalate, or hand back to the user.

### 1a. REWORK ACCOUNTING
Include in the STATUS block (or as a separate line immediately after):
```
REWORK_COUNT: N | KILLED_BY_RESTART: M
```
- `REWORK_COUNT`: Number of formal `[REWORK]` resumes for this task (per `rework-handling` skill, max 2 before escalation).
- `KILLED_BY_RESTART`: Number of times a subagent was cancelled by an external opencode service restart (per `rework-handling` skill). Independent of REWORK_COUNT.

### 2. SUMMARY

A high-level, one-paragraph description of what was achieved or why it failed. The downstream agent should understand the outcome without reading anything else.

#### TLDR (issue #54)

A brief summary for quick understanding of review outcomes:

```
TLDR: <30-word summary of approval status, key changes, and next action>
```

**Examples:**
- `TLDR: Approved. 3 nit fixes recommended. Ready to merge after addressing comments.`
- `TLDR: REWORK. Missing error handling in 2 functions. Add try/catch before re-review.`
- `TLDR: [BLOCK] Critical security issue found. Hardcoded secret in config.yaml line 42.`

### 3. RATIONALE
The "why" behind decisions, changes, or failures. This is critical for the next agent to understand intent.

### 4. TECHNICAL PAYLOAD
The core deliverable:
- **Specs/Contracts:** API definitions, component boundaries, data models
- **Code/Config:** Actual changes (diffs or full file contents)
- **Logs/Errors:** Only diagnostic output relevant to the outcome
- **Metadata:** Branch names, commit SHAs, component names, namespaces

### 5. TRACE (Mandatory)

A single-line call chain showing the dispatch path for debugging and handover validation:

```
TRACE: team-lead → dev-team-lead → dev-architect → backend-engineer [SUCCESS]
```

**Mandatory validation (issue #50):** Every stage name in `PIPELINE STAGE` must have a matching agent in TRACE, and every agent in TRACE must correspond to a stage. `team-lead` and pipeline leads (`dev-team-lead`/`devops-team-lead`) are routing agents, not stages.

**Required format:** Agents separated by `→`, status at end (e.g., `[SUCCESS]`, `[REWORK]`, `[BLOCK]`). If a stage was skipped or blocked, record it in the trace (e.g., `→ SKIPPED (Fast Path)`, `→ [BLOCK]`).

This field must be present for the handover to be complete.

### 6. FAST_PATH_SKIP (Optional but recommended for Fast Path)

When a stage is skipped via Fast Path, document it with structured fields:

```
FAST_PATH_SKIP:
  skip_reason: <why the stage was skipped>
  change_class: <scope of the change>
  evidence_reference: <pointer to design/research that justifies the skip>
```

**Example:**
```
FAST_PATH_SKIP:
  skip_reason: Single manifest update, design covered in Infra Findings
  change_class: config tweak — Helm value change only
  evidence_reference: Research Brief Infra Findings section 3.2
```

This documentation is critical for handover integrity validation and post-mortem analysis.

### 7. IMPORTANT NOTES (Optional)
Anything the next agent MUST know that doesn't fit above. Keep it brief.
