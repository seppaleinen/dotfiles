---
name: knowledge-lookup
description: >-
  Loads installed org knowledge (security requirements, platform conventions,
  domain rules). Use when the task depends on an org standard the repository
  and current context do not answer, or an instruction names a knowledge
  entry or cites `[ref: <name>]`. Not for general programming work.
compatibility: Catalog search requires the aza-market CLI.
---

# Knowledge Lookup

Load only what the task needs. Stop as soon as you have enough.

## Knowledge lists are exclusive

If your instructions list knowledge (`Knowledge: <paths or entry names>`), load only that: read paths directly and resolve names with Step 1. Do not browse the registry or search the catalog. `Knowledge: none` means load nothing.

When you delegate after loading knowledge, list the concept file paths you loaded under `Knowledge:` in the task packet and add "load no other org knowledge".

## Delegated agents

On a bounded task (for example one plan phase), use what the packet names. Run Steps 1–2 only for a concrete org-policy question the packet does not answer, and never Step 3. An agent whose task is to find the applicable guidance (for example a plan explorer) runs the full workflow.

## Step 1 — Find entries

Registries are `~/.agents/knowledge/registry.json` and `.agents/knowledge/registry.json` in the workspace. The project entry wins on a name collision.

- **Named entry** (or `[ref: <name>]`): use it directly, regardless of repo scope. If it is not installed, say so and consider Step 3.
- **Otherwise:** if the workspace has `.agents/knowledge/scope.yaml`, its `user_knowledge` limits user-level entries (`none`, a list of names, or `all`; missing file means `all`). Project entries always apply. Match on `title`, `tags`, and `description`. If none fits, go to Step 3 or stop.

## Step 2 — Load concepts

1. Pick concepts from the entry's `concepts_index` file. Read `{install_path}/index.md` only when there is none or you need the bundle's structure.
2. Load only the matched `{install_path}/<id>.md` files, never catalog source paths.
3. Follow cross-links one hop deep, only when needed. `/references/foo.md` resolves to `{install_path}/references/foo.md`.

## Step 3 — Catalog search (judgment call)

Search only when nothing installed covers the need and the user asks about an org standard, or the task clearly hinges on one and getting it wrong would matter. One search per topic per session:

```bash
aza-market search --type knowledge <free-text>
```

Suggest `aza-market install <name>` (`--project` for this repo only) for relevant hits. Do not auto-install.

## Step 4 — Report and cite

Name loaded entries in one line; say nothing about knowledge when none applied unless asked. Tag claims backed by loaded knowledge with `[ref: <name>]`. When you looked for knowledge on an org-standard question and found none, tag the related claim `[via model]`.
