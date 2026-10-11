---
type: Avanza Guideline
title: Secrets management
description: No secrets in source, config files, or image-baked env. Use Vault or GCP Secret Manager. Have emergency and regular rotation.
tags: [avanza, secrets, vault, secret-manager, rotation]
---

# Secrets management (High)

If Avanza source leaked, it must not compromise systems.

Source: Avanza Technical Security Requirements.

- Store secrets in **Vault** or **GCP Secret Manager** — never in source, config files, or environment variables baked into images.
- Document both **emergency rotation** (leaked secret) and **regular rotation** (long-lived credentials on a cadence). The question is whether you can rotate without downtime when a leak happens.

### Flag

Hardcoded passwords/keys, `secure_files`, committed `.env` with prod secrets, SA JSON keys in the repo, secrets in Docker `ENV`.

### Safe

Workload Identity / short-lived credentials. Rotation runbook exists. See [GitLab CI](/avanza/gitlab-ci.md), [environment separation](/avanza/environment-separation.md).
