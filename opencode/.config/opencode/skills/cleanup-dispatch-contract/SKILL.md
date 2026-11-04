---
name: cleanup-dispatch-contract
description: Cleanup dispatch rules for the devops-cleanup agent. Ensures branch deletion only occurs after proper verification.
---

# Cleanup Dispatch Contract

## Purpose

Orchestrates the cleanup phase after pipeline verification. Ensures branch deletion only occurs after proper verification and explicit user consent.

## When to Load

Load this when dispatching `devops-cleanup`. It documents the landing→deletion dependency explicitly.

## Dispatch Rules

### General cleanup prompt

```
Verification result [SUCCESS]; issue <number>, branch <name>, PR status <status>
```

### The Deletion Dependency

> "Deletion requires all branch content on main. Gate #1 (full branch-vs-main tree equivalence) runs first — any delta or branch-only tracked file ⇒ PENDING/BLOCK with the diff, before issue closing or deletion. Parallel-safe cleanup (issue closing, hygiene) is separate from the deletion path and may proceed independently."

### User Consent Requirements

1. **Branch deletion** requires the PR to be merged, OR explicit user consent for deletion with unmerged branch
2. **Issue closing** requires objectives met (per verification)
3. **If no PR exists** → ask user before deleting the branch

## Dispatch Pattern

```javascript
subagent(
  description="Post-verification cleanup: <issue number>",
  prompt="The verification result from <devops-verificator/code-reviewer>, issue <number>, branch <name>, PR status <status>. See cleanup-dispatch-contract for deletion dependency rules.",
  agent="devops-cleanup"
)
```

## Failure Cases

- `[BLOCK]` if branch has unpushed commits not on main
- `[BLOCK]` if deletion requested but PR not merged and user hasn't consented
- `[SUCCESS]` with details if cleanup completed

## Related

- `post-verification-gate` skill for handover validation
- `session-compactor` for session archival