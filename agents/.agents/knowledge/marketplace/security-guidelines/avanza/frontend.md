---
type: Avanza Guideline
title: Frontend (CSP and safe rendering)
description: Browser pages need CSP that blocks non-Avanza script. Treat all backend and client data as untrusted. Do not bypass Angular sanitization.
tags: [avanza, frontend, csp, xss, angular, avanza-se, aza-nu]
---

# Frontend (High)

Frontend runs in a browser we do not control. Protect customers (`avanza.se`) and colleagues (`aza.nu`) against XSS, DOM injection, token theft, and session hijacking.

Source: Avanza Technical Security Requirements. Not a concern for normal (non-browser) subsystems.

## Content Security Policy

All user-facing pages intended for a web browser must set a CSP that blocks script execution outside Avanza-specified code.

### Flag

Missing CSP on a browser-served app. `unsafe-inline` / `unsafe-eval` without a documented exception. CSP only on some environments.

## Safe rendering

All data from backends or client-side sources is untrusted. Use Angular’s built-in escaping. Never bypass it with `innerHTML` or `bypassSecurityTrustHtml()`. If raw HTML is unavoidable, use Angular `DomSanitizer`.

### Flag

```typescript
element.innerHTML = backendHtml;                    // FLAG
this.sanitizer.bypassSecurityTrustHtml(userHtml);   // FLAG unless DomSanitizer + documented need
```

### Safe

Angular template interpolation / bindings. `DomSanitizer` only after an explicit sanitization path.
