---
name: permissions-suggest
description: Detect and suggest blocked Bash commands from recent sessions
---

# permissions-suggest

## Overview

This skill scans recent Claude Code session debug logs to detect Bash commands that were blocked (permission denied) and helps the user add them to `settings.local.json`.

## Steps

### 1. Run Detection Script

Run the detection script to find blocked commands:

```bash
python3 .claude/skills/permissions-suggest/scripts/detect-blocked-commands.py {num_sessions}
```

**Arguments**:
- `num_sessions`: Number of recent sessions to scan (default: 10)

**Output**: JSON array of blocked commands with occurrence counts:
```json
[
  {"ruleContent": "pnpm --filter contacts test:*", "count": 5},
  {"ruleContent": "npm run lint:*", "count": 3}
]
```

### 2. Handle Results

**If no blocked commands found:**
Report to the user:
> No blocked Bash commands found in the last {n} sessions.

**If commands found:**
Use AskUserQuestion to let the user select which commands to allow:

```yaml
AskUserQuestion tool:
  questions:
    - question: "Which commands would you like to allow?"
      header: "Permissions"
      multiSelect: true
      options:
        # First 4 most frequent commands as options
        # Format: "{ruleContent} ({count}x blocked)"
```

### 3. Update Settings

For each selected command:
1. Read the current `.claude/settings.local.json`
2. Add the rule in format `Bash({ruleContent})` to `permissions.allow`
3. Write the updated settings file

### 4. Report Results

Report which rules were added:
> Added {n} rules to .claude/settings.local.json:
> - Bash({rule1})
> - Bash({rule2})

## Example Usage

```
User: /permissions-suggest 50
Assistant: Found 5 blocked Bash commands in recent 50 sessions.

[AskUserQuestion with multiSelect]
Which commands would you like to allow?
- go get:* (36x blocked)
- pnpm --filter contacts test:* (7x blocked)
- go version:* (6x blocked)
- git submodule update:* (3x blocked)

User: [selects first two]
Assistant: Added 2 rules to .claude/settings.local.json:
- Bash(go get:*)
- Bash(pnpm --filter contacts test:*)
```

## Notes

- The script only detects Bash commands, not other tools
- Commands already in settings.local.json are filtered out
- The script reads debug logs from `~/.claude/debug/`
- Session-to-debug mapping uses the session ID from `.jsonl` filenames
