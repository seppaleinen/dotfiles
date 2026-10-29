# dotfiles

Managed with GNU Stow. Symlinked to `~` on install.

## Install

```bash
git clone git@github.com:seppaleinen/dotfiles.git ~/dotfiles  # if not done already
cd ~/dotfiles
stow -t ~ zsh opencode agents
sops -d secrets/secrets.zsh > ~/.secrets.zsh
```

## Onboarding a new machine (via Ansible)

The recommended path: let Ansible handle it. Ansible clones + stows dotfiles for you.

```bash
ansible-playbook playbook.yml --limit <host> --ask-become-pass
```

This installs system packages, k3s, the SOPS age key, GNU Stow, and
clones + stows dotfiles from `seppaleinen/dotfiles` (see `group_vars/all.yaml`
for the `dotfiles_packages` list).

## Manual install (if skipping Ansible)

```bash
git clone git@github.com:seppaleinen/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ zsh opencode agents
sops -d secrets/secrets.zsh > ~/.secrets.zsh
```

## Verify after Ansible run

```bash
stow -n -t ~ zsh opencode agents secrets   # dry-run check
source ~/.zshrc
```

## Commands

| Command | Description |
|---|---|
| `stow -t ~ <name>` | Symlink `<name>/` into `~` |
| `stow -D -t ~ <name>` | Remove symlinks for `<name>` |
| `stow -n -t ~ <name>` | Dry run (preview without creating) |
| `stow -t ~ <name> --verbose=1` | Check for existing conflicts |

## Loop Orchestrator

The `loop-orchestrator` agent runs the GitHub issue queue unattended — up to 3 hours or 10 tasks, whichever comes first. It dispatches `team-lead` for each issue, comments on GitHub instead of asking in chat, and runs `post-mortem-analyst` after each task.

**Start it:**
```bash
opencode mini --agent loop-orchestrator --model freellmapi
```

Then type `dry run` (to preview) or `start the loop` (to run).

**What it does:**
- Picks open issues in priority→bug→oldest order, skipping `wontfix`/`duplicate`/`waiting`/`needs-input`
- Skips issues where the agent commented last (avoids re-processing its own work)
- Asks for one approval on the loop config, then runs autonomously within budget
- Comments on issues when blocked, instead of stopping the loop
- Stops on: queue empty, 3 hours elapsed, 10 tasks done, or max reworks reached

**Dry run first:**
```bash
opencode --agent loop-orchestrator
# Then say: "dry run"
```
This shows what the loop would pick without dispatching anything.

**Config:** `opencode/.config/opencode/loop-config.json` — max wall clock, max tasks, label tiers, skip labels.

**State:** `.opencode/loop-state.json` tracks tasks run, blocked issues, and stop reason. Restart in the same repo to continue where it left off.

**One repo per loop.** Start a separate session in each repo you want to loop.

## Important

1. **The source of truth is this repo.** Always edit files here, not through the symlink path at `~/.config/`.
2. **Re-cloning requires re-stowing.** On a new machine: clone, `stow -t ~ opencode`.
3. **One stow per folder.** Each subdirectory of this repo is its own stow target (`stow -t ~ opencode`).
4. **Dry-run first** after cloning to catch conflicts: `stow -n -t ~ opencode`.
5. `.gitignore` handles `node_modules/` and `.DS_Store` — stow skips those automatically.
