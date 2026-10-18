#!/usr/bin/env bash
# scripts/check-readme-sync.sh
#
# Keeps opencode/.config/opencode/agents/readme.html in sync with the agent .md files.
#
# The readme lists agents on three surfaces, and this checks each against disk:
#   1. the folder-tree block          — must list EVERY agent (the canonical inventory)
#   2. data-agent="..." attributes    — the clickable pipeline agents
#   3. the JS "agents" object         — blurbs for the clickable agents
#
# Surface 1 is the completeness invariant: if an agent .md is added, removed, or
# renamed and the tree is not updated, this fails. Surfaces 2 and 3 are checked for
# staleness only — the on-demand auditors and ontology agents are deliberately
# non-clickable (outside the team-lead chain), so they are not required there.
#
# Also fails if any .md reference, data-agent attribute, or JS object key points at
# an agent that does not exist on disk.
#
# Exit codes: 0 = in sync, 1 = drift found, 2 = config error.
#
# Usage: ./scripts/check-readme-sync.sh

set -euo pipefail

AGENTS_DIR="${AGENTS_DIR:-opencode/.config/opencode/agents}"
README="${README:-$AGENTS_DIR/readme.html}"

if [[ ! -d "$AGENTS_DIR" ]]; then
    echo "Error: agents directory not found at $AGENTS_DIR" >&2
    exit 2
fi
if [[ ! -f "$README" ]]; then
    echo "Error: readme not found at $README" >&2
    exit 2
fi

# --- every agent .md on disk (top-level + ontology), basename without extension ---
disk=$( (ls "$AGENTS_DIR"/*.md "$AGENTS_DIR"/ontology/*.md 2>/dev/null || true) \
    | xargs -n1 basename | sed 's/\.md$//' | sort -u )

# --- surface 1: the folder-tree block must list every agent ---
tree=$( sed -n '/<pre class="folders">/,/<\/pre>/p' "$README" \
    | grep -oE '[a-z][a-z-]*\.md' | sed 's/\.md$//' | sort -u )

# --- every agent referenced anywhere in the readme (.md refs, data-agent, JS keys) ---
all_refs=$( grep -oE '[a-z][a-z-]*\.md|data-agent="[a-z-]+"|"[a-z-]+": \{' "$README" \
    | sed -E 's/\.md$//; s/data-agent="//; s/"//g; s/: \{$//' \
    | sort -u )

# Non-agent tokens that may legitimately appear: the readme itself, the Approval Gate entry.
allowlist='^readme\.html$|^__.*__$'

rc=0

missing_from_tree=$( comm -23 <(echo "$disk") <(echo "$tree") )
if [[ -n "$missing_from_tree" ]]; then
    echo "FAIL: agents on disk but missing from the readme folder tree:"
    echo "$missing_from_tree" | sed 's/^/  - /'
    echo "      Add them to the <pre class=\"folders\"> block in readme.html."
    rc=1
fi

stale_refs=$( comm -13 <(echo "$disk") <(echo "$all_refs") | grep -vE "$allowlist" || true )
if [[ -n "$stale_refs" ]]; then
    echo "FAIL: references in readme.html with no matching agent file:"
    echo "$stale_refs" | sed 's/^/  - /'
    rc=1
fi

if [[ $rc -eq 0 ]]; then
    n=$( echo "$disk" | wc -l | tr -d ' ' )
    echo "OK: readme.html is in sync — $n agents on disk, all present in the folder tree, no stale references."
fi

exit $rc