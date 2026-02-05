#!/bin/bash
# Update an existing pull request
# Usage: update-pr.sh <repo-path> <title> <body-file>
# Output: PR URL

set -e

REPO_PATH="$1"
TITLE="$2"
BODY_FILE="$3"

if [ -z "$REPO_PATH" ] || [ -z "$TITLE" ] || [ -z "$BODY_FILE" ]; then
    echo "Error: Repository path, title, and body file are required" >&2
    echo "Usage: $0 <repo-path> <title> <body-file>" >&2
    exit 1
fi

cd "$REPO_PATH"

# Update PR title and body
gh pr edit --title "$TITLE" --body-file "$BODY_FILE"

# Output PR URL
gh pr view --json url --jq '.url'
