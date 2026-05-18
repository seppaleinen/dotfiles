# dotfiles

Managed with GNU Stow. Symlinked to `~` on install.

## Install

```bash
git clone <repo-url> ~/dotfiles  # if not done already
cd ~/dotfiles
stow -t ~ opencode
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
