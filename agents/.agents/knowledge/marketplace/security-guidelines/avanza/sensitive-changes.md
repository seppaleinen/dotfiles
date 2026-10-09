---
type: Avanza Guideline
title: Sensitive changes
description: Extra review for auth, IAM, network, secrets, data classification, and external integrations. Check threat model, blast radius, access control, and audit logs.
tags: [avanza, code-review, iam, secrets, authorization, threat-model]
---

# Code review of sensitive changes

Not all changes carry the same risk. Authentication, authorization, IAM bindings, network policies, secrets handling, data classification, and external integrations need extra scrutiny.

Source: Avanza Technical Security Requirements.

When reviewing those changes, ask:

- Does the [threat model](/avanza/threat-modeling.md) still hold?
- Does this expand what the service can reach (blast radius)?
- Is access control correctly applied to **new HTTP endpoints**? ([REST](/avanza/rest-authorization.md))
- Are new secrets properly managed? ([secrets](/avanza/secrets-management.md))
- Are audit logs in place for the new behavior? ([logging](/avanza/logging-tokens.md))

Security-sensitive merge requests deserve more careful review. Four-eyes on production-bound branches: [GitLab CI](/avanza/gitlab-ci.md).
