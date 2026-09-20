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
| `opencode/.config/opencode/` | `~/.config/opencode/` | OpenCode agent config: agents, skills, plugins, MCP servers, model providers |
| `goose/.config/goose/` | `~/.config/goose/` | Goose agent config: extensions, MCP servers, providers |
| `jcode/.jcode/` | `~/.jcode/` | jcode agent config: keybindings, MCP servers, providers |
| `llama-swap/.config/llama-swap/` | `~/.config/llama-swap/` | Local LLM model swap server config |
| `agents/.agents/` | `~/.agents/` | Shared agent skills (caveman, handover, ponytail, etc.) |
| `.opencode/` | (not stowed) | OpenCode plugin deps when editing *this* repo |

## OpenCode Agent System

The agent pipeline is defined in `opencode/.config/opencode/agents/`. Default agent is `team-lead`.

**Pipeline structure (flat 2-level tree):**
- `researcher` (subagent, auto-dispatched by `team-lead`) — grills the user, does web/source/GitOps investigation, writes a **Research Brief** to a file
- `team-lead` → routes a Research Brief to `dev-team-lead` or `devops-team-lead`
- `dev-team-lead` → `dev-architect` → `backend-engineer` / `frontend-engineer` → `test-engineer` → `code-reviewer`
- `devops-team-lead` → `devops-architect` → `devops-engineer` → `devops-verificator`
- `web-scout` (subagent of researcher) → identifies upstream repos/charts/images

`researcher` is a `mode: subagent`, auto-dispatched by `team-lead` via `task()` when a task is raw/ambiguous. No manual Tab-switching.

**Deleted agents:** the old subagent `researcher`, `dev-engineer` (coordinator/integrator role removed — integration check now done by dev-team-lead), `issue-refiner`, and `devops-investigator` have been removed; their investigative work is consolidated into the `researcher` subagent.

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

## Model swap procedure (per-agent models live in agent .md frontmatter)

Per-agent models are assigned via the `model:` field in each agent's `.md` frontmatter (`opencode/.config/opencode/agents/**/*.md`). The `"agent"` map in `opencode.json` does NOT apply to dispatched subagents: runtime dispatch looks up agents by bare name, so path-keyed entries (e.g. `common/team-lead`) create orphan config that is never read (GitHub issue #7). Do not re-add per-agent entries to `"agent"`.

**Model IDs must be provider-qualified.** The runtime resolves `model:` (and `opencode.json` `model`/`small_model`) as `<provider>/<model-id>`; a bare `google/gemma-...` is parsed against the built-in Google provider and fails with `Model not found`. Use the full registered ID from `opencode models` — e.g. `local lmstudio/google/gemma-4-26b-a4b-qat` (provider `local lmstudio`, model `google/gemma-4-26b-a4b-qat`).

### Steps to change a model:

1. **Root defaults** stay in `opencode/.config/opencode/opencode.json`:
   - `model` — primary/default agent model
   - `small_model` — lightweight task model
2. **Per-agent** — edit `model:` in the agent's frontmatter (e.g. `opencode/.config/opencode/agents/dev/backend-engineer.md`):
   ```yaml
   ---
   name: backend-engineer
   model: local lmstudio/qwen/qwen2.5-coder-14b
   mode: subagent
   permission:
     ...
   ---
   ```
3. **Restart opencode** after any change.

### Current assignments (issue #7 fix):

- **gemma tier** (`local lmstudio/google/gemma-4-26b-a4b-qat`): team-lead, researcher, dev-team-lead, dev-architect, devops-team-lead, devops-architect, ai-security-auditor
- **qwen tier** (`local lmstudio/qwen/qwen2.5-coder-14b`): backend-engineer, frontend-engineer, test-engineer, code-reviewer, devops-engineer, devops-verificator, test-auditor
- **default (session model)**: web-scout (intentionally unassigned — "Model tier: balanced")

## Environment Variables

Required for MCP servers: `MCP_TOKEN`, `K8S_TOKEN`, `HINDSIGHT_API_TOKEN`.
Secrets for LiteLLM auth stored at `~/.local/share/opencode/secrets/litellm-swap-*`.

## Hooks

`opencode/.config/opencode/hooks.sh` bridges OpenCode lifecycle events to `cmux notify` for desktop notifications.
