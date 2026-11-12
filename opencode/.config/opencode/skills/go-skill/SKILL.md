---
name: go-skill
description: Go project conventions — lint, test, build commands and config paths.
---

# Go Skill

Load this skill when working on Go projects (detected via `go.mod`).

## Pipeline Variables

These variables are used by `dev-team-lead` in the Lint/Test stages:

| Variable | Command | Purpose |
|----------|---------|---------|
| `LINT_CMD` | `golangci-lint run` | Linting (golangci-lint) |
| `TYPECHECK_CMD` | `go build ./...` | Compilation / type checking |
| `TEST_CMD` | `go test ./... -race` | Test execution with race detector |
| `FORMAT_CMD` | `gofmt -d .` or `go fmt ./...` | Formatting check |

## Config Locations

- **Module**: `go.mod` (root)
- **golangci-lint**: `.golangci.yml`, `.golangci.yaml`, or `go.mod` → `tool.golangci-lint`
- **Makefile**: `Makefile` (common for task automation)

## Conventions

### Module Structure
- **Source**: Root directory or `cmd/` (binaries), `pkg/` (libraries), `internal/` (private)
- **Tests**: `*_test.go` alongside source
- **Build output**: Compiled binaries (gitignored)

### Error Handling
- Return errors as values (`func() (T, error)`)
- Check errors immediately: `if err != nil { return err }`
- Wrap errors with context: `fmt.Errorf("context: %w", err)`
- Avoid panics in production code

### Naming
- **Files/Packages**: `snake_case.go` or `lowercase`
- **Functions/vars**: `camelCase` or `PascalCase` (exported)
- **Types/Structs**: `PascalCase` (exported), `camelCase` (unexported)
- **Interfaces**: Single-method interfaces end in `-er` (`Reader`, `Writer`)
- **Constants**: `PascalCase` (exported), `camelCase` (unexported)

### Tests
- Co-locate tests: `*_test.go` alongside source
- Use `testing` package or `testify`
- Table-driven tests for multiple cases
- Mock external dependencies (gomock, mockery)

## CI Gates

Typical blocking checks (verify in `.github/workflows/`):
- `lint` — runs `golangci-lint run`
- `build` — runs `go build ./...`
- `test` — runs `go test ./... -race`
- `tidy` — runs `go mod tidy && git diff --exit-code`

## When to Override

Project may declare custom commands in `.agents/stack-context.md` or `AGENTS.md`. Use those if present; fall back to these defaults.