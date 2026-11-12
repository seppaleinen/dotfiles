---
name: detect-stack
description: Analyze a codebase to detect its language, framework, conventions, and CI gates. Run this on first use in a project to generate stack context that all coding principle skills reference. Use when the user says "detect stack," "analyze this project," or "what's this codebase using."
---

# Detect Stack

Analyze the current codebase and generate `.agents/stack-context.md`. Run this on first use in a project, or when the stack context is missing or stale.

## What to Detect

Scan the project root for these signals:

### Primary Language Detection

Check for these markers in priority order (first match wins):

| Language | Markers | Skill to Load |
|----------|---------|---------------|
| **Rust** | `Cargo.toml` | `rust-skill` |
| **Go** | `go.mod` | `go-skill` |
| **TypeScript** | `package.json` + `tsconfig.json` | `typescript-skill` |
| **JavaScript** | `package.json` (no `tsconfig.json`) | `typescript-skill` (subset) |
| **Python** | `pyproject.toml` OR `requirements.txt` OR `setup.py` | `python-skill` |
| **Ruby** | `Gemfile` | (future: `ruby-skill`) |
| **Swift** | `Package.swift` | (future: `swift-skill`) |
| **Elixir** | `mix.exs` | (future: `elixir-skill`) |

### Secondary Signals

- **Framework**: Read the package manifest for framework dependencies
- **Test framework**: Look for test config files or test directory patterns
- **CI gates**: Scan `.github/workflows/`, `.gitlab-ci.yml` for blocking checks
- **Conventions**: Check for `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`

## Output

Write `.agents/stack-context.md` — keep it concise (under 50 lines):

```markdown
# Stack Context

Generated: YYYY-MM-DD

## Stack
- **Language**: [primary] [version if pinned]
- **Framework**: [web framework], [db layer]
- **Build**: [build tool]
- **Lint**: [lint command]
- **Typecheck**: [typecheck command] (if applicable)
- **Test**: [test command]
- **Format**: [format command]

## Skill to Load
`skill(name="<language>-skill")`

## Secondary Languages
- [language] ([what it's used for])

## Conventions
- Error handling: [pattern]
- Module structure: [pattern]
- Naming: [pattern]
- Tests: [where they live, how they're organized]

## CI Gates
- [list of blocking checks from CI config]

## Override
If this file conflicts with `AGENTS.md` or explicit project documentation, prefer the explicit documentation.
```

## When to Re-Run

- `.agents/stack-context.md` doesn't exist
- Major dependency changes (new framework, language version bump)
- Project structure significantly changes
- Context file is older than 30 days

## Usage in dev-team-lead Pipeline

After detection, `dev-team-lead` loads the skill:

```
skill(name="typescript-skill")  // or rust-skill, python-skill, go-skill
```

The skill provides pipeline variables (`LINT_CMD`, `TYPECHECK_CMD`, `TEST_CMD`, `FORMAT_CMD`) used in subsequent stages.