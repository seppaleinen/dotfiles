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
- `researcher` (primary intake agent) — grills the user, does web/source/GitOps investigation, writes a **Research Brief** to a file
- `team-lead` → routes a Research Brief to `dev-team-lead` or `devops-team-lead`
- `dev-team-lead` → `dev-architect` → `backend-engineer` / `frontend-engineer` → `test-engineer` → `code-reviewer`
- `devops-team-lead` → `devops-architect` → `devops-engineer` → `devops-verificator`
- `web-scout` (subagent of researcher) → identifies upstream repos/charts/images

`researcher` is a `mode: primary` agent: it cannot be launched as a subagent. The user switches to it (Tab) for intake, then returns to `team-lead` with the Research Brief file path.

**Deleted agents:** the old subagent `researcher`, `dev-engineer` (coordinator/integrator role removed — integration check now done by dev-team-lead), `issue-refiner`, and `devops-investigator` have been removed; their investigative work is consolidated into the primary `researcher`.

All inter-agent communication uses the handover protocol defined in `opencode/.config/opencode/skills/handover/SKILL.md`.

**Model tiers:** `team-lead` and orchestrators use `main_model` (reasoning). Worker agents (`backend-engineer`, `frontend-engineer`, `devops-engineer`) use `small_model` when the spec is clear.

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

## Environment Variables

Required for MCP servers: `MCP_TOKEN`, `K8S_TOKEN`, `HINDSIGHT_API_TOKEN`.
Secrets for LiteLLM auth stored at `~/.local/share/opencode/secrets/litellm-swap-*`.

## Hooks

`opencode/.config/opencode/hooks.sh` bridges OpenCode lifecycle events to `cmux notify` for desktop notifications.
