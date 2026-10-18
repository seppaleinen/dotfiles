---
name: rtk-find-loop-prevention
description: Prevents infinite rtk find loops — after two consecutive filtered/hidden results, switch to Read/Glob tools for directory exploration.
---

# rtk find Loop Prevention

`rtk find` filters and hides results by default. When the filtered output is uninformative, repeating the command produces identical filtered output indefinitely — a loop that wastes cycles without gaining information.

**Rule:** If `rtk find` returns filtered/hidden results **twice in a row**, stop repeating it. Switch to read-based directory exploration using the `Read` or `Glob` tools instead. The `Read`/`Glob` tools do not apply rtk's filter layer and will surface the actual files on disk.

Do not run `rtk find` a third time after two consecutive filtered/hidden results. Break the loop by exploring the directory tree directly.

## Usage

Agents that use `rtk find` should load this skill:

```
skill(name="rtk-find-loop-prevention")
```