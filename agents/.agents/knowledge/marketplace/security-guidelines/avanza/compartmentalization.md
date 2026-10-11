---
type: Avanza Guideline
title: Compartmentalization
description: Limit blast radius with timeouts, mesh and app rate limits, bulkheads, and circuit breakers. Watch capacity asymmetry on fan-out.
tags: [avanza, timeouts, rate-limiting, circuit-breaker, blast-radius, apollo]
---

# Compartmentalization (Medium)

Separate services to minimize blast radius. Catastrophic failures happen when smaller faults chain. Denial of service through overload is a significant risk.

Source: Avanza Technical Security Requirements.

- **Rate limiting**: internal and external APIs. Apollo should rate-limit at the service mesh where available, plus in-app domain throttling.
- **Capacity asymmetry**: if a REST app calls multiple downstreams that fan out further, load grows exponentially. Know whether this service can take the same load as its callers.
- **Failure isolation**: timeouts, circuit breakers, bulkheads — one failing dependency must not take down the whole service.

### Flag

- HTTP/Apollo client without an explicit timeout:
  ```java
  RestTemplate rt = new RestTemplate();   // FLAG: default = infinite
  HttpClient.newHttpClient();             // FLAG: no .connectTimeout(...)
  WebClient.create();                     // FLAG: no responseTimeout
  ```
- Public/edge REST controllers without rate limiting (no `@RateLimited`, Bucket4j/Resilience4j, or mesh config).
- Fan-out loops without batching/parallel cap when `ids` size is user-controlled:
  ```java
  for (Id id : ids) downstream.fetch(id);   // FLAG
  ```
- Missing circuit breaker / fallback on calls to *another team's* service.

See also [Apollo](/avanza/apollo-authorization.md).
