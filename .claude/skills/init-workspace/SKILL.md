---
name: init-workspace
description: Initialize a working directory for development tasks
---

# init-workspace

## Overview

This skill helps you initialize a working environment for development tasks using an automated setup script.

**After initialization:** Use `/execute-workspace` to work through TODO items and complete the task.

## Steps

### 1. Understand the Task Requirements

Before running the setup script, ensure you have:

- Task type (feature, bugfix, research, etc.)
- Brief description
- Target repository path in org/repo format (e.g., github.com/sters/complex-ai-workspace)
- Ticket ID (optional)

**Note:** Base branch is automatically detected from the remote default (main/master). You don't need to specify it.

### 2. Run Setup Script

Execute the setup script with the required parameters:

```bash
./.claude/skills/init-workspace/scripts/setup-workspace.sh <task-type> <description> <org/repo-name> [ticket-id]
```

**Examples:**

```bash
# Basic usage - base branch is auto-detected
./.claude/skills/init-workspace/scripts/setup-workspace.sh feature user-auth github.com/sters/complex-ai-workspace

# With ticket ID
./.claude/skills/init-workspace/scripts/setup-workspace.sh feature user-auth github.com/sters/complex-ai-workspace PROJ-123

# Bug fix
./.claude/skills/init-workspace/scripts/setup-workspace.sh bugfix login-error github.com/sters/complex-ai-workspace

# Research task
./.claude/skills/init-workspace/scripts/setup-workspace.sh research performance-analysis github.com/sters/complex-ai-workspace

# Override base branch - use when the user explicitly specifies a branch
BASE_BRANCH=develop ./.claude/skills/init-workspace/scripts/setup-workspace.sh feature user-auth github.com/sters/complex-ai-workspace
```

The script will automatically:

- Create a working directory with proper naming convention
- Clone or update the target repository
- Create a git worktree in the working directory
- Generate README.md with task template
- Generate `TODO-<repository-name>.md` with task-specific checklist

### 3. Customize Documentation

After setup completes:

- Open the generated `README.md` and fill in task details
- Review and customize `TODO-<repository-name>.md` checklist as needed

## Example Usage

### Example 1: Basic Feature

```
User: Initialize a workspace for user authentication feature in github.com/org/repo
Assistant: [Runs setup script with task-type=feature, description=user-auth]
Workspace created: workspace/feature-user-auth-20260116
```

### Example 2: Bug Fix with Ticket

```
User: Create a workspace to fix login bug, ticket PROJ-123, in github.com/org/repo
Assistant: [Runs setup script with task-type=bugfix, ticket-id=PROJ-123]
Workspace created: workspace/bugfix-PROJ-123-login-fix-20260116
```

### Example 3: With Specific Branch

```
User: Initialize workspace for feature X based on develop branch
Assistant: [Runs setup script with BASE_BRANCH=develop]
```

## Next Steps - Ask User to Proceed

After initialization is complete, **always ask the user** whether to proceed with the next step using AskUserQuestion:

```yaml
AskUserQuestion tool:
  questions:
    - question: "Workspace initialization complete. Would you like to proceed with executing the TODO items?"
      header: "Next Step"
      multiSelect: false
      options:
        - label: "Execute now"
          description: "Run /execute-workspace to work through TODO items immediately"
        - label: "Skip for now"
          description: "I'll review the workspace files first and execute later"
```

If the user selects "Execute now", invoke the `/execute-workspace` skill using the Skill tool.

## Notes

- Base branch is auto-detected from remote default unless explicitly specified
- The setup script creates both README.md and TODO file from templates
- Workspace naming convention: `{task-type}-{ticket-id}-{description}-{date}` or `{task-type}-{description}-{date}`
