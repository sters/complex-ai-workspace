# complex-ai-workspace

This tool provides Claude with skills and sub-agents to handle tasks across multiple repositories.

Tasks are executed in isolated directories like `./workspace/something-to-do/` using git worktrees. Claude clones the working repository on first use and then reuses it, creating git worktrees for subsequent tasks in the directory.


## Usage

1. Clone this repo.
2. Open with `claude` command (claude code CLI)
3. Type `/start-working {What do you want to do by claude code}`
4. claude code will automatically proceed the task.
