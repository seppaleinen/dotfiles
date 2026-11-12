---
name: senior-code-review
description: >-
  Reviews code changes like a senior engineer: pauses for output format and
  intent confirmation, loads repo context and assesses risk, presents an
  implementation-focused change brief for human validation, checks the change
  achieved that intent and fits the repo, assesses readability and design
  alternatives (not just defects), applies human review gates when the repo
  defines them, and optionally runs a subagent self-critique pass.
  Use when the user asks to "review this PR", "code review", "review my changes",
  "review this diff", "review this branch", or similar. Also handles static
  (no-diff) reviews when the user points at a file or folder with no comparator.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Task, Write, Shell
compatibility: Requires git and Shell in the reviewed repo. Optional Task subagent runtime (Cursor) for self-critique escalation; optional glab for MR URLs.
---

# Senior Code Review

## Prerequisites

See frontmatter `compatibility`. **Best results:** target repo has `AGENTS.md` and intent docs (PRD, task file, acceptance criteria).

## Artifact vocabulary

Only this file binds step order. Other modules refer to these **names**, not step numbers.

| Artifact | Step |
|---|---|
| output format | 0 |
| diff / scope | 1 |
| intent | 2 |
| repo context | 3 |
| system characterisation & risk assessment | 4 |
| human sign-off gates | 5 |
| change brief | 6 |
| draft findings | 7 |
| self-critique outcome | 8 |
| human review input | 9 |
| final review | 10 |

## Review dimensions

A senior review is not defect-finding alone. Ask: *would I merge this as-is, and what would make it better even when it is not wrong?* Apply **all four** dimensions to every change — diff and snapshot alike. Org policies come from loaded **knowledge** in repo context; cite with `[ref: <knowledge-name>]` when they apply.

| Dimension | Ask yourself | Typical severity |
|---|---|---|
| **Intent** | Does the **net merge diff** meet acceptance criteria? What's missing? | Blocking when wrong or incomplete |
| **Fit** | Does it match repo conventions and reuse what exists? | Blocking when it violates invariants; Suggestion when a neighbour pattern fits better |
| **Craft** | Is it readable? Clear names? Right-sized functions? Obvious control flow? | Suggestion or Nit — rarely Blocking unless unreadability hides a bug |
| **Design** | Is there a simpler or more idiomatic approach? Better abstraction? Worth a follow-up? | Suggestion — phrase as "This works; consider X because …" unless unsafe or clearly wrong |

Use **Suggestions**, **Nits**, and **Praise** for improvements not required for merge.

Tag findings per [`output/finding-citations.md`](output/finding-citations.md).

## Scope & non-goals

Senior-engineer reviewer assist — complements CI lint/format, SAST, type checkers, and dependency scanners (assume already run; do not duplicate). Flag intent gaps; do not redesign features.

Human-accountability rules (always review every line, never skip steps): [`references/human-accountability.md`](references/human-accountability.md).

## Profile

1. At review start, read [`profiles/interactive.md`](profiles/interactive.md) (default profile).
2. Run Steps 0–10 in order. **Analysis steps always run** — profile only changes checkpoint pauses and delivery.
3. At checkpoint steps, read the matching module in `checkpoints/` (artifact contract and handling) and the profile's gathering rules (how to ask, where input comes from); apply the profile's **checkpoint protocol**.
4. At Step 10, assemble the final review artifact, then follow the profile's **Delivery** section.

| Step | Module |
|---|---|
| 0 | [`checkpoints/output-format.md`](checkpoints/output-format.md) |
| 2 | [`checkpoints/intent.md`](checkpoints/intent.md) |
| 6 | [`checkpoints/change-brief.md`](checkpoints/change-brief.md) |
| 9 | [`checkpoints/human-input.md`](checkpoints/human-input.md) |

## Step 0 — Choose output format

Read and follow [`checkpoints/output-format.md`](checkpoints/output-format.md).


## Step 1 — Obtain the diff

Resolve the user's request to a concrete diff:

| User provided | How to resolve |
|---|---|
| Raw diff in the message | Use as-is. |
| File path(s) with a base/comparator implied | `git diff <base> -- <paths>` against the merge base of the current branch, or against `HEAD~1` if no base is clear. |
| File/folder with no diff context (clean tree, no comparator) | **Static review** — treat the file(s) as-is. Record scope as `snapshot`. Confirmed intent still applies — assess the artifact against stated goals and acceptance criteria, not only style or structure. |
| Branch name or commit SHA | `git diff <base>..<ref>` against its merge base with the default branch — the **net change that will merge**, not per-commit history. |
| MR URL | Fetch the diff via `glab mr diff <num>`; if unavailable, ask the user. |
| "Review my changes" / no scope | `git diff` (working tree) plus `git diff --staged`. |

If the diff cannot be obtained and no static review is appropriate, ask the user — do not invent context.

Record the resolved scope — `diff` or `snapshot` — in the output's `Transparency > Scope` line.


## Review policy file (repo)

Human sign-off gates read a **review policy** file from the repo under review when present. **Fixed section headlines** — teams edit body content only; the agent finds sections by headline.

**Look in order (first found wins):**

1. `docs/review-policy.md`
2. `.agents/review-policy.md`
3. A pointer in `AGENTS.md` (e.g. `Review policy: docs/review-policy.md`)

| Section headline | Purpose |
|---|---|
| `## Human sign-off required` | Triggers → `### Requires Human Review` |

Teams copy `templates/review-policy.example.md` into their repo. Risk assessment is **not** configured here — use system characterisation with repo-context org knowledge and agent judgment. Do **not** add `## Pipeline-covered paths` or classification labels — those were removed.


## Step 2 — Establish intent

Read and follow [`checkpoints/intent.md`](checkpoints/intent.md) — research intent artifacts, present `## Intent`, and **pause for human confirmation** before loading repo context.


## Step 3 — Load repo context

Derive standards from the **repo under review**, not from files inside this skill.

**Always:**

- Use `AGENTS.md` as the primary source for fit and conventions.
- Scan for other guiding docs: `README.md`, `docs/`, `CONTRIBUTING.md`, architecture notes, coding-standard files.

**Missing or thin `AGENTS.md`:**

- Do **not** stop the review.
- Add a finding when fit cannot be assessed reliably: e.g. "No `AGENTS.md` — repo conventions are unclear; agent had to infer patterns from neighbouring code. Add `AGENTS.md` to make this repo workable for AI-assisted development."
- Note in Transparency: **Project context:** list repo docs loaded for fit (e.g. `AGENTS.md`, `docs/architecture.md`) | `AGENTS.md missing` | `AGENTS.md thin`

**Insufficient repo documentation:**

- If you had to guess conventions, architectural rules, invariants, or intent beyond what was confirmed → flag it as a review finding ("docs too thin for confident review on X"). This nudges teams toward better AI-first documentation — not only for review. We are teaching teams how to document their repos for safe AI first coding - so it can be a review comment assessing their AI first documentation.  

**Domain knowledge:** follow [`references/always-on-knowledge.md`](references/always-on-knowledge.md), then the **knowledge-lookup** skill for change-specific domains (skip entries already loaded as always-on). Record **Always-on knowledge** and **Knowledge loaded** in Transparency per that reference.


## Step 4 — Characterise the system and assess risk

After repo context is loaded, read enough of the code to characterise the change and assess risk **once**, with the full picture: confirmed intent, the diff, `AGENTS.md` and repo docs, loaded org knowledge, and agent judgment — **not** path globs or repo-owned risk taxonomies.

**Always run** — answer all three questions; scale length to the change (write less for small changes — see [`references/human-accountability.md`](references/human-accountability.md) Always review):

1. **What does the system under review do, and what does it consist of?**
2. **What is its blast radius?** Who depends on it, worst plausible failure, trust boundaries.
3. **What are the top concerns this specific change demands?** Name what would matter most if it went wrong here.

Cite loaded org knowledge when it shapes risk; use `[via model]` for judgment gaps (tags per [`output/finding-citations.md`](output/finding-citations.md)). Do not invent org risk areas.

Gaps not covered by loaded knowledge or repo docs: cite `[via model]` on related findings.

Record in Transparency under **System characterisation** and **Risk assessment** (one-line summary from the three answers above).


## Step 5 — Human review gates

Check whether the repo defines surfaces that always need a human sign-off, regardless of agent findings.

Load the **review policy file** (see above). Read triggers under `## Human sign-off required` — each `###` heading is one trigger.

If no policy file exists → skip this step entirely.

For each trigger, judge: **does the diff touch this surface?** Use description-match judgement — not keyword scanning.

For each trigger that fires:

- Record the trigger name and `file:line` in the diff that matched.
- Collect matches for `### Requires Human Review` in the final review artifact.

**Critical distinction:** Gates are policy, not quality findings. If the surface matches, the gate fires even when the code looks fine. Do not conflate with Blocking findings.

If no triggers fire, omit `### Requires Human Review`.


## Step 6 — Change brief

Read and follow [`checkpoints/change-brief.md`](checkpoints/change-brief.md) — substantive briefing from repo context, system characterisation, and human sign-off gates; pause for human confirmation before the senior-engineer review.


## Step 7 — Senior-engineer review

Apply **all four review dimensions** above. Before drafting findings, ask what this change demands beyond acceptance criteria — including system characterisation and human sign-off gates. A draft with only defects (bugs, stale docs, missing tests) is incomplete; re-read for craft, design, and praise.

**Intent & correctness** — diff scope: net merge diff vs acceptance criteria; snapshot scope: artifact as-written vs criteria; gaps implied by the goal; characterisation concerns addressed; meaningful tests where load-bearing.

**Fit** — `AGENTS.md` and neighbouring patterns; reuse vs reinvent.

**Craft** — cognitive load, naming, control/data flow, justified complexity; flag readability as Suggestions/Nits (linters do not cover this).

**Design** — at least one plausible alternative when trade-offs exist; Praise when the approach is notably good.


## Step 8 — Self-critique pass

After drafting findings, run a self-critique before finalising.

**Default (inline):** re-read draft findings against the diff and intent — drop low-signal nits, downgrade speculative severity, verify every finding cites `file:line` with a concrete fix; confirm craft/design/praise coverage per the review dimensions.

**Escalate to a subagent** when judgment says stakes are high — for example:

- User asked for a thorough, deep, or careful review
- Sensitive surfaces in the diff (auth, payments, migrations, public API, secrets)
- Multiple blocking findings, especially on sensitive paths

A single obvious bug does **not** require a subagent.

**Review dir** — root of the repo under review. The subagent writes `{review-dir}/.self-critique.md` (repo root, not the skill install dir).

Launch via Task (Cursor) with `readonly: false` so the subagent can write that file. Constrain via prompt: `.self-critique.md` at the repo root is the only write.

**Subagent prompt:** Pass the diff, stated intent/acceptance criteria, draft findings, and characterisation. Ask:

1. Are the findings correctly described?
2. Are important concerns missing (especially vs acceptance criteria)?
3. Is severity calibrated correctly?
4. Craft/design coverage per the review dimensions?

After completion, read `{review-dir}/.self-critique.md`, accept or reject changes, delete the file. Record outcome in Transparency.


## Step 9 — Human input before final output

Read and follow [`checkpoints/human-input.md`](checkpoints/human-input.md).


## Step 10 — Write output

Assemble the final review artifact per [`output/general-output.md`](output/general-output.md) (section contract, template shell) plus the chosen output format file (findings layout only). Start from the locked change brief; refine if findings or human review input add nuance.

Follow the active profile's **Delivery** section.
