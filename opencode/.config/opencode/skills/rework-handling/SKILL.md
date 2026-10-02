---
name: rework-handling
description: Rework contract for pipeline leads: task_id resume on [REWORK], fresh-dispatch fallback, max-2 escalation, immediate halt on [BLOCK]. Includes REWORK_COUNT tracking.
---

# Rework Handling

## Automatic task_id Capture (mandatory, no manual extraction)

After **every** `task()` call — success or failure — extract the `task_id` mechanically and store it as `LAST_TASK_ID`. This is not optional; it is a required step before any re-dispatch.

The `task_id` is always present in the result. It appears in one of two forms — scan for both:

| Result form | Pattern to extract |
|---|---|
| Success / running / completed | `<task id="ses_xxx" state="...">` → capture `ses_xxx` |
| Failure (error thrown) | Error message contains `task_id: ses_xxx` → capture `ses_xxx` |

**Rule:** If neither pattern is found, the dispatch did not produce a session — treat as `[STUCK]` and report. Do NOT guess or fabricate a `task_id`.

**On re-dispatch:** always pass `task_id="$LAST_TASK_ID"` in the new `task()` call. The tool will reuse the existing session if it is still alive, or fall back to a fresh session if it has been aborted — either way, no manual lookup is needed.

## On [REWORK]
If a dispatched pipeline lead returns `[REWORK]`, prefer **`task_id` resume**: use the previous `task_id` to continue the same session with the error context appended. This preserves the subagent's working memory and avoids the empty-result problem.

If the session has been aborted (`task_id` no longer valid), fall back to fresh dispatch with the error context appended.

`[REWORK]` means **resume at the failed stage**, not re-run the pipeline from intake/design. Pass the error context verbatim with the resume.

## Rework Counter (Enforceable)
Add a `REWORK_COUNT: N` field to your handover output. Increment it on every `[REWORK]` for the same task. Once it reaches **2**, escalate to the user with the full error history instead of re-dispatching — do NOT dispatch a 3rd time.

Start each lead's rework section with a note that the counter is incremented on every [REWORK] and escalated to the user with full error history once it reaches 2.

## On [BLOCK]
If it returns `[BLOCK]`, halt immediately and present the issue to the user with full context. Do not route around it.

## On [STUCK]
If a dispatched agent returns empty, errors, or `[STUCK]`:
- Do NOT silently retry in a loop
- Report to the user: which agent stalled, what step it was on, what you'll do next
- Offer: re-dispatch with `task_id` resume, or hand back to the user