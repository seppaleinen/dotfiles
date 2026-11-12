# Finding citations

Tag findings so readers know what backed them. Used when drafting findings and in the final review artifact.

- **`[ref: <knowledge-name>]`** — loaded per the **knowledge-lookup** skill (e.g. `[ref: ai-first]`).
- **`[ref: <repo-path>]`** — a document from the **repo under review or in workspace** that directly informed the finding (e.g. `[ref: AGENTS.md]`, `[ref: docs/specs/prd.md]`, `[ref: CONTRIBUTING.md]`). Use the path relative to the repo root.
- **`[from reviewer]`** — raised by the human during change-brief discussion or at the human-input checkpoint. Preserve their wording; add agent verification or commentary alongside — do not remove or silently rewrite their comment.
- **`[via model]`** — senior-engineer judgment, characterisation concerns, or domain gaps with no matching installed knowledge or repo doc.
