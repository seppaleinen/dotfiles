#!/usr/bin/env bash
# scripts/filter-worktree-noise.sh
#
# Filters out herdr/opencode-managed file changes from git status for cleaner verification gates.
#
# Usage: ./scripts/filter-worktree-noise.sh [--verbose]
#
# These files are NOT part of task deliverables:
# - herdr-tui-session.js (managed by herdr integration)
# - herdr-agent-state.js (managed by herdr plugin integration)
# - opencode.json changes (configuration drift, not tasks)
# - node_modules/ directories
# - .agents/archive/ directory
# - Unmatched skill/ plugin directories (herdr creates these)
#
# Exit codes:
# 0 = clean working tree (ignoring noise)
# 1 = actual work present
# 2 = error

set -euo pipefail

VERBOSE=false
if [[ "${1:-}" == "--verbose" ]]; then
  VERBOSE=true
fi

# Run git status
raw_status=$(git status --short 2>/dev/null || echo "")

if [[ -z "$raw_status" ]]; then
  # Empty status = clean
  if $VERBOSE; then
    echo "Working tree is clean (no changes in any category)"
  fi
  exit 0
fi

# Filter out known noise patterns
# Pattern format: status + tab + path
filtered=()
noise=()

while IFS= read -r line; do
  # Extract status and path
  status="${line:0:2}"
  path="${line:3}"
  
  # Check if this is noise
  is_noise=false
  
  # Herdr-managed files (version bump comments)
  if [[ "$path" == *"herdr-tui-session.js" ]] || [[ "$path" == *"herdr-agent-state.js" ]]; then
    is_noise=true
  fi
  
  # Unstaged config changes that are automated
  if [[ "$path" == "opencode/.config/opencode/opencode.json" ]]; then
    is_noise=true
  fi
  
  # Node modules (gitignored but check anyway)
  if [[ "$path" == node_modules* ]] || [[ "$path" == "*/node_modules/"* ]]; then
    is_noise=true
  fi
  
  # Archive directory
  if [[ "$path" == ".agents/archive"* ]]; then
    is_noise=true
  fi
  
  # Untracked skill/plugin directories (herdr creates these)
  if [[ -n "$status" == "??" ]] && [[ "$path" == "opencode/.config/opencode/skills/"* ]] && [[ ! -f "$path" ]]; then
    is_noise=true
  fi
  if [[ -n "$status" == "??" ]] && [[ "$path" == "opencode/.config/opencode/plugins/"* ]] && [[ ! -f "$path" ]]; then
    is_noise=true
  fi
  
  # .gitignore (often updated by tooling)
  if [[ "$path" == ".gitignore" ]]; then
    is_noise=true
  fi
  
  if $is_noise; then
    noise+=("$line")
  else
    filtered+=("$line")
  fi
done <<< "$raw_status"

# Report results
if $VERBOSE; then
  if [[ ${#noise[@]} -gt 0 ]]; then
    echo "=== Noise (ignored in verification) ==="
    for line in "${noise[@]}"; do
      echo "  $line"
    done
    echo ""
  fi
fi

if [[ ${#filtered[@]} -gt 0 ]]; then
  if $VERBOSE; then
    echo "=== Actual work present (would block SUCCESS) ==="
    for line in "${filtered[@]}"; do
      echo "  $line"
    done
  else
    echo "Uncommitted changes present (not from task deliverables)"
  fi
  exit 1
else
  if $VERBOSE; then
    if [[ ${#noise[@]} -gt 0 ]]; then
      echo "Working tree is clean (ignoring ${#noise[@]} noise entries)"
    else
      echo "Working tree is clean"
    fi
  else
    echo "Working tree clean (ignoring noise)"
  fi
  exit 0
fi