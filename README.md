# complex-ai-workspace

A multi-repository workspace manager for Claude Code. This tool provides Claude with skills and sub-agents to handle complex tasks across multiple repositories using git worktrees for isolation.

## Usage

1. Clone this repo
2. Open with `claude` command (Claude Code CLI)
3. Initialize a workspace:
   ```
   /init-workspace feature user-auth github.com/org/repo
   ```
4. Execute the tasks:
   ```
   /execute-workspace
   ```
5. Review and create PR:
   ```
   /review-workspace-changes
   /create-pr-workspace
   ```

## How It Works

Tasks are executed in isolated directories (`./workspace/{task-name}-{date}/`) using git worktrees. Claude clones the target repository on first use to `./repositories/` and creates worktrees for each task.

## Available Skills

| Skill | Description |
|-------|-------------|
| `/init-workspace` | Initialize workspace with worktree, README, and TODO files |
| `/execute-workspace` | Execute TODO items via workspace-repo-todo-executor agent |
| `/review-workspace-changes` | Review code changes via review-workspace-repo-changes agent |
| `/create-pr-workspace` | Create PRs for all repositories (draft by default) |
| `/update-workspace-todo` | Update TODO items in a workspace repository |
| `/show-current-workspace` | Show the currently focused workspace |
| `/show-workspaces` | List all workspaces in the workspace directory |
| `/show-current-status` | Show TODO progress and background agent status |
| `/delete-workspace` | Delete a workspace after confirmation |
| `/prune-workspaces` | Delete stale workspaces not modified recently |

See [CLAUDE.md](./CLAUDE.md) for detailed documentation.
