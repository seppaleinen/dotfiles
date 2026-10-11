---
type: Avanza Guideline
title: SECURITYGROUPS
description: Internal admin portals must authorize via Active Directory SECURITYGROUPS with appropriate granularity, not custom roles or hard-coded usernames.
tags: [avanza, securitygroups, authorization, admin, aza-nu]
---

# Internal admin auth (Medium)

Internal admin/back-office portals (`*.aza.nu`) must use specific Active Directory access groups with appropriate granularity. Do not use a custom role table or hard-coded usernames.

Source: Avanza Technical Security Requirements. Generic Spring `@PreAuthorize("hasRole('ADMIN')")` is **not** sufficient unless it maps to `SECURITYGROUPS`.

### Flag

```java
if (user.getUsername().equals("admin")) { ... }                    // FLAG
if (Set.of("alice", "bob").contains(user.getUsername())) { ... }   // FLAG
@PreAuthorize("hasRole('ADMIN')")  // FLAG: if not backed by SECURITYGROUPS mapping
```

Also flag `bootstrap.aza.nu` integrations bypassed by a local debug toggle in non-test code.

### Safe

```java
@PreAuthorize("hasAuthority('SECURITYGROUPS/Tech/AppSec/Reviewer')")
```

Further reading: [AD group role assignment](https://wiki.avanza.se/spaces/IUD/pages/163088627/Beh%C3%B6righetsstyrning+f%C3%B6r+sidor+genom+roll-s%C3%A4ttning+AD-grupper).

See also [centralized authentication](/avanza/centralized-auth.md).
