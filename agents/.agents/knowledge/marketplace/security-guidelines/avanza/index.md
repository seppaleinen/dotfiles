# Avanza guidelines

Follow these. See [How to apply these guidelines](/precedence.md).

## Secure by design

* [Threat modeling](/avanza/threat-modeling.md) — blast radius and controls as hypotheses; living document; NPaP input
* [Fail-safe defaults](/avanza/fail-safe-defaults.md) — deny when auth, policy, or rate limiting is unavailable
* [Minimize PII](/avanza/identity-and-pii.md) — no extra PII, never as a DB key, no existence oracle, KYC when using personnummer
* [Data classification](/avanza/data-classification.md) — production data is restricted unless classified otherwise

## Backend

* [Input validation](/avanza/input-validation.md) — hostile input, domain types, negative tests
* [Centralized authentication](/avanza/centralized-auth.md) — platform `@LoggedIn`, do not roll your own
* [SECURITYGROUPS](/avanza/securitygroups.md) — internal admin via Active Directory groups
* [CSRF and HTTP methods](/avanza/csrf-request-mapping.md) — no `@RequestMapping` on state-changing REST
* [Parameterized queries](/avanza/parameterized-queries.md) — validation is not enough if the query is concatenated
* [REST access control](/avanza/rest-authorization.md) — ownership in the controller; IDOR
* [Apollo authorization](/avanza/apollo-authorization.md) — intended callers only; `CustomerId` is not authz
* [Impersonation rights](/avanza/impersonation.md) — `@ImpersonationRightsRequired` and audit who acted
* [Compartmentalization](/avanza/compartmentalization.md) — timeouts, rate limits, bulkheads, capacity asymmetry
* [Logging and audit](/avanza/logging-tokens.md) — never PII/`cstoken`; do log security-sensitive actions
* [Secrets management](/avanza/secrets-management.md) — Vault or Secret Manager; rotation

## Frontend

* [CSP and safe rendering](/avanza/frontend.md) — platform CSP already set; do not add one; do not bypass Angular sanitization

## Secure development practices

* [Dependencies and vendors](/avanza/approved-dependencies.md) — Artifact Registry, pins, BOM, Renovate, Tech Procurement
* [GitLab CI and security tooling](/avanza/gitlab-ci.md) — no `secure_files`, four-eyes, security pipeline
* [Sensitive changes](/avanza/sensitive-changes.md) — extra review for auth, IAM, secrets, integrations

## Operations

* [Environment separation](/avanza/environment-separation.md) — no prod secrets or real customer data in non-prod
* [Three perimeters](/avanza/three-perimeters.md) — identity, network, workload/supply chain
* [IaC and hands-off production](/avanza/iac-production.md) — Terraform in Git; PAM for manual prod access
* [Container base images](/avanza/container-base-images.md) — platform-area images for GCP production
* [Backups and recovery](/avanza/backups.md) — encrypted, separate location, restore-tested
* [Incident readiness](/avanza/incident-readiness.md) — break-glass, runbooks, annual DR
