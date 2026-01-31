#!/bin/bash
# Read PR template from repository
# Usage: read-pr-template.sh <repo-path>
# Output: Template content if found, empty if not found
# Exit code: 0 if found, 1 if not found

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

# Search for PR template (direct file check is faster than find)
# Priority: .github > docs > root
for template in \
    ".github/PULL_REQUEST_TEMPLATE.md" \
    ".github/pull_request_template.md" \
    ".github/PULL_REQUEST_TEMPLATE/default.md" \
    ".github/pull_request_template/default.md" \
    "docs/PULL_REQUEST_TEMPLATE.md" \
    "docs/pull_request_template.md" \
    "PULL_REQUEST_TEMPLATE.md" \
    "pull_request_template.md"; do
    if [ -f "$template" ]; then
        cat "$template"
        exit 0
    fi
done

# No template found, use default
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_TEMPLATE="${SCRIPT_DIR}/../../templates/workspace-repo-create-pr/default-pr-template.md"

if [ -f "$DEFAULT_TEMPLATE" ]; then
    cat "$DEFAULT_TEMPLATE"
    exit 0
fi

# Fallback if default template is missing
echo "Error: Default template not found: $DEFAULT_TEMPLATE" >&2
exit 1
