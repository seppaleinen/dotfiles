### Tool Usage Rules

- The `execute` tool runs in a bare ECMAScript isolate without Node.js global bindings (`require`, `process`, `Buffer`, `fs`).
- Use `execute` strictly for in-memory pure JS operations, data parsing, math, or JSON manipulation.
- For file system access, package dependencies, or running Node.js code, execute directly via the `shell` tool (`node -e "..."` or script files).

**Tool Selection Guardrail (issue #38)**

| Tool | Use For | NOT For |
|------|---------|---------|
| `execute` | Pure JS: `JSON.parse()`, `data.map()`, `fetch(url)`, math, string manipulation | Shell commands, `require()`, `process`, `fs`, `Buffer`, `child_process`, git, file I/O |
| `shell` | CLI commands: `git`, `find`, `grep`, `kubectl`, `flux`, `curl`, `node -e`, `npm`, `stow` | Pure JS computation, file reads/writes (use `read`/`write`/`edit`) |
| `read` / `write` / `edit` | File operations in the workspace | Shell redirections (`cat >`, `tee`), inline file creation |

**Anti-patterns (NEVER do these in `execute`)**
❌ `require('child_process').execSync('git status')`
❌ `require('fs').readFileSync('file.txt')`
❌ `process.env.SOME_VAR`
❌ `Buffer.from('data')`
❌ `ls`, `find`, `grep`, `kubectl`, `flux` via `execute`

**Correct patterns**
✅ `execute`: `JSON.parse(result)`, `data.filter(...)`, `fetch(url).then(r => r.json())`
✅ `shell`: `git status`, `find . -name "*.md"`, `kubectl get pods`
✅ `read`: read file contents
✅ `write`: write file contents
✅ `edit`: modify file contents

The full guardrail is codified in the `delegation-contract` skill. All pipeline leads (`team-lead`, `dev-team-lead`, `devops-team-lead`) load that skill and enforce it on dispatched workers.
