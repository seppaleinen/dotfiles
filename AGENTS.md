# Dotfiles Repository

GNU Stow-managed dotfiles. Each top-level directory is a stow target symlinked to `~`.

## Critical Rules

1. **Edit in this repo, not through symlinks.** Always work in `~/dotfiles/`, never in `~/.config/` directly.
2. **One stow target per folder.** After changes, re-stow: `stow -t ~ <folder>`.
3. **Dry-run first** after adding new targets: `stow -n -t ~ <folder> --verbose=1`.
4. **Stow verification (folded-symlink gotcha):** the top-level dir — e.g. `~/.config/opencode`, `~/.agents` — IS the stow symlink; files inside it look like regular files even on a correct install. When investigating "copies vs symlinks", check one level up with three checks: `readlink ~/.config/opencode` (expect `../workspace/dotfiles/opencode/.config/opencode`), `stow -n -t ~ <target> --verbose=1` (clean, exit 0), and an inode spot-check `ls -i ~/.config/opencode/opencode.json opencode/.config/opencode/opencode.json` (identical). herdr/opencode-managed files write through the symlink into the repo by design — treat rewrites of tracked files (e.g. `herdr-tui-session.js`) as intentional commits. `node_modules/` lives physically in the package dir (`opencode/.config/opencode/`) and is gitignored.

## Repository Layout

| Directory | Stows to | Purpose |
|-----------|----------|---------|
| `zsh/` | `~/.zshrc`, `~/.zsh_plugins.txt`, `~/.p10k.zsh` | Shell config — P10K, antidote, compdef catcher, completion, lazy NVM/SDKMAN, aliases. Source of truth for shell; Ansible only installs deps. |
| `opencode/.config/opencode/` | `~/.config/opencode/` | OpenCode agent config: agents, skills, plugins, MCP servers, model providers |
| `goose/.config/goose/` | `~/.config/goose/` | Goose agent config: extensions, MCP servers, providers |
| `jcode/.jcode/` | `~/.jcode/` | jcode agent config: keybindings, MCP servers, providers |
| `llama-swap/.config/llama-swap/` | `~/.config/llama-swap/` | Local LLM model swap server config |
| `agents/.agents/` | `~/.agents/` | Shared agent skills (caveman, handover, ponytail, etc.) |
| `secrets/` | `~/.secrets.zsh` | SOPS-encrypted user API keys; decrypt with `sops -d secrets/secrets.zsh > ~/.secrets.zsh` |
| `.opencode/` | (not stowed) | OpenCode plugin deps when editing *this* repo |

## OpenCode Agent System

The agent pipeline is defined in `opencode/.config/opencode/agents/`. Default agent is `team-lead`.

**Pipeline structure (flat 2-level tree):**
- `researcher` (subagent, auto-dispatched by `team-lead`) — grills the user, does web/source/GitOps investigation, writes a **Research Brief** to a file
- `team-lead` → routes a Research Brief to `dev-team-lead` or `devops-team-lead`
- `dev-team-lead` → `dev-architect` → `backend-engineer` / `frontend-engineer` → `test-engineer` → `code-reviewer` → **`devops-cleanup` & `post-mortem-analyst`**
- `devops-team-lead` → `devops-architect` → `devops-engineer` → `devops-verificator` → **`devops-cleanup` & `post-mortem-analyst`**
- `web-scout` (subagent of researcher) → identifies upstream repos/charts/images

`researcher` is a `mode: subagent`, auto-dispatched by `team-lead` via `subagent()` when a task is raw/ambiguous. No manual Tab-switching.

**Post-Verification Pipeline (New Stages)**

After verification returns `[SUCCESS]` from `code-reviewer` (dev) or `devops-verificator` (devops), `team-lead` dispatches two new agents:

- **`devops-cleanup`**: Asks the user whether cleanup is wanted, then closes the working issue (if objectives met) and deletes the working branch (only if its PR was merged; asks user if no PR or unmerged)
- **`post-mortem-analyst`**: Reviews the full workflow conversation + git history + agent timeline for errors, dead ends, rework loops; diagnoses root causes (insufficient research, ambiguous requests, miscommunication, missing skills/scripts, pipeline gaps, tooling issues); identifies skill/script gaps ranked by impact; reports findings + concrete proposals back to the user, then asks which fixes should be tracked as follow-up issues (never creates issues or PRs without explicit user request)

Both new agents live in `opencode/.config/opencode/agents/` (shared across dev/devops pipelines) and follow the same handover protocol as other agents.

**Deleted agents:** `dev-engineer` (coordinator/integrator role removed — integration check now done by dev-team-lead), `issue-refiner`, and `devops-investigator` have been removed. Their former intake and investigation work is now handled by the active `researcher` subagent (see the pipeline structure above — `researcher` is **not** deleted).

**Post-edit stale-reference scan:** After changing an agent's behavior (e.g. `post-mortem-analyst` from auto-create to ask-first), run the stale-reference scanner:

```bash
./scripts/check-stale-agent-refs.sh "old behavior pattern"
```

This script greps all agent `.md` files under `opencode/.config/opencode/agents/` for stale references to the changed agent's old behavior. Exit 0 if clean, 1 with file list if stale. Flag any file that still references the old behavior and update it before considering the edit complete.

**readme.html sync check:** `opencode/.config/opencode/agents/readme.html` is the hand-maintained staff chart. It lists agents on three surfaces — the folder-tree block (must list **every** agent), the `data-agent="..."` attributes on clickable buttons, and the JS `agents` object (blurbs for the clickable agents). Run the sync checker after **any** change that adds, removes, or renames an agent `.md`, and after any change to an agent's role:

```bash
./scripts/check-readme-sync.sh
```

Exit 0 means the folder tree lists all 27 agents with no stale references. Exit 1 names the drift. The on-demand auditors (`ai-security-auditor`, `context-drift-auditor`, `performance-auditor`, `seo-aeo-auditor`, `test-auditor`) and the ontology agents (`ontology-auditor`, `api-scanner`, `db-scanner`, `matrix-generator`, `socratic-questioner`, `ux-scanner`) are deliberately **not** clickable — they sit outside the team-lead chain — so they are not required on the button/JS surfaces. If you make one of them part of the dispatch flow, add it to those surfaces too.

All inter-agent communication uses the handover protocol defined in `opencode/.config/opencode/skills/handover/SKILL.md`.

**Model tiers:** `team-lead` and orchestrators use `main_model` (reasoning). Worker agents (`backend-engineer`, `frontend-engineer`, `devops-engineer`) use `small_model` when the spec is clear.

**Dispatch depth:** Max **2 layers** from `team-lead` (`subagent_depth: 2` in `opencode.json`) — deepest chains are `team-lead → dev-team-lead → worker` and `team-lead → researcher → web-scout`. Keep pipelines within this budget; flatten deeper chains or escalate.

**Visibility:** Dispatched agents run as child sessions, but live child-session visibility is unreliable in this stack (opencode 1.18.30 + herdr ignores child sessions in its status reporting). The supported visibility channel is the status lines + handover summaries the pipeline leads post in the main conversation: one line before each dispatch, a status/result line after each return, and every `[STUCK]`/`[REWORK]`/`[BLOCK]`/empty result surfaced with a reason. `ctrl+x+down` (`session_child_first`) / `ctrl+x+up` (`session_parent`) lets you inspect a child session best-effort, not as a guarantee. `team-lead` and the pipeline leads announce their current step (via the `todo` tool and STATUS markers). If a subagent genuinely stalls or a dispatch/depth-limit failure occurs, ask that `team-lead` session for its TRACE so you can see where the chain stalled.

## Shared MCP Servers

Configured identically across OpenCode, Goose, and jcode:
- **authentik**: `uvx authentik-mcp` → `https://authentik.labb.site` (token: `$MCP_TOKEN`)
- **grafana**: `uvx mcp-grafana` → `https://grafana.labb.site` (token: `$MCP_TOKEN`)
- **kubernetes**: remote at `https://mcp.labb.site/k8s/mcp` (token: `$K8S_TOKEN`)
- **hindsight**: remote memory server (token: `$HINDSIGHT_API_TOKEN`)

## llama-swap

Runs local GGUF models via `llama-server`. Two routing groups:
- **chat**: gemma-4-26b, gemma-4-31b, qwen3.6-27b, qwen3.6-35b, gpt-oss-20b, qwen2.5-coder-7b, llama-3.1-8b
- **embeddings**: nomic-embed-text-v2 (persistent, never swapped)

Models stored at `/home/seppa/models/`. Global TTL: 300s. Health check timeout: 180s.

## Model assignment (no per-agent model forcing)

Agents inherit the session model from the opencode model picker. The `"agent"` map in `opencode.json` does NOT apply to dispatched subagents (path-keyed entries are inert — GitHub issue #7). Do not add per-agent entries to `"agent"`, and do not set `model:` in agent `.md` frontmatter — doing so overrides the session model the user chose.

- `opencode.json` `model` / `small_model` — default session model for new sessions
- Per-agent model — inherited from the session; not overridden in frontmatter
- **Model IDs must be provider-qualified** when set in `opencode.json`: use the full ID from `opencode models` (e.g. `opencode/big-pickle`, not bare `big-pickle`). Bare names parse against built-in providers and fail with `Model not found`.
- **Restart opencode** after any change to `opencode.json`.

## Environment Variables

Required for MCP servers: `MCP_TOKEN`, `K8S_TOKEN`, `HINDSIGHT_API_TOKEN`.
Secrets for LiteLLM auth stored at `~/.local/share/opencode/secrets/litellm-swap-*`.

## Hooks

`opencode/.config/opencode/hooks.sh` bridges OpenCode lifecycle events to `cmux notify` for desktop notifications.

## OpenCode plugins

`opencode.json` `plugin:` array currently contains only `opencode-plugin-litellm@latest` and `{env:HOME}/.hindsight/coding-agents`. The v1 opentmux plugin (`opencode-agent-tmux`) was dropped in commit `1bb1c10` and must not be re-added.

**Armed updater risk:** `node_modules/opentmux/dist/scripts/update-plugins.js` (installed as a dependency of the now-unused `opentmux` package) runs only when `OPENCODE_TMUX_UPDATE=1` is set in the environment — which it is not here, so the updater is effectively inert in this repo. However, its `ensurePluginEntry()` only recognizes the legacy name or a path ending in `/opentmux`; it never normalizes npm specs, so if opentmux is ever reinstalled or invoked with that env var set, it re-appends `opencode-agent-tmux` on every run.

**Guard (non-committed, reversible):** a repo opt-out check has been added at the top of `main()` in `node_modules/opentmux/dist/scripts/update-plugins.js`. When `OPENCODE_TMUX_READD` is not set to `1`, the updater bails out early if `opencode-agent-tmux` is absent from `opencode.json` — so it cannot silently re-add the phantom entry. To opt back in, set `OPENCODE_TMUX_READD=1`. `node_modules/` is gitignored and not repo-managed; if you reinstall opentmux, re-apply the guard or set the env var.

## Tool call discipline

These rules govern how tools are invoked across the repo to prevent silent failures, wasted cycles, and output thrash.

### Empty subagent() dispatch results

Any agent that dispatches via `subagent()` must verify the returned result is **non-empty** before acting on it. An empty result is not a valid outcome — it indicates the dispatched agent produced no usable output.

If a `subagent()` result is empty, return `[STUCK]` with:
- The dispatch prompt that was sent
- The session ID of the dispatched agent
- The timestamp when the empty result was received

Do NOT treat an empty result as success, do NOT synthesize or forward it, and do NOT continue downstream on it. Surface it immediately and offer re-dispatch (`task_id` resume) or hand back to the caller.

This rule is enforced in the workflow of every agent that dispatches `subagent()`: `team-lead`, `dev-team-lead`, `devops-team-lead`, and `post-mortem-analyst`.

### Automatic task_id capture (mandatory, no manual extraction)

After **every** `subagent()` call — success or failure — extract the `task_id` mechanically and store it as `LAST_TASK_ID`. This is not optional; it is a required step before any re-dispatch. Do NOT rely on manual lookup or user recall.

The `task_id` is always present in the result. It appears in one of two forms — scan for both:

| Result form | Pattern to extract |
|---|---|
| Success / running / completed | `<subagent sessionID="ses_xxx" state="...">` → capture `ses_xxx` |
| Failure (error thrown) | Error message contains the session id `ses_xxx` → capture `ses_xxx` |

**Rule:** If neither pattern is found, the dispatch did not produce a session — treat as `[STUCK]` and report. Do NOT guess or fabricate a `task_id`.

**On re-dispatch:** always pass `sessionID="$LAST_TASK_ID"` in the new `subagent()` call. The tool will reuse the existing session if it is still alive, or fall back to a fresh session if it has been aborted — either way, no manual lookup is needed.

This rule is enforced in the workflow of every agent that dispatches `subagent()`: `team-lead`, `dev-team-lead`, `devops-team-lead`, `researcher`, and `post-mortem-analyst`.

### rtk find loop prevention

See the `rtk-find-loop-prevention` skill at `opencode/.config/opencode/skills/rtk-find-loop-prevention/SKILL.md`. Load it when using `rtk find`:

```
skill(name="rtk-find-loop-prevention")
```

### General guidance

- Prefer the dedicated tools (`Read`, `Glob`, `Grep`, `Edit`, `Write`) over raw shell commands (`cat`, `grep`, `find`, `head`, `tail`, `sed`, `awk`, `echo`) for file operations.
- When a shell command is genuinely needed, capture its output and verify it is meaningful before repeating it with the same arguments.

### opencode service lifecycle (issue #25)

**NEVER run `opencode service restart`, `opencode service set env`, or `opencode service stop` from inside any opencode session.** These commands kill the daemon, which hosts ALL opencode sessions (subagents + the main session). This has killed live sessions 3x.

- A restart must be the LAST pipeline step, executed by the user in a plain terminal (outside opencode), or via launchd/`setsid` outside the daemon tree.
- Pipeline pattern: return a `[RESTART_NEEDED]` handover instead of performing the restart in-session; verification is a fresh step afterward.
- Hard rule for: `devops-team-lead`, `devops-engineer`, `devops-verificator`, `devops-cleanup`.
- Guard script: `/tmp/oc-service-guard.sh` — run it before any service command to abort early if the current process tree descends from `opencode serve`.
