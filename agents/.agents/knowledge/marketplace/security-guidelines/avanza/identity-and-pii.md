---
type: Avanza Guideline
title: Minimize PII
description: Do not handle, log, key, or leak more PII than needed. Never use personnummer, name, or email as a database key. Oracle responses and KYC checks apply when PII is a lookup.
tags: [avanza, pii, personnummer, gdpr, kyc, oracle, database]
---

# Minimize use of PII (High)

Do not handle Personally Identifiable Information unless you genuinely need it. Do not send more PII than required in service responses. Do not ask for more PII than required when calling backends.

All production data is assumed restricted (customer/PII) unless classified otherwise — see [data classification](/avanza/data-classification.md). Source: Avanza Technical Security Requirements.

## Never use PII as a database key

Use `CustomerId` / `PartyId`. Never `personnummer`, name, or email as a primary key or join key.

### Flag

```java
@Entity
public class CustomerProfile {
    @Id
    private String personnummer;     // FLAG: PII as PK
}

@Query("SELECT p FROM Profile p WHERE p.personnummer = :pnr")  // FLAG (key, not filter)
Profile findByPersonnummer(@Param("pnr") String pnr);
```

```sql
CREATE TABLE profile (personnummer VARCHAR(12) PRIMARY KEY, ...);  -- FLAG
```

### Safe

```java
@Id private long customerId;   // or PartyId
```

When PII must be stored, put it in separate tables behind explicit access boundaries and look up via internal identifiers.

## Never log or stash PII

Never print PII in logs or stdout. Never store PII on disk outside dedicated storage (for example cache files on shared hosts). See [logging](/avanza/logging-tokens.md).

## Customer rights

- Marketing, profiling, or automatic decisions based on PII must let the customer object and disable it.
- Systems must allow removal of customer data on request. Persist the relevant data in one place and reference it via internal identifiers.
- New features that persist PII must support customer data export.

## Existence oracle (side channel)

We must not disclose whether a given person is a customer. Any API that takes an email, `personnummer`, or similar identifier must return the **same** response whether that identifier exists or not.

### Flag

```java
if (!customerRepo.existsByEmail(email)) {
    return ResponseEntity.status(404).body("Unknown customer");  // FLAG: oracle
}
```

### Safe

Same status, body shape, and timing whether the identifier exists. Do not leak via distinct error messages or sleep-on-miss.

## personnummer as a third-party lookup (High)

When you must use PII (typically `personnummer`) as a lookup key — for example a third-party system keyed on it — `@LoggedIn` is **not** sufficient. An attacker can start onboarding, obtain a partially-created account tied to an arbitrary `personnummer`, then hit any endpoint that only checks `@LoggedIn`.

Endpoints that operate on a `personnummer` (or use it to reach third parties) must also verify the authenticated customer is fully onboarded — account status active **and** KYC complete — before the operation. Treat "logged in" and "fully vetted customer" as two distinct checks. Do not rely on downstream systems to enforce this.

### Flag

```java
@LoggedIn
@PostMapping("/kyc-lookup")
public void lookup(RestUser user, @RequestParam String personnummer) {
    thirdParty.lookup(personnummer);  // FLAG: no KYC / account-status check
}
```

### Safe

```java
@LoggedIn
@PostMapping("/kyc-lookup")
public void lookup(RestUser user, @RequestParam String personnummer) {
    requireActiveAccountAndKyc(user);  // explicit second check
    thirdParty.lookup(personnummer);
}
```

Further reading: [Logging of personal data](https://wiki.avanza.se/spaces/IUD/pages/4981083/Riktlinje+Loggning), [GDPR definitions](https://wiki.avanza.se/spaces/GDPR/pages/66821228/Avanzas+GDPR-definitioner), [Data portability](https://wiki.avanza.se/spaces/GDPR/pages/66821232/Dataportabilitet).
