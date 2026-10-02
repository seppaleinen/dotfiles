---
name: pipeline-visibility
description: Status-reporting contract for pipeline leads. Announce before every dispatch, report after every return, surface every STUCK/REWORK/BLOCK/empty result with a reason.
---

# Pipeline Visibility

## Purpose
The supported visibility channel is the **status-reporting contract you post in the main conversation** — not the UI's child-session display. Dispatched agents do run as child sessions, and `ctrl+x+down` (`session_child_first`) / `ctrl+x+up` (`session_parent`) MAY let you or the user inspect a child session best-effort, but live child-session visibility is unreliable on this stack (opencode 1.18.30 + herdr) and must NOT be treated as a guarantee.

## Contract

### Announce before EVERY dispatch
One line naming the agent and which pipeline it runs.
Example: `Dispatching dev-team-lead. Pipeline: architect → backend-engineer → test-engineer → code-reviewer`
Example: `Dispatching researcher. Pipeline: investigate → Research Brief`

### Report after EVERY return
Which agent/stage came back, its STATUS, and a brief outcome.
Example: `dev-team-lead → design → implement → test [SUCCESS]`

### Surface every failure
Any `[STUCK]`, `[REWORK]`, `[BLOCK]`, or empty/crashed result MUST be surfaced to the user in the main conversation with the reason. Never silent retries.

### On stalled agents
If a dispatched agent returns empty, errors, or `[STUCK]`:
- Do NOT silently retry in a loop
- Report to the user: which agent stalled, what step it was on, what you'll do next
- Offer: re-dispatch with `task_id` resume, or hand back to the user

## Handover field
Keep the **PIPELINE STAGE** field in your handover as the summary of record — it documents where the pipeline stopped and other tools read it:
- Include a **PIPELINE STAGE** field showing which stages completed and where you stopped:
  ```
  PIPELINE STAGE: design → implement → test → review [COMPLETE]
  ```
  Or on early stop:
  ```
  PIPELINE STAGE: design → implement [STOPPED: test-engineer returned REWORK]
  ```
- In your **SUMMARY**, mention which stage produced the final result.