---
name: aza-marketplace
description: Use the `aza-market` CLI to find, install, update, and manage agent components (skills, rules, hooks, agents, commands, MCP servers, knowledge, and packages) from the Avanza agent marketplace. Use when the user asks to install or remove marketplace components, browse the catalog, check what is installed, find org knowledge, or debug auto-update issues.
---

# aza-marketplace

CLI for the Avanza agent marketplace.

## Discover

```bash
aza-market search                        # list components (default 20 per page; ✓ marks installed)
aza-market search --not-installed        # only show components not yet installed
aza-market search --type skill           # filter by type
aza-market search --type knowledge       # org knowledge library (✓ = installed)
aza-market search --tag testing          # filter by tag
aza-market search python                 # free-text search
aza-market search avanza coder           # multi-word search (words are joined)
aza-market search --show-all             # include internal and deprecated components
aza-market search --limit 100            # up to 100 results per page (max 100)
aza-market search --type knowledge --limit 100 --offset 100  # next page
aza-market browse                        # open visual browser in default browser
aza-market browse --show-all             # open with "Show internal & deprecated" pre-enabled
```

## Install and remove

```bash
# User-level install (default)
aza-market install python-expert

# Project-level install (into .agents/skills/marketplace/ or .cursor/hooks.json in CWD)
aza-market install python-expert --project

# Install targeting a specific platform (default: cursor)
aza-market install python-expert --platform cursor

# Remove (--yes / -y skips confirmation)
aza-market remove python-expert
aza-market remove python-expert --yes    # skip confirmation
aza-market remove python-expert -y       # shorthand for --yes
aza-market remove python-expert --project  # remove from project scope instead of user

# Install may prompt for missing marketplace dependencies declared in catalog.yaml.
# Use --yes / -y to install them without prompting. Declining still installs the
# requested component — only the dependencies are skipped. External tools (curl,
# uv, etc.) are info-only — declare them under dependencies.external in
# catalog.yaml; the CLI does not install them. README ## Requirements is for
# browse; catalog.yaml is for install.
aza-market install python-expert --yes

# NOTE: removing a package also removes all components that are part of it.
# Install components individually if you want to remove them independently.
```

## List installed

```bash
aza-market list              # all installed components
aza-market list --user       # user-level only
aza-market list --project    # project-level only (current working directory)
```

## Update

```bash
aza-market update python-expert   # update one component
aza-market update --all           # update all non-pinned components
aza-market sync                   # pull catalog + re-install all stale components
aza-market sync --quiet           # suppress output (used by the sessionStart background hook)
```

`sync` and `update --all` re-install when SHA changes and warn about missing marketplace dependencies (logged to `sync.log` when quiet). They do not install deps. Use `aza-market install <name>` or `aza-market update <name>` to resolve them.

## Pin and unpin

```bash
aza-market pin python-expert            # lock to current SHA — no auto-updates (user scope)
aza-market pin python-expert --project  # pin at project scope
aza-market unpin python-expert          # re-enable auto-updates (user scope)
aza-market unpin python-expert --project  # unpin at project scope
```

## Per-install configuration

```bash
# Show effective settings for an installed component
aza-market config component jira
aza-market config component my-skill --project

# GitLab git+ MCP: test a feature branch without hand-editing mcp.json
aza-market config component jira --set branch my-branch
aza-market config component jira --unset branch

# Skill: allow ambient model invocation (disable-model-invocation: false)
aza-market config component aza-cli --set disable-model-invocation false
```

Overrides are stored in `installed.json` and survive sync/update. `aza-market list` shows active overrides in the Status column (`branch=… (override)` for GitLab git+ MCPs, `disable-model-invocation=… (override)` for skills). Pinned installs are patched in place (SHA unchanged).

## Dev / branch testing

**Only run `use-branch` when the user explicitly asks** to test an unmerged catalog branch. Do not suggest or use it proactively — it switches the local marketplace clone to a feature branch and can leave the user stuck there.

```bash
aza-market use-branch feature/my-branch  # switch the local marketplace clone to a branch
aza-market use-branch --reset            # return to the default remote branch and pull
```

If you ran `use-branch`, remind the user to run `aza-market use-branch --reset` when they are finished testing.

## Install paths

| Type | Scope | Path |
|---|---|---|
| skill | user | `~/.agents/skills/marketplace/<name>/` |
| skill | project | `.agents/skills/marketplace/<name>/` (relative to CWD) |
| rule | user | `~/.cursor/rules/marketplace/<name>.mdc` (+ Copilot instruction files under `marketplace/`) |
| rule | project | `.cursor/rules/marketplace/<name>.mdc` (+ `.github/instructions/marketplace/`) |
| command | user | `~/.cursor/commands/marketplace/<name>.md` |
| command | project | `.cursor/commands/marketplace/<name>.md` (+ `.github/prompts/marketplace/`) |
| agent | user | `~/.cursor/agents/marketplace/<name>.md` and `~/.github/agents/marketplace/<name>.md` |
| agent | project | `.cursor/agents/marketplace/<name>.md` and `.github/agents/marketplace/<name>.md` |
| hook | user | `~/.cursor/hooks.json` (merged) |
| hook | project | `.cursor/hooks.json` (merged) |
| knowledge | user | `~/.agents/knowledge/marketplace/<name>/` |
| knowledge | project | `.agents/knowledge/marketplace/<name>/` |

## Knowledge discovery

Installed knowledge is indexed in `registry.json`; the full catalog (installed or not) is via `aza-market search --type knowledge`.

Install copies **OKF bundle files only** — `catalog.yaml` and `README.md` stay in the catalog source; metadata lives in `registry.json`.

| File | Purpose |
|---|---|
| `~/.agents/knowledge/registry.json` | Installed knowledge metadata + `install_path` + `profile` + `concepts` (user scope) |
| `.agents/knowledge/registry.json` | Installed knowledge metadata + `install_path` + `profile` + `concepts` (project scope) |
| `{install_path}/index.md` | OKF bundle entry when present — skim for navigation |
| `{install_path}/<concept>.md` | OKF concept files with YAML frontmatter |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `aza-market: catalog not found` | `aza-market install` never run | Run the bootstrap one-liner from the repo README |
| `Component not found` | Wrong name | Run `aza-market search` to see available components |
| Component not auto-updating | It is pinned | Run `aza-market unpin <name>` |
| `git pull --rebase failed` | No network or SSH key issue | Check VPN and GitLab SSH access |
| Skill not picked up by Cursor | Wrong install path | Confirm `~/.agents/skills/marketplace/<name>/SKILL.md` exists |
| Rule not picked up by Cursor | Wrong install path | Confirm `~/.cursor/rules/marketplace/<name>.mdc` exists |
| Command not picked up by Cursor | Wrong install path | Confirm `~/.cursor/commands/marketplace/<name>.md` exists |
| Agent not picked up by Cursor or Copilot | Wrong install path | Confirm `~/.cursor/agents/marketplace/<name>.md` and `~/.github/agents/marketplace/<name>.md` exist |
