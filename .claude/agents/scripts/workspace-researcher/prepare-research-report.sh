#!/bin/bash
# Prepare research report from template
# Usage: prepare-research-report.sh <workspace-name>
# Output: Path to the created research report file

set -e

WORKSPACE_NAME="$1"

if [ -z "$WORKSPACE_NAME" ]; then
    echo "Error: Workspace name is required" >&2
    echo "Usage: $0 <workspace-name>" >&2
    exit 1
fi

ARTIFACTS_DIR="workspace/${WORKSPACE_NAME}/artifacts"

if [ ! -d "$ARTIFACTS_DIR" ]; then
    echo "Error: Artifacts directory not found: $ARTIFACTS_DIR" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/../../templates/workspace-researcher/research-report.md"

REPORT_FILE="${ARTIFACTS_DIR}/research-report.md"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found: $TEMPLATE" >&2
    exit 1
fi

cp "$TEMPLATE" "$REPORT_FILE"

echo "$REPORT_FILE"
