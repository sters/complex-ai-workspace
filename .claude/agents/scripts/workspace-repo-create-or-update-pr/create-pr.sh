#!/bin/bash
# Create a pull request (assumes branch is already pushed)
# Usage: create-pr.sh <repo-path> <title> <body-file> [--no-draft]
# Output: PR URL

set -e

REPO_PATH="$1"
TITLE="$2"
BODY_FILE="$3"
NO_DRAFT="$4"

if [ -z "$REPO_PATH" ] || [ -z "$TITLE" ] || [ -z "$BODY_FILE" ]; then
    echo "Error: Repository path, title, and body file are required" >&2
    echo "Usage: $0 <repo-path> <title> <body-file> [--no-draft]" >&2
    exit 1
fi

cd "$REPO_PATH"

# Build gh pr create command
DRAFT_FLAG="--draft"
if [ "$NO_DRAFT" = "--no-draft" ]; then
    DRAFT_FLAG=""
fi

# Create PR
gh pr create $DRAFT_FLAG --title "$TITLE" --body-file "$BODY_FILE"
