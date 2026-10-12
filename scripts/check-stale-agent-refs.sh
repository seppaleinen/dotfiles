#!/usr/bin/env bash
# scripts/check-stale-agent-refs.sh
# Greps all agent .md files for patterns matching a changed agent's old description.
# Exits 0 if clean, 1 with file list if stale references found.
# Usage: ./scripts/check-stale-agent-refs.sh "old description pattern" [agent-file-name.md]

set -euo pipefail

AGENTS_DIR="${AGENTS_DIR:-opencode/.config/opencode/agents}"
PATTERN="${1:-}"
TARGET_AGENT="${2:-}"

if [[ -z "$PATTERN" ]]; then
    echo "Usage: $0 \"old description pattern\" [agent-file-name.md]"
    echo "Example: $0 \"Auto-create a follow-up issue\" post-mortem-analyst.md"
    exit 1
fi

if [[ ! -d "$AGENTS_DIR" ]]; then
    echo "Error: Agents directory not found at $AGENTS_DIR" >&2
    exit 1
fi

# Build the file list
if [[ -n "$TARGET_AGENT" ]]; then
    FILES=("$AGENTS_DIR/$TARGET_AGENT")
else
    FILES=("$AGENTS_DIR"/*.md)
fi

# Check each file
FOUND=0
for file in "${FILES[@]}"; do
    [[ -f "$file" ]] || continue
    if grep -q "$PATTERN" "$file"; then
        echo "Stale reference found in: $file"
        grep -n "$PATTERN" "$file" | head -5
        FOUND=1
    fi
done

if [[ $FOUND -eq 1 ]]; then
    echo ""
    echo "FAIL: Stale references to pattern \"$PATTERN\" found in agent files above."
    exit 1
else
    echo "OK: No stale references to pattern \"$PATTERN\" found."
    exit 0
fi