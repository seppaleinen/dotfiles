---
name: test-generation
description: Shared test-writing methodology for test-engineer, adversarial-tester, and plan-auditor. State enumeration, error paths, boundaries, negative inputs, result classification, and test file organization. Load when generating or analyzing tests from a contract, spec, or implementation.
---

# Test Generation

Shared methodology for the three test agents. Each agent applies these patterns through its own frame of mind:

| Agent | Frame of mind | Question |
|---|---|---|
| `test-engineer` | Verification | "Does this work as expected?" |
| `adversarial-tester` | Falsification | "Where does this break?" |
| `plan-auditor` | Spec-completeness | "What didn't the plan think about?" |

The patterns below are frame-of-mind-neutral. The loading agent decides how aggressively to apply them.

## 1. State Transition Enumeration

Before writing any tests, enumerate every state an entity can be in and every transition between states.

**Method:**
1. List every entity whose state changes during the flow (e.g., order, user, ticket, connection).
2. For each entity, list every explicit state from the contract (`open → in-progress → resolved → closed`).
3. Enumerate every transition: valid (explicitly specified) and invalid (unspecified — what should happen?).
4. For each transition, note:
   - Trigger (which action causes it)
   - Preconditions (what must be true before)
   - Postconditions (what must be true after)
   - Side effects (events emitted, records created/updated)

**Test rule:** every valid transition gets a test. Every *unspecified* transition gets a test that asserts the expected rejection — and if the contract is silent on the rejection behavior, that is a gap to report, not a test to guess.

## 2. Error Path Enumeration

Every input boundary, external dependency, and state mutation has a failure mode. Enumerate before writing tests:

| Category | Failure modes to enumerate |
|---|---|
| Input validation | Missing required field, wrong type, empty string, null, oversized, invalid format (bad email, bad date), out-of-range numeric |
| External dependencies | Timeout, 5xx response, malformed response, connection refused, partial failure |
| State mutations | Concurrent modification, double-submit, operation on already-changed state |
| AuthN/AuthZ | No credentials, expired token, valid credentials but wrong permission, self vs. other user's resource |
| Resource limits | Rate limit hit, quota exceeded, disk full, pool exhausted |

**Test rule:** every enumerated failure mode gets a test asserting the *contract's* error behavior (status code, message shape, state). If the contract specifies no behavior for a failure mode, do not guess — record it as a contract gap.

## 3. Boundary Value Generation

For every numeric, length, or collection constraint in the contract:

| Constraint | Test values |
|---|---|
| `min: N` | `N-1`, `N`, `N+1` |
| `max: N` | `N-1`, `N`, `N+1` |
| length limit | 0, 1, limit, limit+1 |
| collection | empty, single, maximum, maximum+1 |
| string | empty, single char, valid, whitespace-only, unicode edge (emoji, combining chars, RTL) |
| numeric | 0, -1, 1, max safe value, float precision loss |

**Test rule:** boundaries are the first place implementations drift from contracts. Every boundary pair (valid/invalid neighbor) gets a test.

## 4. Negative Input Generation

Beyond validation failures, generate inputs that are *well-formed but semantically wrong*:

- Valid email belonging to a different user (authorization confusion)
- Valid ID that does not exist (404 vs 500 distinction)
- Valid payload with fields that are valid individually but inconsistent as a combination (e.g., `startDate > endDate`)
- Duplicate submission of an idempotent operation
- Valid request with headers that change routing (tenant, locale, version)
- Inputs that trigger implicit defaults (missing optional field vs. explicit null)

**Test rule:** each semantically-wrong-but-well-formed input gets a test asserting which error the contract promises. Unpromised behavior is a gap.

## 5. Test Result Classification

Every generated test lands in exactly one bucket:

| Bucket | Meaning | Action |
|---|---|---|
| `COVERED` | Contract specifies behavior, test verifies it, implementation matches | Pass — done |
| `FAILING` | Contract specifies behavior, test written, implementation does not match | Bug — report with exact contract clause |
| `UNSPECIFIED` | Implementation has behavior the contract does not mention | Ambiguity — flag for contract clarification |
| `GAP` | Contract is silent on a failure mode or edge case | Gap — report to architect/lead |

Classification drives the handover:
- `test-engineer` reports `COVERED` count and `FAILING` details.
- `adversarial-tester` reports `FAILING` details and `UNSPECIFIED` findings.
- `plan-auditor` reports `UNSPECIFIED` and `GAP` findings (it cannot evaluate `COVERED`/`FAILING` — it has no implementation).

## 6. Test File Organization

Follow the project's existing conventions (from the language skill / `stack-context.md`). Defaults when no convention exists:

- Unit tests colocate with or mirror the source structure.
- Integration tests live in a dedicated `tests/integration/` or `*_test` equivalent.
- Test names state the behavior, not the mechanism: `returns 422 when email is malformed`, not `testEmailValidation`.
- One behavioral assertion per test where reasonable; a test that fails should tell you exactly which contract clause broke.
- No arbitrary sleeps — use deterministic polling or event synchronization for async flows.
- Tests must be rerunnable in a clean environment (no state leakage between tests, explicit teardown).

## 7. Anti-Patterns

- **Testing the implementation, not the contract.** If a test breaks when the implementation changes internals but behavior is unchanged, the test is wrong.
- **Weak assertions.** `expect(result).toBeTruthy()` when a specific field is checkable — always assert the specific value.
- **Happy-path-only suites.** If a test file has no error-path tests, it is incomplete.
- **Mocking the behavior under test.** If the mock *is* the logic being tested, the test proves nothing.
- **Guessing contract silence.** Unspecified behavior is a gap to report, not a behavior to encode silently into a test.
