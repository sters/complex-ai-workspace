#!/bin/bash
set -euo pipefail

# List all repository worktrees in a workspace
# Usage: list-workspace-repos.sh <workspace-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <workspace-name>" >&2
    exit 1
fi

WORKSPACE_NAME="$1"
WORKSPACE_PATH="$PROJECT_ROOT/workspace/$WORKSPACE_NAME"

if [[ ! -d "$WORKSPACE_PATH" ]]; then
    echo "Workspace not found: $WORKSPACE_NAME" >&2
    exit 1
fi

# Find repository directories (directories containing .git or are git worktrees)
# Exclude hidden directories and known non-repo directories
find "$WORKSPACE_PATH" -mindepth 2 -maxdepth 4 -type d -name ".git" 2>/dev/null | while read -r gitdir; do
    repo_path="$(dirname "$gitdir")"
    # Output relative path from workspace
    echo "${repo_path#$WORKSPACE_PATH/}"
done | sort
