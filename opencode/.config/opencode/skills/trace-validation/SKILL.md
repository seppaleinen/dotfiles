---
name: trace-validation
description: Validates TRACE and PIPELINE STAGE field consistency in handovers.
---

# Trace Validation

## Purpose

Ensures handover integrity by validating that every stage in `PIPELINE STAGE` has a matching agent in `TRACE`, and vice versa.

## When to Load

Load when validating a pipeline lead's handover after `subagent()` returns.

## Validation Rules

### Required Fields

Before checking STATUS, validate:
- **STATUS** — must be `[SUCCESS]`, `[REWORK]`, `[BLOCK]`, or `[STUCK]`
- **TRACE** — must be present and non-empty
- **PIPELINE STAGE** — must be present and non-empty

### PIPELINE STAGE Format

```
PIPELINE STAGE: design → plan-audit → implement → verify → adversarial-test → security [COMPLETE]
```

Or on early stop:
```
PIPELINE STAGE: design → implement [STOPPED: test-engineer returned REWORK]
```

### Agent-to-Stage Mapping

| Stage | Agent(s) |
|-------|----------|
| `design` | `dev-architect` (or `devops-architect`) |
| `plan-audit` | `plan-auditor` |
| `implement` | `backend-engineer` / `frontend-engineer` (or `devops-engineer`) |
| `verify` | `test-engineer` / `code-reviewer` (or `devops-verificator`) |
| `adversarial-test` | `adversarial-tester` |
| `security` | `ai-security-auditor` |
| `docs` | `docs` |
| `analysis` | `post-mortem-analyst` |
| `cleanup` | `devops-cleanup` |
| `compaction` | `session-compactor` |

### Validation Logic

1. **If a stage appears in PIPELINE STAGE but its agent is absent from TRACE** → `[BLOCK]`: "handover integrity violation: stage `<stage>` claimed in PIPELINE STAGE but `<agent>` not dispatched in TRACE"

2. **If an agent appears in TRACE but its stage is absent from PIPELINE STAGE** → `[BLOCK]`: "handover integrity violation: `<agent>` dispatched in TRACE but no matching stage in PIPELINE STAGE"

3. **Routing agents are exempt:** `team-lead` and `dev-team-lead` / `devops-team-lead` are routing agents, not pipeline stages.

### FAST_PATH_SKIP Documentation

When a stage is skipped via Fast Path, the handover must include:

```
FAST_PATH_SKIP:
  skip_reason: <why the stage was skipped>
  change_class: <scope of the change>
  evidence_reference: <pointer to design/research that justifies the skip>
```

## TRACE Format

```
TRACE: team-lead → dev-team-lead → dev-architect → backend-engineer → test-engineer → code-reviewer → ai-security-auditor [SUCCESS]
```

Include `→ [BLOCK]` or `→ SKIPPED (Fast Path)` when stopping early.

## Validation Result

If validation passes: Proceed to status dispatch.

If validation fails: Return `[BLOCK]` with the violation details.