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

## Implementation Tasks

<!--
IMPORTANT: Replace items below with specific, structured TODO items.
Each item MUST follow this format:

- [ ] **[target/file.go]** Specific action description
  - Target: `exact/path/to/file.go` or "New file"
  - Action: Detailed description of what to add/modify/remove
  - Pattern: (optional) `reference/file.go:FunctionName` to follow
  - Verify: (optional) Test command or verification step

Example:
- [ ] **[handlers/user_handler.go]** Add CreateUser endpoint
  - Target: `handlers/user_handler.go` (new function)
  - Action: Create `CreateUserHandler` that accepts JSON with name/email, returns 201 with user ID
  - Pattern: `handlers/order_handler.go:CreateOrderHandler`
  - Verify: `go test ./handlers -run TestCreateUserHandler`

DO NOT leave vague items like "Implement code changes" or "Write tests"
-->

- [ ] **[TBD]** Create feature branch
  - Target: Git repository
  - Action: Create branch `feature/{branch-name}` from base branch

- [ ] **[TBD]** (Replace with specific implementation tasks)
  - Target: (Specify exact file path)
  - Action: (Describe exactly what to add/modify)
  - Pattern: (Reference existing similar code if applicable)

- [ ] **[TBD]** (Replace with specific test tasks)
  - Target: (Specify test file path)
  - Action: (Describe test cases to add)
  - Verify: (Specify test command)

## Verification

- [ ] **[Repository]** Run test suite
  - Target: Repository root
  - Action: Execute test command from CLAUDE.md/README.md or `make test`
  - Verify: All tests pass

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
