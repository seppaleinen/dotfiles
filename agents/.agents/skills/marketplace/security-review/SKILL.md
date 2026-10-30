---
name: security-review
description: >-
  Security code review following Avanza Technical Security Requirements via
  security-guidelines knowledge. Use when asked to "security review",
  "find vulnerabilities", "check for security issues", "audit security",
  or review code for injection, XSS, authentication, authorization, or
  cryptography issues. Reports only high-confidence exploitable findings.
allowed-tools: Read, Grep, Glob, Bash, Task
---

# Security Review

Identify exploitable security vulnerabilities. Report only **HIGH CONFIDENCE** findings — clear vulnerable patterns with attacker-controlled input.

Follow **`security-guidelines` knowledge** (`avanza/` concepts). Follow **knowledge-lookup**; do not load catalog source paths. Cite `[ref: security-guidelines]`.

If `security-guidelines` is not installed, tell the user and suggest `aza-market install security-guidelines` (or `--project`). Continue this workflow; do not invent Avanza-specific rules.

## Scope: Research vs. Reporting

- **Report on**: Only the specific file, diff, or code provided by the user
- **Research**: The ENTIRE codebase to build confidence before reporting

Before flagging, research: where input comes from, whether validation exists elsewhere, how it is configured, and which platform or framework protections apply.

**Do NOT report issues based solely on pattern matching.**

## Confidence Levels

| Level | Criteria | Action |
|--------|----------|--------|
| **HIGH** | Vulnerable pattern + attacker-controlled input confirmed | **Report** with severity |
| **MEDIUM** | Vulnerable pattern, input source unclear | **Note** as "Needs verification" |
| **LOW** | Theoretical, best practice, defense-in-depth | **Do not report** |

## Do Not Flag

- Test files (unless explicitly reviewing test security)
- Dead code, commented code, documentation strings
- Patterns using **constants** or **server-controlled configuration**
- Code paths that require prior authentication to reach (note the auth requirement instead)

### Server-controlled values (not attacker-controlled)

| Source | Example |
|--------|---------|
| Framework settings | `settings.API_URL`, `settings.ALLOWED_HOSTS` |
| Environment variables | `os.environ.get('DATABASE_URL')` |
| Config files | `config.yaml`, `app.config['KEY']` |
| Hardcoded constants | `BASE_URL = "https://api.internal"` |

## Review Process

### 1. Load guidelines

Follow **knowledge-lookup**. Prefer the installed `security-guidelines` entry.

User-level install: `~/.agents/knowledge/marketplace/security-guidelines/` (project: `.agents/knowledge/marketplace/security-guidelines/`). Use the registry `install_path` when it differs.

Skim `{install_path}/index.md`, then follow `{install_path}/precedence.md`. Load matching `{install_path}/avanza/` concepts. For extra bug-class or framework detail, use model knowledge; if it conflicts with an Avanza concept, follow Avanza.

### 2. Research before flagging

For each potential issue: trace the data flow, distinguish deployment config from user input, look for validation/sanitization, and apply framework protections. Use bug-class knowledge as needed.

### 3. Verify exploitability

**Attacker-controlled (investigate):** `request.GET`/`POST`/`json`/`body`, most headers, unsigned cookies, URL path segments, file uploads, other users' DB content, WebSocket messages.

**Server-controlled (usually safe):** settings, env vars, hardcoded constants, internal URLs from config, signed session data, framework settings.

### 4. Report HIGH confidence only

Skip theoretical issues. If an Avanza concept covers the same issue, follow it.

## Severity Classification

Use the loaded Avanza concept’s severity when it states one. Otherwise:

| Severity | Impact | Examples |
|----------|--------|----------|
| **Critical** | Direct exploit, severe impact, no auth required | RCE, SQL injection to data, auth bypass, hardcoded secrets |
| **High** | Exploitable with conditions, significant impact | Stored XSS, SSRF to metadata, IDOR to sensitive data |
| **Medium** | Specific conditions required, moderate impact | Reflected XSS, CSRF on state-changing actions, path traversal |
| **Low** | Defense-in-depth, minimal direct impact | Missing headers, verbose errors, weak algorithms in non-critical context |

## Output Format

````markdown
## Security Review: [File/Component Name]

### Summary
- **Findings**: X (Y Critical, Z High, ...)
- **Risk Level**: Critical/High/Medium/Low
- **Confidence**: High/Mixed

### Findings

#### [VULN-001] [Vulnerability Type] (Severity)
- **Location**: `file.py:123`
- **Confidence**: High
- **Issue**: [What the vulnerability is]
- **Impact**: [What an attacker could do]
- **Evidence**:
  ```python
  [Vulnerable code snippet]
  ```
- **Fix**: [How to remediate]
- **Citation**: [ref: security-guidelines]

### Needs Verification

#### [VERIFY-001] [Potential Issue]
- **Location**: `file.py:456`
- **Question**: [What needs to be verified]
````

If no vulnerabilities found, state: "No high-confidence vulnerabilities identified."
