#!/bin/bash

set -e

# Usage: ./commit-workspace-snapshot.sh <workspace-name> [message]
# Example: ./commit-workspace-snapshot.sh feature-auth-20260130
# Example: ./commit-workspace-snapshot.sh feature-auth-20260130 "Custom message"
#
# Commits changes to README.md, TODO-*.md, and reviews/ in the workspace git repository.
# Auto-generates commit message based on TODO progress if not provided.

WORKSPACE_NAME="$1"
CUSTOM_MESSAGE="$2"

if [ -z "$WORKSPACE_NAME" ]; then
    echo "Usage: $0 <workspace-name> [message]"
    echo "Example: $0 feature-auth-20260130"
    exit 1
fi

WORKSPACE_DIR="workspace/${WORKSPACE_NAME}"

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "Error: Workspace directory not found: $WORKSPACE_DIR"
    exit 1
fi

cd "$WORKSPACE_DIR"

# Check if workspace is a git repository
if [ ! -d ".git" ]; then
    echo "Error: Workspace is not a git repository: $WORKSPACE_DIR"
    echo "Hint: Re-initialize the workspace or run git init manually"
    exit 1
fi

# Check for changes
if git diff --quiet HEAD -- README.md TODO-*.md reviews/ 2>/dev/null && \
   git diff --cached --quiet -- README.md TODO-*.md reviews/ 2>/dev/null && \
   [ -z "$(git ls-files --others --exclude-standard README.md TODO-*.md reviews/ 2>/dev/null)" ]; then
    echo "No changes to commit"
    exit 0
fi

# Stage changes
git add README.md TODO-*.md 2>/dev/null || true
git add reviews/ 2>/dev/null || true

# Check if there are staged changes
if git diff --cached --quiet; then
    echo "No changes to commit"
    exit 0
fi

# Generate commit message if not provided
if [ -z "$CUSTOM_MESSAGE" ]; then
    # Count TODO items
    TOTAL_ITEMS=0
    COMPLETED_ITEMS=0

    for TODO_FILE in TODO-*.md; do
        if [ -f "$TODO_FILE" ]; then
            # Count lines matching "- [ ]" (incomplete) and "- [x]" (complete)
            INCOMPLETE=$(grep -c '^\s*- \[ \]' "$TODO_FILE" 2>/dev/null) || INCOMPLETE=0
            COMPLETE=$(grep -c '^\s*- \[x\]' "$TODO_FILE" 2>/dev/null) || COMPLETE=0
            TOTAL_ITEMS=$((TOTAL_ITEMS + INCOMPLETE + COMPLETE))
            COMPLETED_ITEMS=$((COMPLETED_ITEMS + COMPLETE))
        fi
    done

    # Check if reviews were added/updated
    REVIEWS_CHANGED=""
    if git diff --cached --name-only | grep -q "^reviews/"; then
        REVIEWS_CHANGED=" | reviews updated"
    fi

    if [ "$TOTAL_ITEMS" -gt 0 ]; then
        CUSTOM_MESSAGE="Snapshot: ${COMPLETED_ITEMS}/${TOTAL_ITEMS} TODO items completed${REVIEWS_CHANGED}"
    else
        CUSTOM_MESSAGE="Snapshot: workspace updated${REVIEWS_CHANGED}"
    fi
fi

# Commit
git commit -m "$CUSTOM_MESSAGE"

echo "Committed: $CUSTOM_MESSAGE"
