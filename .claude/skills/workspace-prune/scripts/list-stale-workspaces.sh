#!/bin/bash
# List stale workspaces (not modified within specified days)
# Usage: list-stale-workspaces.sh [days]
# Default: 7 days

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)/workspace"
DAYS="${1:-7}"

if [[ ! -d "$WORKSPACE_DIR" ]]; then
    echo "No workspaces found"
    exit 0
fi

# Use find with -mtime for speed (directories modified more than N days ago)
stale=$(find "$WORKSPACE_DIR" -maxdepth 1 -mindepth 1 -type d -mtime +"$DAYS" 2>/dev/null | sort)

if [[ -z "$stale" ]]; then
    echo "No stale workspaces found (threshold: $DAYS days)"
    exit 0
fi

# Process all at once: get mtime and format output (faster than per-item stat)
echo "$stale" | while IFS= read -r ws; do
    # Use stat -f to get mtime and format in one call
    stat -f "workspace/%N/ (%Sm)" -t "%Y-%m-%d" "$ws" 2>/dev/null | sed 's|.*/\([^/]*\)/ |\1/ |'
done
