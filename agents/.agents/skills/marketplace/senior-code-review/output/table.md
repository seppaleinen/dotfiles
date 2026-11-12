---
name: table
description: >-
  Compact table-based code review output. Findings as tables — readable when
  pasted into MR review threads. Shared sections come from general-output.md.
---

# Output format: table

Findings behaviour and section contract: [`general-output.md`](general-output.md). Citation tags: [`finding-citations.md`](finding-citations.md). Layout only below.

## Template (findings only)

Insert between `### Verdict` and `### Transparency` in `general-output.md`.

```
### Requires Human Review

| Trigger | Location | Why |
|---|---|---|
| trigger name | `file:line` | Brief description of what matched and why the trigger applies |

_These items require a human reviewer regardless of agent findings. Gates are policy-based, not quality judgements._

### Blocking

| Location | Issue | Why | Fix | Via |
|---|---|---|---|---|
| `file:line` | Short headline | Why it matters or what can go wrong | Concrete suggested change | \<one tag per finding-citations.md\> |

### Suggestions

| Location | Issue | Why | Fix | Via |
|---|---|---|---|---|
| `file:line` | Short headline | Readability, simpler design, better fit, or incremental improvement | Concrete change — for alternatives, name option and trade-off | \<one tag per finding-citations.md\> |

### Nits

| Location | What | Via |
|---|---|---|
| `file:line` | What | \<one tag per finding-citations.md\> |

### Praise

| Location | What |
|---|---|
| `file:line` | What it does well and why |
```
