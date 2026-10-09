---
type: Avanza Guideline
title: Apollo authorization
description: Limit Apollo services to intended callers. CustomerId is sharding, not ownership — REST must still check access.
tags: [avanza, apollo, idor, authorization, customerid, mesh]
---

# Access control — Apollo (High)

Internal-facing endpoints (Apollo services) must be limited to **intended systems**. Do not expose an internal API to the entire network if only one or two services need it. Enforce with network policies, service mesh rules, or API gateway config.

Apollo `CustomerId` is often a routing/sharding parameter only. **Do not trust it as authorization.** The caller’s identity must be verified to own that `CustomerId`. REST controllers must still check ownership themselves — see [REST access control](/avanza/rest-authorization.md).

Source: Avanza Technical Security Requirements.

### Flag

```java
public Holdings getHoldings(GetHoldingsRequest req) {
    return holdingsRepo.findByCustomerId(req.getCustomerId());   // FLAG: no ownership check
}
```

Apollo `service.yaml` / mesh: `allowedClients: ["*"]` (or equivalent allow-all).

### Safe

```java
public Holdings getHoldings(GetHoldingsRequest req, CallerContext ctx) {
    authz.requireOwnership(ctx, req.getCustomerId());
    return holdingsRepo.findByCustomerId(req.getCustomerId());
}
```

Explicit caller allowlist; mesh rate limiting where available — see [compartmentalization](/avanza/compartmentalization.md).

Further reading: [Access to non-default apps against my Apollo service](https://wiki.avanza.se/spaces/IUD/pages/225444836/Ge+access+till+icke-default+appar+mot+min+Apollo+tj%C3%A4nst).
