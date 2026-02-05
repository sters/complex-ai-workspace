#!/usr/bin/env python3
"""
detect-blocked-commands.py - Extract blocked Bash commands from Claude Code debug logs

Usage: detect-blocked-commands.py [num_sessions] [settings_file]
Output: JSON array of blocked commands not already in settings

The script:
1. Lists recent session .jsonl files by modification time
2. Extracts session IDs and checks corresponding debug files
3. Parses debug files for permission denied events with addRules suggestions
4. Filters out rules that already exist in settings.local.json
5. Outputs deduplicated rules with occurrence counts
"""

import json
import os
import re
import sys
from collections import Counter
from pathlib import Path


def get_project_path():
    """Convert current working directory to Claude's project path format."""
    cwd = os.getcwd()
    # Replace / and . with - and remove leading -
    return cwd.replace("/", "-").replace(".", "-").lstrip("-")


def get_recent_session_ids(projects_dir: Path, num_sessions: int) -> list[str]:
    """Get session IDs from recent .jsonl files sorted by modification time."""
    if not projects_dir.exists():
        return []

    jsonl_files = list(projects_dir.glob("*.jsonl"))
    # Sort by modification time (newest first)
    jsonl_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)

    session_ids = []
    for f in jsonl_files[:num_sessions]:
        session_ids.append(f.stem)

    return session_ids


def load_existing_rules(settings_file: Path) -> set[str]:
    """Load existing Bash rules from settings.local.json."""
    if not settings_file.exists():
        return set()

    try:
        with open(settings_file) as f:
            settings = json.load(f)

        rules = set()
        for rule in settings.get("permissions", {}).get("allow", []):
            # Extract rule content from "Bash(content)" format
            if rule.startswith("Bash(") and rule.endswith(")"):
                content = rule[5:-1]  # Remove "Bash(" and ")"
                rules.add(content)
        return rules
    except (json.JSONDecodeError, OSError):
        return set()


def extract_blocked_commands(debug_file: Path) -> list[str]:
    """Extract blocked Bash command rules from a debug log file."""
    if not debug_file.exists():
        return []

    blocked_commands = []

    try:
        with open(debug_file, encoding="utf-8", errors="replace") as f:
            content = f.read()

        # Parse line by line to handle the log format correctly
        lines = content.split("\n")
        i = 0
        while i < len(lines):
            line = lines[i]
            if "Permission suggestions for Bash:" in line:
                # Extract the JSON that follows
                marker = "Permission suggestions for Bash:"
                json_start = line.find(marker) + len(marker)
                json_str = line[json_start:].strip()

                # Continue collecting lines until we find the closing bracket
                j = i + 1
                while j < len(lines) and not json_str.rstrip().endswith("]"):
                    json_str += "\n" + lines[j]
                    j += 1

                # Check if the next non-empty line contains 'Bash tool permission denied'
                k = j
                while k < len(lines) and not lines[k].strip():
                    k += 1

                if k < len(lines) and "Bash tool permission denied" in lines[k]:
                    try:
                        suggestions = json.loads(json_str.strip())
                        for suggestion in suggestions:
                            if (
                                suggestion.get("type") == "addRules"
                                and suggestion.get("behavior") == "allow"
                            ):
                                for rule in suggestion.get("rules", []):
                                    if rule.get("toolName") == "Bash":
                                        rule_content = rule.get("ruleContent")
                                        if rule_content:
                                            blocked_commands.append(rule_content)
                    except json.JSONDecodeError:
                        pass
                i = j
            else:
                i += 1

    except OSError:
        return []

    return blocked_commands


def main():
    num_sessions = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    settings_file = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(".claude/settings.local.json")

    home = Path.home()
    project_path = get_project_path()
    projects_dir = home / ".claude" / "projects" / f"-{project_path}"
    debug_dir = home / ".claude" / "debug"

    # Get recent session IDs
    session_ids = get_recent_session_ids(projects_dir, num_sessions)

    if not session_ids:
        print("[]")
        return

    # Load existing rules
    existing_rules = load_existing_rules(settings_file)

    # Collect all blocked commands
    all_blocked = []
    for session_id in session_ids:
        debug_file = debug_dir / f"{session_id}.txt"
        blocked = extract_blocked_commands(debug_file)
        all_blocked.extend(blocked)

    # Count occurrences and filter out existing rules
    counter = Counter(all_blocked)

    results = []
    for rule_content, count in counter.most_common():
        if rule_content not in existing_rules:
            results.append({"ruleContent": rule_content, "count": count})

    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
