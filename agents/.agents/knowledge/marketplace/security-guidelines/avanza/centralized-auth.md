---
type: Avanza Guideline
title: Centralized authentication
description: Do not roll your own authentication. Use platform @LoggedIn for customer REST. Internal admin portals use Active Directory SECURITYGROUPS.
tags: [avanza, authentication, loggedin, spring, rest]
---

# Centralized authentication (High)

Do not roll your own authentication. Use the centralized, audited platform components.

Customer-facing REST: `@LoggedIn` and `RestUser`. Internal admin (`*.aza.nu`): [SECURITYGROUPS](/avanza/securitygroups.md).

`@LoggedIn` is **not** a substitute for resource ownership checks ([REST access control](/avanza/rest-authorization.md)) or for KYC when using `personnummer` ([PII](/avanza/identity-and-pii.md)).

Source: Avanza Technical Security Requirements.

### Flag

Custom session/JWT parsers, homemade password checks, or auth bypass flags in non-test code.

### Safe

```java
@LoggedIn
@GetMapping("/my-endpoint")
public void myEndpoint(RestUser user) {
    // Authentication handled by @LoggedIn
}
```
