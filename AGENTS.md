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
- `dev-team-lead` → `dev-architect` → `backend-engineer` / `frontend-engineer` → `test-engineer` → `code-reviewer` → **`devops-cleanup` & `post-mortem-analyst`**
- `devops-team-lead` → `devops-architect` → `devops-engineer` → `devops-verificator` → **`devops-cleanup` & `post-mortem-analyst`**
- `web-scout` (subagent of researcher) → identifies upstream repos/charts/images

`researcher` is a `mode: subagent`, auto-dispatched by `team-lead` via `task()` when a task is raw/ambiguous. No manual Tab-switching.

**Post-Verification Pipeline (New Stages)**

After verification returns `[SUCCESS]` from `code-reviewer` (dev) or `devops-verificator` (devops), `team-lead` dispatches two new agents:

- **`devops-cleanup`**: Asks the user whether cleanup is wanted, then closes the working issue (if objectives met) and deletes the working branch (only if its PR was merged; asks user if no PR or unmerged)
- **`post-mortem-analyst`**: Reviews the full workflow conversation + git history + agent timeline for errors, dead ends, rework loops; identifies improvement opportunities; reports findings back to the user, then asks which fixes should be tracked as follow-up issues (never creates issues or PRs without explicit user request)

Both new agents live in `opencode/.config/opencode/agents/common/` (shared across dev/devops pipelines) and follow the same handover protocol as other agents.

**Deleted agents:** `dev-engineer` (coordinator/integrator role removed — integration check now done by dev-team-lead), `issue-refiner`, and `devops-investigator` have been removed; their investigative work is consolidated into the `researcher` subagent. (`researcher` is **not** deleted — it is a current, active subagent of `team-lead`.)

**Post-edit stale-reference scan:** After changing an agent's behavior (e.g. `post-mortem-analyst` from auto-create to ask-first), grep all agent `.md` files under `opencode/.config/opencode/agents/` for stale references to the changed agent's old behavior. Flag any file that still references the old behavior and update it before considering the edit complete.

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

## Tool call discipline

These rules govern how tools are invoked across the repo to prevent silent failures, wasted cycles, and output thrash.

### Empty task() dispatch results

Any agent that dispatches via `task()` must verify the returned result is **non-empty** before acting on it. An empty result is not a valid outcome — it indicates the dispatched agent produced no usable output.

If a `task()` result is empty, return `[STUCK]` with:
- The dispatch prompt that was sent
- The session ID of the dispatched agent
- The timestamp when the empty result was received

Do NOT treat an empty result as success, do NOT synthesize or forward it, and do NOT continue downstream on it. Surface it immediately and offer re-dispatch (`task_id` resume) or hand back to the caller.

This rule is enforced in the workflow of every agent that dispatches `task()`: `team-lead`, `dev-team-lead`, `devops-team-lead`, and `post-mortem-analyst`.

### rtk find loop prevention

`rtk find` filters and hides results by default. When the filtered output is uninformative, repeating the command produces identical filtered output indefinitely — a loop that wastes cycles without gaining information.

**Rule:** If `rtk find` returns filtered/hidden results **twice in a row**, stop repeating it. Switch to read-based directory exploration using the `Read` or `Glob` tools instead. The `Read`/`Glob` tools do not apply rtk's filter layer and will surface the actual files on disk.

Do not run `rtk find` a third time after two consecutive filtered/hidden results. Break the loop by exploring the directory tree directly.

### General guidance

- Prefer the dedicated tools (`Read`, `Glob`, `Grep`, `Edit`, `Write`) over raw shell commands (`cat`, `grep`, `find`, `head`, `tail`, `sed`, `awk`, `echo`) for file operations.
- When a shell command is genuinely needed, capture its output and verify it is meaningful before repeating it with the same arguments.
