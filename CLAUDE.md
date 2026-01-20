# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a multi-repository workspace manager for Claude Code. It enables complex tasks across multiple repositories using git worktrees for isolation. The system uses skills and sub-agents to orchestrate work.

## Primary Workflow

```
/init-workspace {task-description}
```

This skill:
1. Creates `workspace/{task-type}-{description}-{date}/` directory
2. Clones or updates target repositories
3. Creates git worktrees for isolated work
4. Generates README.md and TODO-{repo-name}.md templates

After initialization, use:
```
/execute-workspace
```

This skill:
1. Works through TODO items in the workspace
2. Delegates to `workspace-repo-todo-executor` agent for execution
3. Verifies completion (tests, lints, commits)

## Directory Structure

```
.
├── .claude/
│   ├── agents/                 # Sub-agent definitions
│   │   ├── workspace-repo-todo-executor.md    # Executes TODO items
│   │   └── review-workspace-repo-changes.md   # Code review agent
│   ├── skills/                 # User-invokable skills
│   │   ├── init-workspace/     # Workspace initialization
│   │   ├── execute-workspace/  # Task execution
│   │   ├── create-pr/          # PR creation with template
│   │   └── review-workspace-changes/
│   └── settings.local.json     # Allowed bash commands
├── repositories/               # Cloned repos (git data source)
└── workspace/                  # Active task directories (worktrees)
    └── {task-name}-{date}/
        ├── README.md           # Task context
        ├── TODO-{repo}.md      # Task checklist
        └── {org}/{repo}/       # Git worktree
```

## Skills & Agents

### Skills (User-invokable)

- **init-workspace**: Initialize workspace directory and setup git worktrees
- **execute-workspace**: Execute tasks in an initialized workspace
- **create-pr**: Create a pull request following the repository's PR template
- **review-workspace-changes**: Review all changes across workspace repositories

### Sub-Agents (System-invoked)

- **workspace-repo-todo-executor**: Autonomous TODO executor that works through checklist items, runs tests/linters, and commits changes
- **review-workspace-repo-changes**: Performs code review comparing current branch against remote base branch

## Setup Script

```bash
./.claude/skills/init-workspace/scripts/setup-workspace.sh <task-type> <description> <org/repo> [base-branch] [ticket-id]

# Examples:
./.claude/skills/init-workspace/scripts/setup-workspace.sh feature user-auth github.com/org/repo
./.claude/skills/init-workspace/scripts/setup-workspace.sh bugfix login-error github.com/org/repo main PROJ-123
```

## Managed Repository Types

The workspace manages several repository types with different tech stacks:

| Stack | Build | Test | Lint |
|-------|-------|------|------|
| Next.js/React | `npm run build` | `npm test` | `npm run lint` |
| pnpm monorepo | `pnpm build` | `pnpm test` | `pnpm lint` |
| Go | `make build` | `make test` | `make lint` |
| Protobuf | `make proto/go` | `make test` | `make lint` |

## Git Worktree Workflow

Always use git worktrees for isolation:

```bash
# Creating worktree (done by setup script)
git worktree add <path> -b <branch-name>

# Working in worktree
cd workspace/{task}/org/repo
git checkout -b feature/my-change
# ... make changes ...
git add . && git commit -m "message"
```

## Key Constraints

- Never push to remote unless explicitly requested
- Never merge branches
- Work only within the workspace directory scope
- Update TODO files after completing each item (re-read before updating to detect conflicts)
- Run tests and linters before completing work

## Review Output

Reviews are saved to `workspace/{task}/reviews/{timestamp}/`:
- Individual reviews: `{org}_{repo}.md` (slashes replaced with underscores)
- Summary: `SUMMARY.md`
