# Checkpoint: output format

Confirm the findings layout before obtaining the diff or starting analysis.

Do **not** obtain the diff, read intent docs, or start the review until output format is confirmed.

## Choose format

List every selectable file in this skill's `output/` folder (`default.md`, `table.md`, …). **Do not** offer `general-output.md` — it is shared layout, not a format choice. Read each selectable file's frontmatter `description`.

## Skip confirmation when

The user already named a format in the same request (e.g. "table format review of my branch").

## After confirmation

- Load the chosen format from `output/` and `output/general-output.md`
- Record the chosen format in the Transparency footer
