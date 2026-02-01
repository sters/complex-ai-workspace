# TODO: {{REPOSITORY_NAME}}

## Initialize

- [ ] **[README.md]** Read repository documentation
  - Target: `README.md`
  - Action: Understand project overview, setup, and development workflow

- [ ] **[CLAUDE.md]** Read AI-specific instructions (if exists)
  - Target: `CLAUDE.md`
  - Action: Identify build/test/lint commands and coding conventions

- [ ] **[CONTRIBUTING.md]** Read contribution guidelines (if exists)
  - Target: `CONTRIBUTING.md`
  - Action: Understand PR process and code style requirements

## Bug Investigation

<!--
IMPORTANT: Replace items below with specific, structured TODO items.
Each item MUST follow this format:

- [ ] **[target/file.go]** Specific action description
  - Target: `exact/path/to/file.go`
  - Action: Detailed description of what to investigate/fix
  - Pattern: (optional) `reference/file.go:FunctionName` for context
  - Verify: (optional) How to confirm the fix works

DO NOT leave vague items like "Fix the bug" or "Identify root cause"
-->

- [ ] **[TBD]** Reproduce the bug locally
  - Target: (Specify file/endpoint/component where bug occurs)
  - Action: (Describe exact steps to reproduce)
  - Verify: (Describe expected vs actual behavior)

- [ ] **[TBD]** Identify root cause
  - Target: (Specify suspected file/function)
  - Action: (Describe what to investigate - logs, stack trace, data flow)

## Bug Fix Tasks

- [ ] **[Git]** Create bugfix branch
  - Target: Git repository
  - Action: Create branch `bugfix/{branch-name}` from base branch

- [ ] **[TBD]** (Replace with specific fix implementation)
  - Target: (Specify exact file path)
  - Action: (Describe exactly what to change and why)
  - Pattern: (Reference correct behavior if exists elsewhere)

- [ ] **[TBD]** Add regression test
  - Target: (Specify test file path)
  - Action: (Describe test case that would have caught this bug)
  - Verify: Test fails without fix, passes with fix

## Verification

- [ ] **[TBD]** Verify bug is fixed
  - Target: (Same as reproduction step)
  - Action: Follow reproduction steps
  - Verify: Bug no longer occurs, expected behavior confirmed

- [ ] **[Repository]** Run test suite
  - Target: Repository root
  - Action: Execute test command from CLAUDE.md/README.md or `make test`
  - Verify: All tests pass (including new regression test)

- [ ] **[Repository]** Run linter
  - Target: Repository root
  - Action: Execute lint command from CLAUDE.md/README.md or `make lint`
  - Verify: No lint errors

## Finalize

- [ ] **[Git]** Commit changes
  - Target: Git repository
  - Action: Review `git log` for commit message style, then commit with descriptive message

## Notes

<!-- Add any notes, blockers, dependencies, or additional context here -->
