---
type: Avanza Guideline
title: Impersonation rights
description: Sensitive customer REST actions must declare @ImpersonationRightsRequired and audit who acted in impersonated mode.
tags: [avanza, impersonation, spring, rest, crm]
---

# Impersonation controls (High)

Avanza employees can impersonate customers via CRM. Default impersonation gives **full** customer capabilities. For sensitive operations the REST layer must require explicit impersonation permissions via `@ImpersonationRightsRequired`. Log when operations run in impersonated mode **and by whom**.

Source: Avanza Technical Security Requirements.

### Sensitive operation indicators (any of)

- Method/path contains: `order`, `placeOrder`, `cancelOrder`, `transfer`, `withdraw`, `deposit`, `payment`, `corporateAction`, `subscribe`, `powerOfAttorney`, `poa`, `signing`, `sign`
- HTTP verb is `POST`/`PUT`/`DELETE`/`PATCH` against an account/holdings/orders resource

### Flag

```java
@PostMapping                                // FLAG: state-changing, no @ImpersonationRightsRequired
public Order place(@RequestBody OrderDto o) { ... }
```

Impersonated actions with no audit of actor + customer.

### Safe

```java
@PostMapping
@ImpersonationRightsRequired(ImpersonationRight.PLACE_ORDER)
public Order place(...) { ... }
```

Do not log `cstoken` or PII in that audit line — see [logging](/avanza/logging-tokens.md).
