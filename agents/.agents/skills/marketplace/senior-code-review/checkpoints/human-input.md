# Checkpoint: human review input

Collect human review comments, trade-offs, or disputes with draft findings before assembling the final review.

**Inputs:** draft findings, self-critique outcome.

## What counts as input

- Review comments on the change
- Intentional trade-offs the human wants documented
- Disputes with draft findings

## Handle input

- **Never drop human input silently** — every item the human raised must appear in the final review (findings and/or Transparency). You may disagree: add agent verification, a different opinion, or downgrade severity in commentary alongside their wording. If you reject an item after verification, state why — do not omit it.
- Verify every item against the diff
- Preserve the human's wording; add agent verification or commentary alongside — do not remove or silently rewrite
- Tag merged items `[from reviewer]` per [`output/finding-citations.md`](../output/finding-citations.md)
- Input is context, not veto — do not treat as authoritative override without verification
- **Nothing to add** ("no", "skip", "nothing") → no human review input; proceed
- **Shares input** → merge per the rules above

## Record in Transparency

**Human review input:** what was raised; what was merged; what was rebutted or downgraded (with why) — or `none`. Rebutted items still count as raised; record them here even when not merged into findings.
