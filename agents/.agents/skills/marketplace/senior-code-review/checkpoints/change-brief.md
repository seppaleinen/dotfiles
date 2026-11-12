# Checkpoint: change brief

Curated implementation briefing — the human should **not** need to re-read the whole diff. Dense with judgment; scale length to the change. Every subsection needs substantive content, never placeholders.

**Inputs:** repo context, system characterisation & risk, human sign-off gates.

**Implementation-focused** — what the code **does**, not a PRD rehash. Intent explains **why**; the brief explains **what changed**.

**Include:** behavior, data paths, dependencies, blast radius, test gaps, substantive logic, human review points.

**Skip:** file inventories, boilerplate-only tests, formatting tweaks, generated files, rename-only diffs. Mention paths only to anchor verification.

## Artifact structure

**Lead** — overall shape of the change (opening paragraph before subsections).

### What changed

What the code **actually does** — behavior, data paths, runtime effects. Group large diffs by theme, not directory.

### Why

Tied to confirmed intent only.

### Risk surface

What could go wrong — trust boundaries, blast radius, sensitive surfaces. From the system characterisation and loaded org knowledge.

### Human sign-off

Human sign-off gates that fired, or *none*.

### Where to look

Human-only decisions per [`references/human-accountability.md`](../references/human-accountability.md). Concern-themed; do not duplicate code-quality findings here.

## Handle input

- **Confirms** → lock the brief for final output
- **Adjusts focus or discusses** → merge or investigate; re-present if scope changes materially

Observations raised during discussion: handle per [`checkpoints/human-input.md`](human-input.md). Offer **Continue discussing** or **Proceed with review** after each exchange.

Refine the locked brief later if findings add nuance.

## Invalid (never do this)

- Checkpoint label or "same content will appear in final review" with no brief
- Question only, with no substantive change brief
- Commit message or MR title restated without behavior or risk
- File table with no explanation
