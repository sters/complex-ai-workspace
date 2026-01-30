#!/bin/bash

set -e

# Usage: ./show-workspace-history.sh <workspace-path> [--full]
# Example: ./show-workspace-history.sh workspace/feature-auth-20260130
# Example: ./show-workspace-history.sh workspace/feature-auth-20260130 --full
#
# Shows git history of the workspace (README/TODO changes over time).
# Use --full to show detailed diff for each commit.

WORKSPACE_PATH="$1"
SHOW_FULL="$2"

if [ -z "$WORKSPACE_PATH" ]; then
    echo "Usage: $0 <workspace-path> [--full]"
    echo "Example: $0 workspace/feature-auth-20260130"
    exit 1
fi

# Resolve to absolute path
if [[ "$WORKSPACE_PATH" != /* ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
    WORKSPACE_PATH="$WORKSPACE_ROOT/$WORKSPACE_PATH"
fi

if [ ! -d "$WORKSPACE_PATH" ]; then
    echo "Error: Workspace directory not found: $WORKSPACE_PATH"
    exit 1
fi

cd "$WORKSPACE_PATH"

# Check if workspace is a git repository
if [ ! -d ".git" ]; then
    echo "Error: Workspace is not a git repository"
    echo "This workspace was created before git tracking was enabled."
    exit 1
fi

WORKSPACE_NAME=$(basename "$WORKSPACE_PATH")
echo "=== Workspace History: $WORKSPACE_NAME ==="
echo ""

# Show current TODO status
echo "--- Current Status ---"
for TODO_FILE in TODO-*.md; do
    if [ -f "$TODO_FILE" ]; then
        INCOMPLETE=$(grep -c '^\s*- \[ \]' "$TODO_FILE" 2>/dev/null) || INCOMPLETE=0
        COMPLETE=$(grep -c '^\s*- \[x\]' "$TODO_FILE" 2>/dev/null) || COMPLETE=0
        TOTAL=$((INCOMPLETE + COMPLETE))
        echo "$TODO_FILE: ${COMPLETE}/${TOTAL} completed"
    fi
done
echo ""

# Show commit history
echo "--- Commit History ---"
if [ "$SHOW_FULL" = "--full" ]; then
    git log --pretty=format:"%h %ad | %s" --date=short --stat
else
    git log --pretty=format:"%h %ad | %s" --date=short
fi
echo ""
