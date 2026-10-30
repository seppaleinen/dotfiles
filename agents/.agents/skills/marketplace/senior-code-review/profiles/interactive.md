# Interactive profile (default)

In-chat review with human checkpoints. **Default** unless a future automated profile is selected explicitly.

## When this profile applies

- Normal user requests ("review this PR", "code review", …)
- No explicit `automated` / `delivery=gitlab` request

## Settings

| Setting | Value |
|---|---|
| `human_checkpoints` | `true` |
| `delivery` | `chat` |

At each checkpoint in `SKILL.md`:

1. Read the matching module in `checkpoints/` — artifact contract and how to handle input.
2. Read the matching subsection below — how to ask and where input comes from.
3. Apply the **checkpoint protocol**.

## Checkpoint protocol

**Ask:**

- Do **not** use `AskQuestion`.
- Print the full artifact or prompt from the gathering subsection — never a label, stub, or "same content will appear later" placeholder.
- End your turn. Do not continue the workflow until the user replies.

**Source:** user's chat reply (unless the gathering subsection says otherwise).

## Gathering checkpoints

### Output format

Build the choice list per [`checkpoints/output-format.md`](../checkpoints/output-format.md). Present:

> **Output format** — which do you want?
> - **default** — <description from output/default.md frontmatter>
> - **table** — <description from output/table.md frontmatter>

Wait for an explicit pick unless the checkpoint module says to skip confirmation.

### Intent

Present a full `## Intent` block per artifact structure in [`checkpoints/intent.md`](../checkpoints/intent.md).

End with: *Is this intent enough to review against? Confirm to proceed, or add goals and acceptance criteria.*

### Change brief

Present a full `## Change brief` block per artifact structure in [`checkpoints/change-brief.md`](../checkpoints/change-brief.md).

Footer (italic): *This summary will also appear as `### Change brief` in the final review. Discuss now, or add comments at the human-input checkpoint.*

End with: *Is this brief enough to proceed? Confirm, adjust focus, or share observations.*

### Human review input

Present:

> **Your input** — did you review this change, or do you have context to merge into the final review?  
> Share review comments, intentional trade-offs, or disputes with draft findings — or reply **nothing to add**.

## Delivery

Print the full artifact in chat. Do not write to disk unless the user explicitly asks (e.g. "save the review", "write to reviews/", "persist this").

**If the user asks to save** — write to the repo under review, then print in chat and add `→ Saved to <relative-path>`. On write failure, warn and still print.

| Scope | Path |
|---|---|
| MR / branch | `reviews/<branch-name>-review.md` (replace `/` with `-`) |
| Whole repo or main | `reviews/<YYYY-MM-DD>-review.md` |
| Name collision | append `-review-1.md`, `-review-2.md`, … |
