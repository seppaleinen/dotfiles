---
type: Avanza Guideline
title: CSRF and HTTP methods
description: State-changing REST endpoints must use verb-specific mappings, not @RequestMapping that accepts GET.
tags: [avanza, csrf, spring, requestmapping, rest]
---

# CSRF protection (High)

All REST endpoints that modify resources must be CSRF-protected by using the correct HTTP method annotation. Do not use `@RequestMapping` for state-changing operations — use `@PostMapping`, `@PutMapping`, `@DeleteMapping`, and so on.

Source: Avanza Technical Security Requirements.

### Flag

```java
@RequestMapping("/transfer")                                       // FLAG: accepts GET
public void transfer(@RequestParam long to, @RequestParam BigDecimal amount) { ... }

@RequestMapping(value = "/account", method = {RequestMethod.GET, RequestMethod.POST})  // FLAG: mixed
public Account upsert(...) { ... }
```

### Safe

```java
@PostMapping("/transfer")
public void transfer(...) { ... }
```

`@RequestMapping` is fine for read-only `GET` resources.
