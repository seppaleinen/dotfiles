---
name: typescript-skill
description: TypeScript/Vite/Node.js project conventions — lint, test, typecheck commands and config paths.
---

# TypeScript Skill

Load this skill when working on TypeScript projects (detected via `package.json` + `tsconfig.json`).

## Pipeline Variables

These variables are used by `dev-team-lead` in the Lint/Test stages:

| Variable | Command | Purpose |
|----------|---------|---------|
| `LINT_CMD` | `pnpm lint` or `eslint .` | Linting (ESLint) |
| `TYPECHECK_CMD` | `tsc --noEmit` or `pnpm typecheck` | Type checking |
| `TEST_CMD` | `pnpm test` or `vitest` | Test execution |
| `FORMAT_CMD` | `prettier --check .` or `pnpm format` | Formatting check |

## Config Locations

- **ESLint**: `.eslintrc.js`, `.eslintrc.cjs`, `eslint.config.js`, or `package.json` → `eslintConfig`
- **TypeScript**: `tsconfig.json` (root or per-package in monorepo)
- **Prettier**: `.prettierrc`, `prettier.config.js`, or `package.json` → `prettier`
- **Vitest**: `vitest.config.ts` or `vite.config.ts`
- **Package**: `package.json` → `scripts`, `dependencies`, `devDependencies`

## Conventions

### Module Structure
- **Source**: `src/` (or `packages/*/src` in monorepo)
- **Tests**: `*.test.ts`, `*.spec.ts`, or `__tests__/` directory
- **Build output**: `dist/` or `build/` (gitignored)

### Error Handling
- Prefer `Result<T, E>` patterns or typed errors over bare `throw`
- Use `try/catch` boundaries at module edges (API calls, user input)
- Never swallow errors silently — log or rethrow

### Naming
- **Files**: `kebab-case.ts` or `PascalCase.ts` (for components/classes)
- **Functions/vars**: `camelCase`
- **Types/Interfaces**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Tests
- Co-locate tests with source (`*.test.ts` next to `*.ts`)
- Use `describe/it/test` pattern (vitest/jest)
- Mock external dependencies (API calls, filesystem)

## CI Gates

Typical blocking checks (verify in `.github/workflows/`):
- `lint` — runs `pnpm lint`
- `typecheck` — runs `tsc --noEmit`
- `test` — runs `pnpm test`
- `build` — runs `pnpm build` (optional, ensures compilation)

## When to Override

Project may declare custom commands in `.agents/stack-context.md` or `AGENTS.md`. Use those if present; fall back to these defaults.