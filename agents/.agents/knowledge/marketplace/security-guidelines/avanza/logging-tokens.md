---
type: Avanza Guideline
title: Logging and audit
description: Never log PII, session tokens, or credentials. csid is the only cookie allowed in logs. Do log security-sensitive actions.
tags: [avanza, logging, cstoken, csid, pii, audit]
---

# Error handling and audit logging (High)

Assume logs will be read by people who should not have access to the service.

Source: Avanza Technical Security Requirements.

- **Never log PII**, session tokens, or credentials.
- The only cookie approved for logging is `csid` (session tracing without session access). `cstoken` is the primary session credential and must **never** be logged.
- Never log `Authorization` / `Bearer` values.
- **Do log security-sensitive actions** (authz denials, impersonation, privilege changes, money movement) without embedding PII or secrets.

### Flag

```java
log.info("incoming request, cookies={}", request.getHeader("Cookie"));   // FLAG (may include cstoken)
log.debug("token={}", cstoken);                                          // FLAG
log.info("customer={}", personnummer);                                   // FLAG: PII
MDC.put("cstoken", cstoken);                                             // FLAG
log.info("req={}", request);                                             // FLAG: investigate
```

### Safe

```java
log.info("session csid={}", csid);   // OK
```

See also [PII](/avanza/identity-and-pii.md).
