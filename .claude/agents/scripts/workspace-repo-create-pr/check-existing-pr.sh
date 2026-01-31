#!/bin/bash
# Check if a PR already exists for the current branch
# Usage: check-existing-pr.sh <repo-path>
# Output: PR URL if exists, empty if not
# Exit code: 0 if PR exists, 1 if not

set -e

REPO_PATH="$1"

if [ -z "$REPO_PATH" ]; then
    echo "Error: Repository path is required" >&2
    echo "Usage: $0 <repo-path>" >&2
    exit 2
fi

if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository path not found: $REPO_PATH" >&2
    exit 2
fi

cd "$REPO_PATH"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if PR exists for current branch
if PR_URL=$(gh pr view "$CURRENT_BRANCH" --json url --jq '.url' 2>/dev/null); then
    echo "exists"
    echo "$PR_URL"
    exit 0
else
    echo "none"
    exit 1
fi
