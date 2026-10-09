---
type: Avanza Guideline
title: Threat modeling
description: Design-time security. Ask blast radius and which controls contain it. Keep the threat model current; use it as NPaP risk-workshop input.
tags: [avanza, threat-model, design, npap, blast-radius]
---

# Threat modeling

Primary design-time security tool. A living document — update it when architecture, integrations, or controls change. When NPaP applies, the threat model is input for the risk workshop.

Source: Avanza Technical Security Requirements.

Answer:

1. What is the worst thing that happens if this service is fully compromised? (blast radius)
2. What do we believe prevents or contains that? (controls as hypotheses)

### When to load this

New service, new trust boundary, new external integration, IAM/network change, or an explicit threat-model / NPaP / architecture review. Do not flag every line-change PR for a missing threat model.

### Flag

A new outbound integration that sends customer PII to a third party (for example a KYC vendor keyed on `personnummer`) with no threat-model update — blast radius and controls were never written down.

A new Apollo client allowlist of `*` or a new public REST surface with no note on what a full compromise enables.

### Safe

The change is documented in the living threat model, for example:

- **Blast radius:** an attacker who fully compromises this service can call the KYC vendor as any onboarded customer and read the vendor response.
- **Controls (hypotheses):** [KYC/account-status check](/avanza/identity-and-pii.md) before the call; Vault/Secret Manager for vendor credentials; mesh allowlist of intended callers; timeout and rate limit.

If the change expands blast radius and there is no updated threat model, say so and point at the wiki. Sensitive-change checklist: [sensitive changes](/avanza/sensitive-changes.md).

Further reading: [Threat modeling](https://wiki.avanza.se/spaces/UTV/pages/338986613/Threat+modeling).
