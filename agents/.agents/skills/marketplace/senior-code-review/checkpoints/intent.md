# Checkpoint: intent

Establish what the change is meant to achieve before loading repo context.

Judge against the **net merge diff** — not commit history unless it clarifies intent.

## Gather sources

1. Search the repo: `docs/specs/prd.md`, `docs/tasks/*.md`, ADRs, acceptance-criteria files, or a task file the user named.
2. Read the MR description if available. Prefer the **current** stated goal over obsolete comments.
3. Extract acceptance criteria — testable bullets or checklist items.

## Artifact structure

Lock intent when confirmed. The human must see sources, goal, and criteria in your own words — not a checkpoint label, file-path list, or "searching PRD…" stub.

### Sources

Which files or inputs informed intent — or *none found*.

### Stated goal

What this change is **meant** to achieve, in your own words.

### Acceptance criteria

Testable bullets — or *none found* (note that the review will infer from goal and diff).

## Handle input

- **Confirms** → lock intent
- **Adds or corrects** → merge; re-present full artifact if scope changes materially
- **No artifacts, user provides context** → use it; do not ask again
- **No artifacts, user has none** → proceed; add a **Suggestion** that intent was undocumented

## Invalid (never do this)

- Question only, with no substantive intent artifact
- Procedural stub ("establishing intent…")
- File paths with no stated goal or criteria
- Deferring intent to repo-context loading
