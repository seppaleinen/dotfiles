---
type: Avanza Guideline
title: Parameterized queries
description: All database, LDAP, and structured queries must be parameterized or ORM-safe. Validation does not prevent injection if the query is concatenated.
tags: [avanza, injection, sql, ldap, orm, parameterized]
---

# Parameterized queries (High)

All database queries must use parameterized statements, prepared statements, or ORM-safe methods. Input validation and parameterization are **separate** layers — validation alone does not prevent (No)SQL injection if the query is string-concatenated. Same rule for LDAP and any other structured query language.

Source: Avanza Technical Security Requirements.

### Flag

```java
em.createQuery("FROM User WHERE username = '" + username + "'");  // FLAG
@Query(value = "SELECT * FROM users WHERE name = '" + name + "'", nativeQuery = true)  // FLAG
```

### Safe

Named parameters, `PreparedStatement`, Spring Data derived queries.
