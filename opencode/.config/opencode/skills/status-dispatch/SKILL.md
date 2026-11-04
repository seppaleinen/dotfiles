---
name: status-dispatch
description: Status dispatch table for handling subagent results. Routes based on STATUS field value.
---

# Status Dispatch

## Purpose

Defines how to handle subagent results based on their STATUS field. This is the routing logic after a subagent returns.

## When to Load

Load when evaluating `subagent()` results. Check the STATUS field to determine next action.

## STATUS Dispatch Table

Once the result passes empty-result validation, check the STATUS field:

| Status | Action |
|--------|--------|
| `[SUCCESS]` | Proceed to next stage (verification, post-verification, or synthesis) |
| `[REWORK]` | Re-dispatch with `sessionID="$LAST_TASK_ID"` and error context appended (max 2 retries) |
| `[BLOCK]` | Present to user with full context, halt further dispatch |
| `[STUCK]` | Report which agent stalled and on what step, offer re-dispatch or hand back |

## Re-dispatch Pattern

For `[REWORK]`:

```javascript
subagent(
  description="<task summary> (rework)",
  prompt="<original prompt> + error context from previous handover",
  agent="<agent name>",
  sessionID="$LAST_TASK_ID"  // Resume the same session
)
```

## Escalation

- Track `REWORK_COUNT: N` in handovers
- After 2 reworks: escalate to user with full error history
- Do NOT dispatch a 3rd time

## Related

- `rework-handling` skill for task_id resume and counters
- `delegation-contract` skill for dispatch rules