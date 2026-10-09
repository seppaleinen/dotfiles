---
type: Avanza Guideline
title: Data classification
description: All production data is restricted (customer/PII) unless explicitly classified otherwise. If in doubt, treat as PII.
tags: [avanza, pii, classification, gdpr, encryption]
---

# Data classification

All data in production is assumed **restricted (customer/PII)** unless explicitly classified otherwise. That drives encryption, logging, access-control granularity, and retention. GDPR wiki has the authoritative definitions. If in doubt, treat it as PII until clarified.

Source: Avanza Technical Security Requirements.

Handling rules: [minimize PII](/avanza/identity-and-pii.md), [logging](/avanza/logging-tokens.md).

### Flag

```java
log.info("lookup email={}", email);   // FLAG: prod data is restricted until classified otherwise
```

A GCS bucket or log sink for “debug” that holds production holdings, orders, or identifiers and is treated as non-PII because nobody labelled it.

A new table or topic with customer fields shipped without a classification decision (default is restricted).

### Safe

Treat unclassified production data as restricted. Put PII behind explicit access boundaries and internal ids — [minimize PII](/avanza/identity-and-pii.md). Do not log it.

Further reading: [Avanza GDPR definitions](https://wiki.avanza.se/spaces/GDPR/pages/66821228/Avanzas+GDPR-definitioner).
