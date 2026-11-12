# Senior Code Review

## What does it do?

Senior-engineer-style code review for PRs, branches, and working-tree changes. The agent establishes **intent** from PRDs, tasks, and acceptance criteria, checks whether the change achieved that intent and **fits** the repo, assesses **craft** (readability, clarity) and **design** (alternatives, improvements — not only defects), applies human review gates when the repo defines them, and optionally runs a self-critique subagent pass. Human review input is collected at the change brief (optional discuss-while-reviewing) and again before final output.

## Problems it solves

- Reviews that only comment on style or the diff, not whether the change achieved its goal
- Reviews that only hunt bugs and stale docs, without readability, design alternatives, or "what would make this better"
- Reviews that ignore stated acceptance criteria or product intent
- Fit assessment without repo context (`AGENTS.md`, docs, conventions in code)
- Policy surfaces (auth, payments, migrations) that need a human sign-off regardless of agent findings
- Inconsistent review output — the agent pauses for **output format**, **intent**, **change brief**, and **human input** before delivering findings
- Humans re-reading entire diffs — no curated implementation summary before findings

## Example prompts

- "Review this PR" / "code review" / "review my changes" / "review this diff" / "review this branch"
- "Thorough review" / "deep review" / "careful review" (more likely to escalate self-critique to a subagent)
- "Discuss while I review" / "let me weigh in" / "add my context" (at change brief or before final output)
- "Save the review to reviews/" (writes the artifact to the repo under review)

## Requirements

- **git** and **Shell** in the repo under review
- Optional **glab** when reviewing via MR URL
- A subagent-capable runtime (Task in Cursor) when self-critique escalates
- **`AGENTS.md`** and intent docs (PRD, task file, acceptance criteria) in the target repo strongly recommended — missing docs become review findings, not hard stops
- **knowledge-lookup** skill for org knowledge discovery (included in **aza-base**, which auto-installs on `aza-market install` bootstrap). If you install this skill alone, also run `aza-market install knowledge-lookup` or `aza-market install aza-base`.

---

See [TEAM-ONBOARDING.md](TEAM-ONBOARDING.md) for rollout steps.

---

## Conceptual model

The skill owns **review process only**. Team-specific policy and standards live in the **repo under review**, or in installed marketplace **knowledge** (`aza-market install <knowledge-name>`).

Every review applies four dimensions: **Intent**, **Fit**, **Craft** (readability), and **Design** (alternatives and improvements). Defect-only output (bugs, stale docs) without craft, design, or praise is incomplete.

| Layer | What | Where |
|-------|------|--------|
| **Skill logic** | Steps 0–10; artifact vocabulary and step order | `SKILL.md` |
| **Checkpoints** | Artifact contract and input handling — profile-agnostic | `checkpoints/` |
| **Profile** | Interactive checkpoints: how to ask, where input comes from, delivery | `profiles/interactive.md` |
| **Human accountability** | Four-eye model, recommendation-not-approval, human review points | `references/human-accountability.md` |
| **Finding citations** | Tags on findings (`[ref: …]`, `[from reviewer]`, `[via model]`) | `output/finding-citations.md` |
| **Change brief** | Subsections and content rules for checkpoint and final artifact | `checkpoints/change-brief.md` |
| **Always-on knowledge** | Tags/names loaded on every review | `references/always-on-knowledge.md` |
| **Output** | Shared sections + findings layout | `output/general-output.md`, `output/default.md`, … |
| **Project context** | Conventions, stack, patterns | `AGENTS.md` and other docs in the **reviewed repo** |
| **Intent** | What the change should achieve | PRD, task files, acceptance criteria, MR description in the **reviewed repo** |
| **Review policy** | Human sign-off triggers | `docs/review-policy.md` in the **reviewed repo** |

---

## How it works

When you ask for a code review, the agent follows **Steps 0–10** in `SKILL.md`:

| Step | What |
|------|------|
| **0 — Choose output format** | List available formats; **hard pause** for your pick |
| **1 — Obtain the diff** | MR URL, branch, paths, working tree, or static snapshot |
| **2 — Establish intent** | PRD, task file, acceptance criteria; **hard pause** for confirmation |
| **3 — Load repo context** | `AGENTS.md`, repo docs, always-on + change-specific knowledge |
| **4 — Characterise & assess risk** | What could break, who is affected, top concerns |
| **5 — Human review gates** | `## Human sign-off required` from `docs/review-policy.md` |
| **6 — Change brief** | Dense implementation briefing; **hard pause** for confirmation |
| **7 — Senior review** | Intent vs artifact, fit, craft, design, tests |
| **8 — Self-critique** | Inline by default; subagent when stakes are high |
| **9 — Human input** | **Hard pause** — comments, trade-offs, or disputes to merge |
| **10 — Write output** | Deliver interactively by default; save to `reviews/` only when asked |

### Self-critique

- **Inline** by default — drops low-signal nits, checks `file:line` and concrete fixes. Re-reads the diff if the draft only contains defects and lacks craft, design, or praise findings.
- **Subagent** when stakes are high: thorough/deep/careful review, sensitive surfaces (auth, payments, migrations, public API), or multiple blocking findings. A single obvious bug does **not** require a subagent.
- The subagent writes `.self-critique.md` at the **root of the repo under review**; the parent reads it, accepts or rejects, then deletes it.

### Collaborative human input

- **Change brief** — presents the brief; you confirm, adjust focus, or discuss while reviewing
- **Human input** — mandatory pause before final output: share comments, trade-offs, or disputes — or reply nothing to add
- Your wording is preserved (`[from reviewer]`); the agent verifies and may disagree in the open — input is never dropped silently

### Review output

Layout follows the format chosen at review start plus shared sections from [`output/general-output.md`](output/general-output.md). Required sections: `### Change brief`, `### Verdict`, `### Requires Human Review` (when gates fire), findings sections, and `### Transparency`.

---

## Scope & non-goals

Senior-engineer reviewer assist — **not** a replacement for CI lint/format, SAST, type checking, dependency scanning, or product/design review.

---

## Repo configuration

Configure the **reviewed repo**, not the skill install dir — marketplace sync overwrites skill files. See [TEAM-ONBOARDING.md](TEAM-ONBOARDING.md) for a full rollout checklist.

| What | Where | Why |
|------|-------|-----|
| **`AGENTS.md`** | repo root | Fit assessment, conventions, patterns |
| **Intent docs** | e.g. `docs/specs/prd.md`, `docs/tasks/NNN_*.md` | Acceptance criteria the review checks against |
| **Review policy** | `docs/review-policy.md` | Human sign-off triggers (auth, payments, migrations, …) |
| **Org knowledge** | `aza-market install <name>` | Domain and compliance rules loaded during review |

Copy the review policy template:

```bash
cp ~/.agents/skills/marketplace/senior-code-review/templates/review-policy.example.md docs/review-policy.md
```

Keep the `##` section headlines from the template; edit content under each. Risk assessment is not configured in review policy — it comes from system characterisation and installed knowledge during the review.

---

## Tips

- **`AGENTS.md` plus intent docs** are the biggest levers — invest there before anything else.
- **Human review policy** belongs in the repo, not in the skill.
- **Saving reviews** — off by default; ask explicitly ("save the review", "write to reviews/").
