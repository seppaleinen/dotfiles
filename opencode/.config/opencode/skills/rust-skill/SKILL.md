---
name: rust-skill
description: Rust project conventions — lint, test, check commands and config paths.
---

# Rust Skill

Load this skill when working on Rust projects (detected via `Cargo.toml`).

## Pipeline Variables

These variables are used by `dev-team-lead` in the Lint/Test stages:

| Variable | Command | Purpose |
|----------|---------|---------|
| `LINT_CMD` | `cargo clippy --all-targets --all-features -- -D warnings` | Linting (Clippy) |
| `TYPECHECK_CMD` | `cargo check --all-targets --all-features` | Type checking / compilation |
| `TEST_CMD` | `cargo test --all-features` | Test execution |
| `FORMAT_CMD` | `cargo fmt --check` | Formatting check |

## Config Locations

- **Cargo**: `Cargo.toml` (root or per-crate in workspace)
- **Rustfmt**: `rustfmt.toml` or `Cargo.toml` → `[package.metadata.rustfmt]`
- **Clippy**: `clippy.toml` or `Cargo.toml` → `[package.metadata.clippy]`
- **Workspace**: `Cargo.toml` → `[workspace]` with `members = [...]`

## Conventions

### Module Structure
- **Source**: `src/` (binary: `src/main.rs`, library: `src/lib.rs`)
- **Tests**: `tests/` directory (integration) or `#[cfg(test)]` modules (unit)
- **Examples**: `examples/` directory
- **Build output**: `target/` (gitignored)

### Error Handling
- Use `Result<T, E>` with custom error types (thiserror, anyhow)
- Propagate errors with `?` operator
- Avoid `.unwrap()` in production code — use `.expect()` with message or proper error handling

### Naming
- **Files/Modules**: `snake_case.rs`
- **Functions/vars**: `snake_case`
- **Types/Structs/Enums**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Traits**: `PascalCase`

### Tests
- Unit tests: `#[cfg(test)] mod tests { ... }` alongside source
- Integration tests: `tests/*.rs` directory
- Use `#[test]`, `#[should_panic]`, `#[should_panic(expected = "...")]`
- Mock external dependencies (mockall crate)

## CI Gates

Typical blocking checks (verify in `.github/workflows/`):
- `clippy` — runs `cargo clippy --all-targets --all-features -- -D warnings`
- `check` — runs `cargo check --all-targets --all-features`
- `test` — runs `cargo test --all-features`
- `fmt` — runs `cargo fmt --check`

## When to Override

Project may declare custom commands in `.agents/stack-context.md` or `AGENTS.md`. Use those if present; fall back to these defaults.