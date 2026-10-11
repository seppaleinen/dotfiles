---
type: Avanza Guideline
title: Input validation and defensive programming
description: Treat all input as hostile. Validate origin, size, lexicon, syntax, and semantics. Prefer domain types over raw String/int. Write negative tests.
tags: [avanza, validation, domain-types, defensive-programming, backend]
---

# Input validation and defensive programming (High)

Every subsystem must treat all input as hostile and enforce validation and authorization at every boundary. If a request can mutate state or access data, the service must ensure it is allowed and well-formed.

Source: Avanza Technical Security Requirements.

For every piece of data entering the service, check as applicable:

| Check | Question |
|-------|----------|
| Origin | Trusted sender? |
| Size | Reasonably sized? |
| Lexical | Expected characters and encoding? |
| Syntax | Correct format? |
| Semantic | Makes sense in the domain? |

Program as if every input, dependency, and downstream is trying to break the function: check inputs before computation; opt-in to dangerous behavior; write **negative tests** (bad input, missing data, timeouts, unexpected state).

Prefer domain classes with rules on construction over raw `String` / `int` / `double`. An `AccountId` that validates on construct is safer than a `String` anyone might forget to validate. Validation is **not** a substitute for [parameterized queries](/avanza/parameterized-queries.md) or [REST access control](/avanza/rest-authorization.md).

### Flag

Passing request `String`s straight into queries, paths, or downstream calls. Catch-and-ignore on invalid input. Missing max-size on collections/bodies.

### Safe

```java
public class DocumentId {
    private final String id;
    public DocumentId(String id) {
        if (!isValid(id)) {
            throw new IllegalArgumentException("Invalid documentId");
        }
        this.id = id;
    }
    private boolean isValid(String id) {
        if (id == null) return false;
        if (id.length() < 10 || id.length() > 24) return false;
        return id.matches("[0-9a-f]*");
    }
}
```

Do not return exception messages that embed raw input as `text/html` to browsers.
