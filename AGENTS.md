# Dotfiles Repository

GNU Stow-managed dotfiles. Each top-level directory is a stow target symlinked to `~`.

## Critical Rules

1. **Edit in this repo, not through symlinks.** Always work in `~/dotfiles/`, never in `~/.config/` directly.
2. **One stow target per folder.** After changes, re-stow: `stow -t ~ <folder>`.
3. **Dry-run first** after adding new targets: `stow -n -t ~ <folder> --verbose=1`.

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

**Dispatch depth:** Max **3 layers** from `team-lead` (`subagent_depth: 3` in `opencode.json`) — enough for `team-lead → dev-team-lead → dev-architect → backend-engineer`. Keep pipelines within this budget.

**Visibility:** `team-lead` and the pipeline leads announce their current step (via the `todo` tool and STATUS markers) and surface any `[STUCK]` subagent to the user instead of looping silently. If you see a long wait with no progress output, a subagent may have hit a dispatch/depth-limit failure — interrupt that `team-lead` session and ask it for its TRACE so you can see where the chain stalled.

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

## Model swap procedure (enforced via config)

opencode now assigns per-agent models strictly from `opencode.json` under the `agent` key. This is a single-file change:

### Steps to change models:

1. **Update root models** in `opencode/.config/opencode/opencode.json`:
   - Edit `model` field for the primary agent and lightweight tasks
   - Edit `small_model` field for workers

2. **Update agent assignments** in the same file:
   - Modify `agent.<name>.model` entries if using hardcoded model IDs
   - If using `{env:VAR}` indirection, update the environment variables instead

3. **No .md files need changing** — model tier hints have been stripped from all agent `.md` files

### Example (current setup):

```json
{
  "model": "google/gemma-4-26b-a4b-qat",
  "small_model": "qwen/qwen2.5-coder-14b",
  "agent": {
    "common/team-lead":        { "model": "google/gemma-4-26b-a4b-qat" },
    "dev/backend-engineer":    { "model": "qwen/qwen2.5-coder-14b" },
    "devops/devops-engineer":  { "model": "qwen/qwen2.5-coder-14b" }
  }
}
```

**After a model change**:
- Restart opencode (quit and restart)
- No .md files touched

## Environment Variables

Required for MCP servers: `MCP_TOKEN`, `K8S_TOKEN`, `HINDSIGHT_API_TOKEN`.
Secrets for LiteLLM auth stored at `~/.local/share/opencode/secrets/litellm-swap-*`.

## Hooks

`opencode/.config/opencode/hooks.sh` bridges OpenCode lifecycle events to `cmux notify` for desktop notifications.
