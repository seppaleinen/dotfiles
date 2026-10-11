---
type: Avanza Guideline
title: Incident readiness
description: Documented break-glass, secret rotation, escalation, and recovery. Enough logs to investigate. Annual DR exercise. Unknown endpoints are tech debt.
tags: [avanza, incident, break-glass, disaster-recovery, runbooks]
---

# Incident readiness

Source: Avanza Technical Security Requirements.

- **Break-glass**: how to get emergency access; escalation path. Each team needs runbooks for break-glass, secret rotation, escalation, and service-specific recovery.
- **Logs and postmortems**: enough logging to investigate, without PII/tokens ([logging](/avanza/logging-tokens.md)). After an incident, blameless postmortem — [culture](/avanza/culture-and-support.md).
- **Disaster recovery**: exercise annually. Table-top or controlled tests that playbooks exist and are current. [Backups](/avanza/backups.md).
- **Know your code**: inherited services and rotation. If you cannot vouch that every exposed endpoint has correct validation and access control, treat that as high-priority tech debt.
