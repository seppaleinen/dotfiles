---
type: Avanza Guideline
title: REST access control
description: Check ownership in the REST controller. Every user-supplied ID must be authorized for the authenticated caller. Do not assume Apollo or downstream will do it.
tags: [avanza, rest, idor, authorization, restuser, access-control]
---

# Access control — REST (High)

Check ownership and authorization in the **controller** of REST applications. Do not assume services further downstream do it. This is one of the most common pen-test findings: a missing check that lets one customer access another’s data (IDOR).

Rule of thumb: every endpoint that takes a user-supplied identifier (account ID, entity ID, customer ID) must verify the authenticated caller is authorized for **that** resource.

Every REST endpoint has the client’s customer ID via `RestUser`. Use it before returning or mutating data.

Some Apollo services take `CustomerId` — that is often sharding only. Do **not** treat it as an authorization check. See [Apollo](/avanza/apollo-authorization.md).

Source: Avanza Technical Security Requirements.

### Flag

```java
@GetMapping("/applications/{applicationId}")
public ApplicationDTO get(@PathVariable Long applicationId) {
    return repo.findById(applicationId);  // FLAG: no ownership check
}
```

### Safe

```java
@GetMapping("/applications/{applicationId}")
public ApplicationDTO getApplicationById(
        @PathVariable Long applicationId, RestUser restUser) {
    Integer customerId = restUser.getAuthenticatedCustomerId().value();
    if (!checkAccess(applicationId, customerId)) {
        throw new NotFoundException();  // same response as missing — no oracle
    }
    // fetch data
}
```

Prefer `NotFound` over `Forbidden` when the resource must not be shown to exist for other customers.

See also [centralized authentication](/avanza/centralized-auth.md).
