---
name: python-skill
description: Python project conventions — lint, test, typecheck commands and config paths.
---

# Python Skill

Load this skill when working on Python projects (detected via `pyproject.toml`, `requirements.txt`, or `setup.py`).

## Pipeline Variables

These variables are used by `dev-team-lead` in the Lint/Test stages:

| Variable | Command | Purpose |
|----------|---------|---------|
| `LINT_CMD` | `ruff check .` or `uv tool run ruff check .` | Linting (Ruff) |
| `TYPECHECK_CMD` | `mypy .` or `uv tool run mypy .` | Type checking (optional) |
| `TEST_CMD` | `pytest` or `uv run pytest` | Test execution |
| `FORMAT_CMD` | `ruff format --check .` or `black --check .` | Formatting check |

## Config Locations

- **Ruff**: `pyproject.toml` → `[tool.ruff]` or `ruff.toml`
- **Mypy**: `pyproject.toml` → `[tool.mypy]` or `mypy.ini`
- **Pytest**: `pyproject.toml` → `[tool.pytest]`, `pytest.ini`, or `setup.cfg`
- **Black**: `pyproject.toml` → `[tool.black]` or `pyproject.toml`
- **Package**: `pyproject.toml`, `setup.py`, or `requirements.txt`

## Conventions

### Module Structure
- **Source**: `src/` (preferred) or package root directory
- **Tests**: `tests/` directory or `*_test.py` / `test_*.py` alongside source
- **Virtual env**: `.venv/` (gitignored)

### Error Handling
- Use specific exception types, not bare `except Exception`
- Prefer `raise ... from ...` for exception chaining
- Log errors at boundaries (API calls, file I/O, DB)

### Naming
- **Files/Modules**: `snake_case.py`
- **Functions/vars**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: `_leading_underscore`

### Tests
- Use `pytest` fixtures for setup/teardown
- Parametrize tests for multiple cases
- Mock external dependencies (API calls, filesystem, DB)

## CI Gates

Typical blocking checks (verify in `.github/workflows/`):
- `lint` — runs `ruff check .`
- `typecheck` — runs `mypy .` (optional, if type hints present)
- `test` — runs `pytest`
- `format` — runs `ruff format --check .` or `black --check .`

## When to Override

Project may declare custom commands in `.agents/stack-context.md` or `AGENTS.md`. Use those if present; fall back to these defaults.