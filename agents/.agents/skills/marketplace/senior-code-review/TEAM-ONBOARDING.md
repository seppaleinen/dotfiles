# Team onboarding — senior-code-review skill

Checklist for rolling out the senior-code-review skill. Use your agent to follow this guide.

Complete **Steps 1–2** once per team, then **Steps 3–6** for each repo, then **Step 7** to verify.

---

## Steps 1–2 — One-time team setup

**Step 1 — Install the skill**

```bash
aza-market install senior-code-review
```

Org knowledge lookup (`knowledge-lookup` skill) is included in **aza-base**, which auto-installs when you run `aza-market install` bootstrap. No separate install step needed unless you removed `aza-base`.

**Step 2 — Agree on review culture**

- Reviews are **intent-first** — PRDs, tasks, and acceptance criteria should exist before large changes.
- **Four-eye model** — the agent prepares and structures review input; humans retain merge authority. See [`references/human-accountability.md`](references/human-accountability.md). Verdicts are recommendations, not approvals.
- **Review policy** is repo config, not skill config — see Step 4 below.
- Do **not** edit files under `~/.agents/skills/marketplace/senior-code-review/` for team settings; sync will overwrite them.

---

## Steps 3–6 — Each repository

**Step 3 — Add `AGENTS.md`**

Commit `AGENTS.md` to the repo root with stack, conventions, and patterns. Update it when load-bearing conventions change.

**Step 4 — Add review policy (optional)**

One file for human sign-off triggers. Keep the `##` section headlines from the template; edit content under each:

```bash
cp ~/.agents/skills/marketplace/senior-code-review/templates/review-policy.example.md docs/review-policy.md
```

- **`## Human sign-off required`** — surfaces that always need a human before merge (auth, payments, migrations, etc.)

Org-wide risk guidance belongs in marketplace **knowledge**, not review policy.

**Step 5 — Add intent docs**

For non-trivial work, keep a PRD or task file with acceptance criteria — e.g. `docs/specs/prd.md`, `docs/tasks/NNN_feature.md`. The review checks the diff against these.

**Step 6 — Decide where reviews are saved**

Default is chat output only. To persist reviews in the repo, ask the agent to save (e.g. "write the review to reviews/"). If you save locally but do not want them committed, add `reviews/` to `.gitignore`.

---

## Step 7 — Verify the first review

Run a review on a small, known MR. Confirm:

- The agent **paused for output format** and waited for your pick (not silent defaulting)
- The agent **presented full intent** in chat (`## Intent` with sources, goal, criteria) and waited for confirmation
- The agent **presented a full change brief** in chat (`## Change brief` with all subsections) and waited before continuing
- The agent **asked for human input** (comments, trade-offs, disputes) before finalising
- **`### Change brief`** appears in the final review (before verdict)
- **Intent sources** appear in the Transparency footer
- **Project context** shows `AGENTS.md` loaded (or a finding if missing)
- **Human sign-off gates** fire when expected (if `docs/review-policy.md` exists)
- **Risk assessment** appears in Transparency (characterisation + knowledge)
- Findings tag repo docs, installed knowledge, or model judgment where applicable

---

## Optional progression

**Every repo has context**

- `AGENTS.md` committed and maintained
- Intent docs for features that need product alignment

**Thin docs → review pressure**

- If the agent flags "docs too thin to review confidently", treat that as a signal to improve `AGENTS.md` or task files — it helps every agent workflow, not just review.

**Knowledge docs**

- **aza-base** (auto-installed on bootstrap) includes `knowledge-lookup` — no manual install unless you removed the package.
- Install relevant domain knowledge via `aza-market install <knowledge-name>` — not bundled in this skill.
- Follow the **knowledge-lookup** skill for discovery and loading; this skill only records what was loaded in the Transparency footer.

---

## Getting help

- Human guide: [README.md](README.md)
- Agent instructions: [SKILL.md](SKILL.md)
- Human accountability: [references/human-accountability.md](references/human-accountability.md)
- Finding citations: [output/finding-citations.md](output/finding-citations.md)
- Change brief spec: [checkpoints/change-brief.md](checkpoints/change-brief.md)
- Always-on knowledge: [references/always-on-knowledge.md](references/always-on-knowledge.md)
- Review policy template: [templates/review-policy.example.md](templates/review-policy.example.md)
