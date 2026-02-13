---
name: workspace-execute
description: "Continue working on an existing workspace by executing TODO items. Implements code, runs tests, makes commits. Use when the user wants to resume or continue work on a previously initialized workspace, or after /workspace-init completes."
---

# workspace-execute

## Overview

This skill executes work in an initialized workspace. It detects the task type and routes accordingly:
- **Research/Investigation tasks**: Delegates to the `workspace-researcher` agent for cross-repository investigation
- **All other tasks** (feature, bugfix, etc.): Delegates to the `workspace-repo-todo-executor` agent per repository

**Prerequisites:** The workspace must be initialized first using `/workspace-init`.

## Critical: File Path Rules

**ALWAYS use paths relative to the project root** (where `.claude/` directory exists).

When accessing workspace files, use paths like:
- `workspace/{workspace-name}/README.md`
- `workspace/{workspace-name}/TODO-{repository-name}.md`

**DO NOT** use absolute paths (starting with `/`) for workspace files. The permission system requires relative paths from the project root.

## Steps

### 1. Workspace

**Required**: User must specify the workspace.

- If workspace is **not specified**, abort with message:
  > Please specify a workspace. Example: `/workspace-execute workspace/feature-user-auth-20260116`
- Workspace format: `workspace/{workspace-name}` or just `{workspace-name}`

### 2. Detect Task Type and Route

Read the workspace README.md to determine the task type:

```
workspace/{workspace-name}/README.md
```

Look for `**Task Type**` in the README. Based on the value:

- **`research`**, **`investigation`**, **`documentation`**, or **`design-doc`** → **Route A** (Research flow)
- **All other types** (feature, bugfix, etc.) → **Route B** (Standard TODO execution flow)

**Guideline**: Route A is for tasks whose primary output is a **document** (report, design doc, analysis) based on cross-repository exploration. Route B is for tasks that **modify code** in repositories. If the task type is ambiguous, check the README objective — if it describes producing a document rather than changing code, use Route A.

---

#### Route A: Research Flow

For research/investigation tasks, launch a single `workspace-researcher` agent:

```yaml
Task tool:
  subagent_type: workspace-researcher
  run_in_background: true
  prompt: |
    Workspace: {workspace-name}
```

**What the agent does (defined in agent, not by prompt):**

- Reads README.md to understand research objectives
- Discovers all repositories in the workspace
- Investigates each repository and cross-repository concerns
- Writes findings to `artifacts/research-report.md`
- Appends a summary to README.md

After the researcher agent completes, **skip directly to Step 6** (Commit Workspace Snapshot).

---

#### Route B: Standard TODO Execution Flow

For feature, bugfix, and other implementation tasks, continue with Step 3 below.

### 3. Find Repositories (Route B only)

Find all repository worktrees in the workspace:

```bash
./.claude/scripts/list-workspace-repos.sh {workspace-name}
```

For each repository, extract:
- Repository path (e.g., `github.com/sters/ai-workspace`)
- Repository name (e.g., `ai-workspace`)

### 4. Launch Executor Agents (Route B only)

For each repository in the workspace, use the Task tool to launch the `workspace-repo-todo-executor` agent in background:

```yaml
Task tool:
  subagent_type: workspace-repo-todo-executor
  run_in_background: true
  prompt: |
    Workspace: {workspace-name}
    Repository: {org/repo-path}
```

**What the agent does (defined in agent, not by prompt):**

- Reads README.md and `TODO-{repository-name}.md` to understand the task
- Executes TODO items sequentially
- Updates the TODO file as items are completed
- Runs tests and linters
- Makes commits with descriptive messages
- Reports completion summary

**Important**: Launch all agents in parallel if there are multiple repositories.

### 5. Monitor and Handle Blockers (Route B only)

**Do not wait for all agents to complete.** Instead, monitor each agent and handle blockers as soon as they are reported.

For each agent that completes:

1. **Parse the response** - The executor agent returns:
   ```
   DONE: Completed {n} TODO items for {repository-name}
   OUTPUT: workspace/{workspace-name}/TODO-{repository-name}.md
   STATS: completed={n}, remaining={m}, blocked={b}, commits={c}, tests={pass/fail}, lint={pass/fail}
   BLOCKED: {brief description of blocker(s)} (only if blocked > 0)
   ```

2. **If `blocked > 0`**, immediately delegate to the `workspace-repo-blocker-planner` agent:
   ```yaml
   Task tool:
     subagent_type: workspace-repo-blocker-planner
     prompt: |
       Workspace: {workspace-name}
       Repository: {repository-name}
   ```

3. **Present blocker options to user**:
   ```yaml
   AskUserQuestion tool:
     questions:
       - question: "[{repository-name}] {blocker title} - How would you like to proceed?"
         header: "Blocker"
         multiSelect: false
         options:
           - label: "{Option 1 from agent analysis}"
             description: "{Trade-off or impact}"
           - label: "{Option 2 from agent analysis}"
             description: "{Trade-off or impact}"
           - label: "Skip this item"
             description: "Defer to a later PR"
   ```

4. **Based on user selection**:
   - **FIX/WORKAROUND** → Update TODO file with chosen approach, re-launch executor for that repository
   - **SKIP** → Mark item as skipped in TODO file, continue monitoring other agents

5. **If no blockers**, note completion and continue monitoring remaining agents.

**Parallel handling**: While waiting for user input on one blocker, other agents may complete. Queue their results and process blockers sequentially to avoid overwhelming the user.

### 6. Commit Workspace Snapshot

After execution is complete (Route A: researcher done, Route B: all repositories done including re-runs):

```bash
./.claude/scripts/commit-workspace-snapshot.sh {workspace-name}
```

### 7. Report Final Results

Report the execution summary to the user.

**For Route A (Research):**
- Research report location
- Number of repositories analyzed
- Key findings summary (read from `artifacts/research-report.md` if needed)

**For Route B (Standard):**
- Completed TODO items count (per repository and total)
- Remaining TODO items (if any)
- Skipped items (if any blockers were skipped)
- Test/lint status
- Commits made

## Example Usage

### Example 1: Execute Feature Workspace (Route B)

```
User: Execute the tasks in my workspace
Assistant: Let me identify the workspace and execute the TODO items...
[Reads README.md → Task Type: feature → Route B]
[Identifies repositories, launches executor agents]
[After completion]
Execution complete! Completed 8 TODO items across 2 repositories.
```

### Example 2: Execute Research Workspace (Route A)

```
User: Execute workspace/research-auth-flow-20260116
Assistant: I'll execute the research in workspace/research-auth-flow-20260116...
[Reads README.md → Task Type: research → Route A]
[Launches workspace-researcher agent]
[After completion]
Research complete! Report saved to artifacts/research-report.md.
3 repositories analyzed, 12 findings documented.
```

## Next Steps - Ask User to Proceed

After all execution is complete (Step 7), **always ask the user** whether to proceed with the next step using AskUserQuestion.

### For Route B (Standard tasks)

**Note**: Blockers are handled inline during Step 5, so by this point all blockers have been resolved or skipped.

```yaml
AskUserQuestion tool:
  questions:
    - question: "Task execution complete. Would you like to review the code changes before creating/updating a PR?"
      header: "Next Step"
      multiSelect: false
      options:
        - label: "Review changes (Recommended)"
          description: "Run /workspace-review-changes to check for issues before PR"
        - label: "Skip review, create/update PR"
          description: "Proceed directly to /workspace-create-or-update-pr (creates new PR or updates existing)"
        - label: "Done for now"
          description: "I'll continue manually later"
```

Based on the user's selection:
- "Review changes" → Invoke the `/workspace-review-changes` skill using the Skill tool
- "Skip review, create/update PR" → Invoke the `/workspace-create-or-update-pr` skill using the Skill tool
- "Done for now" → End the workflow

### For Route A (Research tasks)

```yaml
AskUserQuestion tool:
  questions:
    - question: "Research complete. The report is at artifacts/research-report.md. What would you like to do next?"
      header: "Next Step"
      multiSelect: false
      options:
        - label: "Done"
          description: "Research is complete, no further action needed"
        - label: "Create implementation workspace"
          description: "Use findings to create a new workspace with implementation TODOs"
```

Based on the user's selection:
- "Done" → End the workflow
- "Create implementation workspace" → Guide the user to run `/workspace-init` for an implementation task based on the research findings

**Important**: Always suggest `/workspace-create-or-update-pr` instead of manual `git push`. The skill handles both creating new PRs and updating existing PRs automatically.

## Notes

- The skill detects task type from README.md and routes to the appropriate agent
- **Research tasks** (Route A): A single `workspace-researcher` agent handles all repositories
- **Standard tasks** (Route B): Each repository is processed by its own `workspace-repo-todo-executor` agent instance
- Agents handle their work autonomously (test execution, linting, commits for Route B; exploration and reporting for Route A)
