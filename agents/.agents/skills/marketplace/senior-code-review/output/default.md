---
name: default
description: >-
  Standard code review output. Findings as nested bullet lists. Shared sections
  (Change brief, Verdict, Transparency) come from general-output.md.
---

# Output format: default

Findings behaviour and section contract: [`general-output.md`](general-output.md). Citation tags: [`finding-citations.md`](finding-citations.md). Layout only below.

## Template (findings only)

Insert between `### Verdict` and `### Transparency` in `general-output.md`.

```
### Requires Human Review

- **[trigger name]** — `file:line` — Brief description of what matched and why the trigger applies.

_These items require a human reviewer regardless of agent findings. Gates are policy-based, not quality judgements._

### Blocking

- **`file:line`** — Short headline of the problem.
  - **Why:** Why this matters or what can go wrong.
  - **Fix:** Concrete suggested change.
  - *\<one citation tag per finding-citations.md\>*

### Suggestions

- **`file:line`** — Short headline.
  - **Why:** Why it is worth changing (readability, simpler design, better fit with neighbours, incremental improvement).
  - **Fix:** Concrete suggested change — for design alternatives, name the alternative and trade-off.
  - *\<one citation tag per finding-citations.md\>*

### Nits

- **`file:line`** — What.
  *\<one citation tag per finding-citations.md\>*

### Praise

- **`file:line`** — What it does well and why.
```
