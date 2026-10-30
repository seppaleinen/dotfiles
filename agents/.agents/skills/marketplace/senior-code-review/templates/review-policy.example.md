# Review policy (example)

<!-- EXAMPLE FILE — copy to the repo you are reviewing as docs/review-policy.md
     (or .agents/review-policy.md) and customise for your team.

     Template: templates/review-policy.example.md (installed to
     ~/.agents/skills/marketplace/senior-code-review/templates/).

     Used by senior-code-review:
     - Human sign-off gates read ## Human sign-off required (mandatory human review)

     Risk assessment is not configured here — the agent loads repo context,
     then characterises and assesses risk.

     Keep the ## section headlines exactly as shown — the agent locates content
     by headline. Edit the body under each section only.

     Gates never skip review steps. The agent always runs the full workflow. -->

## Owner & scope

- **Owner:** engineering (rename for your group)
- **Scope:** this repository

---

## Human sign-off required

Surfaces that always need a human reviewer before merge — regardless of agent
findings. When the diff touches a surface below, the agent emits
`### Requires Human Review`.

Each `###` heading is one trigger. Keep descriptions short and concrete — the
agent matches by reading the description against what changed, not by keywords.

### Authentication & sessions
Any change to login, logout, token issuance, session creation or expiry,
password hashing, or MFA flows.

### Authorisation / permissions
Any change to access-control checks, role or permission definitions, or
middleware that gates routes behind auth.

### Payments & billing
Any change to payment processing, subscription management, invoice generation,
or integrations with payment providers (Stripe, Braintree, etc.).

### Database migrations
Any new migration file, schema change, index addition or removal, or
`ALTER TABLE` / equivalent.

### Public API contract changes
Any addition, removal, or modification of a public API endpoint, request/
response shape, or versioned API route. Includes breaking changes to SDKs or
client contracts.

### Secrets & credentials handling
Any change that reads, writes, rotates, or logs secrets, API keys, tokens,
or environment variables used for authentication.

### Data deletion or bulk mutation
Any operation that deletes or bulk-updates user data without a corresponding
rollback story or dry-run flag.

### Infrastructure / deployment config
Any change to Terraform, Helm charts, Kubernetes manifests, Dockerfiles, or
CI/CD pipeline definitions that affects production environments.

---

## How to customise

- **Human sign-off required** — remove triggers your team is comfortable
  delegating to the agent; add triggers for compliance needs. Policy gates are
  not quality findings — they fire even when the code looks fine.
- **Risk areas** — org-wide risk guidance belongs in marketplace **knowledge**
  (`KNOWLEDGE.md`), loaded automatically with repo context — not in this file.
- Coding standards and fit expectations live in `AGENTS.md`, not here.

## Optional: pointer from AGENTS.md

```markdown
Review policy: docs/review-policy.md
```
