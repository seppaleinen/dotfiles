---
name: post-verification-gate
description: Post-verification validation for cleanup and analysis agents. These agents perform potentially destructive actions (issue closing, branch deletion, session archival) and require pre-acceptance validation.
---

# Post-Verification Gate

## Purpose

After post-verification agents (`devops-cleanup`, `post-mortem-analyst`, `session-compactor`) return, validate their handovers before acceptance. These agents perform potentially destructive actions that require pre-acceptance validation.

## When to Load

Load this skill after `devops-verificator` or `code-reviewer` returns `[SUCCESS]`, before dispatching post-verification agents.

## Gate Checklist

### 1. Parse the handover
Extract the `TRACE` line and `PIPELINE STAGE` field from the agent's handover.

- **If missing:** `[BLOCK]` with "incomplete handover — missing TRACE or PIPELINE STAGE field"

### 2. TRACE present
The handover must contain a `TRACE` line showing the dispatch chain.

- **If missing:** `[BLOCK]`

### 3. PIPELINE STAGE consistency
Verify stages match dispatched agents:

| Stage | Agent |
|-------|-------|
| `cleanup` | `devops-cleanup` |
| `analysis` | `post-mortem-analyst` |
| `compaction` | `session-compactor` |

- `team-lead` is a routing agent, exempt from stage check.

### 4. STATUS validation
Must be `[SUCCESS]` or documented `[REWORK]`/`[BLOCK]`.

- **If missing or invalid:** `[BLOCK]`

### 5. Destructive action verification (devops-cleanup only)
When cleanup is involved, verify:

- Issue was closed only if objectives met
- Branch was deleted only if PR was merged
- No unauthorized deletions occurred

## Gate execution

All checks must pass for handover acceptance. A `[BLOCK]` return prevents destructive actions from being accepted.

## Dispatch pattern

```javascript
subagent(
  description="Post-verification cleanup: <issue number>",
  prompt="Verification result [SUCCESS]; issue <number>, branch <name>, PR status <status>",
  agent="devops-cleanup"
)

subagent(
  description="Post-verification analysis: <issue number>",
  prompt="Verification result [SUCCESS]; session ID; git history summary; agent timeline",
  agent="post-mortem-analyst"
)

subagent(
  description="Compact session: <issue number>",
  prompt="Verification result [SUCCESS]; post-mortem findings; session ID",
  agent="session-compactor"
)
```

## Why These Agents

- **`devops-cleanup`**: Closes working issues and deletes branches. Performs destructive Git operations.
- **`post-mortem-analyst`**: Reviews workflow for errors, dead ends, and improvement opportunities.
- **`session-compactor`**: Archives session data and prepares for fresh start on new tasks.