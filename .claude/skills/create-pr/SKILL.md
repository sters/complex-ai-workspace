---
name: create-pr
description: Create a pull request following the repository's PR template
---

# create-pr

## Overview

This skill creates a pull request while respecting the repository's PR template. It ensures consistent PR formatting across all repositories.

## Steps

### 1. Check for PR Template

Before creating a PR, search for a PR template in the repository. Check these locations in order:

```bash
# Common PR template locations
.github/PULL_REQUEST_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE/default.md
.github/pull_request_template.md
docs/PULL_REQUEST_TEMPLATE.md
PULL_REQUEST_TEMPLATE.md
```

Use glob to find templates:
```bash
# Find any PR template files
find . -iname "*pull_request_template*" -type f 2>/dev/null
```

### 2. Read and Understand the Template

If a template is found:
- Read the template file
- Understand the required sections
- Note any checkboxes or required fields

If no template is found:
- Use the default format (see below)

### 3. Gather PR Information

Collect the following information:
- **Title**: Concise summary of changes
- **Summary**: What was changed and why
- **Test plan**: How the changes were tested
- **Related issues**: Any linked tickets or issues

Run these commands to understand the changes:
```bash
git log origin/<base-branch>..HEAD --oneline
git diff origin/<base-branch>..HEAD --stat
```

### 4. Create the Pull Request

Use `gh pr create` with the template format:

```bash
gh pr create --title "Title here" --body "$(cat <<'EOF'
<PR body following template format>
EOF
)"
```

**If template exists**: Fill in all template sections appropriately.

**If no template**: Use this default format:
```markdown
## Summary
<1-3 bullet points describing what changed>

## Test plan
<How the changes were tested>

## Related issues
<Links to related issues/tickets, or "N/A">
```

### 5. Verify PR Creation

After creating the PR:
- Confirm the PR URL is returned
- Verify the PR appears correctly on GitHub

## Usage by Sub-Agents

Sub-agents (like `workspace-repo-todo-executor`) should follow this skill when creating PRs:

1. Before calling `gh pr create`, check for PR templates
2. Read the template if found
3. Format the PR body according to the template
4. Create the PR with properly formatted content

## Example

```bash
# Step 1: Find template
TEMPLATE=$(find . -iname "*pull_request_template*" -type f 2>/dev/null | head -1)

# Step 2: Read template (if exists)
if [ -n "$TEMPLATE" ]; then
    cat "$TEMPLATE"
fi

# Step 3: Gather info
git log origin/main..HEAD --oneline
git diff origin/main..HEAD --stat

# Step 4: Create PR (example with template sections)
gh pr create --title "feat: Add user authentication" --body "$(cat <<'EOF'
## Summary
- Added JWT-based authentication
- Implemented login/logout endpoints
- Added middleware for protected routes

## Test plan
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual testing completed

## Related issues
Closes #123
EOF
)"
```
