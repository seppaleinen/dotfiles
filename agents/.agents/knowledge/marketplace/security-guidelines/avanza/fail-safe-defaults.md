---
type: Avanza Guideline
title: Fail-safe defaults
description: If an access-control dependency is down, deny. Fail-open turns an outage into a bypass.
tags: [avanza, fail-closed, availability, authorization, rate-limiting]
---

# Fail-safe defaults (High)

If the system relies on an external dependency for access control, the default when that dependency is unavailable must be **deny**, not allow. Applies to auth services, policy engines, rate limiters — anything that gates access. Fail-open means an outage in one system becomes a security bypass in yours.

Source: Avanza Technical Security Requirements.

### Flag

```java
try {
    return policyEngine.allow(request);
} catch (PolicyUnavailableException e) {
    return true;  // FLAG: fail-open
}
```

Catch-all that skips authz/rate-limit on timeout. Feature flags that disable auth in non-test code.

### Safe

```java
try {
    return policyEngine.allow(request);
} catch (PolicyUnavailableException e) {
    log.warn("policy engine unavailable, denying");
    return false;  // deny
}
```

Deny (401/403/429) when the gate cannot be evaluated. Log the failure without PII — [logging](/avanza/logging-tokens.md).
