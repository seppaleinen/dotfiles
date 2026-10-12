# dotfiles

Managed with GNU Stow. Symlinked to `~` on install.

## Install

```bash
git clone git@github.com:seppaleinen/dotfiles.git ~/dotfiles  # if not done already
cd ~/dotfiles
stow -t ~ zsh opencode agents secrets
```

## Onboarding a new machine

1. **Provision** with Ansible (`fleet-infra/machine-setup`):
   ```bash
   ansible-playbook playbook.yml --limit <host> --ask-become-pass
   ```
2. **Install dotfiles** with GNU Stow:
   ```bash
   git clone git@github.com:seppaleinen/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow -t ~ zsh opencode agents secrets
   ```
3. **Decrypt secrets**:
   ```bash
   sops -d secrets/secrets.zsh > ~/.secrets.zsh
   ```

## Commands

| Command | Description |
|---|---|
| `stow -t ~ <name>` | Symlink `<name>/` into `~` |
| `stow -D -t ~ <name>` | Remove symlinks for `<name>` |
| `stow -n -t ~ <name>` | Dry run (preview without creating) |
| `stow -t ~ <name> --verbose=1` | Check for existing conflicts |

## Important

1. **The source of truth is this repo.** Always edit files here, not through the symlink path at `~/.config/`.
2. **Re-cloning requires re-stowing.** On a new machine: clone, `stow -t ~ opencode`.
3. **One stow per folder.** Each subdirectory of this repo is its own stow target (`stow -t ~ opencode`).
4. **Dry-run first** after cloning to catch conflicts: `stow -n -t ~ opencode`.
5. `.gitignore` handles `node_modules/` and `.DS_Store` — stow skips those automatically.
