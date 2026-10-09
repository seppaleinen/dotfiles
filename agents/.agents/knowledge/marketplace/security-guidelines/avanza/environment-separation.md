---
type: Avanza Guideline
title: Environment separation
description: No production secrets or config in non-prod. No real customer data in tests without anonymization or synthetic substitution.
tags: [avanza, environment, testdata, secrets, production]
---

# Environment separation (High)

Production secrets, credentials, and configurations must not be used in non-production. Real customer data must not be used in test environments without anonymization or synthetic substitution.

Source: Avanza Technical Security Requirements.

### Flag

- Production hosts in test/sample config (`apollo.host=apollo.prod.aza.nu`).
- Real customer data in `src/test/resources/**` (`personnummer` as `YYYYMMDD-NNNN`, names, emails not from `@example.com` / `@avanza-test.se`).
- `if (env.equals("prod"))` to *enable* validation — keep validation always-on; extra hardening in prod is OK, skipping it in dev is not.
- Production secrets in committed dev `.env` files.

See also [secrets](/avanza/secrets-management.md), [PII](/avanza/identity-and-pii.md).
