---
name: contract-analysis
description: Shared methodology for parsing an architecture contract into testable behaviors — endpoints, fields, state machines, error states, and ambiguities. Used by plan-auditor (primary) and adversarial-tester (secondary). Load when a contract/spec must be decomposed into verifiable claims.
---

# Contract Analysis

Methodology for turning an architecture contract (from `dev-architect`) into a complete inventory of testable behaviors, and — critically — into an inventory of behaviors the contract *forgot* to specify.

The contract is a **claim set**, not a source of truth. Every clause is a claim that something will be true. The job of contract analysis is to make the claim set explicit, finite, and auditable — so that "what the plan didn't take into account" becomes a list, not a feeling.

## 1. Extract the Claim Set

Parse the contract into atomic claims. Each claim is one testable assertion about the system:

| Contract section | Extract as |
|---|---|
| Backend API spec | One claim per endpoint × per field × per error state. `POST /users` is not one claim — it is: "accepts a body", "returns 201 with the created user", "each field has type X", "each error state E returns status S" |
| Frontend component spec | One claim per interaction (onClick, onSubmit), per state (loading/empty/error/success), per visual behavior |
| Data model impact | One claim per field constraint, per relationship, per migration step |
| Integration verification criteria | These are the contract's *own* acceptance claims — use them as the outer shell of the test plan, then push outward from them |

**Rule:** if a clause cannot be turned into a yes/no claim ("handle errors appropriately"), it is ambiguous — record it, do not resolve it silently.

## 2. Field-by-Field Inventory

For every request/response field in the contract, fill this table:

| Field | Type | Required? | Constraints | Valid example | Invalid examples | Error behavior when invalid |
|---|---|---|---|---|---|---|
| `email` | string | yes | valid email | `a@b.co` | `a@b`, `a@.co`, `""` | 422 (specified?) |

The **last column is the one contracts almost never fill in.** An empty cell is not "no behavior needed" — it is a gap. Flag every empty error-behavior cell.

## 3. State Machine Extraction

For every entity whose state changes:

1. Draw the transitions the contract names.
2. Compute the **closure**: the set of all state pairs (from, to). The contract names some; the *difference* between all pairs and the named pairs is the "unspecified transition" set.
3. For each unspecified pair, ask: *should this be possible, or should it be rejected, and with what response?* If the contract doesn't say, it is a gap.

Typical misses: reopen from closed, cancel from completed, concurrent transitions, idempotency of repeated transitions.

## 4. Implicit Assumption Sweep

Contracts silently assume. Force these assumptions to the surface:

- **Idempotency** — what happens when the same request arrives twice? (duplicate order, double-submit)
- **Concurrency** — two valid, conflicting operations at the same instant: which wins, does the loser get an error, is the system consistent?
- **Ordering** — do operations depend on sequence? What if they arrive out of order?
- **Time** — what happens across a day/week/month boundary, a timezone, a clock skew?
- **Scale** — does the contract hold at 10 records and at 1,000,000? Pagination, limits, partial results.
- **Deletion semantics** — cascade? soft delete? what references a deleted entity?
- **Backward compatibility** — do old clients/old data still work after this change?
- **Permissions** — every claim about data access: who else can see/mutate this data? (This is where BOLA lives.)

For each: if the contract is silent, it is a gap to report — with the specific scenario spelled out so the architect can decide, not a vague "consider concurrency."

## 5. Gap Report Format

Findings are structured, not prose:

```
GAP: <entity/endpoint> | <scenario in one sentence> | <why it matters — the failure that results if unhandled> | <severity: High/Med/Low>
```

Severity:
- **High** — the gap can cause data loss, a security hole, or a user-visible failure.
- **Med** — the gap causes an unclear or inconsistent user experience.
- **Low** — the gap is a documentation/clarification issue.

A gap report with no severity assignments is a wish list, not a gate.

## 6. What This Is NOT

- Not a review of whether the plan is *good* — only whether it is *complete*.
- Not implementation. No code, no suggested fixes. The contract is the input; the claim set and the gap list are the output.
- Not a substitute for the architect's judgment. Gaps are *questions the contract owes an answer to*, each phrased concretely enough that an answer is a one-line spec addition.
