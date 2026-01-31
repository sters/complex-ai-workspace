#!/bin/bash
# Create or update a pull request
# Usage: create-or-update-pr.sh <repo-path> <title> <body-file> [--no-draft]
# Output: "created" or "updated" on first line, PR URL on second line

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_PATH="$1"
TITLE="$2"
BODY_FILE="$3"
NO_DRAFT="$4"

if [ -z "$REPO_PATH" ] || [ -z "$TITLE" ] || [ -z "$BODY_FILE" ]; then
    echo "Error: Repository path, title, and body file are required" >&2
    echo "Usage: $0 <repo-path> <title> <body-file> [--no-draft]" >&2
    exit 1
fi

if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository path not found: $REPO_PATH" >&2
    exit 1
fi

if [ ! -f "$BODY_FILE" ]; then
    echo "Error: Body file not found: $BODY_FILE" >&2
    exit 1
fi

cd "$REPO_PATH"

# Push current branch if needed
CURRENT_BRANCH=$(git branch --show-current)
if ! git ls-remote --exit-code --heads origin "$CURRENT_BRANCH" >/dev/null 2>&1; then
    echo "Pushing branch to remote..." >&2
    git push -u origin "$CURRENT_BRANCH"
else
    # Branch exists, push any new commits
    git push origin "$CURRENT_BRANCH" 2>/dev/null || true
fi

# Check if PR already exists
CHECK_RESULT=$("$SCRIPT_DIR/check-existing-pr.sh" "$REPO_PATH" 2>/dev/null || echo "none")
PR_EXISTS=$(echo "$CHECK_RESULT" | head -n1)

if [ "$PR_EXISTS" = "exists" ]; then
    # Update existing PR
    PR_URL=$("$SCRIPT_DIR/update-pr.sh" "$REPO_PATH" "$TITLE" "$BODY_FILE")
    echo "updated"
    echo "$PR_URL"
else
    # Create new PR
    PR_URL=$("$SCRIPT_DIR/create-pr.sh" "$REPO_PATH" "$TITLE" "$BODY_FILE" "$NO_DRAFT")
    echo "created"
    echo "$PR_URL"
fi
