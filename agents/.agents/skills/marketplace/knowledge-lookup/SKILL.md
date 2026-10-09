---
name: knowledge-lookup
description: >-
  Check whether org knowledge exists for the domain or technology in play
  (security, a framework like Apollo, a platform, a business domain). Use at
  the start of non-trivial work, when the knowledge-discovery rule nudges you,
  when another skill defers here, or whenever you would otherwise rely on
  general model knowledge for a domain that an org team might have documented.
---

# Knowledge Lookup

Find and load relevant org knowledge before relying on general model knowledge.

## Step 1 — Active set (installed)

Read the knowledge registry (user, then project if present; **project overrides user** on name collision):

- `~/.agents/knowledge/registry.json`
- `.agents/knowledge/registry.json` in the workspace repo

For each entry, judge relevance from `tags`, `title`, and `description` against the current task.

### OKF bundles (`profile: bundle`)

1. Read `{install_path}/index.md` when present — skim section headings and linked concept descriptions
2. If the registry includes `concepts`, use `title`, `tags`, and `description` to pick matches without opening every file
3. Load **only** the matched concept files under `{install_path}/`
4. Follow cross-links one hop deep when a loaded concept references another
5. Resolve OKF bundle-relative links: `/references/foo.md` → `{install_path}/references/foo.md`

### OKF handbooks (`profile: handbook`)

Read the concept file listed in `concepts` (or linked from `index.md` when present). For a single-concept handbook, load that file directly.

## Step 2 — Available knowledge (catalog), only on a gap

If nothing in the active set covers the domain, search the catalog:

```bash
aza-market search --type knowledge --not-installed --tag <domain>
aza-market search --type knowledge <free-text>
aza-market search --type knowledge              # full library; ✓ marks installed
```

If a relevant hit is **not installed**, tell the user and suggest:

```bash
aza-market install <name>            # user level
aza-market install <name> --project  # this repo only
```

Do **not** auto-install. Do **not** read from marketplace catalog source paths — only installed files under `{install_path}/`.

## Step 3 — Transparency

State which knowledge you loaded (names + why), which concepts you skipped, and any suggested installs. If both the registry and catalog search come up empty, say so.

## Step 4 — Citing loaded knowledge

Tag claims backed by loaded knowledge with `[ref: <name>]` using the registry `name` (e.g. `[ref: ai-first]`). When no matching knowledge or repo doc applies, use `[via model]`.
