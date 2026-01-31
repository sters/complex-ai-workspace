#!/bin/bash
set -euo pipefail

# List all TODO files in a workspace
# Usage: list-workspace-todos.sh <workspace-name>

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

# Find TODO-*.md files in the workspace root (ls + sed faster than loop + basename)
ls -1 "$WORKSPACE_PATH"/TODO-*.md 2>/dev/null | sed 's|.*/||' | sort
