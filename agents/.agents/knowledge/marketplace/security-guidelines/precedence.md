---
type: Playbook
title: How to apply these guidelines
description: Follow the Avanza Technical Security Requirements. Load matching avanza/ concepts. Use model knowledge of bug classes when you need more detail to investigate.
tags: [avanza, precedence, how-to]
---

# How to apply these guidelines

Follow the **Avanza Technical Security Requirements** under [avanza/](/avanza/) (Team AppSec and Security Champions, RFC). Load matching concepts. That is what to apply.

Most controls should already come from the platform (Java platform, CI templates, base images, GCP Org Policies). [avanza/](/avanza/) is the judgment layer. Challenge stale items via AppSec / Security Champions — [culture and support](/avanza/culture-and-support.md).

When you need more on a bug class or framework pattern (how injection looks in this stack, what a framework already mitigates), use what you know. If that detail conflicts with an Avanza concept, follow Avanza.

Cite loaded material as `[ref: security-guidelines]`.

## Out of scope

Repo-local conventions stay in that repo’s `AGENTS.md`. Review workflow (confidence, report format) lives in the `security-review` skill.
